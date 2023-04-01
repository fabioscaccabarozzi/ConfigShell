function setupAliases_Abbreviations
    set -g -x GREP_OPTIONS "--color=auto"
    abbr -a -g l less
    alias j=jobs
    abbr -a -g ln-s 'ln -s'
    alias a=alias
    alias cp='cp -i'
    alias rm='rm -i'
    alias mv='mv -i'
    abbr -a -g  wh which

    alias la "ls -aCF $LS_COLOUR"
    alias ll "ls -lhF $LS_COLOUR"
    alias lla "ls   -laF       $LS_COLOUR"
    alias lld "ls   -ldF       $LS_COLOUR"
    alias llad "ls  -ladF      $LS_COLOUR"

    abbr -a -g cd.. 'cd ..'
    alias ..='cd ..'
    alias .2='cd ../..'
    alias .3='cd ../../..'
    alias .4='cd ../../../..'
    alias .5='cd ../../../../..'
    alias .6='cd ../../../../../..'
    alias .7='cd ../../../../../../..'
    alias brmd='[ -f .DS_Store ] &&  /bin/rm -f .DS_Store ; set -l a $PWD ; cd .. ; rmdir "$a"; set -e a'
    alias mcd=mkcd
    function mkcd
        mkdir -p $argv[1] && cd $argv[1]
    end
    alias po=popd
    alias pu='pushd .'

    abbr -a -g cm cmake
    abbr -a -g gm gmake
    abbr -a -g m make

    alias disp0='export DISPLAY=:0'
    alias disp1='export DISPLAY=:1'

    abbr -a -g e "grep -E"
    abbr -a -g ei 'grep -Ei'
    abbr -a -g eir 'grep -EiR'
    abbr -a -g er 'grep -ER'
    abbr -a -g f 'grep -F'

    abbr -a -g enf 'env | grep -Ei'

    abbr -a -g fin 'find . -name'
    abbr -a -g fini 'find . -iname'

    abbr -a -g h "history --show-time"

    abbr --erase hf # delete the old hf #abbr -a -g hf 'history | grep -Ei '
    function hf
        history | grep -Ei $argv[1] | sort -r
    end
    abbr -a -g hs 'history search --reverse --contains' # new command from fish. If it is good, it shall replace/become hf
    abbr -a -g proc 'ps -ef | grep -Ei'

    abbr -a -g ipi 'curl https://ipinfo.io'
    abbr -a -g pkgU pkgUpgrade          # pkgU was old name for pkgUpgrade
    abbr -a -g osUpgrade pkgUpgrade     # create intuitive names for pkgUpgrade
    abbr -a -g rl 'source ~/.config/fish/config.fish'
    abbr -a -g ssf ssh-grep

    abbr -a -g tm 'tmux new -s'
    abbr -a -g tw 'tmux new-window -n'
    alias tn=tw
    abbr -a -g tj 'tmux join-pane -s'
    abbr -a -g tmux-prd 'tmux select-pane -P "fg=white,bg=color052"'
    abbr -a -g prd 'tmux select-pane -P "fg=white,bg=color052"'
    abbr -a -g tmux-prd2 'tmux select-pane -P "fg=red,bg=color016"'
    abbr -a -g prd2 'tmux select-pane -P "fg=red,bg=color016"'
    abbr -a -g tmux-qul 'tmux select-pane -P "fg=black,bg=color179"'
    abbr -a -g qul 'tmux select-pane -P "fg=black,bg=color179"'
    abbr -a -g tmux-dvl 'tmux select-pane -P "fg=white,bg=color017"'
    abbr -a -g dvl 'tmux select-pane -P "fg=white,bg=color017"'
    abbr -a -g tmux-loc 'tmux select-pane -P "fg=white,bg=color237"'
    abbr -a -g loc 'tmux select-pane -P "fg=white,bg=color237"'
    abbr -a -g tmux-whbl 'tmux select-pane -P "fg=white,bg=black"'
    abbr -a -g whbl 'tmux select-pane -P "fg=white,bg=black"'
    abbr -a -g tmux-blwh 'tmux select-pane -P "fg=black,bg=white"'
    abbr -a -g blwh 'tmux select-pane -P "fg=black,bg=white"'

    set -g -x KUBECTL kubectl
    if which docker 2&>/dev/null
        set -g -x CONTAINER docker
        #echo set container $CONTAINER
    end
    if which podman 2&>/dev/null
        set -g -x CONTAINER podman
        #echo set container $CONTAINER
    end

    abbr -a -g dih      "$CONTAINER image history"
    abbr -a -g k        $KUBECTL
    abbr -a -g k8       $KUBECTL
    abbr -a -g k8s      $KUBECTL
    abbr -a -g k8af     "$KUBECTL apply -f"
    abbr -a -g k8df     "$KUBECTL delete -f"
    abbr -a -g k8c      "$KUBECTL config"
    abbr -a -g k8cg     "$KUBECTL config get-contexts"
    abbr -a -g k8cs     "$KUBECTL config set-context"
    abbr -a -g k8cu     "$KUBECTL config use-context"
    abbr -a -g k8cv     "$KUBECTL config view"
    abbr -a -g k8gd     "$KUBECTL get deploy -o wide"
    abbr -a -g k8gda    "$KUBECTL get deploy -o wide -A"
    abbr -a -g k8gdA    "$KUBECTL get deploy -o wide -A"
    abbr -a -g k8gn     "$KUBECTL get nodes -o wide"
    abbr -a -g k8gp     "$KUBECTL get pods -o wide"
    abbr -a -g k8gpa    "$KUBECTL get pods -A -o wide"
    abbr -a -g k8gpA    "$KUBECTL get pods -A -o wide"
    abbr -a -g k8gs     "$KUBECTL get services -o wide"
    abbr -a -g k8gsa    "$KUBECTL get services -o wide -A"
    abbr -a -g k8gsA    "$KUBECTL get services -o wide -A"
    abbr -a -g k8ns     "$KUBECTL get ns"
    abbr -a -g k8ga     "$KUBECTL get all"
    abbr -a -g k8gaa    "$KUBECTL get all -A"
    abbr -a -g k8gaA    "$KUBECTL get all -A"
    abbr -a -g k8gaw    "$KUBECTL get all -A -o wide"
    abbr -a -g k8gaaw   "$KUBECTL get all -A -o wide"
    abbr -a -g k8gaAw   "$KUBECTL get all -A -o wide"
    abbr -a -g k8ev     "$KUBECTL get events --sort-by=.metadata.creationTimestamp"
    abbr -a -g k8events "$KUBECTL get events --sort-by=.metadata.creationTimestamp"
    abbr -a -g k8eva    "$KUBECTL get events -A --sort-by=.metadata.creationTimestamp"
    abbr -a -g k8evA    "$KUBECTL get events -A --sort-by=.metadata.creationTimestamp"

    # golang-specific commands
    abbr  -a -g gode goexec-debug
    abbr  -a -g gore goexec-release
    abbr  -a -g godue goexec-upx

    # bumpversion commands
    # increase and show the new version number
    abbr  -a -g bpa 'bumppatch ; version.sh'
    abbr  -a -g bmi 'bumpminor ; version.sh'
    abbr  -a -g bma 'bumpmajor ; version.sh'

