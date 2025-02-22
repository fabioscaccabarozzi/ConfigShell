#!/usr/bin/env bash

########## RELEASE INFORMATION
# 2.4
#   - podman is now default if found
# 2.3
#   - support for podmand by -2 option
# 2.2
#   set container name to directory name if not explicitly set (same as for image name)
# 2.1
#   output help to stdout to make viewing help easier, not nice
# 2.0
# - major clean up into functions
# - creation documentation/usage from source using special comments
#   with 2,3,4 hashmarks (2 normal line, 3 subsection, 4 section)
#   Lines with 1 or more than 4 hashmarks are ignored.
# 1.2.
# - refactor to more normal standards
# 1.1.0
# - introducing new touch variable _detach

VERSION=2.4.0

function err()          { echo $* 1>&2; } # write to stderr
function err4()          { echo '    '$* 1>&2; } # write to stderr
function err8()          { echo '        '$* 1>&2; } # write to stderr

function debugSet()             { DebugFlag=TRUE; return 0; }
function debugUnset()           { DebugFlag=; return 0; }
function debugExecIfDebug()     { [ "$DebugFlag" == TRUE ] && $*; }
function debug()                { [ "$DebugFlag" == TRUE ] && err 'DEBUG:' $* 1>&2 ; return 0; }

function verboseSet()             { VerboseFlag=TRUE; return 0; }
function verbose()                { [ "$VerboseFlag" == TRUE ] && echo $* ; return 0; }

function exitIfBinariesNotFound()       { for file in $@; do [ $(command -v "$file") ] || errorExit 253 binary not found: $file; done }
function exitIfPlainFilesNotExisting()  { for file in $*; do [ ! -f $file ] && errorExit 254 'plain file not found:'$file 1>&2; done }
function exitIfFilesNotExisting()       { for file in $*; do [ ! -e $file ] && errorExit 255 'file not found:'$file 1>&2; done }
function exitIfDirsNotExisting()        { for dir in $*; do [ ! -d $dir ] && errorExit 252 "$APP:ERROR:directory not found:"$dir; done }

function errorExit()    { EXITCODE=$1 ; shift; error $* ; exit $EXITCODE; }

################################################################################

# Listed in order of ASCENDING preference (podman > docker)
which docker &>/dev/null && docker=docker
which podman &>/dev/null && docker=podman

################################################################################

function usage() {
  echo NAME
  echo '    '$(basename $0) version is $VERSION
  echo
  echo  This is a helper application to build, tag, push, run docker
  echo  images and to exec into images. Its main idea is to set the main
  echo  parameters not in a script but to make it visisble immediately by using
  echo  file names of touch '(aka empty)' files. Furthermore, it uses the current
  echo  directory as the default for the docker name. So it is possible to replicate
  echo  a complete directory of this kind and  give it a new name. This new
  echo  configuration does not interfere with the old one.
  echo
  echo  This command is main thought for development environments where is shall be
  echo  easily visisble how an application was started.
  echo
  echo  The touch files are defined as:
  grep -v '#####' $0 | grep '##' | sed 's/^[[:space:]]*##$//' | sed 's/^[[:space:]]*## /    /' | sed 's/^[[:space:]]*### /    ## /' |  sed 's/^[[:space:]]*#### /    # /'
  echo
  echo SYNOPSIS
  echo '    '$(basename $0) '-D        # debug mode, more verbose than verbose'
  echo '    '$(basename $0) '-V        # show version number'
  echo '    '$(basename $0) '-2  ...   # calling podman instead of docker'
  echo '    '$(basename $0) '-b  ...   # build image, further arguments'
  echo '    '$(basename $0) '-d ...    # detached run, implies -r'
  echo '    '$(basename $0) '-e ...    # exec in image'
  echo '    '$(basename $0) '-h        # show help'
  echo '    '$(basename $0) '-k        # kill image'
  echo '    '$(basename $0) '-n        # dry run'
  echo '    '$(basename $0) '-p        # push image'
  echo '    '$(basename $0) '-r ...    # run image'
  echo '    '$(basename $0) '-t        # tag image'
  echo '    '$(basename $0) '-u        # tag & push in one step'
  echo '    '$(basename $0) '-v        # verbose mode'
  echo '    '$(basename $0) '-a        # start container'
  echo '    '$(basename $0) '-o        # stop container'
}

