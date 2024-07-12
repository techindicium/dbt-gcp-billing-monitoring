{% set my_query %}
    select cast({{dbt.current_timestamp()}} as date)
{% endset %}

{% if execute %}
    {% set today = run_query(my_query).columns[0].values()[0] %}
    {% set tomorrow = dbt.dateadd('day', 1, "'" ~ today ~ "'") %}
    {% set start_date = var('gcp_billing_monitoring')['gcp_billing_monitoring_start_date'] %}
    {% else %}
    {% set tomorrow = ' ' %}
    {% set start_date = ' ' %}
{% endif %}

{{ dbt_utils.date_spine(
    datepart="day",
    start_date=start_date,
    end_date=tomorrow
)
}}