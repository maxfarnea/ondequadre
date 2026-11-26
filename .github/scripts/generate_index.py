#!/usr/bin/env python3
"""Prepara gli indici per Quartz (solo italiano).

Nei file del vault i blocchi ```dataview restano invariati (funzionano in
Obsidian); questo script, eseguito solo in CI prima del build Quartz:
  1. ripulisce i corpi dei post dalle righe rese già dal layout (titolo, data,
     tag) e toglie i blocchi dataview residui (Quartz non li esegue);
  2. aggiunge lo slug di categoria ai tag, per avere la pagina /tags/<category>;
  3. ricostruisce la home: contenuto di 20121208/introduzione.md, un
     separatore e un indice a card (thumbnail, titolo, data, categoria);
  4. scrive post-thumbs.json (slug -> prima immagine), usato dal componente
     TagContent patchato per le card delle pagine tag.

Uso: python3 generate_index.py <dir-content-di-quartz>
"""

import json
import posixpath
import re
import sys
from pathlib import Path

FM_RE = re.compile(r"^---\s*\r?\n(.*?)\r?\n---\s*\r?\n?", re.S)
KV_RE = re.compile(r"^(title|date|category|description|author):\s*(.*?)\s*$", re.M)

EXCLUDED_FILES = {"index.md", "brief.md", "how-to.md", "obsidian-config.md", "to-do.md"}

# sorgente dell'introduzione mostrata in home (pagina "about" vera e propria)
HOME_INDEX = "index.md"
HOME_INTRO = "20121208/introduzione.md"

# slug canonico di categoria -> etichetta mostrata nell'indice
# (unica fonte: .github/scripts/categories.txt, insieme a CategoriesAndTags.tsx)
SCRIPT_DIR = Path(__file__).resolve().parent


def load_category_labels() -> dict:
    labels = {}
    for line in (SCRIPT_DIR / "categories.txt").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        slug, label = line.split(":", 1)
        labels[slug.strip()] = label.strip()
    return labels


CATEGORY_LABELS = load_category_labels()


def parse_frontmatter(text: str) -> dict:
    match = FM_RE.match(text)
    if not match:
        return {}
    return {key: value.strip().strip('"') for key, value in KV_RE.findall(match.group(1))}


def collect_posts(content: Path) -> dict:
    """Ritorna {percorso_relativo: campi_frontmatter + 'thumb'}."""
    posts = {}
    for md in content.rglob("*.md"):
        if md.name in EXCLUDED_FILES:
            continue
        text = md.read_text(encoding="utf-8")
        fields = parse_frontmatter(text)
        if fields.get("author", "").lower() != "max farnea":
            continue
        fields["thumb"] = first_image(text, md.parent, content)
        posts[md.relative_to(content).as_posix()] = fields
    return posts


def first_image(text: str, directory: Path, root: Path) -> str:
    """URL della prima immagine del corpo, relativo alla content root."""
    body = FM_RE.sub("", text, count=1)
    m = re.search(r"!\[[^\]]*\]\(([^)\s]+)", body)
    if not m:
        m = re.search(r"<img[^>]*src=[\"']([^\"']+)", body)
    if not m:
        return ""
    url = m.group(1).strip()
    if "://" in url or url.startswith("/"):
        return url
    return posixpath.normpath(posixpath.join(directory.relative_to(root).as_posix(), url))


def esc(s: str) -> str:
    return (s.replace("&", "&amp;").replace("<", "&lt;")
             .replace(">", "&gt;").replace('"', "&quot;"))


def build_cards(posts: dict) -> str:
    """Indice della home: card con thumbnail, titolo, data e categorie."""
    items = sorted(posts.items(), key=lambda p: p[1].get("date", ""), reverse=True)
    cards = []
    for path, fields in items:
        title = fields.get("title", path)
        date = fields.get("date", "")
        cat = fields.get("category", "")
        label = CATEGORY_LABELS.get(cat, cat)
        thumb = fields.get("thumb", "")
        link = path[:-3]  # via l'estensione .md
        if thumb:
            inner = f'<img class="post-card-thumb" src="{esc(thumb)}" alt="" />'
        else:
            inner = (f'<div class="post-card-thumb post-card-nothumb">'
                     f'<span>{esc(title[:1])}</span></div>')
        cards.append(
            f'<a class="post-card" href="{esc(link)}">{inner}'
            f'<div class="post-card-meta">'
            f'<span class="post-card-title">{esc(title)}</span>'
            f'<span class="post-card-info">{esc(date)} · {esc(label)}</span>'
            f'</div></a>'
        )
    return '<div class="post-cards">\n' + "\n".join(cards) + "\n</div>\n"


def write_thumb_manifest(posts: dict) -> None:
    """Manifest slug -> thumbnail (prima immagine del corpo), nello stesso
    formato delle card della home. Viene copiato in quartz/components/ da
    patch-quartz.sh e importato da TagContent.tsx per le pagine tag a card."""
    manifest = {path[:-3]: fields.get("thumb", "") for path, fields in posts.items()}
    out = SCRIPT_DIR / "post-thumbs.json"
    out.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"  post-thumbs.json: {len(manifest)} voci")


