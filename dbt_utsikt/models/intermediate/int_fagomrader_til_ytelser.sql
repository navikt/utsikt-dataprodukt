-- int_fagomrader_til_ytelser
with

ref_stg_db2os__fagomrader as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode
    from {{ ref('stg_db2os__fagomrader') }}
),


derive_ytelse as (
    select
        fagomrade_navn,
        fagomrade_kode,
        faggruppe_kode,
        case
            when fagomrade_navn like '%Arbeidsavklaringspenger%'
                then 'Arbeidsavklaringspenger'
            when fagomrade_navn like '%Dagpenger%'
                then 'Dagpenger'
            when fagomrade_navn like '%Tiltakspenger%'
                then 'Tiltakspenger'
            when fagomrade_navn like '%Tilleggsstønad%' or fagomrade_navn like '%Tilleggstønad%'
                then 'Tilleggsstønad'
            when fagomrade_navn like '%Barnetrygd%'
                then 'Barnetrygd'
            when fagomrade_navn like '%Enslig forsørger%'
                then 'Enslig forsørger'
            when fagomrade_navn like '%Gravferdstønad%' or fagomrade_navn like '%Gravferdsstønad%'
                then 'Gravferdsstønad'
            when fagomrade_navn like '%Grunnstønad%' or fagomrade_navn like '%Hjelpestønad%'
                then 'Grunn og hjelpestønad'
            when fagomrade_navn like '%Uføretrygd%'
                then 'Uføretrygd'
            when fagomrade_navn like '%Alderspensjon%'
                then 'Alderspensjon'
            when fagomrade_navn like '%Uførepensjon fra SPK%'
                then 'Uførepensjon fra SPK'
            when fagomrade_navn like '%Kontantstøtte%'
                then 'Kontantstøtte'
            when fagomrade_navn like '%Sykepenger%'
                then 'Sykepenger'
            when fagomrade_navn like '%Foreldrepenger%'
                then 'Foreldrepenger'
            else 'Annet'
        end as ytelse
    from ref_stg_db2os__fagomrader
),

final as (
    select
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_kode,
        ytelse
    from derive_ytelse
)

select * from final
