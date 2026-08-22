{{ config(materialized='table') }}

with grille as (

    select * from {{ ref('int_fins_de_mois') }}

),

stock_cumule as (

    select * from {{ ref('int_stock_cumule') }}

),

-- Pour chaque case (produit x date_photo), on rattache TOUS les mouvements
-- de ce produit survenus à ou avant la date de photo
rapprochement as (

    select
        g.produit,
        g.date_photo,
        s.date_mouvement,
        s.stock_apres_mouvement,
        row_number() over (
            partition by g.produit, g.date_photo
            order by
                s.date_mouvement desc,
                case when s.type_mouvement = 'RECEPTION' then 0 else 1 end desc
        ) as rang
    from grille g
    left join stock_cumule s
        on g.produit = s.produit
        and s.date_mouvement <= g.date_photo

)
select
    produit,
    date_photo,
    coalesce(stock_apres_mouvement, 0) as stock_fin_de_mois
from rapprochement
where rang = 1     -- on ne garde que le mouvement le plus récent = le stock à cette date