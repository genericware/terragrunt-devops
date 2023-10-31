===================
 terragrunt-devops
===================

:Authors: caerulescens <caerulescens.github@proton.me>
:Description:

--------------
 dependencies
--------------

+------------------+--------------------------------------------+
| dependency       | description                                |
+==================+============================================+
| `minikube`_      | local kubernetes cluster                   |
+------------------+--------------------------------------------+
| `kvm`_           | hardware virtualization driver             |
+------------------+--------------------------------------------+
| `qemu`_          | hardware virtualization driver             |
+------------------+--------------------------------------------+
| `docker`_        | container lifecycle tools                  |
+------------------+--------------------------------------------+
| `kubectl`_       | kubernetes management tools                |
+------------------+--------------------------------------------+
| `terraform`_     | kubernetes infrastructure automation       |
+------------------+--------------------------------------------+
| `helm`_          | kubernetes package manager                 |
+------------------+--------------------------------------------+
| `argocd`_        | argocd cli                                 |
+------------------+--------------------------------------------+
| `istioctl`_      | istio cli                                  |
+------------------+--------------------------------------------+
| `kn`_            | knative cli                                |
+------------------+--------------------------------------------+
| `func`_          | knative functions cli                      |
+------------------+--------------------------------------------+
| `kcat`_          | kafka cli                                  |
+------------------+--------------------------------------------+

----------------
 initialization
----------------

The cluster is initialized using `waves`_; ArgoCD waits for healthy resources at each wave before continuing.

+-------------------------------------+---------+-----------------------------------------+
| description                         | wave    | resources                               |
+=====================================+=========+=========================================+
| project                             | -200    | ``AppProject``                          |
+-------------------------------------+---------+-----------------------------------------+
| istio definitions & resources       | -190    | ``base``                                |
+-------------------------------------+---------+-----------------------------------------+
| istio daemon                        | -180    | ``istiod``                              |
+-------------------------------------+---------+-----------------------------------------+
| istio ingress gateway               | -170    | ``gateway``                             |
+-------------------------------------+---------+-----------------------------------------+
| certificate operator                | -160    | ``cert-manager``                        |
+-------------------------------------+---------+-----------------------------------------+
| cluster issuer & ca certificate     | -150    | ``ClusterIssuer``, ``Certificate``      |
+-------------------------------------+---------+-----------------------------------------+
| certificates                        | -140    | ``Certificate``                         |
+-------------------------------------+---------+-----------------------------------------+
| kiali                               | -130    | ``kiali-operator``                      |
+-------------------------------------+---------+-----------------------------------------+
| gateways                            | -120    | ``Gateway``                             |
+-------------------------------------+---------+-----------------------------------------+
| virtual services                    | -110    | ``VirtualService``                      |
+-------------------------------------+---------+-----------------------------------------+
| peer authentication                 | -100    | ``PeerAuthentication``                  |
+-------------------------------------+---------+-----------------------------------------+
| knative operator                    | -90     | ``knative-operator``                    |
+-------------------------------------+---------+-----------------------------------------+
| knative serving                     | -80     | ``knative-serving``                     |
+-------------------------------------+---------+-----------------------------------------+
| knative eventing                    | -70     | ``knative-eventing``                    |
+-------------------------------------+---------+-----------------------------------------+
| prometheus & grafana                | -60     | ``kube-prometheus-stack``               |
+-------------------------------------+---------+-----------------------------------------+
| minio                               | -50     | ``minio``                               |
+-------------------------------------+---------+-----------------------------------------+
| loki                                | -40     | ``loki-distributed``                    |
+-------------------------------------+---------+-----------------------------------------+
| tempo                               | -30     | ``tempo-distributed``                   |
+-------------------------------------+---------+-----------------------------------------+
| promtail                            | -20     | ``promtail``                            |
+-------------------------------------+---------+-----------------------------------------+
| kafka                               | -10     | ``strimzi-kafka-operator``              |
+-------------------------------------+---------+-----------------------------------------+
|                                     | 0       |                                         |
+-------------------------------------+---------+-----------------------------------------+


---------------
 configuration
---------------

---------
 install
---------

#. ::

    terraform init

#. ::

    terraform plan

#. ::

    terraform apply

#. ::

    kubectl apply -f files/manifest.yaml

--------------
 post-install
--------------

^^^^^^^^^^^^^^
 enable https
^^^^^^^^^^^^^^

#. ::

    kubectl get -n cert-manager secret istio-ca -ogo-template='{{index .data "tls.crt"}}' | base64 -d > ca.pem

#. add cert to browser

^^^^^^^^^^^^^^^^
 enable ingress
^^^^^^^^^^^^^^^^

#. open new terminal window
#. ::

    minikube tunnel

^^^^^^^^^^^^
 enable dns
^^^^^^^^^^^^

#. get ``external-ip``::

    kubectl get -n istio-ingress services

#. ::

    sudo nano /etc/hosts

#. add records::

    <external-ip> argocd.development.local.generic-infrastructure.com
    <external-ip> grafana.development.local.generic-infrastructure.com
    <external-ip> kiali.development.local.generic-infrastructure.com
    <external-ip> minio.development.local.generic-infrastructure.com
    <external-ip> api.development.local.generic-infrastructure.com

^^^^^^^^^^^^^
 enable disk
^^^^^^^^^^^^^

#. ::

    minikube ssh

#. ::

    sudo chmod o+rwx /data/*

-----------
 uninstall
-----------

#. ::

    terraform destroy

-------------------
 uninstall (force)
-------------------

#. ::

    minikube delete


-------
 graph
-------

#. ::

    terraform graph -type=plan | sfdp -Tsvg > graph.svg

--------------
 applications
--------------

* `argocd login`_
    * ``admin``
    * ``test``
* `grafana login`_
    * ``admin``
    * ``prom-operator``
* `kiali login`_
    * ``kubectl -n istio-system create token kiali-service-account``
* `minio login`_
    * ``admin``
    * ``testtesttest``

-----------------
 troubleshooting
-----------------

^^^^^^^^
 driver
^^^^^^^^

* kvm2 fix-all
#. ::

    rm -r ~/.minikube

#. ::

    minikube start --driver=kvm2

#. ::

    minikube delete

* qemu2 fix-all
#. ::

    rm -r ~/.minikube

#. ::

    minikube start --driver=qemu2

#. ::

    minikube delete

^^^^^
 dns
^^^^^

* argocd
#. ::

    kubectl port-forward -n argocd services/argo-cd-argocd-server 8080:443

..
    links for dependencies
.. _minikube: https://minikube.sigs.k8s.io/docs/
.. _kvm: https://www.linux-kvm.org/page/Main_Page
.. _qemu: https://www.qemu.org/
.. _docker: https://docs.docker.com/
.. _kubectl: https://kubernetes.io/docs/reference/kubectl/kubectl/
.. _terraform: https://www.terraform.io/
.. _helm: https://helm.sh/docs/
.. _argocd: https://argo-cd.readthedocs.io/en/stable/cli_installation/
.. _istioctl: https://istio.io/latest/docs/setup/install/istioctl/
.. _kn: https://knative.dev/docs/client/
.. _func: https://knative.dev/docs/client/
.. _kcat: https://github.com/edenhill/kcat

..
    links for initialization
.. _waves: https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/

..
    links for applications
.. _argoCD login: https://argocd.development.local.generic-infrastructure.com
.. _grafana login: https://grafana.development.local.generic-infrastructure.com
.. _kiali login: https://kiali.development.local.generic-infrastructure.com
.. _minIO login: https://minio.development.local.generic-infrastructure.com
