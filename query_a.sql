-- 1. What are the top 5 brands by receipts scanned for most recent month?
-- 2. How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month? 

WITH RecentDate AS (
    SELECT 
        STRFTIME('%Y', MAX(scanned_date)) AS recent_year
        , STRFTIME('%m', MAX(scanned_date)) AS recent_month
        , STRFTIME('%Y', DATE(MAX(scanned_date), '-1 month')) AS previous_year
        , STRFTIME('%m', DATE(MAX(scanned_date), '-1 month')) AS previous_month
    FROM FactReceiptItems 
),
RankedBrandsRecent AS (
    SELECT 
        db.name AS brand_name
        , COUNT(DISTINCT fr.receipt_id) AS receipt_cnt
        , ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT fr.receipt_id) DESC) AS rk_recent
    FROM FactReceiptItems fr
       LEFT JOIN DimBrand db
           ON fr.brand_code = db.brand_code 
       LEFT JOIN DimDate dd
           ON fr.scanned_date = dd.date_key
       INNER JOIN RecentDate md
           ON dd.year = md.recent_year AND dd.month = md.recent_month
    WHERE 
        fr.brand_code IS NOT NULL
        AND db.name IS NOT NULL        
    GROUP BY 
        db.name
),
RankedBrandsPrevious AS (
    SELECT 
        db.name AS brand_name
        , COUNT(DISTINCT fr.receipt_id) AS receipt_cnt
        , ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT fr.receipt_id) DESC) AS rk_previous
    FROM FactReceiptItems fr
       LEFT JOIN DimBrand db
            ON fr.brand_code = db.brand_code 
       LEFT JOIN DimDate dd
            ON fr.scanned_date = dd.date_key
       INNER JOIN RecentDate md
           ON dd.year = md.previous_year AND dd.month = md.previous_month
    WHERE 
        fr.brand_code IS NOT NULL
        AND db.name IS NOT NULL
    GROUP BY 
        db.name
)

SELECT
    COALESCE(rbr.brand_name, rbp.brand_name) AS brand_name
    , rbr.rk_recent
    , rbp.rk_previous
    , rbr.receipt_cnt AS recent_receipt_cnt
    , rbp.receipt_cnt AS previous_receipt_cnt
FROM RankedBrandsRecent rbr
    FULL OUTER JOIN RankedBrandsPrevious rbp 
        ON rbr.brand_name = rbp.brand_name
WHERE 
    rbr.rk_recent <= 5 
    OR rbp.rk_previous <=5
ORDER BY 
    rbr.rk_recent
    , rbp.rk_previous
;