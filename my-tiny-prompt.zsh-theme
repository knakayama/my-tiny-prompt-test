-get-git-current-branch() {
  local branch_name git_status color gitdir action

  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then
    branch_name="$(git rev-parse --abbrev-ref=loose HEAD 2> /dev/null)"
    [[ -z "$branch_name" ]] && return 0

    gitdir="$(git rev-parse --git-dir 2> /dev/null)"
    action="$(VCS_INFO_git_getaction "$gitdir")" && action="($action)"
    git_status="$(git status 2> /dev/null)"

    if [[ "$git_status" =~ "(?m)^nothing to" ]]; then
      color="%F{green}"
    elif [[ "$git_status" =~ "(?m)^nothing added" ]]; then
      color="%F{yellow}"
    elif [[ "$git_status" =~ "(?m)^# Untracked" ]]; then
      color="%B%F{red}"
    else
      color="%F{red}"
    fi
    echo " ${color}@${branch_name}${action}%f%b"
  fi
  return 0
}

# http://d.hatena.ne.jp/pasela/20110216/git_not_pushed
-get-git-remote-commit-log() {
  local head remotes x

  # When the current working directory is inside the work tree of the repository print "true", otherwise "false".
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then

    # Verify that exactly one parameter is provided, and that it can be turned into a raw 20-byte SHA-1 that can be used
    # to access the object database. If so, emit it to the standard output; otherwise, error out.
    head="$(git rev-parse --verify --quite HEAD 2>/dev/null)"

    if [[ $? -eq 0 ]]; then
      remotes=($(git rev-parse --remotes))
      if [[ -n "${remotes[@]}" ]]; then
        for x in ${remotes[@]}; do
          [[ "$head" == "$x" ]] && return 0
        done
        echo " %F{red}@not_pushed%f%b"
      fi
    fi
  fi
  return 0
}

# TODO: get exit status

# enable color prompt
autoload -U colors && colors
# prompt theme
autoload -U promptinit && promptinit

autoload -Uz VCS_INFO_get_data_git
VCS_INFO_get_data_git 2> /dev/null
compinit -u

# use pcre-compatible regexp
setopt re_match_pcre

# eval prompt when showing prompt
setopt prompt_subst

# prompt
# %n -> user name
# %m -> hostname
# %~ -> current directory(home directory is ~)
# %(1,#,$)
# %f%b same as %{${reset_color}%}?
PROMPT='%n %F{blue}%~%f%b$(-get-git-current-branch)$(-get-git-remote-commit-log)'$'\n''%(!,#,$) '
