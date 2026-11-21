#!/usr/bin/env python3
"""Prepara gli indici bilingui per Quartz.

Nei file del vault i blocchi ```dataview restano invariati (funzionano in
Obsidian); questo script, eseguito solo in CI prima del build Quartz:
  1. ripulisce i corpi dei post dalle righe rese già dal layout (titolo, data,
     tag) e toglie i blocchi dataview residui (Quartz non li esegue);
  2. aggiunge, dopo il titolo di ogni post, un link alla versione nell'altra
     lingua (a build time, senza toccare i file del vault);
  3. aggiunge lo slug di categoria ai tag, per avere la pagina /tags/<category>;
  4. ricostruisce la home: contenuto di introduzione.md(Introduzione), un
     separatore e un indice a card (thumbnail, titolo, data, categoria).

Uso: python3 generate_index.py <dir-content-di-quartz>
"""

import posixpath
import re
import sys
from pathlib import Path

FM_RE = re.compile(r"^---\s*\r?\n(.*?)\r?\n---\s*\r?\n?", re.S)
KV_RE = re.compile(r"^(title|date|category|description|author|translations):\s*(.*?)\s*$", re.M)

EXCLUDED_FILES = {"index.md", "index.en.md", "brief.md", "how-to.md", "obsidian-config.md", "to-do.md",
                  "introduzione.md", "introduzione.en.md"}

LINK_SENTENCE = {
    "it": "*Disponibile anche in {link}*",
    "en": "*Also available in {link}*",
}
LINK_TEXT = {"it": "English version", "en": "versione italiana"}

# slug canonico (uguale in entrambe le lingue) -> etichetta mostrata nella
# tabella dell'indice, per lingua
CATEGORY_LABELS = {
    "about": {"it": "Chi sono", "en": "About"},
    "analysis": {"it": "Analisi tecnica", "en": "Technical analysis"},
    "guide": {"it": "Guida", "en": "Guide"},
    "installation": {"it": "Installazione", "en": "Installation"},
    "performance": {"it": "Performance", "en": "Performance"},
    "project": {"it": "Progetto", "en": "Project"},
    "release": {"it": "Release", "en": "Release"},
}


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


def counterpart(rel_path: str, fields: dict) -> str:
    """Percorso (relativo alla content root, con nome file) della traduzione."""
    if "/" in rel_path:
        directory, name = rel_path.rsplit("/", 1)
    else:
        directory, name = "", rel_path
    stem = name.rsplit(".", 1)[0]
    base = stem[:-3] if stem.endswith(".en") else stem
    target = fields.get("translations", "").strip()
    if not target:
        return ""
    filename = target if target.endswith(".md") else target + ".md"
    return directory + "/" + filename if directory else filename


def esc(s: str) -> str:
    return (s.replace("&", "&amp;").replace("<", "&lt;")
             .replace(">", "&gt;").replace('"', "&quot;"))


def build_cards(posts: dict, want_en: bool) -> str:
    """Indice della home: card con thumbnail, titolo, data e categorie."""
    items = sorted(
        (path, fields) for path, fields in posts.items()
        if (path.rsplit("/", 1)[-1].rsplit(".", 1)[0].endswith(".en") == want_en)
    )
    items.sort(key=lambda p: p[1].get("date", ""), reverse=True)
    cards = []
    for path, fields in items:
        title = fields.get("title", path)
        date = fields.get("date", "")
        cat = fields.get("category", "")
        label = CATEGORY_LABELS.get(cat, {}).get("en" if want_en else "it", cat)
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


def rewrite_home(content: Path, posts: dict) -> bool:
    """Ricostruisce la home: introduzione + separatore + card dei post."""
    changed = False
    for index_name, intro_name, want_en in (
        ("index.md", "introduzione.md", False),
        ("index.en.md", "introduzione.en.md", True),
    ):
        index_file = content / index_name
        if not index_file.exists():
            continue
        intro = ""
        intro_file = content / intro_name
        if intro_file.exists():
            intro = FM_RE.sub("", intro_file.read_text(encoding="utf-8"), count=1).strip()
        text = index_file.read_text(encoding="utf-8")
        m = FM_RE.match(text)
        fm = m.group(0) if m else ""
        if not fm.endswith("\n"):
            fm += "\n"
        body = intro + ("\n\n" if intro else "") + "---\n\n" + build_cards(posts, want_en)
        index_file.write_text(fm + "\n" + body, encoding="utf-8")
        changed = True
        print(f"  {index_name}: rigenerata (introduzione + {len(posts)} card candidate)")
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


def add_language_links(content: Path, posts: dict) -> bool:
    changed = False
    for path, fields in posts.items():
        other = counterpart(path, fields)
        if other not in posts:
            continue
        lang = "en" if path.rsplit("/", 1)[-1].rsplit(".", 1)[0].endswith(".en") else "it"
        sentence = LINK_SENTENCE[lang].format(link=f"[{LINK_TEXT[lang]}]({other.rsplit('/', 1)[-1]})")
        post_file = content / path
        lines = post_file.read_text(encoding="utf-8").splitlines(keepends=True)
        insert_at = None
        for i, ln in enumerate(lines):
            if ln.startswith("# "):
                insert_at = i + 1
                break
            if i > 0 and ln.startswith("---") and lines[0].startswith("---"):
                # fine del frontmatter: punto di inserimento di riserva
                if insert_at is None:
                    insert_at = i + 1
        if insert_at is None:
            continue
        if insert_at < len(lines) and lines[insert_at].strip() == sentence:
            continue  # host già presente
        lines.insert(insert_at, f"\n{sentence}\n")
        post_file.write_text("".join(lines), encoding="utf-8")
        changed = True
        print(f"  {path}: link lingua aggiunto -> {other}")
    return changed


def strip_body_duplicates(content: Path, posts: dict) -> None:
    """Rimuove dal corpo le righe che il layout rende già: h1 = titolo
    (ArticleTitle), '*Pubblicato:*' (ContentMeta), '**Tag:**' (TagList)."""
    pub_re = re.compile(r"^\*(Pubblicato|Published):\s*[\d-]+\*$")
    tag_re = re.compile(r"^\*\*Tags?\*\*:")
    items = dict(posts)
    for name in ("index.md", "index.en.md"):  # esclusi da collect_posts ma con h1/dati duplicati
        index_file = content / name
        if index_file.exists():
            items[name] = parse_frontmatter(index_file.read_text(encoding="utf-8"))
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
    n_en = len([p for p in posts if p.rsplit("/", 1)[-1].rsplit(".", 1)[0].endswith(".en")])
    print(f"Trovati {len(posts)} post ({len(posts) - n_en} it, {n_en} en)")
    strip_body_duplicates(content, posts)
    add_category_to_tags(content, posts)
    add_language_links(content, posts)
    rewrite_home(content, posts)
    return 0


if __name__ == "__main__":
    sys.exit(main())
