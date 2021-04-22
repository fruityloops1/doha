module doha.doha;

import core.stdc.stdlib : exit;
import doha.config;
import doha.database;
import std.conv;
import std.datetime;
import std.file : exists;
import std.path : expandTilde;
import std.stdio;

void main(string[] args)
{
	string config_file = expandTilde("~/.config/.doha.sdl");
	if (!exists(config_file))
	{
		Config config = new Config();
		config.server_ip = "127.0.0.1";
		config.server_port = 6379;
		config.auth = "";
		config.use_auth = false;
		config.write_default(config_file);
	}
	Config config = new Config(config_file);
	DohaDatabase ddb;
	if (!config.use_auth) ddb = new DohaDatabase(config.server_ip, config.server_port);
	else ddb = new DohaDatabase(config.server_ip, config.server_port, config.auth);
	if (args.length < 3)
	{
		usage();
	}
	else
	{
		if (args[1] == "-r")
		{
			if (args.length == 3)
			{
				Message[] messages = ddb.get_channel_messages(args[2], 50);
				foreach (Message m; messages)
				{
					SysTime dt = SysTime(unixTimeToStdTime(m.uts));
					writeln("[" ~ dt.toSimpleString ~ "]" ~ m.message);
				}
			}
			else if (args.length == 4)
			{
				int range;
				try
				{
					range = to!int(args[3]);
				} catch(ConvException ex)
				{
					writeln("'" ~ args[3] ~ "' is not a number!");
					exit(1);
				}
				Message[] messages = ddb.get_channel_messages(args[2], range);
				foreach (Message m; messages)
				{
					SysTime dt = SysTime(unixTimeToStdTime(m.uts));
					writeln("[" ~ dt.toSimpleString ~ "]" ~ m.message);
				}
			}
			else usage();
		}
		else
		{
			string message = "";
			for (int i = 2; i < args.length; i++)
			{
				message = message ~ " " ~ args[i];
			}
			ddb.push_channel_message(args[1], message);
		}
	}
}

/**
	Print message to show usage
*/
void usage()
{
	writeln(
`Usage:
  doha <channel> [message]
  doha -r <channel> <amount>
Where:
  <channel>           Channel to push/read message to/from
  <amount>            Amount of messages to display
<option>:
  -r                  Display messages`
	);
	exit(1);
}