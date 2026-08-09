with pays as (
    select distinct pays from {{ ref('stg_ventes') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['pays']) }} as pays_key,
    pays
from pays