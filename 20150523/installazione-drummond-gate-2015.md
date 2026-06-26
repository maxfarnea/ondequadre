---
title: INSTALLAZIONE DRUMMOND GATE 2015
tags: [installazione, suoni, sperimentazione, progetto, sintetizzatore, multimediale, performance, sperimentale, algoritmi, noise, processing, musica, programmazione, live]
category: installazione
date: 2015-05-23
status: final
author: Max Farnea
cover: ../imgs/Cattura.PNG
description: "Questa installazione si basa su un software da me realizzato che permette di acquisire immagini in tempo reale tramite una webcam e, dopo averle elaborate in mo"
translations: installazione-drummond-gate-2015.en
---
# INSTALLAZIONE DRUMMOND GATE 2015

*Pubblicato: 2015-05-23*

**Tag:** installazione, suoni, sperimentazione, progetto, sintetizzatore, multimediale, performance, sperimentale, algoritmi, noise, processing, musica, programmazione, live

---

Questa installazione si basa su un software da me realizzato che permette di acquisire immagini in tempo reale tramite una webcam e, dopo averle elaborate in modo da enfatizzare le parti in movimento, le trasforma in uno spettro audio tramite una scansione verticale, secondo un processo che imita il funzionamento di un sintetizzatore ANS.  
  
Sedendosi davanti a Live ANS è possibile vedere su uno schermo la propria immagine processata e scansionata, mentre si può ascoltare il risultato della generazione dello spettro audio tramite delle cuffie. E' possibile interagire in tempo reale con il processo muovendo la testa o le mani davanti alla webcam.  
  
Questo progetto non vuole essere un altro simulatore di sintetizzatore ANS; si caratterizza e differisce dal funzionamento della macchina originale per i seguenti aspetti, che aprono la strada anche a nuove sperimentazioni:  
  

- la scansione avviene verticalmente secondo un loop infinito.

- l'immagine scansionata non è statica ma, trattandosi di un video, è in continua evoluzione.

- la lettura di una riga dell'immagine durante la scansione avviene in un contesto digitale, cioè invece di rilevare tramite un sensore analogico la presenza di un fascio luminoso in una data area, vengono letti direttamente i valori RGB dei pixel. Questo permette di lavorare non solo con la luminosità ma anche con i colori, o processare le immagini ed estrarre ad esempio da esse le sole parti in movimento.

- il suono non viene prodotto a partire dalle frequenze con le quali i fasci di luce sono modulati e che sono generate a monte dalla luce stessa, ma è sintetizzato da una libreria virtual-analog da centinaia di oscillatori le cui frequenze dipendono dai valori RGB dei vari pixel. Anche in questo caso l'approccio programmatico permette anche di sperimentare diverse forme d'onda per le singole componenti frequenziali, oltre che potenzialmente poter implementare modulazioni più sofisticate o filtri ed effetti audio.

  

[![](../imgs/Cattura.PNG)](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg99ojTpjU2Tr8sOwv3fDpPEJeygkChVQpqrx2KIXavBMJkDkqnytmqaZQHzpz_k0Fyvm47KkDqF2gqpQo-efiHRGIIAEFSzaPXJNMJ6R8VEEvP9xCgOQjVNtfyPCXf0Ik_HXYukfsVGDg/s1600/Cattura.PNG)
