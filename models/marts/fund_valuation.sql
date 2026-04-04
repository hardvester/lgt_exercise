WITH latest_prices AS (
    SELECT
        HK_ASSET,
        PRICE,
        CURRENCY,
        EFFECTIVE_FROM,
        ROW_NUMBER() OVER (
            PARTITION BY HK_ASSET
            ORDER BY LOAD_DATETIME DESC
        ) AS rn
    FROM {{ ref('sat_asset_market') }}
),

current_prices AS (
    SELECT HK_ASSET, PRICE, CURRENCY, EFFECTIVE_FROM
    FROM latest_prices
    WHERE rn = 1
),

fund_holdings AS (
    SELECT
        hf.FUND_ID,
        hf.HK_FUND,
        lfa.HK_ASSET,
        fp.FUND_NAME,
        fp.SHARES_HELD
    FROM {{ ref('hub_fund') }}          hf
    JOIN {{ ref('lnk_fund_asset') }}    lfa ON hf.HK_FUND = lfa.HK_FUND
    JOIN {{ ref('stg_fund_portfolio') }} fp  ON hf.HK_FUND = fp.HK_FUND
                                             AND lfa.HK_ASSET = fp.HK_ASSET
)

SELECT
    fh.FUND_ID,
    fh.FUND_NAME,
    ha.TICKER,
    fh.SHARES_HELD,
    cp.PRICE           AS LATEST_PRICE,
    cp.CURRENCY,
    cp.EFFECTIVE_FROM   AS PRICE_DATE,
    fh.SHARES_HELD * cp.PRICE AS POSITION_VALUE
FROM fund_holdings      fh
JOIN {{ ref('hub_asset') }}  ha ON fh.HK_ASSET = ha.HK_ASSET
JOIN current_prices          cp ON fh.HK_ASSET = cp.HK_ASSET
