-- 1. Cleaned record count            -> output: 1995
SELECT COUNT(*) AS cleaned_rows
FROM layoffs_staging2;

-- 2. Total layoffs                   -> output: 383659
SELECT SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2;

-- 3. Duplicates removed              -> output: 5 (raw 2361 -> 2356 after dedupe)
SELECT COUNT(*) AS raw_rows
FROM layoffs;

-- 4. Largest single layoff           -> output: 12000 (and 1 for max percentage)
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- 5. Companies that shut down        -> output: 116
SELECT COUNT(*) AS shutdown_companies
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- 5b. Largest closure by headcount   -> output: Katerra (2434)
SELECT company, total_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
LIMIT 3;

-- 5c. Most funding among closures    ->  Britishvolt (2400), Quibi (1800), Deliveroo Australia (1700)
SELECT company, funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
LIMIT 3;

-- 6. Top 5 companies overall         -> Amazon 18150, Google 12000, Meta 11000, Salesforce 10090, Microsoft 10000
SELECT company, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY company
ORDER BY total DESC
LIMIT 5;

-- 7. Top 5 industries                -> Consumer 45182, Retail 43613, Other 36289, Transportation 33748, Finance 28344
SELECT industry, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY industry
ORDER BY total DESC
LIMIT 5;

-- 8. Top 3 countries + US share      -> United States 256559 (~67%), India 35993, Netherlands 17220
SELECT country,
       SUM(total_laid_off) AS total,
       ROUND(100 * SUM(total_laid_off) / (SELECT SUM(total_laid_off) FROM layoffs_staging2), 1) AS pct_of_total
FROM layoffs_staging2
GROUP BY country
ORDER BY total DESC
LIMIT 3;

-- 9. Funding stage + Post-IPO share  -> Post-IPO 204132 (~53%)
SELECT stage,
       SUM(total_laid_off) AS total,
       ROUND(100 * SUM(total_laid_off) / (SELECT SUM(total_laid_off) FROM layoffs_staging2), 1) AS pct_of_total
FROM layoffs_staging2
GROUP BY stage
ORDER BY total DESC
LIMIT 3;

-- 10. Layoffs by year                -> 2020: 80998 | 2021: 15823 | 2022: 160661 | 2023: 125677
SELECT YEAR(`date`) AS yr, SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY yr;

-- 11. Peak months                    -> 2023-01: 84714 | 2022-11: 53451 | 2023-02: 36493
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `MONTH`
ORDER BY total DESC
LIMIT 3;

-- 12. Top 5 companies per year       -> 2020 Uber 7525 | 2021 Bytedance 3600 | 2022 Meta 11000 | 2023 Google 12000
WITH Company_Year AS
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
ORDER BY years, Ranking;
















