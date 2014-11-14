#!/bin/sh
# =============================================================
# This file is part of jsh.
# 
# jsh (jo-shell): A basic shell implementation
# Copyright (C) 2014 Jo Van Bulck <jo.vanbulck@student.kuleuven.be>
#
# jsh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# jsh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with jsh.  If not, see <http://www.gnu.org/licenses/>.
# ============================================================

############################## COMMON THINGS #############################

# common options for all dialogs
DIALOG="dialog --stderr --clear"

#USER=`whoami`
INSTALL_PATH="/usr/local/bin"
MAN_PATH="/usr/local/share/man/man1"

# create a tempfile to hold dialogs responses
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/jsh_installer$$
another_temp_file=`tempfile 2>/dev/null` || tempfile=/tmp/jsh_installer_other$$

# cleanup tempfile if any of the signals - SIGHUP SIGINT SIGTERM it received.
trap "rm -f $tempfile; rm -f $another_temp_file; exit" SIGHUP SIGINT SIGTERM

exit_installer()
{
    clear
    echo "jsh installation aborted"
    rm -f $tempfile
    rm -f $another_tempfile
    exit 1
}

display_info()
{
    $DIALOG --backtitle "jsh installer" \
            --title "$1" \
            --msgbox "$2" 10 50 
    retval=$?
    if [ $retval -eq 255 ]
    then
        exit_installer
    fi
}

# the following sections define some dialog fucntions in order to move forward / back
# between them; exection starts at the "hello dialog" below

############################## INSTALL TARGETS DIALOG #############################

query_install_flags()
{
$DIALOG --backtitle "jsh installer" \
        --title "Install targets" \
        --ok-label "Continue" \
        --cancel-label "Stop the time" \
        --separate-output \
        --checklist "select the install targets below" 10 70 5 \
        "jsh"   "the jo-shell - a basic UNIX shell implementation in C" on \
        "man"   "the jsh manpage" on \
        2> $tempfile

retval=$?
case $retval in
  0) # OK pressed; parse response
    while read line
    do
        case ${line} in
        "jsh")
            echo "you chose jsh";;
        "man")
            echo "you chose the man page";;
        esac
    done < $tempfile
    query_compile_flags;; # continue to the next dialog
  1)
    exit_installer;; # Cancel pressed
  255)
    exit_installer;; # ESC pressed
esac
}

############################## COMPILE FLAGS DIALOG #############################

query_compile_flags()
{
$DIALOG --backtitle "jsh installer" \
        --title "Compile flags" \
        --separate-output \
        --ok-label "Continue" \
        --cancel-label "Back" \
        --checklist "select the compile flags below" 12 90 5 \
        "color"     "colorize jsh debug and error messages" on \
        "rcfile"    "auto load the ~/.jshrc file on jsh boot" on \
        "debug"     "turn on debug output by default" off \
        "update"    "check for new jsh release on jsh boot" off \
        "fallback"  "don't use the GNU readline library for input line editing and history" off \
        2> $tempfile

retval=$?
case $retval in
  0) # OK pressed; parse response
    while read line
    do
        case ${line} in
        "jsh")
            echo "you chose jsh";;
        "man")
            echo "you chose the man page";;
        esac
    done < $tempfile
    query_install_dir;; # continue to the next dialog
  1) # "Back" button pressed
    query_install_flags;;
  255)
    exit_installer;; # ESC pressed
esac
}

############################## SELECT INSTALL DIRECTORY DIALOG ###################

query_install_dir()
{
$DIALOG --backtitle "jsh installer" \
        --title "Choose install directory" \
        --ok-label "Continue" \
        --cancel-label "Back" \
        --inputbox "type the jsh installation directory below" \
        7 50 "$INSTALL_PATH" \
        2> $tempfile

retval=$?
case $retval in
  0) # OK pressed; set install path
    inputline=`cat $tempfile`
    if [ ! -d $inputline ]
    then
        display_info "Choose install directory" "The install path you choose isn't a valid \
directory. Too bad, try again..."
        query_install_dir
    else
        INSTALL_PATH=$inputline
        query_man_dir # continue to next dialog
    fi;;
  1) # "back" button pressed
    query_compile_flags;;
  255)
    exit_installer;; # ESC pressed
esac
}

############################## SELECT MAN INSTALL DIRECTORY DIALOG ###################

query_man_dir()
{
$DIALOG --backtitle "jsh installer" \
        --title "Install directory" \
        --ok-label "Install now" \
        --cancel-label "Back" \
        --inputbox "type the jsh manpage installation directory below" \
        8 50 "/usr/local/share/man/man1" \
        2> $tempfile

retval=$?
case $retval in
  0) # OK pressed; parse response
    inputline=`cat $tempfile`
    if [ ! -d $inputline ]
    then
        display_info "Choose man install directory" "The man install path you choose isn't \
a valid directory. Too bad, try again..."
        query_man_dir
    else
        MAN_PATH=$inputline
        # continue normal execution
    fi;;
  1) # "back" button
    query_install_dir;;
  255)
    exit_installer;; # ESC pressed
esac
}


############################## HELLO DIALOG #############################

$DIALOG --backtitle "jsh installer" --title "Install jsh" \
        --msgbox "Hello $USER, this installer will guide you through \
the jsh build and install process.\n\nHit enter to continue; ESC any time to abort." 10 41

