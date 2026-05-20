--agg_oppdrag_per_kilde_fagomrade_dag

with ref_fak_oppdrag as (
    select
        oppdrag_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        kildesystem,
        lastet_tid_kilde,
        lastet_tid
    from {{ ref('fak_oppdrag') }}
),

agg_oppdrag_per_kilde_fagomrade_dag as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        kildesystem,
        extract(date from lastet_tid_kilde) as dato_oppdrag_lastet,
        count(distinct oppdrag_id) as antall_oppdrag
    from ref_fak_oppdrag
    group by
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        kildesystem,
        extract(date from lastet_tid_kilde)
),

final as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        kildesystem,
        dato_oppdrag_lastet,
        antall_oppdrag
    from agg_oppdrag_per_kilde_fagomrade_dag
)

select * from final