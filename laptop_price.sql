--Data Cleanining



--get data backup
SELECT * INTO laptop_backup FROM laptopData WHERE 1=0;

INSERT INTO laptop_backup SELECT * FROM laptopData;

--get table detail
EXEC sp_spaceused 'laptop_price.dbo.laptopdata';
exec sp_spaceused

-- I have a problem in this query
--SELECT (DATA_LENGTH/1024) FROM information_schema.TABLES
--WHERE TABLE_SCHEMA = 'laptop_price'
--AND TABLE_NAME = 'laptopData';


--Drop non imp columns
SELECT * FROM laptopData;
ALTER TABLE laptopData DROP COLUMN [Unnamed_0];

--rename colume 
EXEC sp_rename 'laptopdata.Unnamed_0', 'index', 'COLUMN';

--delete row in which all column having null values

DELETE FROM laptopData
       WHERE Company IS NULL AND 
	         TypeName IS NULL AND 
			 Inches IS NULL AND 
			 ScreenResolution IS NULL AND 
			 Cpu IS NULL AND 
			 Ram IS NULL AND
			 Memory IS NULL AND 
			 Gpu IS NULL AND 
			 OpSys IS NULL AND
             WEIGHT IS NULL AND
			 Price IS NULL;

--To find duplicate row
SELECT Company, 
       TypeName,
	   Inches,
	   ScreenResolution,
	   Cpu,Ram,
	   Memory,Gpu,
	   OpSys,WEIGHT,
	   Price, 
	   COUNT(*) AS duplicate_count
FROM laptopData
GROUP BY Company, 
         TypeName,Inches,
		 ScreenResolution,
		 Cpu,Ram,Memory,
		 Gpu,OpSys,WEIGHT,Price
HAVING COUNT(*) > 1;

--Update Ram column
SELECT ram,REPLACE(Ram,'GB','') from laptopData

UPDATE laptopData
SET Ram = REPLACE(Ram,'GB','')
--convert ram column to integer
ALTER TABLE laptopdata 
ALTER COLUMN Ram INT;

--Update weight column
SELECT Weight,REPLACE(Weight,'KG','') FROM laptopData

UPDATE laptopData
SET Weight = REPLACE(Weight,'KG','')

--Update Price column
SELECT price, ROUND(Price, 0) from laptopData

UPDATE laptopData
SET Price = ROUND(Price, 0)

--Update Opsys 
SELECT OpSys,
       CASE
           WHEN OpSys LIKE '%mac%' THEN 'macos'
           WHEN OpSys LIKE 'windows%' THEN 'windows'
           WHEN OpSys LIKE '%linux%' THEN 'linux'
           WHEN OpSys = 'No OS' THEN 'N/A'
           ELSE 'other'
       END AS 'os_brand'
FROM laptopData;

UPDATE laptopData
SET OpSys =
            CASE
                WHEN OpSys LIKE '%mac%' THEN 'macos'
                WHEN OpSys LIKE 'windows%' THEN 'windows'
                WHEN OpSys LIKE '%linux%' THEN 'linux'
                WHEN OpSys = 'No OS' THEN 'N/A'
                ELSE 'other'
            END;

--Update gpu 
--add new column
ALTER TABLE laptopData
ADD gpu_brand VARCHAR(255) NULL,
    gpu_name VARCHAR(255) NULL;

--How to change position of new column after gpu column
--Update gpu_brand
select gpu,SUBSTRING(Gpu, 1, CHARINDEX(' ', Gpu + ' ') - 1) from laptopData

UPDATE laptopData 
SET gpu_brand = SUBSTRING(Gpu, 1, CHARINDEX(' ', Gpu + ' ') - 1)
FROM laptopData;

--Update gpu_name
select gpu,REPLACE(Gpu, gpu_brand, '')  from laptopdata

UPDATE laptopData
SET gpu_name = REPLACE(Gpu, gpu_brand, '')
               WHERE gpu_brand IS NOT NULL;

--Drop gpu
ALTER TABLE laptopData DROP COLUMN Gpu;

--Update Cpu column
--add new column
ALTER TABLE laptopData
ADD cpu_brand VARCHAR(255) NULL,
    cpu_name VARCHAR(255) NULL,
	cpu_speed DECIMAL(10,1) NULL;

--Update cpu_brand
select cpu, SUBSTRING(Cpu, 1, CHARINDEX(' ', Cpu + ' ') - 1) from laptopData
UPDATE laptopData 
SET cpu_brand = SUBSTRING(Cpu, 1, CHARINDEX(' ', Cpu + ' ') - 1)


