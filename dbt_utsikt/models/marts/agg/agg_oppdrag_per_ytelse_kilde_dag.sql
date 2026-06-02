--agg_oppdrag_per_ytelse_kilde_dag

with ref_agg_oppdrag_per_kilde_fagomrade_dag as (
    select
        fagomrade_navn,
        kildesystem,
        dato_oppdrag_lastet,
        antall_oppdrag
    from {{ ref('agg_oppdrag_per_kilde_fagomrade_dag') }}
),

derive_ytelse as (
    select
        dato_oppdrag_lastet,
        antall_oppdrag,
        coalesce(kildesystem, 'Oppdragssystemet') as kildesystem,
        case
            when fagomrade_navn like '%Arbeidsavklaringspenger%'
                then 'Arbeidsavklaringspenger'
            when fagomrade_navn like '%Dagpenger%'
                then 'Dagpenger'
            when fagomrade_navn like '%Tiltakspenger%'
                then 'Tiltakspenger'
            when fagomrade_navn like '%Tilleggsstønad%'
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
    from ref_agg_oppdrag_per_kilde_fagomrade_dag
),

agg_oppdrag_per_ytelse_kilde_dag as (
    select
        ytelse,
        kildesystem,
        dato_oppdrag_lastet,
        sum(antall_oppdrag) as antall_oppdrag
    from derive_ytelse
    group by ytelse, kildesystem, dato_oppdrag_lastet
),

final as (
    select
        ytelse,
        kildesystem,
        dato_oppdrag_lastet,
        antall_oppdrag
    from agg_oppdrag_per_ytelse_kilde_dag
)

select * from final
