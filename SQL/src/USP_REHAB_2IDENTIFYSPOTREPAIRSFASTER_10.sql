USE [SANDBOX]
GO

/****** Object:  StoredProcedure [ROSE\issacg].[USP_REHAB_2IDENTIFYSPOTREPAIRSFASTER_10]    Script Date: 07/21/2011 08:34:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ROSE\issacg].[USP_REHAB_2IDENTIFYSPOTREPAIRSFASTER_10] AS
BEGIN

------------------------------------------------------------------------------------------------
--Identify the temporary variables for this stored procedure
DECLARE @thisCompkey        int
DECLARE @iterativeYear      float
DECLARE @replaceYear        float
DECLARE @rValue             float
DECLARE @yearExponent       float
DECLARE @replaceSDev        float
DECLARE @interestValue      float
DECLARE @thisYear           float
DECLARE @ReplaceYear_Whole  float

----------------------------------------------------------------------------------------------
--The unit multiplier table is a way to speed up the query process. 
CREATE TABLE #UnitMultiplierTable
(
	failure_yr int,
	std_dev int,
	unit_multiplier float
)

----------------------------------------------------------------------------------------------
--We wont be considering years prior to 1975 as failure years.  It is very very unlikely
--That any failure year could be assumed to be before 1975.
SET @iterativeYear = 1975

----------------------------------------------------------------------------------------------
--Fill the unit multiplier table with the appropriate values.  We won't be considering
--contributions following the year 2250.  This is about 50 years beyond any appreciable
--contribution due to standard deviations.
WHILE @iterativeYear <= 2250
BEGIN
	--------------------------------------------------------------------------------------------
	--We will assume that the range of possible standard deviations is 1 to 50.  I'm fairly
	--certain the standard deviation doesn't go much higher than 24, but just in case.
	SET @replaceSDev = 1
	WHILE @replaceSDev <= 50
	BEGIN
		----------------------------------------------------------------------------------------
		--Fill the unitMultiplier table with the base data.
		INSERT INTO #UnitMultiplierTable 
		SELECT	@iterativeYear as failure_yr, 
				@replaceSDev as std_dev, 
				0 as unit_multiplier
		SET @replaceSDev = @replaceSDev + 1
	END
	SET @iterativeYear = @iterativeYear + 1
END

----------------------------------------------------------------------------------------------
--Prepare the temporary variables with the base data
SET @ReplaceYear = 2040.00
SET @ReplaceYear_Whole = 2130
SET @ReplaceSDev = 12.00
SET @interestValue = 1.025
SET @thisYear = 2010.00
SET @iterativeYear = 2011

----------------------------------------------------------------------------------------------
--This is the loop that fills the unitMultiplierTable with the actual Unit Multipliers
WHILE @iterativeYear <= 2250
BEGIN
	----------------------------------------------------------------------------------------------
	--Of course we need to temper our unit multipliers with the effects of inflation
	SET    @yearExponent = Power(@interestValue, @thisYear - @iterativeYear)
	----------------------------------------------------------------------------------------------
	UPDATE  #UnitMultiplierTable SET unit_multiplier = ISNULL(unit_multiplier, 0)+@yearExponent * [ROSE\issacg].NORMDIST(@iterativeYear,Failure_Yr ,Std_Dev,0)/std_dev
	---------------------------------------------------------------------------------------------- 
	SET @iterativeYear = @iterativeYear+1
END
	
----------------------------------------------------------------------------------------------
--CompkeyTable was originally intended to keep track of the
--Grade 4 and 5 pipes and the amount of damage they had
--sustained.  CompkeyTable now keeps track of all
--pipes with HANSEN grades of 1 or greater and total
--defect scores of 1000 or greater.  It is possible
--that this table is no longer necessary.
CREATE TABLE #CompkeyTable
(
	compkey int,
	numSegments float,
	numBroke float,
	numFixed float,
	Fail_tot float,
	Consequence_Failure float,
	Replacement_Cost float
)

----------------------------------------------------------------------------------------------
--Dropping tables is faster than deleting.
DROP TABLE  REHAB_SmallResultsTable

----------------------------------------------------------------------------------------------
--REHAB_SmallResultsTable is used for finding the future and present
--worth of the segments in question.  This could conceiveably be
--a temporary table, and the results could be used in this query
--set instead of the next query set.
CREATE TABLE  REHAB_SmallResultsTable
(
	compkey int,
	cutno int,
	fm int,
	[to] int,
	point_defect_score float,
	linear_defect_score float,
	total_defect_score float,
	Failure_Year int,
	Fail_Yr_Seg int,
	std_dev int,
	std_dev_Seg int,
	consequence_Failure int,
	replacement_cost int,
	R2010 float,
	R2150 float,
	B2010 float,
	B2150 float,
	B2010_Seg float,
	B2150_Seg float,
	R2010_Seg float,
	R2150_Seg float
)

----------------------------------------------------------------------------------------------
--first make a list of compkeys that contain hansen graded segments
--of 1 or greater and defect scores of 1000 or greater.
--hansen query
INSERT INTO #CompkeyTable 
	SELECT	COMPKEY, 
			0			AS numSegments, 
			Count(*)	AS numBroke, 
			0			AS numFixed, 
			0			AS Fail_tot, 
			MAX(Consequence_Failure)	AS Consequence_Failure, 
			MAX(Replacement_Cost)		AS Replacement_Cost 
	FROM  REHAB_RedundancyTable 
	WHERE RATING >= 1 and Total_Defect_Score >= 1000
	GROUP BY COMPKEY
	
----------------------------------------------------------------------------------------------
--The compkey table needs to know how many segments are in each pipe
--(rehabredundancytable contains only segments, so don't worry about
--the whole pipe being counted as a segment in this query).
UPDATE #CompkeyTable 
SET #CompkeyTable.numSegments = A.numSegments 
FROM #CompkeyTable INNER JOIN 
(	
	SELECT	COMPKEY, 
			Count(*) AS numSegments 
	FROM  REHAB_RedundancyTable 
	GROUP BY COMPKEY
) AS A 
ON #CompkeyTable.compkey = A.Compkey

----------------------------------------------------------------------------------------------
--Compkeytable needs to know how many segments we think have been fixed 
--or replaced
UPDATE #CompkeyTable 
SET #CompkeyTable.numFixed = A.numFixed 
FROM #CompkeyTable INNER JOIN 
(	
	SELECT	COMPKEY, 
			Count(*) AS numFixed 
	FROM  REHAB_RedundancyTable		
	WHERE Material like '2_%' 
	GROUP BY COMPKEY
) AS A 
ON #CompkeyTable.compkey = A.Compkey

----------------------------------------------------------------------------------------------
--Compkey table needs to know how many segments we think either
--have been replaced or still need to be replaced.
--This query is separate from the other two counting
--queries because we want to only count a segment that has
--already been replaced AND needs to be replaced again
--as just one segment.
UPDATE #CompkeyTable 
SET Fail_tot = theCount   
FROM	#CompkeyTable 
		INNER JOIN 
		(	
			SELECT	COMPKEY, 
					COUNT(*) AS theCOunt 
			FROM  REHAB_RedundancyTable 
			WHERE Total_Defect_Score >=1000 OR Material like '2_%' 
			GROUP BY COMPKEY
		) AS A 
ON #CompkeyTable.COMPKEY = A.COMPKEY

----------------------------------------------------------------------------------------------
--Move the std_dev and failure year to the segment columns, because the
--standard deviation and failure year are currently describing the
--state of the segments.
UPDATE	REHAB_RedundancyTable 
SET		Fail_YR_Seg = Failure_Year, 
		Std_DEV_Seg = Std_Dev 
WHERE	Failure_Year <> 0 
		AND Std_Dev <>0
		
----------------------------------------------------------------------------------------------
--Update the standard deviation and failure years of pipes that have no hansen grade
--using the data from the RULmla table.
--Many of these updates are likely to be negated by Joes request of 7/1/2011
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Std_dev = STD, 
		Failure_Year = RUF + 2008 
FROM	REHAB_RedundancyTable AS tabA 
		INNER JOIN 
		(	
			SELECT	tabB.Compkey, 
					CASE WHEN Std_Dev_Calc < 1 THEN 1 ELSE Std_Dev_Calc END AS STD, 
					ISNULL(RUL_Final, 0) AS RUF
			FROM 
			(	
				SELECT	COMPKEY, 
						RUL_Final, 
						(RUL_Final*Std_dev_Coeff_RUL + ISNULL(Std_dev_Years_Insp,0) * ISNULL(Years_Since_Last_Inspect, 0))  AS Std_Dev_Calc
				FROM	REHAB_Tbl_RULmla_ac 
						INNER JOIN  
						REHAB_Rul_Std_dev 
						ON	RUL_Source_Flag = RUL_Source_ID
			)AS tabB 
		)AS tabC 
ON TabC.Compkey = tabA.Compkey AND (tabA.RATING IS NULL OR tabA.RATING = 0)

----------------------------------------------------------------------------------------------
--Update the RULife value from the RULmla table
--Considering the new requests that demonstrate a clear lack of
--organization, this field should probably be expected to 
--have a few errors in it.  I think this field is a reading comprehension failure
--type field anyway, so it shouldn't be in this table, it should be in a view.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.RULife = RUF 
FROM	REHAB_RedundancyTable AS tabA 
		INNER JOIN 
		(
			SELECT	tabB.Compkey, 
					CASE WHEN Std_Dev_Calc < 1 THEN 1 ELSE Std_Dev_Calc END AS STD, 
					ISNULL(RUL_Final, 0) AS RUF
			FROM 
			(
				SELECT	COMPKEY, 
						RUL_Final, 
						(RUL_Final*Std_dev_Coeff_RUL + ISNULL(Std_dev_Years_Insp,0) * ISNULL(Years_Since_Last_Inspect, 0))  AS Std_Dev_Calc 
				FROM	REHAB_Tbl_RULmla_ac 
						INNER JOIN  
						REHAB_Rul_Std_dev 
						ON	RUL_Source_Flag = RUL_Source_ID
			)AS tabB 
		)AS tabC 
		ON TabC.Compkey = tabA.Compkey AND (tabA.RATING IS NULL OR tabA.RATING = 0)

----------------------------------------------------------------------------------------------
--Identify the action 1 pipes
--It is possible an action 1 pipe having a score of 1000 or greater
--could be reassigned later.  That has a low liklihood of happening to
--any one pipe, but should happen to at least several pipes during this procedure.
UPDATE  REHAB_RedundancyTable 
SET		[ACTION] = 1 
FROM	REHAB_RedundancyTable 
WHERE		REHAB_RedundancyTable.RATING = 3
			OR
			REHAB_RedundancyTable.RATING = 2
			OR
			REHAB_RedundancyTable.RATING = 1

----------------------------------------------------------------------------------------------
--Identify the action 2 pipes.
--These are pipes that should have the entire pipe replaced.
UPDATE  REHAB_RedundancyTable 
SET		[ACTION] = 2 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		#CompkeyTable 
		ON 
		( 
			REHAB_RedundancyTable.Compkey = #CompkeyTable.Compkey
			AND 
			(
				#CompkeyTable.Fail_tot/#CompkeyTable.numSegments >= 0.1 
				AND 
				#CompkeyTable.numBroke > 1
			) 
			AND 
			( 
				REHAB_RedundancyTable.Insp_Curr = 1 
				OR  
				REHAB_RedundancyTable.Insp_Curr = 2
			) 
			AND	REHAB_RedundancyTable.RATING >=4
		)
		
----------------------------------------------------------------------------------------------
--Identify the action 3 pipes.
--Action 3 pipes simply require a few spot repairs and the whole pipe
--should be replaced in 30 years if there are spot repairs that need to be done.
--I wonder if it is a good idea to limit spot repair pipes to those
--that have hansen grades of 4 or more.  There does exist ONE case as
--of 07-12-2011 that is grade_h5 of 3 and total defect score of 1002, 
--compkey 131818.
UPDATE	REHAB_RedundancyTable 
SET		[ACTION] = 3
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		#CompkeyTable
		ON 
		( 
			REHAB_RedundancyTable.Compkey = #CompkeyTable.Compkey 
			AND 
			(
				(
					#CompkeyTable.Fail_tot/#CompkeyTable.numSegments < 0.1 
					AND 
					#CompkeyTable.numBroke >= 1
				) 
				OR 
				(
					#CompkeyTable.Fail_tot/#CompkeyTable.numSegments >= 0.1 
					AND 
					#CompkeyTable.numBroke = 1
				)
			) 
			AND 
			( 
				REHAB_RedundancyTable.Insp_Curr = 1 
				OR  
				REHAB_RedundancyTable.Insp_Curr = 2
			) 
			AND  
			REHAB_RedundancyTable.RATING >=4
		)
		
----------------------------------------------------------------------------------------------	
--Action 4 pipes are pipes that have absolutely no broken segments but
--still have HANSEN ratings of 4 or greater.
UPDATE	REHAB_RedundancyTable 
SET		[ACTION] = 4
FROM	REHAB_RedundancyTable 
WHERE	Compkey NOT IN
		(
			SELECT	COMPKEY
			FROM	#CompkeyTable
			WHERE	#CompkeyTable.numBroke <> 0
		)
		AND  
		REHAB_RedundancyTable.RATING >=4
		
----------------------------------------------------------------------------------------------	
--The action flag 5 pipes are those pipes that exist in
--master links, but do not exist in HANSEN.
UPDATE	SANDBOX.GIS.REHAB10FTSEGS 
SET		[ACTION] = 5 
FROM	SANDBOX.GIS.REHAB10FTSEGS 
		INNER JOIN 
		REHAB_Flag5Table 
		ON SANDBOX.GIS.REHAB10FTSEGS.COMPKEY = REHAB_Flag5Table.COMPKEY

----------------------------------------------------------------------------------------------
--For cases where action = 0
UPDATE  REHAB_RedundancyTable 
SET		Std_Dev =	CASE	WHEN (0.2*RULife) < 5 
							THEN 5 
							ELSE 0.2*RULife 
					END, 
		[ACTION] =	0
WHERE	(
			Insp_Curr = 3 
			OR  
			Insp_Curr = 4
		)
		AND
		hservstat <> 'NEW'
		AND
		hservstat <> 'PEND'
		AND
		(
			2010 - YEAR(instdate) > 40
			OR
			instdate is null
		)
		
----------------------------------------------------------------------------------------------
--For cases where action = 9
UPDATE  REHAB_RedundancyTable 
SET		Std_Dev =	CASE	WHEN (0.1*Convert(INT,  REHAB_tblRemainingUsefulLifeLookup.YearsToFailure)) < 1 
							THEN 1 
							ELSE 0.1*Convert(INT,  REHAB_tblRemainingUsefulLifeLookup.YearsToFailure) 
					END, 
		[ACTION] =	9
FROM	REHAB_tblRemainingUsefulLifeLookup,  
		REHAB_RedundancyTable,  
		REHAB_tblPipeTypeRosetta
WHERE	REHAB_RedundancyTable.Material = REHAB_tblPipeTypeRosetta.[Hansen Material] 
		AND  
		REHAB_tblPipeTypeRosetta.[Useful Life Curve] = 
		REHAB_tblRemainingUsefulLifeLookup.Material
		AND
		REHAB_tblRemainingUsefulLifeLookup.AGE = 0
		AND
		(
			Insp_Curr = 3 
			OR  
			Insp_Curr = 4
		)
		AND
		hservstat <> 'NEW'
		AND
		hservstat <> 'PEND'
		AND
		2010 - YEAR(instdate) < 40
		AND
		instdate is not null

		
----------------------------------------------------------------------------------------------
--For cases where action = 10
--Service status = 'PEND'
UPDATE  REHAB_RedundancyTable 
SET		RULife = 120,
		Failure_year = 2010 + 120,
		Std_Dev =	12, 
		[ACTION] =	10 
FROM	REHAB_RedundancyTable  
WHERE	hservstat = 'PEND'
		
----------------------------------------------------------------------------------------------
--For cases where action = 11
--Service status = 'NEW'
UPDATE  REHAB_RedundancyTable 
SET		RULife = Convert(INT,  REHAB_tblRemainingUsefulLifeLookup.YearsToFailure),
		Std_Dev =	CASE	WHEN (0.1*Convert(INT,  REHAB_tblRemainingUsefulLifeLookup.YearsToFailure)) < 1 
							THEN 1 
							ELSE 0.1*Convert(INT,  REHAB_tblRemainingUsefulLifeLookup.YearsToFailure) 
					END, 
		[ACTION] =	11, 
		failure_year = 2010 + Convert(INT,  REHAB_tblRemainingUsefulLifeLookup.YearsToFailure)
FROM	REHAB_tblRemainingUsefulLifeLookup,  
		REHAB_RedundancyTable,  
		REHAB_tblPipeTypeRosetta
WHERE	REHAB_RedundancyTable.Material = REHAB_tblPipeTypeRosetta.[Hansen Material] 
		AND  
		REHAB_tblPipeTypeRosetta.[Useful Life Curve] = 
		REHAB_tblRemainingUsefulLifeLookup.Material
		AND
		REHAB_tblRemainingUsefulLifeLookup.AGE = 0
		AND 
		hservstat = 'NEW'
		
----------------------------------------------------------------------------------------------
--Those pipes that received their rul from rul_mla need to 
--show their source flag as well.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.RUL_Flag = RUL_Source_ID 
FROM	REHAB_RedundancyTable AS tabA 
		INNER JOIN 
		REHAB_Tbl_RULmla_ac  
		ON 
		tabA.COMPKEY = REHAB_Tbl_RULmla_ac.COMPKEY
WHERE	[ACTION] = 0
		AND
		hservstat <> 'PEND'

----------------------------------------------------------------------------------------------
--If a pipe has an insp_curr of 3 (replaced after the last inspection) 
--then the failure year of the pipe is 120 years from the install date.
--This rule reflects the fact that we expect new pipes to last 120
--years and have an std_dev of 12 years.  Arguing for one of these
--rules and against another had better include lots of evidence for
--that position. 
UPDATE	REHAB_RedundancyTable 
SET		Failure_Year = 120 + YEAR(instdate), 
		RULife = 120 + YEAR(instdate) - 2010, 
		Std_Dev = CASE	WHEN (120 + YEAR(instdate) - 2010)*0.1 < 1 
							THEN 1 
							ELSE (120 + YEAR(instdate) - 2010)*0.1 
					END,
		RUL_Flag = NULL 
where	insp_curr = 3

----------------------------------------------------------------------------------------------
--If a pipe has an hservstat of 'PEND' then the pipe is assumed to
--already have been scheduled for replacement or has been replaced 
UPDATE	REHAB_RedundancyTable 
SET		Failure_Year = 2130, 
		RULife = 120, 
		Std_Dev = 12,
		RUL_Flag = NULL 
where	hservstat = 'PEND'

----------------------------------------------------------------------------------------------
--Pipes that have 4 or more failed laterals and are action 3 or action 
--4 need to be replaced now.
--These pipes will be called action 6 or 7.  
--ACTION 6 sanitary
UPDATE  REHAB_RedundancyTable SET /*Failure_Year = 2010, RULife = 0, Std_Dev = 12,*/ [ACTION] = 6
	FROM  
			(
				(
					[HANSEN].[IMSV7].[INSMNFR] AS A 
					INNER JOIN 
					[SANDBOX].[ROSE\issacg].REHAB_CONVERSION AS B 
					ON	A.INSPKEY = B.INSPKEY 
						AND A.RATING >= 3.9 
						AND RATINGKEY = 1010
				) 
				INNER JOIN 
				REHAB_RedundancyTable AS C 
				ON B.COMPKEY = C.COMPKEY
			)
			INNER JOIN 
			#CompkeyTable ON  
			C.Compkey = #CompkeyTable.Compkey 
			AND 
			(
				(
					#CompkeyTable.Fail_tot/#CompkeyTable.numSegments < 0.1 
					AND 
					#CompkeyTable.numBroke >= 1
				) 
				OR 
				(
					#CompkeyTable.Fail_tot/#CompkeyTable.numSegments >= 0.1 
					AND 
					#CompkeyTable.numBroke = 1
				)
			) 
			AND 
			(
				 C.Insp_Curr = 1 
				 OR  
				 C.Insp_Curr = 2
			) 
			AND  
			C.RATING >=4
	
