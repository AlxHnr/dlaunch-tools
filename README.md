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

It will save its metadata somewhere in your DATA directory. On most systems
this is `~/.local/share/dlaunch-tools/dlaunch-run.scm`.

### dlaunch-run

This tool is like dlaunch combined with dmenu\_run. It allows you to define
custom commands and learns the commands you use the most. Dlaunch-run sorts
the results depending on their frequency. If you stop using a command, its
importance will fade. Custom commands are defined in the config file
`~/.config/dlaunch-tools/custom-commands.scm`. The path on your system may
differ.

You can define a list with one or more strings in this file, which will be
passed to dmenu additionally to the commands in your PATH directories.

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

### dlaunch-score

This tool is like dlaunch, but with the difference that it takes a path to
a score file as its first argument and uses it to sort its input before
passing it to dmenu. The score file will be updated after the user has
selected a string. If the file does not exist, it will be created.
Dlaunch-score returns 1 if the user has aborted his selection.

Here is an example, which lets the user search for a file in his home
directory:

```shell
find "$HOME" | dlaunch-score "$HOME/my-score-file.scm"
```

## Requirements

* [CHICKEN Scheme](http://call-cc.org)
* Make
* dmenu

## Installation

First you need to build dlaunch-tools using the following commands:

```
git clone https://github.com/AlxHnr/dlaunch-tools
cd dlaunch-tools
make
```

Now you can install it. Here are two ways of installing dlaunch-tools:

**Globally**

```shell
sudo make install
```

**Locally**

```shell
export INSTALL_PREFIX="$HOME/.local"
make install
```

To be able to run locally installed commands from your shell, you need to
add the local binary path to your PATH variable.

One way of doing this, is to add the following line to your `~/.profile`:

```shell
export PATH+=":$HOME/.local/bin"
```

## Uninstalling

Uninstalling dlaunch-tools is almost the same as installing it. Just
replace "install" with "uninstall" when running make. Here are two examples
for both global and local installations:

```shell
sudo make uninstall

export INSTALL_PREFIX="$HOME/.local"
make uninstall
```

If you want to get rid of all the user files dlaunch-tools has created, run
these commands:

```shell
rm -vrf "$HOME/.cache/dlaunch-tools/"
rm -vrf "$HOME/.local/share/dlaunch-tools/"
```

And to get rid of your config files:

```shell
rm -vrf "$HOME/.config/dlaunch-tools/"
```

Please mind, that on your system the config file paths may differ.

## License

Released under the zlib license.
