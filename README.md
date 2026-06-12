# Isabelle Proof Templates

A small Isabelle/Isar tool that prints **clickable proof templates** into the
output panel, like the built-in proof outlines for `proof (induction ...)` —
but for *any* proof block.

After every `proof (...)` command, a template with `fix`/`assume`/`show ... sorry`
for all remaining subgoals (separated by `next`) appears automatically in the
output. Clicking it inserts the template into the proof text:

```isabelle
lemma "\<forall>x. P x \<longrightarrow> P x"
proof (intro allI impI)   (* output: fix x  /  assume "P x"  /  show "P x" sorry *)
```

The `template` command prints the same template on demand anywhere inside a
proof block, e.g. also after `apply` steps.

## Options

| Option                       | Default | Effect                                     |
|------------------------------|---------|--------------------------------------------|
| `[[template_auto = false]]`  | `true`  | disable the automatic output after `proof` |
| `[[template_show_types]]`    | `false` | annotate fixed variables with their types  |
| `[[template_cartouches]]`    | `false` | print terms in cartouches instead of quotes|

## Files

- `Template.thy` / `template.ML` — the tool, in session `Template` (Pure-only,
  works in any object logic)
- `test/` — session `Template_Test` (HOL-based): example lemmas in
  `Template_Test.thy`, each checked against the expected template by the
  `template_test` command (`Template_Testing.thy` / `template_testing.ML`)

## Limitations

- Inserted `show` lines are re-parsed, so terms whose types the syntax does not
  determine (e.g. bare numerals) may need manual type annotations.
- A subgoal parameter that shadows an outer fixed variable occurring in the same
  subgoal may be printed under a conflated name (as in `Sketch_and_Explore`).

## Build / test

```
isabelle build -D .
```

This builds both sessions: `Template` on `Pure` and `Template_Test` on `HOL`.

Works with both Isabelle2025-2 and the current development version
(repository version, June 2026).
