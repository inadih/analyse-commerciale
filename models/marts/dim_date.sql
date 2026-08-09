{% set date_query %}
    select
        min(date_vente) as min_date,
        max(date_vente) as max_date
    from {{ ref('stg_ventes') }}
{% endset %}

{% set results = run_query(date_query) %}

{% if execute %}
    {% set min_date = results.columns[0].values()[0] %}
    {% set max_date = results.columns[1].values()[0] %}
{% else %}
    {% set min_date = none %}
    {% set max_date = none %}
{% endif %}

with dates as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ min_date ~ "' as date)",
        end_date="dateadd(day, 1, cast('" ~ max_date ~ "' as date))"
    ) }}

)

select
    cast(date_day as date)            as date_key,
    date_day                          as date_complete,
    extract(year    from date_day)    as annee,
    extract(quarter from date_day)    as trimestre,
    extract(month   from date_day)    as mois,
    extract(day     from date_day)    as jour,
    to_char(date_day, 'MMMM')         as nom_mois,
    to_char(date_day, 'YYYY-MM')      as annee_mois
from dates