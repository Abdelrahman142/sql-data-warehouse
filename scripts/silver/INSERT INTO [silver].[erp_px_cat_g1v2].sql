USE Datawarehouse
GO
PRINT 'TABLE TRUNCATED ';
TRUNCATE TABLE  [silver].[erp_px_cat_g1v2]
INSERT INTO [silver].[erp_px_cat_g1v2] (ID,
CAT,
SUBCAT,
MAINTENACE)

SELECT 
ID,
CAT,
SUBCAT,
MAINTENACE
FROM [bronze].[erp_px_cat_g1v2]
