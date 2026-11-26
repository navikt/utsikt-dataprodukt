--agg_beregnet_belop_per_ytelse_kilde_dag
with

ref_fak_stoppnivaer as (
    select
        beregning_id,
        oppdrag_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        belop_brutto,
        lastet_tid_kilde
    from {{ ref('fak_stoppnivaer') }}
),

ref_int_fagomrader_med_tilhorende_faggrupper as (
    select
        fagomrade_kode,
        ytelse
    from {{ ref('int_fagomrader_med_tilhorende_faggrupper') }}
),

ref_fak_oppdrag_kilde as (
    select
        oppdrag_id,
        kildesystem,
        lastet_tid_kilde
    from {{ ref('fak_oppdrag_kilde') }}
),

group_beregning_belop_dag as (
    select 
        beregning_id,
        oppdrag_id,
        fagomrade_kode,
        sum(belop_brutto) as belop_brutto,
        date(lastet_tid_kilde) as lastet_dato_kilde
    from ref_fak_stoppnivaer
    group by beregning_id, oppdrag_id, fagomrade_kode, date(lastet_tid_kilde)
),

join_ytelse as (
    select
        group_beregning_belop_dag.beregning_id,
        group_beregning_belop_dag.oppdrag_id,
        group_beregning_belop_dag.belop_brutto,
        group_beregning_belop_dag.lastet_dato_kilde,
        ref_int_fagomrader_med_tilhorende_faggrupper.ytelse
    from group_beregning_belop_dag
    left join
        ref_int_fagomrader_med_tilhorende_faggrupper
        on group_beregning_belop_dag.fagomrade_kode = ref_int_fagomrader_med_tilhorende_faggrupper.fagomrade_kode
),

join_kildesystem as (
    select
        join_ytelse.beregning_id,
        join_ytelse.oppdrag_id,
        join_ytelse.belop_brutto,
        join_ytelse.lastet_dato_kilde,
        join_ytelse.ytelse,
        coalesce(ref_fak_oppdrag_kilde.kildesystem, 'Oppdragssystemet') as kildesystem
    from join_ytelse
    left join
        ref_fak_oppdrag_kilde
        on join_ytelse.oppdrag_id = ref_fak_oppdrag_kilde.oppdrag_id
),

count_beregninger as (
    select
        ytelse,
        kildesystem,
        lastet_dato_kilde,
        sum(belop_brutto) as belop_brutto,
        count(beregning_id) as antall_beregninger
    from join_kildesystem
    group by ytelse, kildesystem, lastet_dato_kilde
),

final as (
    select
        ytelse,
        kildesystem,
        lastet_dato_kilde,
        belop_brutto,
        antall_beregninger
    from count_beregninger
)

select * from final
