---
permalink: /guides/python/
redirect_from:
  - /v2/guides/python/
title: "Python Guide"
sidebar:
    nav: v2guides
toc: true
classes: wide
---

## Python Module

[Python Package Index module](https://pypi.org/project/netfoundry/)
: Python3 interface to the NetFoundry API

```bash
pip install --upgrade --user netfoundry
# or
python3 -m pip install --upgrade --user netfoundry
```



### Documentation

The module works with `pydoc` in the usual ways. For example:

```bash
pydoc netfoundry.Organization
pydoc netfoundry.NetworkGroup
pydoc netfoundry.Network
pydoc netfoundry.demo
pydoc netfoundry
```

### Create a Custom Docker Container with the NetFoundry Python Module

Suppose you have written a Python program named "my-netfoundry-network.py" that imports the NetFoundry module. You could run your program with a Docker container image that has the NetFoundry module pre-installed.

```docker
FROM netfoundry/python
COPY ./my-netfoundry-network.py .
CMD ./my-netfoundry-network.py
```
