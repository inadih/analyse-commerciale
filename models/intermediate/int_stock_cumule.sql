with mouvements as (

    select * from {{ ref('stg_mouvements_stock') }}

)

select
    produit,
    type_mouvement,          -- ← AJOUTER cette ligne
    date_mouvement,
    quantite_signee,
    sum(quantite_signee) over (
        partition by produit
        order by
            date_mouvement,
            case when type_mouvement = 'RECEPTION' then 0 else 1 end
        rows between unbounded preceding and current row
    ) as stock_apres_mouvement
from mouvements