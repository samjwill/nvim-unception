# Purpose

Leverages Neovim's `client-server` feature to make opening files from within
Neovim's terminal emulator easier. Terminals will no longer go into a
state of "inception" in which an instance of Neovim is open within an instance
of Neovim. Instead, the desired files will be opened by the
"host" Neovim session, using `:argedit` to update the host session's arguments.

# Limitations

I'm sure there are plenty. This is in an entirely experimental state currently.

# Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug) (preferred):

    Plug 'SamuelWilliams256/nvim-outception'

#### Manual:

* Copy the contents of the `plugin` directory to `~/.vim/plugin` and ensure that they load on startup.
