with base as (

    select *
    from {{ ref('stg_dbt__model_information') }}

),

model_information as (

    select
        command_invocation_id,
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
        commit_action,
        created,
        last_altered,
        last_ddl,
        last_ddl_by,
        auto_clustering_on,
        comment
    from base

)

select * from model_information
