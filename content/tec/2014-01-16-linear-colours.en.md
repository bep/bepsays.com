---
date: 2014-01-16 13:11:45+00:00
slug: linear-colours
title: Linear colour scheme with LESS
title_main: |
            Linear colour scheme  
            **with LESS**
blackfriday:
  angledQuotes: false
---

**Make content boxes with a linear colour scheme using a LESS loop.**

{{< img src="/assets/img/wp-featured/bepsays-gradient-boxes-1024x448.png" caption="Linear colour scheme by LESS" >}}

<!--more-->

Beauty is in the eye of the beholder, but I think it looks nice (if I have not changed the front page design of this site, go ahead and take a look). The colours are all generated in a [LESS](http://www.lesscss.org/) loop. In the code snippet below I started out with a colour (_#CC66FF_), then tested with different values until I got something that looked good.

_The LESS snippet below explained:_



	
  * @no-main-boxes: 6; - Number of iterations (boxes)

	
  * .bs-main-box-@{index} - Will create CSS classes _.bs-main-box-1, .bs-main-box-2_ ... _.bs-main-box-6_

	
  * The styling is performed in the mixin .bs-main-box-style(@index)    

``` css

.bs-main-box-style(@index) {
    @color: desaturate(spin(lighten(#CC66FF, 28%), @index * 40), (@index * 5));

    background-color: @color;
    .bs-title-icon {
      color: darken(@color, 20%);
    }
    border: 1px solid darken(@color, 4%);
  }

  @no-main-boxes: 6;

  .loop (@index) when (@index > 0) {

    .bs-main-box-@{index} {
      .bs-main-box-style(@index);
    }

    .loop(@index - 1);
  }

  .loop (@no-main-boxes);


```



