select
    dato_postert_ur as postert_ur_dato,
    hovedkontonr as hovedkonto_nr,
    underkontonr as underkonto_nr,
    kode_oppdrag_num as oppdrag_nummer,
    antall_mottakere,
    parse_numeric(sum_debet) as sum_debet,
    parse_numeric(sum_kredit) as sum_kredit,
    timestamp(registrert, 'Europe/Oslo') as lastet_tid_kilde,
    timestamp(sist_oppdatert, 'Europe/Oslo') as oppdatert_tid_kilde

from {{ source('UR', 'v_saldo_detalj') }}
