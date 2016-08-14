---
categories:
- Technology
date: 2016-08-14T12:50:48+02:00
draft: true
tags:
- Go
- Hugo
- Testing
title: Effective testing in Go
---

**Mock at the lowest practical level, if at all, and do not bend them into unit tests when running the entire flow is simple and blistering fast.**
<!--more-->

Those are the two most important lessons I learned while [finishing the multilingual feature in Hugo](https://github.com/spf13/hugo/pull/2303).

Hugo had a fair test line coverage, between 70 and 80 percent, but the tests did not provide enough confidence to support making big structural changes without a fair amount of manual testing.

**And as Hugo has become one of the most popular Go projects on GitHub, people will shout loud if you break the master branch.**

So, adding multiple language support while still keeping full backwards compatibility became more of a testing challenge than anything else.  

## Mock at the lowest practical level
Or do not mock[^mock] at all, if possible, I might add. When unit-testing an isolated component, this can be as simple as passing the data it needs as function arguments.

When testing components that interacts with others, reads and writes to disk or a database, the best solution isn't always obvious.

It is possible to remove the dependencies on file systems and databases by providing test implementations of an interface:

```go
type DataStore interface {
	GetData() string
	SaveData(s string)
}
```

This if fine in many situations.  But reading and writing files is a vital part of Hugo. Removing that from the tests isn't building confidence. 

| File Type | Variants |
| ---|---|
|Content|{{<hf  JSON YAML TOML Blackfriday Asciidoctor reStructuredText HTML >}}
|Config|{{<hf  JSON YAML TOML >}}
|Data|{{<hf  JSON YAML TOML >}}
|Language|{{<hf  JSON YAML >}}
|Layout|{{<hf  Go Ace Amber HTML >}}
|Shortcode|{{<hf  Go Ace Amber HTML >}}

The table above shows the basic file types in Hugo and their variations.

**Add to the mix that Hugo also supports live reloads and partial rebuilds triggered by filesystem events, and that most files can be provided by both the project and the theme, you get a complex test matrix.**

Steve Francia, the founder of Hugo, lay the foundation some time ago with the introduction of [Afero](https://github.com/spf13/afero), a file system abstraction.

But even if now the result files were written to a proper file system and the content could be verified, the source files were not. They were either force-fed into the handler chain by a byte-slice-backed file source, or only tested in isolation.

Now every file operation in Hugo is backed by an Afero file system, and the integration tests are as close to the real deal as practically possible.

And these low-level tests matter. Even the most experienced developer can fail when checking if a [file exists](https://github.com/fsnotify/fsnotify/commit/8611c35ab31c1c28aa903d33cf8b6e44a399b09e#diff-404f64cc5098dd7697665c2cfad57d32L338). This becomes glaringly relevant for applications that is supposed to run on (almost) any platform and operating system.

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

And yes, you will get double-coverage when testing this way. But you will discover corner-cases you never would have thought existed. And the extra tests are cheap.

## Do not force-write unit tests 

Testing things in isolation, proper unit tests, is a good thing when you can do so with ease, and you should build your code with that in mind. The  `JSONParserTest`  should be present.

But when the "unit of test" depends on a chain of preprocessing, going out of the way to run only that small part makes little sense. You'll end up with tests that look like this:

```go
	prepareStep1()
	prepareStep2() 
	runUnit()
```

When you feel the need for a test to verify the test, you have taken a wrong turn. 

But if you have a test setup that allows you to run *the whole thing* really fast, you might as well do that for most tests, and then do the unit testing by narrowing the scope of the test assertions. 

And if you really need to limit what gets run, make it explicit in the production code. One way of doing this is by adding feature flags, as in the `BuildCfg` in Hugo:

```go
type BuildCfg struct {
	//...
	// Skip rendering. Useful for testing.
	SkipRender bool
	//...
}
```

[^mock]: Many people distinguish between a mock and a stub. I don't. See [this discussion](http://stackoverflow.com/questions/2665812/what-is-mocking).
