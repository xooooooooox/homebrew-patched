# homebrew-patched

Patched versions of upstream tools, pending upstream fixes.

Each formula here builds from a fork of the upstream project with a small,
well-scoped patch applied. When the fix lands upstream, the formula is
retired and users can return to homebrew-core.

## Usage

```bash
brew tap xooooooooox/patched
brew install xooooooooox/patched/<tool>
```

## Tools

| Tool | Patch | Upstream issue | Retire when |
|------|-------|----------------|-------------|
| [yadm](https://github.com/xooooooooox/yadm/tree/fix/zsh-completion-add) | zsh completion for `add`/`checkout`: delegate to git's completion (CWD-relative candidates, respects ignore rules, no full `$HOME` scan) | [yadm-dev/yadm#359](https://github.com/yadm-dev/yadm/issues/359), [#355](https://github.com/yadm-dev/yadm/issues/355) | fix merged upstream + released |
| [vfox](https://github.com/xooooooooox/vfox/tree/patched-v1.0.11) | deterministic PATH order in `vfox env` output: collect per-SDK envs, merge sorted-by-name after `g.Wait()` — goroutine completion order shuffled same-scope entries, permanently invalidating the env-state cache (slow rebuild on every hook run / `cd`) | [version-fox/vfox#690](https://github.com/version-fox/vfox/issues/690), PR [#691](https://github.com/version-fox/vfox/pull/691) | PR merged + released (> 1.0.11) |

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
3. Move its row from *Tools* to a *Retired* table (created beside *Tools* on
   first use).
