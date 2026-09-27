# Contributing a template

Thanks for making a template. Once it's merged, every IdealJob Premium user can
pick it in **Build Resume**, and you're credited on it.

A template is one folder with two files. You write how the CV looks, in
[Typst](https://typst.app/docs/); IdealJob's library gives you the candidate's
data and handles the fiddly parts (empty fields, date ranges, grouping jobs
by company).

## 1. Set up (5 minutes)

1. Install Typst **0.14.2**, the version IdealJob renders with:
   - macOS: `brew install typst` (then check `typst --version`)
   - Linux/Windows: download 0.14.2 from
     <https://github.com/typst/typst/releases/tag/v0.14.2> and put `typst` on
     your PATH
   - or `cargo install --locked typst-cli@0.14.2`
2. Fork this repository on GitHub and clone your fork:
   ```bash
   git clone https://github.com/<you>/resume-templates.git
   cd resume-templates
   ```
3. Check everything renders:
   ```bash
   scripts/check.sh
   ```
   You should see a ✓ for every template and sample. (Windows: use WSL or
   Git Bash.)

## 2. Start from an existing template

Pick the one closest to what you want and copy it. The folder name is your
template's id: lowercase letters, digits and dashes.

```bash
cp -r templates/classic-blue templates/my-template
```

Edit `templates/my-template/meta.json`:

```json
{
  "id": "my-template",
  "name": "My Template",
  "author": "Your Name (@your-github)",
  "version": "1.0.0",
  "description": "One sentence shown under the name in the picker.",
  "paper": "a4",
  "photo": true,
  "tags": ["one-column"]
}
```

- `id` must match the folder name.
- `paper` is `"a4"` or `"us-letter"`.
- `photo` says whether the design shows a photo. Designs with a photo must
  still look good without one: IdealJob never sends photos with applications.

## 3. Design it

Open `templates/my-template/template.typ`. The top always looks like this:

```typ
#import "/lib/idealjob.typ": *
#let cv = load-cv()
```

After that, it's normal Typst. Everything about the candidate is in `cv`
(`cv.name`, `cv.summary`, `experience-groups(cv)`, …). The full list of
fields and helpers is in [docs/data-contract.md](docs/data-contract.md).

Preview while you work. This re-renders every time you save:

```bash
typst watch --root . templates/my-template/template.typ preview.pdf
```

Open `preview.pdf` in a viewer that reloads on change. To try another sample,
add `--input cv=/samples/tricky.json`.

### Rules

These keep templates safe to run on IdealJob's servers and good for every
candidate. The checks enforce most of them.

1. **Only the data from `load-cv()`.** No hard-coded names, links or text
   about a person. Section titles ("Experience", "Skills") are fine.
2. **Empty means invisible.** When a field is empty, its heading, icon and
   spacing disappear too. Use the helpers, they already filter.
3. **Handle every sample.** Long names and emails wrap or shrink, special
   characters print as themselves, 12 jobs break across pages cleanly.
4. **Support "what changed" marks** with `hl` and `hl-block` (see the data
   contract). The existing templates show where they go.
5. **Imports:** only `/lib/idealjob.typ`, files inside your own folder, and
   packages on the allow list below. No reading files outside your folder, no
   `sys.inputs`, no WebAssembly plugins.
6. **Fonts:** DejaVu Sans, DejaVu Serif, DejaVu Sans Mono and Font Awesome 7
   are installed. Want another font? Put the `.ttf`/`.otf` inside your folder
   (it must have an open licence, e.g. OFL) and mention it in the PR.
7. **Size:** at most 3 pages for the normal samples, under 10 seconds to
   render, whole folder under 2 MB.
8. **Text readable by applicant tracking systems:** keep real text as text,
   not images, and in reading order.

### Allowed packages

| Package | Why |
|---|---|
| `@preview/modern-cv:0.10.0` | Used by Modern No Photo. |
| `@preview/fontawesome:0.6.0` | Icons. |

Want another one from [Typst Universe](https://typst.app/universe/)? Open an
issue first, or ask in your PR. We review each package's code before adding
it, since it runs on our servers.

## 4. Check it

```bash
scripts/check.sh my-template
```

Then look at every image in `previews/my-template/`, one per sample and page.
Pay attention to `minimal`, `tricky` and `many-roles`: that's where templates
usually break.

## 5. Open a pull request

```bash
git checkout -b template/my-template
git add templates/my-template
git commit -m "Add My Template"
git push -u origin template/my-template
```

Then open a pull request on GitHub. The PR description asks for a screenshot
and a short checklist.

What happens next:

1. **Checks run automatically.** They render your template against every
   sample and check the rules. Previews of every page are attached to the run
   (open the run, then **Artifacts → previews**). A red ✗ tells you what to
   fix; push again and they re-run.
2. **We review it**, usually within a week: design quality, the rules above,
   and how it reads. We may suggest changes in the PR.
3. **Merged templates ship with the next IdealJob release.** You're credited
   as the author in the template picker.

By opening a pull request you agree your template is released under this
repository's [MIT licence](LICENSE).

## Changing an existing template

Same steps. Bump `version` in `meta.json` (`1.0.0` → `1.1.0` for visible
changes, `1.0.1` for fixes). Changing a template changes every CV that uses
it, so describe the change in the PR and include before/after screenshots.

## Changing the library or the samples

`lib/idealjob.typ` and `samples/` are shared by every template, so changes
there need a maintainer. Open an issue first. New fields must also be added in
IdealJob and in [docs/data-contract.md](docs/data-contract.md).

## Not a designer? Request one

Open an issue with the **Request a template** form, or use **Request a
template** in IdealJob's Build Resume page. Describe it or link an example.
