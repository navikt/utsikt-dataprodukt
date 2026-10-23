select
    kode_oppdrag_num as oppdrag_nummer,
    kode_oppdrag as oppdrag_kode,
    oppdragsnavn as oppdrag_navn

from {{ source('UR', 'v_oppdragskode') }}
