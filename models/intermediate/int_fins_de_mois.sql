with fins_de_mois as (

    -- les derniers jours de chaque mois, depuis dim_date
    select distinct
        last_day(date_key) as date_photo
    from {{ ref('dim_date') }}
    where date_key <= current_date()   -- pas de photo dans le futur

),

produits as (

    -- la liste des produits qui ont des mouvements
    select distinct produit
    from {{ ref('stg_mouvements_stock') }}

)

-- le produit cartésien : chaque produit × chaque fin de mois
select
    p.produit,
    f.date_photo
from produits p
cross join fins_de_mois f