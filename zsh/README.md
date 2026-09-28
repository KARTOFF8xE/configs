# zsh

A zsh setup for **Ubuntu** (and friends that pretend to be Ubuntu).

```bash
git clone https://github.com/KARTOFF8xE/configs
sudo ./configs/zsh/zsh_startscript.sh
```

That's the whole thing. It installs zsh, eza, fzf, vivid and bat, drops this
repo's `.zshrc` into your home, clones the plugins into `~/.zsh_scripts` and
makes zsh your login shell. Your old `.zshrc` gets renamed to
`.zshrc.bak.<timestamp>` -- not deleted, relax.

You end up with vi mode, autosuggestions, syntax highlighting, `z`, a colourful
git prompt and enough aliases that `gst` is a valid thing to type.

Run it again whenever you pull this repo, or whenever you want to give a friend
your shell. Existing plugins are left alone; `git -C ~/.zsh_scripts/<plugin> pull`
updates them.

Needs Ubuntu 24.04 or newer (eza and vivid live in `universe`). sudo is required
because the script installs packages and touches other people's home directories.
