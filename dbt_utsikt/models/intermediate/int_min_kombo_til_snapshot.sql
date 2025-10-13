--int_min_kombo_til_snapshot
with

stoppstatuser as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        registrert_tidspunkt
    from {{ ref('stg_db2os__stoppstatuser') }}
    -- burde ha noe logikk som kun tar de nyeste stoppstatusene
),

{%- set source_relation = adapter.get_relation(
      database=ref('stoppstatus_snapshot').database,
      schema=ref('stoppstatus_snapshot').schema,
      identifier=ref('stoppstatus_snapshot').name) -%}

{% set table_exists=source_relation is not none  %}

{% if table_exists %}

{{ log("Table exists", info=True) }}

stoppstatus_snapshot as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        dbt_updated_at as registrert_tidspunkt
    from {{ ref('stoppstatus_snapshot') }}
),

{% else %}

{{ log("Table does not exist", info=True) }}

stoppstatus_snapshot as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        lopenummer,
        registrert_tidspunkt
    from {{ ref('stg_db2os__stoppstatuser') }}
    where lopenummer = 1
),

{% endif %}





nye_stoppstatuser as (
    select
        stoppstatuser.beregning_id,
        stoppstatuser.stoppniva_id,
        stoppstatuser.ventestatus_kode,
        stoppstatuser.registrert_tidspunkt
    from stoppstatuser
    left join stoppstatus_snapshot
        on
             stoppstatus_snapshot.beregning_id = stoppstatuser.beregning_id
            and  stoppstatus_snapshot.stoppniva_id = stoppstatuser.stoppniva_id
            and  stoppstatus_snapshot.ventestatus_kode = stoppstatuser.ventestatus_kode
            and  stoppstatus_snapshot.registrert_tidspunkt = stoppstatuser.registrert_tidspunkt
    where stoppstatus_snapshot.beregning_id is NULL
    --dette skal sikre kun nye rader ikke i snapshot allerede

),

eldste_stoppstatus_ikke_i_snapshot as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        registrert_tidspunkt,
        row_number() over (
            partition by beregning_id, stoppniva_id order by registrert_tidspunkt
        ) as radnummer
    from nye_stoppstatuser
),

final as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        registrert_tidspunkt
    from eldste_stoppstatus_ikke_i_snapshot
    where radnummer = 1
)

select * from nye_stoppstatuser
