select
    kode_oppdrag_num as oppdrag_nr,
    kode_oppdrag as oppdrag_kode,
    oppdragsnavn as oppdrag_navn

from {{ source('UR', 'v_oppdragskode') }}
