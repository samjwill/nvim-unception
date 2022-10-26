# nvim-unception

A plugin that leverages Neovim's ***native*** `client-server` feature to
simplify opening files from within Neovim's terminal emulator without
unintentionally nesting sessions.

Terminal buffers will no longer enter a state of "inception" in which an
instance of Neovim is open within an instance of Neovim. Instead, the desired
files and directories will be opened by the "host" Neovim session, which
leverages `:argadd` to update its own arguments.

https://user-images.githubusercontent.com/25990267/170632310-8bbee2fa-672b-4385-9dea-7ed4501a0558.mp4

# Requirements

Requires Neovim 0.7 or later and a bash or somewhat bash-like shell. Basically,
the shell must be capable of running the `realpath` command, and treat `/` as
the file separator.

Note that while the `realpath` command ships with most Linux distributions, on
MacOS, it is not provided by default. It can be installed with Homebrew by
running `brew install coreutils`.

# Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'samjwill/nvim-unception'

#### Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

    use "samjwill/nvim-unception"

# How does it work?

The plugin tells Neovim to automatically start a local server listening to a
named pipe at launch. Upon launching a new Neovim session within a terminal
emulator buffer, the arguments are forwarded to the aforementioned Neovim
server session via the pipe, and the server session replaces the buffer under
the cursor (the terminal buffer) with the first file/directory argument
specified.

# Limitations

This plugin works well enough for me but your mileage may vary. If you
find an issue, feel free to create one detailing the problem on the
GitHub repo, and I'll try to fix it if I'm able. If you run into a
problem, Unception can be temporarily disabled when launching Neovim
like so:
`nvim --cmd "let g:unception_disable=1"`

***If using Neovim as your default editor for git, for example, and you
would like to be able to use it from WITHIN the terminal emulator, I would
recommend updating your .gitconfig to always pass the flag to disable
unception described above (like [this](https://github.com/samjwill/dotfiles/blob/c59477c47867fb8f5560ba01d17722443428bc7e/.gitconfig#L5)).***

Other Neovim command-line arguments that do not involve editing a file or
directory may not work as expected from *within* the terminal emulator (e.g.
passing `-b` to edit in binary mode when inside of a terminal buffer will not
propagate binary mode to the file when it's unnested, and opening a file as
read-only when the server session is not set to read-only mode will not result
in a read-only buffer). See `:help vim-arguments` for how these are typically
used. Note that any arguments that might not work when launched from within a
Neovim terminal buffer should work just fine when launching Neovim normally.
They should also behave as as they do by default if you pass the disable flag
described above, even if launched from within a terminal buffer.

# Settings

For usage details and options (such as opening the file buffers in new tabs
rather than the current window), see `doc/nvim-unception.txt`, or, after
installation, run `:help nvim-unception`.

# Can this work with [FTerm.nvim](https://github.com/numToStr/FTerm.nvim) or other terminal plugins?

Yep! See the [wiki](https://github.com/samjwill/nvim-unception/wiki) for more info.
