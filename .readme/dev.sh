#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit

declare -r IDE_LIST=(
  'idea|IntelliJ IDEA, ultimate or community'
  'pycharm|PyCharm, professional or community'
  'webstorm|WebStorm'
  'phpstorm|PhpStorm'
  'clion|CLion'
  'rubymine|RubyMine'
  'rustrover|RustRover'
  'goland|GoLand'
  'datagrip|DataGrip'
  'dataspell|DataSpell'
)

function main() {
  case "${1:-}" in
  download-logos) download_logos ;;
  update-oneliners) update_oneliners ;;
  *)
    printf "Usage: %s {download-logos|update-oneliners}\n" "$(basename "$0")"
    return 1
    ;;
  esac
}

function download_logos() {
  local logos_dir='.readme/logos'
  rm -rf -- "$logos_dir"
  mkdir -p -- "$logos_dir"

  local ide ide_id logo_id
  for ide in "${IDE_LIST[@]}"; do
    IFS='|' read -r ide_id _ <<<"${ide}"
    case "${ide_id}" in
    idea) logo_id='intellij-idea' ;;
    *) logo_id="${ide_id}" ;;
    esac
    printf 'Downloading %s.svg\n' "${ide_id}"
    curl -fsSL "https://resources.jetbrains.com/storage/logos/web/${logo_id}/${logo_id}.svg" |
      scour --enable-viewboxing --enable-id-stripping --enable-comment-stripping --shorten-ids --no-line-breaks \
        -o "${logos_dir}/${ide_id}.svg"
  done
}

function update_oneliners() {
  local marker_begin marker_end content
  marker_begin='<!--BEGIN ONE-LINERS-->'
  marker_end='<!--END ONE-LINERS-->'
  content="$(
    echo "$marker_begin"
    local ide ide_id ide_description
    for ide in "${IDE_LIST[@]}"; do
      IFS='|' read -r ide_id ide_description _ <<<"${ide}"
      cat <<EOF
<details>
  <summary><code>${ide_id}</code> (<img alt="${ide_description%%,*} logo" src=".readme/logos/${ide_id}.svg?raw=true" width="16" height="16"> ${ide_description})</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\\\\
    Download the launcher to \`~/.local/bin/${ide_id}\` (make sure \`~/.local/bin\` is in your PATH):
    \`\`\`shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/${ide_id}
    \`\`\`

  - **🍏 macOS** (see requirements above)\\\\
    Download the launcher to \`~/.local/bin/${ide_id}\` (make sure \`~/.local/bin\` is in your PATH):
    \`\`\`shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/${ide_id} && chmod +x ~/.local/bin/${ide_id}
    \`\`\`
</details>
EOF
    done
    echo "$marker_end"
  )"
  awk -v mb="$marker_begin" -v me="$marker_end" -v c="$content" \
    '($0==mb){del=1} ($0==me){$0=c; del=0} !del' README.md >README.md.tmp
  mv -f README.md.tmp README.md

  printf 'README.md updated\n'
}

eval 'main "$@";exit "$?"'
