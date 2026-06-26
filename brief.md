Voglio creare un vault obsidian con il mio blog, 

Ogni cartella è un post e dentro c'è un file markdown con l'articolo in italiano

C'è anche una cartella imgs con le immagini

Un file tags.txt contiene l'elenco dei tag (dovrebbero essere cmq già inclusi nell'articolo)

Ogni file è in italiano e le prime righe sono il titolo, la data di pubblicazione e i tags, ad esempio

## TASK 1

Per ogni post (folder) spostare le immagini nella cartella 'imgs' nella root del progetto e aggiustare i riferimenti ad esse che ci sono nel post.

## TASK 2

Se il post ha link a video youtube trasformarli in immagini cliccabili dove l'immagine sarà una thumbnail del video, ma al momento usa l'immagine

imgs/yt-placeholder.png

Se il post ha link ad album di bandcamp trasformarli in immagini cliccabili dove l'immagine sarà una thumbnail della cover, ma al momento usa l'immagine

imgs/bc-placeholder.png

Se il post ha link ad album di soundcloud trasformarli in immagini cliccabili dove l'immagine sarà una thumbnail della traccia, ma al momento usa l'immagine

imgs/sc-placeholder.png

## TASK 3

Traduciamo tutti i post in inglese, generando dei file insieme ai post in italiano aggiungendo '.en' come suffisso al file.

## TASK 4

Voglio usare Dataview o Bases per realizzare una struttura navigabile, quale è meglio? Pensavo di iniziare con Dataview e quindi per ogni file mettere un frontmatter tipo questo

```markdown
---
title: GUIDA A UN SEMPLICE CIRCUIT BENDING
tags: [suoni, circuit, sperimentazione, giocattoli, glitch, circuitbending, sperimentale, micromusic, lofi, DIY, noise, guida, elettronica]
category: analisi-tecnica
date: 2012-12-11
status: final
author: Max Farnea
---
```

