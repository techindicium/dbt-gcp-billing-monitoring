{{ config(
    materialized='table'
    , partition_by={
       'field': 'billing_date'
       , 'data_type': 'date'
    }
    , cluster_by=['service_fk', 'sku_fk', 'location_fk', 'billing_date']
) }}

with
    source as (
        select
            billing_account_id
            , billing_date
            , service_id
            , sku_id
            , project_id
            , project_number
            , location_location
            , location_region
            , location_zone
            , resource_name
            , resource_global_name
            , labels_key
            , labels_value
            , usage_start_time
            , usage_end_time
            , export_date
            , invoice_month
            , usage_amount
            , usage_unit
            , usage_pricing_units
            , usage_amount_in_pricing_units
            , cost
            , currency
            , currency_conversion_rate
            , cost_type
        from {{ ref('stg_billing_monitoring_gcp_billing_export') }}
    )
    , utils_days as (
        select cast(date_day as date) as date_day
        from {{ ref('dbt_utils_days') }}
    )
    , dim_locations as (
        select
            location_sk
            , location_location
        from {{ ref('dim_billing_monitoring_locations') }}
    )
    , dim_projects as (
        select
            project_sk
            , project_id
        from {{ ref('dim_billing_monitoring_projects') }}
    )
    , dim_services as (
        select
            service_sk
            , service_id
        from {{ ref('dim_billing_monitoring_services') }}
    )
    , dim_skus as (
        select
            sku_sk
            , sku_id
        from {{ ref('dim_billing_monitoring_skus') }}
    )
    , joined as (
        select
            {{ numeric_surrogate_key([
                'source.billing_account_id'
                , 'dim_services.service_sk'
                , 'dim_skus.sku_sk'
                , 'dim_projects.project_sk'
                , 'dim_locations.location_sk'
                , 'source.billing_date'
            ]) }} as billing_sk
            , dim_services.service_sk as service_fk
            , dim_skus.sku_sk as sku_fk
            , dim_projects.project_sk as project_fk
            , dim_locations.location_sk as location_fk
            , utils_days.date_day as billing_date
            , source.usage_start_time
            , source.usage_end_time
            , source.invoice_month
            , source.labels_value
            , source.usage_amount
            , source.usage_unit
            , source.usage_pricing_units
            , source.usage_amount_in_pricing_units
            , source.cost
            , source.currency
            , source.currency_conversion_rate
            , source.cost_type
        from source
        left join utils_days on source.billing_date = utils_days.date_day
        left join dim_locations on source.location_location = dim_locations.location_location
        left join dim_projects on source.project_id = dim_projects.project_id
        left join dim_services on source.service_id = dim_services.service_id
        left join dim_skus on source.sku_id = dim_skus.sku_id
    )
    , aggregated as (
        select
            billing_sk
            , project_fk
            , service_fk
            , sku_fk
            , location_fk
            , billing_date
            , sum(usage_amount) as usage_amount
            , usage_unit
            , sum(usage_amount_in_pricing_units) as usage_amount_in_pricing_units
            , usage_pricing_units
            , sum(cost) as total_cost
        from joined
        group by
            billing_sk
            , project_fk
            , service_fk
            , sku_fk
            , location_fk
            , billing_date
            , usage_unit
            , usage_pricing_units
    )
select *
from aggregated