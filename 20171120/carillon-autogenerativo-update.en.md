---
title: AUTOGENERATIVE CARILLON UPDATE
tags: [do it yourself, autocostruzione, arduino, DIY, MIDI, algoritmi, musica, programmazione, fai da te, microcontrollori]
category: progetto
date: 2017-11-20
status: final
author: Max Farnea
lang: en
translations: carillon-autogenerativo-update
---
# AUTOGENERATIVE CARILLON UPDATE

*Published: 2017-11-20*

**Tag:** do it yourself, autocostruzione, arduino, DIY, MIDI, algoritmi, musica, programmazione, fai da te, microcontrollori

---

[![](../imgs/6849915410_507a2e1c3e.jpg)](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhAMz__8Xz2pUijFLwiZOm9VU48vDB7P3EFI1U17zVhUbHoRw7MPT79d5Edl326mUIpDMZjSLoa_V11QJjNvgAhhuX0criQv1T7bYqsYOBPH2xe5NtPSllZ3-R0_wtq5DG1iwbprFADBZo/s1600/6849915410_507a2e1c3e.jpg)

  

  

For those who don't know my carillon, please read this [[carillon-autogenerativo.en|post]] first.  

   

After some time I came back to this project to update it — basically I included a purely MIDI version that sends notes via a standard MIDI port connected to the TX pin of Arduino. In the new archive you will also find the schematic for connecting a simple MIDI OUT port.

  

Inside the source code of the MIDI implementation you will find the midiChannel variable to configure the MIDI channel (default 1), and the bass_octave and voice_octave variables to set the octave on which bass and melody will operate (default 2 and 4).

  

With this release, the standard version has also undergone a small update in the definition of the scales.

  

**You can download the new archive here:** [autocarillion_20171119.zip](https://drive.google.com/open?id=1zxxcqw6c4hkAz1sPAUXPeEl9tLGii8Qt)
