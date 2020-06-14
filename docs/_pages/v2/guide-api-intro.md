---
title: Overview
permalink: /v2/guides/introduction/
redirect_from:
    - /v2/
    - /v2/guides/
    - /v2/guides/overview/
sidebar:
    nav: "v2guides"
toc: true
---

{% include intro.md %}

## Representations

This RESTful API transacts meaningful HTTP verbs and request paths and parameters. Most types of requests and responses also have an HTTP document body which is always a JSON representation. Requests that include a JSON body must also include a header `Content-Type: application/json`, and responses with a JSON body will have this header too.

You'll find the [API definition and reference](/v2/reference/) here.
