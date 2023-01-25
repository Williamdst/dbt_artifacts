# dbt Artifacts Package (EON Adaptation)
The package builds a mart of tables and views describing the project it is installed in.
> ***This package is a modification of the [dbt_artifacts](https://github.com/brooklyn-data/dbt_artifacts) (v2.2.2) package managed by Brooklyn Data Company.***

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
    revision: 0.1.0
```

2. Run `dbt deps` to install the package

3. Add an on-run-end hook to your `dbt_project.yml`: `on-run-end: "{{ dbt_artifacts.upload_results(results) }}"`
(We recommend adding a conditional here so that the upload only occurs in your production environment, such as `on-run-end: "{% if target.name == 'prod' %}{{ dbt_artifacts.upload_results(results) }}{% endif %}"`)

4. If you are using [selectors](https://docs.getdbt.com/reference/node-selection/syntax), be sure to include the `dbt_artifacts` models in your dbt invocation step.

5. Run your project!

> :construction_worker: Always run the dbt_artifacts models in every dbt invocation which uses the `upload_results` macro. This ensures that the source models always have the correct fields in case of an update.

## Configuration

The following configuration can be used to specify where the raw (sources) data is uploaded, and where the dbt models are created:

```yml
models:
  ...
  dbt_artifacts_eon:
    +database: your_destination_database # optional, default is your target database
    +schema: your_destination_schema # optional, default is your target schema
    staging:
      +database: your_destination_database # optional, default is your target database
      +schema: your_destination_schema # optional, default is your target schema
    sources:
      +database: your_sources_database # optional, default is your target database
      +schema: your sources_database # optional, default is your target schema
```

Note that model materializations and `on_schema_change` configs are defined in this package's `dbt_project.yml`, so do not set them globally in your `dbt_project.yml` ([see docs on configuring packages](https://docs.getdbt.com/docs/building-a-dbt-project/package-management#configuring-packages)):

> Configurations made in your dbt_project.yml file will override any configurations in a package (either in the dbt_project.yml file of the package, or in config blocks).

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
Thank you to [Tails.com](https://tails.com/gb/careers/) for initial development and maintenance of this package. On 2021/12/20, the repository was transferred from the Tails.com GitHub organization to Brooklyn Data Co.

The macros in the early versions package were adapted from code shared by [Kevin Chan](https://github.com/KevinC-wk) and [Jonathan Talmi](https://github.com/jtalmi) of [Snaptravel](snaptravel.com).

Thank you for sharing your work with the community!

## Contributing

### Running the tests

1. Install pipx
```bash
pip install pipx
pipx ensurepath
```

2. Install tox
```bash
pipx install tox
```

3. Copy and paste the `integration_test_project/example-env.sh` file and save as `env.sh`. Fill in the missing values.

4. Source the file in your current shell context with the command: `. ./env.sh`.

5. From this directory, run

```
tox -e integration_snowflake # For the Snowflake tests
tox -e integration_databricks # For the Databricks tests
tox -e integration_bigquery # For the BigQuery tests
```

The Spark tests require installing the [ODBC driver](https://www.databricks.com/spark/odbc-drivers-download). On a Mac, DBT_ENV_SPARK_DRIVER_PATH should be set to `/Library/simba/spark/lib/libsparkodbc_sbu.dylib`. Spark tests have not yet been added to the integration tests.

### SQLFluff

We use SQLFluff to keep SQL style consistent. A GitHub action automatically tests pull requests and adds annotations where there are failures. SQLFluff can also be run locally with `tox`. To install tox, we recommend using `pipx`.

Install pipx:
```bash
pip install pipx
pipx ensurepath
```

Install tox:
```bash
pipx install tox
```

Lint all models in the /models directory:
```bash
tox
```

Fix all models in the /models directory:
```bash
tox -e fix_all
```

Lint (or subsitute lint to fix) a specific model:
```bash
tox -e lint -- models/path/to/model.sql
```

Lint (or subsitute lint to fix) a specific directory:
```bash
tox -e lint -- models/path/to/directory
```

#### Rules

Enforced rules are defined within `tox.ini`. To view the full list of available rules and their configuration, see the [SQLFluff documentation](https://docs.sqlfluff.com/en/stable/rules.html).


Tip - Output the mart to a separate schema. I personally use DBT_AUDIT
Note - The package creates another two sets of tables (the source models and the stage views)
Note: There is a potential error if the model information query text goes over the 1MB
Note: How to revert back to the original package
