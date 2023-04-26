{{ config(
    materialized='table'
    , partition_by={
        'field': 'project_sk'
        , 'data_type': 'int64'
        , "range": {
           "start": -9223372036854775807
           , "end": 9223372036854775807
           , "interval": 18446744073709500
       }
    }
    , cluster_by=['project_id']
) }}

with
    projects as (
        select distinct
            project_id
            , project_name
            , project_number
            , project_labels_key
            , project_labels_value
            , project_ancestry_numbers
            , project_ancestors_resource_name
            , project_ancestors_display_name
        from {{ ref('stg_billing_monitoring_gcp_billing_export') }}
    )
    , projects_with_sk as (
        select distinct
            {{ numeric_surrogate_key(['project_id']) }} as project_sk
            , project_id
            , project_name
            , project_number
            , project_labels_key
            , project_labels_value
            , project_ancestry_numbers
            , project_ancestors_resource_name
            , project_ancestors_display_name
        from projects
    )
select *
from projects_with_sk