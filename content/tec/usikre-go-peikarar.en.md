---

date: 2016-10-14T12:14:47+01:00
lastmod: 2016-10-14T12:14:47+01:00
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

With emphasis on *may*. This is not an advice, but more a demonstration of some of the interesting dark alleys in Go City.


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
The unsafe variant is fast as lightning -- and no memory allocation!

## Bytes are Changing

`unsafe.Pointer` lives in the package that spells danger. You are on your own without seat belts: Behaviour may change from Go version to the next and there are no guarantees that it behaves the same on different platforms.

But it is tempting in some rare cases to get rid of those memory allocations and reduce garbage collection.

A regular `string` (`s := "Hello World!"`) in Go is immutable -- it will never change. If we revisit the two functions earlier: What happens if the original byte slice changes?

Both tests run without error:

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

This is fine if this is what you want and expect, but it can be a major surprise if you don't.

**Mutable objects are a big contributor in the bug department.**

## Search and Replace

I will leave it up to the reader to find practical use cases for this, but I will spend some time investigating *text search and replace*, a common problem.

In the Go stdlib there are both a `strings` and a `bytes` package. That there is two packages that seems to be mostly duplicates was probably a mistake by the Go language designers, but that is another and bigger dicsussion. 

There is, however, one nice feature in `strings` that does not exist in the `bytes` mirror: The `strings.Replacer`. 

I created the GitHub issue [bytes: add Replacer](https://github.com/golang/go/issues/9905) last winter, and while it got several "I want this" and "we should do this" from core Go people, it eventually got rejected -- because doing it the effective way, by changing the input byte slice, would make it different from the `strings` alternative.

That is a petty, because `strings.Replacer` is really fast and really useful.

And when using the `strings` version for `byte` slices, the win and loss evens out:

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

Running the benchmarks above:

```bash
BenchmarkUnsafeStringsReplacer-4  5000000  254 ns/op  0 B/op  0 allocs/op
BenchmarkSafeStringsReplacer-4  5000000  290 ns/op  48 B/op  1 allocs/op
BenchmarkMultipleBytesReplace-4  3000000  407 ns/op  144 B/op  3 allocs/op
BenchmarkMultiplesStringsReplace-4  2000000  637 ns/op  288 B/op  6 allocs/op
```

The above tries to demonstrate using the `strings.Replace` for `byte` slices both in a safe and unsafe way, and then doing the same replacements with the `bytes.Replace` and `strings.Replace` functions.

The numbers speak for themselves, but `strings.Replace` is very effective when you have a fixed set of replacements and If you really care about memory allocations, using it for `byte` slices may be an option.

The example above also show two peculiar features in Go: interface-upgrades and the fact that `append(bytesBuff, aString...)` is "free" in the memory department:

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
