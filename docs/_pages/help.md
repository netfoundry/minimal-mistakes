---
title: Help
permalink: /help/
toc: true
---

<!-- 
## Search

Google site search
<script async src="https://cse.google.com/cse.js?cx=012487269132852934767:xsww2ydkdoy"></script>
<div class="gcse-search"></div>

 -->

## Customer Support

Send a help request to <support@netfoundry.io> or read more about contacting support in [Support Hub](https://support.netfoundry.io/hc/en-us/articles/360019471912-Contact-NetFoundry-Support).

<!-- <button onclick="_chatlio.showOrHide();" data-chatlio-widget-button>Chat</button> -->

## Improve this Site

Contributions are welcome! This site is open-source. You may [create a branch or a fork on GitHub](https://github.com/netfoundry/mop-api-docs) and send a pull request. Learn [how to edit this site](/contribute/).

Minor changes may be made directly in GitHub's online editor wherever &nbsp;<i class="fas fa-edit" aria-hidden="true"></i>&nbsp;**Edit**&nbsp; appears at bottom-right.

## Foundational Concepts

### Organization

An Organization is a consolidated billing and ownership domain comprising Network Groups. Read [articles about Organizations](https://support.netfoundry.io/hc/en-us/sections/360002448992-Organizations-Network-Groups)

### Network Group

A Network Group is a collection of Networks. Read [articles about Network Groups](https://support.netfoundry.io/hc/en-us/sections/360002448992-Organizations-Network-Groups)

### Network

A NetFoundry Network is a management domain and collection of resources e.g. Endpoints, Services, Edge Routers (and Edge Router Policies), and AppWANs.

### AppWAN

An AppWAN is a policy that controls access to Services and it works like a permission group. In the web console, An AppWAN is visually represented as Endpoints on the left that are allowed to connect to Services on the right. Read [articles about AppWANs](https://support.netfoundry.io/hc/en-us/sections/360002806392-AppWANs-Services).

![AppWAN](/assets/images/appwan.png)

### Endpoint

An endpoint is node on the edge of your Network. Protected traffic flows to, from, and through Endpoints. Endpoints may be configured to dial or host Services, or both.

### Service

A Service describes a server and determines which AppWANs will grant access. A Service is hosted by some device which must be able to reach the server. Read [articles about Services](https://support.netfoundry.io/hc/en-us/sections/360002806392-AppWANs-Services).

### Edge Router

An Edge Router is an enrolled instance of `ziti-router`, typically auto-configured by NetFoundry by way of "registration". Edge Routers typically perform one of two primary functions: hosting a Service in your branch or data center (customer-hosted Edge Routers), or listening for dialing Endpoints in a NetFoundry data center (hosted Edge Routers). Edge Routers automatically form the mesh overlay fabric by creating links to the hosted Edge Routers in NetFoundry data centers. Read [articles about Edge Routers](https://support.netfoundry.io/hc/en-us/sections/360002445391-Endpoints-Edge-Routers/).

#### NetFoundry VM

The NetFoundry VM is a deployable system image with pre-installed software for a variety of virtual network functions e.g. customer-hosted Edge Router, gateway tunneler, Linux router. NetFoundry offers a variety of virtual machine system image formats that can be imported in your preferred VM stack or launched by on your preferred cloud.

The best way to obtain the latest VM for your Network is to create an Edge Router and then visit its detail page in the console and click "get the VM" and follow the stack-specific instructions found there.

#### Edge Tunneler

Edge Tunnelers are a category of Endpoint softwares. 

 <!-- <script type="text/javascript">
    window._chatlio = window._chatlio||[];
    !function(){ var t=document.getElementById("chatlio-widget-embed");if(t&&window.ChatlioReact&&_chatlio.init)return void _chatlio.init(t,ChatlioReact);for(var e=function(t){return function(){_chatlio.push([t].concat(arguments)) }},i=["configure","identify","track","show","hide","isShown","isOnline", "page", "open", "showOrHide"],a=0;a<i.length;a++)_chatlio[i[a]]||(_chatlio[i[a]]=e(i[a]));var n=document.createElement("script"),c=document.getElementsByTagName("script")[0];n.id="chatlio-widget-embed",n.src="https://w.chatlio.com/w.chatlio-widget.js",n.async=!0,n.setAttribute("data-embed-version","2.3");
       n.setAttribute('data-widget-id','7157de3d-04c0-4665-5731-7e3e9c291dd4');
       c.parentNode.insertBefore(n,c);
    }();
</script> -->
