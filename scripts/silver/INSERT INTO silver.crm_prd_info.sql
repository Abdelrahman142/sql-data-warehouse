USE Datawarehouse
GO 

PRINT 'TABLE TRUNCATED ';
TRUNCATE TABLE  [silver].[crm_prd_info];

INSERT INTO silver.crm_prd_info (
    prd_id,
    prd_key,
    cat_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
    prd_id,
    substring(prd_key,7,len(prd_key)) as prd_key, -- Now used correctly here
    replace(substring(prd_key,1,5),'-','_') as cat_id,
    prd_nm,
    isnull(prd_cost,0) as prd_cost,
    CASE upper(trim(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'other sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END as prd_line,
    prd_start_dt,
    lead(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) as prd_end_dt
FROM bronze.crm_prd_info;
