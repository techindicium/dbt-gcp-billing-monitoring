# GCP Billing Monitoring

This package allows you to easily monitor and manage your BigQuery cloud service and usage costs to help improving the billing management of your project.

## Before creating a branch

Pay attention, it is very important to know if your modification to this repository is a release (breaking changes), a feature (functionalities) or a patch(to fix bugs).
With that information, create your branch name like this:

* ```release/<branch-name>```
* ```feature/<branch-name> ```
* ```patch/<branch-name>```

# :running: Quickstart

New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).

## Requirements
dbt version
* ```dbt version >= 1.0.0```

dbt_utils package. Read more about them [here](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/).
* ```dbt-labs/dbt_utils version: 0.8.0```

## Installation

1. Include this package in your `packages.yml` file.
```yaml
packages:
  - git: "git@github.com/techindicium/dbt-gcp-billing-monitoring.git" # insert git URL
```

2. Run `dbt deps` to install the package.


## Configuring models package

The package's models can be configured in your `dbt_project.yml` by specifying the package under `models` node. The billing data's start date you want to monitor also must be declared in vars node.

### Models

```yaml
models:
    gcp_billing_monitoring:
        staging:
            materialized: ephemeral
        marts:
            materialized: table
```
### Vars

```yaml
vars:
    gcp_billing_monitoring:
       gcp_billing_monitoring_start_date: cast('2023-01-01' as date) # inside the double quotes, add the start date of the project
```

## Configuring project sources

The project's sources can be configured in your `source.yml`, normally on your staging folder, by specifying the schema and table names of your billing data table. Since the name can be different by project, a name configuration is needed to ensure your package works.

### Source configuration

```yaml
sources:

  - name: gcp_billing
    description: "Data source containing billing information extracted from Google BigQuery."
    schema: sandbox_varejo_billing # add the name of your schema where the billing data will be stored
    tables:
      - name: table_name_gcp_billing_export_resource # add the billing export table name
        description: "This table contains daily statistics from the organization's BigQuery billing."
        columns:
```

## Running the models

After setting up the package in `dbt_project.yml` and `source.yml` as the previous steps, you can now run the package with the following command line: `dbt run -m gcp_billing_monitoring`. After running it, the 7 models of the package will materialize in your target schema as they have been configured.


## New releases

Want a new release (major/minor/patch) ?
1. Push your modifications to main
2. Push the tag you want, example: "git tag v1.0.1"
3. git push origin tag v1.0.1 or git push --tags (warning: It pushes all tags you have)