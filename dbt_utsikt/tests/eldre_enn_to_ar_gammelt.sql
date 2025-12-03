select * from venteregister.antall_beregninger_per_fagomrade_per_dag --noqa: AM04
where beregnet_dato < date_add(current_date(), interval -2 year)
