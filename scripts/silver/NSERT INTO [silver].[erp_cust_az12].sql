use Datawarehouse;
GO 

PRINT 'TABLE TRUNCATED ';
TRUNCATE TABLE [silver].[erp_cust_az12] ;
INSERT INTO [silver].[erp_cust_az12] (CID,BDATE,GEN)
select 
		case 
	when cid like 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
	ELSE CID
	END AS CID,

	case when BDATE > GETDATE() then null
	else BDATE
	end as BDATE,

		CASE WHEN upper(trim(GEN)) = 'F' THEN 'Female'
		 WHEN upper(trim(GEN)) = 'M' THEN 'Male'
		 WHEN GEN = ' ' THEN 'n/a'

	else GEN 
    END AS GEN 

	from [bronze].[erp_cust_az12]
