# GCP Billing Monitoring

This package allows you to easily monitor and manage your BigQuery cloud service costs, as well as the usage, to finally identify where the resources are   helpful info to improve your data pipeline.

Facilitar o monitoramento e gerenciamento de custos dos serviços do BigQuery, bem como seu uso, a fim de identificar onde estão os maiores gastos com a cloud.

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
  - git: "https://github.com/techindicium/dbt-gcp-billing-monitoring.git" # insert git URL
```

2. Run `dbt deps` to install the package.



## Configuring models package

The package's models can be configured in your `dbt_project.yml` by specifying the package under `models` and the start date of the airflow monitoring data must be declared in vars.

# Model node

```
models:
    gcp_billing_monitoring:
        staging:
            materialized: ephemeral
        marts:
            materialized: table
        tags:
            - 'gcp_billing'
```

# Vars

```
vars:
    gcp_billing_monitoring:
       gcp_billing_monitoring_start_date: cast('2023-01-01' as date) <------------ in the double quotes you add the start date of the project
```

## Configuring project sources

The project's sources can be configured in your `source.yml`, normally on your staging folder, by specifying the schema and table names of your billing data table. Since the name can be different by project, a name configuration is needed to ensure your package works.

# Source configuration

```
sources:

  - name: gcp_billing
    description: "Data source containing billing information extracted from Google BigQuery."
    schema: sandbox_varejo_billing <------------ here you add the name of your schema where the billing data will be stored
    tables:
      - name: table_name_gcp_billing_export_resource <------------ here you add the billing export table name
        description: "This table contains daily statistics from the organization's BigQuery billing."
        columns:
```