# nvim-unception

A plugin that leverages Neovim's ***native*** `client-server` feature to
make opening files from within Neovim's terminal emulator without
experiencing weird behavior easier and completely automatic.

Terminal buffers will no longer enter a state of "inception" in which an
instance of Neovim is open within an instance of Neovim. Instead, the
desired files and directories will be opened by the "host" Neovim session,
which leverages `:argadd` to update its own arguments.

https://user-images.githubusercontent.com/25990267/170632310-8bbee2fa-672b-4385-9dea-7ed4501a0558.mp4

# How does it work?

The plugin tells Neovim to automatically start a local server listening to
a named pipe at launch. Upon launching a new Neovim session within a
terminal emulator buffer, the arguments are forwarded to the aforementioned
Neovim server session via the pipe, and the server session replaces the
buffer under the cursor (the terminal buffer) with the first file/directory
argument specified.

# Requirements

Requires Neovim 0.7 or later and a bash or somewhat bash-like shell.

# Limitations

I'm sure there are plenty. This plugin is experimental and probably has
some unaccounted for edge cases. It works well enough for me but YMMV.
Unception can be temporarily disabled when launching Neovim if you run into
any side-effects like so: `nvim --cmd "let g:unception_disable=1"`

***If using Neovim as your default editor for git, for example, and you
would like to be able to use it from WITHIN the terminal emulator, I would
recommend updating your .gitconfig to always pass the flag to disable
unception described above.***

Other Neovim command-line arguments that do not involve editing a file or
directory may not work as expected from within the terminal emulator, (e.g.
passing `-b` to edit in binary mode or opening a file as read-only when the
server session is not set to read-only mode). Note that any commands that
might not work well within the Neovim terminal emulator should work just
fine when launching the initial server session.

# Settings

See `doc/nvim-unception.txt` for usage details, or after installation, run
`:help nvim-unception`.

# Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'samjwill/nvim-unception'

#### Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

    use "samjwill/nvim-unception"

