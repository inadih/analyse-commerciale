{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

with ventes as (

    select * from {{ ref('stg_ventes') }}

    {% if is_incremental() %}
    -- Ne s'active QUE lors des runs incrémentaux :
    -- on ne prend que les ventes plus récentes que la date max déjà chargée.
    where date_vente > (select max(date_key) from {{ this }})
    {% endif %}

)

select
    order_id,
    {{ dbt_utils.generate_surrogate_key(['categorie', 'produit']) }} as produit_key,
    {{ dbt_utils.generate_surrogate_key(['client']) }}              as client_key,
    {{ dbt_utils.generate_surrogate_key(['pays']) }}                as geographie_key,
    {{ dbt_utils.generate_surrogate_key(['canal_vente']) }}         as canal_key,
    cast(date_vente as date)                                        as date_key,
    quantite,
    prix_unitaire,
    remise,
    frais_livraison,
    montant_total,
    montant_total - remise - frais_livraison                        as marge,
    satisfaction
from ventes