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

## Prompt Customizing
       You can define a custom jsh prompt using the prompt builtin command:
       prompt  "prompt_string" [max_cwd_length]. 
       The first argument define the new prompt string. 
       The second optional argument defines the maximum length for the current working directory, included with '%d'.
       One can include the following prompt expansion options preceded by a '%' char in the prompt string:

       %u     includes the current username

       %U     includes  the current username, colored red and bold iff sudo
          access is activated

       %h     includes the current hostname

       %s     includes the return value of the last executed shell command

       %S     includes the return value of the last executed shell command,
          colored red and bold iff non-zero

       %d     includes  the  current working directory. When this directory
          path is longer then  the  value  specified  by  the  optional
          max_cwd_length second argument (default is 25), the directory
          path is 'smart' truncated to include the  maximum  number  of
          individual trailing directories of the path. If the path con‐
          tains the current user's home directory, it is replaced  with
          a '~' char.

       %g     includes  the  git branch name iff the current working direc‐
          tory is a git repository

       %c     includes a bold and red '*'  char  iff  the  current  working
          directory  is  a  git repository and git indicates files have
          changed since the last commit

       %$     includes a '$' char or a '#' char iff sudo  access  is  acti‐
          vated (usefull for the prompt ending)

       %%     includes the verbatim '%' character

       %B     turns on bold/bright text coloring

       %n     restores normal coloring: turns off bold/bright text coloring

       %f{color_name}
          Enables  the specified foreground non-bold text color. Recog‐
          nized colors are {black, red, green, yellow,  blue,  magenta,
          cyan,  white}.  The  special  colors {reset, resetall} can be
          used to  respectively  reset  the  foreground  color  to  the
          default or reset all color properties to default.

       %F{color_name}
          Enables the specified foreground bold/bright text color. Rec‐
          ognized colors are the same as with  %f  above.  The  special
          colors  {reset, resetall} can be used to respectively disable
          bold style and reset the foreground color to the  default  or
          reset all color properties to default.

       %b{color_name}
          Enables  the specified background text color. Recognized col‐
          ors are the same as with %f above. The special colors {reset,
          resetall}  can  be  used to respectively reset the background
          color to  the  default  or  reset  all  color  properties  to
          default

##  Configuration files:
 * `~/.jsh_login`: file containing the ASCII welcome message auto printed at login of an interactive session
 * `~/.jshrc`: file containing commands to be executed at login
 * `~/.jsh_history`: containing the command history auto loaded and saved at login/logout

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

The content of this file is interpreted line per line by `jsh` at logout of an interactive session.<br />

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