----------------------------------------------------------------------------------------------	 
--Action 6 Storm
UPDATE  REHAB_RedundancyTable SET /*Failure_Year = 2010, RULife = 0, Std_Dev = 12,*/ [ACTION] = 6
FROM 
		(
			(
				[HANSEN].[IMSV7].[INSTMNFR] AS A 
				INNER JOIN 
				[SANDBOX].[ROSE\issacg].REHAB_CONVERSION AS B 
				ON	A.INSPKEY = B.INSPKEY 
					AND A.RATING >= 3.9 
					AND RATINGKEY = 1005
			) 
			INNER JOIN 
			REHAB_RedundancyTable AS C 
			ON B.COMPKEY = C.COMPKEY
		)
		INNER JOIN 
		#CompkeyTable 
		ON  C.Compkey = #CompkeyTable.Compkey 
		AND 
		(
			(
				#CompkeyTable.Fail_tot/#CompkeyTable.numSegments < 0.1 
				AND 
				#CompkeyTable.numBroke >= 1
			) 
			OR 
			(
				#CompkeyTable.Fail_tot/#CompkeyTable.numSegments >= 0.1 
				AND 
				#CompkeyTable.numBroke = 1
			)
		) 
		AND 
		(
			C.Insp_Curr = 1 
			OR  
			C.Insp_Curr = 2
		) 
		AND  
		C.RATING >=4

