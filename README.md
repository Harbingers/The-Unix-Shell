<!--- logo generated with "figlet -w 52 -cf smslant jsh && echo -e "\\t\\t\\ta basic UNIX shell implementation in C"" --->

##  A BASIC UNIX SHELL IMPLEMENTATION IN C <br /><br /> [![build-status](https://travis-ci.org/jovanbulck/jsh.svg?branch=master)](https://travis-ci.org/jovanbulck/jsh) [![release](http://github-release-version.herokuapp.com/github/jovanbulck/jsh/release.svg?style=plastic)](https://github.com/jovanbulck/jsh/releases/latest) [![license](http://img.shields.io/:license-gpl3-orange.svg)](https://gnu.org/licenses/gpl.html)

## Supported options:
* -h, --help	display the help message
* -d, --debug	turn printing of debug messages on
* -n, --nodebug	turn printing of debug messages on
* -c, --color	turn coloring of jsh output messages on
* -o, --nocolor	turn coloring of jsh output messages off
* -f, --norc	disable autoloading of the ~/.jshrc file
* -l, --license	display licence information

## Supported shell grammar

The following recursive grammar is currently supported.

```
 input  :=    expr

 expr   :=    <space>expr         // expr is a logical combination of cmds
              expr<space>
              expr #comment
              "expr"
              (expr)
              expr ; expr
              expr && expr
              expr || expr
              cmd

 cmd    :=    cmd | cmd           // cmd is the unit of truth value evaluation
              cmd >> path         // note: pipe redirection get priority over explicit redirection
              cmd 2> path
              cmd > path
              cmd < path
              cmd &               *TODO not yet implemented
              comd

 comd   :=    comd option         // comd is the unit of fork / built_in
              alias               // note priority: alias > built_in > executable
              built_in
              executable_path     // relative (using the PATH env var) or absolute

 alias  :=    (expr)              // alias is a symbolic linkt to an expr
```

## Built in shell commands

The `jsh` shell can execute any executable, identified by either an absolute or relative path (using the PATH environment variable). Alongside it also supports some built_in shell commands. This is a list of currently supported built_ins:

* `cd`
* `color`
* `debug`
* `exit`
* `history`
* `shcat`
* `source`
* `alias`       // syntax: alias key "value with spaces"
* `unalias`