UPDATE laptopData
SET cpu_name =  REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), '') 
 
select REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), '') from laptopData
---------------------------------------
UPDATE laptopData 
SET cpu_speed = CAST(
        CASE 
            WHEN ISNUMERIC(
                REPLACE(
                    SUBSTRING(
                        REPLACE(
                            REPLACE(
                                CPU,
                                REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), ''),
                                ''
                            ),
                            cpu_brand,
                            ''
                        ),
                        PATINDEX('%[0-9.-]%', REPLACE(REPLACE(CPU,REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), ''),''),cpu_brand,'')),
                        LEN(REPLACE(REPLACE(CPU,REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), ''),''),cpu_brand,''))
                    ),
                    'GHz',
                    ''
                )
            ) = 1
            THEN 
                CAST(
                    REPLACE(
                        SUBSTRING(
                            REPLACE(
                                REPLACE(
                                    CPU,
                                    REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), ''),
                                    ''
                                ),
                                cpu_brand,
                                ''
                            ),
                            PATINDEX('%[0-9.-]%', REPLACE(REPLACE(CPU,REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), ''),''),cpu_brand,'')),
                            LEN(REPLACE(REPLACE(CPU,REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), ''),''),cpu_brand,''))
                        ),
                        'GHz',
                        ''
                    ) AS DECIMAL(10,1)
            ) 
            ELSE 0
        END 
        AS DECIMAL(10,1))


select REPLACE(REPLACE(CPU,REPLACE(REPLACE(Cpu, cpu_brand, ''), RIGHT(Cpu, 6), ''),''),cpu_brand,'') from laptopData
 


--Drop cpu column
ALTER TABLE laptopData DROP COLUMN cpu;

-- add new column 
ALTER TABLE laptopData
ADD resolution_width INTEGER NULL,
    resolution_height INTEGER NULL;
	

UPDATE laptopData 
 set resolution_width =   LEFT(REVERSE(SUBSTRING(REVERSE(ScreenResolution), 1, CHARINDEX(' ', REVERSE(ScreenResolution) + ' ') - 1)),
	                            CHARINDEX('x', REVERSE(SUBSTRING(REVERSE(ScreenResolution), 1,
								CHARINDEX(' ', REVERSE(ScreenResolution) + ' ') - 1))) - 1)

UPDATE laptopData
 set resolution_height = RIGHT(REVERSE(SUBSTRING(REVERSE(ScreenResolution), 1, CHARINDEX(' ', REVERSE(ScreenResolution) + ' ') - 1)),
	                          LEN(REVERSE(SUBSTRING(REVERSE(ScreenResolution), 1, CHARINDEX(' ', REVERSE(ScreenResolution) + ' ') - 1))) 
	                          - CHARINDEX('x', REVERSE(SUBSTRING(REVERSE(ScreenResolution), 1, CHARINDEX(' ', REVERSE(ScreenResolution) + ' ') - 1)))) 

-- add touchscreen column
ALTER TABLE laptopData
ADD touchscreen INTEGER NULL;

UPDATE laptopData
SET touchscreen = CASE WHEN ScreenResolution LIKE '%Touch%' 
                       THEN 1 
					   ELSE 0 
				  END ;

--update cpu_name
UPDATE laptopData
SET cpu_name = CASE WHEN cpu_name Like '%core%' 
                    THEN SUBSTRING(trim(cpu_name), 1, CHARINDEX(' ', trim(cpu_name), CHARINDEX(' ', cpu_name)+1)+2)
				    ELSE cpu_name  
			    END;

SELECT Memory FROM laptopData

--add column to separete memory column
ALTER TABLE laptopData
ADD memory_type VARCHAR(255) NULL,
    primary_storage INTEGER NULL,
	secondary_storage VARCHAR(255) NULL;

--Update memory type
SELECT Memory,
       CASE
           WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
           WHEN Memory LIKE '%SSD%' THEN 'SSD'
           WHEN Memory LIKE '%HDD%' THEN 'HDD'
           WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
           WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
           WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
           ELSE NULL
       END AS 'memory_type'
FROM laptopData;

UPDATE laptopData
SET memory_type = CASE
                      WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
                      WHEN Memory LIKE '%SSD%' THEN 'SSD'
                      WHEN Memory LIKE '%HDD%' THEN 'HDD'
                      WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
                      WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
                      WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
                      ELSE NULL
                   END;

select * from laptopData
ALTER TABLE laptopData DROP COLUMN gpu_name;
ALTER TABLE laptopData DROP COLUMN primary_storage;
ALTER TABLE laptopData DROP COLUMN secondary_storage;