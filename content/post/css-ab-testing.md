---
categories:
- Teknologi
date: 2014-11-08T09:57:44+01:00
draft: false
tags:
- Meta
- Asterisk
title: "Lynrask A∕B-testing av stilsettendringar"
---
**Om tykkjer det hadde vore kjekt å bla deg gjennom ulike utsjånadsvariantar av nettstaden din med eit tastetrykk -- og sjå nye endringar smyge seg inn i nettlesaren...**

Då bør du lese vidare. Dette kan gjerast med enkle grep.

 <!--more-->

No finst det allereie løysingar for å laste endringar automatisk i nettlesaren; byggeverktøy som Grunt og Gulp har dette som tillegg, [Hugo](http://gohugo.io/) -- sidegeneratoren eg bruker for denne nettstaden -- har alt dette innebygd.

Og dei støttar alle det eg kaller _mjuk omlasting_ av endringar i stilsett og bilete, som i motsetnad til ein CTRL-R i Firefox nesten ikkje er til å merke -- endringane smyg seg på plass.

**Men det kan gjerast betre! Mykje betre!**

## Kva for font passar best?
Det finst mange grunnar til å gjere endringar i uforminga av ei nettside, det vere seg om ho er ny eller gamal.

Kanskje hadde det gjort seg betre med ein sans-serif som tittelfont? Eller kva om me gøymde _det_ biletet på små mobiltelefonar?

No _kan_ ein gjere desse endringane og samanlikne med nettsida som er i produksjon, men om ein har ein tre-fire variantar ein ynskjer å teste ut -- og gjerne litt fram og tilbake -- ja, då blir det mykje alt-tabbing.

**Og det blir ikkje betre om endringane har fleire interessentar enn deg sjølv, kanskje kundar som betaler for plunderet.**

## Hurtigtast deg gjennom variantane

Då kan du heller gjere som meg -- eller gjere som eg kjem til å gjere _etter_ at dette innlegget med tilhøyrande skript er klart, for førebels er det berre tankar på ein skjerm -- lag deg ein hurtigtast som vekslar mellom dei ulike endringsutkasta.

**Eg har valgt tastekombinasjonen ALT-SUPER-N, stilsettet sitt svar på ALT-TAB.**

Eg skal ta deg gjennom kva som skal til for å få til dette, men eg forutset eit par ting: At du veit korleis du lagar hurtigtastar og at du har eller veit korleis du får deg eit oppsett for _livereload_[^livereload] og bygging av stilsett frå LESS eller SASS.[^cssalt]

Eg skal syne deg døme på skript som gjer dette, men her er omrisset:

1. I stilsettet `minestilar.less` har du eit sett med variablar.
1. Du kopierer ut dei variablane som du ser for deg å endre ut i ei ny fil med eit kjent prefiks, feks. `minvariant_1.less` (her er er _minvariant_ prefikset som må gjentakast i variantane). Eg seier _variablar_ her, men det kan vel også tenkjast at du vil byte ut alt...
1. Du importerer `minvariant_1.less` i `minestilar.less`, og her er det viktig at importen kjem etter variablane du skal overstyre.
1. Du lagar ein kopi av varianten, `minvariant_fargetestar.less`, og gjer dei endringane som skal til i denne. Gjenta dette med nye namn for fleire variantar.
1. Medan du ser på sida i nettlesaren trykker du på _ALT-SUPER-N_ og blar deg gjennom variantane.
1. Når du er nøgd er du ferdig. 

Medan du tenkjer litt på dette, så må eg skripte litt. Er attende om litt... 

... OK, då er eg attende.

## Eit Ruby-skript til hjelp

Følgjande Ruby-skript gjer jobben for meg. Skriptet roterer importen i LESS-fila `/assets/less/bs.less` med filene `/assets/less/variants/bs-variant*.less`. 

{{< highlight rb >}}
#!/usr/bin/ruby

#
# This script performs replacement of a set of LESS-imports in round-robin style.
#
# @version: 0.1
# @author: Bjørn Erik Pedersen
#
LESS_PATH=File.expand_path('../assets/less', File.dirname(__FILE__))
LESS_VARIANT_PATH=LESS_PATH + '/variants'
LESS_FILE=LESS_PATH + '/bs.less'
VARIANT_PREFIX='bs-variant'

# Get all the variants and sort them
variants ||= Dir.chdir(LESS_VARIANT_PATH) { Dir['*.less'] }
variants.sort

# Replace import with the next LESS file in line
File.open(LESS_FILE, 'r+') { |f|
  new_content = ""
  f.each_line { |line|
    if line.include? VARIANT_PREFIX
      curr_variant = line.match(/import.*(#{VARIANT_PREFIX}.*?\.less)/)[1]
      curr_index = variants.index(curr_variant)
      next_index = (curr_index + 2) > variants.length ? 0 : curr_index + 1
      next_variant = variants[next_index]
      new_content << "@import \"variants/#{next_variant}\";\n"
    else
      new_content << line
    end
  }
  f.rewind
  f.puts new_content
}

{{< / highlight >}}

No er filnamna og katalogane i skriptet over tilpassa min struktur, men det skulle la seg gjere å forstå.

## Korleis fungerer det?

"Dette var mykje for lite," seier du kanskje -- men eg meiner dette er eit glimrande lite grep, særleg for slike som meg, eg som har litt vanskar med å bestemme meg for om overskriftene tek seg best ut i svart eller i mørk blått.

**Og det er lettare magi å sjå skjermen endre seg med eit tastetrykk...** 

[^livereload]: _livereload_ for Grunt finn du [her](https://github.com/gruntjs/grunt-contrib-livereload), for Gulp kan du gå [hit](https://github.com/vohof/gulp-livereload).
[^cssalt]: No burde vel dette la seg gjere også med CSS, men då må skriptet "tenkjast om".