## Find out

 | [Configuration](https://github.com/jovanbulck/jsh/wiki/Sample-configuration-files) | [Manual](https://github.com/jovanbulck/jsh/wiki/Manual) |  
|----|----------|----------|---------|---------|
 | [<div align="center"> <img src="https://jovanbulck.github.io/jsh/icons/cog.svg"/> </div>](https://github.com/jovanbulck/jsh/wiki/Sample-configuration-files) | [<div align="center"> <img src="https://jovanbulck.github.io/jsh/icons/book.svg"/> </div>](https://github.com/jovanbulck/jsh/wiki/Manual) |
 | Step-by-step guide to build `jsh`for your own system | Configuring the shell for your own use | Online text version of the latest `man jsh` | 

##  Configuration files:
 * `~/.jshrc`: file containing commands to be executed at login
 * `~/.jsh_history`: containing the command history auto loaded and saved at login/logout
 * `~/.jsh_login`: file containing the ASCII welcome message auto printed at login of an interactive session

## Sample ~/.jsh_login file
Sample `~/.jsh_login` file:
```

hello world! This is the proof of concept jsh shell
                                      _     __ 
                                     (_)__ / / 
                                    / (_-</ _ \
                                 __/ /___/_//_/
                                |___/
```

## Sample ~/.jshrc file
<b>Note</b>:   <br />
1. a character preceded by a '\' is escaped by `jsh`'s shell expansion.  <br />
2. one can escape a arbitrary string by "quoting" it. <br />

Sample `~/.jshrc` file:
``` sh
# This example file is part of jsh: A basic UNIX shell implementation in C
#
# ~/.jshrc : file containing jsh-shell commands executed by jsh on startup of an interactive
#   sesssion. This (example) file defines a custom prompt and loads some aliases.

################ 1. define a custom prompt ################

# a simple elegant prompt "user@hostname[exit_status]::pwd$ " with max_pwd_length 25
prompt "%u@%h[%s]::%d$ " 25

# a prompt with advanced coloring enabled (see the above screenshot)
# user@hostname[exit_status]::pwd [current_git_branch]git_status_char$ with max_pwd_length 15
prompt "%B%u%n@%F{black}%h%F{reset}[%S]::%f{yellow}%d%f{reset}%f{green}%g%f{resetall}%c%$ " 15 

################ 2. define some alias key value pairs ################
# SYNTAX:       alias key "a value with spaces"
# ALT SYNTAX:   alias key value\ escape\ if\ needed

alias ls        "ls --color=auto"       # (normal syntax example)
alias ll        ls\ -lh                 # (alt syntax example)
alias clr       clear                   # (non-space-value example)
alias grep      "grep --color=auto -i"
alias q         exit
alias h         "cat ~/.jsh_history"
alias test      "echo \"this is a \\\backslash\"; echo jo&&    pwd"

################ 3. Some more examples/ideas ################

# color on
# debug off

# echo "Hi from the rc_file" # note you can use ~/.jsh_login for printing welcome messages

# source some/file/path      # e.g. an external alias_file
# source ~/.jsh_logout       # as an example of a file mixing print and other shell commands

# echo -n "welcome to jsh version "
# jsh --version
```

## Sample ~/.jsh_logout file

The content of this file is interpreted line per line by `jsh` at logout of an interactive session. It can for example be useful to print an exit message or clear the terminal screen, especially when nesting several `jsh` sessions. Note static output can be combined with the output of shell commands, as shown in the example below. (Currently this is still a bit messy as there's not yet support for a `printf` built_in and/or back ticks for command evaluation...)

Sample `~/.jsh_logout` file:
``` sh
# This example file is part of jsh: A basic UNIX shell implementation in C
#
# ~/.jsh_logout: a file containing jsh-shell commands executed by jsh when exiting
#   an interactive sesssion. This (example) file clears the screen, prints a blue ascii art
#   GNU and right to it the pid of the exited jsh and the number of history entries appended.
#
#     ,= ,-_-. =.
#    ((_/)o o(\_))          <- this is the GNU ascii art, taken from
#     `-'(. .)`-'           https://www.gnu.org/graphics/gnu-ascii2.html
#         \_/

################ 1. clear the terminal screen ################
clear

################ 2. print GNU ascii art and jsh-info ################
# NOTE: backspaces have to be '\\' escaped

printf "\\033[1;34m"        # toggle ascii art color (blue)
printf "  ,= ,-_-. =.\\n"
printf " ((_/)o o(\\_))"

printf "\\033[0m"           # toggle message color (normal)
printf "\\t############### jsh with pid "; pidof -s jsh | tr -d '\\n'
printf " exited ###############\\n"

printf "\\033[1;34m"        # restore ascii art color (blue)
printf "  `-'(. .)`-'"

printf "\\033[0m"           # toggle message color (normal)
printf "\\t############### added "; history --nb-entries | tr -d '\\n'
printf " history entries  ###############\\n"

printf "\\033[1;34m"        # restore ascii art color (blue)
printf "      \\_/\\n"
printf "\\033[0m"           # restore normal color

################ 3. Some more examples/ideas ################

# cat       # the shell won't exit till the user types ^D
# read      # (future) shell built_in that reads a single line from the user
# sl        # steam locomotive before exiting
```
This is how it looks in a terminal:

![jsh_logout_screenshot](https://cloud.githubusercontent.com/assets/2464627/4868361/33c30942-613f-11e4-889b-8adfef59ee41.png)

## Sample ~/.inputrc file

`jsh` uses the GNU `readline` library for user input line editing and history. `Readline`'s behavior can be customized by including [commands](http://cnswww.cns.cwru.edu/php/chet/readline/readline.html#SEC9) in the `~/.inputrc` file.

When `jsh` starts up, `readline` automatically reads the init file. From the [readline doc](http://cnswww.cns.cwru.edu/php/chet/readline/readline.html#SEC9):

> The name of this file is taken from the value of the environment variable INPUTRC. If that variable is unset, the default is `~/.inputrc`. If that file does not exist or cannot be read, the ultimate default is `/etc/inputrc`.

Note that in the future `jsh` will change some of `readline`'s default settings, still allowing a user to override these (by re-loading the `~/.inputrc` file after changing the defaults).

A sample `~/.inputrc` file:
```sh
#### an ~/.inputrc file demonstrating some useful 'readline' settings ####

set completion-ignore-case on           # filename matching and completion in a case-insensitive fashion (default off)
set colored-stats on                    # display possible completions using different colors to indicate their file type (default off)
set print-completions-horizontally on   # display completions with matches sorted horizontally in alphabetical order, rather than down the screen (default off)
set show-all-if-ambiguous on            # list all matching possibilities immediately instead of hitting TAB twice (default off)
set expand-tilde on                     # tilde expansion is performed on word completion (default off)
set completion-query-items number       # set the number of possible completions that determine when the user is asked whether the list of possibilities should be displayed (default 100)
set history-size number                 # set the maximum number of history entries saved in the history list (default unlimited)
```


## Get it!

<a href="https://github.com/jovanbulck/jsh/releases/latest"><img src="http://jovanbulck.github.io/jsh/icons/download_icon_right_space.png"
 alt="Download logo" title="Download latest release" align="left" /></a>

[This page](https://github.com/jovanbulck/jsh/releases/latest) provides pre-built binaries for all official `jsh` releases. To build `jsh` yourself, clone this respository, `cd` into it and execute `make`. See [the wiki page](https://github.com/jovanbulck/jsh/wiki/Compiling-and-running) for more info and dependencies overview.