function parseCLI() {
    local currentOption
    declare -g docker ; docker=docker
    while getopts "2DVbdehknprtuvao" options; do         # Loop: Get the next option;
        case "${options}" in                    # TIMES=${OPTARG}
            D)  err Debug \& verbose enabled ; debugSet ; verboseSet
                ;;
            V)  debug version number; echo $VERSION
                exit 0
                ;;
            2)  debug podman mode
                docker=podman
                ;;
            b)  debug build mode;
                mode=build
                ;;
            d)  debug detached run mode;
                _detach='--detach'
                mode=run
                ;;
            e)  debug exec mode;
                mode=exec
                ;;
            h)  usage ; exit 0
                ;;
            k)  debug kill mode;
                mode=kill
                ;;
            n)  debug dry mode;
                dry="echo # "
                verbose DRY MODE is on ..................
                ;;
            p)  debug push mode;
                mode=push
                ;;
            r)  debug run mode;
                mode=run
                ;;
            t)  debug tag mode;
                mode=tag
                ;;
            u)  debug tag and push mode;
                mode=tagPush
                ;;
            v)  debug verbose mode;
                verboseSet
                ;;
            a)  debug start mode;
                mode=start
                ;;
            o)  debug stop mode;
                mode=stop
                ;;
            *)  err Help with $_app -h
                exit 1  # Exit abnormally.
                ;;
        esac
    done
}


################################################################################
# evaluation of convention-based filenames
### Docker2 uses convention-based filenames to configure it. The supported filenames are listed here:
##

function checkDetach() {
  ## `_detach` defined that if the container is to be started,
  ## it is to be run in detached mode.
  ##
  declare -g _detach
  [ -f _detach ] && _detach='--detach'
  debug Detach is $_detach
}

function checkDockerRegistry() {
  ## A docker registry can be defined for pushing/pulling images.
  ## Either to be set by the file `docker-registry` or by the environment
  ## variable `DOCKERREGISTRY`.
  ##
  declare -g _registry
  _dockerRegistryFile=./docker-registry
  if [ -f $_dockerRegistryFile ] ; then
    _registry=$(cat $_dockerRegistryFile | grep -v ^$ | grep -v '^#' | head -n1 | sed 's/[[:space:]]#.*//')
  elif [ ! -z "$DOCKERREGISTRY" ] ; then
    _registry=$DOCKERREGISTRY
  fi
  unset _dockerRegistryFile
  debug Docker registry is $_registry
}

function checkVersionFile() {
  ## `.version` file or `_version` can contain a version number which is used for tagging an image.
  ## The version file can either be updated manually or better using the provided scripts
  ## `bumpmajor`, `bumpminor`, `bumppatch`.
  ##
  declare -g _ver
  _ver=
  [ -f .version ] && _verfile=.version
  [ -f _version ] && _verfile=_version
  [ ! -z "$_verfile" ] && _ver=$(cat $_verfile | grep -v '^$' | sed 's/#.*//' )
  debug Version is $_ver
}

function checkSudo() {
  ## `_sudo` flag to start docker with sudo
  ##
  declare -g sudo
  [ -f _sudo ] && sudo=sudo
  debug Sudo is $sudo
}

function checkImageName() {
  ## `_image_<<imageName>>` map image names, replac upper- against lower-case
  ## If no such file is defined, then the current directory name is used for
  ## the image name.
  ##
  declare -g image
  for file in _image_* ; do
    [ $file = '_image_*'  ] && continue
    image=$(echo $file | sed -e "s/_image_//" | sed -e "s,_,/,g" | tr [A-Z] [a-z] )
  done
  if [ -z "$image" ] ; then
    image=$(basename $PWD | sed -e 's/ /_/g' | tr [A-Z] [a-z]) # as in dockerBuild
  fi
  unset file
  debug Image name is $image
}

