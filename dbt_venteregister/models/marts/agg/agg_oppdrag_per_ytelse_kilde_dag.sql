--agg_oppdrag_per_ytelse_kilde_dag

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

ref_int_fagomrader_med_tilhorende_faggrupper as (
    select
        fagomrade_kode,
        ytelse
    from {{ ref('int_fagomrader_med_tilhorende_faggrupper') }}
),

join_ytelse as (
    select
        agg_oppdrag_per_kilde_fagomrade_dag.fagomrade_kode,
        agg_oppdrag_per_kilde_fagomrade_dag.fagomrade_navn,
        agg_oppdrag_per_kilde_fagomrade_dag.faggruppe_kode,
        agg_oppdrag_per_kilde_fagomrade_dag.faggruppe_navn,
        agg_oppdrag_per_kilde_fagomrade_dag.dato_oppdrag_lastet,
        agg_oppdrag_per_kilde_fagomrade_dag.antall_oppdrag,
        ref_int_fagomrader_med_tilhorende_faggrupper.ytelse,
        coalesce(agg_oppdrag_per_kilde_fagomrade_dag.kildesystem, 'Oppdragssystemet') as kildesystem
    from agg_oppdrag_per_kilde_fagomrade_dag
    left join ref_int_fagomrader_med_tilhorende_faggrupper
        on agg_oppdrag_per_kilde_fagomrade_dag.fagomrade_kode = ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_kode
),

final as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        faggruppe_navn,
        ytelse,
        kildesystem,
        dato_oppdrag_lastet,
        antall_oppdrag
    from join_ytelse
)

select * from final
