## Audience

This documentation is aimed at developers wishing to automate things they can already do with the [NetFoundry Web Console](https://nfconsole.io/). If you are looking for a general introduction to NetFoundry then the [Support Hub](https://support.netfoundry.io/hc/en-us) or the [main web site](https://netfoundry.io) are also places you could begin.

## The Web Console

the [NetFoundry Web Console](https://nfconsole.io/) is an implementation of the API and so may help to express the model of the API while you're learning [how to build an AppWAN](/v1/guides/hello-appwan/). For example, you might inspect the HTTP requests sent from your browser if you're unsure how to automate a particular action and need a hint for searching [the API reference](/v1/reference/).

## Your Code, NetFoundry's API

The API allows you to manage your AppWANs with your own code. You could program your AppWAN to

* disallow a lost or non-compliant device from connecting,
* allow a new device to connect to a service based on some event or condition,
* create a path to a new network service for an existing group of devices, or
* trigger an alert based on an unexpected metric that NetFoundry reports.