/**********************************************/
UPDATE  REHAB_RedundancyTable SET MAT_FmTo = REHAB_RedundancyTable.Material FROM  REHAB_RedundancyTable INNER JOIN SANDBOX.GIS.REHAB10FTSEGS AS C ON  REHAB_RedundancyTable.MLinkID = C.MLinkID WHERE C.Material <>  REHAB_RedundancyTable.Material

--UPDATE segcount
UPDATE  REHAB_RedundancyTable SET seg_count = theCount FROM  REHAB_RedundancyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCount FROM  REHAB_RedundancyTable GROUP BY COMPKEY) AS B ON  REHAB_RedundancyTable.COMPKEY = B.COMPKEY WHERE B.COMPKEY <> 0

--UPDATE fail_near
UPDATE  REHAB_RedundancyTable SET Fail_near = theCount FROM  REHAB_RedundancyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCount FROM  REHAB_RedundancyTable WHERE Total_Defect_Score >= 1000 GROUP BY COMPKEY) AS A ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--UPDATE fail_prev
UPDATE  REHAB_RedundancyTable SET Fail_prev = theCount FROM  REHAB_RedundancyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCount FROM  REHAB_RedundancyTable WHERE Material like '2_%' GROUP BY COMPKEY) AS A ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--UPDATE fail_TOT
UPDATE  REHAB_RedundancyTable SET Fail_tot = theCount FROM  REHAB_RedundancyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCOunt FROM  REHAB_RedundancyTable WHERE Total_Defect_Score >=1000 OR Material like '2_%' GROUP BY COMPKEY) AS A ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--UPDATE fail_PCT
UPDATE  REHAB_RedundancyTable SET Fail_pct = CASE WHEN seg_count = 0 THEN 0 ELSE CAST(fail_tot AS FLOAT)/CAST(seg_count AS FLOAT)*100 END WHERE COMPKEY <> 0
/**************************************************/
----------------------------------------------------------------------------------------------
--Identify Action 7 sanitary pipes:
UPDATE  REHAB_RedundancyTable SET /*Failure_Year = 2010, RULife = 0, Std_Dev = 12,*/ [ACTION] = 7
FROM  
			([HANSEN].[IMSV7].[INSTMNFR] AS A INNER JOIN [SANDBOX].[ROSE\issacg].REHAB_CONVERSION AS B 
				ON A.INSPKEY = B.INSPKEY AND A.RATING >= 3.9 AND RATINGKEY = 1005
			) INNER JOIN REHAB_RedundancyTable AS C ON B.COMPKEY = C.COMPKEY
			AND

				 C.Fail_near = 0 
				AND
				(C.Insp_Curr = 1 OR  C.Insp_Curr = 2)
				AND
				C.RATING >=4

