-- Disneyland Review Data Cleaning & Exploration by Augusto Jonathan Lauw--------------------------------------------------------------------

SELECT * 
FROM ProjectSQL..Disneyland

-- First, let's determine each rating with a more spesific impression------------------------------------------------------------------------

SELECT Distinct(Rating), Count(Rating)
FROM ProjectSQL..Disneyland
GROUP BY Rating
ORDER BY 2

SELECT Rating,
CASE WHEN Rating= 1 THEN 'Very Bad'
		WHEN Rating=2 THEN 'Bad'
		WHEN Rating=3 THEN 'Normal'
		WHEN Rating=4 THEN 'Good'
		WHEN Rating=5 THEN 'Very Good'
		END
FROM ProjectSQL..Disneyland

ALTER TABLE Disneyland
ALTER COLUMN Rating NVARCHAR (100)

UPDATE Disneyland
SET Rating = CASE WHEN Rating= 1 THEN 'Very Bad'
		WHEN Rating=2 THEN 'Bad'
		WHEN Rating=3 THEN 'Normal'
		WHEN Rating=4 THEN 'Good'
		WHEN Rating=5 THEN 'Very Good'
		END

EXEC sp_help Disneyland

SELECT Rating
From ProjectSQL..Disneyland


-- Let's also change the Branch column-------------------------------------------------------------------------------------------------------
SELECT Distinct(Branch), Count(Branch)
FROM ProjectSQL..Disneyland
GROUP BY Branch
ORDER BY 2

SELECT Branch,
CASE WHEN Branch= 'Disneyland_HongKong' THEN 'Hong Kong'
		WHEN Branch= 'Disneyland_Paris' THEN 'Paris'
		WHEN Branch= 'Disneyland_California' THEN 'California'
		END
FROM ProjectSQL..Disneyland

ALTER TABLE Disneyland
ADD Disneyland_Branch NVARCHAR(100)

UPDATE Disneyland
SET Disneyland_Branch =CASE WHEN Branch= 'Disneyland_HongKong' THEN 'Hong Kong'
		WHEN Branch= 'Disneyland_Paris' THEN 'Paris'
		WHEN Branch= 'Disneyland_California' THEN 'California'
		END

-- Now, let's split the Year_Month column into 2 columns of Year and Month Name---------------------------------------------------------------

-- OPTION 1--

SELECT Year_Month
FROM ProjectSQL..Disneyland

SELECT
PARSENAME(REPLACE(Year_Month,'-','.'),1)
, PARSENAME(REPLACE(Year_Month,'-','.'),2)
FROM ProjectSQL..Disneyland

ALTER TABLE Disneyland
ADD Month NVARCHAR(10)

UPDATE Disneyland
SET Month=PARSENAME(REPLACE(Year_Month,'-','.'),1)

ALTER TABLE Disneyland
ADD Year NVARCHAR(10)

UPDATE Disneyland
SET Year=PARSENAME(REPLACE(Year_Month,'-','.'),2)

EXEC sp_help Disneyland

SELECT *,
CASE WHEN Month= '1' THEN 'January'
		WHEN Month='2' THEN 'February'
		WHEN Month='3' THEN 'March'
		WHEN Month='4' THEN 'April'
		WHEN Month='5' THEN 'May'
		WHEN Month='6' THEN 'June'
		WHEN Month='7' THEN 'July'
		WHEN Month='8' THEN 'August'
		WHEN Month='9' THEN 'September'
		WHEN Month='10' THEN 'October'
		WHEN Month='11' THEN 'November'
		WHEN Month='12' THEN 'December'
		END
FROM ProjectSQL..Disneyland


ALTER TABLE Disneyland
ALTER COLUMN Month NVARCHAR (100)

UPDATE Disneyland
SET Month = CASE WHEN Month= '1' THEN 'January'
		WHEN Month='2' THEN 'February'
		WHEN Month='3' THEN 'March'
		WHEN Month='4' THEN 'April'
		WHEN Month='5' THEN 'May'
		WHEN Month='6' THEN 'June'
		WHEN Month='7' THEN 'July'
		WHEN Month='8' THEN 'August'
		WHEN Month='9' THEN 'September'
		WHEN Month='10' THEN 'October'
		WHEN Month='11' THEN 'November'
		WHEN Month='12' THEN 'December'
		END

SELECT*
FROM ProjectSQL..Disneyland

-- OPTION 2--

SELECT
SUBSTRING (Year_Month,1, 
						CASE WHEN
						CHARINDEX('-',Year_Month) = 0 THEN LEN (Year_Month)
						ELSE CHARINDEX('-',Year_Month)-1 END) 
						as Year
, SUBSTRING (Year_Month, CHARINDEX('-',Year_Month)+1, LEN(Year_Month)) as Month
FROM ProjectSQL..Disneyland

-- Next, we are going to delete all the contradictive review text and rating which can be considered as garbage and bias data----------------

SELECT 
SUM (CASE WHEN Review_Text LIKE '%crowded%' THEN 1 ELSE 0 END) Crowded,
SUM (CASE WHEN Review_Text LIKE '%expensive%' THEN 1 ELSE 0 END) Expensive,
SUM (CASE WHEN Review_Text LIKE '%disappointed%' THEN 1 ELSE 0 END) Disappointed
FROM ProjectSQL..Disneyland
WHERE Rating='Very Good'

DELETE FROM ProjectSQL..Disneyland
WHERE (Review_Text LIKE '%crowded%' OR
		Review_Text LIKE '%expensive%' OR
		Review_Text LIKE '%disappointed%') 
		AND Rating = 'Very Good'

SELECT 
SUM (CASE WHEN Review_Text LIKE '%fantastic%' THEN 1 ELSE 0 END) Fantastic,
SUM (CASE WHEN Review_Text LIKE '%happy%' THEN 1 ELSE 0 END) Happy,
SUM (CASE WHEN Review_Text LIKE '%amazing%' THEN 1 ELSE 0 END) Amazing
FROM ProjectSQL..Disneyland
WHERE Rating='Very Bad'

DELETE FROM ProjectSQL..Disneyland
WHERE (Review_Text LIKE '%fantastic%' OR
		Review_Text LIKE '%happy%' OR
		Review_Text LIKE '%amazing%') 
		AND Rating = 'Very Bad'

-- And, we are going to delete some duplicate data based on the same review-------------------------------------------------------------------

WITH CTE  AS(
SELECT *,
		ROW_NUMBER() 
		OVER
		(
		PARTITION BY Review_Text
		ORDER BY Review_ID
		) duplicate
FROM ProjectSQL..Disneyland
-- ORDER BY Review_ID
)
DELETE
FROM CTE
WHERE duplicate >1

-- Finally, we are going to delete the unused column----------------------------------------------------------------------------------------

SELECT*
FROM ProjectSQL..Disneyland

ALTER TABLE ProjectSQL..Disneyland
DROP COLUMN Year_Month, Branch


-- Now, we good to go! Thank you!------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------