end

function setupPath
    if test (id -u) -eq 0
        set fish_user_paths /bin /usr/bin/ /sbin /usr/sbin /usr/local/bin /usr/local/sbin
    else
        set fish_user_paths /bin /usr/bin/ /sbin /usr/sbin /usr/local/bin /usr/local/sbin
        # build up elements to come before default ones
        for dir in $HOME/bin $HOME/.cargo/bin $HOME/go/bin /opt/ConfigShell/bin $HOME/Library/Android/sdk/platform-tools /usr/local/share/dotnet /usr/local/go/bin \
                ~/.local/share/JetBrains/Toolbox/scripts/ \
                $HOME/.dotnet/tools $HOME/.rvm/bin /usr/local/google-cloud-sdk/ $HOME/google-cloud-sdk/ \
                $HOME/.pub-cache/bin /opt/flutter/bin $HOME/.linkerd2/bin $HOME/google-cloud-sdk/bin \
                /usr/local/google-cloud-sdk/bin \
                /opt/android-studio/bin /opt/1Password/ /opt/Xmind/ \
                /opt/ConfigShell/Config(uname)/bin_(uname)-(uname -m)
            fish_add_path -p "$dir"
        end
        # build up OSX elements
        if test (uname) = Darwin
            for dir in /opt/homebrew/bin /opt/homebrew/sbin /opt/homebrew/opt/ \
                    /opt/homebrew/opt/gnu-getopt/bin /usr/local/opt/gnu-getopt/bin \
                    /usr/local/homebrew/bin /usr/local/homebrew/sbin \
                    "/opt/homebrew/opt/openssl@1.1/bin" "/usr/local/opt/openssl@1.1/bin" \
                    /opt/homebrew/opt/curl/bin  /usr/local/opt/curl/bin/ /usr/local/opt/gnu-getopt/bin \
                    /opt/homebrew/opt/java/bin /usr/local/opt/java/bin /Library/Java/JavaVirtualMachines/current/bin \
                    /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin \
                    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/" \
                    "/Applications/Sublime Text.app/Contents/MacOS/" \
                    /usr/local/texlive/2022/bin/universal-darwin/ \
                    ~/.rubies/*/bin \
                    ~/.iterm2
                fish_add_path -p "$dir"
            end
        end
    end
