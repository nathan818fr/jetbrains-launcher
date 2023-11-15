# JetBrains Scripts

This project contains scripts to open your projects in a JetBrains IDE, but with
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

One-liners to install the scripts in `~/.local/bin`:

- `idea` (IntelliJ IDEA, ultimate or community)
  ```shell
  curl -fL https://github.com/nathan818fr/jetbrains-scripts/raw/main/idea.sh | install -vDT /dev/stdin ~/.local/bin/idea
  ```

## Usage

Use these scripts to open your projects from the command line rather than from
the JetBrains IDEs interfaces. e.g.:
```shell
# Open ~/projects/my-project with IntelliJ IDEA:
idea ~/projects/my-project

# Open the current directory with IntelliJ IDEA:
idea .
```

If a project has been opened once, you can re-open it from the "Recent Projects"
interface.
But you should NOT open it from "File > Open...".

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
