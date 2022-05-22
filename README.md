# Purpose

A plugin that leverages Neovim's `client-server` feature to make opening files from within
Neovim's terminal emulator easier.

Terminals will no longer go into a
state of "inception" in which an instance of Neovim is open within an instance
of Neovim. Instead, the desired files will be opened by the
"host" Neovim session, using `:argedit` to update the host session's arguments.

# Limitations

I'm sure there are plenty. For one, this plugin assumes you have the ability to execute the `realpath` command in your shell and also have the ability to write to `/tmp/`.

Other Vim commands that do not involve editing files/directories may or may not work as expected from within the terminal emulator; I haven't done a lot of testing in this regard (the commands should be fine from the "host" session).

This is in an entirely experimental state currently.

# Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug) (preferred):

    Plug 'samjwill/nvim-unception'

#### Manual:

* Copy the contents of the `plugin` directory to `~/.vim/plugin` and ensure that they load on startup.
