WITH fund_daily AS (
    SELECT
        ha.TICKER,
        s.PRICE,
        s.EFFECTIVE_FROM,
        fp.SHARES_HELD,
        lfa.HK_FUND,
        s.PRICE * fp.SHARES_HELD AS POSITION_VALUE
    FROM {{ ref('sat_asset_market') }} s
    JOIN {{ ref('hub_asset') }}        ha ON s.HK_ASSET = ha.HK_ASSET
    JOIN {{ ref('lnk_fund_asset') }}   lfa ON s.HK_ASSET = lfa.HK_ASSET
    JOIN {{ ref('stg_fund_portfolio') }} fp ON lfa.HK_FUND = fp.HK_FUND
                                            AND lfa.HK_ASSET = fp.HK_ASSET
),

fund_total AS (
    SELECT
        HK_FUND,
        EFFECTIVE_FROM,
        SUM(POSITION_VALUE) AS FUND_VALUE
    FROM fund_daily
    GROUP BY HK_FUND, EFFECTIVE_FROM
),

benchmark_daily AS (
    SELECT
        sb.EFFECTIVE_FROM,
        sb.HK_BENCHMARK,
        hb.BENCHMARK_ID,
        sb.BENCHMARK_NAME,
        sb.BENCHMARK_VALUE
    FROM {{ ref('sat_benchmark_value') }} sb
    JOIN {{ ref('hub_benchmark') }}       hb ON sb.HK_BENCHMARK = hb.HK_BENCHMARK
)

SELECT
    hf.FUND_ID,
    f.EFFECTIVE_FROM            AS DATE,
    f.FUND_VALUE,
    b.BENCHMARK_NAME,
    b.BENCHMARK_VALUE,
    ROUND(100.0 * (f.FUND_VALUE / LAG(f.FUND_VALUE) OVER (PARTITION BY hf.FUND_ID ORDER BY f.EFFECTIVE_FROM) - 1), 4) AS FUND_RETURN_PCT,
    ROUND(100.0 * (b.BENCHMARK_VALUE / LAG(b.BENCHMARK_VALUE) OVER (PARTITION BY hf.FUND_ID ORDER BY f.EFFECTIVE_FROM) - 1), 4) AS BENCHMARK_RETURN_PCT
FROM fund_total f
JOIN {{ ref('hub_fund') }}             hf  ON f.HK_FUND = hf.HK_FUND
JOIN {{ ref('lnk_fund_benchmark') }}   lfb ON f.HK_FUND = lfb.HK_FUND
JOIN benchmark_daily                   b   ON lfb.HK_BENCHMARK = b.HK_BENCHMARK
                                            AND f.EFFECTIVE_FROM = b.EFFECTIVE_FROM
ORDER BY hf.FUND_ID, f.EFFECTIVE_FROM
