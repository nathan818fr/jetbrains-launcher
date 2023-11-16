# JetBrains Launcher

A command-line launcher to open your projects in a JetBrains IDE, but with
a twist: **it stores the IDE config (`.idea`) in a separate directory!**

## Why is this beneficial?

Storing `.idea` in a separate directory has several advantages:
1. **Version control friendly**: It's easier to manage your version control
   system (like Git) as you don't have to worry about excluding IDE-specific
   files. Also, your IDE will not break if a team member pushes its `.idea`
   content ([it happens][1]).
2. **Cleaner project directory**: Your project directory remain clean and IDE
   agnostic.
3. **Support multiple IDEs**: You can open your project with different JetBrains
   IDEs without having to worry about configuration conflicts (e.g. when using
   both [IntelliJ IDEA and CLion][2], or [PyCharm and CLion][3]).

## Installation

Download `jetbrains-launcher.sh`, rename it to the name of the JetBrains IDE you
want to use (e.g. `idea` or `idea.sh`), and put it in your `PATH`.

One-liners to download and install the launcher in `~/.local/bin`:

- `idea` (IntelliJ IDEA, ultimate or community)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/idea
  ```
- `pycharm` (PyCharm, professional or community)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/pycharm
  ```
- `webstorm` (WebStorm)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/webstorm
  ```
- `phpstorm` (PhpStorm)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/phpstorm
  ```
- `clion` (CLion)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/clion
  ```
- `rubymine` (RubyMine)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/rubymine
  ```
- `rustrover` (RustRover)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/rustrover
  ```
- `goland` (GoLand)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/goland
  ```
- `datagrip` (DataGrip)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/datagrip
  ```
- `dataspell` (DataSpell)
  ```shell
  curl -fsSL https://github.com/nathan818fr/jetbrains-launcher/raw/main/jetbrains-launcher.sh | install -vDT /dev/stdin ~/.local/bin/dataspell
  ```

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
- `-h`, `--help` – Show help message and exit. _Use this to see all options and
  environment variables (this readme only summarizes the most useful ones)._
- `--reset` – Reset existing project configuration (if any) before starting
  the IDE. _This removes the `.idea` directory._
- `--no-detach` – Start the IDE in foreground instead of detaching it.

Environment variables:
- `JETBRAINS_PROJECTS_DIR` – Path to the directory where projects configurations
  are stored.
  Defaults to `~/.local/share/JetBrainsProjects`.

---

[1]: https://youtrack.jetbrains.com/issue/IDEA-170102#focus=Comments-27-7538571.0-0
[2]: https://intellij-support.jetbrains.com/hc/en-us/community/posts/206607105
[3]: https://youtrack.jetbrains.com/issue/IDEA-140707