----------------------------------------------------------------------------------------------				
--Identify action 7 storm pipes
UPDATE  REHAB_RedundancyTable SET /*Failure_Year = 2010, RULife = 0, Std_Dev = 12,*/ [ACTION] = 7
	--SELECT C.COMPKEY, MAX(C.def_tot), MAX(C.fail_near), MAX(C.fail_tot)
	FROM  
			([HANSEN].[IMSV7].[INSMNFR] AS A INNER JOIN [SANDBOX].[ROSE\issacg].REHAB_CONVERSION AS B 
				ON A.INSPKEY = B.INSPKEY AND A.RATING >= 3.9 AND RATINGKEY = 1010
			) INNER JOIN REHAB_RedundancyTable AS C ON B.COMPKEY = C.COMPKEY
			AND

				 C.Fail_near = 0 
				AND
				 (C.Insp_Curr = 1 OR  C.Insp_Curr = 2)
				AND
				C.RATING >=4

			
/**********************************************/
UPDATE  REHAB_RedundancyTable SET MAT_FmTo = REHAB_RedundancyTable.Material FROM  REHAB_RedundancyTable INNER JOIN SANDBOX.GIS.REHAB10FTSEGS AS C ON  REHAB_RedundancyTable.MLinkID = C.MLinkID WHERE C.Material <>  REHAB_RedundancyTable.Material

