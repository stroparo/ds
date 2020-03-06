# Git routines
# #############################################################################

# Oneliners
gcheckedout () { git branch -v "$@" | egrep '^(==|[*]|---)' ; }
gdd () { git add -A "$@" ; git status -s ; }
gddd () { git add -A "$@" ; git status -s ; git diff --cached ; } ; ddd () { gddd ; }


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

  echo "${PROGNAME:+$PROGNAME: }INFO: ==> ${header_msg}" 1>&2

  for repo in "$@" ; do
    repo=${repo%/.git}

    echo "${PROGNAME:+$PROGNAME: }INFO: ||"
    echo "${PROGNAME:+$PROGNAME: }INFO: ==> Pulling '${repo}' branch '${branch}' from remote '${remote}'..."
    (
      cd $repo

      branch_previously_out="$(git branch 2>/dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/')"
      echo ${BASH_VERSION:+-e} "... current branch: ${branch_previously_out}"

      git checkout "${branch}" \
        && (git branch 2>/dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/') \
        && git branch --set-upstream-to="${remote}/${branch}" "${branch}" \
        && git pull "${remote}" "${branch}"
      echo "${PROGNAME:+$PROGNAME: }INFO: git status at '${PWD}':"
      git status -s

      git checkout "${branch_previously_out}"
      branch_restored="$(git branch 2>/dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/')"
      echo "${PROGNAME:+$PROGNAME: }INFO: ... checked out previous branch '${branch_restored}'"
      if [ $branch_restored != $branch_previously_out ] ; then
        echo "${PROGNAME:+$PROGNAME: }WARN: Could not checkout previous active branch '$branch_previously_out'." 1>&2
      fi
    )
    echo '---'
  done
}


gitreinit () {
  typeset remote_url="$1"

  if [ -n "$(find . -mindepth 2 -type d -name .git)" ] ; then
    echo "greinit: SKIP: Git (sub?)repos found in current tree, which is not supported."
    return
  fi
  if git status -s ; then
    if [ -d ./.git ] ; then
      rm -f -r ./.git
      if [ -d ./.git ] ; then
        echo "greinit: FATAL: Could not remove ./.git so cannot continue." 1>&2
        return 1
      fi
    else
      echo "greinit: SKIP: Inside a repo but not at the root."
      return
    fi
  fi

  git init \
    && git add -A . \
    && git commit -m 'First'

  if [ -n "${remote_url}" ] ; then
    git remote add origin "${remote_url}"
    git push -u origin master
  fi
}


gitremotepatternreplace () {
  # Usage: [-s [-b {branch-to-sync}]] [-r {remote_name:=origin}] {sed-pattern} {replacement} {repo paths}

  typeset post_sync_branch
  typeset remote_name=origin
  typeset post_sync=false

  typeset pattern
  typeset replace

  # Options:
  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':b:r:s' option ; do
    case "${option}" in
      b) post_sync_branch="${OPTARG}";;
      r) remote_name="${OPTARG}";;
      s) post_sync=true;;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  pattern="$1"
  replace="$2"
  shift 2

  for repo in "$@" ; do
    (
      cd "${repo%/.git}"
      if git remote -v | grep -q "^ *${remote_name}" ; then
        old_remote_value="$(git remote -v | grep "^ *${remote_name}" | head -1 | awk '{print $2;}')"
        new_remote_value="$(echo "${old_remote_value}" | sed -e "s#${pattern}#${replace}#")"
        if [ "${old_remote_value}" != "${new_remote_value}" ] ; then
          echo "==> Repo: '${repo}'"
          echo "Old '$remote_name' remote: ${old_remote_value}"
          echo "New '$remote_name' remote: ${new_remote_value}"
          git remote remove "${remote_name}"
          git remote add "${remote_name}" "${new_remote_value}"
          # if "${post_sync:-false}" ; then
          #   TODO test current branch behavior..
          #   if [ -n "${post_sync_branch}" ] ; then git checkout "${post_sync_branch}" fi
          #   git pull "${remote_name}"
          #   git push "${remote_name}" HEAD
          # fi
        fi
      fi
    )
  done
}


gitset () {
  # Info: Configure git.
  # Syn: [-e email] [-n name] [-f file] [-r] 'key1 value1'[ key2 value2[ ...]]
  # Example: gitset -e "john@doe.com" -n "John Doe" 'core.autocrlf false' 'push.default simple'

  typeset email name replace where
  typeset verbose=false

  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':e:f:n:rv' opt ; do
    case "${opt}" in
    e) email="${OPTARG}" ;;
    f) where="${OPTARG}" ;;
    n) name="${OPTARG}" ;;
    r) replace="--replace-all";;
    v) verbose=true;;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  if [ -n "$where" ]; then
    if [ ! -w "${where}" ] ; then
      echo "FATAL: Must pass writeable file to -f option." 1>&2
      return 1
    else
      where="-f${where}"
    fi
  else
    where='--global'
  fi

  if [ -n "$email" ] ; then
    $verbose && echo "==>" git config $replace $where "user.email" "$email" 1>&2
    git config $replace $where user.email "$email"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
  fi

  if [ -n "$name" ]  ; then
    $verbose && echo "==>" git config $replace $where "user.name" "$name" 1>&2
    git config $replace $where user.name "$name"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
  fi

  while [ $# -ge 2 ] ; do
    $verbose && echo "==>" git config $replace $where "$1" "$2" 1>&2
    git config $replace $where "$1" "$2"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
    shift 2
  done
}

