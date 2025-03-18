-- 3. When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
-- 4. When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

WITH UniqueReceipt AS (
    SELECT DISTINCT 
        receipt_id
        , receipt_total_spent
        , receipt_purchased_item_count
    FROM FactReceiptItems
)

SELECT 
    CASE 
        -- 'Accepted' not found, assume 'FINISHED' is 'Accepted'. 
        WHEN dr.rewards_receipt_status = 'FINISHED' THEN 'Accepted'
        WHEN dr.rewards_receipt_status = 'REJECTED' THEN 'Rejected'
     END AS rewards_receipt_status
    , AVG(receipt_total_spent) AS avg_total_spent
    , SUM(receipt_purchased_item_count) AS purchased_item_total
FROM DimReceipt dr
    LEFT JOIN UniqueReceipt ur
        ON dr.receipt_id = ur.receipt_id
WHERE dr.rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY dr.rewards_receipt_status
ORDER BY 
    AVG(receipt_total_spent) DESC
    , SUM(receipt_purchased_item_count) DESC
;