with source as (

    select * from {{ source('bronze', 'mouvements_stock') }}

)

select
    produit,
    type_mouvement,
    date_mouvement,
    case
        when type_mouvement = 'VENTE' then -quantite
        else quantite
    end as quantite_signee
from source