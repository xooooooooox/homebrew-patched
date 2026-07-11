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

## Conventions

- Every formula's `url` points at a `github.com/xooooooooox/<tool>` fork tag tarball.
- Fork tags are named `<upstream-version>-patched.<n>` (e.g. `3.5.0-patched.1`).
- Formulas declare explicit `version` (upstream version) and `revision` (the `<n>`).

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
