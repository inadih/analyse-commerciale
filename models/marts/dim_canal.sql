with canal as (
    select distinct canal_vente from {{ ref('stg_ventes') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['canal_vente']) }} as canal_key,
    canal_vente as canal
from canal