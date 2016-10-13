---

date: 2016-01-23T11:40:13+01:00
markdown:
  angledQuotes: false
tags:
- Javascript
- ReactJS
title: Abstract ReactJS components
slug: reactjs-template-methods
---
**If you look for a clean and simple alternative to mixins for ReactiveJS ES6 components, read this.** 
<!--more-->

Mixins was	 a way of implementing cross-cutting concerns in a DRY way with the old-style ReactJS components, a way to hook into your components' life cycle.

In ReactJS components written using ES6 -- or ECMAScript 6 -- styled Javascript, the [next version of Javascript](es6-features.org//), mixins are no longer an option.

There are workarounds to be found on the net, some more complex than [others](https://medium.com/@dan_abramov/mixins-are-dead-long-live-higher-order-components-94a0d2f9e750#.hfhzkwfec). 

But in simple use cases an abstract base class seems to be a good fit. But does it work? The [class specification](http://www.2ality.com/2015/02/es6-classes-final.html) may shine some light on it, but it isn't apparent.

So I tried it:

```javascript
class Base extends React.Component {

    constructor() {
        super();
        if (this.doComponentDidMount === undefined) {
            throw new TypeError(this.constructor.name + " must implement doComponentDidMount");
        }

        if (this.doComponentWillUnmount === undefined) {
            throw new TypeError(this.constructor.name + " must implement doComponentWillUnmount");
        }
    }

    componentDidMount() {
        // implement your hook logic here
        // ...
        // then let the derived class finish the job
        this.doComponentDidMount();
    }

    componentWillUnmount() {
        this.doComponentWillUnmount();
    }
}
```
**And it works!** There may be room for complex *composition-patterns and high-order components*, but often the simplest approach that works is the best.

If the abstract methods are optional, this becomes even shorter:

```javascript
class Base extends React.Component {
    componentDidMount() {
        if (this.doComponentDidMount !== undefined) {
              this.doComponentDidMount();
        }
    }

    componentWillUnmount() {
        if (this.doComponentWillUnmount !== undefined) {
              this.doComponentWillUnmount();
        }
    }
}
```

There may  not be enough templating going on in the examples above, but the closest well known pattern is probably  the [Template method pattern](https://en.wikipedia.org/wiki/Template_method_pattern) -- widely used in Javascript's name cousin Java.
