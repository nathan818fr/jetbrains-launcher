#!/usr/bin/env bash
#
# Source: https://github.com/nathan818fr/jetbrains-launcher
# Author: Nathan Poirier <nathan@poirier.io>
# Dependencies:
# - bash
# - coreutils (basename, cat, mkdir, nohup, realpath, rm, tr)
# - util-linux (getopt)
#
set -Eeuo pipefail
shopt -s inherit_errexit

declare -r VERSION='2023-11-17.1'
declare -r XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}
declare -r DEFAULT_JETBRAINS_APPS_DIR="${XDG_DATA_HOME}/JetBrains/Toolbox/apps"
declare -r JETBRAINS_APPS_DIR=${JETBRAINS_APPS_DIR:-$DEFAULT_JETBRAINS_APPS_DIR}
declare -r DEFAULT_JETBRAINS_PROJECTS_DIR="${XDG_DATA_HOME}/JetBrainsProjects"
declare -r JETBRAINS_PROJECTS_DIR=${JETBRAINS_PROJECTS_DIR:-$DEFAULT_JETBRAINS_PROJECTS_DIR}

function detect_ide() {
  # to test during development, use: JETBRAINS_LAUNCHER_IDE_OVERRIDE=idea ./jetbrains-launcher.sh
  case "$(basename "${JETBRAINS_LAUNCHER_IDE_OVERRIDE:-$0}" .sh)" in
  idea | intellij | intellij-idea)
    ide_id='idea'
    ide_name='IntelliJ IDEA'
    ide_command_name='idea.sh'
    ide_apps=('intellij-idea-ultimate' 'intellij-idea-community-edition')
    ide_module_type='JAVA_MODULE'
    ;;
  pycharm)
    ide_id='pycharm'
    ide_name='PyCharm'
    ide_command_name='pycharm.sh'
    ide_apps=('pycharm-professional' 'pycharm-community')
    ide_module_type='PYTHON_MODULE'
    ;;
  webstorm)
    ide_id='webstorm'
    ide_name='WebStorm'
    ide_command_name='webstorm.sh'
    ide_apps=('webstorm')
    ide_module_type='WEB_MODULE'
    ide_module_exclude_folders=('.tmp' 'temp' 'tmp')
    ;;
  phpstorm)
    ide_id='phpstorm'
    ide_name='PhpStorm'
    ide_command_name='phpstorm.sh'
    ide_apps=('phpstorm')
    ide_module_type='WEB_MODULE'
    ;;
  clion)
    ide_id='clion'
    ide_name='CLion'
    ide_command_name='clion.sh'
    ide_apps=('clion')
    ide_module_type='CPP_MODULE'
    ;;
  clion-nova)
    ide_id='clion' # CLion Nova will replace CLion, so we keep the same id
    ide_name='CLion Nova'
    ide_command_name='clion.sh'
    ide_apps=('clion-nova')
    ide_module_type='CPP_MODULE'
    ;;
  rubymine)
    ide_id='rubymine'
    ide_name='RubyMine'
    ide_command_name='rubymine.sh'
    ide_apps=('rubymine')
    ide_module_type='RUBY_MODULE'
    ide_module_testsource_folders=('features' 'spec' 'test')
    ;;
  rustrover)
    ide_id='rustrover'
    ide_name='RustRover'
    ide_command_name='rustrover.sh'
    ide_apps=('rustrover')
    ide_module_type='EMPTY_MODULE'
    ;;
  goland)
    ide_id='goland'
    ide_name='GoLand'
    ide_command_name='goland.sh'
    ide_apps=('goland')
    ide_module_type='WEB_MODULE'
    ide_module_components=('Go')
    ;;
  datagrip)
    ide_id='datagrip'
    ide_name='DataGrip'
    ide_command_name='datagrip.sh'
    ide_apps=('datagrip')
    ide_module_type='DBE_MODULE'
    ;;
  dataspell)
    ide_id='dataspell'
    ide_name='DataSpell'
    ide_command_name='dataspell.sh'
    ide_apps=('dataspell')
    ide_module_type='PYTHON_MODULE'
    ;;
  # TODO: Check if Rider can be supported
  # TODO: Check if AppCode can be supported
  # TODO: Check if MPS can be supported
  *)
    print_launcher_version >&2 # --version will not be accessible in this case, so print it here to facilitate debugging
    printf 'error: Unable to detect the IDE you want to open\n' >&2
    printf 'hint: Rename this script to "idea", "pycharm", etc.\n' >&2
    return 1
    ;;
  esac
  if [[ ! -v ide_module_components ]]; then declare -a ide_module_components; fi
  if [[ ! -v ide_module_exclude_folders ]]; then declare -a ide_module_exclude_folders; fi
  if [[ ! -v ide_module_testsource_folders ]]; then declare -a ide_module_testsource_folders; fi
  ide_command_env="JETBRAINS_${ide_id^^}_COMMAND"
}

function print_usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <project-path>

Opens a project in ${ide_name}, but stores its configuration (.idea) in a
separate directory.

Environment variables:
  JETBRAINS_APPS_DIR
    Path to the JetBrains Toolbox apps directory
    Default: ${DEFAULT_JETBRAINS_APPS_DIR}
  ${ide_command_env}
    Path to the ${ide_name} command (${ide_command_name})
    Default: auto-detected from JETBRAINS_APPS_DIR
  JETBRAINS_PROJECTS_DIR
    Path to the directory where projects configurations are stored
    Default: ${DEFAULT_JETBRAINS_PROJECTS_DIR}

Arguments:
  <project-path>  Path to the project directory to open

