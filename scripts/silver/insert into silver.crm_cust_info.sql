
insert into silver.crm_cust_info(
 cst_id,
 cst_key,
 cst_firstname,
 cst_lastname,
 cst_gndr,
 cst_marital_status,

 cst_create_date
)

select 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname ,
TRIM(cst_lastname) as cst_firstname,
case 
	when upper(trim(cst_gndr)) = 'M' then 'Male' 
	when upper(trim(cst_gndr)) = 'F' then 'Female' 
	else 'n/a'
end as cst_gndr,


case 
 
	when cst_marital_status = 'S' then 'Single' 
	when cst_marital_status = 'M' then 'Married'
	else 'n/a'
end as cst_marital_status ,
cst_create_date
from 


(select *
,ROW_NUMBER() over (partition by cst_id order by cst_create_date DESC ) as flag
from
bronze.crm_cust_info
WHERE cst_id is not null )t
where flag = 1 

-----------------------------------
