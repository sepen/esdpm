#!/usr/bin/env bash

export ESDPM_OPTION_DEBUG=0
export ESDPM_OPTION_VERBOSE=0

export ESDPM_BASE_DIR=/opt/esdpm
export ESDPM_CONFIG_FILE="${ESDPM_BASE_DIR}/esdpm.conf"
export ESDPM_HOOKS_DIR="${ESDPM_BASE_DIR}/hooks"

msgError() {
  printf "ERROR: %s(): %s\n" "${FUNCNAME[1]}" "$@" >&2
  exit 1
}

msgWarning() {
  printf "WARNING: %s(): %s\n" "${FUNCNAME[1]}" "$@" >&2
}

msgVerbose() {
  if [ ${ESDPM_OPTION_VERBOSE} -ne 0 ]; then
    printf "%s\n" "${@}"
  fi
}

msgDebug() {
  if [ ${ESDPM_OPTION_DEBUG} -ne 0 ]; then
    printf "DEBUG: ${FUNCNAME[1]}(): " >&2
    for arg in "${@}";  do printf "%s " "${arg}" >&2; done
    printf "\n" >&2
  fi
}

msgUsage() {
  local appname="$(basename $0)"
  printf "Usage: $appname command [target] <[option(s)]>\n"
  printf "\n"
  printf "Where commands are:\n"
  printf "  init    [GIT_LOCAL_DIR] [GIT_REPO_URL]\n"
  printf "  update  [GIT_LOCAL_DIR]\n"
  printf "  switch  [GIT_LOCAL_DIR] [GIT_REPO_BRANCH]\n"
  printf "  reset   [GIT_LOCAL_DIR] [GIT_REPO_HASH]\n"
  printf "  status  [GIT_LOCAL_DIR] <-u|--uri|-h|--hash|-b|--branch>\n"
  printf "  avail   [GIT_LOCAL_DIR] <-a|--all|-t|--tags|-b|--branches>\n"
  printf "  log     [GIT_LOCAL_DIR]"
  printf "  env\n"
  printf "\n"
  printf "Options for all commands:\n"
  printf "  -d|--debug\n"
  printf "  -v|--verbose\n"
  printf "\n"
  printf "Examples:\n"
  printf "  $appname init   /var/www/vhosts/test http://server.domain/git/test.git\n"
  printf "  $appname update /var/www/vhosts/test\n"
  printf "  $appname switch /var/www/vhosts/test dev-master --verbose\n"
  printf "  $appname reset  /var/www/vhosts/test f8864e8dc63af915b869ffe0ef357c26ccee1470\n"
  printf "  $appname status /var/www/vhosts/test --hash\n"
  printf "  $appname avail  /var/www/vhosts/test --tags\n"
  printf "  $appname log    /var/www/vhosts/test\n"
  printf "  $appname env\n"
  exit 0
}

checkGitLocalDir() {
  local git_local_dir="${1}"
  [ -z ${git_local_dir} ] && msgUsage
  [ ! -d "${git_local_dir}" ] && msgError "cannot find git_local_dir: '${git_local_dir}'"
}

parseGlobalOptions() {
  msgDebug "${@}"

  for opt in "${@}"; do
    case "${opt}" in
      -d|--debug) ESDPM_OPTION_DEBUG=1 ;;
      -v|--verbose) ESDPM_OPTION_VERBOSE=1 ;;
    esac
  done
}

