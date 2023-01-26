# dbt Artifacts Package (EON Adaptation)
The package builds a mart of tables and views describing the project it is installed in.
> ***This package is a modification of the [dbt_artifacts](https://github.com/brooklyn-data/dbt_artifacts) (v2.2.2) package developed by Brooklyn Data Co.***

## Supported Data Warehouses

The package currently supports
- Snowflake :white_check_mark:

Models included:

```
dim_dbt__current_models
dim_dbt__exposures
dim_dbt__models
dim_dbt__seeds
dim_dbt__snapshots
dim_dbt__sources
dim_dbt__tests
fct_dbt__invocations
fct_dbt__model_executions
fct_dbt__model_information
fct_dbt__seed_executions
fct_dbt__snapshot_executions
fct_dbt__test_executions
```

## Quickstart

1. Add this package to your `packages.yml`:
```
packages:
  - git: "https://github.com/eon-collective/dbt_artifacts_eon.git"
    revision: <latest.release.number>
```

2. Run `dbt deps` to install the package

3. Add an on-run-end hook to your `dbt_project.yml`: `on-run-end: "{{ dbt_artifacts.upload_results(results) }}"` (We recommend adding a conditional here so that the upload only occurs in your production environment, such as `on-run-end: "{% if target.name == 'prod' %}{{ dbt_artifacts.upload_results(results) }}{% endif %}"`)

4. If you are using [selectors](https://docs.getdbt.com/reference/node-selection/syntax), be sure to include the `dbt_artifacts` models in your dbt invocation step.

5. Run your project!

> :construction_worker: Always run the dbt_artifacts models in every dbt invocation which uses the `upload_results` macro. This ensures that the source models always have the correct fields in case of an update.

> :bulb: To run the package without pulling data from the `INFORMATION_SCHEMA.TABLES` use `dbt_project.yml`: `on-run-end: "{{ dbt_artifacts.upload_results(results, include_information=true) }}"`


## Configuration

The following configuration can be used to specify where the raw (sources) data is uploaded, and where the dbt models are created:

```yml
models:
  ...
  dbt_artifacts:
    +database: your_destination_database # optional, default is your target database
    +schema: your_destination_schema # optional, default is your target schema
    staging:
      +database: your_destination_database # optional, default is your target database
      +schema: your_destination_schema # optional, default is your target schema
    sources:
      +database: your_sources_database # optional, default is your target database
      +schema: your sources_database # optional, default is your target schema
```
> :bulb: A Recommendation is that the models be outputted to a seperate schema from the target (DBT_AUDIT). Although there are only 13 Facts & Dimensions, the package creates 37 Total Objects.

Note that model materializations and `on_schema_change` configs are defined in this package's `dbt_project.yml`, so do not set them globally in your `dbt_project.yml` ([see docs on configuring packages](https://docs.getdbt.com/docs/building-a-dbt-project/package-management#configuring-packages)):

> Configurations made in your dbt_project.yml file will override any configurations in a package (either in the dbt_project.yml file of the package, or in config blocks).

### Configurations Inside the Package [(source)](https://github.com/eon-collective/dbt_mart_auditor/blob/main/dbt_project.yml)

```yml
models:
  dbt_artifacts:
    +materialized: view
    +file_format: delta # Used for Spark configurations
    sources:
      +materialized: incremental
      +on_schema_change: append_new_columns
      +full_refresh: false
```

### Environment Variables

If the project is running in dbt Cloud, the following five columns (https://docs.getdbt.com/docs/dbt-cloud/using-dbt-cloud/cloud-environment-variables#special-environment-variables) will be automatically populated in the fct_dbt__invocations model:
- dbt_cloud_project_id
- dbt_cloud_job_id
- dbt_cloud_run_id
- dbt_cloud_run_reason_category
- dbt_cloud_run_reason

To capture other environment variables in the fct_dbt__invocations model in the `env_vars` column, add them to the `env_vars` variable in your `dbt_project.yml`. Note that environment variables with secrets (`DBT_ENV_SECRET_`) can't be logged.
```yml
vars:
  env_vars: [
    'ENV_VAR_1',
    'ENV_VAR_2',
    '...'
  ]
```

### dbt Variables

To capture dbt variables in the fct_dbt__invocations model in the `dbt_vars` column, add them to the `dbt_vars` variable in your `dbt_project.yml`.
```yml
vars:
  dbt_vars: [
    'var_1',
    'var_2',
    '...'
  ]
```

## Acknowledgements
Thank you to [Tails.com](https://tails.com/gb/careers/) for initial development and maintenance of this package. On 2021/12/20, the repository was transferred from the Tails.com GitHub organization to [Brooklyn Data Co.](https://brooklyndata.co/). On 2022/12/16, the repository was forked by [EON Collective](https://www.eoncollective.com/).

The macros in the early versions package were adapted from code shared by [Kevin Chan](https://github.com/KevinC-wk) and [Jonathan Talmi](https://github.com/jtalmi) of [Snaptravel](snaptravel.com).

Thank you for sharing your work with the community!

## Why Fork & Not Contribute?
The original `dbt Artifacts` package is compatible with Databricks, Spark, Snowflake, & BigQuery. To integrate code changes into the repository those changes have to compatible with all four services. Our development efforts are Snowflake specific.

Note - The package creates another two sets of tables (the source models and the stage views)
Note: There is a potential error if the model information query text goes over the 1MB
