dotfiles-installer
==================

Tiny bash script used to install dotfiles.

For every dotfile you'd like to install, you need to have a file in your home
directory called ".&lt;app&gt;install" (e.g. .tmuxinstall, .viminstall)
that defines the following:

  - GIT_REPO - path to the git repo holding your configuration files
  - GIT_EXEC - path to your git executable (default: /opt/local/bin/git)

If defined, there are three function callbacks that will be called during the
execution of the installer.  These three function calls include:

  - pre_install
  - install
  - post_install

They allow you to customize the installation in the case you want to do
something amazing.

## Running the installer

### Clone the repo

`./dotfiles-installer <app>`

For example, assuming you have a .viminstall in your home directory (see below),

`./dotfiles-installer vim`

### Curl the repo

`bash <(curl -s https://raw2.github.com/ryankanno/dotfiles-installer/master/dotfiles-installer.sh) <app>`

For example, assuming you have a .viminstall in your home directory (see below),

`bash <(curl -s https://raw2.github.com/ryankanno/dotfiles-installer/master/dotfiles-installer.sh) vim`

## Examples

Please check out the example install file as well.

Here are sample .<app>install files:

### vim

    #!/usr/bin/env bash

    GIT_REPO=git://github.com/ryankanno/vim-config.git
    GIT_EXEC=/opt/local/bin/git

    function install() {
        update_symlink ".vim"
        update_symlink ".vimrc"
    }

### tmux

    #!/usr/bin/env bash

    GIT_REPO=git://github.com/ryankanno/dotfiles.git
    GIT_EXEC=/opt/local/bin/git

    function install() {
        update_symlink ".tmux.conf"
    }

## How does it work?

  - Checks for .&lt;app&gt;install file in your home directory or in ~/.dotfiles-installer/conf
  - Either clone or update the github repo in ~/.dotfiles-installer/repo/&lt;repo_name&gt;
  - Run callback functions defined in the .&lt;app&gt;install file

## TODO

  - document functions like update_symlink

