# CV data contract

Every template gets the same data: one JSON document with the candidate's CV,
exactly as they filled it in IdealJob's resume builder. `load-cv()` reads it
and makes sure every field below exists, so a template can use `cv.email`
without checking first. An empty text field is `""`, an empty list is `()`.

```typ
#import "/lib/idealjob.typ": *
#let cv = load-cv()
```

**Never assume a field is filled in.** Real CVs are messy: no photo, no
summary, a job with no end date, a name with five parts, a skill list of 40
items. The helpers in `lib/idealjob.typ` already drop empty entries, so use
them (`experience-groups(cv)`, `educations(cv)`, `skills(cv)`, …) rather than
reading the raw lists.

## Top level

| Field | Type | Notes |
|---|---|---|
| `name` | text | Full name. Use `split-name(cv.name)` for first/last, `initials(cv.name)` for a monogram. |
| `headline` | text | One line under the name, e.g. "Senior Backend Engineer". |
| `email` | text | |
| `phone` | text | As typed, any format. |
| `website` | text | A URL. Can be a GitHub or LinkedIn URL. |
| `linkedin` | text | A URL (`https://www.linkedin.com/in/x`) or a bare handle. `handle(cv.linkedin, "linkedin.com/in/")` gives the handle. |
| `github` | text | A URL or a bare handle. `handle(cv.github, "github.com/")`. |
| `location` | text | Free text, e.g. "Lisbon, Portugal". |
| `photo` | text | Path to the photo, or `""`. **Often empty**: IdealJob never sends a photo with job applications. Use `photo(cv)`, which falls back to initials. |
| `summary` | text | A paragraph. |
| `experiences` | list | See below. |
| `educations` | list | |
| `projects` | list | |
| `certifications` | list | |
| `volunteerings` | list | |
| `skills` | list of text | |
| `languages` | list | Spoken languages. |

Text is plain text, never Typst markup: `*`, `#`, `$`, `[` and `_` come
through as the characters themselves. Pass it to `text()` or put it in
content as a value (`#cv.name`); don't `eval` it.

## experiences

| Field | Type | Notes |
|---|---|---|
| `organization` | text | Can be empty (freelance). |
| `position` | text | Job title. |
| `start_date`, `end_date` | text | Usually `YYYY-MM-DD`, sometimes just a year or free text. Use `date-range(item)`. |
| `current` | true/false | Still there. `date-range` prints "Present". |
| `description` | text | |
| `highlights` | list of text | Achievements. `achievements(position)` drops blank lines. |

`experience-groups(cv)` groups positions by organization (most recent first),
the way every IdealJob template shows them:
`((organization: "Acme", positions: (...)), ...)`.

## educations

`institution`, `course`, `start_date`, `end_date`, `current`, `gpa`,
`coursework`. `education-details(e)` gives "GPA 17/20. Relevant coursework: …".

## projects

`name`, `description`, `start_date`, `end_date`, `current`.

## certifications

`name`, `issuer`, `date` (free text, often just a year).

## volunteerings

`position`, `institution`, `start_date`, `end_date`, `current`.

## languages

`name`, `proficiency` (free text: "Native", "C1", "Fluent", or empty).

## What changed (tailored CVs)

When IdealJob tailors a CV for a specific job, it marks what it rewrote so the
candidate can check it before sending. On normal downloads these are all
false. Support them so tailored CVs are reviewable in your template:

| Flag | What to mark |
|---|---|
| `changed(cv, "summary")` | The summary. |
| `changed(cv, "headline")` | The headline. |
| `changed(cv, "skills")` | The skills block. |
| `position.at("highlight", default: false)` | That position's description. |
| `position.at("highlights_highlight", default: false)` | That position's achievements. |

Wrap text with `hl(flag, body)` and blocks with `hl-block(flag, body)`. They
do nothing when the flag is off. `samples/tailored.json` has them all on.

## Samples

`samples/` holds the CVs every template is checked against:

| Sample | Tests |
|---|---|
| `full.json` | Every field filled, with a photo. |
| `no-photo.json` | Same without a photo (how applications are sent). |
| `minimal.json` | Only a name and an email. Nothing else may show up: no empty headings, no stray icons. |
| `tailored.json` | Every "what changed" flag on. |
| `tricky.json` | A very long name and email, Typst special characters, accents, emoji, CJK, blank entries and a GitHub field holding a GitLab URL. |
| `many-roles.json` | 12 jobs: page breaks must look right. |