end

function err
    echo $argv 1>&2
end

function optSourceFile
    if ! count $argv >/dev/null         #err no argument supplied to optSourceFile
        return
    end
    if ! test -f $argv[1]                #err supplied argument not a plain file
        return
    end
    if ! test -r $argv[1]               #err supplied plain file is not readable
        return
    end
    source $argv[1]
end

# function git_prompt_status
#     if [ (git rev-parse --is-inside-work-tree 2>&1 | grep fatal | wc -l) -eq 0  ]
#         set -l _gitBranch (git status -s -b | head -1 | sed 's/^##.//')
#         set -l _gitStatus (git status -s -b | tail -n +2 | sed 's/^\(..\).*/\1/' | sort | uniq | tr "\n" " " | sed -e 's/ //g' -e 's/??/?/' -e 's/^[ ]*//')
#         echo $_gitStatus $_gitBranch
#     end
# end

# function fish_cloud_prompt
#     test -n "$AWS_PROFILE" && echo " <AWS:$AWS_PROFILE> "
# end
#
# function fish_vcs_prompt
#     set_color yellow
#     set -l out (git_prompt_status or fish_hg_prompt $argv)
#     test -n "$out" && echo " ($out)"  # use or own bash way to show git status
#     set_color magenta
#     fish_cloud_prompt   # not nice to integrate it here but changes are minimal than changing the complete prompt mechanism
#     set_color normal
# end

function setupCompletion
    if test -r ~/.ssh/completion.lst
        complete -F -c rsync -a ~/.ssh/completion.lst
        # complete -F -c scp -a ~/.ssh/completion.lst       # working from scratch. there seems to be more logic behind it
        complete -x -c ssh -a ~/.ssh/completion.lst
    end
end

function err
    echo $argv 1>&2
end

function start_ssh_agent
   # start the ssh-agent and store the variable for ssh-add in a file for next shells
   set -l ssh_agent_output (ssh-agent)
   set -e -g SSH_AUTH_SOCK
   set -x -U SSH_AUTH_SOCK (echo $ssh_agent_output | grep SSH_AUTH_SOCK | sed 's/^.*SSH_AUTH_SOCK=//' | sed 's/;.*//')
   ssh-add
end

function setupSsh
    [ -n "$SSH_AUTH_SOCK" ] && [ -n "$SSH_TTY" ] && return

    ssh-add -l 2>/dev/null 1>&2 ; set -l res $status
    switch $res
    case 0      # ssh-agent loaded, keys loaded
        #echo agent found, keys loaded
        return
    case 1      # ssh-agent loaded, but no identities loaded
        #echo found agent status 1
        ssh-add
    case 2      # ssh-agent could not be contacted, starting
        #echo no agent found
        start_ssh_agent $ssh_auth_sock_file
    case '*'
        err setupSsh unknown answer from ssh-add $status
    end
end

function setupExportVars
    umask 0022
    set -g -x LESS '-iR'
    set -g -x RSYNC_FLAGS "-rltHpDvu" # Windows FS updates file-times only every 2nd second
    set -g -x RSYNC_Add_Windows "--modfiy-window=1" # Windows FS updates file-times only every 2nd second
    set -g -x RSYNC_Add_RemoveSLinks "--copy-links"  # convert links into files
    set -g -x VISUAL vim
    set -g -x EDITOR vim       # bsroot has no notion about VISUAL
    set -g -x BLOCKSIZE 1K
    set -g -x FISH_RC_VERSION "1.18.0"
    if test -n "$_current_FISH_RC_VERSION" -a "$FISH_RC_VERSION" != "$_current_FISH_RC_VERSION"
        echo new FISH_RC_VERSION "$FISH_RC_VERSION"
    end
    set -g _current_FISH_RC_VERSION "$FISH_RC_VERSION"
end

function execIfExisting
    for file in $argv
        test -f $file && bash $file
    end
end


# main code
if status is-interactive
    # Commands to run in interactive sessions can go here

    optSourceFile ~/.config/fish/pre.fish
    #  COMPATIBILITY WITH OH-MY-FISH
    #for file in $HOME/.config/fish/conf.d/*.fish
    #    optSourceFile $file
    #end
    set -g theme_color_scheme nord
    set -g theme_display_date yes
    set -g theme_display_jobs_verbose yes
    set -g theme_display_k8s_namespace yes
    set -g theme_newline_cursor yes
    set -g theme_display_ruby yes
    set -g theme_display_node yes
    set -g theme_show_exit_status yes
    for file in $HOME/.config/fish/conf.d/*.sh
        bash $file
    end
    setupExportVars
    setupPath
    setupAliases_Abbreviations
    setupCompletion
    setupSsh

    optSourceFile ~/.config/fish/post.fish
end

# EOF