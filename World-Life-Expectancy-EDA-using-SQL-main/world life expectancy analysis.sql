# World Life Expectancy Project

# Selecting all records from the world_life_expectancy table
SELECT * 
FROM world_life_expectancy;

# Checked for duplicate entries by counting how many times each Country-Year combination appears
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

# Identifying duplicate records by assigning a row number to each Country-Year combination
SELECT *
FROM (
    SELECT Row_ID,
    CONCAT(Country, Year),
    ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
    FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1;

# Deleted duplicate records from the table identified using the querey above
DELETE FROM world_life_expectancy
WHERE 
    Row_ID IN (
        SELECT Row_ID
        FROM (
            SELECT Row_ID,
            CONCAT(Country, Year),
            ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
            FROM world_life_expectancy
        ) AS Row_table
        WHERE Row_Num > 1
    );

# Checked for records where the Status field is NULL
SELECT * 
FROM world_life_expectancy
WHERE Status IS NULL;

# To get a distinct list of Status values that are not empty
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> '';

# To get distinct countries that are labeled as 'Developing'
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing';

# Update the Status of countries that are still empty to 'Developing' if they are listed as such elsewhere
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

# Look at records for the United States of America to review its data
SELECT * 
FROM world_life_expectancy
WHERE Country = 'United States of America';

# Update the Status of countries that are still empty to 'Developed' based on other records
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

# Select records where Life expectancy is empty
SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = '';

# Identify records where Life expectancy is empty
SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
WHERE `Life expectancy` = '';

# Find neighboring years' life expectancy to fill in missing values
SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3. `Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';

# Update missing Life expectancy values using the average of the surrounding years
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3. `Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = '';

# Final check of the data after cleaning
SELECT *
FROM world_life_expectancy;

# Get minimum and maximum life expectancy for each country and calculate the increase over 15 years
SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years ASC;

# Calculate average life expectancy for each year
SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;

# Select all records again, for further analysis
SELECT * 
FROM world_life_expectancy;

# Calculate average life expectancy and GDP for each country
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC;

# Count and average life expectancy for countries based on GDP thresholds
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy;

# Select all records again for further checks
SELECT * 
FROM world_life_expectancy;

# Calculate average life expectancy grouped by status (Developed/Developing)
SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status;

# Count distinct countries and average life expectancy for each status
SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status;

# Calculate average life expectancy and BMI for each country
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI ASC;

# Calculate rolling total of adult mortality for all countries
SELECT Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy;