--UPDATE segcount
UPDATE  REHAB_RedundancyTable SET seg_count = theCount FROM  REHAB_RedundancyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCount FROM  REHAB_RedundancyTable GROUP BY COMPKEY) AS B ON  REHAB_RedundancyTable.COMPKEY = B.COMPKEY WHERE B.COMPKEY <> 0

--UPDATE fail_near
UPDATE  REHAB_RedundancyTable SET Fail_near = theCount FROM  REHAB_RedundancyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCount FROM  REHAB_RedundancyTable WHERE Total_Defect_Score >= 1000 GROUP BY COMPKEY) AS A ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--UPDATE fail_prev
UPDATE  REHAB_RedundancyTable SET Fail_prev = theCount FROM  REHAB_RedundancyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCount FROM  REHAB_RedundancyTable WHERE Material like '2_%' GROUP BY COMPKEY) AS A ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--UPDATE fail_TOT
UPDATE  REHAB_RedundancyTable SET Fail_tot = theCount FROM  REHAB_RedundancyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCOunt FROM  REHAB_RedundancyTable WHERE Total_Defect_Score >=1000 OR Material like '2_%' GROUP BY COMPKEY) AS A ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--UPDATE fail_PCT
UPDATE  REHAB_RedundancyTable SET Fail_pct = CASE WHEN seg_count = 0 THEN 0 ELSE CAST(fail_tot AS FLOAT)/CAST(seg_count AS FLOAT)*100 END WHERE COMPKEY <> 0
/**************************************************/


