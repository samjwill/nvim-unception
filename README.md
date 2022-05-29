# nvim-unception

A plugin that leverages Neovim's ***native*** `client-server` feature to make opening files
from within Neovim's terminal emulator without experiencing weird behavior easier and completely automatic.

Terminal buffers will no longer enter a state of "inception" in which an instance of
Neovim is open within an instance of Neovim. Instead, the desired files and
directories will be opened by the "host" Neovim session, which leverages
`:argadd` to update its own arguments.

https://user-images.githubusercontent.com/25990267/170632310-8bbee2fa-672b-4385-9dea-7ed4501a0558.mp4

# How does it work?

The plugin tells Neovim to automatically start a local server listening to a
named pipe at launch. Upon launching a new Neovim session within a terminal
emulator buffer, the arguments are forwarded to the aforementioned Neovim server
session via the pipe, and the server session replaces the buffer under the cursor, which
should be the terminal buffer, with the first file/directory argument
specified.

# Requirements

Requires Neovim 0.7 or higher and a bash or somewhat bash-like shell.

It is assumed that you have the ability to run the `realpath` and `pgrep`
commands in the shell that is used to launch Neovim, as well as the shell used
by the internal Neovim terminal emulator. The user launching Neovim must also
have the ability to write to `/tmp/`, and the `$USER` environment variable is assumed to be set.

# Limitations

I'm sure there are plenty. This plugin is experimental and probably has some
(several) unaccounted for edge cases. It works well enough for me but YMMV. Unception can be temporarily disabled
when launching Neovim if you run into any side-effects like so: `nvim --cmd
"let g:disable_unception=1"`.

***If using Neovim as your default editor for git, for example, and you would
like to be able to use it from within the terminal emulator, I would recommend
updating your .gitconfig to always pass the flag to disable unception described
above.***

If trying to open a NEW Neovim instance outside of the terminal emulator when
an instance using this plugin is already running, the arguments will instead be
piped to the existing Neovim server, and a new Neovim instance will not be
launched. This means you can really only use one Neovim instance at a time (per
user) unless disabling this plugin when launching the new Neovim session.

Other Neovim non-filepath command-line arguments that do not involve editing a file or directory may or may not
work as expected from within the terminal emulator; try them out and let me
know if there's an issue :). Note that any commands that might not work well
within the Neovim terminal emulator should work just fine when launching the
initial server session.

Additionally, if any of the commands passed to the Neovim server session
through the terminal buffer conflict with arguments provided to the initial
host session, they probably won't work.

When the server session receives the command, the old terminal buffer is deleted when the new file is switched to. It assumes that the terminal buffer used to send the command will be the one under the cursor at the time the server receives the command. This happens extremely quickly, so it should not be an issue unless you're the Flash, but it's worth noting.

# Troubleshooting

If something goes horribly wrong, try deleting the pipe in the `/tmp/` directory. It will be named `nvim-<username>.pipe`.

# Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'samjwill/nvim-unception'

#### Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

    use "samjwill/nvim-unception"

