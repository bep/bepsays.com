---
date: 2012-02-07 17:52:22+00:00
slug: ruter-sanntid
title: Implementasjonen av Ruter si sanntidsløysing
categories:
- Kollektivtransport
---

**Eg stod ein halv time og venta på trikken i ettermiddag, såg teljaren på Ruter si sanntidsløysing gå mot null tre gonger.**

Pussig, tenkte eg. Så fekk eg tak i kjeldekoden (eller, det kan vel hende at skreiv denne i sjølv etter å ha frose på ein trikkestopp i ein halv time).

<!--more-->

    
{{< highlight java >}}     
package no.ruter.sanntid;

import java.util.Random;

import static no.ruter.sanntid.SanntidUtils.*;

public class RuterSannTid {

    public void sannTid() {
        // TODO: Støtte for 5 og 20 min. mellom trikkene
        // TODO: Hva med søndager, helligdager etc.?
        int minutterMellomTrikkene = 10;
        Random rnd = new Random(System.currentTimeMillis());

        while (true) {
            int minutterAaVente = minutterMellomTrikkene;
            oppdaterTekst(String.valueOf(minutterAaVente));
            while (isNotTrikkenKommet()) {
                if (minutterAaVente == 0) {
                    // forsinka!!
                    minutterAaVente = (rnd.nextInt(10) + 1);
                }
                waitEttMinutt();
                minutterAaVente--;
                String nyTekst = minutterAaVente == 0 ? 
                    "nå" : String
                        .valueOf(minutterAaVente);
                oppdaterTekst(nyTekst);
            }
        }
    }

    // TODO Denne vil stemme i de fleste tilfeller, men vi bør
    // vel hoste opp noe bedre? GPS?
    // Bernhard 2009-01-23: Hva med solceller? Alle trikkene
    // har frontlys!
    // Ted Johnny 2011-02-12: Vi testa solceller. Tanken er
    // god; problemet er at også personbiler har frontlys!!
    private boolean isNotTrikkenKommet() {
        return true;
    }
}
{{< / highlight >}}




