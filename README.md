# Spot Ocean Controller Terraform Module

A Terraform module to install Ocean Controller.

## Table of Contents

- [Usage](#usage)
- [Examples](#examples)
- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Documentation](#documentation)
- [Getting Help](#getting-help)
- [Community](#community)
- [Contributing](#contributing)
- [License](#license)

## Usage

```hcl
module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  # Credentials.
  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  # Configuration.
  cluster_identifier = var.cluster_identifier
}
```

## Examples

- [Simple Installation](https://github.com/spotinst/terraform-spotinst-ocean-controller/tree/master/examples/simple-installation)
- [Azure Installation](https://github.com/spotinst/terraform-spotinst-ocean-controller/tree/master/examples/azure-installation)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_deployment.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_job.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_secret.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acd_identifier"></a> [acd\_identifier](#input\_acd\_identifier) | A unique identifier used by the Ocean AKS Connector when importing an AKS cluster | `string` | `null` | no |
| <a name="input_aks_connector_enabled"></a> [aks\_connector\_enabled](#input\_aks\_connector\_enabled) | Controls whether the Ocean AKS Connector should be deployed (requires a valid `acd_identifier`) | `bool` | `true` | no |
| <a name="input_aks_connector_image"></a> [aks\_connector\_image](#input\_aks\_connector\_image) | Set the Docker image name for the Ocean AKS Connector that should be deployed | `string` | `"spotinst/ocean-aks-connector"` | no |
| <a name="input_aks_connector_version"></a> [aks\_connector\_version](#input\_aks\_connector\_version) | Set the Docker version for the Ocean AKS Connector that should be deployed | `string` | `"1.0.8"` | no |
| <a name="input_base_url"></a> [base\_url](#input\_base\_url) | Base URL to be used by the HTTP client | `string` | `""` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | Cluster identifier | `string` | n/a | yes |
| <a name="input_controller_image"></a> [controller\_image](#input\_controller\_image) | Set the Docker image name for the Ocean Controller that should be deployed | `string` | `"gcr.io/spotinst-artifacts/kubernetes-cluster-controller"` | no |
| <a name="input_controller_version"></a> [controller\_version](#input\_controller\_version) | Set the Docker version for the Ocean Controller that should be deployed | `string` | `"1.0.77"` | no |
| <a name="input_create_controller"></a> [create\_controller](#input\_create\_controller) | Controls whether the Ocean Controller should be deployed (it affects all resources) | `bool` | `true` | no |
| <a name="input_disable_auto_update"></a> [disable\_auto\_update](#input\_disable\_auto\_update) | Disable the auto-update feature | `bool` | `false` | no |
| <a name="input_enable_csr_approval"></a> [enable\_csr\_approval](#input\_enable\_csr\_approval) | Enable the CSR approval feature | `bool` | `false` | no |
| <a name="input_image_pull_policy"></a> [image\_pull\_policy](#input\_image\_pull\_policy) | Image pull policy (one of: Always, Never, IfNotPresent) | `string` | `"Always"` | no |
| <a name="input_image_pull_secrets"></a> [image\_pull\_secrets](#input\_image\_pull\_secrets) | List of references to secrets in the same namespace to use for pulling the image | `list(string)` | `[]` | no |
| <a name="input_proxy_url"></a> [proxy\_url](#input\_proxy\_url) | Proxy server URL to communicate through | `string` | `""` | no |
| <a name="input_resources_limits"></a> [resources\_limits](#input\_resources\_limits) | Definition of the maximum amount of compute resources allowed | `map(any)` | `null` | no |
| <a name="input_resources_requests"></a> [resources\_requests](#input\_resources\_requests) | Definition of the minimum amount of compute resources required | `map(any)` | `null` | no |
| <a name="input_spotinst_account"></a> [spotinst\_account](#input\_spotinst\_account) | Spot account ID | `string` | n/a | yes |
| <a name="input_spotinst_token"></a> [spotinst\_token](#input\_spotinst\_token) | Spot Personal Access token | `string` | n/a | yes |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | List of additional `toleration` objects, see: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod#toleration | `list(any)` | <pre>[<br>  {<br>    "effect": "NoExecute",<br>    "key": "node.kubernetes.io/not-ready",<br>    "operator": "Exists",<br>    "toleration_seconds": 150<br>  },<br>  {<br>    "effect": "NoExecute",<br>    "key": "node.kubernetes.io/unreachable",<br>    "operator": "Exists",<br>    "toleration_seconds": 150<br>  }<br>]</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Documentation

If you're new to [Spot](https://spot.io/) and want to get started, please checkout our [Getting Started](https://docs.spot.io/connect-your-cloud-provider/) guide, available on the [Spot Documentation](https://docs.spot.io/) website.

## Getting Help

We use GitHub issues for tracking bugs and feature requests. Please use these community resources for getting help:

- Ask a question on [Stack Overflow](https://stackoverflow.com/) and tag it with [terraform-spotinst](https://stackoverflow.com/questions/tagged/terraform-spotinst/).
- Join our [Spot](https://spot.io/) community on [Slack](http://slack.spot.io/).
- Open an issue.

## Community

- [Slack](http://slack.spot.io/)
- [Twitter](https://twitter.com/spot_hq/)

## Contributing

Please see the [contribution guidelines](CONTRIBUTING.md).

## License

Code is licensed under the [Apache License 2.0](LICENSE).
