# Spotinst Ocean Controller Terraform module

A Terraform module to install Ocean Controller.

## Contents

  - [Usage](#usage)
  - [Examples](#examples)
  - [Resources](#resources)
  - [Variables](#variables)
  - [Documentation](#documentation)
  - [Getting Help](#getting-help)
  - [Community](#community)
  - [License](#license)

## Usage

```hcl
module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"

  # Credentials.
  spotinst_token   = "<spotinst_token>"
  spotinst_account = "<spotinst_account>"

  # Configuration.
  cluster_identifier = "<cluster_identifier>"
}
```

## Examples

  - [Basic](examples/basic)

## Resources

This module creates and manages the following resources:
- kubernetes_config_map
- kubernetes_service_account
- kubernetes_cluster_role
- kubernetes_cluster_role_binding
- kubernetes_deployment

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| spotinst_token | Spotinst Personal Access token | `string` | none | yes |
| spotinst_account | Spotinst account ID | `string` | none | yes |
| cluster_identifier | Cluster identifier | `string` | none | yes |
| base_url | Base URL to be used by the HTTP client | `string` | none | no |
| proxy_url | Proxy server URL to communicate through | `string` | none | no |
| enable_csr_approval | Enable the CSR approval feature | `bool` | false | no |
| disable_auto_update | Disable the auto-update feature | `bool` | false | no |

## Documentation

If you're new to [Spot](https://spot.io/) and want to get started, please checkout our [Getting Started](https://api.spotinst.com/getting-started-with-spotinst/) guide, available on the [Spot Documentation](https://api.spotinst.com/) website.

## Getting Help

We use GitHub issues for tracking bugs and feature requests. Please use these community resources for getting help:

* Ask a question on [Stack Overflow](https://stackoverflow.com/) and tag it with [terraform-spotinst](https://stackoverflow.com/questions/tagged/terraform-spotinst/).
* Join our [Spot](https://spot.io/) community on [Slack](http://slack.spotinst.com/).
* Open an issue.

## Community

* [Slack](http://slack.spotinst.com/)
* [Twitter](https://twitter.com/spotinst/)

## License
Code is licensed under the [Apache License 2.0](LICENSE).
