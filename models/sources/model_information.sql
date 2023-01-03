/* Bigquery won't let us `where` without `from` so we use this workaround */
with dummy_cte as (
    select 1 as foo
)

select
    cast(null as {{ type_string() }}) as command_invocation_id,
    cast(null as {{ type_string() }}) as table_catalog,
    cast(null as {{ type_string() }}) as table_schema,
    cast(null as {{ type_string() }}) as table_name,
    cast(null as {{ type_string() }}) as table_owner,
    cast(null as {{ type_string() }}) as table_type,
    cast(null as {{ type_string() }}) as is_transient,
    cast(null as {{ type_string() }}) as clustering_key,
    cast(null as {{ type_int() }}) as row_count,
    cast(null as {{ type_int() }}) as bytes,
    cast(null as {{ type_int() }}) as retention_time,
    cast(null as {{ type_string() }}) as self_referencing_column_name,
    cast(null as {{ type_string() }}) as reference_generation,
    cast(null as {{ type_string() }}) as user_defined_type_catalog,
    cast(null as {{ type_string() }}) as user_defined_type_schema,
    cast(null as {{ type_string() }}) as user_defined_type_name,
    cast(null as {{ type_string() }}) as is_insertable_into,
    cast(null as {{ type_string() }}) as is_typed,
    cast(null as {{ type_string() }}) as commit_action,
    cast(null as TIMESTAMP_LTZ) as created,
    cast(null as TIMESTAMP_LTZ) as last_altered,
    cast(null as {{ type_string() }}) as auto_clustering_on,
    cast(null as {{ type_string() }}) as comment
from dummy_cte
where 1 = 0
