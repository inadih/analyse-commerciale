{% snapshot snap_produits %}

{{
    config(
      target_schema='SILVER',
      unique_key='produit',
      strategy='timestamp',
      updated_at='date_maj'
    )
}}

select * from {{ source('bronze', 'produits_ref') }}

{% endsnapshot %}
