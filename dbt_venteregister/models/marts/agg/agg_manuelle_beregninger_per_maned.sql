--agg_manuelle_beregninger_per_maned
with
ref_fak_stoppstatus as (
    select
        beregning_id,
        handteres_manuelt_flagg,
        lastet_tid_kilde
    from {{ ref('fak_stoppstatus') }}
),


manuelle_beregninger as (
    select
        beregning_id,
        date_trunc(lastet_tid_kilde, month) as mnd,
        sum(handteres_manuelt_flagg) as manuelt
    from ref_fak_stoppstatus
    group by beregning_id, mnd
),

antall_periode as (
    select
        mnd,
        count(beregning_id) as totalt_antall,
        sum(case when manuelt > 0 then 1 else 0 end) as manuelt_antall
    from manuelle_beregninger
    group by mnd
),

calculate_andel as (

    select
        mnd,
        manuelt_antall,
        totalt_antall,
        round(manuelt_antall * 100 / totalt_antall, 2) as prosent_manuelt
    from antall_periode
    order by mnd
),

final as (
    select
        mnd,
        manuelt_antall,
        totalt_antall,
        prosent_manuelt
    from calculate_andel
)

select * from final
