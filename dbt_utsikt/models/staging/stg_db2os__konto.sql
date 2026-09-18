select
    aar,
    hovedkontonr,
    underkontonr,
    tidspkt_reg,
    trim(hovedkonto_navn) as hovedkonto_navn,
    trim(underkonto_navn) as underkonto_navn
from {{ source('OS', 't_konto') }}
