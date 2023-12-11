# JetBrains Launcher

A command-line launcher to open your projects in a JetBrains IDE, but with
a twist: **it stores the IDE config (`.idea`) in a separate directory!**

## Why is this beneficial?

Storing `.idea` in a separate directory has several advantages:
1. **Version control friendly**: It's easier to manage your version control
   system (like Git) as you don't have to worry about excluding IDE-specific
   files. Also, your IDE will not break if a team member pushes its `.idea`
   content ([it happens][issue-1]).
2. **Cleaner project directory**: Your project directory remain clean and IDE
   agnostic.
3. **Support multiple IDEs**: You can open your project with different JetBrains
   IDEs without having to worry about configuration conflicts (e.g. when using
   both [IntelliJ IDEA and CLion][issue-2], or [PyCharm and CLion][issue-3]).

[issue-1]: https://youtrack.jetbrains.com/issue/IDEA-170102#focus=Comments-27-7538571.0-0
[issue-2]: https://intellij-support.jetbrains.com/hc/en-us/community/posts/206607105
[issue-3]: https://youtrack.jetbrains.com/issue/IDEA-140707

## Installation

Supported platforms:
- 🐧 Linux and other Unix-like systems
- 🍏 macOS (require [a recent bash version][brew-bash],
  [coreutils][brew-coreutils] and [gnu-getopt][brew-gnu-getopt])
- 🪟 Windows (using Bash: Git Bash/WSL/MinGW/MSYS/Cygwin)

[brew-bash]: https://formulae.brew.sh/formula/bash
[brew-coreutils]: https://formulae.brew.sh/formula/coreutils
[brew-gnu-getopt]: https://formulae.brew.sh/formula/gnu-getopt

To install or update jetbrains-launcher, you should download
`jetbrains-launcher.sh`, rename it to the name of the JetBrains IDE you want to
use (e.g. `idea` or `idea.sh`), and put it in your `PATH`.

One-liners to do this are available below:

<!--BEGIN ONE-LINERS-->
<details>
  <summary><code>idea</code> (<img alt="IntelliJ IDEA logo" src=".readme/logos/idea.svg?raw=true" width="16" height="16"> IntelliJ IDEA, ultimate or community)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/idea` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/idea
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/idea` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/idea && chmod +x ~/.local/bin/idea
    ```
</details>
<details>
  <summary><code>pycharm</code> (<img alt="PyCharm logo" src=".readme/logos/pycharm.svg?raw=true" width="16" height="16"> PyCharm, professional or community)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/pycharm` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/pycharm
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/pycharm` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/pycharm && chmod +x ~/.local/bin/pycharm
    ```
</details>
<details>
  <summary><code>webstorm</code> (<img alt="WebStorm logo" src=".readme/logos/webstorm.svg?raw=true" width="16" height="16"> WebStorm)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/webstorm` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/webstorm
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/webstorm` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/webstorm && chmod +x ~/.local/bin/webstorm
    ```
</details>
<details>
  <summary><code>phpstorm</code> (<img alt="PhpStorm logo" src=".readme/logos/phpstorm.svg?raw=true" width="16" height="16"> PhpStorm)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/phpstorm` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/phpstorm
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/phpstorm` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/phpstorm && chmod +x ~/.local/bin/phpstorm
    ```
</details>
<details>
  <summary><code>clion</code> (<img alt="CLion logo" src=".readme/logos/clion.svg?raw=true" width="16" height="16"> CLion)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/clion` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/clion
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/clion` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/clion && chmod +x ~/.local/bin/clion
    ```
</details>
<details>
  <summary><code>rubymine</code> (<img alt="RubyMine logo" src=".readme/logos/rubymine.svg?raw=true" width="16" height="16"> RubyMine)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/rubymine` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/rubymine
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/rubymine` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/rubymine && chmod +x ~/.local/bin/rubymine
    ```
</details>
<details>
  <summary><code>rustrover</code> (<img alt="RustRover logo" src=".readme/logos/rustrover.svg?raw=true" width="16" height="16"> RustRover)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/rustrover` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/rustrover
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/rustrover` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/rustrover && chmod +x ~/.local/bin/rustrover
    ```
</details>
<details>
  <summary><code>goland</code> (<img alt="GoLand logo" src=".readme/logos/goland.svg?raw=true" width="16" height="16"> GoLand)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/goland` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/goland
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/goland` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/goland && chmod +x ~/.local/bin/goland
    ```
</details>
<details>
  <summary><code>datagrip</code> (<img alt="DataGrip logo" src=".readme/logos/datagrip.svg?raw=true" width="16" height="16"> DataGrip)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/datagrip` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/datagrip
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/datagrip` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/datagrip && chmod +x ~/.local/bin/datagrip
    ```
</details>
<details>
  <summary><code>dataspell</code> (<img alt="DataSpell logo" src=".readme/logos/dataspell.svg?raw=true" width="16" height="16"> DataSpell)</summary>

  - **🐧 Linux, 🪟 Windows (using Bash)**\
    Download the launcher to `~/.local/bin/dataspell` (make sure `~/.local/bin` is in your PATH):
    ```shell
    curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/dataspell
    ```

  - **🍏 macOS** (see requirements above)\
    Download the launcher to `~/.local/bin/dataspell` (make sure `~/.local/bin` is in your PATH):
    ```shell
    mkdir -p ~/.local/bin && curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh -o ~/.local/bin/dataspell && chmod +x ~/.local/bin/dataspell
    ```
</details>
<!--END ONE-LINERS-->

## Usage

Use this launcher to open your projects from the command line rather than from
the JetBrains IDEs interfaces. e.g.:
```shell
# Open ~/projects/my-project with IntelliJ IDEA:
idea ~/projects/my-project

# Open the current directory with IntelliJ IDEA:
idea .
```

👉️ If a project has been opened once with this launcher, you can re-open it
from the "Recent Projects" interface (or you can use this launcher again).

⚠️ But you should NOT open it from "File > Open...".

---

Usage: `command [options] <project-path>`

Options:
- `-h`, `--help` – Show help message and exit.<br>
  _Use this to see all options and environment variables (this readme only
  summarizes the most useful ones)._
- `--reset` – Reset existing project configuration (if any) before starting
  the IDE.<br>
  _This removes the `.idea` directory created by this launcher._
- `--no-detach` – Start the IDE in foreground instead of detaching it.

Environment variables:
- `JETBRAINS_PROJECTS_DIR` – Path to the directory where projects configurations
  are stored.<br>
  Defaults to `~/.local/share/JetBrainsProjects`.

---