----------------------------------------------------------------------------------------------
--Update all the action flags for the redundancytableWhole
--We do this because we don't want to identify segments, only
--whole pipes as flag 8.
UPDATE	REHAB_RedundancyTableWhole 
Set		REHAB_RedundancyTableWhole.[Action] = REHAB_RedundancyTable.[Action]
FROM	REHAB_RedundancyTableWhole 
		INNER JOIN 
		REHAB_RedundancyTable 
		ON 
		REHAB_RedundancyTableWhole.COMPKEY = REHAB_RedundancyTable.COMPKEY

----------------------------------------------------------------------------------------------
--Pipes that are between two action 2s, 6s, or 7s need to be replaced now.
--These pipes will be called action 8.
UPDATE	REHAB_RedundancyTable 
SET		/*REHAB_RedundancyTable.Std_dev = 12, 
		Failure_Year = 2010, 
		RULife = 0 ,*/ 
		[ACTION] = 8
FROM 
	(
		(
			REHAB_RedundancyTable AS A 
			INNER JOIN 
			REHAB_RedundancyTableWhole AS B 
			ON A.COMPKEY = B.COMPKEY
		) 
		INNER JOIN 
		REHAB_RedundancyTableWhole AS C 
		ON B.UsNode = C.DsNode 
		AND 
		(
			C.[Action] = 2 
			OR 
			C.[Action] = 6 
			OR 
			C.[Action] = 7
		) 
		AND 
		(
			B.[Action] <> 2 
			AND 
			B.[Action] <> 6 
			AND 
			B.[Action] <> 7
		)
	) 
	INNER JOIN 
	REHAB_RedundancyTableWhole AS D 
	ON B.DsNode = D.UsNode
	AND 
	(
		D.[Action] = 2 
		OR 
		D.[Action] = 6 
		OR 
		D.[Action] = 7
	)
	
