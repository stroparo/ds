# Git routines
# #############################################################################

# Oneliners
gcheckedout () { git branch -v "$@" | egrep '^(==|[*]|---)' ; }
gdd () { git add -A "$@" ; git status -s ; }
gddd () { git add -A "$@" ; git status -s ; git diff --cached ; } ; ddd () { gddd ; }
gitbranchactive () { echo "$(git branch 2>/dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/')" ; }
isgitbranch () { typeset branch="$1" ; [ "${branch}" = "$(gitbranchactive)" ] ; }


clonegits () {
  # Info: Clone repos passed in the argument, one per line (quote it).
  # Syntax: {repositories-one-per-line}

  [ -z "${1}" ] && return

  while read repo repo_path ; do
    [ -z "${repo}" ] && continue
    [ -z "${repo_path}" ] && repo_path="$(basename "${repo%.git}")"

    if [ ! -d "$repo_path" ] ; then
      if ! git clone "$repo" "$repo_path" ; then
        echo "clonegits: ERROR: Cloning '$repo' repository to '${repo_path}/'." 1>&2
      fi
    else
      echo "clonegits: SKIP: '$repo_path' repository already exists." 1>&2
    fi

    echo '' 1>&2
  done <<EOF
${1}
EOF
}


clonemygits () {
  typeset devdir="${DEV:-$HOME/workspace}"
  typeset mygits

  # Options:
  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':d:' option ; do
    case "${option}" in
      d) devdir="${OPTARG}";;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  if [ -n "$1" ] ; then
    mygits="$*"
  else
    mygits="$MYGITS"
  fi
  if [ -z "$mygits" ] ; then
    echo "clonemygits: SKIP: no Git repos in MYGITS or args." 1>&2
    return
  fi

  if [ -d "${devdir}" ] ; then
    # Using the clonegits function from Daily Shells at stroparo.github.io/ds:
    (cd "${devdir}" \
      && [ "$(basename "$(pwd)")" = "$(basename "$devdir")" ] \
      && clonegits "$mygits")
  fi
}


confgits () {
  for repo in "$@" ; do
    [ -d "$repo/.git" ] || continue
    touch "$repo/.git/config"
    gitset -e "$MYEMAIL" -n "$MYSIGN" -r -v -f "$repo/.git/config"
  done
}


gitbranchtrackall () {
  # Did not use git branch -r because of this:
  # https://stackoverflow.com/questions/379081/track-all-remote-git-branches-as-local-branches

  for i in `git branch -a | grep remotes/ | grep -v HEAD | grep -v master` ; do
    git branch --track "${i#remotes/origin/}" "$i"
  done
}


gitenforcemyuser () {
  [ -n "$MYEMAIL" ] && git config --global --replace-all user.email "$MYEMAIL"
  [ -n "$MYSIGN" ] && git config --global --replace-all user.name "$MYSIGN"
}


gitpull () {

  typeset branch=master
  typeset header_msg
  typeset remote=origin
  typeset PROGNAME="gitpull()"

  # Options:
  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':b:h:r:' option ; do
    case "${option}" in
      b) branch="${OPTARG:-master}";;
      h) header_msg="${OPTARG:-master}";;
      r) remote="${OPTARG:-master}";;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  : ${header_msg:=git repositories starting with '$1'}

  echo
  echo
  echo '###############################################################################'
  echo "${PROGNAME:+$PROGNAME: }INFO: ==> ${header_msg}" 1>&2
  echo '###############################################################################'

  for repo in "$@" ; do
    repo=${repo%/.git}

    echo
    echo
    echo "${PROGNAME:+$PROGNAME: }INFO: ||"
    echo "${PROGNAME:+$PROGNAME: }INFO: ==> Pulling '${repo}' branch '${branch}' from remote '${remote}'..."
    (
      cd $repo

      branch_previously_out="$(gitbranchactive)"
      echo "${PROGNAME:+$PROGNAME: }INFO: ... current branch: ${branch_previously_out}"

      if [ "${branch_previously_out}" != "${branch}" ] ; then
        git checkout "${branch}" >/dev/null 2>&1
        if ! isgitbranch "${branch}" ; then
          echo "${PROGNAME:+$PROGNAME: }WARN: ... failed checking out '${branch}'"
          echo '---'
          continue
        fi
      fi

      # git branch --set-upstream-to="${remote}/${branch}" "${branch}"
      if git pull "${remote}" "${branch}" ; then
        echo "${PROGNAME:+$PROGNAME: }INFO: ... git status at '${PWD}':"
        git status -s
      fi

      if [ "${branch_previously_out}" != "${branch}" ] ; then
        git checkout "${branch_previously_out}" >/dev/null 2>&1
        if isgitbranch "${branch_previously_out}" ; then
          echo "${PROGNAME:+$PROGNAME: }INFO: ... checked out previous branch '${branch_previously_out}'"
        else
          echo "${PROGNAME:+$PROGNAME: }WARN: ... failed checking out previous branch '${branch_previously_out}'." 1>&2
        fi
      fi
    )
    echo '---'
  done
}


