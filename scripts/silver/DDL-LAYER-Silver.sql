-- ================================================================
-- Procedure Name: silver.load_Silver
-- Description   : This procedure transforms and loads data from
--                 bronze to silver layer in a Data Warehouse model.
--                 It includes CRM and ERP tables, cleaning and mapping
--                 data during the load process.
-- Author        : Abdelrahman Ebrahim Ghazy
-- Date Created  : 2025-07-11
-- ================================================================


USE Datawarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_Silver
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_end_time DATETIME, @batch_start_time DATETIME; 
    SET @batch_start_time = GETDATE();

    BEGIN TRY
        PRINT '======================================';
        PRINT 'Loading Silver Layer';
        PRINT '======================================';

        PRINT '======================================';
        PRINT 'Loading CRM Tables';
        PRINT '======================================';

        -- Load CRM Customer Info Table
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserting Data Into: silver.crm_cust_info'; 

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            -- Normalize gender values
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' 
                ELSE 'n/a'
            END,
            -- Normalize marital status values
            CASE 
                WHEN cst_marital_status = 'S' THEN 'Single' 
                WHEN cst_marital_status = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag = 1;
        SET @end_time = GETDATE();
        PRINT '>>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';
        PRINT '-----------------------------------------------------------------';

        -- Load CRM Product Info
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserting Data Into: silver.crm_prd_info'; 

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
            SUBSTRING(prd_key, 7, LEN(prd_key)), -- Extract product key part
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            prd_nm,
            ISNULL(prd_cost, 0), -- Replace NULL cost with 0
            -- Map product line codes to readable text
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            prd_start_dt,
            LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';
        PRINT '-----------------------------------------------------------------';

        -- Load CRM Sales Details
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserting Data Into: silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            -- Clean and convert order date
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            -- Clean and convert ship date
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            -- Clean and convert due date
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,
            -- Recalculate sales if necessary
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                 THEN sls_sales * ABS(sls_quantity)
                 ELSE sls_sales
            END,
            sls_quantity,
            -- Recalculate price if missing or zero
            CASE WHEN sls_price IS NULL OR sls_price <= 0
                 THEN sls_sales / NULLIF(sls_quantity, 0)
                 ELSE sls_price
            END
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';
        PRINT '-----------------------------------------------------------------';

        PRINT '======================================';
        PRINT 'Loading ERP Tables';
        PRINT '======================================';

        -- Load ERP Customer Data
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserting Data Into: silver.erp_cust_az12';

        INSERT INTO silver.erp_cust_az12 (CID, BDATE, GEN)
        SELECT 
            -- Remove 'NAS' prefix from CID
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID)) ELSE CID END,
            -- Remove future birthdates
            CASE WHEN BDATE > GETDATE() THEN NULL ELSE BDATE END,
            -- Normalize gender values
            CASE 
                WHEN UPPER(TRIM(GEN)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(GEN)) = 'M' THEN 'Male'
                WHEN GEN = ' ' THEN 'n/a'
                ELSE GEN
            END
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';
        PRINT '-----------------------------------------------------------------';

        -- Load ERP Location Data
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserting Data Into: silver.erp_loc_a101';

        INSERT INTO silver.erp_loc_a101 (CID, CNTRY)
        SELECT 
            REPLACE(CID, '-', '') AS CID, -- Remove dashes from CID
            CASE 
                WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
                WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
                WHEN TRIM(CNTRY) = 'US' THEN 'USA'
                ELSE TRIM(CNTRY)
            END AS CNTRY
        FROM bronze.erp_LOC_A101;
        SET @end_time = GETDATE();
        PRINT '>>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';
        PRINT '-----------------------------------------------------------------';

        -- Load ERP Product Category
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';

        INSERT INTO silver.erp_px_cat_g1v2 (ID, CAT, SUBCAT, MAINTENACE)
        SELECT ID, CAT, SUBCAT, MAINTENACE
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        SET @batch_end_time = GETDATE();
        PRINT '>>> LOAD DURATION : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' sec';
        PRINT '-----------------------------------------------------------------';

        PRINT 'All Silver Tables Loaded Successfully.';
        PRINT '>> END OF SILVER LAYER <<';
        PRINT 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' sec';
        PRINT '=============================';

    END TRY

    BEGIN CATCH
        -- Handle any unexpected errors
        PRINT '======================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error message: ' + ERROR_MESSAGE();
        PRINT 'Error number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error state  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '======================================';
    END CATCH
END;
GO
