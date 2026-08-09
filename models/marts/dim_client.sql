with clients as (
    select distinct client from {{ ref('stg_ventes') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['client']) }} as client_key,
    client
from clients