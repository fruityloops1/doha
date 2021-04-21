module doha.database;

import core.stdc.stdlib : exit;
import tinyredis;
import std.stdio;
import std.socket;

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

}