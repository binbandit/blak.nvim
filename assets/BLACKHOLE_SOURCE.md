# Black-hole splash source

The animated splash is sourced from [`milli.nvim`](https://github.com/Amansingh-afk/milli.nvim)
(MIT, Aman Singh). Two artefacts live here for traceability:

- `assets/blackhole.gif` — the original GIF, copied from the milli media branch:
  `https://raw.githubusercontent.com/amansingh-afk/milli.nvim/media/previews/blackhole.gif`
- `lua/blak/splash/frames/blackhole.lua` — the braille-encoded frame table that
  milli's `milli export -t lua` produces from that GIF. We copy it verbatim from
  `lua/milli/splashes/blackhole.lua` on the milli `main` branch.

Why braille: each character carries 8 sub-pixels (2x4), so the disc renders
cleanly at 50x14 cells. The earlier ASCII rendering at the same size looked
squashed because each cell only carried one pixel.

To refresh, replace the frame file with the latest copy from upstream — do not
hand-edit it. The Blak runtime (`lua/blak/splash/init.lua`) reads the standard
milli export shape (`cols`, `rows`, `delays`, `frames`, `colors`), so a drop-in
replacement is enough.
