---
permalink: /guides/cli/
redirect_from:
  - /v2/guides/cli/
title: "Command-Line Interface Guide"
sidebar:
    nav: v2guides
toc: true
#classes: wide
---

## nfctl

The NetFoundry CLI `nfctl` is an interactive tool for MacOS, Windows, and Linux and is useful for inspecting and configuring NetFoundry networks.

## Installation

The CLI is bundled with [the NetFoundry Python module](/guides/python/).

```bash
❯ pip install --quiet netfoundry
❯ nfctl --version
v5.5.0
```

## Upgrade

```bash
❯ pip install --quiet --upgrade netfoundry
```

## Auto-Complete

The CLI has built-in support for auto-complete in BASH, ZSH, FISH, and TCSH (limited). This is accomplished with `argcomplete` like so:

```bash
source <(register-python-argcomplete nfctl)
```

You may choose to add a line like this to your shell config to enable all future shells or run it at any time to configure that shell for auto-complete until exit.

`nfctl` also supports [global tab auto-completion](https://github.com/kislyuk/argcomplete#global-completion) for BASH >=4.2 by way of `complete -D` should you desire to avoid configuring the shell entirely.

## Grammar

The CLI expects options and sub-commands. The options must precede the sub-command. The default sub-command is `login`. Sub-commands also expect options which must follow the sub-command. The sub-commands are generally verbs that act upon an object. For example: `edit endpoint` or `list endpoints`.

```bash
nfctl GENERAL_OPTIONS SUB_COMMAND RESOURCE_TYPE SUB_OPTIONS
# e.g.
nfctl --network NETWORK list services --keys id,zitiId,name
```

## Options

I'll describe the most relevant options immediately below. Run `nfctl --help` to see the up-to-date and complete options and sub-commands.

### credentials

```bash
nfctl --credentials NETFOUNDRY_API_ACCOUNT
```

You may supply an API account as a JSON file path to `nfctl --credentials NETFOUNDRY_API_ACCOUNT` in order to login. It is not strictly necessary to supply this option if you already have a non-expired login token. You may learn how to obtain an API account credentials file in [the authentication guide](/guides/authentication/#get-an-api-account).

### verbose

```bash
nfctl --verbose
```

Print DEBUG and higher-level messages including HTTP requests to the NF API and from the Python library.

### output

```bash
nfctl --output {text,yaml,json}
```

Format output as text tables, YAML, or JSON.
### network

```bash
nfctl --network NETWORK
```

Configure the CLI to use a particular network by name. Escape if the name has spaces. Network names are not case sensitive.
### network-group

```bash
nfctl --network-group NETWORK_GROUP
```

Configure the CLI to use a particular network group by name. Network names are unique within each group, and so it may be necessary to specify the group to disambiguate two networks with the same name.
### yes

```bash
nfctl --yes
```

Answer in the affirmative without prompting for confirmation. Use this with caution because it is possible to unintentionally destroy an entire network. You did `nfctl get network` to create a backup, right?

### profile

```bash
nfctl --profile PROFILE
```

Login profiles allow you to cache more than one login token concurrently. You must specify the same value for `nfctl --profile PROFILE` for every command that you wish to use a non-default profile. This behavior is not set in stone. See also the [logout](#logout) command.

## Sub-Commands

### config

Interactively configure `nfctl`. Most of the OPTIONS are also configuration directives and may be declared with `nfctl config` sub-command or added to the INI configuration file. The file location depends on your OS.

```bash
❯ nfctl config --help
usage: nfctl config [-h] [-ro] [-a] [configs ...]

positional arguments:
  configs           Configuration options to read or write.

optional arguments:
  -h, --help        show this help message and exit
  -ro, --read-only  Operate in read-only mode.
  -a, --all         Show all configuration options.
```

```bash
# view current configurations that differ from defaults
❯ nfctl config 
general.borders=False
general.color=False
general.proxy=http://localhost:4321
```

```bash
# declare a new value for some directive
❯ nfctl config general.proxy='http://localhost:4321'
general.proxy: None -> http://localhost:4321
ℹ Wrote configuration to /home/kbingham/.config/nfctl/nfctl.ini
```

```bash
# unset a config directive by assigning "None" or delete from INI file
❯ nfctl config general.proxy=None
general.proxy: http://localhost:4321 -> None
ℹ Wrote configuration to /home/kbingham/.config/nfctl/nfctl.ini
```

```powershell
# recommended Windows configuration
PS C:\Users\IEUser> nfctl.exe config general.color=False general.unicode=False
general.color: True -> False
general.unicode: True -> False
ℹ Wrote configuration to 'C:\Users\IEUser\AppData\Local\NFCTL.EXE\nfctl.exe\nfctl.exe.ini'
```

### logout

Delete any cached login token for the current login profile. This is useful for switching between API account identities. See also the [profile](#profile) option.

### login

This is the default sub-command and logs you in to a NetFoundry organization by fetching and caching a login token with your API account credentials. You must supply an API account as a JSON file path to `nfctl --credentials NETFOUNDRY_API_ACCOUNT` or as environment variables as described in [the authentication guide](/guides/authentication/#command-line-examples). You may also learn how to obtain an API account credentials file in [the authentication guide](/guides/authentication/#get-an-api-account).

### get

Fetch a single resource as YAML or JSON from any of several resource domains of which `network` and `organization` are the most relevant. You must specify the singular form of the type of resource to get e.g. `nfctl get service`.

#### Network Domain

```bash
# download an entire network with embedded lists of resources
nfctl --network NETWORK get network
# or just the as=create representation which is useful for cloning
nfctl --network NETWORK get network --accept create
# or select the network with a query, even a deleted network
nfctl get network name="ACME Net",status=DELETED
# optionally filter for keys you're interested in
nfctl get network id=4e601202-5260-425a-bdd0-677358bc3a7c --keys name,id,status
```

```bash
# get an endpoint by name
nfctl --network NETWORK get endpoint name="ACME Endpoint"
```

#### Organization Domain

```bash
# get caller organization
nfctl get organization
```

```bash
# get caller identity
nfctl get identity
# get an identity by name if there's only one that starts with "Bob"
nfctl get identity name=Bob%
```

```bash
❯ nfctl get --help
usage: nfctl get [-h] [-a {create,update}] [-k KEYS]
                 {data-center,organization,network-group,network,network-controller,identity,host,endpoint,edge-router,edge-router-policy,app-wan,service,service-policy,service-edge-router-policy,posture-check,certificate-authority}
                 [query]

positional arguments:
  {data-center,organization,network-group,network,network-controller,identity,host,endpoint,edge-router,edge-router-policy,app-wan,service,service-policy,service-edge-router-policy,posture-check,certificate-authority}
                        type of resource
  query                 id=UUIDv4 or query params as k=v,k=v comma-separated pairs

optional arguments:
  -h, --help            show this help message and exit
  -a {create,update}, --accept {create,update}
                        request the as=create or as=update form of the resource
  -k KEYS, --keys KEYS  list of keys as a,b,c to print only selected keys (columns)
```

### list

Find resources as lists. You must specify the plural form of the type of resource to list e.g. `nfctl list services`. The default output format is a text table and you may configure table preferences for headers, borders, or color in the general configuration section of the INI file, interactively with the `nfctl config` command, or by including the appropriate general options each time you run `nfctl --no-headers --no-borders --no-color list services`.

You may supply any query parameters that are supported by the NF API.

You may filter the output's columns with the `--keys k,k,k` option. This works for the text, yaml, and json output formats.

```bash
nfctl --network NETWORK list edge-routers
# or query by provider
nfctl --network NETWORK list edge-routers provider=AZURE
# or filter results for only interesting keys
nfctl --network NETWORK list edge-routers region=us-east-2 --keys name,id,status,provider
```

### create

You may create a resource in the network domain (in a particular network) by supplying an object as YAML or JSON. There is partial support at this time for creating a resource from a template. You can try it out by saying:

```bash
nfctl --network NETWORK create endpoint
```

```bash
# create from stdin
nfctl --network NETWORK create endpoint < ./new-endpoint.yml
# or from a file
nfctl --network NETWORK create endpoint --file ./new-endpoint.yml
```

### edit

You may edit a resource in the network domain (in a particular network) by specifying the singular form or a resource type and a query that selects exactly one resource. This will open that resource in your default editor allowing you to modify its properties. It will be updated when you exit the editor. You may cancel the edit / update operation by clearing the editor's buffer just like `kubectl` or `git`.

You may configure your default editor with the NETFOUNDRY_EDITOR or EDITOR environment variables. I use VS Code like this:

```bash
# from shell config
NETFOUNDRY_EDITOR="/usr/bin/code --wait"
```

```bash
nfctl --network NETWORK edit service name="ACME Service"
```

### delete

You may delete a resource in the network domain (in a particular network, or the network itself) by specifying the singular form of a resource type and a query that selects exactly one resource. You will be prompted to confirm unless you set `--yes` in the general config. Nothing will get deleted if this fails to match exatly one resource.

```bash
nfctl --network NETWORK delete service name="ACME Service"
# or by ID
nfctl --network NETWORK delete service id=8b3be67b-919c-4431-8cf8-b43cfe5fda46
```
