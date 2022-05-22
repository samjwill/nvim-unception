# Purpose

A plugin that leverages Neovim's `client-server` feature to make opening files
from within Neovim's terminal emulator easier.

Terminals will no longer enter a state of "inception" in which an instance of
Neovim is open within an instance of Neovim. Instead, the desired files will be
opened by the "host" Neovim session, and leverage `:argedit` to update the host
session's arguments.

# How does it work?

The plugin tells Neovim to automatically start a server listening to a pipe on
launch. Upon launching a new Neovim session within a terminal emulator, the
arguments are forwarded to the aforementioned Neovim session, and the host
session replaces the buffer under the cursor (which should be the terminal
buffer), with the first file specified.

# Limitations

I'm sure there are plenty. This plugin is experimental. Unception can be
temporarily disabled when launching Neovim if you run into any side-effects
like so: `nvim --cmd "let g:disable_unception=1"`

For one, this plugin assumes you have the ability to execute the `realpath`
command in your shell and also that you have the ability to write to `/tmp/`.

If trying to open a NEW Neovim instance outside of the terminal emulator when
an instance using this plugin is already running, the arguments will instead be
piped to the existing Neovim server, and Neovim will not be launched. This
means you can really only use one Neovim instance at a time (per user) unless
disabling this plugin when launching the new Neovim session.

Other Vim commands that do not involve editing files/directories may or may not
work as expected from within the terminal emulator; I haven't done a ton of
testing in this regard (the commands should be fine from the "host" session
though). If using Neovim as your default editor for git, **for example, I would
reccommend updating your .gitconfig to always pass the flag to disable
unception described above.**

# Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug) (preferred):

    Plug 'samjwill/nvim-unception'

#### Manual:

* Copy the contents of the `plugin` directory to `~/.vim/plugin` and ensure
  that they load on startup.
