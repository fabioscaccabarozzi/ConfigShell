# vim:ts=2:sw=2
# hadm-profile alias common-profile

# echo common-profile.sh

# Copyright © 2021 by Christian ENGEL (mailto:engel-ch@outlook.com)
# License: BSD
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#    This product includes software developed by the <organization>.
# 4. Neither the name of the <organization> nor the
#    names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# DESCRIPTION:
#  - common-profile can be used on its own as a default profile for bash and zsh.
#
# RELEASES:
# << now in Shell/bash.version.sh>>

export DebugFlag=${DebugFlag:-FALSE}
export VerboseFlag=${VerboseFlasg:-FALSE}

#########################################################################################
# SKELETON FUNCTIONS, considered R/O, v0.4.1

# so helps to write a message in reverse mode
function so()
# always show such a message.  If known terminal, print the message
# in reverse video mode. This is the other way, not using escape sequences
{
   [ "$1" != on -a "$1" != off ] && return
    if [ "$TERM" = xterm -o "$TERM" = vt100 -o "$TERM" = xterm-256color  -o "$TERM" = screen ] ; then
      [ "$1" = on ] && tput smso
      [ "$1" = off ] && tput rmso
    fi
}

# --- debug: Conditional debugging. All commands begin w/ debug.

function debugSet()             { DebugFlag=TRUE; return 0; }
function debugUnset()           { DebugFlag=; return 0; }
function debugExecIfDebug()     { [ "$DebugFlag" = TRUE ] && $*; return 0; }
function debug()                { [ "$DebugFlag" = TRUE ] && echo 'DEBUG:'$* 1>&2 ; return 0; }
function debug4()               { [ "$DebugFlag" = TRUE ] && echo 'DEBUG:    ' $* 1>&2 ; return 0; }
function debug8()               { [ "$DebugFlag" = TRUE ] && echo 'DEBUG:        ' $* 1>&2 ; return 0; }
function debug12()              { [ "$DebugFlag" = TRUE ] && echo 'DEBUG:            ' $* 1>&2 ; return 0; }

function verbose()              { [ "$VerboseFlag" = TRUE ] && echo -n $* ; return 0; }
function verbosenl()            { [ "$VerboseFlag" = TRUE ] && echo $* ; return 0; }
function verboseSet()           { VerboseFlag=TRUE; return 0; }

# --- Colour lines. It requires either linux echo or zsh built-in echo

function colBold()      { printf '\e[1m'; return 0; }
function colNormal()    { printf "\e[0m"; return 0; }
function colBlink()     { printf "\e[5m"; return 0; }

# --- Exits

# function error()        { err 'ERROR:' $*; return 0; } # similar to err but with ERROR prefix and possibility to include
# Write an error message to stderr. We cannot use err here as the spaces would be removed.
function error()        { so on; echo 'ERROR:'$* 1>&2;            so off ; return 0; }
function error4()       { so on; echo 'ERROR:    '$* 1>&2;        so off ; return 0; }
function error8()       { so on; echo 'ERROR:        '$* 1>&2;    so off ; return 0; }
function error12()      { so on; echo 'ERROR:            '$* 1>&2;so off ; return 0; }

function warning()      { so on; echo 'WARNING:'$* 1>&2;          so off; return 0; }

function errorExit()    { EXITCODE=$1 ; shift; error $* 1>&2; exit $EXITCODE; }
function exitIfErr()    { a="$1"; b="$2"; shift; shift; [ "$a" -ne 0 ] && errorExit $b App returned $b $*; }

function err()          { echo $* 1>&2; }                 # just write to stderr
function err4()         { echo '   ' $* 1>&2; }           # just write to stderr
function err8()         { echo '       ' $* 1>&2; }       # just write to stderr
function err12()        { echo '           ' $* 1>&2; }   # just write to stderr

# --- Existance checks
function exitIfBinariesNotFound()       { for file in $@; do [ $(command -v "$file") ] || errorExit 253 binary not found: $file; done }
function exitIfPlainFilesNotExisting()  { for file in $*; do [ ! -f $file ] && errorExit 254 'plain file not found:'$file 1>&2; done }
function exitIfFilesNotExisting()       { for file in $*; do [ ! -e $file ] && errorExit 255 'file not found:'$file 1>&2; done }
function exitIfDirsNotExisting()        { for dir in $*; do [ ! -d $dir ] && errorExit 252 "$APP:ERROR:directory not found:"$dir; done }

# --- Temporary file/directory  creation
# -- file creation -- TMP1=$(tempFile); TMP2=$(tempFile) ;;;; trap "rm -f $TMP1 $TMP2" EXIT
# -- directory creation -- TMPDIR=$(tempDir) ;;;;;  trap "rm -fr $TMPDIR;" EXIT
#
function tempFile()                     { mktemp ${TMPDIR:-/tmp/}$_app.XXXXXXXX; }
function tempDir()                      { mktemp -d "${TMPDIR:-/tmp/}$_app.YYYYYYYYY"; }
# realpath as shell, argument either supplied as stdin or as $1

