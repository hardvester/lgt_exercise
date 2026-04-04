# LGT Vault Project

A Data Vault 2.0 implementation using [dbt](https://www.getdbt.com/) and [AutomateDV](https://automate-dv.readthedocs.io/) (formerly dbtvault), running on DuckDB.

Tracks a **Princely Selection Fund** portfolio with market price data (mock Yahoo Finance) and fund ownership data.

## Architecture

```
Seeds (CSV)          Staging (SHA-256 Hashing)       Raw Vault                    Mart
─────────────        ────────────────────────        ─────────                    ────
raw_market_data  ──► stg_market_data            ──► HUB_ASSET
                                                 ──► SAT_ASSET_MARKET (SCD2)  ──► fund_valuation
raw_fund_portfolio ► stg_fund_portfolio          ──► HUB_FUND                     (Star Schema)
                                                 ──► LNK_FUND_ASSET
```

## Data Model

| Layer | Model | Description |
|-------|-------|-------------|
| **Hub** | `hub_asset` | Unique assets by TICKER (VT, VOO) |
| **Hub** | `hub_fund` | Unique funds by FUND_ID |
| **Link** | `lnk_fund_asset` | Fund-to-Asset relationships |
| **Satellite** | `sat_asset_market` | Price & currency history (SCD Type 2) |
| **Mart** | `fund_valuation` | Latest portfolio valuation per fund |

## Setup

### Prerequisites

- Python 3.11+
- dbt-core 1.9+
- dbt-duckdb

### Install

```bash
pip install dbt-duckdb
```

Add this profile to `~/.dbt/profiles.yml`:

```yaml
lgt_vault_project:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: /path/to/vault.duckdb
      threads: 4
```

### Run

```bash
dbt deps          # install automate_dv package
dbt seed          # load CSV data into DuckDB
dbt run           # build staging, vault, and mart models
```

### Query the result

```sql
SELECT
    FUND_NAME,
    TICKER,
    SHARES_HELD,
    LATEST_PRICE,
    POSITION_VALUE,
    SUM(POSITION_VALUE) OVER () AS TOTAL_FUND_VALUE
FROM main_marts.fund_valuation;
```

**Sample output:**

| FUND_NAME | TICKER | SHARES | PRICE | POSITION_VALUE | TOTAL_FUND_VALUE |
|-----------|--------|--------|-------|----------------|------------------|
| Princely Selection | VT | 10,000 | $104.87 | $1,048,700 | $3,446,700 |
| Princely Selection | VOO | 5,000 | $479.60 | $2,398,000 | $3,446,700 |

## DuckDB Compatibility

AutomateDV doesn't natively support DuckDB. This project includes custom dispatch overrides in `macros/automate_dv_duckdb_overrides.sql` for hash functions, binary types, and date casting.

Staging models are materialized as **tables** (not views) to work around a DuckDB CTAS+QUALIFY bug with computed columns.

## Standards

- **Hashing**: SHA-256 (uppercase hex VARCHAR)
- **Business keys**: `UPPER(TRIM())` before hashing
- **Methodology**: Data Vault 2.0
