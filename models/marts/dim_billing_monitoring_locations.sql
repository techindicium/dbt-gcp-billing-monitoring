{{ config(
    materialized='table'
    , partition_by={
        'field': 'location_sk'
        , 'data_type': 'int64'
        , "range": {
           "start": -9223372036854775807
           , "end": 9223372036854775807
           , "interval": 18446744073709500
       }
    }
    , cluster_by=['location_country', 'location_region', 'location_zone']
) }}

with
    locations as (
        select distinct
            location_location
            , location_country
            , location_region
            , location_zone
        from {{ ref('stg_billing_monitoring_gcp_billing_export') }}
    )
    , locations_with_sk as (
        select distinct
            {{ numeric_surrogate_key([
                'location_location'
                , 'location_region'
                , 'location_zone'
            ]) }} as location_sk
            , *
        from locations
    )
select *
from locations_with_sk