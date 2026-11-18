---
title: "How We Leverage Kubernetes to Deploy Our Cloud Infra"
date: 2025-09-19T10:44:40+02:00
draft: false
notice: "This post was originally published on the Flink Tech Blog."
---

{{< figure
src="/assets/k8s-cloud-infra-cover.png"
alt="A pink Ferris wheel with the Kubernetes helm logo at its hub" >}}

At Flink, Kubernetes and Google Cloud are at the heart of our platform. With resources spread across more than a hundred GCP projects, we had the need for automation around how we interact with the cloud, and how we provision and manage the lifecycle of our resources. To build this automation, initially we relied on building everything around Terraform and brought together a solution of 3rd party tools and our custom code on top.

One particular pain point was maintaining two separate tech stacks largely overlapping in functionality. We found ourselves managing numerous Terraform states, handling authN & authZ, reconciling and managing drifts, working on change management, GitOps, provider updates, and a host of UX problems for Terraform once and then for Kubernetes as well, and maintaining them side by side. If only we could reuse some of what we already have… 🙄

## Now we have our problem statement

So, let’s break down what we were really trying to achieve. Our goals were to:

- Make use of the existing ecosystem rather than build and maintain everything twice.
- Provide a familiar ecosystem and interface to our developers. (Kubernetes, YAML)
- Move provisioning closer to service owners.
- Improve developer experience. 🚀

With these goals in mind, we started looking elsewhere for an alternative approach.

Today I’ll tell you a bit about what we’ve tried, how it helped us, and how it might benefit you as well.

## WDYM “Leverage Kubernetes”? 🤔

Lately there has been an influx of products that offer managing cloud resources as Kubernetes resources, by defining [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) and through controllers serving as the engine. Users simply use standard Kubernetes tooling to interact with their cloud, and *`kubectl create`* their resources in the cloud just like any other Kubernetes resource.

