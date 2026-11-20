---
title: LIVE CODING, OR WHEN THE PROGRAM BECOMES AN INSTRUMENT
tags: [live coding, experimental, algorithms, programming, electronics, MIDI, synth, sonic pi, algorave]
category: analysis
date: 2026-11-19
status: final
author: Max Farnea
lang: en
description: "Live coding: performing music by writing code in real time, in front of the audience, screens wide open. The TOPLAP manifesto, algorave, Sonic Pi and generative pattern"
translations: live-coding
---
# LIVE CODING, OR WHEN THE PROGRAM BECOMES AN INSTRUMENT

*Published: 2026-11-19*

**Tags:** live coding, experimental, algorithms, programming, electronics, MIDI, synth, sonic pi, algorave

---

There are musicians who play code. Literally: not a score, not a programmed sequencer, but instructions written in real time, screens wide open, in front of an audience. This movement is called **live coding**, and in its most popular musical branch, **algorave**, people dance in front of a projector full of lines of code.

The founding text is the manifesto of **TOPLAP**, the community born in a smoky bar in Hamburg in 2004. It is written as a decalogue of claims, and deserves to be quoted:

> *Give us access to the performer's mind, to the whole human instrument. Obscurantism is dangerous. Show us your screens.*
>
> *Programs are instruments that can change themselves.*
>
> *Code should be seen as well as heard, underlying algorithms viewed as well as their visual outcome.*
>
> *Live coding is not about tools. Algorithms are thoughts. Chainsaws are tools.*

The claims go on: extemporaneous improvisation of the algorithm as an expressive gesture, and **no backups**, no prerecorded tracks, no backup computers. And finally an honest admission: the audience does not need to understand the code to appreciate it, just as you don't need to know how to play guitar to attend a concert. The screen is not a backstage exposed as a challenge: it is part of the show, the place where thought becomes sound in real time.

From that manifesto, **algorave** was born: raves where there is no DJ, but someone writing the beat while it runs, and the best moment is when code and music grow together.

Readers of this blog know that I always look for the algorithm inside creative processes, not as an executor, but as an element of sound itself. I wrote about it regarding the Macchina Harmoniosa, the generative sequencer based on Arduino: the starting point is the same. A **deterministic** algorithm, by its nature, when combined with noise (controlled stochastic processes, Perlin noise and the like) stops being a repeated sequence and becomes a **living pattern**, which evolves and surprises even its author. It is exactly the kind of music I care about: unstable, unpredictable but not random.

Live coding takes this idea to the extreme: no longer an algorithm written once and locked inside a machine, but **rewritten while it plays, live**. The risk is real: one mistake and the pattern dies on stage. But in this world, error is not failure: as Sam Aaron also says, it is an **opportunity**, a door that opens. The error that turns a loop into something you had not foreseen, the off-scale note that becomes the new center of the pattern. Those who play mangled circuits with circuit bending know it: a glitch is just a scenario you had not explored yet.

My reference tool is **Sonic Pi**, by Sam Aaron: a live coding environment based on Ruby, born to teach programming in schools and grown into a complete musical instrument (built-in synths, sampling, a precision clock for synchronization, MIDI and OSC towards the outside world). The project is open source, curated continuously from 2013 to today; I have been supporting it on **Patreon since 2018**, because I believe in it on two levels: as a creative tool and as an educational tool (in a **S.T.E.A.M.** perspective).

There are also very solid and more recent alternatives, such as **Strudel** (the JavaScript reimplementation of TidalCycles), which runs directly in the browser and is very strong for generating rhythmic patterns. But so far I still feel at home with Sonic Pi: an established workflow and the ability to bring MIDI synths on stage or generate OSC events to interface with Processing and generate visuals programmatically, in sync with the music.

The full manifesto is on the [TOPLAP website](https://toplap.org/), and the Sonic Pi documentation is on [sonic-pi.net](https://sonic-pi.net/).
