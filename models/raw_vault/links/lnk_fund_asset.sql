{%- set src_pk = 'HK_FUND_ASSET' -%}
{%- set src_fk = ['HK_FUND', 'HK_ASSET'] -%}
{%- set src_ldts = 'LOAD_DATETIME' -%}
{%- set src_source = 'RECORD_SOURCE' -%}

{{ automate_dv.link(
    src_pk=src_pk,
    src_fk=src_fk,
    src_ldts=src_ldts,
    src_source=src_source,
    source_model='stg_fund_portfolio'
) }}
