select
    dato_valutert_ur as valutert_ur_dato,
    hovedkontonr as hovedkonto_nr,
    underkontonr as underkonto_nr,
    antall_mottakere,
    parse_numeric(sum_debet) as sum_debet,
    parse_numeric(sum_kredit) as sum_kredit,
    timestamp(registrert, 'Europe/Oslo') as lastet_tid_kilde,
    timestamp(sist_oppdatert, 'Europe/Oslo') as oppdatert_tid_kilde

from {{ source('UR', 'v_saldo_avregn') }}
