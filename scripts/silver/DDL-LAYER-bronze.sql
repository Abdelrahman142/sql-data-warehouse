USE Datawarehouse;
GO
-- Drop existing tables if they exist

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO



IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

IF OBJECT_ID('silver.erp_CUST_AZ12','U') IS NOT NULL
    DROP TABLE silver.erp_CUST_AZ12;
GO

IF OBJECT_ID('silver.erp_LOC_A101','U') IS NOT NULL
    DROP TABLE silver.erp_LOC_A101;
GO

IF OBJECT_ID('silver.erp_PX_CAT_G1V2','U') IS NOT NULL
    DROP TABLE silver.erp_PX_CAT_G1V2 ;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date Datetime2 Default getdate()
);
GO
use Datawarehouse
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    cat_id NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date Datetime2 Default getdate()
);
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt date,
    sls_ship_dt  date,
    sls_due_dt   date,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date Datetime2 Default getdate()
);
GO
-----------------------------
create table silver.erp_cust_az12 (
CID NVARCHAR (50),
BDATE DATE ,
GEN NVARCHAR(50),
    dwh_create_date Datetime2 Default getdate()

);

GO
-------------------------------

create table silver.erp_loc_a101 (
CID NVARCHAR(50),
CNTRY NVARCHAR (50),
dwh_create_date Datetime2 Default getdate()
);
------------------------------
GO


create table silver.erp_px_cat_g1v2 (
ID NVARCHAR(50) ,
CAT NVARCHAR(50),
SUBCAT NVARCHAR(50),
MAINTENACE NVARCHAR(50),
dwh_create_date Datetime2 Default getdate()

);
----------------------------
