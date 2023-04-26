with
    transformed as (
        select
            billing_account_id
            , service.id as service_id
            , service.description as service_description
            , sku.id as sku_id
            , sku.description as sku_description
            , datetime(usage_start_time, "America/Sao_Paulo") as usage_start_time
            , datetime(usage_end_time, "America/Sao_Paulo") as usage_end_time
            , cast(usage_start_time as date) as billing_date
            , project.id as project_id
            , project.number as project_number
            , project.name as project_name
            , project.labels[safe_offset(0)].key as project_labels_key
            , project.labels[safe_offset(0)].value as project_labels_value
            , project.ancestry_numbers as project_ancestry_numbers
            , project.ancestors[safe_offset(0)].resource_name as project_ancestors_resource_name
            , project.ancestors[safe_offset(0)].display_name as project_ancestors_display_name
            , labels[safe_offset(0)].key as labels_key
            , labels[safe_offset(0)].value as labels_value
            , system_labels[safe_offset(0)].key as system_labels_key
            , case
                when system_labels[safe_offset(0)].key like '%/cores%' then cast(system_labels[safe_offset(0)].value as int64)
                when system_labels[safe_offset(0)].key like '%/memory%' then cast(system_labels[safe_offset(0)].value as int64)
                else null
            end as system_labels_value_int
            , case
                when system_labels[safe_offset(0)].key like '%/machine_spec%' then cast(system_labels[safe_offset(0)].value as string)
            end as system_labels_value_str
            , case
                when location.location like '%us-%' then 'us'
                when location.location like '%asia%' then 'asia'
                when location.location like '%austr%' then 'australia'
                when location.location like '%europe%' then 'europe'
                when location.location like '%me-%' then 'middle east'
                when location.location like '%northam%' then 'canada'
                when location.location like '%southam%' then 'southamerica'
                else location.location
            end as location_location
            , location.country as location_country
            , location.region as location_region
            , location.zone as location_zone
            , resource.name as resource_name
            , resource.global_name as resource_global_name
            , tags[safe_offset(0)].key as tags_key
            , tags[safe_offset(0)].value as tags_value
            , tags[safe_offset(0)].inherited as tags_inherited
            , tags[safe_offset(0)].namespace as tags_namespace
            , datetime(export_time, "America/Sao_Paulo") as export_date
            , cast(cost as numeric) as cost
            , currency
            , cast(currency_conversion_rate as numeric) as currency_conversion_rate
            , cast(usage.amount as numeric) as usage_amount
            , usage.unit as usage_unit
            , cast(usage.amount_in_pricing_units as numeric) as usage_amount_in_pricing_units
            , usage.pricing_unit as usage_pricing_units
            , credits[safe_offset(0)].name as credits_name
            , credits[safe_offset(0)].amount as credits_amount
            , credits[safe_offset(0)].full_name as credits_full_name
            , credits[safe_offset(0)].id as credits_id
            , credits[safe_offset(0)].type as credits_type
            , cast(invoice.month as string) as invoice_month
            , cost_type
            , adjustment_info.id as adjustment_info_id
            , adjustment_info.description as adjustment_info_description
            , adjustment_info.mode as adjustment_info_mode
            , adjustment_info.type as adjustment_info_type
        from {{ source('gcp_billing','gcp_billing_export_resource_v1_017006_67EE6C_8DAC3D') }}
        where project.id = "{{ target.project }}"
    )
select *
from transformed