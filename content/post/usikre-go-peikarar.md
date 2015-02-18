---
categories:
- Teknologi
date: 2015-02-18T08:14:47+01:00
draft: true
tags:
- Go, Golang
title: Usikre peikarar i Go
slug: usikre-go-peikarar
---

**Go, også kjent som Golang, er eit programmeringsspråk laga for fart. Men av og til set det på bremsen, og då _kan_ du ta turen ut i usikkert terreng.**

Eg skriv _kan_ -- dette er ikkje eit råd, men meir eit døme på dei mange fine krinkelkrokane som finst.

Dette skal mellom anna handle om usikre peikarar, eller som det heiter på fint, _unsafe pointers_.

<!--more-->
Kva som gjer dei usikre skal me ta om litt, men først to døme, som, om ein berre ser på signaturen, ser ut til å gjere akkurat det same:

{{< highlight go >}}
func SafeBytesToString(b []byte) string {
	return string(b)
}

func UnsafeBytesToString(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}
{{< / highlight >}}

Begge to tek eit byte-array, `[]byte`, og gir ein `string` i retur. Eg skal prøve å forklare skilnaden seinare -- sjølv om dette kjennest tungt å få gjort på nynorsk -- men først det mest interessante; farten og minnebruken:

_Go_ kjem med ei svært kraftig verktøykasse, som inneheld verktøy for profilering og måling av ytelse.

Gitt desse to referansemålingstestane:

{{< highlight go >}}
func BenchmarkSafeBytesToString(b *testing.B) {
	testBytes := []byte("The quick brown fox jumps over the lazy dog.")

	b.ResetTimer()
	var s string
	for i := 0; i < b.N; i++ {
		s = SafeBytesToString(testBytes)
	}
	s = s[:]
}

func BenchmarkUnsafeBytesToString(b *testing.B) {
	testBytes := []byte("The quick brown fox jumps over the lazy dog.")

	b.ResetTimer()
	var s string
	for i := 0; i < b.N; i++ {
		s = UnsafeBytesToString(testBytes)
	}
	s = s[:]
}
{{< / highlight >}}

Om ein så køyrer desse:

`go test -test.run=NONE -bench=".*" -test.benchmem=true ./unsafestrings`

```
BenchmarkSafeBytesToString   175 ns/op	  48 B/op   1 allocs/op
BenchmarkUnsafeBytesToString 1.70 ns/op	  0 B/op    0 allocs/op
```
Den sikre varianten tek altså 175 nanosekund for kvar strengekonvertering, medan den usikre er knapt målbar med sine 1.70 nanosekund.

**Men det mest interessante her er kanskje at den usikre varianten ikkje tek opp minne**

Dette er minne som må frigjerast etter bruk. _Go_ er -- slik til dømes også Java er det -- utstyrt med ein Garbage Collector (GC), eller søppeltømmar. Denne køyrer ved behov, og om det blir produsert nok søppel, kan det kjennast ut som om programmet stoggar opp ved kvar søppelhenting. 

Dette er sjølvsagt ikkje heldig, og er nok grunnen til at _Go_ ikkje har festa rot hjå spelutviklarane.

Men det finst måtar å redusere behovet for søppelhenting. Ein kan la vere å produsere søppel, eller ein kan drive med gjenbruk. Sjå t.d. `sync.Pool`.

Men om ein skal drive gjenbruk må ein anten vere heilt sikker på at det ein tek i bruk anten ikkje er i bruk av andre, eller, om det framleis er i bruk, er stabilt.

Ein `string` i _Go_ er _immutable_, som er eit fint, engelsk ord for at denne er stabil og kjem ikkje til å endre seg. Skal du endre ein `string` må du lage ein ny. Originalen forblir. No har _Go_ også ein mekanikk dei kallar _slice_, som gjer at ein kan dele opp ein `string` utan å lage ein ny kopi, men det blir litt på sida av denne diskusjonen.

For om me vender attende til dei to funksjonane me starta med; kva skjer om det opphavlege byte-arrayet endrar seg _etter_ at me har gjort det om til ein `string`?

Gitt dei to testane under. Eg kan røpe at dei begge køyrer med grønt lys.

{{< highlight go >}}
var testString = "The quick brown fox jumps over the lazy dog."

func TestSafeBytesToString(t *testing.T) {
	testBytes := []byte(testString)
	s := SafeBytesToString(testBytes)

	if s != testString {
		t.Errorf("Expected '%s' was '%s'", testString, s)
	}

	testBytes[0] = byte('S')

	if s == string(testBytes) {
		t.Errorf("Expected '%s' was '%s'", testBytes, s)
	}

}

func TestUnsafeBytesToString(t *testing.T) {
	testBytes := []byte(testString)
	s := UnsafeBytesToString(testBytes)

	if s != testString {
		t.Errorf("Expected '%s' was '%s'", testString, s)
	}

	testBytes[0] = byte('S')

	if s != string(testBytes) {
		t.Errorf("Expected '%s' was '%s'", testBytes, s)
	}
}
{{< / highlight >}}

Dei ser nesten like ut, utanom det forventa resultatet mot slutten. I den usikre varianten så har har strengen endra seg i takt med det opphavlege byte-arrayet.

Dette kan vere ønskjeleg oppførsel, men om ein får desse strengane frå andre, t.d. som innargument i ein funksjon, er det lett for at greina blir saga under deg utan at du høyrer saga.

Mutable objekt er mellom dei største kjeldene til programvarefeil. Eg kjenner at eg likar det ordet på norsk -- mutabel.

Dette var for å få `[]byte` til `string`, og her må ein ty til `unsafe`-pakken i _Go_ om ein skal unngå å lage ein kopi.

Kor nyttig dette er, ja, det er eit spørsmål som er på sin plass. No kjem ein ofte nok opp i situasjonar der ein har ein `[]byte` og treng ein `string`, men ein har det ikkje så travelt med å få det gjort. Men ettersom `string` er ein slags berre-les-versjon av `[]byte`, kan ein jo spørje seg kvifor smartingane i Google ikkje valde i slå dei samen. `strings`- og `bytes`-pakken er full av funksjonar og metodar som ser nesten like ut, og utan generiske typar blir det mykje kodeduplisering.

No har `strings`-pakken noko som ikkje finst i spegelpakken, som t.d. den lynraske `strings.Replacer`. Som namnet fortel, er denne til for å erstatte deltekstar i ein tekst. Google kan tekstsøk, og denne er rask.

Men om utgangspunktet er `[]byte` går vinninga opp i spinninga om du først må gjere om til ein `string`. 

Skal ein andre vegen, frå `string` til `[]byte`, så finst det eit par søppelfrie vegar i _Go_.
