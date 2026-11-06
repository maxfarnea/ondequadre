---
title: MACCHINA HARMONIOSA, UN SEQUENCER MIDI GENERATIVO CON ARDUINO
tags: [suoni, progetto, fai da te, do it yourself, download, sperimentale, autocostruzione, arduino, DIY, algoritmi, programmazione, elettronica, microcontrollori, MIDI, sequencer]
category: release
date: 2017-06-23
status: final
author: Max Farnea
description: "Macchina Harmoniosa è un sequencer/arpeggiatore MIDI generativo basato su Arduino, con pattern a due tracce, morphing realtime verso ventuno scale e autogenera"
translations: macchina-harmoniosa.en
---
# MACCHINA HARMONIOSA, UN SEQUENCER MIDI GENERATIVO CON ARDUINO

*Pubblicato: 2017-06-23*

**Tag:** suoni, progetto, fai da te, do it yourself, download, sperimentale, autocostruzione, arduino, DIY, algoritmi, programmazione, elettronica, microcontrollori, MIDI, sequencer

---

Macchina Harmoniosa è un piccolo sequencer/arpeggiatore MIDI generativo basato su Arduino, come tanti che si vedono in azione su YouTube, ma con qualche caratteristica in più. E come tutti i progetti che mi piacciono, comincia da un pezzo di surplus elettronico: la sua tastiera viene da un vecchio registratore di cassa di un ristorante pizzeria, recuperata e riciclata. 88 tasti, otto righe per undici colonne, gestiti tramite due moduli demultiplexer collegati ad Arduino. Sopra ci ho montato un display LCD 16x2 e, visto che il sequencer lavora su due tracce, due uscite MIDI.

L'ispirazione per costruirla mi è venuta ascoltando ***Vertical*** di **Caterina Barbieri**: un album fatto di pattern minimisti che si ripetono e si trasformano con una pazienza ipnotica. Ascoltandolo, a un certo punto, non ho più voluto solo ascoltare quegli arabeschi di note: ho voluto uno strumento che me li facesse costruire.

### Specifiche

Il sequencer gestisce **due tracce indipendenti** di 16 step ciascuna, con canali MIDI separati (di default 1 e 2, configurabili). Ogni step ha nota, durata (dal quarto alla sedicesima, in tick MIDI) e volume, con accenti.

Il timing è la prima cosa a cui ho tenuto: la macchina genera un **master clock MIDI interno a 24 impulsi per quarto di nota**, gestito via interrupt, e trasmette in uscita tutti i messaggi di clock (Start, Stop, Clock). Il tempo è variabile in continuo da 10 a 480 BPM con i tasti cursore, oppure selezionabile tra sedici valori preimpostati. Il loop principale del programma è vuoto: tutto, esecuzione compresa, è interrupt driven.

La parte armonica è il cuore della macchina:

- **morphing realtime**: il pattern può essere riarmonizzato al volo verso **ventuno scale** diverse;
- **trasposizione realtime** verso un'altra tonica, anche durante l'esecuzione;
- **editing evoluto del pattern in realtime**: tempo, durata delle note, pitch, lunghezza del pattern, scala, volume master.

Le funzioni di **autogenerazione** sono la sezione più caratteristica e il motivo per cui l'ho costruita. Ho usato un approccio strettamente algoritmico e specificatamente **stocastico** (rigenerazione del pattern con probabilità di variazione al 10%, 20%, 33% o 50%).

Ho implementato 3 modalità di funzionamento:

- **modalità pattern**: il pattern gira in loop, e lo puoi rigenerare o variare a mano quando vuoi;
- **modalità verticale**: gli step sostengono le note invece di spegnerle, verso una musica verticale, fatta di droni e strati;
- **modalità frattale**: la macchina, al termine di ogni brano (lunghezza configurabile in blocchi), autorigenera il pattern applicando da sola il tipo di variazione scelto: da semplici trasposizioni di singole note fino alla rigenerazione completa. Ogni brano è figlio del precedente e di un po' di rumore.

I pattern si salvano e caricano dalla **EEPROM** di Arduino, in sedici bank.

E poi c'è un tasto **PANIC**, che spegne tutte le note su tutti i canali: quando una modalità verticale lascia qualcosa in sospeso, o quando la creatività degenera.

L'esecuzione può avvenire anche al contrario, con i tasti di forward e backward.

### Dettagli tecnici

Il seme del generatore casuale viene preso all'avvio da un ingresso analogico libero e mostrato sul display, così ogni accensione è potenzialmente diversa dalle altre. La tastiera viene scandita riga per riga scrivendo gli indirizzi sui demultiplexer e leggendo il risultato su un singolo pin dati, con debounce software.

Le due tracce suonano i gradi della scala selezionata: la nota MIDI è calcolata come ottava, tonica e grado, quindi cambiare scala a runtime non cambia il pattern ma il suo vestito armonico.


[![](https://img.youtube.com/vi/v5611vssoK4/hqdefault.jpg)](https://www.youtube.com/watch?v=v5611vssoK4)

[![](https://img.youtube.com/vi/mB54FS6n3Wk/hqdefault.jpg)](https://www.youtube.com/watch?v=mB54FS6n3Wk)

[![](https://img.youtube.com/vi/eyXHU_BBZy4/hqdefault.jpg)](https://www.youtube.com/watch?v=eyXHU_BBZy4)

[![](https://img.youtube.com/vi/QqZFFEUk9Us/hqdefault.jpg)](https://www.youtube.com/watch?v=QqZFFEUk9Us)
