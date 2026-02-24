UPDATE `utsikt-prod-2dfe.OS.t_vent_stoppstatus` AS stoppstatus
SET tidspkt_reg = timestamp_add(stoppstatus.tidspkt_reg, INTERVAL 1 MICROSECOND)
FROM (
    SELECT
        beregnings_id,
        stoppnivaa_id,
        tidspkt_reg,
        max(lopenr) AS lopenr
    FROM `utsikt-prod-2dfe.OS.t_vent_stoppstatus`
    GROUP BY beregnings_id, stoppnivaa_id, tidspkt_reg
    HAVING count(*) > 1
) AS rows_to_change
WHERE
    stoppstatus.beregnings_id = rows_to_change.beregnings_id
    AND stoppstatus.stoppnivaa_id = rows_to_change.stoppnivaa_id
    AND stoppstatus.lopenr = rows_to_change.lopenr
