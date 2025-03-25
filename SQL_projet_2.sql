-- Exploratory Data Analysis

-- We're just going to look around and see if can find anything interesting pattern by digging as much we can into our dataset
SELECT *
FROM p1_data_cl.layoffs_working2;

-- Stating with simple queries

SELECT MAX(total_laid_off)
FROM layoffs_working2;
-- There's a lot of people laid off in one day

-- Can check the percentage to have a better idea
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_working2;
-- 1 means 100% of the company was laid off but it's not realistic

-- We can filter them to have a better look of these compnies
SELECT *
FROM layoffs_working2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- We can see the largest laid off company is Katerra et the following

SELECT company, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company
ORDER BY 2 DESC;
-- Here we can observe that the big company like Amazon, Google or Meta are the one who laid off the most

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_working2;
-- Here we can observe when thos laid off started in 2020 and the last recent in 2023

SELECT industry, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY industry
ORDER BY 2 DESC;
-- Here we can observe the industry that was the most affected by thos laid off

SELECT country, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY country
ORDER BY 2 DESC;
-- Here we can observe the country where there's was the most laid off

SELECT `date`, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY `date`
ORDER BY 1 DESC;
-- Here we can observe number of people who was laid off by date

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- Here we can observe that in the starting of 2023 they're already a lot of people who was laid off and the year is 
-- not finish yet

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_working2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
-- Here we can observe sum of total laid off all around the world on every month of each year = doing to use it 
-- to create a total rolling sum to observe the progression of laid off in time

WITH Rolling_sum AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS tt_laid_off
FROM layoffs_working2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, tt_laid_off,
SUM(tt_laid_off) OVER(ORDER BY `MONTH`) AS tt_rolling_sum
FROM Rolling_sum;
-- Total Rolling sum on every month of each year, useful to compare in year
-- We can observe that between 2022-11 to 2023-03 = enormous number of laid off

-- Now we are going to have a look to company layying off per year 
SELECT company, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, `date`,SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company, `date`;
-- here it's show company's lay off by exact date, we don't want that

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;
-- Now we can see every company's total lays off per each year

-- We are going to rank wich year company laid off the most employees
WITH Company_year(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking 
FROM Company_year -- There's some null values in Years so we're going to filter with WHERE clause
WHERE years IS NOT NULL
) -- Here we want to filter our ranking to have a better understanding
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;
-- With this CTE's we can explore the ranking pisition of the company wich laid off the most employees each year between 2020 to 2023






