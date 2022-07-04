# Marc Qualie's Dot Files

My dot files are shared between all my OSX machines.


## Usage

This repository follows [scripts to rule them all](https://github.com/github/scripts-to-rule-them-all) convention.

For convenience I've included the following shell function which calls `script/update` from anywhere.

``` shell
$ update-dotfiles
```


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


## TODO

- Rewrite scripts to work with Bash (fresh machines don't have zsh yet)
- Auto configure nginx via ~/src/**/**/.nginx-dev.conf
