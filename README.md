# Spot Ocean Controller Terraform Module

A Terraform module to install Ocean Controller.

## Contents

- [Usage](#usage)
- [Examples](#examples)
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

- kubernetes_secret
- kubernetes_config_map
- kubernetes_service_account
- kubernetes_cluster_role
- kubernetes_cluster_role_binding
- kubernetes_deployment

## Inputs

| Name                | Description                             | Type     | Default | Required |
| ------------------- | --------------------------------------- | -------- | ------- | :------: |
| spotinst_token      | Spot Personal Access token              | `string` | none    |   yes    |
| spotinst_account    | Spot account ID                         | `string` | none    |   yes    |
| cluster_identifier  | Cluster identifier                      | `string` | none    |   yes    |
| base_url            | Base URL to be used by the HTTP client  | `string` | none    |    no    |
| proxy_url           | Proxy server URL to communicate through | `string` | none    |    no    |
| enable_csr_approval | Enable the CSR approval feature         | `bool`   | false   |    no    |
| disable_auto_update | Disable the auto-update feature         | `bool`   | false   |    no    |

## Outputs

None.

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
