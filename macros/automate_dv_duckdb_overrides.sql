{# ============================================================
   DuckDB dispatch overrides for automate_dv
   Store hashes as uppercase hex VARCHAR (like BigQuery non-native)
   ============================================================ #}

{#- Escape characters: DuckDB uses double quotes -#}
{%- macro duckdb__get_escape_characters() %}
    {%- do return (('"', '"')) -%}
{%- endmacro %}

{#- Date casting -#}
{%- macro duckdb__cast_date(column_str, as_string=false, alias=none) -%}
    {%- if not as_string -%}
        CAST({{ column_str }} AS DATE)
    {%- else -%}
        CAST('{{ column_str }}' AS DATE)
    {%- endif -%}
    {%- if alias %} AS {{ alias }} {%- endif %}
{%- endmacro -%}

{#- Datetime casting -#}
{%- macro duckdb__cast_datetime(column_str, as_string=false, alias=none, date_type=none) -%}
    CAST({{ column_str }} AS TIMESTAMP)
    {%- if alias %} AS {{ alias }} {%- endif %}
{%- endmacro -%}

{#- Binary type: store hashes as VARCHAR hex strings -#}
{%- macro duckdb__type_binary(for_dbt_compare=false) -%}
    VARCHAR
{%- endmacro -%}

{#- Timestamp type: DuckDB uses TIMESTAMP, not TIMESTAMP_NTZ -#}
{%- macro duckdb__type_timestamp() -%}
    TIMESTAMP
{%- endmacro -%}

{#- Cast binary: for DuckDB, just cast to VARCHAR -#}
{%- macro duckdb__cast_binary(column_str, alias=none, quote=true) -%}
    {%- if quote -%}
        CAST('{{ column_str }}' AS VARCHAR)
    {%- else -%}
        CAST({{ column_str }} AS VARCHAR)
    {%- endif -%}
    {%- if alias %} AS {{ alias }} {%- endif -%}
{%- endmacro -%}

{#- SHA-256: DuckDB sha256() returns hex string -#}
{%- macro duckdb__hash_alg_sha256() -%}
    {%- do return("UPPER(sha256([HASH_STRING_PLACEHOLDER])::VARCHAR)") -%}
{%- endmacro -%}

{#- MD5: DuckDB md5() returns hex string -#}
{%- macro duckdb__hash_alg_md5() -%}
    {%- do return("UPPER(md5([HASH_STRING_PLACEHOLDER]))") -%}
{%- endmacro -%}

{#- Binary ghost record: zero-filled hex VARCHAR -#}
{%- macro duckdb__binary_ghost(alias, hash) -%}
    {%- if hash == 'md5' -%}
        {%- set zero_string_size = 32 %}
    {%- elif hash == 'sha' -%}
        {%- set zero_string_size = 64 %}
    {%- elif hash == 'sha1' -%}
        {%- set zero_string_size = 40 %}
    {%- else -%}
        {%- set zero_string_size = 32 %}
    {%- endif -%}
    CAST('{{ '0' * zero_string_size }}' AS VARCHAR)
    {%- if alias %} AS {{ alias }} {%- endif -%}
{%- endmacro -%}
