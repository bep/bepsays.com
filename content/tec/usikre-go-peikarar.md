---
categories:
- Teknologi
date: 2015-02-18T08:14:47+01:00
lastmod: 2016-10-12T08:14:47+01:00
tags:
- Go
title: Usikre peikarar i Go
slug: usikre-go-peikarar
images:
- /assets/img/2014/Golang.png
---

**Go, eller Golang, er programmeringsspråka sin Ferrari. Men også her finst det ein brems, og då _kan_ du ta turen ut i usikkert terreng.**

Eg skriv _kan_ -- dette er ikkje eit råd. Dette er meir eit døme på dei mange fine krinkelkrokane som finst i _Go_-landskapet.

Dette skal mellom anna handle om usikre peikarar, eller som det heiter på fint, _unsafe pointers_.

<!--more-->

{{< img src="/assets/img/2014/Golang.png" class="small" caption="Golang-logoen. Utforming: Renée French" >}}

## Sikker og usikker

Kva som gjer dei usikre skal me ta om litt, men først to døme, som, om ein berre ser på signaturen, ser ut til å gjere akkurat det same:

``` go
func SafeBytesToString(b []byte) string {
	return string(b)
}

func UnsafeBytesToString(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}
```

Begge tek ein byte-slice, `[]byte`, og gir ein `string` i retur. No gir eg ingen garanti for at den usikre varianten virkar i alle _Go_-kompilatorane -- og eg skal prøve å forklare skilnaden seinare, sjølv om det kjennest tungt å formulere på nynorsk. Men først det mest interessante; farten og minnebruken:

_Go_ kjem med ei svært kraftig verktøykasse, som inneheld verktøy for profilering og måling av fart.

Gitt desse to referansemålingane:

``` go
func BenchmarkSafeBytesToString(b *testing.B) {
	var (
		bt = []byte("The quick brown fox jumps over the lazy dog.")
		s  string
	)

	for i := 0; i < b.N; i++ {
		s = SafeBytesToString(bt)
	}

	s = s[:]
}

func BenchmarkUnsafeBytesToString(b *testing.B) {
	var (
		bt = []byte("The quick brown fox jumps over the lazy dog.")
		s  string
	)

	for i := 0; i < b.N; i++ {
		s = UnsafeBytesToString(bt)
	}

	s = s[:]
}
```

Om ein så køyrer desse:

`go test -test.run=NONE -bench=".*" -test.benchmem=true ./unsafestrings`

```bash
BenchmarkSafeBytesToString-4  30000000  47.7 ns/op  48 B/op	  1 allocs/op
BenchmarkUnsafeBytesToString-4   2000000000  1.04 ns/op  0 B/op	  0 allocs/op
```
Den sikre varianten tek 48 nanosekund for kvar strengekonvertering, medan den usikre er knapt målbar med sine 1 nanosekund.

**Men det mest interessante her er nullane i den usikre varianten. Null i minneforbruk.**

## Søppeltømming

Dette er minne som må frigjerast etter bruk. _Go_ er -- slik til dømes også Java er det -- utstyrt med ein _Garbage Collector (GC)_, eller søppeltømmar. Denne køyrer ved behov, og om det blir produsert nok søppel, kan det kjennast ut som om programmet stoggar opp ved kvar søppelhenting. 

Dette er nok grunnen til at _Go_ ikkje har slege rot hjå spelutviklarane. I dei fleste andre samanhengar er dette mest av det gode.

Men det finst måtar å redusere behovet for søppelhenting. Ein kan la vere å produsere søppel, eller ein kan drive med gjenbruk.

Men om ein skal drive gjenbruk må ein anten vere heilt sikker på at det ein tek i bruk anten ikkje er i bruk av andre, eller, om det framleis er i bruk, er stabilt.

## Omskiftelege objekt 

Ein `string` i _Go_ er _immutable_, som er eit fint, engelsk ord for at han er uomskifteleg -- han kjem ikkje til å endre seg. Skal du endre ein `string` må du lage ein ny. Originalen er som før. 

Om me vender attende til dei to funksjonane me starta med; kva skjer om den opphavlege byte-slicen endrar seg _etter_ at me har gjort han om til ein `string`?

Sjå på dei to testane under. Eg kan røpe at dei begge køyrer med grønt lys.

