---
date: 2017-02-06T19:44:46+07:00
title: MacBook Wi-Fi Dropout Band-Aid
slug: macbook-wifi-dropout-bandaid
images:
- /assets/img/2016/go-react-bep-gr.jpg
---

**11Read on for a band-aid solution to the recurring MacBook Wi-Fi dropout problem.**
<!--more-->

{{< img src="/assets/img/2016/go-react-bep-gr.jpg" caption="My MacBook, now online." >}}

The solution first. Open [a terminal](https://discussions.apple.com/thread/3223989?tstart=0) and copy and paste the content below into the terminal window and hit enter:

```bash
while true; do echo "add State:/Network/Interface/en0/RefreshConfiguration temporary" | sudo scutil; sleep 10; done;
```

**Note: This isn't a permanent solution. Apple will have to fix their product. But the above will (most likely) help if you're sitting at that South Eeast Asian guest house and the Wi-Fi is dropping out every minute.**

Also note:

* The command above requires that you type in your password.
* The command will just silently refresh the `en0` network interface (silently as in: You will most likely not notice it). That should in most cases be your Wi-Fi network interface. If not, this [link](http://superuser.com/questions/89994/how-can-i-tell-which-network-interface-my-computer-is-using) may give some more info.
* It will do a refresh every 10 seconds, which may be too aggressive for some situations.

I guess if you arrived here, you have been going through the obvious Google searches, like [macbook wifi disconnects randomly](https://www.google.co.th/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=macbook+wifi+disconnects+randomly) or [macbook wifi dropouts](https://www.google.co.th/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=macbook+wifi+dropouts) -- and followed some 20 step tutorial that did not work.

I'm writing this from a hotel with a very unstable Wi-Fi network. But all my other devices (Android phone, iPad and Kindle -- yes, I know, it does not sound like a holiday) all handle this instability just fine. But on my MacBook, with the latest macOS Sierra, I have to go through some  Wi-Fi Diagnostics tool for it to get back in order -- which I guess is doing some DHCP refreshment or something. 