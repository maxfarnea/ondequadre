---
title: AN AUTOGENERATIVE CARILLON WITH ARDUINO
tags: [suoni, progetto, fai da te, do it yourself, download, sperimentale, autocostruzione, arduino, DIY, algoritmi, programmazione, elettronica, microcontrollori]
category: release
date: 2013-01-25
status: final
author: Max Farnea
lang: en
translations: carillon-autogenerativo
---
# AN AUTOGENERATIVE CARILLON WITH ARDUINO

*Published: 2013-01-25*

**Tag:** suoni, progetto, fai da te, do it yourself, download, sperimentale, autocostruzione, arduino, DIY, algoritmi, programmazione, elettronica, microcontrollori

---

After years spent programming Motorola 68HC11 or Microchip PIC microcontrollers for robotics or musical projects, discovering Arduino was like a breath of fresh air.   

  

[![](../imgs/Uno_Orig.jpg)](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh1Cgsj7yJV6yV7uI6SImjVUEXB1IZaI_XHnSJhdPKxg_KN7dBJpTODHZW1dSy9c6W5glE2UVezjEO1xmFaZwcgLGw8AaZvCxtZU3JM-wXKfgEHjJ6OQhenj9QyQFgh_tqOX2Re2Kz2RHw/s1600/Uno_Orig.jpg)This incredible Italian product has now become a well-established worldwide paradigm for hobbyists and digital circuit prototyping. The number of projects using it, the resources available online, the clones and the various expansion boards available (shields) are proof of this.

  

[![](../imgs/6849915410_507a2e1c3e.jpg)](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiGydjaan8sFdnIEGWhhnXu9yuoIOKtUYieJeegIJ9NLoCIym-LEJDwsHaxzptxgLrSYRua8ZNpbWrVYV3V1AMo873P7jQ7BG0e8QSf23gmGlEyQSd5rXxicJHZcc6LKzImBq8v8al-Q70/s1600/6849915410_507a2e1c3e.jpg)After a few tests to get comfortable with the environment, I decided to build a project of my own. Starting from the idea of making a musical toy for my daughter, I ended up with a solid foundation for experimenting with autogenerative music algorithms — and this autogenerative carillon was born.  

  

**Specifications**  

  
The carillon consists of two voices (bass and melody) generated randomly on the basis of a pentatonic scale, itself also chosen randomly.  
  
The basic sequence is 4 bars of 4/4.   
  
The bass moves in quarter notes, on a 2-bar pattern repeated twice.  
  
The melody is composed of eighth notes and occasional rests, over a full 4-bar pattern. The melody moves at least one octave above the bass.  
  
The first bass run happens without the melody, which enters in one of the following bars based on a random choice.  
  
After each complete 4-bar cycle, the algorithm decides whether to regenerate the bass notes, the melody notes, or both.  
  
Pressing an external button generates an interrupt that resets the algorithm, setting a new scale and a new tempo.  
  
The stored pentatonic scales number 24: 12 major and 12 minor.  
  
The playback tempo can take one of the preset values: 60, 90, 120, 180.  

  

**Technical Details**  

  

At software startup, the random number generator is seeded with the value present on Arduino's analogue input 0. If nothing is connected to it, the seed is set randomly based on noise; otherwise a potentiometer can be used to set a specific seed value.  
  
A software switch, to be enabled at compile time, adds an extra degree of variability by allowing momentary alteration of a melody note by a semitone during playback (the corresponding degree of the pentatonic scale immediately before or after the current one is played).  
  
The randomness of variations in the melody structure is not uniform; it is possible to set a weight to make it more or less variable. For example, while the choice of scale and tempo is equiprobable, the probability that the melody is activated after the first bass run is 75%, while the probability that a note is altered by a semitone is 10% (if alteration is enabled). Finally, the probability that after a cycle the bass or the melody is regenerated is 50%. All these weights are constants that can be set at compile time.  
  
Sound generation occurs via two PWM outputs to which a piezo transducer is connected. The Tone Library by Rogue Robotics Open Source Code was used:  
  
[http://code.google.com/p/rogue-code/wiki/ToneLibraryDocumentation](http://code.google.com/p/rogue-code/wiki/ToneLibraryDocumentation)  
  
A digital output varies according to the playback tempo, allowing LEDs to flash in time with the music.  
  
Three outputs are configured to drive an RGB LED whose colour continuously varies based on the tempo and the frequency of the notes being played.  

  

**Future Experimental Developments**  
  
Replacing internal sound generation with a MIDI output in order to use external musical hardware.  
  
Digital outputs to drive solenoids or servo motors in time with the music.  
  
Implementation of a microtonal approach.

  

[![](../imgs/yt-placeholder.png)](https://www.youtube.com/watch?v=XCt9-f3kTwc)

  

** ****Download the project here**: [autocarillion_20171119.zip](https://drive.google.com/open?id=1zxxcqw6c4hkAz1sPAUXPeEl9tLGii8Qt)

  

[![](../imgs/autocarillion.png)](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj76moQlTJHHEcQ_udL4LpTjc9a4-rtc0Jy6PfSkLWLBNhqtXe-rV6DqYGrEYNzxLLUfUxHaA2-R4geXEYIYsLSBhNB-udLkKVj7IFohdkPn3HV2dPqfpJY5bHDxBQvPmup2uCjpqyn-yA/s1600/autocarillion.png)** ****IMPORTANT**: the Tone Library has not been updated for Arduino IDEs later than 0023. To fix compilation issues in more recent development environments, simply edit the Tone.cpp file and replace the wiring.h import with Arduino.h, as also discussed in the Arduino forum [here](http://forum.arduino.cc/index.php?topic=87398.0). Alternatively you can download my already-modified version [here](https://drive.google.com/open?id=0B5R3uOmkGTIrNW4ycFdsT3VzV28).
