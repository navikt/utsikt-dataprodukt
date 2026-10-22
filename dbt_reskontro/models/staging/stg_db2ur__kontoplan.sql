select
    hovedkontonr as hovedkonto_nummer,
    underkontonr as underkonto_nummer,
    oebs_artskonto,
    kontonavn_oebs as oebs_kontonavn,
    bevilgningskonto,
    hovedkonto_navn,
    underkonto_navn_nb as underkonto_navn,
    kode_uttrekk,
    ray_fom,
    lopenr

from {{ source('UR', 'v_kontoplan') }}
