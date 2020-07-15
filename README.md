# ghost-terrform

Provision an instance of [Ghost](https://github.com/TryGhost/Ghost) on Kubernetes using Terraform.

This will create a single pod running Ghost using a persistent disk for the content, and a
load balancer for the service.

A certificate is not provisioned. You will need to provide one for yourself, using a cloud provided
one, or using [`cert-manager`](https://cert-manager.io/) to provision a Let's Encrypt certificate.

## Required variables

* `name` - Name of the blog, e.g. "myblog". Must be unique.
* `namespace` - Kubernetes namespace to create and place resources in, e.g. "myblog". Must be unique.
* `url` - URL of the blog, e.g. https://myblog.com.

Check out `variables.tf` for other variables that can be changed.

## TODO

More flexibility in deployment, e.g. allow specifying different storage types, and play nicely with
nginx ingress controller instead of provisioning a load balancer.