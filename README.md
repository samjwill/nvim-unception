# nvim-unception

A plugin that leverages Neovim's ***native*** `client-server` feature to
simplify opening files from within Neovim's terminal emulator without
unintentionally nesting sessions.

Terminal buffers will no longer enter a state of "inception" in which an
instance of Neovim is open within an instance of Neovim. Instead, the
desired files and directories will be opened by the "host" Neovim session,
which leverages `:argadd` to update its own arguments.

https://user-images.githubusercontent.com/25990267/170632310-8bbee2fa-672b-4385-9dea-7ed4501a0558.mp4

# Requirements

Requires Neovim 0.7 or later and a bash or somewhat bash-like shell. Basically,
the shell must be capable of running the `realpath` and `mktemp` commands, and
treat `/` as the file separator.

# Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'samjwill/nvim-unception'

#### Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

    use "samjwill/nvim-unception"

# How does it work?

The plugin tells Neovim to automatically start a local server listening to
a named pipe at launch. Upon launching a new Neovim session within a
terminal emulator buffer, the arguments are forwarded to the aforementioned
Neovim server session via the pipe, and the server session replaces the
buffer under the cursor (the terminal buffer) with the first file/directory
argument specified.

# Limitations

This plugin is experimental and probably has some unaccounted for
limitations/edge cases. It works well enough for me but YMMV. If you find an
issue, feel free to create one detailing the problem on the GitHub repo, and
I'll try to fix it if I'm able. Unception can be temporarily disabled when
launching Neovim like so: `nvim --cmd "let g:unception_disable=1"`

***If using Neovim as your default editor for git, for example, and you
would like to be able to use it from WITHIN the terminal emulator, I would
recommend updating your .gitconfig to always pass the flag to disable
unception described above (like [this](https://github.com/samjwill/dotfiles/blob/c59477c47867fb8f5560ba01d17722443428bc7e/.gitconfig#L5)).***

Other Neovim command-line arguments that do not involve editing a file or
directory may not work as expected from *within* the terminal emulator (e.g.
passing `-b` to edit in binary mode when inside of a terminal buffer or opening
a file as read-only when the server session is not set to read-only mode). Note
that any commands that might not work well within Neovim terminal buffers
should work just fine outside of terminal buffers. They should also behave as
as they do by default if you pass the disable flag detailed above, even within
the terminal emulator.

# Settings

For usage details and options (such as setting the new buffers to be opened in
new tabs instead of the current window), see `doc/nvim-unception.txt`, or,
after installation, run `:help nvim-unception`.
