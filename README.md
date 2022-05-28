# nvim-unception

A plugin that leverages Neovim's ***native*** `client-server` feature to make opening files
from within Neovim's terminal emulator without experiencing weird behavior easier and completely automatic.

Terminals will no longer enter a state of "inception" in which an instance of
Neovim is open within an instance of Neovim. Instead, the desired files and directories will be
opened by the "host" Neovim session, and which leverages `:argedit` to update its own arguments.

https://user-images.githubusercontent.com/25990267/170632310-8bbee2fa-672b-4385-9dea-7ed4501a0558.mp4

# How does it work?

The plugin tells Neovim to automatically start a local server listening to a named pipe on
launch. Upon launching a new Neovim session within a terminal emulator, the
arguments are forwarded to the aforementioned Neovim server session, and the server
session replaces the buffer under the cursor, which should be the terminal
buffer, with the first file/directory argument specified.

# Requirements

Requires Neovim 0.7 or higher.

It is assumed that you have the ability to run the `realpath` and `pidof`
commands in the shell that is used to launch Neovim, as well as the shell used
by the internal Neovim terminal emulator. The user launching Neovim must also
have the ability to write to `/tmp/`.

# Limitations

I'm sure there are plenty. This plugin is experimental and probably has some (several) unaccounted for edge cases. Unception can be
temporarily disabled when launching Neovim if you run into any side-effects
like so: `nvim --cmd "let g:disable_unception=1"`

If trying to open a NEW Neovim instance outside of the terminal emulator when
an instance using this plugin is already running, the arguments will instead be
piped to the existing Neovim server, and a new Neovim instance will not be
launched. This means you can really only use one Neovim instance at a time (per
user) unless disabling this plugin when launching the new Neovim session.

Other Neovim non-filepath commands that do not involve editing may or may not
work as expected from within the terminal emulator; try them out and let me
know if there's an issue :). Note that any commands that might not work well
within the Neovim terminal emulator should work just fine when launching the
"host" session.

***If using Neovim as your default editor for git, for example, and you would
like to be able to use it from within the terminal emulator, I would reccommend
updating your .gitconfig to always pass the flag to disable unception described
above.***

Additionally, if any of the commands passed to the Neovim "host" session
through the terminal buffer conflict with arguments provided to the initial
host session, they probably won't work.

# Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'samjwill/nvim-unception'

#### Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

    use "samjwill/nvim-unception"

