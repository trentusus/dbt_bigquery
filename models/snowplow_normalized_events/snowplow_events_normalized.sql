{{ config(
    tags = "snowplow_normalize_incremental",
    materialized = var("snowplow__incremental_materialization", "snowplow_incremental"),
    unique_key = "unique_id",
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

select
    event_id
    , collector_tstamp
    {% if target.type in ['databricks', 'spark'] -%}
    , DATE(collector_tstamp) as collector_tstamp_date
    {%- endif %}
    , event_name
    , 'data_structures_workflow_1' as event_table_name
    , event_id||'-'||'data_structures_workflow_1' as unique_id
from
    {{ ref('snowplow_normalize_base_events_this_run') }}
where
    event_name in ('data_structures_workflow')
    and {{ snowplow_utils.is_run_with_new_events("snowplow_normalize") }}
        