with registrerte_tidsstempler as (
    select
        t1.beregning_id,
        t1.stoppniva_id,
        t1.lopenummer,
        t1.ventestatus_kode,
        t1.lastet_tid_kilde,
        t2.lastet_tid_kilde as lastet_tid_kilde_neste_ventestatus,
        t3.lastet_tid_kilde as lastet_tid_kilde_gjeldende_ventestatus
    from {{ ref('stg_db2os__stoppstatuser') }} as t1
    left join {{ ref('stg_db2os__stoppstatuser') }} as t2
        on
            t1.beregning_id = t2.beregning_id
            and t1.stoppniva_id = t2.stoppniva_id
            and t2.lopenummer = t1.lopenummer + 1
    left join {{ ref('stg_db2os__stoppstatuser') }} as t3
        on
            t1.beregning_id = t3.beregning_id
            and t1.stoppniva_id = t3.stoppniva_id
            and t3.lopenummer = 9999
),

lengder_stoppstatuser as (
    select
        beregning_id,
        stoppniva_id,
        lopenummer,
        ventestatus_kode,
        lastet_tid_kilde,
        case
            when
                lastet_tid_kilde_neste_ventestatus is not null
                then
                    lastet_tid_kilde_neste_ventestatus
                    - lastet_tid_kilde
            when
                lopenummer = 9999
                then
                    cast(current_datetime('Europe/Oslo') as timestamp)
                    - lastet_tid_kilde
            else
                lastet_tid_kilde_gjeldende_ventestatus
                - lastet_tid_kilde
        end as lengde_lopenummer
    from registrerte_tidsstempler
)

select
    beregning_id,
    stoppniva_id,
    lopenummer,
    sts.ventestatus_kode,
    ventestatus_beskrivelse,
    lastet_tid_kilde,
    lengde_lopenummer,
    case
        when handteres_manuelt = 1 then 'Håndteres manuelt'
        else 'Ingen manuell håndtering'
    end as handteres_manuelt,
    --antar at ingen intervals har registrert noe større enn timer
    round(
        (
            extract(hour from lengde_lopenummer)
            + (extract(minute from lengde_lopenummer) / 60)
            + (extract(second from lengde_lopenummer) / 3600)
        ),
        3
    ) as lengde_antall_timer
from
    lengder_stoppstatuser as sts
left join {{ ref('int_stoppstatuskoder_manuell_handtering') }} as stn
    on sts.ventestatus_kode = stn.ventestatus_kode
