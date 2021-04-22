module doha.database;

import core.stdc.stdlib : exit;
import tinyredis;
import std.array;
import std.conv;
import std.datetime;
import std.stdio;
import std.socket;

/**
        Stores Text and Date of a Message
*/
public struct Message
{
    long uts; /// Date of Message creation
    string message; /// Message text
}

/**
Class that connects to the Redis Server for storing Blog Data
*/
class DohaDatabase
{

    private Redis connection;

    /**
        Connect to Redis Server without Authorization
    */
    this(string address, ushort port)
    {
        connect(address, port);
    }

    /**
        Connect to Redis Server and Authorize
    */
    this(string address, ushort port, string auth)
    {
        connect(address, port);
        try
        {
            connection.send("AUTH " ~ auth);
        } catch (RedisResponseException ex)
        {
            writefln("Failed to authenticate: " ~ ex.msg);
            exit(1);
        }
    }

    private void connect(string address, ushort port)
    {
        try connection = new Redis(address, port);
        catch (SocketOSException ex)
        {
            writefln("Failed to connect to Redis Server: " ~ ex.msg);
            exit(1);
        }
    }

    /**
        Returns true if channel exists in the Database
    */
    public bool channel_exists(string channel)
    {
        return connection.send!(bool)("EXISTS doha:channels:" ~ channel ~ ":messages");
    }

    /**
        Add message to a channel
    */
    public void push_channel_message(string channel, string message)
    {
        SysTime now = Clock.currTime();
        message = message.replace("\'", "\\'");
        message = message.replace("\"", "\\\"");
        connection.send("RPUSH doha:channels:" ~ channel ~ ":messages '" ~ message ~ "'");
        connection.send("RPUSH doha:channels:" ~ channel ~ ":uts " ~ to!string(now.toUnixTime()));
    }

    /**
        Get messages from a channel
    */
    public Message[] get_channel_messages(string channel, int range)
    {
        Message[] messages;
        if (!channel_exists(channel)) return messages;
        int from = 0;
        from = cast(int)connection.send("LLEN doha:channels:" ~ channel ~ ":messages");
        Response msgs = connection.send("LRANGE doha:channels:" ~ channel ~ ":messages " ~ to!string(from - range) ~ " " ~ to!string(from));
        while (!msgs.empty())
        {
            Message m;
            m.message = cast(string)msgs.front();
            msgs.popFront();
            messages ~= m;
        }
        {
            int i = 0;
            Response utss = connection.send("LRANGE doha:channels:" ~ channel ~ ":uts " ~ to!string(from - range) ~ " " ~ to!string(from));
            while (!utss.empty())
            {
                messages[i].uts = cast(long)utss.front();
                utss.popFront();
                i++;
            }
        }
        return messages;
    }

}