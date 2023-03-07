{{ config(
    tags = "snowplow_normalize_incremental",
    materialized = var("snowplow__incremental_materialization", "snowplow_incremental"),
    unique_key = "event_id",
    upsert_date_key = "collector_tstamp",
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by={
      "field": "collector_tstamp",
      "data_type": "timestamp"
    }, databricks_partition_by='collector_tstamp_date'),
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    tblproperties={
      'delta.autoOptimize.optimizeWrite' : 'true',
      'delta.autoOptimize.autoCompact' : 'true'
    }
) }}

{%- set event_names = ['data_structures_workflow'] -%}
{%- set flat_cols = ['app_id', 'derived_tstamp', 'domain_userid', 'network_userid'] -%}
{%- set sde_cols = ['UNSTRUCT_EVENT_COM_SNOWPLOWANALYTICS_CONSOLE_DATA_STRUCTURES_WORKFLOW_1_0_2'] -%}
{%- set sde_keys = [['step_action', 'step_value', 'step_failure_reason']] -%}
{%- set sde_types = [['string', 'string', 'string']] -%}
{%- set sde_aliases = ['step'] -%}
{%- set context_cols = ['CONTEXTS_COM_SNOWPLOWANALYTICS_CONSOLE_USER_1_0_1'] -%}
{%- set context_keys = [['userId', 'firstName', 'lastName', 'organizationId', 'email', 'jobTitle', 'accessLevel']] -%}
{%- set context_types = [['string', 'string', 'string', 'string', 'string', 'string', 'string']] -%}
{%- set context_alias = [] -%}

{{ snowplow_normalize.normalize_events(
    event_names,
    flat_cols,
    sde_cols,
    sde_keys,
    sde_types,
    sde_aliases,
    context_cols,
    context_keys,
    context_types,
    context_alias
) }}
