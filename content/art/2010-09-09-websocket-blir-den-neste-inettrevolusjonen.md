---
date: 2010-09-09 15:52:04+00:00
slug: websocket-blir-den-neste-inettrevolusjonen
title: WebSockets blir den neste nettrevolusjonen

---
**WebSockets blir den neste store nettrevolusjonen! Ein bråkjekk påstand, men eg vart overtydd av foredraget «HTML5 & WebSockets: Think BIG.  Really BIG!»  av [John Fallows](http://johnfallows.sys-con.com/) på [JavaZone](http://javazone.no) onsdag. Tenk stort! seier Fallows -- og han har rett.**

<!--more-->


Protokollen [HTTP](http://en.wikipedia.org/wiki/HTTP) vart laga for å hente ut dokument, med ein førespurnad og eit svar (request/response), eller kommunikasjon som ein walkie talkie om du vil. HTTP er tilstandslaus, og kvar førespurnad blir påført masse metadata. 

{{< img src="/assets/img/wp/mrdoobscratchpad.png" class="alignright" caption="Skjermdump frå mrdoob.com sitt teiknebrett der alle kan teikne samstundes, takka vere WebSockets." >}}

Med Web 2.0 har me rett nok fått rikare og meir interaktive applikasjonar, som Facebook, GMail og liveoverføring av fotballkampar. Men til ein pris: Begrensningane i HTTP gjer applikasjonane kompliserte og dyre å lage. Og dei genererer store mengder nettverkstrafikk, som i seg sjølv set grenser for kva ein kan få gjort.


WebSockets er ein svært undervurdert del av [HTML5](http://dev.w3.org/html5/spec/Overview.html)-spesifikasjonen. WebSockets er [TCP](http://www.igvita.com/2009/12/22/ruby-websockets-tcp-for-the-browser/) for nettlesaren. [Full-duplex](http://en.wikipedia.org/wiki/Duplex_%28telecommunications%29#Full-duplex), kommunikasjonen går begge vegar - og kommunikasjonslinja vert halde open, og ein kan ha så mange ein berre vil. Datamengda nettlesaren sender for kvart tastetrykk i autofullfør-funksjonen til Google-søket går ned frå 800 til 2 bytes (og der blir det gjort mange tastetrykk). John Fallows seier Facebook var svært imponerte då selskapet hans, [Kaazing](http://kaazing.com/), demonstrerte ein WebSocket-versjon av Facebook-chatten, som - til tross for at den var laga på ein god ettermiddag - virka slik chatten til Facebook skulle ha gjort.


<blockquote>Reducing kilobytes of data to 2 bytes… and reducing latency from  150ms to 50ms is far more than marginal. In fact, these two factors  alone are enough to make WebSocket seriously interesting to Google.
Ian Hickson (Google)</blockquote>


Det kan ta tid før alle dei mest populære nettlesarane har innebygd støtte. I dag har Google Chrome, IOS 4 og FireFox 4 Beta støtte for WebSockets, Microsoft er tause. Men eg er overtydd om at mediehusa, finansinstitusjonane og straumleverandørane (straumforbruk i sanntid?) med fleire allereie er i ferd med å pønske ut WebSocket-drivne applikasjonar. Det har allereie kome klientbibliotek for mykje brukte protokollar som  [XMPP](http://en.wikipedia.org/wiki/Extensible_Messaging_and_Presence_Protocol) (instant messaging) og [JMS](http://en.wikipedia.org/wiki/Java_Message_Service) (API for distribusjon av meldingar). JMS vil kunne redefinere omgrepet RSS-feed. Fantasien set grensene.

Nokre døme (merk: du må ha nettlesar som støttar WebSockets):



	
  * Demosida til [Kaazing](http://kaazing.me/) gir eit innsyn i kva som er mulig.

	
  * Fleirbrukar [teiknebrett](http://mrdoob.com/projects/multiuserpad/)


