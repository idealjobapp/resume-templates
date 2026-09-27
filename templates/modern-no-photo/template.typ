// Modern No Photo: single column, built on the modern-cv package. IdealJob's
// default template, and the one used for applications sent to employers.
#import "/lib/idealjob.typ": *
#import "@preview/modern-cv:0.10.0": *

#let cv = load-cv()

// modern-cv draws an icon for every key it gets, so only filled ones go in.
#let author = {
  let (firstname, lastname) = split-name(first-present(cv.name, "IdealJob"))
  let a = (firstname: firstname, lastname: lastname)
  if cv.email != "" { a.insert("email", cv.email) }
  if cv.phone != "" { a.insert("phone", cv.phone) }
  if cv.location != "" { a.insert("address", cv.location) }
  let site = cv.website
  if site.contains("github.com/") { a.insert("github", handle(site, "github.com/")) }
  else if site.contains("linkedin.com/in/") { a.insert("linkedin", handle(site, "linkedin.com/in/")) }
  else if site != "" { a.insert("homepage", site) }
  let linkedin = handle(cv.linkedin, "linkedin.com/in/")
  if linkedin != "" and "linkedin" not in a { a.insert("linkedin", linkedin) }
  let github = handle(cv.github, "github.com/")
  if github != "" and "github" not in a { a.insert("github", github) }
  a.insert("positions", if cv.headline != "" { (cv.headline,) } else { () })
  a
}

#show: resume.with(
  author: author,
  profile-picture: none,
  date: datetime.today().display(),
  language: "en",
  colored-headers: true,
  show-footer: false,
  paper-size: "us-letter",
  font: "DejaVu Sans",
  header-font: "DejaVu Sans",
)

#if cv.summary != "" [
  = Summary
  #resume-item[#hl(changed(cv, "summary"), cv.summary)]
]

#let groups = experience-groups(cv)
#if groups.len() > 0 [
  = Experience
  #for group in groups [
    == #group.organization
    #for position in group.positions [
      #block(above: 0.35em, below: 0.9em, sticky: true)[
        #__justify_align[
          #text(size: 10.2pt, weight: "regular", fill: rgb("#444444"), clean(position.position))
        ][
          #text(size: 10pt, weight: "light", fill: rgb("#666666"), date-range(position))
        ]
        #if present(position.at("description", default: none)) [
          #text(size: 9.5pt, fill: rgb("#4b5563"),
            hl(position.at("highlight", default: false) == true, clean(position.description)))
        ]
        #let lines = achievements(position)
        #if lines.len() > 0 {
          hl-block(position.at("highlights_highlight", default: false) == true,
            text(size: 9.5pt, fill: rgb("#4b5563"), list(..lines)))
        }
      ]
    ]
  ]
]

#let eds = educations(cv)
#if eds.len() > 0 [
  = Education
  #for e in eds {
    resume-entry(
      title: (clean(e.at("course", default: none)), clean(e.at("institution", default: none))).filter(present).join(", "),
      location: "",
      date: date-range(e),
      description: education-details(e),
    )
  }
]

#let projs = projects(cv)
#if projs.len() > 0 [
  = Projects
  #for p in projs {
    resume-entry(title: clean(p.name), location: "", date: date-range(p), description: clean(p.at("description", default: none)))
  }
]

#let certs = certifications(cv)
#if certs.len() > 0 [
  = Certifications
  #for c in certs {
    resume-entry(title: clean(c.name), location: clean(c.at("issuer", default: none)), date: clean(c.at("date", default: none)), description: "")
  }
]

#let vols = volunteerings(cv)
#if vols.len() > 0 [
  = Volunteering
  #for vol in vols {
    resume-entry(title: clean(vol.at("position", default: none)), location: clean(vol.at("institution", default: none)), date: date-range(vol), description: "")
  }
]

#let sk = skills(cv)
#let langs = languages(cv).map(l => clean(l.name))
#if sk.len() > 0 or langs.len() > 0 [
  = Skills
  #hl-block(changed(cv, "skills"), {
    if sk.len() > 0 { resume-skill-item("Skills", sk) }
    if langs.len() > 0 { resume-skill-item("Spoken Languages", langs) }
  })
]
