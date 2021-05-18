---
title: Connect to Kubernetes with NetFoundry
excerpt: Install a Helm chart for secure access to cluster or pod services.
tags:
    - devops
    - kubernetes
    - helm
    - tunneler
permalink: /guides/kubernetes/
sidebar:
    nav: v2guides
toc: true
classes: wide
#last_updated: June 9, 2019
header:
    image: /assets/images/nfkubbiker.jpg
---

Let's talk about using a NetFoundry network to publish your Kubernetes cluster's internal services. This is a programmable approach to secure access that makes traditional alternatives like IP allow lists, virtual private networks, and bastion hosts obsolete. This also means your cluster could be anywhere it can reach out to the internet, and the master API server need not be exposed to the public internet.

You will deploy a NetFoundry endpoint as a pod on your Kubernetes cluster with a Helm chart. The endpoint may then be assigned in your NetFoundry network to host any services that are reachable inside your Kubernetes cluster. For example, the master API server used by `kubectl`, a Kubernetes dashboard, or any pod, service, or node IP or domain name you wish to expose to authorized remote apps, devices, or subnets.

## Before you begin

1. [Create a Kubernetes cluster with at least one worker node](https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/).
2. [Install `kubectl`, the command line interface for Kubernetes](https://kubernetes.io/docs/tasks/tools/)
3. [Install Helm, the package manager for Kubernetes](https://helm.sh/docs/intro/quickstart/).
4. [Sign up for a free trial with NetFoundry](https://nfconsole.io/signup)

## Create a NetFoundry Network

You will need a basic network to describe the services you wish to publish and to authorize clients to connect. Follow these steps to create a NetFoundry service for your Kubernetes master API server.

1. In the NF web console, create a network. The network will be ready in a few minutes.
2. In endpoints, create an endpoint named "k8s pod endpoint", then open the endpoint details to download the enrollment token .jwt file to the computer where you will connect to the k8s API server with `kubectl` and `helm`. This will be used a little later when you install the Helm chart on your cluster.
    ![NetFoundry service for Kubernetes master API server](/assets/images/create-endpoint-apiserver.png)
3. Create an endpoint named "my laptop". This will be used to connect to any Kubernetes services you decide to publish. Download the enrollment token .jwt file to your laptop.
4. In services, create a service like "k8s api server" for https://kubernetes.default.svc:443 as shown in the image above, hosted by the endpoint you just created. This is how you describe the cluster's internal services you'd like to publish.
    ![NetFoundry service for Kubernetes master API server](/assets/images/create-service-apiserver.png)

    _https://kubernetes.default.svc:443 is typically the default URL for accessing the master API server from a pod._

    ```bash
    ❯ kubectl cluster-info
    Kubernetes control plane is running at https://kubernetes.default.svc:443
    CoreDNS is running at https://kubernetes.default.svc:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
    ```

5. In AppWANs, create an AppWAN authorizing `#all` endpoints to connect to `#all` services. This is for simplicity's sake and assumes you are the only operator of your network. You could instead define a more restrictive policy.
6. In edge routers, create an edge router in any data center, ideally near your laptop.
7. In edge router policies, create a blanket edge router policy for #all endpoints to use #all edge routers.
8. Install [Ziti Desktop Edge](https://netfoundry.io/resources/support/downloads/networkversion7/#zititunnelers) on your laptop.
9. In Ziti Desktop Edge, add the endpoint identity you downloaded.

## Install Ziti with Helm

The Helm chart will create a Kubernetes deployment pod running the Ziti Linux tunneler which will be enrolled with your NetFoundry network using the token file you downloaded earlier.

1. Add NetFoundry charts repo to Helm.

    ```bash
    ❯ helm repo add netfoundry https://netfoundry.github.io/charts/                                                                                               
    "netfoundry" has been added to your repositories                         
    ```

2. Install the chart

    ```bash
    ❯ helm install ziti-host netfoundry/ziti-host --set-file enrollmentToken="k8s pod endpoint.jwt"
    NAME: ziti-host
    LAST DEPLOYED: Mon Apr 26 12:19:05 2021
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    NOTES:
    1. This deployment does not provide an ingress / server port, only egress from the pod to any `serverEgress` destinations you configure in a NetFoundry network e.g. https://kubernetes.default.svc:443:
    export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=ziti-host,app.kubernetes.io/instance=ziti-host" -o jsonpath="{.items[0].metadata.name}")
    ```

## Configure `kubectl` to use the private Ziti URL

_You may skip this section if you are not interested in making the Kubernetes API private_

Now your NetFoundry network is set up to allow your Ziti Desktop Edge app on your laptop to connect to your Kubernetes cluster. Next you will configure a new `kubectl` context to connect to the private URL with Ziti.

1. Find the master API *server* URL for the current `kubectl` context. In my case it is the server for cluster "my-cluster".

    ```bash
    ❯ kubectl config view -o jsonpath='{.contexts[?(@.name == "'$(kubectl config current-context)'")].context.cluster}'
    my-cluster

    ❯ kubectl config view -o jsonpath='{.clusters[?(@.name == "my-cluster")].cluster.server}'
    https://129.159.89.193:6443
    ```

2. Find the name of the *user* for the current context

    ```bash
    ❯ kubectl config view -o jsonpath='{.contexts[?(@.name == "'$(kubectl config current-context)'")].context.user}'
    my-user
    ```

3. Define a new `kubectl` cluster "my-cluster-private".

    This new cluster definition will have the private *server* URL with the same *certificate authority* as the current context.

    ```bash
    # create the new cluster definition with private URL and same CA
    ❯ kubectl config set clusters.my-cluster-private.server https://kubernetes.default.svc:443                                                                                                               
    Property "clusters.my-cluster-private.server" set.

    # Learn how the current context's CA is known, by data or file path. In my case it is by data in "certificate-authority-data"
    ❯ kubectl config view -o jsonpath='{.clusters[?(@.name == "my-cluster")].cluster}'
    {"certificate-authority-data":"DATA+OMITTED","server":"https://129.159.89.193:6443"}

    # use certificate-authority-data or certificate-authority (file path) depending on which your current context is already using
    ❯ kubectl config set clusters.my-cluster-private.certificate-authority-data $(kubectl config view --raw -o jsonpath='{.clusters[?(@.name == "my-cluster")].cluster.certificate-authority-data}')
    Property "clusters.my-cluster-private.certificate-authority-data" set.
    # or, if your CA is known by a file
    ❯ kubectl config set clusters.my-cluster-private.certificate-authority $(kubectl config view --raw -o jsonpath='{.clusters[?(@.name == "my-cluster")].cluster.certificate-authority}')     
    Property "clusters.my-cluster-private.certificate-authority" set.
    ```

4. Create the private `kubectl` context "my-context-private".

    This new context will pair the same Kubernetes *user* with the newly-created private cluster definition.

    ```bash
    ❯ kubectl config set-context my-context-private --cluster my-cluster-private --user my-user
    Context "my-context-private" created.
    ```

5. Switch to the new `kubectl` context

    ```bash
    ❯ kubectl config use-context my-context-private                                                                                                      
    Switched to context "my-context-private".

    ❯ kubectl get pods                                      
    NAME                        READY   STATUS    RESTARTS   AGE
    ziti-host-dfcb98fcd-l7rcr   1/1     Running   0          29m
    ```

This demonstrates that you are able to connect to your Kubernetes cluster's master API server via Ziti, and so you could at this point disable the public cluster API endpoint and continue normally!

## Expose Cluster Services with Ziti

You may immediately connect to any HTTP or HTTPS services in your cluster with `kubectl proxy`. In this case `kubectl` is authenticating to the API on your behalf and providing a plain HTTP server on the loopback interface.

```bash
❯ kubectl proxy
Starting to serve on 127.0.0.1:8001

# Now, if Kubernetes Dashboard is running, you may connect via the proxy:
#  http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

```

This is where it gets good: you may publish private cluster services with Ziti to your NetFoundry network so that there is no need for a proxy, and thereafter control access primarily through the NetFoundry console or API.

1. Deploy a lightweight NetFoundry hello world web server on your cluster.

    ```bash
    ❯ helm install hello netfoundry/hello-netfoundry 
    NAME: hello
    LAST DEPLOYED: Sat May  1 19:33:21 2021
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    ```

2. In NetFoundry console, in Services, create a service for the hello server.

    The server domain name for the new service is "hello-netfoundry.default.svc". Your ziti-host pod will use cluster DNS to resolve the service name in the default namespace.

    ![NetFoundry service for the hello web server](/assets/images/create-service-hello-netfoundry.png)

3. Visit the hello server in the browser on your laptop!

    [http://hello.netfoundry/](http://hello.netfoundry/)

## Troubleshooting

If you made an adjustment to your NetFoundry network and you're waiting for the pod endpoint to notice then you might reduce the delay by deleting the pod. This will cause Kubernetes to re-create the pod, and you will not need to re-install the chart.

```bash
❯ kubectl get pods                           
NAME                        READY   STATUS    RESTARTS   AGE
ziti-host-dfcb98fcd-vjlww   1/1     Running   0          27m

❯ kubectl delete pod ziti-host-dfcb98fcd-vjlww 
pod "ziti-host-dfcb98fcd-vjlww" deleted
```

You may also inspect the endpoint tunneler `ziti-tunnel` log messages for clues if it is not working. An error like "NO_EDGE_ROUTERS_AVAILABLE" could mean you did not create the blanket edge router policy when you set up your NetFoundry network.

```bash
❯ kubectl logs ziti-host-dfcb98fcd-vjlww | tail -
{"error":"unable to create apiSession. http status code: 400, msg: {\"error\":{\"code\":\"NO_EDGE_ROUTERS_AVAILABLE\",\"message\":\"No edge routers are assigned and online to handle the requested connection\",\"requestId\":\"fk7Gl3Isj\"},\"meta\":{\"apiEnrolmentVersion\":\"0.0.1\",\"apiVersion\":\"0.0.1\"}}\n","file":"/home/runner/go/pkg/mod/github.com/openziti/sdk-golang@v0.15.43/ziti/ziti.go:1187","func":"github.com/openziti/sdk-golang/ziti.(*listenerManager).createSessionWithBackoff","level":"error","msg":"failed to create bind session for service echo-1691-50050","time":"2021-05-01T18:08:34Z"}
```
