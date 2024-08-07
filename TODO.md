- [X] Get rid of those banners in noice.nvim.
    - They just get in the way of the text there and they mess with switching windows because they are recognized as a little window or something.
- [ ] What is luarocks?
- [ ] Fix treesitter
- [ ] I want this to work well on HPG as well. This means if there are things that can only be gotten through `apt` and not from source then I should not have them.


Some problems with trying to use the same Nvim config on HPG and local:
- Obsidian is looking for my vault in HPG. I have disabled Obsidian.
- The xsel clipboard does not work on HPG. I commented out xsel as before.
- HPG doesn't have GLIBC>=2.29 which Nvim and Treesitter whine about