retval=$?
if [ $retval -eq 255 ]
then
    exit_installer
fi

# start normal execution of the above dialogs on the next line; continue below thereafter
query_install_flags

############################## JSH CONFIG FILES ##############################

show_config_file_dialog()
{
    file=$1
    $DIALOG --backtitle "jsh installer" \
            --title "Create jsh configuration file" \
            --yesno "The installer hasn't found an existing '$file' config file. \
            Should I create an empty one? You will be provided with the possibility \
to edit it afterwards." 8 60
    retval=$?
    case $retval in 
        0) # Yes : create a default file and edit
            touch $file
            echo $2 > $file
            if [ $# -eq 3 ] && [ $3 = "add_dummy_conf" ]
            then
                echo "#" >> $file
                echo "# Insert commands here to create your own custom jsh shell! :-)" >> $file
                echo "# To get you started, see (https://github.com/jovanbulck/jo-shell/wiki/Sample-\
configuration-files)" >> $file
                echo "# for more info and example configuration files" >> $file
                echo "" >> $file
                echo "" >> $file
            fi
            show_edit_config_file_dialog $file;;
        1) # No : continue normal execution
            ;;
        255) # ESC pressed
            exit_installer;;
    esac
}

show_edit_config_file_dialog()
{
    file=$1
    $DIALOG --backtitle "jsh installer" \
            --title "Edit the new jsh configuration file below" \
            --editbox $file 50 100 \
            2> $tempfile
    
    retval=$?
    case $retval in
        0) # OK : write out the file
            cp $tempfile $file;;
        1) # Cancel : continue normal execution; dont write out the file
            ;;
        255) # ESC
            exit_installer;;
    esac
}

if [ ! -e "$HOME/.jshrc" ]
then
    show_config_file_dialog "$HOME/.jshrc" "# ~/.jshrc : file containing jsh-shell commands \
executed by jsh on startup of an interactive session" "add_dummy_conf"
fi

if [ ! -e "$HOME/.jsh_logout" ]
then
    show_config_file_dialog "$HOME/.jsh_logout" "# ~/.jsh_logout: a file containing jsh-shell \
commands executed by jsh when exiting an interactive sesssion." "add_dummy_conf"
fi

if [ ! -e "$HOME/.jsh_login" ]
then
    show_config_file_dialog "$HOME/.jsh_login" "Hi $USER, welcome back to jsh!"
fi

############################## MAKE OUTPUT DIALOG ##############################

MAKE_CMD="make install JSH_INSTALL_DIR="$INSTALL_PATH" MANPAGE_INSTALL_DIR="$MAN_PATH" 2>&1 | \
        $DIALOG --backtitle \"jsh installer\" \
                --title \"making jsh\" \
                --ok-label \"Continue\" \
                --programbox \"make install jsh output\" 100 100"

# see if we need sudo (have write rights to install directories)
if [ ! -w $INSTALL_PATH ] || [ ! -w $MAN_PATH ]
then
    clear
    echo "The installer will now make and install jsh to '$INSTALL_PATH' and '$MAN_PATH'. \
Since you don't have write rights to these directories, we'll use sudo. Type your sudo \
password below:"
    # run the whole pipeline as sudo to avoid having sudo prompting and messing up the
    # stdout of the dialog
    echo $MAKE_CMD | sudo sh
else
    echo $MAKE_CMD | sh
fi

retval=$?
if [ ! $retval -eq 0 ]
then
    display_info "make install jsh" "make install exited with an error (return value = \
$retval) The installer will now exit.\n\nSee (https://github.com/jovanbulck/jo-shell/ \
wiki/Compiling-and-running) for help on compiling jsh for your system."
    exit_installer
fi

############################## DEFAULT SHELL DIALOG ############################

$DIALOG --backtitle "jsh installer" \
        --title "jsh as default shell" \
        --no-label "Yes" --yes-label "No" \
        --yesno "Do you want to set jsh as your default UNIX login shell? \
        (currently not recommended)" 6 50

retval=$?
case $retval in 
    0) # No pressed
        ;; # continue normal execution
    1) # Yes pressed
        clear
        echo "changing the default shell to jsh"
        OLD_SHELL=$SHELL
        # redirect chsh stdout and stderr to screen as well as to a file
        # save the return value of chsh (otherwise $? will be the ret value of tee)
        { chsh -s /usr/local/bin/jsh 2>&1 ; echo $? > another_temp_file; } | tee $tempfile
        
        chsh_retval=`cat another_temp_file`
        if [ $chsh_retval -eq 0 ]
        then
            display_info "changing shell to jsh" "chsh exited successfully: \njsh is now \
your default UNIX login shell. Use 'chsh -s $OLD_SHELL' any time to revert the default shell."
        else
            display_info "changing shell to jsh" "Your default UNIX login shell hasn't \
changed. Use 'chsh -s $INSTALL_PATH/jsh' after the installation to retry. chsh says\n\n \
`cat $tempfile`"
        fi;;
   255) # ESC pressed
        exit_installer;;
esac

############################## EXIT SUCCESS DIALOG #############################

display_info "jsh installation completed" "jsh is installed successfully on your system. \
Have fun with your new shell!\n\n`$INSTALL_PATH/jsh --version`"

rm -f $tempfile
rm -f $another_tempfile
clear
echo "jsh installer exited successfully"
exit 0
