with base as (

    select *
    from {{ ref('stg_dbt__model_executions') }}

),

model_information as (

  select *
  from {{ ref('stg_dbt__model_information') }}

),

model_executions as (

    select
        base.model_execution_id,
        base.command_invocation_id,
        base.node_id,
        base.run_started_at,
        base.was_full_refresh,
        base.thread_id,
        base.status,
        base.compile_started_at,
        base.query_completed_at,
        base.total_node_runtime,
        base.rows_affected,
        {% if target.type == 'bigquery' %}
          base.bytes_processed,
        {% endif %}
        base.materialization,
        base.database,
        base.schema, -- noqa
        base.name,
        base.alias,
        model_information.table_owner,
        model_information.table_type,
        model_information.is_transient,
        model_information.clustering_key,
        model_information.row_count,
        model_information.bytes,
        model_information.retention_time,
        model_information.created,
        model_information.last_altered,
        model_information.auto_clustering_on,
        model_information.comment
    from base
    left join model_information
      on base.command_invocation_id = model_information.command_invocation_id
     and upper(base.database) = model_information.table_catalog
     and upper(base.schema) = model_information.table_schema
     and upper(base.alias) = model_information.table_name

)

select * from model_executions