function checkVolumeMounts() {
  ## `_v<<fromDir>>:<<toDir>>` map directories/volumnes.
  ## It allows for relative directories such as if the fromDir starts with a
  ## `.` it will be replaced with the absolute path to the current directory.
  ## `/` in paths are to be expressed underscores `_`.
  ##
  declare -g dirmap
  for file in _v*:* ; do
    [ $file = '_v*:*'  ] && continue
    srcmap=$(echo $file | sed 's/^_v//' | sed -e "s,:.*,," | sed "s,_,/,g" | sed -e s",^\.,$(pwd)," )
    dstmap=$(echo $file | sed 's/^_v//' | sed -e "s,.*:,," | sed "s,_,/,g" )
    # debug srcmap $srcmap dstmap $dstmap
    dirmap="-v $srcmap:$dstmap $dirmap"
  done
  unset file srcmap dstmap
  debug Directory mappings are $dirmap
}

function checkContainerName() {
  ## `_name_<<name>` can specify the container alias instance name. Only one suche file
  ## must exist in the current directory.
  ##
  declare -g name
  [ $(echo _name_* | wc -w) -gt 1 ] && 1>&2 echo 'ERROR: more than one _name file found' && return 1
  for file in _name_* ; do
    [ $file = '_name_*'  ] && continue
    name="--name $(echo $file | sed -e 's/^_name_//' | tr '[A-Z]' '[a-z]') $name"
  done
  if [ -z "$name" ] ; then # if not set, set it to the directory name
    name="--name "$(basename $PWD | sed -e 's/ /_/g' | tr [A-Z] [a-z]) # as in dockerBuild
  fi
  unset file
  debug Instance/container name is $name
}

function checkContainerRemoval() {
  ## The `_rm`, `__rm`, or `--rm` can be defined to express that the container
  ## image is to be removed after running.  Please make sure to understand
  ## the difference between a container and an image file.
  ##
  declare -g rm
  [ -f --rm -o -f __rm -o -f _rm ] && rm='--rm'
  debug Remove image is $rm
}

function checkNetworkMappings() {
  ## NETWORK mappings can be expressed as flag files of type `_net_<<networkName>>`
  ##
  declare -g net
  for file in _net_*  ; do
    [ $file = '_net_*'  ] && continue # none found, no expansion of wild card
    net="--net $(echo $file | sed -e 's/^_net_//' ) $net"
  done
  unset file
  debug Nets are $net
}

function checkPortMappings() {
  ## PORT mapping flag files are of type
  ## `_p<outerPort>:<containerInternalPort>` or `_p<outerPort>_<containerInternalPort>`
  ##
  declare -g map
  for file in _p*:* _p*_* ; do
    [ $file = '_p*:*' -o $file = '_p*_*' ] && continue
    map="-p$(echo $file | sed -e 's/^_p//' | sed -e 's/_/:/') $map"
  done
  unset file
  debug Port mappings are $map
}

function checkFileConventions() {
  # calls all the other particular file conventions
  checkPortMappings
  checkNetworkMappings
  checkContainerRemoval
  checkContainerName
  checkVolumeMounts
  checkImageName
  checkVersionFile
  checkDockerRegistry
  checkSudo
  checkDetach
}

##########################################################
# mode implementation

function modeExec() {
  debug evaluateMode exec
  ## docker2 -e expects either that the environment variable `DOCKERSHELL`
  ## or otherwise /bin/bash will try to be started in the container.
  ##
  shift
  if [ ! -z "$name" ] ; then
    purename=$(echo $name | awk '{ print $2 }' )
    verbose $docker exec $* -it $purename ${DOCKERSHELL:-/bin/bash}
    $dry $docker  exec $* -it $purename ${DOCKERSHELL:-/bin/bash}
    res=$?
  else
    err ERROR No clear image name.
    res=1
  fi
}

function modeRun() {
  debug evaluateMode run
  shift # remove argument so that $* b4 supplied to command
  ver=
  [ ! -z "$_ver" ] && ver=:$_ver
  verbose $sudo $docker run $rm $net $name $map $dirmap $_detach $* $image$ver
  $dry    $sudo $docker run $rm $net $name $map $dirmap $_detach $* $image$ver
  res=$?
}

