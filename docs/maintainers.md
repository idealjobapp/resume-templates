# Maintainers

## Reviewing a template pull request

1. **Checks are green.** Every template × sample rendered, rules passed.
2. **Download the previews** (the checks run → Artifacts → `previews`) and look
   at every page, especially `minimal`, `tricky`, `tailored` and `many-roles`.
3. **Read the `.typ` files.** Typst can't reach the network or files outside
   the repository, but look for:
   - hard-coded personal data or links (tracking pixels, a URL in a footer);
   - loops that could run away on large input;
   - fonts or images without an open licence;
   - anything the checks missed from the rules in CONTRIBUTING.md.
4. **Design quality.** Would we be happy to see it on a candidate's CV? Is it
   readable by applicant tracking systems (real text, sensible reading order)?
5. **Merge** with a squash commit named "Add <Template name>".

A new package goes on the allow list (`ALLOWED_PACKAGES` in `scripts/check.sh`
and the table in CONTRIBUTING.md) only after reading its source, pinned to an
exact version.

## Releasing to IdealJob

IdealJob doesn't read this repository live. It uses a tagged release, so what
users get has always been reviewed.

1. After merging, tag a release: `git tag v2026.10.1 && git push --tags`
   (year.month.n).
2. In IssuePay, bump the templates version and deploy.

Rendering in IssuePay runs Typst with the release as `--root`, the CV JSON
written to a temporary file inside it, a timeout, and no photo on applications
to employers.

## Keeping Typst in step

CI pins Typst to the version in IssuePay's `Dockerfile` (`TYPST_VERSION`). When
IssuePay upgrades Typst, update `TYPST_VERSION` in `.github/workflows/check.yml`
and the version in CONTRIBUTING.md in the same change, and look over the
previews for differences.

## Changing the library or the data contract

`lib/idealjob.typ` is shared by every template: after any change, run
`scripts/check.sh` and look at every template's previews. Only add fields;
renaming or removing one breaks community templates. A new field needs:

1. IssuePay sending it in the CV JSON;
2. `load-cv()` giving it a default;
3. a row in `docs/data-contract.md` and a value in `samples/full.json`.
