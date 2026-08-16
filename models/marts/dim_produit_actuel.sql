with snapshot_produits as (

    select * from {{ ref('snap_produits') }}

),

version_courante as (

    select
        produit,
        categorie,
        prix_unitaire,
        fournisseur,
        dbt_valid_from as prix_valide_depuis
    from snapshot_produits
    where dbt_valid_to is null

)

select
    {{ dbt_utils.generate_surrogate_key(['produit']) }} as produit_key,
    produit,
    categorie,
    prix_unitaire,
    fournisseur,
    prix_valide_depuis
from version_courante