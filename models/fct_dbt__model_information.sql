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
        self_referencing_column_name,
        reference_generation,
        user_defined_type_catalog,
        user_defined_type_schema,
        user_defined_type_name,
        is_insertable_into,
        is_typed,
        commit_action,
        created,
        last_altered,
        auto_clustering_on,
        comment
    from base

)

select * from model_information