[Config Connector](https://cloud.google.com/config-connector/docs/overview) is Google Cloud’s own offering that does just that, and what we are using at Flink to deliver cloud provisioning to our teams, helping them provision and manage their cloud resources as smoothly as we can.

With this kind of setup, when you use Kubernetes for provisioning, you define resources in YAML, apply them the usual way you’d apply any change to your cluster, and a controller in the cluster ensures that the configuration in Kubernetes matches the reality in the cloud. In other words, it reconciles the desired state in the cluster with the actual state in the cloud.

So, if you create a GCS Bucket resource in Kubernetes, its state is kept in *etcd* like any other resource, and the bucket is created in your cloud. Once you update this bucket in Kubernetes, your changes are immediately and continuously reconciled to the cloud, and if you delete the bucket object in Kubernetes, the bucket is deleted from the cloud.[^1]

Put simply, instead of this:

```hcl
# HCL (Terraform)
resource "google_storage_bucket" "my-bucket-1" { 
 name = "my-bucket-1"
 storage_class = "STANDARD"
 versioning {
 enabled = true
 }
}
```

Config Connector lets you do this:

```yaml
# YAML
apiVersion: storage.cnrm.cloud.google.com/v1beta1
kind: StorageBucket
metadata:
  name: my-bucket-1
  namespace: platform-sandbox # by default, = GCP project name 
spec:
  storageClass: STANDARD
  versioning:
  enabled: false
```

With that, we get:

- storage for our state
- a backend that listens for our API calls
- continuous reconciliation of code and configuration

for *free*, that is if we already have a Kubernetes cluster.

But that’s not even all that we get to reuse from what Kubernetes offers. Here’s an incomplete list of what we get by using Kubernetes in this way, out of the box:

### Continuous reconciliation

Already mentioned, reconciliation of configuration and reality is what Kubernetes already does, now it applies to your cloud infrastructure.

No more drifts because of a momentary interruption of a CI workflow, the controller takes care of ensuring configuration is applied to prevent accumulation of drift.

### Authentication & Authorization

We use GKE. GKE already knows who I am, and can check my membership to the Google Groups we already have. Kubernetes on GKE already has RBAC enabled, authorization is already built-in.

Enabling a team to manage their own pub-sub topics in their own GCP project is now just doing this:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pubsub-topic-editor
rules:
  apiGroups:
    - pubsub.cnrm.cloud.google.com
  resources:
    - pubsubtopics
  verbs: ["get", "list", "create", "update", "patch", "delete"]
--
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pubsub-topic-editor
  namespace: payment-team
  roleRef:
  # […]
  subjects:
  - apiGroup: rbac.authorization.k8s.io
  kind: "Group"
  name: "payment-team@example.com"
  namespace: payment-team
```

Ta da! ✨ You can grant access to your already existing Groups and Users in Kubernetes to read/write, and structure boundaries per namespace, without needing to do anything extra.

### YAML

May not be a *“plus”* depending on who you ask, though having the lowest common denominator as the standard interface makes onboarding *far* easier.

Config Connector also doesn’t have many bells and whistles in its CRs, getting a developer who is already familiar with Kubernetes to use Config Connector is probably easier than most other options.

### API Server

Since we’re running on Kubernetes, there is already a backend working for us. Any other automation that we want to integrate with our Infrastructure as Code tool, can simply make requests to Kubernetes API server.

### State storage

We don’t need to handle many remote states and juggle between them, now everything is neatly stored in *etcd*.

This is also nice since Kubernetes has the capability to hold Secrets, and with 3rd party controllers (or your own) you can synchronize secrets from pretty much anywhere else to your cluster and use them in your Config Connector resources.

### Support for many Google Cloud resources

A full list of it is available [here.](https://cloud.google.com/config-connector/docs/reference/overview) (That’s a long sidebar on the left!)

## Standing on the shoulders of giants

{{< figure
src="/assets/k8s-cloud-infra-cncf-landscape.png"
alt="A slice of the CNCF landscape map"
caption="The complete CNCF map wouldn’t fit here 🙂" >}}

One major advantage of setting up our Infrastructure as Code platform this way is to be able to use what already exists out there for Kubernetes in a different way.

This means whatever we might already use for Kubernetes, we can reuse them here, and we’re saved from re-inventing them again, or maintaining two solutions largely solving the same problems.

When we backup Kubernetes state, we’ve also backed up our IaC state. The same way we monitor Kubernetes resources, we can monitor our IaC resources. Third party tooling that exists for Kubernetes, also exists now for our cloud infrastructure. It has enabled us to significantly reduce our tech footprint, and reduce maintenance and onboarding burden. Once you reuse, there’s simply less to know and care for. It also unlocks new opportunities.

At Flink, we already opted to use:

- ArgoCD for continuous deployments
- Helm to package solutions and re-use them organization-wide
- ExternalSecrets, to synchronize secrets from the cloud to the cluster
- Kyverno for policy checking
- … Probably a few that I’m missing from the [CNCF map.](https://landscape.cncf.io/)

Being able to use these tools that we already had in our toolbox has been probably the biggest benefit of using Kubernetes this way. Not only that our developers were more familiar with this ecosystem, and we were saved from building the same functionality elsewhere, but also whenever we improved anything we use from the Kubernetes ecosystem, we also got a free improvement for our cloud provisioning infrastructure.

### ArgoCD

{{< figure
src="/assets/k8s-cloud-infra-argocd.png"
alt="ArgoCD application tree showing Config Connector resources"
caption="Normally you’d see Deployments and CronJobs here. Today it’s also SQLDatabases and SecretManagerSecrets." >}}

We already had ArgoCD for the usual Kubernetes resources, so we simply started using it for infrastructure. This enabled us to:

- Do GitOps right away and synchronize what is in Git with what is in the cloud
- Run diffs between incoming changes in PRs and what is in the cluster
- Use history and rollbacks[^2]
- Present a nice UI to everyone in the organization, RBAC and SSO enabled.
- Enable/disable auto-syncs to freely switch between CD and manual verification gates.
- Make use of observability and alerting we’ve already had for unhealthy ArgoCD Applications, and reuse them for our cloud resources as well.

### Helm

{{< figure
src="/assets/k8s-cloud-infra-helm-values.png"
alt="A simplified Helm values.yaml next to the Kubernetes resources it renders"
caption="On the left, a `values.yaml` as a simplified YAML interface. On the right, actual Kubernetes resources." >}}

Just like a module in Terraform or a CDK library for CloudFormation, since we already have Helm for workloads, we simply have another chart for cloud infrastructure that covers our organization-wide best practices and solutions, so we don’t reinvent the wheel over and over again.

To improve the quality of our charts, we have also implemented JSONSchema validations, automatic document generation and snapshot tests, and along with the theme of reusing what we have, these improvements applied to both Kubernetes resources and Google Cloud resources.

### ExternalSecrets

There are many ways to handle secrets management, we’ve opted to synchronize our secrets from another secure vault. Be it an environment variable for one of our Deployments, or an API key or password for one of our infrastructure components, we solve the problem the same way.

### Policy checking

{{< figure
src="/assets/k8s-cloud-infra-policy-checking.png"
alt="An admission controller rejecting an SQLDatabase in us-central1 because the policy only allows eu-west3" >}}

There are many alternatives in this area: Google’s own GCP Policy Controller (based on Gatekeeper), Gatekeeper itself, Kyverno, Kubewarden… just to name a few.

Since admission controllers are already a thing in Kubernetes, we are enabled to simply define our policies for our controller, and have it ensure compliance, generate audit reports and enforce policies for infrastructure changes. If you want everyone to set their bucket’s *`location`* to `EU`, you can make sure that it happens.

Having well defined policies means shifting governance to the server side rather than the client’s, and your developers now have freedom in how they structure their code and define their resources. It also gives your platform team some space from incoming requests, and gives everyone an additional layer of confidence.

### Okay, is it really all 🌞 and 🌈 ?

Nothing is. 😔

While we are pretty happy with Config Connector as it is and reap the benefits, there are at least a few drawbacks to consider before you jump in:

- Config Connector is exclusively Google Cloud. If you have any desire to go multi-cloud, Config Connector isn’t it.
- While Config Connector [is open source](https://github.com/GoogleCloudPlatform/k8s-config-connector) and covers a pretty large area in its support for resources, as far as I could tell, it’s not easily extendable in the way some of its alternatives are.
- [Composition](https://docs.crossplane.io/v1.11/concepts/composition/) in the style of *Crossplane* is not offered. While it seems to be a powerful feature, we also haven’t felt the lack of it as an issue. It seems to be heavily promoted in their comparison pages though, and might be relevant to your use cases.
- Compared to Terraform, lack of “[data sources](https://developer.hashicorp.com/terraform/language/data-sources)” and the way referencing works might feel a bit limiting. Though since we generate our resources through another tool, we could still do it there. Also, in our case we haven’t felt the need for it.

### Why use Config Connector and not Crossplane? 🤔

Crossplane is a perfectly viable choice as well.

We had two points in favour of Config Connector, neither being technical ones:

- We already had a support channel with GCP. We’d either be on our own with Crossplane, or possibly setup and pay for another vendor.
- Both products were offered for free, but GCP had less reasons to monetize theirs in the future. They already made money whenever someone creates something through Config Connector.

That being said, Crossplane seems to offer more features and it’s cloud-agnostic, both might be more important in your use cases. Consider this article more about the approach in general, and less about the particular product.

### TL;DR

{{< figure
src="/assets/k8s-cloud-infra-the-flow.png"
alt="A values.yaml change in a pull request, its Config Connector diff posted by a bot, and ArgoCD syncing it to Google Cloud"
caption="The Flow" >}}

This approach enabled us to re-use what Kubernetes already offers, and benefit from the large and ever expanding ecosystem around it to improve our cloud provisioning experience. Even if this specific solution is not for you, it might be beneficial, or at least fun, to consider the possibilities.

[^1]: By default. This is configurable with deletion policies, if you are (rightly) afraid of accidentally deleting important resources.

[^2]: A semi-related note: Regardless of what you deploy with ArgoCD, be it a Deployment or SQLDatabase, you’ll want to be careful with how Rollbacks interact with AutoSync. If AutoSync is enabled as you do a Rollback, after some (short) time it may accidentally roll forward.
