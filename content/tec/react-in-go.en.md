---
date: 2016-10-13T19:37:42+02:00
title: Write React Components in Go
tags:
- Go
title_main: |
                    Write 
                    
                    **React Components** 
                    
                    **in Go**
slug: react-in-go
images:
- /assets/img/2016/go-react-bep-gr.jpg
---
**_Go React_ is React bindings for Go with a set of supplementary components.** 

<!--more-->

To be more specific, it is [GopherJS](http://www.gopherjs.org/) bindings for [Facebook's React](https://facebook.github.io/react/) -- have a look at [github.com/bep/gr](https://github.com/bep/gr).

{{< img src="/assets/img/2016/go-react-bep-gr.jpg" caption="Go React code example in editor." >}}

I started this side project some time ago, and I have plans to get it passed the experimental stage -- it isn't ready for production use yet -- but I use it for some internal web apps and it works.

**And it is a very pleasant experience to write React applications in Go and have all the ReactJS components available via `npm install`.**

A simple click counter example looks like this:

```go
func main() {
    component := gr.New(new(clickCounter))

    gr.RenderLoop(func() {
        component.Render("react", gr.Props{})
    })
}

type clickCounter struct {
    *gr.This
}

// Implements the StateInitializer interface.
func (c clickCounter) GetInitialState() gr.State {
    return gr.State{"counter": 0}
}

// Implements the Renderer interface.
func (c clickCounter) Render() gr.Component {
    counter := c.State()["counter"]
    message := fmt.Sprintf(" Click me! Number of clicks: %v", counter)

    elem := el.Div(
        el.Button(
            gr.CSS("btn", "btn-lg", "btn-primary"),
            gr.Style("color", "orange"),
            gr.Text(message),
            evt.Click(c.onClick)))

    return examples.Example("Click Counter", elem)
}

func (c clickCounter) onClick(event *gr.Event) {
    c.SetState(gr.State{"counter": c.State().Int("counter") + 1})
}

// Implements the ShouldComponentUpdate interface.
func (c clickCounter) ShouldComponentUpdate(next gr.Cops) bool {
    return c.State().HasChanged(next.State, "counter")
}
```

## Links

* Running examples: http://bego.io/goreact/examples/basic/
* Main Git repo: https://github.com/bep/gr
* A small set of components: https://github.com/bep/grcomponents
* React Router bindings: https://github.com/bep/grouter
