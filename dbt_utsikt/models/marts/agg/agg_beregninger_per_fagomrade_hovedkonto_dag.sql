--agg_beregninger_per_fagomrade_hovedkonto_dag
with

ref_int_stoppniva_hovedkonto as (
    select
        beregning_id,
        fagomrade_kode,
        fagomrade_navn,
        faggruppe_navn,
        hovedkonto_navn,
        date(lastet_tid_kilde) as lastet_dato_kilde
    from {{ ref('int_stoppniva_hovedkonto') }}
),

dist_beregning_fagomrade as (
    select distinct
        beregning_id,
        fagomrade_kode,
        faggruppe_navn,
        fagomrade_navn,
        hovedkonto_navn,
        lastet_dato_kilde
    from ref_int_stoppniva_hovedkonto
),

final as (
    select
        fagomrade_navn,
        faggruppe_navn,
        hovedkonto_navn,
        lastet_dato_kilde,
        count(beregning_id) as antall_beregninger
    from dist_beregning_fagomrade
    group by fagomrade_navn, faggruppe_navn, hovedkonto_navn, lastet_dato_kilde
)

select
    fagomrade_navn,
    faggruppe_navn,
    hovedkonto_navn,
    lastet_dato_kilde,
    antall_beregninger
from final


--legg merke til at en beregning_id kan tilhøre flere fagomrader, 
--så en beregning kan telle i flere antall_beregninger per fagområde per hovedkonto per dag
