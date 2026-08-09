with source as (

    select * from {{ ref('ventes_10000') }}

),

cleaned as (

    select
        order_id,
        date                as date_vente,
        trim(client)        as client,
        trim(categorie)     as categorie,
        trim(produit)       as produit,
        quantite,
        prix_unitaire,
        remise,
        trim(pays)          as pays,
        trim(canal_vente)   as canal_vente,
        frais_livraison,
        satisfaction,
        montant_total
    from source

)

select * from cleaned