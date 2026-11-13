# Marc Qualie's Dot Files

My dot files are shared between all my macOS machines, and also work on Linux (Ubuntu).


## Usage

This repository follows [scripts to rule them all](https://github.com/github/scripts-to-rule-them-all) convention.


### Initial setup

On macOS the base setup requires homebrew to be installed.

```shell
$ script/setup
```

On Linux, install `git` and `zsh` with the system package manager first. The
macOS-only steps (Homebrew, `~/Library` links, `defaults`) are skipped, and a
`.gitconfig.device` is written that turns off commit signing and the macOS
keychain/editor settings.


### Updating

For convenience I've included the following shell function which calls `script/update` from anywhere.

``` shell
$ update-dotfiles
```


## Zsh Config Files

Zsh picks which files to load based on whether the shell is a login shell and whether it is interactive. They always load in the order shown, top to bottom.

| File         | Login + interactive | Interactive only | Login only | Neither |
| ------------ | ------------------- | ---------------- | ---------- | ------- |
| `.zshenv`    | Yes                 | Yes              | Yes        | Yes     |
| `.zprofile`  | Yes                 | No               | Yes        | No      |
| `.zshrc`     | Yes                 | Yes              | No         | No      |

- **Login + interactive:** new terminal windows and tabs on macOS, `ssh host`
- **Interactive only:** running `zsh` inside an existing shell
- **Login only:** `zsh -lc 'command'`
- **Neither:** scripts, `zsh -c 'command'`, `ssh host command`

What belongs where:

- `.zshenv` is for anything every shell needs, including scripts: environment variables and `PATH`.
- `.zprofile` is for login shells only. macOS runs `path_helper` from `/etc/zprofile` after `.zshenv`, which moves system directories to the front of `PATH`, so this is where version managers get put back in front of them.
- `.zshrc` is for the interactive experience: prompt, completions, aliases and keybindings.


## Multiple Devices

Syncing this data between M1 + Intel is a pain due to homebrew installing to different directories.

Make sure to add custom device overrides for Git config in `.gitconfig.device`

```conf
[user]
  signingKey = 822B03FBDEEA045B
  name = Marc Qualie
  email = marc@marcqualie.com

[gpg]
  program = /usr/local/bin/gpg
```

Also it's required to link certain binaries since these configs are hard to make dynamic:

```shell
sudo mkdir -p /opt/homebrew/bin
sudo chown -R marc: /opt/homebrew
```
