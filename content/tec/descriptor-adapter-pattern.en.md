---
date: 2017-03-13T13:39:05+01:00
draft: true
title: Descriptor and Adapter Pattern
---

**Unit testing objects with many and complex dependencies: Describe a functional part of it, test the heck out of that descriptor, then create an adapter to pull that into the real object.**

<!--more-->

This pattern sprung out from the need to consolidate the URL and path handling in [Hugo](https://gohugo.io). When you reach 16K stars on GitHub and a lot of people start to use it on a lot of different platforms in any thinkable configuration, subtle bugs gets very visible. And while this worked great when Hugo was a simple HTML static site generator with RSS added as a bonus, making it work for all media types (aka MIME types) in a general and fully configurable way -- the `if filename == "index.html"` constructs had to go.

I had wanted to do this in Hugo earlier, but it seemed like such a daunting task. 

Using `the `string` type as an Intermediary representation of URLs is a bad idea. You loose lots of the information about how it is built (what is the file suffix?), and it is hard to say which state it is in (has it  been URL-endocded? Let us do it just in case...).

