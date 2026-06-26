# Obsidian come knowledge base per analisi tecniche

## Properties (YAML Frontmatter)

Obsidian supporta metadati strutturati tramite frontmatter YAML all'inizio di ogni file:

```markdown
---
title: Analisi Performance API Gateway
tags: [performance, api, aws]
category: analisi-tecnica
date: 2026-06-19
status: draft | review | final
author: Massimiliano
aliases: [API GW Perf Analysis]
---
```

Queste properties sono indicizzabili, filtrabili e ricercabili. `tags` e `aliases` sono campi nativi riconosciuti da Obsidian.

## Date e ordinamento cronologico

- Il campo `date` nel frontmatter (formato ISO `YYYY-MM-DD`) è il modo standard
- Obsidian lo riconosce come tipo "Date" nelle property
- Puoi anche usare `created` e `modified` come campi custom
- Con il plugin Dataview (vedi sotto), puoi ordinare e filtrare per data

## Link interni e backlink

La killer feature di Obsidian come wiki:

```markdown
Vedi [[Analisi Performance API Gateway]]
Vedi [[API GW Perf Analysis]]  ← funziona grazie agli aliases
```

- I **backlink** mostrano automaticamente quali documenti puntano a quello corrente
- Il **Graph View** visualizza le relazioni tra documenti come un grafo navigabile

## Documenti di summary/indice

Puoi crearli manualmente con link, oppure generarli dinamicamente con **Dataview** (plugin community molto diffuso):

````markdown
## Tutte le analisi per categoria

```dataview
TABLE date, status, category
FROM "analisi"
WHERE category = "analisi-tecnica"
SORT date DESC
```

## Analisi recenti

```dataview
LIST
FROM #performance
SORT date DESC
LIMIT 10
```
````

Dataview supporta query SQL-like su tutte le properties dei tuoi file.

## Tag e navigazione per topic

- `#tag` inline nel testo o nel frontmatter `tags: [...]`
- Tag gerarchici: `#aws/lambda`, `#aws/api-gateway`
- Il pannello Tags mostra tutti i tag con conteggio
- Puoi combinare tag + Dataview per creare indici automatici per topic

## Feature utili per una wiki tecnica

| Feature | Uso |
|---------|-----|
| **Templates** | Template predefiniti per ogni tipo di documento (analisi, decisione, ADR) |
| **Folders** | Struttura gerarchica classica che convive con i link |
| **Embeds** | `![[altro-documento]]` incorpora contenuto inline |
| **Callouts** | `> [!warning]` per evidenziare note, avvisi, decisioni |
| **Canvas** | Mappe visuali per collegare documenti in diagrammi |
| **Search operators** | `path:`, `tag:`, `file:`, `section:` per ricerca avanzata |
| **MOC (Map of Content)** | Pattern comune: documenti-indice manuali che fungono da hub di navigazione |

## Pubblicazione come sito statico (wiki)

Opzioni:

1. **Obsidian Publish** — servizio ufficiale a pagamento, zero config
2. **Quartz** — generatore statico open source pensato per vault Obsidian, supporta graph view, backlink, search
3. **MkDocs + Material** — con plugin `obsidian-to-mkdocs`, ottimo per documentazione tecnica
4. **Hugo** — con qualche adattamento dei link `[[wikilink]]`

## Struttura consigliata

```
vault/
├── _templates/         ← template per nuovi doc
├── _index/             ← MOC e summary
│   ├── per-categoria.md
│   ├── per-data.md
│   └── per-progetto.md
├── analisi/
├── decisioni/          ← ADR (Architecture Decision Records)
├── specifiche/
└── riferimenti/
```

## Templates

Obsidian ha un **core plugin "Templates"** (incluso, basta attivarlo nelle Settings) che automatizza l'inserimento di template nei nuovi documenti. Non è un semplice copia-incolla: la cartella template è riconosciuta dall'engine.

### Come funziona

1. Nelle Settings → Templates, indichi la cartella template (es. `_templates`)
2. Quando crei un nuovo file, usi il comando `Insert template` (Cmd+P → "Insert template")
3. Obsidian inserisce il contenuto del template scelto, sostituendo le variabili dinamiche

### Variabili native

```
{{title}}  → nome del file corrente
{{date}}   → data corrente (formato configurabile, es. YYYY-MM-DD)
{{time}}   → ora corrente
```

### Esempio: `_templates/analisi.md`

```markdown
---
title: "{{title}}"
date: {{date}}
tags: []
category: analisi-tecnica
status: draft
author: Massimiliano
---

## Contesto

## Obiettivo

## Analisi

## Conclusioni

## Prossimi passi
```

### Esempio: `_templates/adr.md`

```markdown
---
title: "{{title}}"
date: {{date}}
tags: [decisione]
status: proposed | accepted | deprecated
category: adr
---

## Contesto e problema

## Opzioni considerate

### Opzione A

### Opzione B

## Decisione

## Conseguenze
```

### Esempio: `_templates/specifica.md`

```markdown
---
title: "{{title}}"
date: {{date}}
tags: []
category: specifica
status: draft
---

## Overview

## Requisiti

## Design

## API / Interfacce

## Dipendenze

## Open questions
```

### Templater (plugin community)

