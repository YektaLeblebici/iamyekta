# iamyekta

This repository contains the source code, posts & assets and custom theme of my personal website at https://iamyekta.com.

* Static website generated with Hugo.
* Posts are written in Markdown.
* Hugo theme is created from "Stellar" CSS template by HTML5UP, with some customizations.
* Deployed with Docker Compose and a tiny Makefile.

## Dependencies
* hugo
* docker, docker-compose
* make

## Installation & Setup

If you would like to build a similar website:

* Simply clone this repo and install the dependencies above.
* Remove everything inside the `content/` directory.
* Change `config.yml` as you see fit, there are only a few parameters anyway.
* Change `favicon-*` and `profile.jpg` files in `static/` directory.
* Run `make build`, and it's done!

## Adding a new post

* cd to working directory and run: `hugo new post/title-of-the-post.md`
* Edit `content/post/title-of-the-post.md` as you see fit.
* Run `make build` and it's done!