Options:
  -h, --help      Show this help message and exit
  -v, --version   Show version information and exit
  --reset         Reset existing project configuration (if any) before starting
                  ${ide_name}
  --no-detach     Start ${ide_name} in foreground instead of detaching it
EOF
}

function print_launcher_version() {
  printf 'JetBrains Launcher version: %s (https://github.com/nathan818fr/jetbrains-launcher)\n' "$VERSION"
}

function main() {
  detect_ide

  # parse options
  local arg_project opt_help=false opt_version=false opt_reset=false opt_no_detach=false
  eval set -- "$(getopt -o hv --long help,version,reset,no-detach -- "$@")"
  while true; do
    case "$1" in
    -h | --help)
      opt_help=true
      shift
      ;;
    -v | --version)
      opt_version=true
      shift
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
      print_usage >&2
      return 1
      ;;
    esac
  done

  # perform alternative actions if requested
  if [[ "$opt_help" = true ]]; then
    print_usage
    return 0
  fi

  if [[ "$opt_version" = true ]]; then
    print_launcher_version
    local ide_command
    ide_command="$(find_ide_command || true)"
    if [[ -n "$ide_command" ]]; then
      "$ide_command" --version || true
    fi
    return 0
  fi

  # or continue the default action
  # parse positional arguments
  if [[ $# -lt 1 ]]; then
    printf 'error: Missing project path\n\n' >&2
    print_usage >&2
    return 1
  fi
  if [[ $# -gt 1 ]]; then
    printf 'error: Too many arguments\n\n' >&2
    print_usage >&2
    return 1
  fi
  arg_project="$1"

  local ide_command project_dir conf_dir
  ide_command="$(find_ide_command)"
  project_dir=$(realpath -m -- "$arg_project")
  conf_dir="${JETBRAINS_PROJECTS_DIR}/${ide_id}/${project_dir#/}"

  printf 'Project directory: %s\n' "$project_dir"
  printf 'Configuration directory: %s\n' "$conf_dir"

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
  if [[ -z "$(shopt -s nullglob && echo "${conf_dir}/.idea/"{*.iml,*.xml})" ]]; then
    printf 'Initializing configuration\n'

    local iml_filename
    iml_filename="$(basename -- "$project_dir" | LC_ALL=C tr -dc '[:alnum:]_.-')"
    if [[ -z "$iml_filename" ]]; then iml_filename="x"; fi

    mkdir -p -- "${conf_dir}/.idea"
    if [[ "$ide_id" = 'clion' ]]; then
      write_conf_clion_cmake
    else
      write_conf_common
    fi
  else
    printf 'Existing configuration found\n'
  fi

  # start the IDE
  if [[ "$opt_no_detach" = true ]]; then
    printf 'Starting %s\n' "$ide_name"
    exec "$ide_command" "$conf_dir"
  else
    printf 'Starting %s (detached, use --no-detach to run in foreground)\n' "$ide_name"
    exec nohup "$ide_command" "$conf_dir" >/dev/null 2>/dev/null </dev/null &
  fi
}

function write_conf_modules() {
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
}

function write_conf_common() {
  # NewModuleRootManager/inherit-compiler-output, NewModuleRootManager/exclude-output and ProjectRootManager/output
  # seem only relevant for Java projects, but we set them for all projects as it doesn't seem to hurt
  cat <<EOF >"${conf_dir}/.idea/${iml_filename}.iml"
<?xml version="1.0" encoding="UTF-8"?>
<module type="$(xml_str_encode "$ide_module_type")" version="4">$(
    for e in "${ide_module_components[@]}"; do
      printf '\n  <component name="%s" enabled="true" />' "$(xml_str_encode "$e")"
    done
  )
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$(xml_str_encode "$project_dir")">$(
    for e in "${ide_module_exclude_folders[@]}"; do
      printf '\n      <excludeFolder url="file://%s/%s" />' "$(xml_str_encode "$project_dir")" "$(xml_str_encode "$e")"
    done
    for e in "${ide_module_testsource_folders[@]}"; do
      printf '\n      <sourceFolder url="file://%s/%s" isTestSource="true" />' "$(xml_str_encode "$project_dir")" "$(xml_str_encode "$e")"
    done
  )
    </content>
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
  write_conf_modules
}

function write_conf_clion_cmake() {
  cat <<EOF >"${conf_dir}/.idea/${iml_filename}.iml"
<?xml version="1.0" encoding="UTF-8"?>
<module classpath="CMake" type="CPP_MODULE" version="4" />
EOF
  cat <<EOF >"${conf_dir}/.idea/misc.xml"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="CMakeWorkspace" PROJECT_DIR="$(xml_str_encode "$project_dir")" />
</project>
EOF
  write_conf_modules
}

function find_ide_command() {
  # if JETBRAINS_*_COMMAND is set, use it
  if [[ -n "${!ide_command_env:-}" ]]; then
    if [[ ! -x "${!ide_command_env}" ]]; then
      printf 'error: %s is not executable\n' "$ide_command_env" >&2
      return 1
    fi
    printf '%s' "${!ide_command_env}"
    return
  fi

  # otherwise, try to find it in the defaults locations
  local app
  for app in "${ide_apps[@]}"; do
    local command="${JETBRAINS_APPS_DIR}/${app}/bin/${ide_command_name}"
    if [[ -x "$command" ]]; then
      printf '%s' "$command"
      return
    fi
  done

  # if not found, print error and fail
  printf 'error: %s not found in "%s"\n' "$ide_name" "$JETBRAINS_APPS_DIR" >&2
  printf 'hint: Intall it with the JetBrains Toolbox or set %s to the path of "%s"\n' "$ide_command_env" "$ide_command_name" >&2
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