# =========================================================================================
# === normal use-case related functions ===================================================
# =========================================================================================

# user-specific pre/post/... configuration, duplicate in .bash_profile
function loadSource() {
   if [ -r "$HOME/.bashrc.$1" ] ; then debug loadSource .bashrc.$1 ; source "$HOME/.bashrc.$1" ; else
      debug4 loadSource FILE NOT FOUND $HOME/.bashrc.$1
   fi
}

# setHistFileUserShell sets the HISTFILE to individual files for each terminal. The related ssf command searches in all created
# history files.
function setHistFileUserShell() {
   debug4 ......................... in setHistFileUserShell
      # Avoid duplicates

   export HISTCONTROL=ignoredups:erasedups:ignorespace
   export HISTSIZE=1000
   export HISTFILESIZE=10000
    export HISTTIMEFORMAT='%Y-%m-%d_%H%M%S: '
   # When the shell exits, append to the history file instead of overwriting it
   shopt -s histappend
    [ -f ~/.history ] && /bin/rm -f ~/.history
    [[ -d ~/.history ]] || mkdir ~/.history && debug8 creating history directory
    [[ -d ~/.history ]] && chmod 0700 ~/.history && debug8 setting history directory permission
   # previous version export HISTFILE=$(eval echo ~$USER/.bash_history)
    [[ "$HISTFILE" == '' ||  "$HISTFILE" =~ bash_history ]] && HISTFILE=~/.history/history.$(date +%y%b%d-%H%M%S).$$
   debug8 HISTFILE is $HISTFILE
   #[ -f $HISTFILE ] && debug8 histfile existing && \
#      local histfileUser=$(ls -l $HISTFILE | awk '{ print $3 } ') && \
      USER=${USER:-root} # fix for docker
      SHELL=${SHELL:-$(ps a | grep $$ | sed -n "/^ *$$/p" | awk '{ print $NF }')} # fix for docker
#     [ $histfileUser != $USER ] && echo ownship of history file must be corrected from user $histfileUser to user $USER && sudo chown $USER $HISTFILE
    [ $(du -sk ~/.history/ | cut -f1 ) -gt 99099 ] && echo Please consider deleting some files from ~/.history
}

############################################################################
# main
############################################################################

function main() {
   umask 0022

   case $- in
      *i*) #  "This shell is interactive"
         # source .bash_profile if it was not done before
         # .bash_profile calls .bashrc; in such a case, stop .bashrc sourcing here
         [ -z "$BASH_ENV" -a -r ~/.bash_profile ] && . ~/.bash_profile && return
         loadSource pre
         set -o ignoreeof                 # prevent ^d logout
         set -o noclobber                 # overwrite protection, use >| to force
         setHistFileUserShell                      # history file permission, ownership, settings

         # env.*.sh are loading in bash_profile
         for file in $PROFILES_CONFIG_DIR/Shell/common.*.sh $PROFILES_CONFIG_DIR/Shell/bash.*.sh; do
            if [ -f $file  ] ; then
               source $file
               $(basename $file .sh).init # call the file-local initialiser
            else
               warning $file is not a plain file  1>&2
            fi
         done

         # load os-specifics
         if [ -f "$PROFILES_CONFIG_DIR/Shell/os.$(uname).sh" ] ; then
            source "$PROFILES_CONFIG_DIR/Shell/os.$(uname).sh"
            os.$(uname).init
         else
            warning No OS-specific path file "$PROFILES_CONFIG_DIR/Shell/os.$(uname).sh" found
         fi
         local sshCompletionList=$HOME/.ssh/completion.lst
         [ -f $sshCompletionList ] && complete -W "$(cat $sshCompletionList)" -- ssh && complete -f -d -W "$(cat $sshCompletionList)" -- rsync
         if [ -z $NO_loadPost ] ; then
            loadSource post
            for file in $HOME/.bashrc.d/*.rc ; do
               [ "$file" = "$HOME/.bashrc.d/"'*.rc' ] && continue # in case that no file is found
               [ -r "$file" ] && debug4 sourcing "$file" && source "$file"
               [ -r "$file" ] || err could not read "$file"
            done
            for file in $HOME/.bashrc.d/*.sh ; do
               [ "$file" = "$HOME/.bashrc.d/"'*.sh' ] && continue # in case that no file is found
               [ -r "$file" ] && debug4 executing "$file" && bash "$file"
               [ -r "$file" ] || err could not read "$file"
            done
         fi
         ;;
      *) #echo "This is a script";;
         debug non-interactive shell
         ;;
   esac
}

main $@

#################### EOF

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
