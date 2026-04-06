{%- set src_pk = 'HK_BENCHMARK' -%}
{%- set src_hashdiff = 'HASHDIFF_BENCHMARK' -%}
{%- set src_payload = ['BENCHMARK_NAME', 'BENCHMARK_VALUE'] -%}
{%- set src_eff = 'EFFECTIVE_FROM' -%}
{%- set src_ldts = 'LOAD_DATETIME' -%}
{%- set src_source = 'RECORD_SOURCE' -%}

{{ automate_dv.sat(
    src_pk=src_pk,
    src_hashdiff=src_hashdiff,
    src_payload=src_payload,
    src_eff=src_eff,
    src_ldts=src_ldts,
    src_source=src_source,
    source_model='stg_benchmark_data'
) }}