----------------------------------------------------------------------------------------------
--Update all failure years prior to 2010 year to 2010
--NOTE: this limits the domain of the CBR input, and
--so limits the CBR values.
UPDATE	REHAB_RedundancyTable
SET		Failure_year = 2010
WHERE	Failure_year < 2010

----------------------------------------------------------------------------------------------
--Update all failure years for segments prior to 2010 year to 2010
--NOTE: this limits the domain of the CBR input, and
--so limits the CBR values.
UPDATE	REHAB_RedundancyTable
SET		Fail_YR_Seg = 2010
WHERE	Fail_YR_Seg < 2010

DELETE 
FROM	REHAB_SmallResultsTable

----------------------------------------------------------------------------------------------
--Do something that looks like the cost estimator to all of the Pipes
--REHAB_SmallResultsTable is used for finding the future and present
--worth of the segments in question.  This could conceiveably be
--a temporary table, and the results could be used in this query
--set instead of the next query set.
INSERT 
INTO	REHAB_SmallResultsTable 
		(
			compkey,
			cutno,
			fm,
			[to],
			point_defect_score,
			linear_defect_score,
			total_defect_score,
			Failure_Year,
			std_dev,
			consequence_Failure,
			replacement_cost,
			Std_Dev_Seg,
			Fail_YR_Seg,
			B2010,
			R2010,
			B2150,
			R2150
		)
SELECT	compkey,
		cutno,
		fm,
		[to],
		point_defect_score,
		linear_defect_score,
		total_defect_score,
		Failure_Year,
		std_dev,
		consequence_Failure,
		replacement_cost ,
		Std_Dev_Seg,
		Fail_YR_Seg,
		0,
		0,
		0,
		0
FROM	REHAB_RedundancyTable

----------------------------------------------------------------------------------------------
--The variables for this process are initialized here
--ReplaceYear is for spot repair elements
SET @ReplaceYear = 2040.00
--ReplaceYearWhole is for pipes that need a whole pipe replacement now.
SET @ReplaceYear_Whole = 2130
--ReplaceSDev is the standard deviation of replaced elements
SET @ReplaceSDev = 12.00
--InterestValue is the discount rate applied over time for costs associated with an element
SET @interestValue = 1.025
--ThisYear is assumed to be 2010.
SET @thisYear = 2010.00

----------------------------------------------------------------------------------------------
--set the repair/mortality cost of segments to the area of the normal distribution
--considering that the whole pipe may need to be replaced
UPDATE  REHAB_SmallResultsTable 
SET		B2010 = Consequence_Failure * A 
FROM	REHAB_SmallResultsTable 
		INNER JOIN  
		REHAB_NormalDistribution  
		ON Z = CASE WHEN ROUND((@thisYear-Failure_Year)/Std_Dev,2) < -3 THEN -4
                    WHEN ROUND((@thisYear-Failure_Year)/Std_Dev,2) >  3 THEN  4
                    ELSE ROUND((@thisYear-Failure_Year)/Std_Dev,2) 
               END  
               
