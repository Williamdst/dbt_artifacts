with base as (
  select *
  from {{ ref('stg_dbt__invocations') }}
),

model_executions_statuses as (
  select
      command_invocation_id,
      status
  from {{ ref('stg_dbt__model_executions') }}
),

seed_executions_statuses as (
    select
      command_invocation_id,
      status
    from {{ ref('stg_dbt__seed_executions') }}
),

snapshot_executions_statuses as (
    select
      command_invocation_id,
      status
    from {{ ref('stg_dbt__snapshot_executions') }}
),

test_executions_statuses as (
    select
      command_invocation_id,
      status
    from {{ ref('stg_dbt__test_executions') }}
),

all_executions_statuses as (

  SELECT * FROM model_executions_statuses
  UNION ALL
  SELECT * FROM seed_executions_statuses
  UNION ALL
  SELECT * FROM snapshot_executions_statuses
  UNION ALL
  SELECT * FROM test_executions_statuses

),

invocation_error_counting as (

	select
        command_invocation_id,
        sum(case when status NOT IN ('success', 'pass') then 1 else 0 end) as error_count
	from all_executions_statuses
	group by command_invocation_id

),

invocation_error_labeling as (

	select
	    command_invocation_id,
	    case
          when error_count is null then null
          when error_count != 0 then 'error' else 'success'
        end as invocation_status
    from invocation_error_counting

),

final as (

    select
        base.command_invocation_id,
        base.dbt_version,
        base.project_name,
        base.run_started_at,
        base.dbt_command,
        GET(base.invocation_args, 'select') as selection_criteria,
        invocation_error_labeling.invocation_status,
        base.full_refresh_flag,
        base.target_profile_name,
        base.target_name,
        base.target_schema,
        base.target_threads,
        base.dbt_cloud_project_id,
        base.dbt_cloud_job_id,
        base.dbt_cloud_run_id,
        base.dbt_cloud_run_reason_category,
        base.dbt_cloud_run_reason,
        base.env_vars,
        base.dbt_vars,
        base.invocation_args,
        base.dbt_custom_envs
    from base
    left join invocation_error_labeling
      on base.command_invocation_id = invocation_error_labeling.command_invocation_id
)

select * from final
