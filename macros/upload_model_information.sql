{% macro upload_model_information(results) -%}
    {% set models = [] %}
    {% for result in results  %}
        {% if result.node.resource_type == "model" %}
            {% do models.append(result) %}
        {% endif %}
    {% endfor %}
    {{ return(adapter.dispatch('get_models_information_dml_sql_array', 'dbt_artifacts')(models)) }}
{%- endmacro %}

{% macro default__get_models_information_dml_sql_array(models) -%}}
    {% if models != [] %}
        {% set information_schema_queries = [] %}
        {% for model in models -%}
        {% set query %}
            select
                '{{ invocation_id }}',
                *
            from {{ model.node.database }}.information_schema.tables
            where table_schema = upper('{{ model.node.schema }}')
              and table_name = upper('{{ model.node.alias }}')
        {% endset %}
        {% do information_schema_queries.append(query) %}
        {% endfor %}
        {{ return(information_schema_queries) }}
    {% else %}
        {{ return("") }}
    {% endif %}
{% endmacro %}













