---

date: 2016-10-12T12:14:47+01:00
lastmod: 2016-10-12T12:14:47+01:00
draft: true
tags:
- Go
title: Unsafe Go Strings
slug: unsafe-go-strings
images:
- /assets/img/2014/Golang.png
---

**Go is the Ferrari of the programming languages. But there are occasional friction that may lure you into unsafe terrain.**

<!--more-->

With emphasis on *may*. This is not an advice, but more a demonstration of some of the interesting dark alleys in Go.


{{< img src="/assets/img/2014/Golang.png" class="small" caption="The Go Gopher. Design: Renée French" >}}

## Safe and Unsafe

Two examples which, looking at the signature, seems to do the same:

``` go
func SafeBytesToString(b []byte) string {
	return string(b)
}

func UnsafeBytesToString(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}
```
Both take a byte-slice, `[]byte`, and return a `string`.

Given these benchmarks:

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

And run these with:

`go test -test.run=NONE -bench=".*" -test.benchmem=true ./unsafestrings`

```bash
BenchmarkSafeBytesToString-4  30000000  47.7 ns/op  48 B/op	  1 allocs/op
BenchmarkUnsafeBytesToString-4   2000000000  1.04 ns/op  0 B/op	  0 allocs/op
```
The unsafe variant is blistering fast -- and no memory allocation!

## Bytes are Changing

`unsafe.Pointer` lives in the package with a name that smells danger. You are on your own and without seat belts: Behaviour may change from Go version to the next and there are no guarantees that it behaves the same on the different platform.

But it is tempting in some rare cases to get rid of those memory allocations and reduce garbage collection.

A regular `string` (`s := "Hello World!"`) in Go is immutable -- it will never change. If we revisit to the two functions that started this: What happens if the original byte slice changes after it is converted to a string?

Look at the two tests below. Both of them runs without error.

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
		t.Errorf("Expected '%s' was '%s'", string(b), s)
	}
}
```

The *unsafe string* has changed in line with the byte slice.

This is fine if that is what you want and you know about it, but it can be a major surprise if you don't.

**Mutable objects are a big contributor in the bug department.**

## Search and Replace

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
