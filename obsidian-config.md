# Configurazione Obsidian + Dataview + Quartz

## Struttura del vault

```
ondequadre/
  index.md              ← homepage italiana
  index.en.md           ← homepage inglese
  imgs/                 ← tutte le immagini centralizzate
  YYYYMMDD/
    slug.md             ← post italiano
    slug.en.md          ← post inglese
```

## Frontmatter (campi usati)

```yaml
title: TITOLO DEL POST
tags: [tag1, tag2]
category: guida | installazione | release | performance | progetto | analisi-tecnica
date: YYYY-MM-DD
status: final
author: Max Farnea
lang: en                # solo nei file .en.md
cover: ../imgs/img.jpg  # prima immagine del post
description: "..."      # max ~160 caratteri
translations: slug.en   # slug della versione nell'altra lingua
```

---

## Obsidian

### Impostazioni consigliate

- **Settings → Files & Links → New link format**: `Relative path to file`
- **Settings → Files & Links → Use [[Wikilinks]]**: attivo
- **Settings → Files & Links → Default location for new notes**: cartella della data corrente
- **Settings → Editor → Strict line breaks**: disattivo (il vault usa doppio spazio per a-capo)

### Plugin da installare

| Plugin | Uso |
|--------|-----|
| **Dataview** | Query sui frontmatter per index e navigazione |
| **Templater** | Template per nuovi post con frontmatter precompilato |

---

## Dataview

### Lista tutti i post italiani per data
```dataview
TABLE date, category, description
FROM ""
WHERE author = "Max Farnea" AND !contains(file.name, ".en") AND file.name != "index"
SORT date DESC
```

### Lista per categoria
```dataview
TABLE date, title
FROM ""
WHERE author = "Max Farnea" AND !contains(file.name, ".en") AND category = "guida"
SORT date DESC
```

### Lista per tag
```dataview
TABLE date, title
FROM ""
WHERE author = "Max Farnea" AND !contains(file.name, ".en") AND contains(tags, "circuitbending")
SORT date DESC
```

### Language switcher manuale (in ogni post)
```dataview
LIST
FROM ""
WHERE file.name = this.translations
```

---

## Quartz

### Setup iniziale

```bash
git clone https://github.com/jackyzha0/quartz.git
cd quartz
npm install
npx quartz create
```

Copia il contenuto del vault nella cartella `content/` di Quartz.

### Configurazione `quartz.config.ts`

Campi rilevanti:

```ts
const config: QuartzConfig = {
  configuration: {
    pageTitle: "Onde Quadre",
    enableSPA: true,
    enablePopovers: true,
    locale: "it-IT",
    baseUrl: "tuodominio.com",
    ignorePatterns: [
      "obsidian-config.md",
      "brief.md",
      "how-to.md",
      "task*.py",
    ],
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({ priority: ["frontmatter"] }),
      Plugin.Latex(),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
    ],
    // ...
  }
}
```

### i18n / language switcher

Quartz non ha un language switcher nativo. Opzioni:

1. **Campo `translations` nel frontmatter** (già presente) — usabile con un componente custom o tramite Dataview nell'anteprima Obsidian
2. **Due baseUrl separate**: `it.tuodominio.com` e `en.tuodominio.com` con due build distinte
3. **Sottocartelle** `/it/` e `/en/` con routing manuale nel tema

L'approccio più semplice per ora: aggiungere in ogni post un link esplicito alla traduzione usando il campo `translations`:

```md
> 🇬🇧 [Read in English](../cracklebox.en)
```

### Deploy su GitHub Pages

```bash
# quartz.config.ts → baseUrl: "username.github.io/ondequadre"
npx quartz sync --no-pull
```

Aggiungi `.github/workflows/deploy.yml` secondo la documentazione ufficiale di Quartz.

---

## Template per nuovi post

Crea `.obsidian/templates/nuovo-post.md`:

```md
---
title: {{title}}
tags: []
category: analisi-tecnica
date: {{date:YYYY-MM-DD}}
status: draft
author: Max Farnea
cover: 
description: ""
translations: 
---

# {{title}}

*Pubblicato: {{date:YYYY-MM-DD}}*

**Tag:** 

---

```
