USE [SANDBOX]
GO
/****** Object:  StoredProcedure [ROSE\issacg].[USP_REHAB_IDENTIFYSPOTREPAIRSFASTER_10_old]    Script Date: 06/28/2011 16:34:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [ROSE\issacg].[USP_REHAB_IDENTIFYSPOTREPAIRSFASTER_10_old] AS
BEGIN

DECLARE @thisCompkey        int
DECLARE @iterativeYear      float
DECLARE @replaceYear        float
DECLARE @rValue             float
DECLARE @yearExponent       float
DECLARE @replaceSDev        float
DECLARE @interestValue      float
DECLARE @thisYear           float
DECLARE @ReplaceYear_Whole  float

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
BEGIN
Print '1'
DROP TABLE  REHAB_SmallResultsTable
END
BEGIN
Print '2'
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
	R2150_Seg float,
	yearInStdDev float
)
--Remember to make yearInStdDev a keyed field after calculating it
END
BEGIN
Print '3'
--first make a list of compkeys that contain 4/5 graded segments
--hansen query
INSERT INTO #CompkeyTable SELECT COMPKEY, 0 AS numSegments, Count(*) AS numBroke, 0 AS numFixed, 0 AS Fail_tot, MAX(Consequence_Failure) AS Consequence_Failure, MAX(Replacement_Cost) AS Replacement_Cost FROM  REHAB_RedundancyTable WHERE RATING >= 1 GROUP BY COMPKEY
END
BEGIN
Print '4'
UPDATE #CompkeyTable SET #CompkeyTable.numSegments = A.numSegments FROM #CompkeyTable INNER JOIN (SELECT COMPKEY, Count(*) AS numSegments FROM  REHAB_RedundancyTable GROUP BY COMPKEY) AS A ON #CompkeyTable.compkey = A.Compkey
END
BEGIN
Print '5'
UPDATE #CompkeyTable SET #CompkeyTable.numFixed = A.numFixed FROM #CompkeyTable INNER JOIN (SELECT COMPKEY, Count(*) AS numFixed FROM  REHAB_RedundancyTable WHERE Material like '2_%' GROUP BY COMPKEY) AS A ON #CompkeyTable.compkey = A.Compkey

UPDATE #CompkeyTable SET Fail_tot               = theCount   FROM #CompkeyTable INNER JOIN (SELECT COMPKEY, COUNT(*) AS theCOunt FROM  REHAB_RedundancyTable WHERE Total_Defect_Score >=1000 OR Material like '2_%' GROUP BY COMPKEY) AS A ON #CompkeyTable.COMPKEY = A.COMPKEY
END
BEGIN
Print '6'

UPDATE  REHAB_RedundancyTable SET Fail_YR_Seg = Failure_Year, Std_DEV_Seg = Std_Dev WHERE Failure_Year <> 0 AND Std_Dev <>0

--Update the standard deviation and failure years of pipes that are not in compkey table
UPDATE  REHAB_RedundancyTable SET  REHAB_RedundancyTable.Std_dev = STD, Failure_Year = RUF + 2008 
FROM  REHAB_RedundancyTable AS tabA 
INNER JOIN 
(SELECT tabB.Compkey, CASE WHEN Std_Dev_Calc < 1 THEN 1 ELSE Std_Dev_Calc END AS STD, ISNULL(RUL_Final, 0) AS RUF 
   FROM 
   (SELECT COMPKEY, RUL_Final, (RUL_Final*Std_dev_Coeff_RUL + ISNULL(Std_dev_Years_Insp,0) * ISNULL(Years_Since_Last_Inspect, 0))  AS Std_Dev_Calc 
       FROM  REHAB_Tbl_RULmla_ac INNER JOIN  REHAB_Rul_Std_dev on RUL_Source_Flag = RUL_Source_ID
    )AS tabB 
    WHERE tabB.Compkey NOT IN (SELECT COMPKEY FROM #COMPKEYTABLE)
)AS tabC ON TabC.Compkey = tabA.Compkey

UPDATE  REHAB_RedundancyTable SET  REHAB_RedundancyTable.RULife = RUF 
FROM  REHAB_RedundancyTable AS tabA 
INNER JOIN 
(SELECT tabB.Compkey, CASE WHEN Std_Dev_Calc < 1 THEN 1 ELSE Std_Dev_Calc END AS STD, ISNULL(RUL_Final, 0) AS RUF 
   FROM 
   (SELECT COMPKEY, RUL_Final, (RUL_Final*Std_dev_Coeff_RUL + ISNULL(Std_dev_Years_Insp,0) * ISNULL(Years_Since_Last_Inspect, 0))  AS Std_Dev_Calc 
       FROM  REHAB_Tbl_RULmla_ac INNER JOIN  REHAB_Rul_Std_dev on RUL_Source_Flag = RUL_Source_ID
    )AS tabB 
    WHERE tabB.Compkey NOT IN (SELECT COMPKEY FROM #COMPKEYTABLE)
)AS tabC ON TabC.Compkey = tabA.Compkey

--Set failure year for 'jellybeans' that have score >=1000 and Fail_tot for the whole pipe < 0.05 AND numBroke for the whole pipe>= 1
--If a 'jellybean' meets these requirements, then that whole pipe must be replaced now.
UPDATE  REHAB_RedundancyTable SET Failure_Year = 2050, RULife = 30, Std_Dev = 12 FROM  REHAB_RedundancyTable INNER JOIN #COMPKEYTABLE ON ( REHAB_RedundancyTable.Compkey = #CompkeyTable.Compkey AND ((#CompkeyTable.Fail_tot < 0.1 AND #CompkeyTable.numBroke >= 1) OR (#CompkeyTable.Fail_tot >= 0.1 AND #CompkeyTable.numBroke = 1)) AND ( REHAB_RedundancyTable.Insp_Curr = 1 OR  REHAB_RedundancyTable.Insp_Curr = 2) AND  REHAB_RedundancyTable.RATING >=4)
--If a pipe has an insp_curr of 3 (replaced after the last inspection) then the failure year of the pipe is 120 years from today.
UPDATE  REHAB_RedundancyTable SET Failure_Year = 120 + 2010, RULife = 120, Std_Dev = 12 where insp_curr = 3

UPDATE  REHAB_RedundancyTable SET  REHAB_RedundancyTable.RUL_Flag = RUL_Source_ID 
FROM  REHAB_RedundancyTable AS tabA 
INNER JOIN 
  REHAB_Tbl_RULmla_ac  ON tabA.COMPKEY =  REHAB_Tbl_RULmla_ac.COMPKEY
--Get the PIpes that need spot repairs
--SELECT Compkey, numBroke, Replacement_Cost, numBroke*Replacement_Cost AS RepairCost FROM #CompkeyTable WHERE (numFixed + numBroke)/numSegments < 0.1 AND numBroke >= 1
--Get the costs of those spot repairs
--SELECT SUM(RepairCost) FROM (SELECT Compkey, numBroke, Replacement_Cost, numBroke*Replacement_Cost AS RepairCost FROM #CompkeyTable AS B WHERE (numFixed + numBroke)/numSegments < 0.1 AND numBroke >= 1  ) AS A
END
BEGIN
Print '7'

DELETE FROM  REHAB_SmallResultsTable
END
BEGIN
Print '8'
--Do something that looks like the cost estimator to all of the PIpes
INSERT INTO  REHAB_SmallResultsTable (compkey,
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
	Fail_YR_Seg)

	SELECT compkey,
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
	Fail_YR_Seg FROM  REHAB_RedundancyTable
END
BEGIN
Print '9'
--update the failure Year on the Pipes with spot repairs to 40 years from now
--UPDATE  REHAB_SmallResultsTable SET Failure_Year = 2050 FROM  REHAB_SmallResultsTable INNER JOIN (SELECT Compkey, numBroke, Replacement_Cost, numBroke*Replacement_Cost AS RepairCost FROM #CompkeyTable AS B WHERE (numFixed + numBroke)/numSegments < 0.1 AND numBroke >= 1 ) AS A ON  REHAB_SmallResultsTable.Compkey = A.Compkey
END
BEGIN
Print '10'
SET @iterativeYear = 1950.00
SET @ReplaceYear = 2040.00
SET @ReplaceYear_Whole = 2130
SET @ReplaceSDev = 12.00
SET @interestValue = 1.025
SET @thisYear = 2010.00
UPDATE  REHAB_SmallResultsTable SET B2010 = 0
UPDATE  REHAB_SmallResultsTable SET R2010 = 0
UPDATE  REHAB_SmallResultsTable SET B2150 = 0
UPDATE  REHAB_SmallResultsTable SET R2150 = 0
END
--
--set the repair/mortality cost of segments to the area of the normal distribution
BEGIN
UPDATE  REHAB_SmallResultsTable SET B2010 = Consequence_Failure * A FROM  REHAB_SmallResultsTable INNER JOIN  REHAB_NormalDistribution  ON Z = CASE WHEN ROUND((@thisYear-Failure_Year)/Std_Dev,2) < -3 THEN -4
                                                                                                                               WHEN ROUND((@thisYear-Failure_Year)/Std_Dev,2) >  3 THEN  4
                                                                                                                               ELSE ROUND((@thisYear-Failure_Year)/Std_Dev,2) END  

UPDATE  REHAB_SmallResultsTable SET B2010_Seg = Consequence_Failure * A FROM  REHAB_SmallResultsTable INNER JOIN  REHAB_NormalDistribution  ON Z = CASE WHEN ROUND((@thisYear-Fail_YR_Seg)/Std_Dev_Seg,2) < -3 THEN -4
																																   WHEN ROUND((@thisYear-Fail_YR_Seg)/Std_Dev_Seg,2) >  3 THEN  4
                                                                                                                                   ELSE ROUND((@thisYear-Fail_YR_Seg)/Std_Dev_Seg,2) END  WHERE Std_Dev_Seg <> 0
                                                                                                                          
UPDATE  REHAB_SmallResultsTable SET R2010 = Replacement_Cost + Consequence_Failure * A FROM  REHAB_SmallResultsTable INNER JOIN  REHAB_NormalDistribution  ON Z = CASE WHEN ROUND((@thisYear-@ReplaceYear_Whole)/@ReplaceSDev,2) < -3 THEN -4
                                                                                                                                                  WHEN ROUND((@thisYear-@ReplaceYear_Whole)/@ReplaceSDev,2) >  3 THEN  4
                                                                                                                                                  ELSE ROUND((@thisYear-@ReplaceYear_Whole)/@ReplaceSDev,2) END 


UPDATE  REHAB_SmallResultsTable SET R2010_Seg = Replacement_Cost + Consequence_Failure * A FROM  REHAB_SmallResultsTable INNER JOIN  REHAB_NormalDistribution  ON Z = CASE WHEN ROUND((@thisYear-@ReplaceYear)/@ReplaceSDev,2) < -3 THEN -4
                                                                                                                                                  WHEN ROUND((@thisYear-@ReplaceYear)/@ReplaceSDev,2) >  3 THEN  4
                                                                                                                                                  ELSE ROUND((@thisYear-@ReplaceYear)/@ReplaceSDev,2) END 

END

--
SET @iterativeYear = 2011
WHILE @iterativeYear <= 2150
BEGIN
SET    @yearExponent = Power(@interestValue, @thisYear - @iterativeYear)
UPDATE  REHAB_SmallResultsTable SET B2150 = ISNULL(B2150, 0)+@yearExponent * Consequence_Failure * (ISNULL(P,0)/Std_Dev) FROM  REHAB_SmallResultsTable INNER JOIN  REHAB_NormalDistribution  ON Z = CASE WHEN ROUND((@iterativeYear-Failure_Year)/Std_Dev,2) < -3 THEN -4
                                                                                                                                                                                    WHEN ROUND((@iterativeYear-Failure_Year)/Std_Dev,2) >  3 THEN  4
                                                                                                                                                                                    ELSE ROUND((@iterativeYear-Failure_Year)/Std_Dev,2) END 
UPDATE  REHAB_SmallResultsTable SET B2150_Seg = ISNULL(B2150_Seg, 0)+@yearExponent * Consequence_Failure * (ISNULL(P,0)/Std_Dev_Seg) FROM  REHAB_SmallResultsTable INNER JOIN  REHAB_NormalDistribution  ON Z = CASE WHEN ROUND((@iterativeYear-Fail_YR_Seg)/Std_Dev_Seg,2) < -3 THEN -4
                                                                                                                                                                                    WHEN ROUND((@iterativeYear-Fail_YR_Seg)/Std_Dev_Seg,2) >  3 THEN  4
                                                                                                                                                                                    ELSE ROUND((@iterativeYear-Fail_YR_Seg)/Std_Dev_Seg,2) END 
																																													WHERE Std_Dev_Seg <> 0
UPDATE  REHAB_SmallResultsTable SET R2150 =	 ISNULL(R2150, 0)+@yearExponent * Consequence_Failure * (ISNULL(P,0)/@ReplaceSDev) FROM  REHAB_SmallResultsTable INNER JOIN  REHAB_NormalDistribution  ON Z = CASE WHEN ROUND((@iterativeYear-@ReplaceYear_Whole)/@ReplaceSDev,2) < -3 THEN -4
                                                                                                                                                                                         WHEN ROUND((@iterativeYear-@ReplaceYear_Whole)/@ReplaceSDev,2) >  3 THEN  4
                                                                                                                                                                                         ELSE ROUND((@iterativeYear-@ReplaceYear_Whole)/@ReplaceSDev,2) END 
UPDATE  REHAB_SmallResultsTable SET R2150_Seg = ISNULL(R2150_Seg, 0)+@yearExponent * Consequence_Failure * (ISNULL(P,0)/@ReplaceSDev) FROM  REHAB_SmallResultsTable INNER JOIN  REHAB_NormalDistribution  ON Z = CASE WHEN ROUND((@iterativeYear-@ReplaceYear)/@ReplaceSDev,2) < -3 THEN -4
                                                                                                                                                                                         WHEN ROUND((@iterativeYear-@ReplaceYear)/@ReplaceSDev,2) >  3 THEN  4
                                                                                                                                                                                         ELSE ROUND((@iterativeYear-@ReplaceYear)/@ReplaceSDev,2) END 
SET @iterativeYear = @iterativeYear+1
END

DROP TABLE #CompkeyTable

END

