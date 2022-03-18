---
title: Bastion Dark Mode
excerpt: Defense in depth without disrupting business as usual
tags:
    - devops
    - zerotrust
    - bastion
    - openssh
    - ssh
author: Ken
toc: false
classes: wide
#last_updated: June 9, 2019
header:
    image: /assets/images/hourglass-header.jpg
---


## A Zero Trust Journey (ep.1)

When we first built the platform that Netfoudry's products run on we followed a pretty typical bastion pattern: the stack was a fortress, and you had to be inside to do all the fun stuff. At that early stage, it wasn’t yet feasible to use OpenZiti to create the safe zone that we needed to create the infrastructure that would eventually support the NetFoundry platform.

When OpenZiti was ready we started to look at how we could apply what we’d built and learned along the way. We knew we wanted to adopt the zero trust mindset that had motivated the development of OpenZiti in the first place. We had one strong layer of defense directly exposed to the internet: a perimeter of bastions. We knew that lots of developers were facing the same problem: first, get it working, then try to make it secure by bolting-on armor. We knew bad things would happen if an attacker somehow slipped inside the fortress, but we didn’t want to encumber operations too much.

OpenZiti was designed to solve this problem. For the first time ever it would be possible to start with security without slowing down the getting-it-working part. The only problem was that we didn’t have it yet, so we built a temporary fortress with SSH. This is the story of how we retrofitted our infrastructure for zero trust with OpenZiti without rebuilding or shutting down during the process.

## Isn’t Secure Shell…Secure?

There are dimensions to “secure” worth mentioning. The popular take on zero trust is to secure the host device instead of the network, and that’s what we set out to accomplish here in episode 1. OpenZiti's SDKs are meant to be embedded directly into your application bringing the strong identity and zero trust principles directly into your application's process space. We'll approach that in a post later down the road.

We wanted to remove our bastions from the open internet because active scanning of the network is the most common way to discover vulnerabilities. Those vulnerabilities are then exploited, data is compromised, and trust is broken. You can learn more in How Do Ransomware Actors Find Victims? by NetFoundry’s chief of security, Mike Gorman. Eliminating the network attack surface makes this problem go away.

OpenSSH server has enjoyed a great security track record for the last few years, but internet exposure can still lead to problems like denial of service attacks, zero-day exploits, and insider misuse. A bastion presents an attack surface analogous to the gate and walls of a fortress. If there’s one weakness then it will eventually be discovered.

It was popular for a while to obscure the SSH server by configuring a non-standard port to listen for connections or require a port knocking pattern to open the listener port. Those tactics may have seemed clever at the time but in reality, would only delay the discovery of the same weakness. I like the idea of having an assurance of security that is not dependent upon the prospective intruder’s lack of imagination.

## Gracefully Going Dark

Build systems, support engineers, admins, and developers were all using the SSH infrastructure every day. We came to realize that we would have to step this forward without too much disruption. Our fortress walls were composed of a fleet of Linux hosts, each running an OpenSSH server. They were locked down tight according to best practices but were still listening on the open internet. Going “dark” would mean the internet access we were using to reach the bastion hosts would no longer be available as soon as the firewall exceptions are removed, disallowing inbound 22/TCP.

![public bastion](/assets/images/zt-ssh-public-bastion.svg){: .align-center}
<center><i>
Before OpenZiti: depicts a bastion sheltering an SQL server from the internet
</i></center>

## Enter the Dark Bastions

We treated our bastions like any other app and applied OpenZiti to control the network-level access to the servers’ listening ports. On the SSH server host, we installed an OpenZiti tunneler as a system daemon. Any tunneler can be configured to provide server or client functionality, so to clarify I’ll refer to "server tunneler" or "client tunneler". In our case, the server tunneler was bound to a single OpenZiti service for SSH that shovels packets between the OpenZiti network and localhost:22, the device’s host-only loopback interface. This is a simple thing to set up and works for any services you want to expose securely, on any OS, any device.

On the admin workstations, we continued using the familiar “ssh” (OpenSSH client) in tandem with a client tunneler installed. This means we didn’t have to change our OpenSSH client configuration or the domain names we were using or the “ssh” command-line arguments and options! The global DNS records for the bastions were still in place to allow for a seamless transition.

A neat feature of an OpenZiti tunneling app is its ability to discover OpenZiti services with its built-in DNS. This meant that our workstations preferred the built-in OpenZiti DNS above global DNS for name queries that match an authorized OpenZiti service. This was powerful because it enabled a seamless transition! Each workstation gained the ability to jump on and off to the OpenZiti solution by merely toggling their client tunneler. We retained the global records to support our transition, but there’s nothing stopping us from deleting them entirely.

```bash
 # without OpenZiti we “see” the result from global DNS
 $ dig +short bastion.production.netfoundry.io
 3.214.111.111
 
 # with tunneler turned on OpenZiti DNS provides the result
 $ dig +short bastion.production.netfoundry.io
 100.64.64.47
```

![dark bastion](/assets/images/zt-ssh-dark-bastion.svg){: .align-center}
<center><i>
After adding OpenZiti to the bastion: depicts a now-invisible bastion sheltering an SQL server from the internet
</i></center><br/>

The final result here is that the bastions are invisible to the attacker who is viewing them from the internet or the subnet behind the wall. Our authorized devices continue using them normally after installing OpenZiti as signified by the ultraviolet zed badge. This has been a practically-painless change and is an enormous improvement. Every time we gain a new admin or support engineer we:

1. ask for their SSH pubkey to add to the Jenkins job for bastion configs which uses an OpenZiti tunneler to access the dark bastions in the same way as the workstations 
1. have them install a tunneler on their workstation
1. add the appropriate attributes to their identity in the NetFoundry console to authorize bastion access.

There’s still one not-so-zero-trust feature of the dark bastions diagram: the SQL server. That represents the workloads that were still visible to their own network and therefore vulnerable behind the wall. We’ll take a swing at that remaining vulnerability in a future episode.
