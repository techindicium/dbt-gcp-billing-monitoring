{{ config(
    materialized='table'
    , partition_by={
        'field': 'sku_sk'
        , 'data_type': 'int64'
        , "range": {
           "start": -9223372036854775807
           , "end": 9223372036854775807
           , "interval": 18446744073709500
       }
    }
    , cluster_by=['sku_id']
) }}

with
    skus as (
        select distinct
            sku_id
            , sku_description
        from {{ ref('stg_billing_monitoring_gcp_billing_export') }}
    )
    , skus_with_sk as (
        select distinct
            {{ numeric_surrogate_key(['sku_id']) }} as sku_sk
            , sku_id
            , sku_description
        from skus
    )
select *
from skus_with_sk