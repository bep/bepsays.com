---
date: 2017-03-13T13:39:05+01:00
draft: true
title: Descriptor and Adapter Pattern
---

**Unit testing objects with many and complex dependencies: Describe a functional part of it, test the heck out of that descriptor, then create an adapter to pull that into the real object.**

<!--more-->

Using `the `string` type as an Intermediary representation of URLs is a bad idea. You loose lots of the information about how it is built (what is the file suffix?), and it is hard to say which state it is in (has it  been URL-endocded? Let us do it just in case...).

