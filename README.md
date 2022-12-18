# nvim-unception

A plugin that leverages Neovim's built-in `RPC` functionality to simplify
opening files from within Neovim's terminal emulator without unintentionally
nesting sessions.

Terminal buffers will no longer enter a state of "inception" in which an
instance of Neovim is open within an instance of Neovim. Instead, the desired
files and directories will be opened by the "host" Neovim session, which
leverages `:argadd` to update its own arguments.

https://user-images.githubusercontent.com/25990267/170632310-8bbee2fa-672b-4385-9dea-7ed4501a0558.mp4

## Working with Git

There are a few options for using Neovim as your editor for git from within
Neovim itself.

The first option is to make git defer editing to the host session, and block
until the host quits the buffer being edited. This can be done by setting your
git `core.editor` to pass the `g:unception_block_while_host_edits=1` argument
(like
[this](https://github.com/samjwill/dotfiles/blob/ba56af2ff49cd23ac19fcffe7840a78c58a89c9b/.gitconfig#L5)).
Note that the terminal will be blocked until the built-in `QuitPre` event is triggered for the commit buffer.

Here's an example workflow with this flag set:

https://user-images.githubusercontent.com/25990267/208282262-594b5693-8166-414b-9695-63fc02d3c25f.mp4

Alternatively, if you would like to be able to edit using Neovim directly
inside of a nested session, you can disable unception altogether by setting
your git `core.editor` to pass the `g:unception_disable=1` argument (like
[this](https://github.com/samjwill/dotfiles/blob/c59477c47867fb8f5560ba01d17722443428bc7e/.gitconfig#L5)).

Lastly, setting your `core.editor` to another file editor, such as GNU nano would also work.

## Can this work with terminal-toggling plugins?

Yep! See the [wiki](https://github.com/samjwill/nvim-unception/wiki) for setup info.

## Requirements

Neovim 0.7 or later.

## Installation

#### Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'samjwill/nvim-unception'

#### Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

    use "samjwill/nvim-unception"

## How does it work?

The plugin tells Neovim to automatically start a local server listening to a
named pipe at launch. Upon launching a new Neovim session within a terminal
emulator buffer, the arguments are forwarded to the aforementioned Neovim
server session via the pipe, and the server session replaces the buffer under
the cursor (the terminal buffer) with the first file/directory argument
specified.

## Limitations

This plugin works well enough for me but your mileage may vary. If you
find an issue, feel free to create one detailing the problem on the
GitHub repo, and I'll try to fix it if I'm able. If you run into a
problem, Unception can be temporarily disabled when launching Neovim
like so:
`nvim --cmd "let g:unception_disable=1"`

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

## Settings

For usage details and options (such as opening the file buffers in new tabs
rather than the current window), see [doc/nvim-unception.txt](https://github.com/samjwill/nvim-unception/blob/main/doc/nvim-unception.txt), or, after
installation, run `:help nvim-unception`.
