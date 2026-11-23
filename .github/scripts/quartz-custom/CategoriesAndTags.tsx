import { FullSlug, resolveRelative } from "../util/path"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"

// Etichette localizzate degli slug di categoria (stessa mappa di generate_index.py)
const CATEGORY_LABELS: Record<string, string> = {
  about: "Chi sono",
  analysis: "Analisi tecnica",
  guide: "Guida",
  installation: "Installazione",
  performance: "Performance",
  project: "Progetto",
  release: "Release",
}

const CategoriesAndTags: QuartzComponent = ({
  allFiles,
  fileData,
  displayClass,
}: QuartzComponentProps) => {
  const catCounts = new Map<string, number>()
  const tagCounts = new Map<string, number>()
  for (const f of allFiles) {
    const fm = f.frontmatter
    if (!fm) continue
    const cat = fm.category as string | undefined
    if (cat) catCounts.set(cat, (catCounts.get(cat) ?? 0) + 1)
    const tags = (fm.tags ?? []) as string[]
    for (const t of tags) {
      if (cat && t === cat) continue
      tagCounts.set(t, (tagCounts.get(t) ?? 0) + 1)
    }
  }

  const label = (c: string) => CATEGORY_LABELS[c] ?? c
  const link = (slug: string) => resolveRelative(fileData.slug!, `tags/${slug}` as FullSlug)
  const cats = [...catCounts].sort((a, b) => a[0].localeCompare(b[0]))
  const tags = [...tagCounts].sort((a, b) => a[0].localeCompare(b[0]))

  if (cats.length === 0 && tags.length === 0) return null

  return (
    <div class={classNames(displayClass, "categories-and-tags")}>
      <h3>Categorie</h3>
      <ul class="cats">
        {cats.map(([c, n]) => (
          <li>
            <a href={link(c)} class="internal tag-link">
              {label(c)} <span class="cat-count">{n}</span>
            </a>
          </li>
        ))}
      </ul>
      <hr />
      <h3>Tag</h3>
      <ul class="cats tags-cloud">
        {tags.map(([t, n]) => (
          <li>
            <a href={link(t)} class="internal tag-link">
              {t} <span class="cat-count">{n}</span>
            </a>
          </li>
        ))}
      </ul>
    </div>
  )
}

CategoriesAndTags.css = `
.categories-and-tags {
  margin: 2rem 1rem;
}
.categories-and-tags h3 {
  font-size: 1rem;
  margin: 0.5rem 0;
  opacity: 0.8;
}
.categories-and-tags hr {
  margin: 1rem 0;
  border: none;
  border-top: 1px solid var(--lightgray);
}
.categories-and-tags ul {
  list-style: none;
  padding: 0;
  margin: 0.5rem 0;
}
.categories-and-tags ul.cats > li {
  margin: 0.15rem 0;
}
.categories-and-tags ul.tags-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}
.categories-and-tags ul.tags-cloud > li {
  margin: 0;
}
.categories-and-tags a.internal.tag-link {
  text-decoration: none;
}
.categories-and-tags a.internal.tag-link::before {
  content: "#";
  color: var(--secondary);
}
.categories-and-tags .cat-count {
  opacity: 0.6;
  font-size: 0.8rem;
}
.categories-and-tags ul.tags-cloud a.internal.tag-link::before {
  content: none;
}
`

export default (() => CategoriesAndTags) satisfies QuartzComponentConstructor
