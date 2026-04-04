{%- set src_pk = 'HK_ASSET' -%}
{%- set src_nk = 'TICKER' -%}
{%- set src_ldts = 'LOAD_DATETIME' -%}
{%- set src_source = 'RECORD_SOURCE' -%}

{{ automate_dv.hub(
    src_pk=src_pk,
    src_nk=src_nk,
    src_ldts=src_ldts,
    src_source=src_source,
    source_model='stg_market_data'
) }}
