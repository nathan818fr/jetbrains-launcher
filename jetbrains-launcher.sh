#!/usr/bin/env bash
#
# Source: https://github.com/nathan818fr/jetbrains-launcher
# Author: Nathan Poirier <nathan@poirier.io>
# Debian dependencies:
# - bash
# - coreutils (basename, cat, mkdir, nohup, realpath, rm, tr)
# - util-linux (getopt)
# Homebrew dependencies:
# - bash
# - coreutils
# - gnu-getopt
#
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]] || [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -lt 2 ]]; then
  printf 'error: Bash 4.2 or higher is required\n' >&2
  exit 1
fi

set -Eeuo pipefail
shopt -s inherit_errexit

declare -r VERSION='2023-12-11.0'

function detect_platform() {
  # Detect the launcher platform
  # - win_cyg: Windows, Cygwin-like (Cygwin, MSYS2, Git Bash, ...)
  # - win_wsl: Windows, WSL
  # - mac: macOS
  # - linux: Linux or others unix-like systems (default)
  case "${OSTYPE:-}" in
  cygwin* | msys* | win32)
    declare -gr launcher_platform='win_cyg'
    ;;
  darwin*)
    declare -gr launcher_platform='mac'
    ;;
  *)
    if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
      declare -gr launcher_platform='win_wsl'
    else
      declare -gr launcher_platform='linux'
    fi
    ;;
  esac

  # Set platform-specific variables
  case "$launcher_platform" in
  win*)
    if [[ "$launcher_platform" = 'win_cyg' ]]; then
      function winvar() { printf '%s' "${!1}"; }
    else
      function winvar() {
        local val
        val=$(cmd.exe /c "<nul set /p =%$1%" 2>/dev/null || true)
        if [[ -z "$val" ]]; then
          printf 'error: Unable to read windows variable %s\n' "$1" >&2
          return 1
        fi
        printf '%s' "$val"
      }
    fi
    local localappdata appdata
    localappdata=$(read_path "$(winvar LOCALAPPDATA)")
    appdata=$(read_path "$(winvar APPDATA)")
    declare -gr default_jetbrains_apps_dir="${localappdata}/Programs"
    declare -gr default_jetbrains_projects_dir="${appdata}/JetBrainsProjects"
    ;;
  mac)
    declare -gr default_jetbrains_apps_dir="${HOME}/Applications"
    declare -gr default_jetbrains_projects_dir="${HOME}/Library/JetBrainsProjects"
    ;;
  *)
    local xdg_data_home
    xdg_data_home=$(read_path "${XDG_DATA_HOME:-${HOME}/.local/share}")
    declare -gr default_jetbrains_apps_dir="${xdg_data_home}/JetBrains/Toolbox/apps"
    declare -gr default_jetbrains_projects_dir="${xdg_data_home}/JetBrainsProjects"
    ;;
  esac

  # Set user-defined variables, or use default values if not set
  local path
  if [[ -n "${JETBRAINS_APPS_DIR:-}" ]]; then
    path=$(read_path "$JETBRAINS_APPS_DIR")
    declare -gr jetbrains_apps_dir=$path
  else
    declare -gr jetbrains_apps_dir=$default_jetbrains_apps_dir
  fi
  if [[ -n "${JETBRAINS_PROJECTS_DIR:-}" ]]; then
    path=$(read_path "$JETBRAINS_PROJECTS_DIR")
    declare -gr jetbrains_projects_dir=$path
  else
    declare -gr jetbrains_projects_dir=$default_jetbrains_projects_dir
  fi
}

