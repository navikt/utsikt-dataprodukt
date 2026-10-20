with test as (
    select count(*) as antall_rader
    from {{ ref('int_min_kombo_til_snapshot') }}
)

-- denne testen returnerer rader (gir feil) dersom viewet er tomt (dvs ingen nye rader til snapshot)
select antall_rader from test
where antall_rader = 0
