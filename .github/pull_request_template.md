## Summary

<!-- What changed, and what user problem does it solve? -->

## Linked Issue

<!-- Link the issue for non-trivial changes, especially defaults, providers, commands, keymaps, install behavior, or update behavior. -->

## Track

<!-- Check the closest track. -->

- [ ] Bug fix
- [ ] Core change
- [ ] Extra
- [ ] Provider
- [ ] Docs only
- [ ] Install, update, or release workflow

## Blak contract

<!-- Keep the core small, native-first, and predictable. Check what applies. -->

- [ ] I read `CONTRIBUTING.md` and the relevant design rules.
- [ ] This prefers native Neovim APIs where they are enough.
- [ ] This keeps defaults boring, memorable, and documented.
- [ ] This does not silently change a default picker, completion engine, explorer, LSP strategy, leader key, or core workflow.
- [ ] No new keymaps were added, or every new keymap has a description and appears in `:BlakKeys`.
- [ ] No extras were added or changed, or every affected extra is reversible through `:BlakExtras` and restart.
- [ ] User-facing behavior is documented in the README, help docs, or docs site as appropriate.

## Validation

<!-- Check what you ran. If something was skipped, explain why. -->

- [ ] `make validate`
- [ ] `make smoke`
- [ ] `stylua --check .` or `stylua .`
- [ ] `make docs-build`, if docs changed
- [ ] Manual test with `./dev-install.sh` and `blak-dev`

## Screenshots or output

<!-- For UI, splash, docs, command output, health output, or failing/repaired behavior. -->

## Notes for reviewers

<!-- Compatibility concerns, migration notes, follow-up work, or areas that need extra attention. -->