``` go
var testString = "The quick brown fox jumps over the lazy dog."

func TestSafeBytesToString(t *testing.T) {
	var (
		b = []byte(testString)
		s = SafeBytesToString(b)
	)

	if s != testString {
		t.Errorf("Expected '%s' was '%s'", testString, s)
	}

	b[0] = byte('S')

	if s == string(b) {
		t.Errorf("Expected '%s' was '%s'", b, s)
	}
}

func TestUnsafeBytesToString(t *testing.T) {
	var (
		b = []byte(testString)
		s = UnsafeBytesToString(b)
	)

	if s != testString {
		t.Errorf("Expected '%s' was '%s'", testString, s)
	}

	b[0] = byte('S')

	if s != string(b) {
		t.Errorf("Expected '%s' was '%s'", b, s)
		t.Errorf("Expected '%s' was '%s'", b, s)
	}
}
```

Dei ser nesten like ut, utanom det forventa resultatet mot slutten. I den usikre varianten har har strengen endra seg i takt med den opphavlege byte-slicen.

Dette kan vere ønskjeleg, men om ein får desse strengane frå andre, t.d. som innargument i ein funksjon, er det lett for at greina blir saga i to under deg utan at du høyrer saga.

**Omskiftelege objekt er mellom dei største kjeldene til programvarefeil.**

## Søk og erstatt

No er kanskje ikkje dette den mest matnyttige kunnskapen. Ein kjem ofte nok opp i situasjonar der ein har ein `[]byte` og treng ein `string`, men ein har det kanskje ikkje så travelt med å få det gjort, og minne er det nok av. Men ettersom `string` er ein slags berre-les-versjon av `[]byte`, kan ein jo spørje seg kvifor smartingane i Google ikkje valde i slå dei samen. `strings`- og `bytes`-pakken er full av funksjonar og metodar som ser nesten like ut, og utan generiske typar blir det mykje kodeduplisering.

