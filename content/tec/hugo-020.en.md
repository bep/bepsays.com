---
date: 2017-04-10T09:19:38+01:00
title: "Hugo 0.20 Released: Custom Output Formats!"
title_main: |
   Hugo 0.20 Released:
   **Custom Output Formats!**
slug: hugo-20
images:
- /assets/img/hugo.png
---
**More than 180 contributions by over 30 contributors in six weeks is impressive! The new Hugo 0.20 paves the way for JSON search indexes, calendars, e-books, Facebook Instant Articles, Google AMP…**

<!--more-->

Grab the binary of your choice [here](https://github.com/spf13/hugo/releases/tag/v0.20).


## Release Notes

Hugo `0.20` introduces the powerful and long sought after feature [Custom Output Formats](https://gohugo.io/extras/output-formats/); Hugo isn't just that "static HTML with an added RSS feed" anymore. *Say hello* to calendars, e-book formats, Google AMP, and JSON search indexes, to name a few ({{< gh 2828 >}}).

This release represents **over 180 contributions by over 30 contributors** to the main Hugo code base. Since last release Hugo has **gained 1100 stars, 20 new contributors and 5 additional themes.**

Hugo now has:

- 16300+ stars
- 495+ contributors
- 156+ themes

{{< gh "@bep" >}} still leads the Hugo development with his witty Norwegian humor, and once again contributed a significant amount of additions. Also a big shoutout to {{< gh "@digitalcraftsman" >}} for his relentless work on keeping the documentation and the themes site in pristine condition, and {{< gh "@moorereason" >}} and {{< gh "@bogem" >}} for their ongoing contributions.

{{< img src="/assets/img/hugo.png" class="small" >}}


## Other Highlights

{{< gh "@bogem" >}} has also contributed TOML as an alternative and much simpler format for language/i18n files ({{< gh 3200 >}}). A feature you will appreciate when you start to work on larger translations.

Also, there have been some important updates in the Emacs Org-mode handling: {{< gh "@chaseadamsio" >}} has fixed the newline-handling ({{< gh 3126 >}}) and {{< gh "@clockoon" >}}  has added basic footnote support.

Worth mentioning is also the ongoing work that {{< gh "@rdwatters" >}} and {{< gh "@budparr" >}} is doing to re-do the [gohugo.io](https://gohugo.io/) site, including a total restructuring and partial rewrite of the documentation. It is getting close to finished, and it looks fantastic!

## Notes
* `RSS` description in the built-in template is changed from full `.Content` to `.Summary`. This is a somewhat breaking change, but is what most people expect from their RSS feeds. If you want full content, please provide your own RSS template.
* The deprecated `.RSSlink` is now removed. Use `.RSSLink`.
* `RSSUri` is deprecated and will be removed in a future Hugo version, replace it with an output format definition.
* The deprecated `.Site.GetParam` is now removed, use `.Site.Param`.
* Hugo does no longer append missing trailing slash to `baseURL` set as a command line parameter, making it consistent with how it behaves from site config. {{< gh 3262 >}}

## Enhancements

* Hugo `0.20` is built with Go 1.8.1.
* Add `.Site.Params.mainSections` that defaults to the section with the most pages. Plan is to get themes to use this instead of the hardcoded `blog` in `where` clauses.  {{< gh 3206 >}}
* File extension is now configurable. {{< gh 320 >}}
* Impove `markdownify` template function performance. {{< gh 3292 >}}
* Add taxonomy terms' pages to `.Data.Pages` {{< gh 2826 >}}
* Change `RSS` description from full `.Content` to `.Summary`.
* Ignore "." dirs in `hugo --cleanDestinationDir` {{< gh 3202 >}}
* Allow `jekyll import` to accept both `2006-01-02` and `2006-1-2` date format {{< gh 2738 >}}
* Raise the default `rssLimit` {{< gh 3145 >}}
* Unify section list vs single template lookup order {{< gh 3116 >}}
* Allow `apply` to be used with the built-in Go template funcs `print`, `printf` and `println`. {{< gh 3139 >}}

## Fixes
* Fix deadlock in `getJSON` {{< gh 3211 >}}
* Make sure empty terms pages are created. {{< gh 2977 >}}
* Fix base template lookup order for sections {{< gh 2995 >}}
* `URL` fixes:
    * Fix pagination URLs with `baseURL` with sub-root and `canonifyUrls=false` {{< gh 1252 >}}
    * Fix pagination URL for resources with "." in name {{< gh 2110 >}} {{< gh 2374 >}} {{< gh 1885 >}}
    * Handle taxonomy names with period {{< gh 3169 >}}
    * Handle `uglyURLs` ambiguity in `Permalink` {{< gh 3102 >}}
    * Fix `Permalink` for language-roots wrong when `uglyURLs` is `true` {{< gh 3179 >}}
    * Fix misc case issues for `URLs` {{< gh 1641 >}}
    * Fix for taxonomies URLs when `uglyUrls=true` {{< gh 1989 >}}
    * Fix empty `RSSLink` for list pages with content page. {{< gh 3131 >}}
* Correctly identify regular pages on the form "my_index_page.md" {{< gh 3234 >}}
*  `Exit -1` on `ERROR` in global logger {{< gh 3239 >}}
* Document hugo `help command` {{< gh 2349 >}}
* Fix internal `Hugo` version handling for bug fix releases. {{< gh 3025 >}}
* Only return `RSSLink` for pages that actually have a RSS feed. {{< gh 1302 >}}

