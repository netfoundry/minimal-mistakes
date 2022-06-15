---
title: Bastion Dark Mode
excerpt: Defense in depth without disrupting business as usual
tags:
    - devops
    - zerotrust
    - bastion
    - openziti
    - ssh
author: Ken
toc: false
classes: wide
last_modified_at: June 14, 2022
header:
    image: /assets/images/dark-bastions-castle.jpg
canonical_url: https://netfoundry.io/bastion-dark-mode/
---


## A Zero Trust Journey (ep.1)

When we built Netfoudry's platform, **we followed a typical bastion pattern**: the stack was a fortress, and you had to be inside to do all the fun stuff. At that early stage, **it wasn't yet feasible to use OpenZiti** to create the safe zone that we needed in which to develop the foundational infrastructure.

When OpenZiti was ready, we started to look at how we could apply what we’d built and learned. We knew **we wanted to adopt the zero trust<sup>[_1_](#zerotrust)</sup> mindset** that had motivated the development of OpenZiti in the first place. We had one strong layer of defense directly exposed to the internet: a perimeter of bastions. We knew that lots of developers were facing the same problem: first, get it working, then try to make it secure by bolting-on armor. We knew bad things would happen if an attacker somehow slipped inside the fortress, but we didn’t want to impede day-to-day operations too much.

OpenZiti was designed to solve this problem. With OpenZiti, it would become possible to start with secure-by-design without slowing down the getting-it-working part<sup>[_2_](#devopslove)</sup>. The only problem was that we didn’t have it yet, so we built a temporary fortress with SSH. This is the story of how we retrofitted our infrastructure for zero trust with OpenZiti without rebuilding or shutting down during the process.

## Isn’t Secure Shell…Secure?

There are dimensions to “secure” worth mentioning. **The OpenZiti approach to zero trust<sup>[_3_](#zitiapproach)</sup> maturity is to secure the application instead of the network**. The best way to secure the application is to embed the OpenZiti SDK directly into your application. This brings strong identity and zero trust principles directly into the process space. We won’t get that far in this episode, but we will in a later post. We’ll start by securing the host device instead of the network.

**Our immediate need was to remove our bastions from the open internet because active network scanning is the most common way to discover vulnerabilities<sup>[_4_](#activescanning)</sup>**. Those vulnerabilities are then exploited, data is compromised, and trust is broken. You can learn more in [How Do Ransomware Actors Find Victims](https://netfoundry.io/anvil/NFWP-HowdoRansomwareactorsfindvictimsPart1.pdf)? by NetFoundry’s chief of security, Mike Gorman. Eliminating the network attack surface makes this problem go away.

OpenSSH server has enjoyed a great security track record for the last few years. However, **internet exposure can still lead to problems like denial of service attacks, zero-day exploits, and insider misuse**. A bastion presents an attack surface analogous to the gate and walls of a fortress. If there’s one weakness then it will eventually be discovered.

It was popular for a while to obscure the SSH server by configuring a non-standard port to listen for connections or require a port knocking pattern to open the listener port. Those tactics may have seemed clever at the time, but would only delay the discovery of the same weakness. **I like the idea of having an assurance of security that is not dependent upon the prospective intruder’s lack of imagination**.

## Gracefully Going Dark

Our build systems, support engineers, admins, and developers use the SSH infrastructure daily. We realized that we would have to step this forward without too much disruption. Our fortress walls comprised a fleet of Linux hosts, each running an OpenSSH server. **According to best practices, they were locked down tight but were still listening on the open internet. Going “dark” would mean the internet access we were using to reach the bastion hosts would no longer be available as soon as the firewall exceptions are removed, disallowing inbound 22/TCP**.

![public bastion](/assets/images/zt-ssh-public-bastion.svg){: .align-center}
<center><i>
Before OpenZiti: depicts a bastion sheltering an SQL server from the internet
</i></center>

## Enter the Dark Bastions

**We treated our bastions like any other app and applied OpenZiti to control the network-level access to the servers’ listening ports**. On the SSH server host, we installed an OpenZiti tunneler as a system daemon. Any tunneler can be configured to provide server or client functionality. For the sake of clarity, I’ll refer to "server tunneler" or "client tunneler". In our case, the server tunneler was bound to a single OpenZiti service for SSH that shovels packets between the OpenZiti network and localhost:22, the device’s host-only loopback interface. This is a simple thing to set up and works for any services you want to expose securely, on any OS, any device.

We continued using the familiar “ssh” (OpenSSH client) on the admin workstations in tandem with a client tunneler. This means **we didn’t have to change our OpenSSH client configuration, the domain names we were using, or the “ssh” command-line arguments and options!** The global DNS records for the bastions were still in place to allow for a seamless transition.

**A neat feature of an OpenZiti tunneling app is its ability to discover OpenZiti services with its built-in DNS. Our workstations then preferred the built-in OpenZiti DNS** above global DNS for name queries that match an authorized OpenZiti service. **This was powerful because it enabled a seamless transition!** Each workstation gained the ability to jump on and off the OpenZiti solution by merely toggling its client tunneler. We retained the global records to support our transition, but nothing stops us from deleting them entirely.

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

**The final result is that the bastions are invisible to the attacker viewing them from the internet or the subnet behind the wall**. Our authorized workstations continue to use them normally after installing OpenZiti as signified in the drawing by the ultraviolet “Z” badge. This has been **a painless change and is an enormous improvement in the overall security posture and immediate visibility of how the bastions are being used, and by whom!** Every time we gain a new admin or support engineer we add them to the system with these steps:

1. ask for their SSH pubkey to add to the Jenkins job for bastion configs which uses an OpenZiti tunneler to access the dark bastions in the same way as the workstations
1. have them install a tunneler on their workstation
1. add the appropriate attributes to their identity in the NetFoundry console to authorize bastion access.

There’s still one not-so-zero-trust feature of the dark bastions diagram: the SQL server. It is still visible to its local network and therefore vulnerable if a malicious actor can get behind the wall. We’ll take a swing at that remaining vulnerability in a future episode.

## Footnotes

* <a name="zerotrust">1</a>: [Implementing Zero Trust Networking](https://netfoundry.io/implementing-true-zero-trust-networking)
* <a name="devopslove">2</a>: [Why every DevOps person should love OpenZiti](https://netfoundry.io/devops-meets-secops/)
* <a name="zitiapproach">3</a>: The main concept behind the zero trust security model is "never trust, always verify,” but many interpret it to mean that devices should not be trusted by default, even if they are connected to a permissioned network. We strongly believe this does not go far enough as it places too much trust networks which are inherently insecure by design.
* <a name="activescanning">4</a>: X-Force Threat Intelligence Index