def rewrite_rel(url: str, intro_dir: str) -> str:
    """URL relativo alla content root (per l'uso in home)."""
    if "://" in url or url.startswith(("/", "#")):
        return url
    return posixpath.normpath(posixpath.join(intro_dir, url))


def inline_intro(text: str, intro_dir: str) -> str:
    """Corpo dell'introduzione pronto per la home: niente frontmatter,
    link/immagini riscritti in root."""
    intro = FM_RE.sub("", text, count=1).replace("\r\n", "\n")
    # riscrivo solo l'URL: la ")" del markdown originale resta dov'è
    return re.sub(r"(!?)\]\(([^)\s]+)", lambda m: f"{m.group(1)}]({rewrite_rel(m.group(2), intro_dir)}", intro)


def rewrite_home(content: Path, posts: dict) -> bool:
    """Ricostruisce la home: introduzione + separatore + card dei post."""
    index_file = content / HOME_INDEX
    if not index_file.exists():
        return False
    intro = ""
    intro_file = content / HOME_INTRO
    if intro_file.exists():
        intro = inline_intro(intro_file.read_text(encoding="utf-8"), posixpath.dirname(HOME_INTRO))
    text = index_file.read_text(encoding="utf-8")
    m = FM_RE.match(text)
    fm = m.group(0) if m else ""
    if not fm.endswith("\n"):
        fm += "\n"
    body = intro + ("\n\n" if intro else "") + "---\n\n" + build_cards(posts)
    index_file.write_text(fm + "\n" + body, encoding="utf-8")
    changed = True
    print(f"  {HOME_INDEX}: rigenerata (introduzione + {len(posts)} card candidate)")
    return changed


def add_category_to_tags(content: Path, posts: dict) -> bool:
    """Aggiunge lo slug di categoria ai tag (a build time) cosi' che esista la
    pagina /tags/<category> linkata dall'elenco categorie in colonna destra."""
    changed = False
    tags_re = re.compile(r"^(tags:\s*\[)([^\]]*)(\]\s*)$", re.M)
    for path, fields in posts.items():
        cat = (fields.get("category") or "").strip()
        if not cat:
            continue
        post_file = content / path
        text = post_file.read_text(encoding="utf-8")
        fm_match = FM_RE.match(text)
        if not fm_match:
            continue
        fm = fm_match.group(1)
        if "tags:" in fm:
            items = [t.strip().strip("'\"") for t in fm.split("tags:", 1)[1].split("]")[0].split(",")]
        else:
            items = []
        if cat in items:
            continue
        m = tags_re.search(fm)
        if m:
            middle = f", {cat}" if m.group(2).strip() else f" {cat}"
            new_fm = fm[:m.start()] + m.group(1) + m.group(2) + middle + m.group(3) + fm[m.end():]
        else:
            new_fm = fm + f"\ntags: [{cat}]"
        post_file.write_text(text[:fm_match.start(1)] + new_fm + text[fm_match.end(1):], encoding="utf-8")
        changed = True
        print(f"  {path}: categoria '{cat}' aggiunta ai tag")
    return changed


def strip_body_duplicates(content: Path, posts: dict) -> None:
    """Rimuove dal corpo le righe che il layout rende già: h1 = titolo
    (ArticleTitle), '*Pubblicato:*' (ContentMeta), '**Tag:**' (TagList)."""
    pub_re = re.compile(r"^\*(Pubblicato):\s*[\d-]+\*$")
    tag_re = re.compile(r"^\*\*Tags?\*\*:")
    items = dict(posts)
    index_file = content / HOME_INDEX  # escluso da collect_posts ma con h1/dati duplicati
    if index_file.exists():
        items[HOME_INDEX] = parse_frontmatter(index_file.read_text(encoding="utf-8"))
    for path, fields in items.items():
        post_file = content / path
        lines = post_file.read_text(encoding="utf-8").splitlines(keepends=True)
        body_start = 0
        for i in range(1, len(lines)):
            if lines[i].startswith("---"):
                body_start = i + 1
                break
        title = fields.get("title", "").strip()
        kept, seen_h1 = [], False
        for ln in lines[body_start:]:
            s = ln.strip()
            if not seen_h1 and title and s == "# " + title:
                seen_h1 = True
                continue
            if pub_re.match(s) or tag_re.match(s):
                continue
            kept.append(ln)
        post_file.write_text("".join(lines[:body_start]) + "".join(kept), encoding="utf-8")


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: generate_index.py <content-dir>")
        return 1
    content = Path(sys.argv[1])
    if not content.is_dir():
        print(f"not a directory: {content}")
        return 1
    posts = collect_posts(content)
    print(f"Trovati {len(posts)} post")
    strip_body_duplicates(content, posts)
    add_category_to_tags(content, posts)
    rewrite_home(content, posts)
    write_thumb_manifest(posts)
    return 0


if __name__ == "__main__":
    sys.exit(main())