Per più potenza, il plugin **Templater** aggiunge logica condizionale, prompt interattivi e JavaScript:

```markdown
---
title: "<% tp.file.title %>"
date: <% tp.date.now("YYYY-MM-DD") %>
category: <% await tp.system.prompt("Categoria?") %>
tags: [<% await tp.system.prompt("Tags (comma-separated)?") %>]
---
```

## File indice (MOC - Map of Content)

I file sotto `_index` sono MOC e possono essere manuali, dinamici (Dataview) o ibridi. Non c'è un meccanismo built-in per generarli — Dataview è lo standard de facto.

### MOC manuale (curato)

Utile per creare percorsi di lettura guidati:

```markdown
---
title: Indice per Progetto
date: 2026-06-19
tags: [moc, indice]
---

## Progetto API Gateway

- [[Analisi performance API GW]]
- [[ADR - Scelta tra REST e GraphQL]]
- [[Specifica endpoint autenticazione]]

## Progetto Migrazione DB

- [[Analisi impatto migrazione PostgreSQL]]
- [[ADR - Strategy blue-green vs rolling]]
```

Vantaggio: controlli la narrativa e l'ordine. Svantaggio: manutenzione manuale.

### MOC dinamico: `_index/per-categoria.md`

````markdown
---
title: Indice per Categoria
tags: [moc, indice]
---

## Analisi Tecniche

```dataview
TABLE date, status
FROM "analisi"
WHERE category = "analisi-tecnica"
SORT date DESC
```

## Decisioni (ADR)

```dataview
TABLE date, status
FROM "decisioni"
SORT date DESC
```

## Specifiche

```dataview
TABLE date, status
FROM "specifiche"
SORT date DESC
```
````

### MOC dinamico: `_index/per-data.md`

````markdown
---
title: Timeline
tags: [moc, indice]
---

## Ultimi 30 giorni

```dataview
TABLE category, status, tags
FROM "" AND -"_templates" AND -"_index"
WHERE date >= date(today) - dur(30 days)
SORT date DESC
```

## Archivio per mese

```dataview
TABLE category, status
FROM "" AND -"_templates" AND -"_index"
GROUP BY dateformat(date, "yyyy-MM")
```
````

### MOC dinamico: `_index/per-tag.md`

````markdown
---
title: Indice per Tag
tags: [moc, indice]
---

## Performance

```dataview
LIST
FROM #performance
SORT date DESC
```

## AWS

```dataview
LIST
FROM #aws
SORT date DESC
```
````

### Approccio ibrido (consigliato)

- La struttura del MOC è manuale (decidi tu le sezioni)
- Il contenuto delle sezioni è Dataview (si auto-popola)
- Aggiungi note editoriali o link "pinned" a mano sopra le query

### Workflow pratico

1. Crei un nuovo documento usando il template
2. Compili il frontmatter (tags, category, date)
3. I MOC dinamici lo vedono subito — nessuna azione extra
4. Periodicamente rivedi i MOC manuali per aggiungere contesto narrativo

## Gestione documenti bilingue (IT/EN)

Non esiste una funzione nativa per il multilinguismo. L'approccio consigliato è: suffisso lingua + property `lang`.

### Struttura file

```
analisi/
├── analisi-performance-api-gw.md        ← italiano (default)
├── analisi-performance-api-gw.en.md     ← inglese
├── adr-scelta-database.md
└── adr-scelta-database.en.md
```

### Frontmatter versione inglese

```markdown
---
title: API Gateway Performance Analysis
date: 2026-06-19
lang: en
original: "[[analisi-performance-api-gw]]"
tags: [performance, api]
---
```

### Frontmatter versione italiana

```markdown
---
title: Analisi Performance API Gateway
date: 2026-06-19
lang: it
translations:
  en: "[[analisi-performance-api-gw.en]]"
tags: [performance, api]
---
```

### MOC filtrato per lingua

````markdown
## Documenti in italiano

```dataview
TABLE title, date, status
FROM "" AND -"_templates" AND -"_index"
WHERE lang = "it" OR !lang
SORT date DESC
```

## English documents

```dataview
TABLE title, date, status
FROM "" AND -"_templates" AND -"_index"
WHERE lang = "en"
SORT date DESC
```
````

### Alternative meno consigliabili

| Approccio | Pro | Contro |
|-----------|-----|--------|
| **Cartelle separate** (`it/`, `en/`) | Separazione netta | Backlink spezzati, duplicazione struttura |
| **Documento unico bilingue** | Zero duplicazione | File lunghi, Dataview non filtra per sezione |
| **Vault separati** | Isolamento totale | Nessun link tra lingue, doppia manutenzione |

### Workflow bilingue

1. Scrivi il documento nella lingua primaria (es. italiano)
2. Quando serve la traduzione, duplichi il file con suffisso `.en`
3. Aggiungi il link reciproco nel frontmatter di entrambi
4. I MOC Dataview mostrano automaticamente la versione nella lingua desiderata

## Conclusione

Obsidian con Dataview ti dà il 90% di quello che cerchi out-of-the-box — properties strutturate, tag gerarchici, indici dinamici, ordinamento cronologico, e un ecosistema maturo per trasformare il vault in un sito statico navigabile.
