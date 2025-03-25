-- Data Cleaning Project

-- Creating another table for working on it
CREATE TABLE layoffs_working
LIKE layoffs;

SELECT *
FROM layoffs_working;

-- Inserting values
INSERT layoffs_working
SELECT *
FROM layoffs;

-- 1. Remove duplicates
-- 1.1 Looking for duplicates

SELECT *
FROM layoffs_working;

SELECT company, industry, total_laid_off,`date`,
ROW_NUMBER() OVER (
	PARTITION BY company, industry, total_laid_off,`date`) AS row_num
FROM layoffs_working;

SELECT *
FROM (
SELECT company, industry, total_laid_off,`date`,
	ROW_NUMBER() OVER (
	PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM layoffs_working
) duplicates
WHERE row_num > 1; # row_num > 1 = duplicates

-- Need to check with 1 column to confirm (Oda)
SELECT *
FROM layoffs_working
WHERE company = 'Oda';
-- We can see that these are not duplicates because country and funds raised are different so can't delete them

-- les't try another exemple
SELECT *
FROM layoffs_working
WHERE company = 'Terminus';
-- Again these are not duplicates because funds raise and stage are different.

-- Let's try another way using subquerie with FROM
SELECT *
FROM (
SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
ROW_NUMBER() OVER (
	PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_working
) duplicates
WHERE row_num > 1;

-- let's check if those are real duplicates or not with CASPER and CAZOO
SELECT *
FROM layoffs_working
WHERE company = 'Casper';

SELECT *
FROM layoffs_working
WHERE company = 'Cazoo';
-- Those are real duplicates because date, percentages ect are identical = need to delete them

-- Another way to write subquerie with From is using CTEs
WITH dup_layoffs AS
(
SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
ROW_NUMBER() OVER (
	PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_working
)
SELECT *
FROM dup_layoffs
WHERE row_num > 1; # As we can see the result is the same

-- let's try to delete these duplicates with DELETE statement
WITH dup_layoffs AS
(
SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
ROW_NUMBER() OVER (
	PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_working
)
DELETE
FROM dup_layoffs
WHERE row_num > 1;
-- Can't do it with DELETE statement because it's considered as an update function

-- To delete these dup = can try to create another copi of layoffs_working and add a new column for row number
CREATE TABLE `layoffs_working2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_working2;

-- Now let's insert out values into our new table

INSERT INTO layoffs_working2
SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
ROW_NUMBER() OVER (
	PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_working;

-- Now let's filter by duplicates
SELECT *
FROM layoffs_working2
WHERE row_num > 1;

-- Now let's delete these duplicates
DELETE
FROM layoffs_working2
WHERE row_num > 1;

-- let's check now
SELECT *
FROM layoffs_working2;

-- 2. Standarize the data = finding all ype of issues and fixing them

-- Deleting uncessery space
SELECT  company, TRIM(company)
FROM layoffs_working2;

-- Upadating column correcting
UPDATE layoffs_working2
SET company = TRIM(company);

-- Let's check Industry column
SELECT  DISTINCT industry
FROM layoffs_working2
ORDER BY industry; 
# We can see that there's blanc and null values and also some same field but titled differently

-- Let's correct the issue with titled field
SELECT *
FROM layoffs_working2
WHERE industry LIKE 'Crypto%';

-- Update crypto industry in only title
UPDATE layoffs_working2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Lets check location
SELECT  DISTINCT location
FROM layoffs_working2
ORDER BY 1; 

-- Lets check country
SELECT  DISTINCT country
FROM layoffs_working2
ORDER BY 1; 

-- We can see that US in country column is written differently so let's modify it
UPDATE layoffs_working2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT DISTINCT country
FROM layoffs_working2
WHERE country LIKE 'United States%';

-- Let's chage the datatype of date column: text > date
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') AS date_format
FROM layoffs_working2;
-- Used STR_TO_DATE to transform string(text) to date, 2 parameter (column, format)

UPDATE layoffs_working2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Now we can change it to date column
ALTER TABLE layoffs_working2
MODIFY COLUMN `date` DATE;

-- 3. Look at NULL values and blanck values
SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_working2
WHERE industry IS NULL
OR industry = '';
-- Here is few rows with null and blanc value in industry column

-- We can check if thoses company are populated elsewhere so we can update them (ex: Airbnb = travel)
SELECT *
FROM layoffs_working2
WHERE company = 'Airbnb';
-- Airbnb is populated as "travel"

-- let's see at first thoses woh are blanck and not blanck to find their populated data
SELECT *
FROM layoffs_working2 AS tb1
JOIN layoffs_working2 AS tb2
	ON tb1.company = tb2.company
WHERE (tb1.industry IS NULL OR tb1.industry = '')
AND tb2.industry IS NOT NULL;

SELECT tb1.industry , tb2.industry
FROM layoffs_working2 AS tb1
JOIN layoffs_working2 AS tb2
	ON tb1.company = tb2.company
WHERE (tb1.industry IS NULL OR tb1.industry = '')
AND tb2.industry IS NOT NULL;

-- let's try to transforme blanc value by Null value first
UPDATE layoffs_working2
SET industry = NULL
WHERE industry = '';

-- Now we can update with the same value for the rest
UPDATE layoffs_working2 AS tb1
JOIN layoffs_working2 AS tb2
	ON tb1.company = tb2.company
SET tb1.industry = tb2.industry
WHERE tb1.industry IS NULL 
AND tb2.industry IS NOT NULL;

-- But 1 company "Bally's Interactive" still has null value in industry
SELECT *
FROM layoffs_working2
WHERE company Like 'Bally%';
-- But we can change it bc there is no other populated data for this one

-- 4. Remove any irrelevent columns 
SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- We can delete thoses data because they are both no giving any important info and not useful bc no values
DELETE
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- We can also delete row_num bc we don't need it anymore
ALTER TABLE layoffs_working2
DROP COLUMN row_num; 

SELECT *
FROM layoffs_working2;

-- END OF DATA CLEANING










