# Dlaunch Tools

A simple set of tools and wrappers extending dmenu with features like
defining custom commands or sorting commands by usage.


### dlaunch

A modest wrapper around dmenu. It launches dmenu with arguments defined in
`~/.config/dlaunch-tools/dmenu-args.scm`. The config file path might differ
on your system. This is a scheme file containing exactly one list of
strings. Here is an example:

```scheme
("-fn" "xft:DejaVu Sans Mono:pixelsize=13"
 "-b" "-l" "5" "-i"
 "-nb" "#262626" "-nf" "#BCBCBC"
 "-sb" "#3A3A3A" "-sf" "#BCBCBC")
```

### dlaunch-run

This tool is like dlaunch + dmenu\_run. It allows you to define custom
commands and learns the commands you use the most. Dlaunch-run to pre-sort
the results depending on usage, before passing them to dmenu. If you stop
using a command, its importance will fade. Custom commands are defined in
the config file `~/.config/dlaunch-tools/custom-commands.scm`, though the
path on your system may differ.

You can define a list with one or more strings in this file, which will be
passed to dmenu besides the commands in your PATH directories.

```scheme
("i3-msg restart")
("notify-send \"This is a test\"")
("claws-mail -q"
 "claws-mail --receive-all")
```

You can associate a description with a command. The description will be
shown to the user and the associated command will be executed.

```scheme
("Reboot System"   . "sudo shutdown -r now")
("Suspend System"  . "sudo pm-suspend")
("Shutdown System" . "sudo shutdown -h now")
```

## Requirements

* [CHICKEN Scheme](http://call-cc.org)
* Make
* dmenu

## License

Released under the zlib license.
