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

        {% for object_pair in database_schemas %}
            {% set tables_in_db_schema = [] %}
            {% for model in models -%}
                {% if (model.node.database in object_pair and model.node.schema in object_pair) %}
                    {% do tables_in_db_schema.append(model.node.alias|upper) %}
                {% endif %}
            {% endfor %}

            {% set query %}
                select
                    '{{ invocation_id }}',
                    table_catalog,
                    table_schema,
                    table_name,
                    table_owner,
                    table_type,
                    is_transient,
                    clustering_key,
                    row_count,
                    bytes,
                    retention_time,
                    self_referencing_column_name,
                    reference_generation,
                    user_defined_type_catalog,
                    user_defined_type_name,
                    is_insertable_into,
                    is_typed,
                    commit_action,
                    created,
                    last_altered,
                    auto_clustering_on,
                    comment
                from {{ object_pair[0] }}.information_schema.tables
                where table_schema = '{{ object_pair[1]|upper }}'
                AND ({% for table_name in tables_in_db_schema %}
                    table_name = '{{table_name}}' {% if not loop.last %} OR {% endif %}
                {% endfor %})
            {% endset %}
            {% do information_schema_queries.append(query) %}
        {% endfor %}
		{{ return(information_schema_queries) }}
	{% else %}
	    {{ return("") }}
	{% endif %}
{% endmacro %}






