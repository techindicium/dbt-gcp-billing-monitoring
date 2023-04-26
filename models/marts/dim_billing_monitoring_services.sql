{{ config(
    materialized='table'
    , partition_by={
        'field': 'service_sk'
        , 'data_type': 'int64'
        , "range": {
           "start": -9223372036854775807
           , "end": 9223372036854775807
           , "interval": 18446744073709500
       }
    }
    , cluster_by=['service_id']
) }}

with
    services as (
        select distinct
            service_id
            , service_description
        from {{ ref('stg_billing_monitoring_gcp_billing_export') }}
    )
    , services_with_sk as (
        select distinct
            {{ numeric_surrogate_key(['service_id']) }} as service_sk
            , service_id
            , service_description
        from services
    )
select *
from services_with_sk