function modeBuild() {
  debug evaluateMode build
  ver=
  [ ! -z "$_ver" ] && ver="-t $image:$_ver" && debug version is $image:$_ver
  verbose $docker build  -t $image:latest .
  $dry $docker build     -t $image:latest .
  res=$?
}

function modeTag() {
  debug evaluateMode tag
  [ -z "$_registry" ] && err Error, registry not set. && exit 20
  debug Docker registry is: $_registry
  _date=$(date +%y%m%d)
  debug Date is $_date
  _out=$($docker inspect --format='{{.Id}}' $image 2>&1) ; resTmp=$?
  [ $resTmp -ne 0 ] && err ERROR running $docker inspect: $_out && res=2 && return
  _sha=$($docker inspect --format='{{.Id}}' $image | sed 's/:/_/g')
  debug SHA checksum is $_sha
  if [ -z "$_sha" ] ; then
    err SHA could not be determined for the image
    res=1
    return
  fi
  debug Tagging for latest
  verbose $docker tag $image $_registry/$image:latest
  $dry $docker tag $image $_registry/$image:latest
  if [ ! -z "$_ver" ] ; then
    debug Version is defined, also tagging for '<<version>>'
    verbose $docker tag $image $_registry/$image:$_ver
    $dry $docker tag $image $_registry/$image:$_ver
  else
    debug No version is defined, no further tagging.
  fi
  # debug TAG FOR '<<date>>'
  # debug docker tag $image $_registry/$image:$_date
  # $dry docker tag $image $_registry/$image:$_date
  # debug TAG FOR '<<date-sha>>'
  # debug docker tag $image $_registry/$image:$_date-$_sha
  # $dry docker tag $image $_registry/$image:$_date-$_sha
  debug Tagging for '<<sha>>'
  verbose $docker tag $image $_registry/$image:$_sha
  $dry $docker tag $image $_registry/$image:$_sha
  res=$?
}

function modePush() {
  debug evaluateMode push
  [ -z $_registry ] && err Error, registry not set. && res=10 && return
  debug Docker registry is: $_registry
  _err=$($docker inspect --format='{{.Id}}' $image 2>&1); resTmp=$?
  [ $resTmp -ne 0 ] && err SHA could not be determined for the image: $_err && res=11 && return
  _sha=$($docker inspect --format='{{.Id}}' $image | sed 's/:/_/g')
  verbose $docker push $_registry/$image:latest
  $dry $docker push $_registry/$image:latest
  [ ! -z $_ver ] && $dry $docker push $_registry/$image:$_ver

  verbose $docker push $_registry/$image:$_date
  $dry $docker push $_registry/$image:$_date

  debug SHA checksum is $_sha
  verbose $docker push $_registry/$image:$_sha
  $dry $docker push $_registry/$image:$_sha
  res=$(( res + $? )) # might be combined with res from modeTag
}

function modeStartStopKill() {
  debug evaluateMode $1
  cmd=$1
  shift
  if [ ! -z "$name" ] ; then
    instance=$(echo $name | awk '{ print $2 }' ) # --name name0
    [ -z "$instance" ] && err ERROR, could not determine instance name. Nmae is $name && res=2 && return
    verbose $docker $cmd $instance
    $dry $docker  $cmd $instance
    res=$?
  else
    err ERROR, istance name not detected.
    res=1
  fi
}

function evaluateMode() {
  mode=$1
  [ -z $mode ] && usage && exit 1
  # -V, -D already handled in parseCLI
  case "$mode" in
exec)       modeExec $*
            ;;
run)        modeRun $*
            ;;
build)      modeBuild $*
            ;;
tag)        modeTag $*
            ;;
push)       modePush $*
            ;;
tagPush)    debug TAG+PUSH case
            modeTag $*
            modePush $*
            ;;
  start|stop|kill)
            modeStartStopKill $*
            ;;
  esac
}

function main() {
  exitIfBinariesNotFound pwd tput basename dirname mktemp
  parseCLI $*
  shift $(($OPTIND - 1))  # not working inside parseCLI

  debug Script version is $VERSION
  debug Arguments to scripts are: $*

  checkFileConventions
  debug mode is $mode
  evaluateMode $mode $*
}

main $*
exit $res

# eof
