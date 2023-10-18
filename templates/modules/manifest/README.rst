==========
 manifest
==========

:Authors: caerulescens <caerulescens.github@proton.me>
:Description:

--------------
 dependencies
--------------

+------------------+--------------------------------------------+
| dependency       | description                                |
+==================+============================================+
| `kubectl`_       | kubernetes management tools                |
+------------------+--------------------------------------------+
| `terraform`_     | kubernetes infrastructure automation       |
+------------------+--------------------------------------------+

---------
 install
---------

#. ::

    terraform init

#. ::

    terraform plan

#. ::

    terraform apply

-------
 usage
-------

#. apply::

    kubectl apply -f files/manifest.yaml

#. delete::

    kubectl delete -f files/manifest.yaml


.. _kubectl: https://kubernetes.io/docs/reference/kubectl/kubectl/
.. _terraform: https://www.terraform.io/
