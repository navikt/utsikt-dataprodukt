--antall_beregninger_per_faggruppe_per_dag


with
ref_fak_beregninger as (
    select
        beregning_id,
        faggruppe_kode,
        faggruppe_navn,
        beregnet_dato,
        lastet_tid_kilde
    from {{ ref('fak_beregninger') }}
),

antall_beregninger_per_faggruppe_per_dag as (
    select
        faggruppe_kode,
        faggruppe_navn,
        beregnet_dato,
        count(beregning_id) as antall_beregninger
    from ref_fak_beregninger
    group by
        faggruppe_kode,
        faggruppe_navn,
        beregnet_dato

),

final as (
    select
        faggruppe_kode,
        faggruppe_navn,
        beregnet_dato,
        antall_beregninger
    from antall_beregninger_per_faggruppe_per_dag
)

select * from final
