# Dlaunch Tools

A simple set of tools and wrappers extending dmenu with features like
defining custom commands or sorting commands by usage.


### dlaunch

This tool launches dmenu with arguments defined in
`~/.config/dlaunch-tools/dmenu-args.scm`. The config file path might differ
on your system. This is a scheme file containing exactly one list of
strings. Here is an example:

```scheme
("-fn" "xft:DejaVu Sans Mono:pixelsize=13"
 "-b" "-l" "5" "-i"
 "-nb" "#262626" "-nf" "#BCBCBC"
 "-sb" "#3A3A3A" "-sf" "#BCBCBC")
```

Dlaunch is able to learn and can sort its input stream based on popularity.
To make use of this feature, you must pass the path to a score file to
dlaunch. This can be done by the `--score-file=FILE` argument. This file
will be updated after each invocation. If the file does not exist, it will
be created after the user selects a string. The importance of each learned
string will fade from time to time, unless the user keeps selecting it.
Dlaunch aborts with an error and returns 1 if the score file contains
invalid expressions.

Here is an example, which lets the user search for a file in his home
directory:

```sh
find "$HOME" | dlaunch --score-file="$HOME/my-score-file.scm"
```

### dlaunch-run

This tool is like dlaunch combined with dmenu\_run. It allows you to define
custom commands and has the same set of learning features as dlaunch.
Custom commands are defined in the config file
`~/.config/dlaunch-tools/custom-commands.scm`. The path on your system may
differ.

In this file you can define an arbitrary amount of lists. Each list can
contain one string or more. These will be passed to dmenu, additionally to
the commands in your PATH directories. Here is an example:

```scheme
("i3-msg restart")
("notify-send \"This is a test\"")
("claws-mail -q"
 "claws-mail --receive-all")
```

You can associate a description with a command. The description will be
shown to the user and the command will be executed:

```scheme
("Reboot System"   . "sudo shutdown -r now")
("Suspend System"  . "sudo pm-suspend")
("Shutdown System" . "sudo shutdown -h now")
```

Dlaunch-run will save its metadata somewhere in your DATA directory. On
most systems this is `~/.local/share/dlaunch-tools/dlaunch-run.scm`.

## Requirements

* [CHICKEN Scheme](http://call-cc.org)
* [dmenu](http://tools.suckless.org/dmenu/)

## Installation

First you need to build dlaunch-tools using the following commands:

```sh
git clone https://github.com/AlxHnr/dlaunch-tools
cd dlaunch-tools/
make
```

Now you can install it. Here are two ways of installing dlaunch-tools:

**Globally**

```sh
sudo make install
```

**Locally**

```sh
export INSTALL_PREFIX="$HOME/.local"
make install
```

To be able to run locally installed commands from your shell, you need to
add the local binary path to your PATH variable.

One way of doing this, is to add the following line to your `~/.profile`:

```sh
export PATH+=":$HOME/.local/bin"
```

## Uninstalling

Uninstalling dlaunch-tools is almost the same as installing it. Just
replace "install" with "uninstall" when running make. Here are two examples
for both global and local installations:

```sh
sudo make uninstall

export INSTALL_PREFIX="$HOME/.local"
make uninstall
```

If you want to get rid of all the data files dlaunch-tools has created, run
these commands:

```sh
rm -vrf "$HOME/.cache/dlaunch-tools/"
rm -vrf "$HOME/.local/share/dlaunch-tools/"
```

And to get rid of your config files:

```sh
rm -vrf "$HOME/.config/dlaunch-tools/"
```

Please mind, that on your system the config file paths may differ.

## Unit Testing

For unit testing you need the [test](http://wiki.call-cc.org/eggref/4/test)
egg. Testing is as simple as running:

```sh
make test
```

This will build and run all the tests. To add a new test, just throw a
scheme script into the test/ directory.

## License

Released under the zlib license.
