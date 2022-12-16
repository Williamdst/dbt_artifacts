with base as (
  select *
  from {{ ref('stg_dbt__invocations') }}
),

model_executions as (
  select *
  from {{ ref('stg_dbt__model_executions') }}
),

seed_executions as (
    select *
    from {{ ref('stg_dbt__seed_executions') }}
),

snapshot_executions as (
    select *
    from {{ ref('stg_dbt__snapshot_executions') }}
),

test_executions as (
    select *
    from {{ ref('stg_dbt__test_executions') }}
),

model_status_flagging as (

	select
        command_invocation_id,
        sum(case when status != 'success' then 1 else 0 end) as model_success_flag
	from model_executions
	group by command_invocation_id

),

seed_status_flagging as (

	select
        command_invocation_id,
        sum(case when status != 'success' then 1 else 0 end) as seed_success_flag
	from seed_executions
	group by command_invocation_id

),

snapshot_status_flagging as (

	select
        command_invocation_id,
        sum(case when status != 'success' then 1 else 0 end) as snapshot_success_flag
	from snapshot_executions
	group by command_invocation_id

),

test_status_flagging as (

	select
        command_invocation_id,
        sum(case when status != 'success' then 1 else 0 end) as test_success_flag
	from test_executions
	group by command_invocation_id

),

final as (

    select
        base.command_invocation_id,
        base.dbt_version,
        base.project_name,
        base.run_started_at,
        base.dbt_command,
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
        base.dbt_custom_envs,

        case
          when model_status_flagging.model_success_flag is null then null
          when model_status_flagging.model_success_flag != 0 then 'error' else 'success'
        end as invocation_models_status,

        case
          when seed_status_flagging.seed_success_flag is null then null
          when seed_status_flagging.seed_success_flag != 0 then 'error' else 'success'
        end as invocation_seeds_status,

        case
          when snapshot_status_flagging.snapshot_success_flag is null then null
          when snapshot_status_flagging.snapshot_success_flag != 0 then 'error' else 'success'
        end as invocation_snapshots_status,

        case
          when test_status_flagging.test_success_flag is null then null
          when test_status_flagging.test_success_flag != 0 then 'error' else 'success'
        end as invocation_tests_status

    from base
    left join model_status_flagging
      on base.command_invocation_id = model_status_flagging.command_invocation_id
    left join seed_status_flagging
      on base.command_invocation_id = seed_status_flagging.command_invocation_id
    left join snapshot_status_flagging
      on base.command_invocation_id = snapshot_status_flagging.command_invocation_id
    left join test_status_flagging
      on base.command_invocation_id = test_status_flagging.command_invocation_id
)

select * from final
