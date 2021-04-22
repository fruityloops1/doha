module doha.config;

import sdlang;
import std.file : read;

/**
    TOML config to load Redis Server Location and Credentials
*/
class Config
{
    /// IP of Redis Database
    public string server_ip;
    /// Port of Redis Database
    public int server_port;
    /// Authentication token/password for Redis Database
    public string auth;

    /**
        Load config from given File name
    */
    this(string file)
    {
        Tag root;
        root = parseSource(cast(string)read(file));
        server_ip = root.getTagValue!string("server", "127.0.0.1");
        server_port = root.getTagAttribute!int("server", "port", 6379);
        auth = root.getTagValue!string("auth", null);
    }

}