# bashmod\_lib

Reusable Bash functions and modules for script developers of all genders.
This library allows you to develop, share, and reuse modular Bash components in your own scripts.

## Usage

You can source individual modules in your own script:

```bash
# Example: Sourcing the string and log modules
source /path/to/bashmod_lib/modules/string.sh
source /path/to/bashmod_lib/modules/log.sh

log_info "Starting script..."
result=$(string_trim "   Text with spaces   ")
echo "$result"
```

Alternatively, you can load a module directly from GitHub without cloning:

```bash
source <(curl -s https://raw.githubusercontent.com/youruser/bashmod_lib/refs/heads/master/modules/log.sh)
```

## Installation

Clone the repository (e.g. as a submodule or via `curl`/`wget`):

```bash
git clone https://github.com/youruser/bashmod_lib.git
```

Or add it to an existing project:

```bash
git submodule add https://github.com/youruser/bashmod_lib.git libs/bashmod_lib
```

## Compatibility

* Bash ≥ 4.0
* POSIX-like shells (partially supported)

## Contributions

Pull requests, issues, and discussions are welcome.
Please stick to simple, POSIX-compatible Bash syntax and structure new modules like the existing ones.
