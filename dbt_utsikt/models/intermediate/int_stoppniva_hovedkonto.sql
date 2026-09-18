with

ref_fak_stoppnivaer as (
    select
        beregning_id,
        stoppniva_id,
        oppdrag_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        lastet_tid_kilde
    from {{ ref('fak_stoppnivaer') }}
),

ref_fak_stoppnivaer_detaljer as (
    select
        beregning_id,
        stoppniva_id,
        linje_id,
        klasse_kode
    from {{ ref('fak_stoppnivaer_detaljer') }}
    where linje_id > 0
),

ref_stg_db2os__kontoregel as (
    select
        aar,
        dato_fom,
        hovedkontonr,
        klasse_kode
    from {{ ref('stg_db2os__kontoregel') }}
),

ref_stg_db2os__konto as (
    select
        aar,
        hovedkontonr,
        hovedkonto_navn
    from {{ ref('stg_db2os__konto') }}
),

kontoregel_unik_klassekode as (
    select
        klasse_kode,
        hovedkontonr,
        row_number() over (partition by klasse_kode order by dato_fom desc) as row_number
    from ref_stg_db2os__kontoregel
),

konto_unik_hovedkontonr as (
    select
        hovedkontonr,
        hovedkonto_navn,
        row_number() over (partition by hovedkontonr order by aar desc) as row_number
    from ref_stg_db2os__konto
),

stoppniva_til_klassekode as (
    select
        beregning_id,
        stoppniva_id,
        min(klasse_kode) as klasse_kode
    from ref_fak_stoppnivaer_detaljer
    group by beregning_id, stoppniva_id
),

join_stoppniva_konto as (
    select
        stoppniva_til_klassekode.beregning_id,
        stoppniva_til_klassekode.stoppniva_id,
        stoppniva_til_klassekode.klasse_kode,
        kontoregel_unik_klassekode.hovedkontonr,
        konto_unik_hovedkontonr.hovedkonto_navn
    from stoppniva_til_klassekode
    left join kontoregel_unik_klassekode
        on
            stoppniva_til_klassekode.klasse_kode = kontoregel_unik_klassekode.klasse_kode
            and kontoregel_unik_klassekode.row_number = 1
    left join konto_unik_hovedkontonr
        on
            kontoregel_unik_klassekode.hovedkontonr = konto_unik_hovedkontonr.hovedkontonr
            and konto_unik_hovedkontonr.row_number = 1
),

join_fak_stoppnivaer as (
    select
        ref_fak_stoppnivaer.beregning_id,
        ref_fak_stoppnivaer.stoppniva_id,
        ref_fak_stoppnivaer.oppdrag_id,
        ref_fak_stoppnivaer.fagomrade_kode,
        ref_fak_stoppnivaer.fagomrade_navn,
        ref_fak_stoppnivaer.faggruppe_navn,
        ref_fak_stoppnivaer.lastet_tid_kilde,
        join_stoppniva_konto.klasse_kode,
        join_stoppniva_konto.hovedkontonr,
        join_stoppniva_konto.hovedkonto_navn
    from ref_fak_stoppnivaer
    left join join_stoppniva_konto
        on
            ref_fak_stoppnivaer.beregning_id = join_stoppniva_konto.beregning_id
            and ref_fak_stoppnivaer.stoppniva_id = join_stoppniva_konto.stoppniva_id
),

final as (
    select
        beregning_id,
        stoppniva_id,
        oppdrag_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        klasse_kode,
        hovedkontonr,
        hovedkonto_navn,
        lastet_tid_kilde
    from join_fak_stoppnivaer
)

select * from final
