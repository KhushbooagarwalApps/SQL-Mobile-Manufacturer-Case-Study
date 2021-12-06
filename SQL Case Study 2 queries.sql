1. WITH TEMP AS(
  	select f.date,f.IDLocation From DIM_CUSTOMER c inner join 
	FACT_TRANSACTIONS f on c.idcustomer= f.IDCustomer where year(f.Date)>=2005
) SELECT DISTINCT(STATE) as state FROM DIM_LOCATION L INNER JOIN TEMP P ON L.IDLocation=P.idlocation;

2.with temp as 
(SELECT city,sum(quantity) as quan FROM DIM_LOCATION L INNER JOIN FACT_TRANSACTIONS F
ON L.IDLocation=F.idlocation inner join DIM_MODEL p on F.IDModel= p.IDModel inner join DIM_MANUFACTURER b 
on  p.IDManufacturer=b.IDManufacturer WHERE L.country LIKE 'US' and b.Manufacturer_Name like 'Samsung' 
group by city)
select * from temp where quan=(SELECT Max(temp.quan) from temp);

3.select state,zipcode,COUNT(*) from FACT_TRANSACTIONS f inner join DIM_LOCATION l 
on f.IDLocation=l.IDLocation group by state,zipcode

4.select model_name,unit_price from DIM_MODEL where unit_price=(select min(unit_price) from DIM_MODEL)

5. select manufacturer_name,model_name as model,sum(quantity) as totquan,sum(totalprice)/sum(quantity) as average 
 from FACT_TRANSACTIONS f inner join 
DIM_MODEL a on f.IDModel=a.IDModel inner join 
DIM_MANUFACTURER b on a.IDManufacturer=b.IDManufacturer where manufacturer_name in 
(select Top 5 manufacturer_name as mn from FACT_TRANSACTIONS f inner join 
DIM_MODEL a on f.IDModel=a.IDModel inner join 
DIM_MANUFACTURER b on a.IDManufacturer=b.IDManufacturer 
 group by manufacturer_name order by sum(quantity) desc) 
group by manufacturer_name,model_name order by average desc

6. SELECT customer_name,average from (select customer_name,SUM(totalprice)/Sum(quantity) as average from DIM_CUSTOMER c inner join 
FACT_TRANSACTIONS f on c.IDCustomer=f.IDCustomer 
where year(date)=2009 GROUP BY customer_name) temp WHERE average >500;

7. WITH CTE AS
( SELECT RN = ROW_NUMBER() OVER(PARTITION BY YEAR([date]) ORDER BY COUNT(Quantity) DESC),IDModel,MyYear = YEAR([date]),Cnt = COUNT(Quantity)
  FROM Fact_Transactions WHERE YEAR(date) IN (2008,2009,2010) GROUP BY IDModel,YEAR([date])
)SELECT id_model FROM CTE WHERE RN <6 GROUP BY IDModel HAVING COUNT(1)=3

8.WITH cte AS
(
SELECT Manufacturer_name, DATEPART(Year,date) as yr,
DENSE_RANK() OVER (PARTITION BY DATEPART(Year,date) ORDER BY SUM(TotalPrice) DESC) AS Rank 
    FROM Fact_Transactions FT
    LEFT JOIN DIM_Model DM ON FT.IDModel = DM.IDModel
    LEFT JOIN DIM_MANUFACTURER MFC  ON MFC.IDManufacturer = DM.IDManufacturer
    group by Manufacturer_name,DATEPART(Year,date) 
),
cte2 AS(
SELECT Manufacturer_Name, yr
FROM cte WHERE rank = 2
AND yr IN ('2009','2010')
)
SELECT c.Manufacturer_Name AS Manufacturer_Name_2009
,t.Manufacturer_Name AS Manufacturer_Name_2010
FROM cte2 AS c, cte2 AS t
WHERE c.yr < t.yr;

9. select m.*
from dim_manufacturer m
where exists (select 1
              from FACT_TRANSACTIONS t join
                   DIM_MODEL mo
                   on t.idmodel = mo.idmodel
              where m.IDManufacturer = mo.IDManufacturer and
                    t.Date >= '2010-01-01' and t.Date < '2011-01-01'
             ) and
      not exists (select 1
                  from FACT_TRANSACTIONS t join
                       DIM_MODEL mo
                      on t.idmodel = mo.idmodel
                  where m.IDManufacturer = mo.IDManufacturer and
                        t.Date >= '2009-01-01' and t.Date < '2010-01-01'
                 ) ;


