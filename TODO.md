- [X] Get rid of those banners in noice.nvim.
    - They just get in the way of the text there and they mess with switching windows because they are recognized as a little window or something.
- [ ] What is luarocks?
- [ ] Fix treesitter
- [ ] I want this to work well on HPG as well. This means if there are things that can only be gotten through `apt` and not from source then I should not have them.
- [ ] Obsidian integration
- [ ] Have the HPG version as a separate branch? Idk, plugins like Obsidian crash unless they can point to a vault.
- [ ] Fix the which-key format or something so it stops being so annoying

Some problems with trying to use the same Nvim config on HPG and local:
- Obsidian is looking for my vault in HPG. I have therefore disabled Obsidian.
- The xsel clipboard does not work on HPG. I commented out xsel as before.
- HPG doesn't have GLIBC>=2.29 which Nvim and Treesitter whines about it
