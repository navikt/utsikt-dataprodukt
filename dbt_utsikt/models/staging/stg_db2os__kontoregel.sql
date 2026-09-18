select
    dato_fom,
    aar,
    hovedkontonr,
    underkontonr,
    tidspkt_reg,
    trim(kode_klasse) as klasse_kode
from {{ source('OS', 't_kontoregel') }}
