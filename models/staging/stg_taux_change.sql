with source as (

    select * from {{ source('bronze', 'taux_change') }}

)

select
    date_taux,
    devise,
    taux
from source