-- 5. Which brand has the most spend among users who were created within the past 6 months?
-- 6. Which brand has the most transactions among users who were created within the past 6 months?

WITH UniqueReceipt AS (
    SELECT DISTINCT 
        receipt_id
        , user_id
        , brand_code
        , receipt_total_spent
    FROM FactReceiptItems
),
RankedBrands AS (
    SELECT 
        db.name AS brand_name
        , SUM(receipt_total_spent) AS receipt_total_spent
        , COUNT(DISTINCT receipt_id) AS receipt_count
        , ROW_NUMBER() OVER (ORDER BY SUM(receipt_total_spent) DESC) AS rk_sp
        , ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT receipt_id) DESC) AS rk_trxn
    FROM UniqueReceipt ur
        LEFT JOIN DimUser du
            ON ur.user_id = du.user_id
        LEFT JOIN DimBrand db
            ON ur.brand_code = db.brand_code 
    WHERE 
        ur.brand_code IS NOT NULL
        AND db.name IS NOT NULL         
        AND du.created_date >= (SELECT STRFTIME('%Y%m%d', DATE(MAX(last_login_date), '-6 month')) FROM DimUser) 
    GROUP BY 
        db.name
)

SELECT 
    brand_name
    , receipt_total_spent
    , receipt_count
    , rk_sp
    , rk_trxn
FROM RankedBrands
WHERE rk_sp = 1 OR rk_trxn = 1
ORDER BY rk_sp, rk_trxn
;