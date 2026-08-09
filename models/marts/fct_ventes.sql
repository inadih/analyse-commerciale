with ventes as (

    select * from {{ ref('stg_ventes') }}

)

select
    -- clé de la transaction (dimension dégénérée)
    order_id,

    -- clés étrangères vers les dimensions (mêmes colonnes que dans les dims)
    {{ dbt_utils.generate_surrogate_key(['categorie', 'produit']) }} as produit_key,
    {{ dbt_utils.generate_surrogate_key(['client']) }}              as client_key,
    {{ dbt_utils.generate_surrogate_key(['pays']) }}                as geographie_key,
    {{ dbt_utils.generate_surrogate_key(['canal_vente']) }}         as canal_key,
    cast(date_vente as date)                                        as date_key,

    -- mesures
    quantite,
    prix_unitaire,
    remise,
    frais_livraison,
    montant_total,
    montant_total - remise - frais_livraison                        as marge,
    satisfaction

from ventes