<!--- logo generated with "figlet -w 52 -cf smslant jsh && echo -e "\\t\\t\\ta basic UNIX shell implementation in C"" --->

##  A BASIC UNIX SHELL IMPLEMENTATION IN C <br /><br /> [![build-status](https://travis-ci.org/jovanbulck/jsh.svg?branch=master)](https://travis-ci.org/jovanbulck/jsh) [![release](http://github-release-version.herokuapp.com/github/jovanbulck/jsh/release.svg?style=plastic)](https://github.com/jovanbulck/jsh/releases/latest) [![license](http://img.shields.io/:license-gpl3-orange.svg)](https://gnu.org/licenses/gpl.html)


##  Configuration files:
 * `~/.jshrc`: file containing commands to be executed at login
 * `~/.jsh_history`: containing the command history auto loaded and saved at login/logout
 * `~/.jsh_login`: file containing the ASCII welcome message auto printed at login of an interactive session

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

| [Installation guide](https://github.com/jovanbulck/jsh/wiki/Compiling-and-running) | [Configuration](https://github.com/jovanbulck/jsh/wiki/Sample-configuration-files) | [Manual](https://github.com/jovanbulck/jsh/wiki/Manual) |  
|----|----------|----------|---------|---------|
| [<div align="center"> <img src="https://jovanbulck.github.io/jsh/icons/wrench.svg"/> </div>](https://github.com/jovanbulck/jsh/wiki/Compiling-and-running) | [<div align="center"> <img src="https://jovanbulck.github.io/jsh/icons/cog.svg"/> </div>](https://github.com/jovanbulck/jsh/wiki/Sample-configuration-files) | [<div align="center"> <img src="https://jovanbulck.github.io/jsh/icons/book.svg"/> </div>](https://github.com/jovanbulck/jsh/wiki/Manual) |
| Introducing the shell | Step-by-step guide to build `jsh`for your own system | Configuring the shell for your own use | Online text version of the latest `man jsh` | 

## Get it!

<a href="https://github.com/jovanbulck/jsh/releases/latest"><img src="http://jovanbulck.github.io/jsh/icons/download_icon_right_space.png"
 alt="Download logo" title="Download latest release" align="left" /></a>

[This page](https://github.com/jovanbulck/jsh/releases/latest) provides pre-built binaries for all official `jsh` releases. To build `jsh` yourself, clone this respository, `cd` into it and execute `make`. See [the wiki page](https://github.com/jovanbulck/jsh/wiki/Compiling-and-running) for more info and dependencies overview.
