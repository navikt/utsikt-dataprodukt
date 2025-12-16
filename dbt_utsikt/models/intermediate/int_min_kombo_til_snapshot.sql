--int_min_kombo_til_snapshot
with
stoppstatuser as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        lastet_tid_kilde
    from {{ ref('stg_db2os__stoppstatuser') }}
    -- burde ha noe logikk som kun tar de nyeste stoppstatusene
),

{%- set source_relation = adapter.get_relation( --noqa: TMP
      database=ref('stoppstatus_snapshot').database,
      schema=ref('stoppstatus_snapshot').schema,
      identifier=ref('stoppstatus_snapshot').name) -%}

{% set table_exists=source_relation is not none %}

{% if table_exists %}

    {{ log("Table exists", info=True) }}

    stoppstatus_snapshot as (
        select
            beregning_id,
            stoppniva_id,
            ventestatus_kode,
            dbt_updated_at as lastet_tid_kilde
        from {{ ref('stoppstatus_snapshot') }}
    ),

{% else %}

{{ log("Table does not exist", info=True) }}

stoppstatus_snapshot as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        lastet_tid_kilde
    from {{ ref('stg_db2os__stoppstatuser') }}
    -- this means there will be zero rows
    where false

),

{% endif %}

nye_stoppstatuser as (
    select
        stoppstatuser.beregning_id,
        stoppstatuser.stoppniva_id,
        stoppstatuser.ventestatus_kode,
        stoppstatuser.lastet_tid_kilde
    from stoppstatuser
    left join stoppstatus_snapshot
        on
            stoppstatuser.beregning_id = stoppstatus_snapshot.beregning_id
            and stoppstatuser.stoppniva_id = stoppstatus_snapshot.stoppniva_id
            and stoppstatuser.ventestatus_kode = stoppstatus_snapshot.ventestatus_kode
            and stoppstatuser.lastet_tid_kilde = stoppstatus_snapshot.lastet_tid_kilde
    where stoppstatus_snapshot.beregning_id is NULL
    --dette skal sikre kun nye rader ikke i snapshot allerede

),

eldste_stoppstatus_ikke_i_snapshot as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        lastet_tid_kilde,
        row_number() over (
            partition by beregning_id, stoppniva_id order by lastet_tid_kilde
        ) as radnummer
    from nye_stoppstatuser
),

final as (
    select
        beregning_id,
        stoppniva_id,
        ventestatus_kode,
        lastet_tid_kilde
    from eldste_stoppstatus_ikke_i_snapshot
    where radnummer = 1
)

select * from final
