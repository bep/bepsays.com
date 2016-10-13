---
date: 2014-06-23 16:32:25+00:00
slug: the-legacy-of-date-and-time
title: The legacy of date and time
title_main: |
            The legacy of  
            date and time
categories:
- English
- Teknologi
blackfriday:
  angledQuotes: false

---

**[The JSR 310](https://today.java.net/pub/a/today/2008/09/18/jsr-310-new-java-date-time-api.html) gave JDK 8 a new and long awaited new design of date and time in Java. But since the old classes that has been trying to do the same are still in wide spread use, handling of these vital value types will suffer from the legacy in the next decade or so.**

So the creators of the new API decided they needed to bridge the old and the new. The code snippet below is borrowed from [Oracle's JDK 8.](http://docs.oracle.com/javase/8/docs/api/java/sql/Timestamp.html#valueOf-java.time.LocalDateTime-) It converts a java.time.LocalDateTime  to a java.sql.Timestamp (the latter is used to persist timestamps to the database through JDBC):

<!--more-->

``` java    
@SuppressWarnings("deprecation")
public static Timestamp valueOf(LocalDateTime dateTime) {
    return new Timestamp(dateTime.getYear() - 1900,
            dateTime.getMonthValue() - 1,
            dateTime.getDayOfMonth(),
            dateTime.getHour(),
            dateTime.getMinute(),
            dateTime.getSecond(),
            dateTime.getNano());
}

```


java.sql.Timestamp extends java.util.Date, but they are very different, a _Timestamp_ is **not** a _Date_. But then java.util.Date isn't really a date, either, but an instant in time ([Epoch time](http://en.wikipedia.org/wiki/Unix_time), number of milliseconds since Thursday, January 1 1970).

Most of the new [value types](http://blog.joda.org/2014/03/valjos-value-java-objects.html) (being a value type implies that they, among other characteristics, are immutable) involve some kind of zoning context (a time-zone or an offset). A java.util.Date can be converted to a java.time.Instant (java.util.Date#toInstant()) – but how about a _LocalDateTime_ to a _Timestam_ as showed in the method above, introduced in JDK 8.


## To be deprecated


This method shows some peculiar stuff: the old API's choice of 1900 as the magic starting year and the 0-indexed values for months (January is month 0). And it uses a constructor that has been deprecated since 1998 (since [JDK 1.2](http://en.wikipedia.org/wiki/Java_version_history)). In most other software systems _deprecated_ means _there are now better ways to do this_ and this will be removed in the next major version. For Java it means that it will **never** be removed. The [license](http://www.oracle.com/technetwork/java/javase/downloads/jdk-6u21-license-159167.txt) says that this software _is not designed or intended for use in the design, construction, operation or maintenance of any nuclear facility_, but it is still used in important enough places that they will not remove anything from the public APIs.

Looking at the JavaDoc for [java.util.Date,](http://docs.oracle.com/javase/8/docs/api/) with the myriads of methods deprecated in JDK 1.1 (1997) – one can imagine the Sun designers kicking themselves in the legs when realizing the blunder. _And they can never remove it._ You are even free to _change the state_ after creation!

{{< img src="/assets/img/wp/java.util_.Date_.png" class="alignnone" caption="Deprecated methods in java.util.Date." >}}

The JavaDoc of [java.time.LocalDateTime](http://docs.oracle.com/javase/8/docs/api/java/time/LocalDateTime.html) says:


<blockquote>This class does not store or represent a time-zone. Instead, it is a description of the date, as used for birthdays, combined with the local time as seen on a wall clock. It cannot represent an instant on the time-line without additional information such as an offset or time-zone.</blockquote>


## In the zone


Offset is offset in (usually) whole hours from Greenwich/UTC. Different time-zones can share the same offset, but have different rules for daylight saving time. So if I create an instance of java.time.LocalDateTime on my computer, with it's default time-zone set at _Europe/Oslo_, it will print the same as it would when created on a computer in Beijing. But what do I get when converting it to a _Timestamp?_

``` java    
    
ZoneId systemZone = ZoneId.systemDefault();
out.println(systemZone);
// => Europe/Oslo

LocalDateTime dateTime = LocalDateTime.of(1970, Month.JANUARY, 1, 0, 0);
out.println(dateTime);
// => 1970-01-01T00:00

Timestamp timestamp1 = Timestamp.valueOf(dateTime);
out.println(timestamp1.getTime());
// ==> -3600000 ( -1 hour)

ZonedDateTime zonedDateTime = ZonedDateTime.of(dateTime, ZoneOffset.UTC);
out.println(zonedDateTime);
// => 1970-01-01T00:00Z

Timestamp timestamp2 = Timestamp.from(zonedDateTime.toInstant());
out.println(timestamp2.getTime());
// ==> 0

```    
    


I guess this behavior makes some sense if you think long and hard about it, but there are some food for thought in here:


* Conversion from _LocalDateTime_ to a _Timestamp_ uses the system's time zone to do the conversion. One might think that LocalDateTime.of(1970, Month.JANUARY, 1, 0, 0) would give Epoch zero, but that is not the case (Oslo is UTC+1 and daylight saving time was not enabled in January 1970). Interestingly enough, _java.util.Date_ does not provide a conversion method from _LocalDateTime_.

* Use [ZonedDateTime](http://docs.oracle.com/javase/8/docs/api/java/time/ZonedDateTime.html) in stead of _LocalDateTime_ when control over the zoning context is important.


