with produits as (

    select distinct
        categorie,
        produit
    from {{ ref('stg_ventes') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['categorie', 'produit']) }} as produit_key,
    categorie,
    produit
from produits