----------------------------------------------------------------------------------------------
--Set the repair/mortality cost of segments to the area of the normal distribution
--considering that the segment may need to be replaced
UPDATE  REHAB_SmallResultsTable 
SET		B2010_Seg = Consequence_Failure * A 
FROM	REHAB_SmallResultsTable 
		INNER JOIN  
		REHAB_NormalDistribution  
		ON Z = CASE WHEN ROUND((@thisYear-Fail_YR_Seg)/Std_Dev_Seg,2) < -3 THEN -4
					WHEN ROUND((@thisYear-Fail_YR_Seg)/Std_Dev_Seg,2) >  3 THEN  4
                    ELSE ROUND((@thisYear-Fail_YR_Seg)/Std_Dev_Seg,2) 
               END  
WHERE	Std_Dev_Seg <> 0

----------------------------------------------------------------------------------------------                                                                                                                          
--Set the repair/mortality cost of segments to the area of the normal distribution
--considering that the whole pipe has been replaced and will
--need to be replaced again in 120 years.
UPDATE  REHAB_SmallResultsTable 
SET		R2010 = Replacement_Cost + Consequence_Failure * A 
FROM	REHAB_SmallResultsTable 
		INNER JOIN  
		REHAB_NormalDistribution  
		ON Z = CASE WHEN ROUND((@thisYear-@ReplaceYear_Whole)/@ReplaceSDev,2) < -3 THEN -4
                    WHEN ROUND((@thisYear-@ReplaceYear_Whole)/@ReplaceSDev,2) >  3 THEN  4
                    ELSE ROUND((@thisYear-@ReplaceYear_Whole)/@ReplaceSDev,2) 
			   END 

----------------------------------------------------------------------------------------------
--Set the repair/mortality cost of segments to the area of the normal distribution
--considering that the segment has been replaced and the whole pipe will need
--to be replaced again in 30 years
UPDATE  REHAB_SmallResultsTable 
SET		R2010_Seg = Replacement_Cost + Consequence_Failure * A 
FROM	REHAB_SmallResultsTable 
		INNER JOIN  
		REHAB_NormalDistribution  
		ON Z = CASE WHEN ROUND((@thisYear-@ReplaceYear)/@ReplaceSDev,2) < -3 THEN -4
                    WHEN ROUND((@thisYear-@ReplaceYear)/@ReplaceSDev,2) >  3 THEN  4
                    ELSE ROUND((@thisYear-@ReplaceYear)/@ReplaceSDev,2) 
               END 

----------------------------------------------------------------------------------------------
--Use the unitmultipliertable to quickly find the value of
--replacing a whole pipe now
UPDATE  REHAB_SmallResultsTable 
SET		B2150 = Consequence_Failure * unit_multiplier 
FROM	REHAB_SmallResultsTable 
		INNER JOIN  
		#UnitMultiplierTable 
		ON	REHAB_SmallResultsTable.Std_Dev = #UnitMultiplierTable.std_dev 
			AND 
			Failure_Year = failure_yr
			
----------------------------------------------------------------------------------------------
--Use the unitmultipliertable to quickly find the value of
--replacing a segment now
UPDATE  REHAB_SmallResultsTable 
SET		B2150_Seg = Consequence_Failure * unit_multiplier 
FROM	REHAB_SmallResultsTable 
		INNER JOIN  
		#UnitMultiplierTable  
		ON	REHAB_SmallResultsTable.Std_Dev_seg = #UnitMultiplierTable.std_dev 
			AND 
			Fail_yr_seg = failure_yr
			
----------------------------------------------------------------------------------------------			
--Use the unitmultipliertable to quickly find the value of
--replacing a whole pipe again after its initial replacement
UPDATE	REHAB_SmallResultsTable 
SET		R2150 =	Consequence_Failure * unit_multiplier 
FROM	REHAB_SmallResultsTable 
		INNER JOIN  
		#UnitMultiplierTable  
		ON	@ReplaceSDev = #UnitMultiplierTable.std_dev 
			AND 
			@ReplaceYear_Whole = failure_yr 
			
----------------------------------------------------------------------------------------------
--Use the unitmultipliertable to quickly find the value of
--replacing a whole pipe again after its initial patch job.
UPDATE  REHAB_SmallResultsTable 
SET		R2150_Seg = Consequence_Failure * unit_multiplier 
FROM	REHAB_SmallResultsTable 
		INNER JOIN  
		#UnitMultiplierTable 
		ON	@ReplaceSDev = #UnitMultiplierTable.std_dev 
			AND 
			@ReplaceYear = failure_yr 
			
----------------------------------------------------------------------------------------------
DROP TABLE #CompkeyTable

END
GO

