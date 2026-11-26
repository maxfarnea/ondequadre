import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "../../types"
import {
  FullSlug,
  getAllSegmentPrefixes,
  joinSegments,
  pathToRoot,
  resolveRelative,
  simplifySlug,
} from "../../util/path"
import { CATEGORY_LABELS } from "../CategoriesAndTags"
import postThumbs from "../post-thumbs.json"

// Pagina tag reimplementata con lo stesso grigliato di card della home
// (markup .post-cards generato da generate_index.py), cosi' filtrare per
// categoria o tag appare come un filtro dell'indice. Il manifest
// post-thumbs.json (slug -> prima immagine del corpo) e' generato da
// generate_index.py e copiato qui da patch-quartz.sh.

const TagContent: QuartzComponent = ({ fileData, allFiles }) => {
  const slug = fileData.slug!
  if (!(slug.startsWith("tags/") || slug === "tags")) {
    throw new Error(`Component "TagContent" tried to render a non-tag page: ${slug}`)
  }
  const root = pathToRoot(slug)
  const thumbs = postThumbs as Record<string, string>
  const tag = simplifySlug(slug.slice("tags/".length) as FullSlug)
  const fmtDate = (d: unknown) => {
    const t = d ? new Date(d as string | number).getTime() : NaN
    return Number.isNaN(t) ? "" : new Date(t).toISOString().slice(0, 10)
  }

  // indice di tutti i tag, con conteggio (slug "tags" e "tags/index" -> "/")
  if (tag === "/") {
    const counts = new Map<string, number>()
    for (const f of allFiles) {
      for (const t of (f.frontmatter?.tags ?? []) as string[]) {
        counts.set(t, (counts.get(t) ?? 0) + 1)
      }
    }
    const tags = [...counts].sort((a, b) => a[0].localeCompare(b[0]))
    return (
      <article class="popover-hint">
        <ul class="tags-index">
          {tags.map(([t, n]) => (
            <li key={t}>
              <a
                href={resolveRelative(slug, joinSegments("tags", t) as FullSlug)}
                class="internal tag-link"
              >
                {CATEGORY_LABELS[t] ?? t}
              </a>{" "}
              <span class="cat-count">{n}</span>
            </li>
          ))}
        </ul>
      </article>
    )
  }

  const pages = allFiles
    .filter((f) =>
      ((f.frontmatter?.tags ?? []) as string[]).flatMap(getAllSegmentPrefixes).includes(tag),
    )
    .sort((a, b) => {
      const da = new Date((a.frontmatter?.date ?? 0) as string | number).getTime() || 0
      const db = new Date((b.frontmatter?.date ?? 0) as string | number).getTime() || 0
      return db - da
    })

  return (
    <article class="popover-hint">
      <p class="tag-filter-note">{pages.length} post</p>
      <div class="post-cards">
        {pages.map((f) => {
          const title = (f.frontmatter?.title as string) ?? f.slug ?? ""
          const cat = (f.frontmatter?.category as string) ?? ""
          const label = CATEGORY_LABELS[cat] ?? cat
          const date = fmtDate(f.frontmatter?.date)
          const info = [date, label].filter(Boolean).join(" · ")
          const thumb = thumbs[f.slug!] ?? ""
          // le thumb possono essere URL esterni o path assoluti: solo i path
          // relativi alla content root vanno riprefissati con pathToRoot
          const thumbSrc =
            thumb.includes("://") || thumb.startsWith("/") ? thumb : joinSegments(root, thumb)
          return (
            <a class="post-card" href={resolveRelative(slug, f.slug! as FullSlug)} key={f.slug}>
              {thumb ? (
                <img class="post-card-thumb" src={thumbSrc} alt="" />
              ) : (
                <div class="post-card-thumb post-card-nothumb">
                  <span>{title.slice(0, 1)}</span>
                </div>
              )}
              <div class="post-card-meta">
                <span class="post-card-title">{title}</span>
                <span class="post-card-info">{info}</span>
              </div>
            </a>
          )
        })}
      </div>
    </article>
  )
}

export default (() => TagContent) satisfies QuartzComponentConstructor
