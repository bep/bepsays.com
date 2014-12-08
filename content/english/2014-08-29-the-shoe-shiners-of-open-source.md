---
date: 2014-08-29 16:52:25+00:00
slug: the-shoe-shiners-of-open-source
title: The shoeshiners of open source
categories:
- English
- Teknologi

MarkdownAngledQuotes: false


---

**The coders of Open Source often do a second shining of their code – and when they do they mark their commit with the word "polish".**

And by "polish" they don’t mean a person from Poland, but: I am not changing any functionality with this commit, but make the code better, prettier, more extensible, less [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) …

<!--more-->


{{< img src="/assets/img/wp-featured/Shoeshine_stand_Southeastern_U.S._by_Walker_Evans_1936.jpg" caption="Shoeshine stand, Southeastern U.S. by Walker Evans,1936" >}}



The listings below are all outputs from the following one liner:

`git log -i --grep=polish --pretty=format:"%an" | sort | uniq -c | sort -nr` 


## Spring Framework
        
        346 Juergen Hoeller
        182 Keith Donald
        168 Sam Brannen
        126 Chris Beams
        110 Rossen Stoyanchev
         67 Phillip Webb
         20 Stephane Nicoll
          8 Thomas Risberg
          7 Arjen Poutsma
          3 Brian Clozel
          3 Andy Clement
          2 Scott Andrews
          2 Rob Winch
          2 Mark Pollack
          1 Vasyl Tretiakov
          1 Costin Leau
          1 Ben Hale
          1 Andy Wilkinson

[Jürgen Höller](https://twitter.com/springjuergen) is topping this list. He is one of the two founders of this [framework](https://github.com/spring-projects/spring-framework), he is the top committer and is renowned for his very high quality software code. And the term [_Jürgenized_](http://olivergierke.de/2013/03/juergenized/) is made in his name:


<blockquote>The process of turning code to solve a problem at hand that might look sufficient at the first glance into rock solid, quality assured, perfectly documented and extensible code. Jürgenization</blockquote>

## Spring Boot
        
        164 Phillip Webb
         10 Christian Dupuis
         10 Andy Wilkinson
          2 Stephane Nicoll
          1 Josh Long
    

[Spring Boot](https://github.com/spring-projects/spring-boot) is a fairly young project. Not surprising to see one of the two project leads, Phillip Webb (940 commits), on top of this list. A little more surprising **not** seeing Dave Syer (1261 commits), the other project lead, on this list.

{{< tweet 505022938156785664 >}}


## Hibernate ORM
          
    3 Sanne Grinovero

Almost no polishing from the [Hibernate](https://github.com/hibernate/hibernate-orm) department.

Seems like this is a Spring thing. Like spring cleaning …
