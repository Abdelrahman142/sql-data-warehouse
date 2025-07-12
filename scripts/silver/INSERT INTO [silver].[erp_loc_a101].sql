
USE Datawarehouse;
GO 

PRINT 'TABLE TRUNCATED ';
TRUNCATE TABLE  [silver].[erp_loc_a101];
INSERT INTO [silver].[erp_loc_a101] (CID ,CNTRY)

--SELECT DISTINCT CNTRY FROM [bronze].[erp_loc_a101]


SELECT 

REPLACE(CID,'-' ,'')AS CID,

CASE WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
	 WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
	 WHEN TRIM(CNTRY) = 'US' THEN 'USA'

ELSE TRIM(CNTRY)
END AS CNTRY
FROM bronze.erp_LOC_A101