runHookScripts() {
  msgDebug "${@}"

  local target="${1}"
  local command="${2}"

  # find hook
  local hook="$(find ${ESDPM_HOOKS_DIR} -type f -name "${target//\//_}" 2>/dev/null)"

  # load hook and run command
  if [ ! -z ${hook} ] && [ -d "${target}" ]; then
    cd "${target}" && (
      msgVerbose "Running _${command} hook on ${target}"
      [ ${ESDPM_OPTION_VERBOSE} -ne 0 ] && set -e -x
      . "${hook}"
      if [ "$(type -t "_${command}")" != "function" ]; then
        msgVerbose "Function '_${command}' not specified in hook"
      else
        "_${command}"
      fi
    )
  fi
}

esdpmInit() {
  msgDebug "${@}"

  local git_local_dir="${1}"
  local git_repo_uri="${2}"
  local git_tmp_dir="$(mktemp -d)/$(basename ${git_local_dir})"

  # check input args
  [ -z ${git_repo_uri} ] && msgUsage

  # clone a fresh workingcopy
  git clone "${git_repo_uri}" "${git_local_dir}"
  git fetch -pta "${git_local_dir}"

  # delete temporary directory
  rm -rf "${git_tmp_dir}"
}

esdpmUpdate() {
  msgDebug "${@}"

  local git_local_dir="${1}"

  # check input args
  checkGitLocalDir ${git_local_dir}

  # update workingcopy
  cd "${git_local_dir}"
  git fetch -pta origin
  git merge origin/$(git rev-parse --abbrev-ref HEAD)
  # if failed then do stash+rebase
  if [ $? -ne 0 ]; then
    git stash
    git rebase origin/$(git rev-parse --abbrev-ref HEAD)
    git stash apply
  fi
}

esdpmSwitch() {
  msgDebug "${@}"

  local git_local_dir="${1}"
  local git_repo_branch="${2}"

  # check input args
  checkGitLocalDir "${git_local_dir}"
  [ -z ${git_repo_branch} ] && msgUsage

  # switch branch in workingcopy
  cd "${git_local_dir}"
  git fetch -pta origin
  git checkout "${git_repo_branch}"
  # if failed then get remote branch locally and checkout
  if [ $? -ne 0 ]; then
    git branch "${git_repo_branch}" origin/"${git_repo_branch}"
    git checkout "${git_repo_branch}"
  fi
}

esdpmReset() {
  msgDebug "${@}"

  local git_local_dir="${1}"
  local git_repo_hash="${2}"

  # check input args
  checkGitLocalDir "${git_local_dir}"
  [ -z ${git_repo_hash} ] && msgUsage

  # reset branch in workingcopy
  cd "${git_local_dir}"
  git reset --hard "${git_repo_hash}"
}

esdpmStatus() {
  msgDebug "${@}"

  local git_local_dir="${1}"
  local options="${2}"
  local git_repo_branch git_repo_hash

  # check input args
  checkGitLocalDir "${git_local_dir}"

  # get status from workingcopy
  cd "${git_local_dir}"
  git_repo_uri="$(git config --get remote.origin.url | sed 's|://.*@|://|g')"
  git_repo_branch="$(git rev-parse --abbrev-ref HEAD)"
  git_repo_hash="$(git rev-parse HEAD)"

  case "${options}" in
    -u|--uri) echo "${git_repo_uri}" ;;
    -b|--branch) echo "${git_repo_branch}" ;;
    -h|--hash) echo "${git_repo_hash}" ;;
    *)
       printf "uri:     %s\n" "${git_repo_uri}"
       printf "branch:  %s\n" "${git_repo_branch}"
       printf "hash:    %s\n" "${git_repo_hash}"
       ;;
  esac
}

esdpmAvail() {
  msgDebug "${@}"

  local git_local_dir="${1}"
  local options="${2}"

  # check input args
  checkGitLocalDir "${git_local_dir}"

  cd "${git_local_dir}"
  case "${options}" in
    -a|--all)
      # get all remote branches and tags available
      git for-each-ref --sort=-committerdate --format='%(refname)' refs/
      ;;
    -t|--tags)
      # get all remote tags available
      git for-each-ref --sort=-committerdate --format='%(refname)' refs/tags/ | sed 's|refs/tags/||'
      ;;
    -b|--branches)
      # get all remote branches available
      git for-each-ref --sort=-committerdate --format='%(refname)' refs/remotes/ | sed 's|refs/remotes/||'
      ;;
    *)
      # get local branches available
      git for-each-ref --sort=-committerdate --format='%(refname)' refs/heads/ | sed 's|refs/heads/||'
      ;;
  esac
}

esdpmLog() {
  msgDebug "${@}"

  local git_local_dir="${1}"

  # check input args
  checkGitLocalDir "${git_local_dir}"

  cd "${git_local_dir}"
  git log --pretty=oneline
}

esdpmEnv() {
  msgDebug "${@}"

  env | grep ^ESDPM_
}

esdpmMain() {
  local command="${1}"
  local target="${2}"

  # remove slash from the end
  target="${target%/}"

  # load config file
  [ -r "${ESDPM_CONFIG_FILE}" ] && . "${ESDPM_CONFIG_FILE}"

  # check input args
  if [ -z ${command} ]; then
    [ -z ${target} ] && [ "${command}" != "esdpmEnv" ] && msgUsage
  fi
  shift 1

  # launch hook scripts (pre-)
  runHookScripts "${target}" "pre-${command}"

  # launch command
  [ "$(type -t esdpm${command^})" == "function" ] || msgUsage
  esdpm${command^} "${@}"

  # launch hook scripts
  runHookScripts "${target}" "${command}"
}

# load config file
[ -r "${ESDPM_CONFIG_FILE}" ] && . "${ESDPM_CONFIG_FILE}"

# parse options from user input
parseGlobalOptions "${@}"

# run main function
esdpmMain "${@}"

# End of file
