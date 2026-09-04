# homebrew-patched

Patched versions of upstream tools, pending upstream fixes.

Each formula here builds from a fork of the upstream project with a small,
well-scoped patch applied. When the fix lands upstream, the formula is
retired and users can return to homebrew-core.

Sibling taps: [legacy](https://github.com/xooooooooox/homebrew-legacy) (Homebrew's historical bottles, pinned old versions) - [prebuilt](https://github.com/xooooooooox/homebrew-prebuilt) (official upstream binaries).

## Usage

```bash
brew tap xooooooooox/patched
brew install xooooooooox/patched/<tool>
```

## Tools

| Tool | Patch | Upstream issue | Retire when |
|------|-------|----------------|-------------|
| [yadm](https://github.com/xooooooooox/yadm/tree/fix/zsh-completion-add) | zsh completion for `add`/`checkout`: delegate to git's completion (CWD-relative candidates, respects ignore rules, no full `$HOME` scan) | [yadm-dev/yadm#359](https://github.com/yadm-dev/yadm/issues/359), [#355](https://github.com/yadm-dev/yadm/issues/355) | fix merged upstream + released |
| [vfox](https://github.com/xooooooooox/vfox/tree/patched-v1.0.11) | (1) deterministic PATH order in `vfox env` output: collect per-SDK envs, merge sorted-by-name after `g.Wait()` — goroutine completion order shuffled same-scope entries, permanently invalidating the env-state cache (slow rebuild on every hook run / `cd`); (2) machine-global shared env cache (`~/.version-fox/env-cache/`): new sessions reuse the computed env output (content-addressed by vfox version + shell + PATH + config path/mtime) instead of a full plugin rebuild — session-scoped, legacy-enabled and degraded (SDK-error) outputs are excluded from sharing, so session semantics stay intact | (1) [version-fox/vfox#690](https://github.com/version-fox/vfox/issues/690), PR [#691](https://github.com/version-fox/vfox/pull/691); (2) [#694](https://github.com/version-fox/vfox/issues/694) (proposal; PR on maintainer interest) | both fixes merged + released (> 1.0.11) |
| [lazygit](https://github.com/xooooooooox/lazygit/tree/fix-recent-repos-git-location) | recent repos menu (`ctrl+r`) for dotfile repos opened via `--git-dir`/`--work-tree` (yadm/vcsh): the list stores the git location env vars alongside the path and restores them on switch — entries whose git dir isn't at `<path>/.git` used to be filtered out of the menu, and switching to a surviving entry failed with "not a git repository". Base: upstream master > v0.64.1, which includes the [#5910](https://github.com/jesseduffield/lazygit/pull/5910) fix that retired our previous 0.64.0 submodule-escape patch | [jesseduffield/lazygit#5942](https://github.com/jesseduffield/lazygit/issues/5942) | fix merged upstream + released (> 0.64.1) |

## Conventions

- Every formula's `url` points at a `github.com/xooooooooox/<tool>` fork tag tarball.
- Fork tags are named `<upstream-tag>-patched.<n>`, following the upstream tag
  style (e.g. `3.5.0-patched.1` for yadm, `v1.0.11-patched.1` for vfox).
- Formulas declare explicit `version` (upstream version) and `revision` (the `<n>`).
- Formulas carry a `livecheck` block pointing at the **upstream** repo (the fork
  tag never moves), so `brew livecheck --tap xooooooooox/patched` reports when
  upstream ships a newer release — the "released" half of *Retire when*. The
  "merged" half arrives via GitHub notifications (issue/PR author is
  auto-subscribed).

## Bumping a formula

Push a new tag to the tool's fork, then run the generic bump workflow:

```bash
gh workflow run bump-formula.yml -R xooooooooox/homebrew-patched \
  -f formula=<tool> -f tag=<new-tag>
```

The workflow recomputes the tarball sha256 and updates `url` / `sha256` /
`version` / `revision` in `Formula/<tool>.rb` — works for any formula in this
tap that follows the conventions above.

The bump workflow does **not** touch a formula's `bottle do` block. If the
formula carries one, re-run `bottle-<tool>.yml` for the new tag and update
`root_url` + `sha256`, or delete the block — a stale bottle block fails
installs with a 404 / checksum mismatch.

## Bottles

Formulas here normally build from source. For machines on a macOS that
Homebrew no longer ships core bottles for (e.g. an Intel Mac on Monterey,
where installing lazygit means first compiling go itself), the tap can carry
its own bottle:

- `bottle-<tool>.yml` (workflow_dispatch, input = fork tag) cross-compiles
  the tool on an ubuntu runner (pure-Go tools only, `CGO_ENABLED=0`), packs
  the keg as `<tool>-<version>.<os>.bottle.tar.gz` (single dash: brew's
  `Bottle::Filename#url_encode`, used for custom `root_url`s -- the
  double-dash form is only the local cache name), and uploads it to a
  release named `<tool>-<fork-tag>` on this repo.
- The formula's `bottle do` block points `root_url` at that release. The
  binaries embed no prefix, hence `cellar: :any_skip_relocation` — the same
  bottle serves `/usr/local` and `/opt/homebrew`.
- Current bottles: lazygit (`monterey`), vfox (`monterey` + `sequoia` — the
  same lane also serves supported Intel machines where a source build is
  undesirable, e.g. the Go module proxy is unreachable from the local
  network).

## Adding a new tool

1. Fork the upstream project, apply the patch on a branch, tag it
   `<upstream-version>-patched.1`, push branch + tag.
2. Write `Formula/<tool>.rb` by hand once (copy install logic from
   homebrew-core, point `url` at the fork tag tarball, set `version` /
   `revision` / `sha256`).
3. Add a row to the Tools table above.
4. Future updates use the bump workflow — no more manual formula edits.

## Retiring a tool

When the upstream fix is merged **and** released (`brew livecheck --tap
xooooooooox/patched` reports a newer upstream version), retire the formula —
**mark, don't delete**: the fork, tag and formula stay as history and as the
template for the next patch.

1. Reinstall from core: `brew uninstall <tool> && brew install <tool>`.
2. Mark the formula with brew's own DSL:
   `deprecate! date: "...", because: "fixed upstream in vX.Y.Z"`.
   Remove its `bottle do` block, if any (bottle releases stay up as history).
3. Move its row from *Tools* to a *Retired* table (created beside *Tools* on
   first use).
