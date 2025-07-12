/*# Bronze Layer ETL Load Instructions

This procedure loads raw CSV data from the local filesystem into the `bronze` schema of the `Datawarehouse` database.

## 📦 Prerequisites

- SQL Server installed and running.
- `Datawarehouse` database exists.
- `bronze` schema exists inside `Datawarehouse`.
- Tables must be already created (run the table creation script first).
- Dataset `.csv` files must be present in the correct local path.

## 📁 File Paths Expected

The following CSV files must be located as follows:
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME , @batch_end_time DATETIME;
    SET @batch_start_time = GETDATE ();

    BEGIN TRY   
        PRINT'>>Trauncating Tables';
        TRUNCATE TABLE bronze.crm_cust_info;
        TRUNCATE TABLE bronze.crm_prd_info;
        TRUNCATE TABLE bronze.crm_sales_details;
        TRUNCATE TABLE bronze.erp_cust_az12;
        TRUNCATE TABLE bronze.erp_loc_a101;
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT '======================================';
        PRINT 'Loading Bronze Layer';
        PRINT '======================================';

        PRINT '======================================';
        PRINT 'Loading CRM Tables';
        PRINT '======================================';

        SET @start_time = GETDATE ();
        PRINT '>> Inserting Data Into:bronze.crm_cust_info'; 
        BULK INSERT bronze.crm_cust_info
        FROM '/data/source_crm/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK

        );
        SET @end_time = GETDATE ();
        PRINT 'Load Duration: ' + cast(DATEDIFF(second, @start_time ,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------' 

        SET @start_time = GETDATE ();
        PRINT '>> Inserting Data Into:bronze.crm_prd_info'; 
        BULK INSERT bronze.crm_prd_info
        FROM '/data/source_crm/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK

        );
        SET @end_time = GETDATE ();
        PRINT 'Load Duration: ' + cast(DATEDIFF(second, @start_time ,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------' 


        SET @start_time = GETDATE ();
        PRINT '>> Inserting Data Into:bronze.crm_sales_details' 
        BULK INSERT bronze.crm_sales_details
        FROM '/data/source_crm/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK

        );
        SET @end_time = GETDATE ();
        PRINT 'Load Duration: ' + cast(DATEDIFF(second, @start_time ,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------' 


        PRINT '======================================';
        PRINT 'Loading ERP Tables';
        PRINT '======================================';

        SET @start_time = GETDATE ();
        PRINT '>> Inserting Data Into:bronze.erp_cust_az12'; 

        BULK INSERT bronze.erp_cust_az12
        FROM '/data/source_erp/CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK

        );
        SET @end_time = GETDATE ();
        PRINT 'Load Duration: ' + cast(DATEDIFF(second, @start_time ,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------' 


        SET @start_time = GETDATE ();
        PRINT '>> Inserting Data Into:bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM '/data/source_erp/LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK

        );
        SET @end_time = GETDATE ();
        PRINT 'Load Duration: ' + cast(DATEDIFF(second, @start_time ,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------' 


        SET @start_time = GETDATE ();
        PRINT '>> Inserting Data Into:bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/data/source_erp/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK

        );
        SET @end_time = GETDATE ();
        PRINT 'Load Duration: ' + cast(DATEDIFF(second, @start_time ,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '=======================' 
        PRINT '>> END OF BRONZE LAYER<< '  
        SET @batch_end_time = GETDATE ();
        PRINT 'Total Load Duration: ' + cast(DATEDIFF(second, @batch_start_time ,@batch_end_time) AS NVARCHAR) + 'seconds';
        PRINT '=======================' 


    END TRY
    BEGIN CATCH
        PRINT '======================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error massage' + ERROR_MESSAGE();
        PRINT 'Error massage' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error massage' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '======================================';
    END CATCH


END
