---
title: TypeScript tsgo Compatibility Alias
description: Keep existing lang.typescript-tsgo configurations working with native TypeScript 7.
---

`lang.typescript-tsgo` is a compatibility alias for
[`lang.typescript`](/extras/lang/typescript/), which now uses the stable native
TypeScript 7 `tsc` language server. Existing saved extra IDs continue to work;
new configurations should use `lang.typescript`.

The alias carries `lsp.servers.tsgo` settings into `lsp.servers.tsc`, with
explicit `tsc` settings taking precedence. Update the server name in `user.lua`
when convenient. Enabling both the alias and standard extra applies the stack
once.

Run `:BlakToolsInstall`, wait for installation, and restart. Old Mason `tsgo`
packages remain installed until you remove them. The native preview package is
no longer needed for this stack.

To rename a selection saved through the extras UI:

```vim
:BlakExtras enable lang.typescript
:BlakExtras disable lang.typescript-tsgo
```

For a config-managed extra, replace the ID in `extras.enabled` in `user.lua`
instead. Restart after switching. See the [standard extra's
settings and verification steps](/extras/lang/typescript/).

For the older `ts_ls` server, disable this alias and `lang.typescript`, enable
[`lang.typescript-legacy`](/extras/lang/typescript-legacy/), then restart.
