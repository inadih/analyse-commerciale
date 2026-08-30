with ventes as (

    select * from {{ ref('stg_ventes') }}

),

taux as (

    select * from {{ ref('stg_taux_change') }}
    where devise = 'USD'          -- on convertit en USD pour l'exemple

),

-- pour chaque vente, rattacher tous les taux à ou avant sa date,
-- puis garder le plus récent (le dernier taux connu)
rapprochement as (

    select
        v.order_id,
        v.date_vente,
        v.montant_total,
        t.taux,
        t.date_taux,
        row_number() over (
            partition by v.order_id
            order by t.date_taux desc
        ) as rang
    from ventes v
    left join taux t
        on t.date_taux <= v.date_vente

)

select
    order_id,
    date_vente,
    montant_total                          as montant_eur,
    taux                                   as taux_usd,
    round(montant_total * taux, 2)         as montant_usd
from rapprochement
where rang = 1