gitreinit () {
  typeset remote_url="$1"

  if [ -n "$(find . -mindepth 2 -type d -name .git)" ] ; then
    echo "gitreinit: SKIP: Git (sub?)repos found in current tree, which is not supported."
    return
  fi
  if git status -s ; then
    if [ -d ./.git ] ; then
      rm -f -r ./.git
      if [ -d ./.git ] ; then
        echo "gitreinit: FATAL: Could not remove ./.git so cannot continue." 1>&2
        return 1
      fi
    else
      echo "gitreinit: SKIP: Inside a repo but not at the root."
      return
    fi
  fi

  git init \
    && git add -A . \
    && git commit -m 'First commit'

  if [ -n "${remote_url}" ] ; then
    git remote add origin "${remote_url}"
    git push -u origin master
  fi
}


gitremotepatternreplace () {
  typeset usage="[-b {branches-to-track-comma-separated}] [-r {remote_name:=origin}] {sed-pattern} {replacement} {repo paths}"

  typeset branches_to_track="master develop"
  typeset remote_name="origin"

  typeset pattern
  typeset replace

  typeset tracksetup=false

  # Options:
  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':b:hr:st' option ; do
    case "${option}" in
      b) branches_to_track="${OPTARG:-$branches_to_track}";;
      h) echo "$usage" ; return;;
      r) remote_name="${OPTARG}";;
      s) post_sync=true;;
      t) tracksetup=true;;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  pattern="$1"
  replace="$2"
  shift 2

  for repo in "$@" ; do
    (
      repo="${repo%/.git}"
      cd "${repo}"
      if ! (git remote -v | grep -q "^ *${remote_name}") ; then
        continue
      fi

      old_remote_value="$(git remote -v | grep "^ *${remote_name}" | head -1 | awk '{print $2;}')"
      new_remote_value="$(echo "${old_remote_value}" | sed -e "s#${pattern}#${replace}#")"

      if [ "${old_remote_value}" != "${new_remote_value}" ] ; then
        echo
        echo "==> Repo: '${repo}'"
        echo "Old '$remote_name' remote: ${old_remote_value}"
        echo "New '$remote_name' remote: ${new_remote_value}"
        git remote remove "${remote_name}"
        git remote add "${remote_name}" "${new_remote_value}"

        if ${tracksetup} ; then
          for branch_to_track in $(echo "${branches_to_track}" | sed -e 's/,/ /g'); do
            gittrackremotebranches -r "${remote_name}" "${PWD}" "${branch_to_track}"
          done
        fi
      fi
    )
  done
}


gitset () {
  # Info: Configure git.
  # Syn: [-e email] [-n name] [-f file] [-r] 'key1 value1'[ key2 value2[ ...]]
  # Example: gitset -e "john@doe.com" -n "John Doe" 'core.autocrlf false' 'push.default simple'

  typeset email name replace gitconfigfile
  typeset verbose=false

  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':e:f:n:rv' opt ; do
    case "${opt}" in
    e) email="${OPTARG}" ;;
    f) gitconfigfile="${OPTARG}" ;;
    n) name="${OPTARG}" ;;
    r) replace="--replace-all";;
    v) verbose=true;;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  if [ -n "$gitconfigfile" ]; then
    if [ ! -w "${gitconfigfile}" ] ; then
      echo "FATAL: Must pass writeable file to -f option." 1>&2
      return 1
    else
      gitconfigfile="-f${gitconfigfile}"
    fi
  else
    gitconfigfile='--global'
  fi

  if [ -n "$email" ] ; then
    $verbose && echo "==>" git config $replace $gitconfigfile "user.email" "$email" 1>&2
    git config $replace $gitconfigfile user.email "$email"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
  fi

  if [ -n "$name" ]  ; then
    $verbose && echo "==>" git config $replace $gitconfigfile "user.name" "$name" 1>&2
    git config $replace $gitconfigfile user.name "$name"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
  fi

  while [ $# -ge 2 ] ; do
    $verbose && echo "==>" git config $replace $gitconfigfile "$1" "$2" 1>&2
    git config $replace $gitconfigfile "$1" "$2"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
    shift 2
  done
}


gittrackremotebranches () {
  typeset progname='gittrackremotebranches()'
  typeset usage="[-r {remote_name:=origin}] {repo_path} {branch1[ branch2[ ...]]}"

  typeset remote_name=origin
  typeset repo_path="${PWD%/.git}"

  # Options:
  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':hr:' option ; do
    case "${option}" in
      h) echo "$usage" ; return;;
      r) remote_name="${OPTARG}";;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  if [ $# -lt 2 ] ; then
    echo "${progname:+$progname: }FATAL: missed valid usage: ${usage}" 1>&2
  fi

  if [ -d "${1%/.git}/.git" ] ; then
    repo_path="${1%/.git}"
  else
    echo "${progname:+$progname: }WARN: No repository directory in first arg, falling back to default '${repo_path}'." 1>&2
  fi
  shift

  if [ ! -d "${repo_path}/.git" ] ; then
    echo "${progname:+$progname: }FATAL: No repository in directory '${repo_path}'." 1>&2
    return 1
  fi

  (
    cd "${repo_path}"

    for branch_to_track in "$@" ; do
      if git fetch "${remote_name}" "${branch_to_track}" ; then
        git branch --set-upstream-to="${remote_name}/${branch_to_track}" "${branch_to_track}"
      fi
    done
  )
}
