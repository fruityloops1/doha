# doha

Simple CLI "(b)logger" program. Uses Redis to store messages.

```
Usage:
  doha <channel> [message]
  doha -r <channel> <amount>
Where:
  <channel>           Channel to push/read message to/from
  <amount>            Amount of messages to display
<option>:
  -r                  Display messages

Server Config is in ~/.config/.doha.sdl`
```

You can store messages in different channels:
`doha music just heard this song called ______`
`doha work finish project by 28th`

You can display messages like this:
```
$ doha -r music
[2021-Apr-22 14:52:12] just heard this song called ______
[2021-Apr-22 14:52:50] rick astley
```

You can limit the amount of shown messages like this:
```
$ doha -r music 1
[2021-Apr-22 14:52:50] rick astley
```

The Configuration is pretty straightforward:
```
~/.config/doha.sdl

server "127.0.0.1" port=6379
auth "" use=false
```
If you use Authentication on your Redis Server, put your password in `auth` and set `use` to true.