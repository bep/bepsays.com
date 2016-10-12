---
categories:
- Technology
date: 2016-10-12T12:50:48+02:00
tags:
- Go
- Hugo
title: Pragmatic and Effective Testing in Go
stub: pragmatic-and-effective-testing-in-go
images:
- /assets/img/2016/gophers-keyboard.jpg
---

**Stub at the lowest practical level, if at all, and do not bend tests into unit tests when running the entire flow is simple and blistering fast.**

<!--more-->

{{< img src="/assets/img/2016/gophers-keyboard.jpg" caption="Gophers on screen." class="small" >}}

And if *running the entire flow isn't both simple and fast*: Make it!

[Hugo](http://gohugo.io/), the popular static site generator, was released in [version 0.17](https://github.com/spf13/hugo/releases/tag/v0.172) Friday. And while the most eye-catching news in this release was the impressive improvement in speed in an already very speedy piece of software, the big new functional feature was native [multilingual support](https://github.com/spf13/hugo/pull/2303).

I wrote the main bulk of the code in this release, too, and adding support for multiple languages was more or less a "core Hugo" rewrite.  

Hugo already had a fair test line coverage, between 70 and 80 percent, but the tests did not provide enough confidence to support making big structural changes without a fair amount of manual testing.

**And as Hugo has become one of the [most popular Go projects on GitHub](https://github.com/trending?l=go), people will scream if you break the master branch.**

Keeping full backwards compatibility became more of a testing challenge than anything else.  

This article is about the main lessons learned.

## Stub at the lowest practical level

Or do not stub[^stub] at all, if possible, I might add. When unit-testing an isolated component, this can be as simple as passing the data it needs as function arguments.

When testing components that read from and write to disk or a database, the best solution isn't always obvious.

It is possible to remove the dependencies on file systems and databases by providing test implementations of high level interfaces interface such as `SomeDataStore`.

This if fine in many situations.  But file IO is a vital part of Hugo:

| File Type | Variants |
| ---|---|
|Content|{{<hf  JSON YAML TOML Blackfriday Asciidoctor reStructuredText HTML >}}
|Config|{{<hf  JSON YAML TOML >}}
|Data|{{<hf  JSON YAML TOML >}}
|Language|{{<hf  JSON YAML >}}
|Layout|{{<hf  Go Ace Amber HTML >}}
|Shortcode|{{<hf  Go Ace Amber HTML >}}

The table above shows the basic file types in Hugo and their variations.

**Add to the mix that Hugo also supports live reloads and partial rebuilds triggered by filesystem events on a variety of platforms, and that most files can be provided by both the project and the theme, you get a massive test matrix.**

Steve Francia, the founder of Hugo, lay the foundation some time ago with the introduction of [Afero](https://github.com/spf13/afero), a file system abstraction.

But even if now the result files were written to a proper file system and the content could be verified, the source files were not. They were either force-fed into the handler chain by a byte-slice-backed file source, or only tested in isolation.

Now every file operation in Hugo is backed by a virtual file system, and the integration tests are as close to the real deal as practically possible.

And these low-level tests matter. Even the most experienced developer can fail when checking if a [file exists](https://github.com/fsnotify/fsnotify/commit/8611c35ab31c1c28aa903d33cf8b6e44a399b09e#diff-404f64cc5098dd7697665c2cfad57d32L338). This becomes glaringly relevant for applications that are supposed to run on (almost) any platform and operating system.

## Nest Table-Driven Tests

And when building "the whole thing" is as cheap as a couple of milliseconds, you might as well do so many times, as in the example below for every configuration format:

```go
func TestMultiSitesBuild(t *testing.T) {
	for _, config := range []struct {
		content string
		suffix  string
	}{
		{multiSiteTOMLConfig, "toml"},
		{multiSiteYAMLConfig, "yml"},
		{multiSiteJSONConfig, "json"},
	} {
		doTestMultiSitesBuild(t, config.content, config.suffix)
	}
}
```
Table-driven tests are encouraged and easy to write in Go. Exponentially adding more test-variants by nesting the loops can be very powerful, and a practical way to approach the test matrix outlined above. 

You will get tests that overlap. But you will discover corner-cases you never would have thought existed.  And the superfluous tests are cheap.

## Do not force-write unit tests 

Testing in isolation, proper unit tests, is a good thing when you can do so with ease, and you should build your code with that in mind. 

But when the "unit of test" depends on a chain of preprocessing, going out of the way to run only that small part makes little sense. You'll end up with tests that depends on a not-so-realistic synthetic data set or tests that look like this:

```go
	prepareStep1()
	prepareStep2() 
	runUnit()
```

When you need a test to verify the test, you have taken a wrong turn. 

If you have a test setup that allows you to run *the whole thing* really fast, you might as well do that for most tests, and then verify the unit by narrowing the scope of the assertions. 

And if you really need to limit what gets run, make it explicit in the production code. One way of doing this is by adding feature flags, as in the `BuildCfg` in Hugo:

```go
type BuildCfg struct {
	//...
	// Skip the rendering. Useful in tests.
	SkipRender bool
	//...
}
```

[^stub]: For a discussion about mocks vs stubs, see [Martin Fowlers's Mocks Aren't Stubs](http://martinfowler.com/articles/mocksArentStubs.html)