function detect_ide() {
  # Detect the launcher IDE
  # To test during development, use: JETBRAINS_LAUNCHER_IDE_OVERRIDE=idea ./jetbrains-launcher.sh
  local launcher_ide
  launcher_ide=$(basename "${JETBRAINS_LAUNCHER_IDE_OVERRIDE:-$0}" .sh)

  # Set ide-specific variables
  # - ide_id
  # - ide_name
  # - ide_apps: list of IDE variants (defaults to ide_name)
  # - ide_bins: list of IDE binaries names (defaults based on ide_id depending on the platform)
  # - ide_module_type: .iml module type
  # - ide_module_components: list of .iml additional components
  # - ide_module_exclude_folders: list of .iml additional exclude folders
  # - ide_module_testsource_folders: list of .iml additional test source folders
  # - ide_command_env: environment variable to override the IDE command
  case "$launcher_ide" in
  idea | intellij | intellij-idea)
    declare -gr ide_id='idea'
    declare -gr ide_name='IntelliJ IDEA'
    declare -gr ide_apps=('IntelliJ IDEA Ultimate' 'IntelliJ IDEA Community Edition')
    declare -gr ide_module_type='JAVA_MODULE'
    ;;
  pycharm)
    declare -gr ide_id='pycharm'
    declare -gr ide_name='PyCharm'
    declare -gr ide_apps=('PyCharm Professional' 'PyCharm Community')
    declare -gr ide_module_type='PYTHON_MODULE'
    ;;
  webstorm)
    declare -gr ide_id='webstorm'
    declare -gr ide_name='WebStorm'
    declare -gr ide_module_type='WEB_MODULE'
    declare -gr ide_module_exclude_folders=('.tmp' 'temp' 'tmp')
    ;;
  phpstorm)
    declare -gr ide_id='phpstorm'
    declare -gr ide_name='PhpStorm'
    declare -gr ide_module_type='WEB_MODULE'
    ;;
  clion)
    declare -gr ide_id='clion'
    declare -gr ide_name='CLion'
    declare -gr ide_module_type='CPP_MODULE'
    ;;
  clion-nova)
    declare -gr ide_id='clion' # CLion Nova will replace CLion, so we keep the same id
    declare -gr ide_name='CLion Nova'
    declare -gr ide_module_type='CPP_MODULE'
    ;;
  rubymine)
    declare -gr ide_id='rubymine'
    declare -gr ide_name='RubyMine'
    declare -gr ide_module_type='RUBY_MODULE'
    declare -gr ide_module_testsource_folders=('features' 'spec' 'test')
    ;;
  rustrover)
    declare -gr ide_id='rustrover'
    declare -gr ide_name='RustRover'
    declare -gr ide_module_type='EMPTY_MODULE'
    ;;
  goland)
    declare -gr ide_id='goland'
    declare -gr ide_name='GoLand'
    declare -gr ide_module_type='WEB_MODULE'
    declare -gr ide_module_components=('Go')
    ;;
  datagrip)
    declare -gr ide_id='datagrip'
    declare -gr ide_name='DataGrip'
    declare -gr ide_module_type='DBE_MODULE'
    ;;
  dataspell)
    declare -gr ide_id='dataspell'
    declare -gr ide_name='DataSpell'
    declare -gr ide_module_type='PYTHON_MODULE'
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

  if [[ ! -v ide_apps ]]; then
    declare -gr ide_apps=("$ide_name")
  fi
  if [[ ! -v ide_bins ]]; then
    case "$launcher_platform" in
    win*) declare -gr ide_bins=("bin/${ide_id}64.exe" "bin/${ide_id}.exe") ;;
    mac) declare -gr ide_bins=("MacOS/${ide_id}") ;;
    *) declare -gr ide_bins=("bin/${ide_id}.sh") ;;
    esac
  fi
  if [[ ! -v ide_module_components ]]; then declare -gr ide_module_components=(); fi
  if [[ ! -v ide_module_exclude_folders ]]; then declare -gr ide_module_exclude_folders=(); fi
  if [[ ! -v ide_module_testsource_folders ]]; then declare -gr ide_module_testsource_folders=(); fi
  declare -gr ide_command_env="JETBRAINS_${ide_id^^}_COMMAND"
}

function print_usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <project-path>

Opens a project in ${ide_name}, but stores its configuration (.idea) in a
separate directory.

Environment variables:
  JETBRAINS_APPS_DIR
    Path to the JetBrains Toolbox apps directory
    Default: $(write_path "$default_jetbrains_apps_dir")
  ${ide_command_env}
    Path to the ${ide_name} command (${ide_bins[0]})
    Default: auto-detected from JETBRAINS_APPS_DIR
  JETBRAINS_PROJECTS_DIR
    Path to the directory where projects configurations are stored
    Default: $(write_path "$default_jetbrains_projects_dir")

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
  printf 'JetBrains Launcher platform: %s\n' "${launcher_platform:-unknown}"
}

