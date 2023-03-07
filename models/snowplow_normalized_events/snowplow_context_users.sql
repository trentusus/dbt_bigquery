{{ config(
    tags = "snowplow_normalize_incremental",
    materialized = var("snowplow__incremental_materialization", "snowplow_incremental"),
    unique_key = "user_id",
    upsert_date_key = "latest_collector_tstamp",
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by={
      "field": "latest_collector_tstamp",
      "data_type": "timestamp"
    }, databricks_partition_by='latest_collector_tstamp_date'),
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    tblproperties={
      'delta.autoOptimize.optimizeWrite' : 'true',
      'delta.autoOptimize.autoCompact' : 'true'
    }
) }}

{%- set user_cols = ['CONTEXTS_COM_SNOWPLOWANALYTICS_CONSOLE_USER_1_0_1'] -%}
{%- set user_keys = [['userId', 'firstName', 'lastName', 'organizationId', 'email', 'jobTitle', 'accessLevel']] -%}
{%- set user_types = [['string', 'string', 'string', 'string', 'string', 'string', 'string']] -%}

{{ snowplow_normalize.users_table(
    'network_userid',
    '',
    '',
    user_cols,
    user_keys,
    user_types
) }}
