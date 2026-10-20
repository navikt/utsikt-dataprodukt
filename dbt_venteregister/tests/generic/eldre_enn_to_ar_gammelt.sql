{% test eldre_enn_to_ar_gammelt(model, column_name) %}
    select * from {{ model }} 
    where cast({{ column_name }} AS DATE) < date_add(current_date(), interval -731 day)
{% endtest %}