No har `strings`-pakken noko som ikkje finst i spegelpakken, som t.d. den lynraske `strings.Replacer`. Som namnet fortel, er denne til for å erstatte deltekstar i ein større tekst. I Google _kan_ dei tekstsøk, og denne er rask. Eg har sjølv  [etterlyst](https://github.com/golang/go/issues/9905) ein `bytes`-versjon, men i mellomtida er det `strings`-pakken som er gjeldande.

Men om utgangspunktet er `[]byte` går vinninga lett opp i spinninga om du først må kopiere over i ein `string`:

``` go
type appendSliceWriter []byte

func (w *appendSliceWriter) Write(p []byte) (int, error) {
	*w = append(*w, p...)
	return len(p), nil
}

func (w *appendSliceWriter) WriteString(s string) (int, error) {
	*w = append(*w, s...)
	return len(s), nil
}

func BenchmarkUnsafeStringsReplacer(b *testing.B) {
	var (
		by = []byte("The quick brown fox jumps over the lazy dog.")
		re = strings.NewReplacer("quick", "slow", "brown", "blue", "lazy", "energetic")
	)

	buf := make(appendSliceWriter, 0, len(by))

	for i := 0; i < b.N; i++ {
		re.WriteString(&buf, UnsafeBytesToString(by))
		if UnsafeBytesToString(buf) !=
			"The slow blue fox jumps over the energetic dog." {
			b.Fatalf("Failed replacement")
		}
		buf = buf[:0] // reuse
	}
}

func BenchmarkSafeStringsReplacer(b *testing.B) {
	var (
		by = []byte("The quick brown fox jumps over the lazy dog.")
		re = strings.NewReplacer("quick", "slow", "brown", "blue", "lazy", "energetic")
	)

	buf := make(appendSliceWriter, 0, len(by))

	for i := 0; i < b.N; i++ {

		re.WriteString(&buf, SafeBytesToString(by))
		if UnsafeBytesToString(buf) !=
			"The slow blue fox jumps over the energetic dog." {
			b.Fatalf("Failed replacement")
		}
		buf = buf[:0]
	}
}

func BenchmarkMultipleBytesReplace(b *testing.B) {
	by := []byte("The quick brown fox jumps over the lazy dog.")

	for i := 0; i < b.N; i++ {
		var replaced []byte

		replaced = bytes.Replace(by, []byte("quick"), []byte("slow"), -1)
		replaced = bytes.Replace(replaced, []byte("brown"), []byte("blue"), -1)
		replaced = bytes.Replace(replaced, []byte("lazy"), []byte("energetic"), -1)

		if UnsafeBytesToString(replaced) != "The slow blue fox jumps over the energetic dog." {
			b.Fatalf("Failed replacement")
		}
	}
}

func BenchmarkMultiplesStringsReplace(b *testing.B) {
	s := "The quick brown fox jumps over the lazy dog."

	for i := 0; i < b.N; i++ {
		var replaced string

		replaced = strings.Replace(s, "quick", "slow", -1)
		replaced = strings.Replace(replaced, "brown", "blue", -1)
		replaced = strings.Replace(replaced, "lazy", "energetic", -1)

		if replaced != "The slow blue fox jumps over the energetic dog." {
			b.Fatalf("Failed replacement")
		}
	}
}
```

No gir ikkje dette det heilt store utslaget, men dette er meir merkbart med større tekstmengder:

```bash
BenchmarkUnsafeStringsReplacer-4  5000000  247 ns/op  0 B/op  0 allocs/op
BenchmarkSafeStringsReplacer-4   5000000  294 ns/op  48 B/op  1 allocs/op
```

Dømet over syner også fram to andre finurlege eigenskapar ved _Go_: Grensesnitt-oppgradering og at `append(bytesBuff, aString...)` er "gratis" på minnefronten.

* `replacer.WriteString` tek ein `io.Writer`, men internt blir det oppgradert til eit `stringWriterIface` om også  `WriteString(s string)` er implementert.
* `appendSliceWriter.WriteString(s string)` utnyttar eit spesialtilfelle i _Go_:

For dei to referansemålingane under:

``` go
func BenchmarkAppendString(b *testing.B) {
	var (
		buf  = make([]byte, 0, 100)
		buf2 []byte
		s    = "bepsays"
	)

	for i := 0; i < b.N; i++ {
		buf2 = append(buf, s...)
	}
	buf2 = buf2[:]
}

func BenchmarkAppendByteString(b *testing.B) {
	var (
		buf  = make([]byte, 0, 100)
		buf2 []byte
		s    = "bepsays"
	)

	for i := 0; i < b.N; i++ {
		buf2 = append(buf, []byte(s)...)
	}
	buf2 = buf2[:]
}
```

Her er kanskje resultatet overraskande:

```bash
BenchmarkAppendString-4  500000000  3.09 ns/op   0 B/op   0 allocs/op
BenchmarkAppendByteString-4   100000000  13.0 ns/op  0 B/op  0 allocs/op
```

Men denne konstruksjonen har folka bak _Go_ tenkt at denne, ja denne er så vanleg, at denne får spesialhandsaming.

No finst også både enkelterstatningsfunksjonane `bytes.Replace` og `strings.Replace`:

``` go
func BenchmarkMultipleBytesReplace(b *testing.B) {
	by := []byte("The quick brown fox jumps over the lazy dog.")

	for i := 0; i < b.N; i++ {
		var replaced []byte

		replaced = bytes.Replace(by, []byte("quick"), []byte("slow"), -1)
		replaced = bytes.Replace(replaced, []byte("brown"), []byte("blue"), -1)
		replaced = bytes.Replace(replaced, []byte("lazy"), []byte("energetic"), -1)

		if UnsafeBytesToString(replaced) != "The slow blue fox jumps over the energetic dog." {
			b.Fatalf("Failed replacement")
		}
	}
}

func BenchmarkMultiplesStringsReplace(b *testing.B) {
	s := "The quick brown fox jumps over the lazy dog."

	for i := 0; i < b.N; i++ {
		var replaced string

		replaced = strings.Replace(s, "quick", "slow", -1)
		replaced = strings.Replace(replaced, "brown", "blue", -1)
		replaced = strings.Replace(replaced, "lazy", "energetic", -1)

		if replaced != "The slow blue fox jumps over the energetic dog." {
			b.Fatalf("Failed replacement")
		}
	}
}
```

Men desse er monaleg treigare enn `strings.Replacer`:

```bash
BenchmarkUnsafeStringsReplacer-4  5000000  247 ns/op  0 B/op  0 allocs/op
BenchmarkSafeStringsReplacer-4  5000000  294 ns/op  48 B/op  1 allocs/op
BenchmarkMultipleBytesReplace-4  3000000  412 ns/op  144 B/op  3 allocs/op
BenchmarkMultiplesStringsReplace-4  2000000  648 ns/op  288 B/op	       6 allocs/op
```
*Alle testane over er køyrt på Go 1.7.1 på ein MacBook 2.7 i5 med to kjerner. Køyrbare versjonar av kodedøma over finn du [her](https://github.com/bep/gosandbox/tree/master/unsafestrings).*
