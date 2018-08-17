---
title: "Cutting the red ribbon"
date: 2018-08-16T13:07:49+03:00
draft: false
---


## A little backstory 
It's been 2 years since the last time I've written a blog post. In those two years, I have worked two full-time software jobs, learned a TON of new stuff, worked on a few side projects, and got married. :ring: 

In the meantime, I abandoned the previous blog I maintained since 2007. I couldn't see the point of keeping a blog in Turkish anymore, and most of the time I felt like I had no story to tell, and not even a single person to listen. After a long break, today I visited it for one last time and got an instant shot of nostalgia. I've started and run a community for local mobile Linux enthusiasts and developers [^1] there, I've announced first (and to this day, only) mobile apps I created, announced a few side projects, shared videos, comics, and opinions on topics I cared about the most. I learned a bit about everything and somehow managed to help a few people along the road.

After a long time of neglect, my previous blog, a hungry, WordPress-based mammoth, now sits on a Raspberry Pi with the help of aggressive caching, CloudFlare and a few optimizations I made back in the day. It runs on out-of-date versions of Nginx, PHP, and MySQL. To my surprise, somehow it seems like it's still not hacked yet. (as far as I can tell)

Anyway, in a few hours, I will pull the plug and my now 11-year old blog [^2] can finally rest in peace. :relieved:

## Moving on to greener pastures
Time for more energetic thoughts! Today, I am starting a new version of my blog! And it doubles as a personal landing page too. It is now in English, and to me, it is a thing of beauty. It's minimalistic, there are no share/social buttons, no sidebar, no tags, categories, twitter widgets or any other kind of badges, and the best part of it: not a single component moves or animates on its own.

As for content, I don't really have a plan in mind right now. I think I'll post infrequently, and mostly about software, personal projects, and other stuff I am interested in.

Under the hood, it's a beautiful static website, generated with Hugo. I created a Hugo theme from HTML5UP's "Stellar" CSS template and made a few customizations on top of it. [^3] It's deployed with Docker Compose, and all of this process is wrapped in a tiny Makefile. To add a new post, all I have to do is to write my post in a Markdown file and run `make build`.

By the way, if you like this website, and wish you had your own: all you have to do is to [fork  my repository](https://github.com/YektaLeblebici/iamyekta). Everything is configurable, so you can just remove my name from `config.yml` and remove my posts from the `content/` directory, then it's all yours!

PS: This is my first time blogging in English. There will be some grammatical errors and questionable word choices. Please go easy on me. :smiley:


[^1]: MeeGo Turkey was an initiative to help non-tech people and developers get on-board to Linux-based mobile devices.
[^2]: I started it just after installing Linux to my computer for the first time. 
[^3]: There already was a Hugo theme for Stellar, named "hugo-stellar-theme". But it did not support blog posts, and I wanted to create something more personalized with customized layout, colors etc.