function main() {
  detect_platform
  detect_ide

  # parse options
  local opt_help=false opt_version=false opt_reset=false opt_no_detach=false
  eval set -- "$(gnu_getopt -o hv --long help,version,reset,no-detach -- "$@")"
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

  local ide_command project_dir conf_dir
  ide_command="$(find_ide_command)"
  project_dir=$(read_path "$1")
  conf_dir="${jetbrains_projects_dir}/${ide_id}/$(appendable_path "$project_dir")"

  printf 'Project directory: %s\n' "$(write_path "$project_dir")"
  printf 'Configuration directory: %s\n' "$(write_path "$conf_dir")"

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
    exec_attached "$ide_command" "$(write_path "$conf_dir")"
  else
    printf 'Starting %s (detached, use --no-detach to run in foreground)\n' "$ide_name"
    exec_detached "$ide_command" "$(write_path "$conf_dir")"
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
    <content url="file://$(xml_str_encode "$(write_path "$project_dir")")">$(
    for e in "${ide_module_exclude_folders[@]}"; do
      printf '\n      <excludeFolder url="file://%s/%s" />' "$(xml_str_encode "$(write_path "$project_dir")")" "$(xml_str_encode "$e")"
    done
    for e in "${ide_module_testsource_folders[@]}"; do
      printf '\n      <sourceFolder url="file://%s/%s" isTestSource="true" />' "$(xml_str_encode "$(write_path "$project_dir")")" "$(xml_str_encode "$e")"
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
    <output url="file://$(xml_str_encode "$(write_path "$project_dir")")/out" />
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
  <component name="CMakeWorkspace" PROJECT_DIR="$(xml_str_encode "$(write_path "$project_dir")")" />
</project>
EOF
  write_conf_modules
}

function find_ide_command() {
  # if JETBRAINS_*_COMMAND is set, use it
  if [[ -n "${!ide_command_env:-}" ]]; then
    local command
    command="$(read_path "${!ide_command_env:-}")"
    if [[ ! -x "$command" ]]; then
      printf 'error: %s is not executable\n' "$ide_command_env" >&2
      return 1
    fi
    printf '%s' "$command"
    return
  fi

  # otherwise, try to find it in the defaults locations
  local app bin
  for app in "${ide_apps[@]}"; do
    for bin in "${ide_bins[@]}"; do
      local app_dir
      case "$launcher_platform" in
      win*) app_dir="$app" ;;
      mac) app_dir="${app}.app/Contents" ;;
      *)
        app_dir="${app,,}"        # lowercase
        app_dir="${app_dir// /-}" # replace spaces with dashes
        ;;
      esac
      local command="${jetbrains_apps_dir}/${app_dir}/${bin}"
      if [[ -x "$command" ]]; then
        printf '%s' "$command"
        return
      fi
    done
  done

  # if not found, print error and fail
  printf 'error: %s not found in "%s"\n' "$ide_name" "$(write_path "$jetbrains_apps_dir")" >&2
  printf 'hint: Install it with the JetBrains Toolbox or set %s to the path of "%s"\n' "$ide_command_env" "${ide_bins[0]}" >&2
  return 1
}

# Convert a system path to an absolute unix path
function read_path() {
  local path=$1
  case "$launcher_platform" in
  win_cyg)
    # Convert all paths using cygpath (unix mode, absolute path)
    # It supports both unix and windows paths
    cygpath -u -a -- "$path"
    ;;
  win_wsl)
    case "$path" in
    [a-zA-Z]:\\* | [a-zA-Z]:/* | \\\\* | //*)
      # Convert windows path using wslpath (unix mode, absolute path)
      wslpath -u -a -- "$path"
      ;;
    *)
      # Convert unix path using realpath
      realpath -m -- "$path"
      ;;
    esac
    ;;
  *)
    realpath -m -- "$path"
    ;;
  esac
}

# Convert unix path to system path
function write_path() {
  local path=$1
  case "$launcher_platform" in
  win_cyg)
    # Convert using cygpath (mixed mode, absolute path, long form)
    cygpath -m -a -l -- "$path"
    ;;
  win_wsl)
    # Convert using wslpath (mixed mode, absolute path)
    wslpath -m -a -- "$path"
    ;;
  *)
    printf '%s' "$path"
    ;;
  esac
}

function appendable_path() {
  local path=$1
  path=$(write_path "$path")
  case "$launcher_platform" in
  win*)
    path=${path//\\/\/} # replace backslashes with slashes
    path=${path//:/}    # remove colons
    path=${path#//}     # remove leading double slash
    ;;
  *)
    path=${path#/} # remove leading slash
    ;;
  esac
  printf '%s' "$path"
}

function gnu_getopt() {
  case "$launcher_platform" in
  mac)
    # macOS ships with a BSD version of getopt, which is not compatible with the GNU version

    # Try to use the Homebrew gnu-getopt
    local getopt_path
    getopt_path="$(brew --prefix 2>/dev/null || echo /usr/local)/opt/gnu-getopt/bin/getopt"
    if [[ -x "$getopt_path" ]]; then
      "$getopt_path" "$@"
      return
    fi

    # If getopt is the GNU version, use it
    local getopt_version
    getopt_version=$(getopt --version 2>/dev/null || true)
    if [[ "$getopt_version" = *util-linux* ]]; then
      getopt "$@"
      return
    fi

    printf 'error: GNU getopt not found\n' >&2
    printf 'hint: Install it with "brew install gnu-getopt"\n' >&2
    return 1
    ;;
  *)
    getopt "$@"
    ;;
  esac
}

function exec_attached() {
  exec "$@"
}

function exec_detached() {
  exec nohup "$@" >/dev/null 2>/dev/null </dev/null &
}

# Encode a string for use in XML texts or attribute values
function xml_str_encode() {
  local encoded=$1
  encoded=${encoded//&/\&amp;}
  encoded=${encoded//</\&lt;}
  encoded=${encoded//>/\&gt;}
  encoded=${encoded//\"/\&quot;}
  encoded=${encoded//\'/\&apos;}
  printf '%s' "$encoded"
}

eval 'main "$@";exit "$?"'
