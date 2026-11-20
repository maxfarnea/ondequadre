#!/usr/bin/env python3
"""Prepara gli indici bilingui per Quartz.

Nei file del vault i blocchi ```dataview restano invariati (funzionano in
Obsidian); questo script, eseguito solo in CI prima del build Quartz:
  1. sostituisce i blocchi dataview di index.md / index.en.md con la stessa
     tabella generata staticamente dal frontmatter dei post;
  2. aggiunge, dopo il titolo di ogni post, un link alla versione nell'altra
     lingua (a build time, senza toccare i file del vault).

Uso: python3 generate_index.py <dir-content-di-quartz>
"""

import re
import sys
from pathlib import Path

FM_RE = re.compile(r"^---\s*\r?\n(.*?)\r?\n---\s*\r?\n?", re.S)
DVIEW_RE = re.compile(r"```\s*dataview\r?\n.*?\r?\n```(?:\r?\n)?", re.S)
KV_RE = re.compile(r"^(title|date|category|description|author|translations):\s*(.*?)\s*$", re.M)

EXCLUDED_FILES = {"index.md", "index.en.md", "brief.md", "how-to.md", "obsidian-config.md", "to-do.md"}

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
    """Ritorna {percorso_relativo: campi_frontmatter}."""
    posts = {}
    for md in content.rglob("*.md"):
        if md.name in EXCLUDED_FILES:
            continue
        fields = parse_frontmatter(md.read_text(encoding="utf-8"))
        if fields.get("author", "").lower() != "max farnea":
            continue
        posts[md.relative_to(content).as_posix()] = fields
    return posts


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


def build_table(posts_all: dict, want_en: bool) -> str:
    rows = []
    for path, fields in posts_all.items():
        is_en = path.rsplit("/", 1)[-1].rsplit(".", 1)[0].endswith(".en")
        if is_en != want_en:
            continue
        date = fields.get("date", "")
        title = fields.get("title", path)
        desc = fields.get("description", "").replace("|", "\\|")
        cat = fields.get("category", "")
        label = CATEGORY_LABELS.get(cat, {}).get("en" if want_en else "it", cat)
        rows.append((date, f"| [{title}]({path}) | {date} | {label} | {desc} |"))
    rows.sort(key=lambda r: r[0], reverse=True)
    header = "| Post | Date | Category | Description |\n| - | - | - | - |"
    return header + "\n" + "\n".join(r[1] for r in rows) + "\n"


def replace_dataview_blocks(content: Path, posts: dict) -> bool:
    changed = False
    for index_name in ("index.md", "index.en.md"):
        index_file = content / index_name
        if not index_file.exists():
            continue
        text = index_file.read_text(encoding="utf-8")
        table = build_table(posts, want_en=(index_name == "index.en.md"))
        new_text, n = DVIEW_RE.subn(table, text)
        if n:
            index_file.write_text(new_text, encoding="utf-8")
            changed = True
            print(f"  {index_name}: sostituito/i {n} blocco/i dataview con la tabella statica")
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
    replace_dataview_blocks(content, posts)
    add_language_links(content, posts)
    return 0


if __name__ == "__main__":
    sys.exit(main())
