---
title: AGGIORNAMENTO CARILLON AUTOGENERATIVO
tags: [do it yourself, autocostruzione, arduino, DIY, MIDI, algoritmi, musica, programmazione, fai da te, microcontrollori]
category: progetto
date: 2017-11-20
status: final
author: Max Farnea
cover: ../imgs/6849915410_507a2e1c3e.jpg
description: "Per chi non conoscesse il mio carillon, leggete prima questo [[carillon-autogenerativo|post]]."
translations: carillon-autogenerativo-update.en
---
# AGGIORNAMENTO CARILLON AUTOGENERATIVO

*Pubblicato: 2017-11-20*

**Tag:** do it yourself, autocostruzione, arduino, DIY, MIDI, algoritmi, musica, programmazione, fai da te, microcontrollori

---

[![](../imgs/6849915410_507a2e1c3e.jpg)](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhAMz__8Xz2pUijFLwiZOm9VU48vDB7P3EFI1U17zVhUbHoRw7MPT79d5Edl326mUIpDMZjSLoa_V11QJjNvgAhhuX0criQv1T7bYqsYOBPH2xe5NtPSllZ3-R0_wtq5DG1iwbprFADBZo/s1600/6849915410_507a2e1c3e.jpg)

  

  

Per chi non conoscesse il mio carillon, leggete prima questo [[carillon-autogenerativo|post]].  

   

Dopo un po' di tempo sono tornato su questo progetto per aggiornarlo, in pratica ho incluso una versione puramente MIDI che invia le note tramite una porta MIDI standard collegata al pin TX di Arduino. Nel nuovo archivio trovate anche lo schema per collegare una semplice porta MIDI OUT.

  

All'interno del sorgente dell'implementazione MIDI trovate la variabile midiChannel per configurare il canale MIDI (default 1), e le varibili bass_octave e voice_octave per impostare l'ottava su cui far lavorare basso e melodia (default 2 e 4).

  

Con questo rilascio anche la versione standard ha subito un piccolo aggiornamento nella definizione delle scale.

  

**Potete scaricare il nuovo archivio qui:** [autocarillion_20171119.zip](https://drive.google.com/open?id=1zxxcqw6c4hkAz1sPAUXPeEl9tLGii8Qt)
