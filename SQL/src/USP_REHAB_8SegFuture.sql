USE [SANDBOX]
GO

/****** Object:  StoredProcedure [ROSE\issacg].[USP_REHAB_8SegFuture]    Script Date: 07/21/2011 08:24:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [ROSE\issacg].[USP_REHAB_8SegFuture]  --(@Compkey int)
AS
BEGIN

DECLARE @thisCompkey        int
DECLARE @iterativeYear      float
DECLARE @replaceYear        float
DECLARE @rValue             float
DECLARE @yearExponent       float
DECLARE @replaceSDev        float
DECLARE @thisYear			float
DECLARE @ReplaceYear_Whole  float
DECLARE @iterativeColumn	int
DECLARE @SQL				nchar(4000)
--
DELETE FROM REHAB_SegFuture
--
SET @ReplaceYear = 2040.00
SET @ReplaceYear_Whole = 2130
SET @ReplaceSDev = 12.00
SET @thisYear = 2010.00

DECLARE @columnName			nchar(6)
DECLARE @interestValue      float

SET @thisYear = 2010.00
SET @iterativeYear = 2010
SET @iterativeColumn = 14

WHILE @iterativeYear <= 2130
BEGIN
--
	INSERT 
	INTO	REHAB_SegFuture 
	SELECT	COMPKEY, 
			MLinkID, 
			Std_dev_seg, 
			Fail_Yr_seg, 
			cof, 
			@iterativeYear, 
			cof * [ROSE\issacg].NORMDIST(convert(numeric(12,2),@iterativeYear), Fail_Yr_seg , Std_dev_seg,1)
	FROM	[SANDBOX].[GIS].[REHAB10FTSEGS] 
	WHERE	MLINKID >= 40000000 
			AND REMARKS = 'BES' 
			AND ReplaceCost <> 0 
			AND Std_dev_seg <> 0
			AND Fail_yr_seg <> 0
			AND replaceCost <> 0
			AND cof <> 0

SET @iterativeYear = @iterativeYear + 1
--
END

--------------------------------------------------------------------------------------------
--Get the accumulated risk inspect year
UPDATE	X 
SET		X.ACCUM_RISK_INSPECT_YEAR = C.ACCUM_RISK_INSPECT_YEAR
FROM
(
	SELECT	X.COMPKEY, 
			MIN(Year) AS ACCUM_RISK_INSPECT_YEAR 
	FROM	[SANDBOX].[GIS].[REHAB10FTSEGS] AS X
			INNER JOIN
			(	
				--Get the sum of the bpw for each pipe for each year
				SELECT	Compkey, 
						Year, 
						SUM(bpw) AS BPW 
				FROM	REHAB_SegFuture 
				GROUP BY COMPKEY, YEAR
			) AS A 
			ON	X.COMPKEY = A.COMPKEY 
			AND 
			MLinkID < 40000000 
			AND 
			--The inspect year is when the sum of the base present
			--worth is greater than the length of the pipe times
			--these arbitrary numbers.
			A.BPW > CASE	WHEN DiamWidth <= 36 
							THEN [Length] * 1.5 
							ELSE [Length] * 5 
					END 
	GROUP BY X.COMPKEY 
)		AS C 
		INNER JOIN 
		[SANDBOX].[GIS].[REHAB10FTSEGS] AS X
		ON	C.COMPKEY = X.COMPKEY 
			AND 
			MLinkID < 40000000

----------------------------------------------------------------------------------------------
--Get the accumulated risk replace year
UPDATE	X 
SET		X.ACCUM_RISK_REPLACE_YEAR = C.ACCUM_RISK_REPLACE_YEAR
FROM
(
	SELECT	X.COMPKEY, 
			--The lowest year that has a bpw higher than the replace
			--cost is the accumulated risk replace year.
			MIN([Year]) AS ACCUM_RISK_REPLACE_YEAR 
	FROM	[SANDBOX].[GIS].[REHAB10FTSEGS] AS X
			INNER JOIN
			(
				--Get the sum of the bpw for each pipe for each year
				SELECT	Compkey, 
						[Year], 
						SUM(bpw) AS BPW 
				FROM REHAB_SegFuture 
				GROUP BY	COMPKEY, 
							[YEAR]
			) AS A 
			ON	X.COMPKEY = A.COMPKEY 
				AND
				MLinkID < 40000000 
				AND
				--when the base present worth is greater than the
				--cost to replace a pipe, that is the replace year.
				--Get all of the years that have a bpw greater than
				--the replace cost.
				A.BPW > Replacecost
	GROUP BY X.COMPKEY
)		AS C 
		INNER JOIN 
		[SANDBOX].[GIS].[REHAB10FTSEGS] AS X
		ON	C.COMPKEY = X.COMPKEY 
			AND 
			MLinkID <40000000


END
GO

