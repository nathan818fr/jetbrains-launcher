#!/usr/bin/env bash
#
# Source: https://github.com/nathan818fr/jetbrains-scripts
# Author: Nathan Poirier <nathan@poirier.io>
# Revision: 2023-11-15.0
# Dependencies:
# - bash
# - coreutils (basename, cat, mkdir, nohup, realpath, rm, tr)
# - util-linux (getopt)
#
set -Eeuo pipefail
shopt -s inherit_errexit

declare -r XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}
declare -r DEFAULT_JETBRAINS_APPS_DIR="${XDG_DATA_HOME}/JetBrains/Toolbox/apps"
declare -r JETBRAINS_APPS_DIR=${JETBRAINS_APPS_DIR:-$DEFAULT_JETBRAINS_APPS_DIR}
declare -r DEFAULT_JETBRAINS_PROJECTS_DIR="${XDG_DATA_HOME}/JetBrainsProjects"
declare -r JETBRAINS_PROJECTS_DIR=${JETBRAINS_PROJECTS_DIR:-$DEFAULT_JETBRAINS_PROJECTS_DIR}

function usage() {
  cat <<EOF
Usage: $0 [options] <project-path>

Opens a project in IntelliJ IDEA, but stores its configuration (.idea) in a
separate directory.

Environment variables:
  JETBRAINS_APPS_DIR
    Path to the JetBrains Toolbox apps directory
    Default: ${DEFAULT_JETBRAINS_APPS_DIR}
  JETBRAINS_IDEA_COMMAND
    Path to the IntelliJ IDEA command (idea.sh)
    Default: auto-detected from JETBRAINS_APPS_DIR
  JETBRAINS_PROJECTS_DIR
    Path to the directory where projects configurations are stored
    Default: ${DEFAULT_JETBRAINS_PROJECTS_DIR}

Arguments:
  <project-path>  Path to the project directory to open

Options:
  -h, --help      Show this help message and exit
  --reset         Reset existing project configuration (if any) before starting
                  IntelliJ IDEA
  --no-detach     Start IntelliJ IDEA in foreground instead of detaching it
EOF
}

function main() {
  # parse arguments
  local arg_project opt_reset=false opt_no_detach=false
  eval set -- "$(getopt -o h --long help,reset,no-detach -- "$@")"
  while true; do
    case "$1" in
    -h | --help)
      usage
      return 0
      ;;
    --reset)
      opt_reset=true
      shift
      ;;
    --no-detach)
      opt_no_detach=true
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      printf 'error: Invalid option "%s"\n\n' "$1" >&2
      usage >&2
      return 1
      ;;
    esac
  done
  if [[ $# -lt 1 ]]; then
    printf 'error: Missing project path\n\n' >&2
    usage >&2
    return 1
  fi
  if [[ $# -gt 1 ]]; then
    printf 'error: Too many arguments\n\n' >&2
    usage >&2
    return 1
  fi
  arg_project="$1"

  local ide_command project_dir conf_dir
  ide_command="$(find_ide_command)"
  project_dir=$(realpath -m -- "$arg_project")
  conf_dir="${JETBRAINS_PROJECTS_DIR}/idea/${project_dir#/}"

  printf 'Project directory: %s\n' "$project_dir"
  printf 'Configuration directory: %s\n' "${conf_dir}"

  # ensure project directory exists
  if [[ ! -e "$project_dir" ]]; then
    printf 'error: Project directory does not exist\n' >&2
    return 1
  fi

  # reset configuration if requested
  if [[ "$opt_reset" = true ]] && [[ -e "$conf_dir" ]]; then
    printf 'Removing existing configuration\n'
    rm -rf -- "${conf_dir}/.idea"
  fi

  # initialize configuration if needed
  if [[ -z "$(shopt -s nullglob && echo "${conf_dir}/.idea/"*.iml)" ]]; then
    printf 'Initializing configuration\n'

    local iml_filename
    iml_filename="$(basename -- "$project_dir" | LC_ALL=C tr -dc '[:alnum:]_.-')"
    if [[ -z "$iml_filename" ]]; then iml_filename="x"; fi

    mkdir -p -- "${conf_dir}/.idea"
    cat <<EOF >"${conf_dir}/.idea/${iml_filename}.iml"
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$(xml_str_encode "$project_dir")" />
    <orderEntry type="inheritedJdk" />
    <orderEntry type="sourceFolder" forTests="false" />
  </component>
</module>
EOF
    cat <<EOF >"${conf_dir}/.idea/misc.xml"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectRootManager">
    <output url="file://$(xml_str_encode "$project_dir")/out" />
  </component>
</project>
EOF
    cat <<EOF >"${conf_dir}/.idea/modules.xml"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://\$PROJECT_DIR\$/.idea/$(xml_str_encode "$iml_filename").iml" filepath="\$PROJECT_DIR\$/.idea/$(xml_str_encode "$iml_filename").iml" />
    </modules>
  </component>
</project>
EOF
  fi

  # start IntelliJ IDEA
  if [[ "$opt_no_detach" = true ]]; then
    printf 'Starting IntelliJ IDEA\n'
    exec "$ide_command" "$conf_dir"
  else
    printf 'Starting IntelliJ IDEA (detached, use --no-detach to run in foreground)\n'
    exec nohup "$ide_command" "$conf_dir" >/dev/null 2>/dev/null </dev/null &
  fi
}

function find_ide_command() {
  # if JETBRAINS_IDEA_COMMAND is set, use it
  if [[ -n "${JETBRAINS_IDEA_COMMAND:-}" ]]; then
    if [[ ! -x "$JETBRAINS_IDEA_COMMAND" ]]; then
      printf 'error: JETBRAINS_IDEA_COMMAND is not executable\n' >&2
      return 1
    fi
    printf '%s' "$JETBRAINS_IDEA_COMMAND"
    return
  fi

  # otherwise, try to find it in the defaults locations
  local app
  for app in 'intellij-idea-ultimate' 'intelij-idea-community-edition'; do
    local command="${JETBRAINS_APPS_DIR}/${app}/bin/idea.sh"
    if [[ -x "$command" ]]; then
      printf '%s' "$command"
      return
    fi
  done

  # if not found, print error and fail
  printf 'error: IntelliJ IDEA not found in "%s"\n' "$JETBRAINS_APPS_DIR" >&2
  printf 'hint: Intall it with the JetBrains Toolbox or set JETBRAINS_IDEA_COMMAND to the path of "idea.sh"\n' >&2
  return 1
}

# Encode a string for use in XML texts or attribute values
function xml_str_encode() {
  local encoded="$1"
  encoded="${encoded//&/\&amp;}"
  encoded="${encoded//</\&lt;}"
  encoded="${encoded//>/\&gt;}"
  encoded="${encoded//\"/\&quot;}"
  encoded="${encoded//\'/\&apos;}"
  printf '%s' "$encoded"
}

eval 'main "$@";exit "$?"'
