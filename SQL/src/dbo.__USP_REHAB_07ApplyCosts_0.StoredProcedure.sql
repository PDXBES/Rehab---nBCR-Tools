USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[__USP_REHAB_07ApplyCosts_0]    Script Date: 03/23/2016 14:10:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[__USP_REHAB_07ApplyCosts_0] @recreateLookupTables INT = 0, @AsOfDate datetime = null
AS
BEGIN

IF @AsOfDate IS NULL
   SET @AsOfDate = GETDATE()

------------------------------------------------------------------------------------------------
--Identify the temporary variables for this stored procedure
DECLARE @ENR FLOAT = 1.7375
DECLARE @EmergencyRepairFactor FLOAT = 1.4
DECLARE @COSTESTIMATOR_FLAG_WHOLEPIPE NVARCHAR(255) = 'W'
DECLARE @COSTESTIMATOR_FLAG_LINER NVARCHAR(255) = 'L'
DECLARE @COSTESTIMATOR_FLAG_SPOTREPAIR NVARCHAR(255) = 'S'
DECLARE @CostOfLaterals INT

SELECT @CostOfLaterals = EMLateralRepairCost FROM Constants

DECLARE @thisCompkey        int
DECLARE @iterativeYear      float
DECLARE @replaceYear        float
DECLARE @rValue             float
DECLARE @yearExponent       float
DECLARE @replaceSDev        float
DECLARE @thisYear           float
DECLARE @ReplaceYear_Whole  FLOAT
DECLARE @ReplaceYear_Liner  FLOAT



-----------------------------------------------------
--OBSEVKEY CODES
DECLARE @OBSEVKEY01 INT 
DECLARE @OBSEVKEY02 INT
DECLARE @OBSEVKEY03 INT
DECLARE @OBSEVKEY04 INT
DECLARE @OBSEVKEY05 INT
DECLARE @OBSEVKEY06 INT
DECLARE @OBSEVKEY07 INT
DECLARE @OBSEVKEY08 INT
DECLARE @OBSEVKEY09 INT
DECLARE @OBSEVKEY10 INT
DECLARE @OBSEVKEY11 INT
DECLARE @OBSEVKEY12 INT
DECLARE @OBSEVKEY13 INT
DECLARE @OBSEVKEY14 INT
DECLARE @OBSEVKEY15 INT

DECLARE @MaxStandardDeviation INT = 50
DECLARE @CountOfYearsToPlanFor INT = 240
DECLARE @SegmentReplacementRUL INT = 30
DECLARE @PipeReplacementRUL INT = 120
DECLARE @ReplacementStandardDeviation FLOAT = 12
DECLARE @SimulationStartYear INT = 1975
DECLARE @interestValue FLOAT = 1.025
DECLARE @Grade4MinimumScore INT = 1000
DECLARE @ReplacingMaterialPrefixSEARCH NVARCHAR(255) = '2_%'
DECLARE @MininumFractionOfFailedSegmentsBeforeWholePipeReplacement FLOAT = 0.1

DECLARE @HSERVSTAT_NEW NVARCHAR(255) = 'NEW'
DECLARE @HSERVSTAT_PEND NVARCHAR(255) = 'PEND'

DECLARE @InspectionFlag_InspectionDateIsNotNullAndInstallDateIsLessThanInspectionDateOrNull INT = 1
DECLARE @InspectionFlag_InstallDateIsNullAndServstatIsTBABOrABAN INT = 2
DECLARE @InspectionFlag_InstallDateIsAfterLastInspection INT = 3
DECLARE @InspectionFlag_InspectionDateIsNULL INT = 4

DECLARE @ActionFlag_PipeInProcessOfReplacement INT = 0
DECLARE @ActionFlag_DoNothing INT = 1 
DECLARE @ActionFlag_ReplaceWholePipe INT = 2
DECLARE @ActionFlag_SpotRepair INT = 3
DECLARE @ActionFlag_WatchMe INT = 4
DECLARE @ActionFlag_PipeRecentlyReplaced INT = 9
--DECLARE @ActionFlag_ServStatIsPEND INT = 10
DECLARE @ActionFlag_ServStatIsNEW INT = 11
DECLARE @ActionFlag_NonSpotRepairOnPipeWithSpotRepair INT = 12

DECLARE @RUL_General FLOAT = 120
DECLARE @RUL_SpotRepair FLOAT = 30
DECLARE @RUL_Liner FLOAT = 60
DECLARE @StandardDeviation_General FLOAT = 12

DECLARE @StandardDeviationFactor_High FLOAT = 0.2
DECLARE @StandardDeviationFactor_General FLOAT = 0.1
DECLARE @StandardDeviationMinimum_General FLOAT = 3
DECLARE @MinAgeOfPipeForReplacement FLOAT = 40
DECLARE @FailureYearAdjustment FLOAT = 2


--This should be a temp table instead of a set of variables.
SELECT @OBSEVKEY01 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BP PIPE MOVEMENT NOT MISSING'  --1000
SELECT @OBSEVKEY02 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BP PIPE COLLAPSED. CANNOT PASS'  --1002
SELECT @OBSEVKEY03 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BP OVAL PIPE. CRACKS' --1005
SELECT @OBSEVKEY04 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BP PIPE MISSING. SOIL VISIBLE' --1006
SELECT @OBSEVKEY05 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BP PIPE MISSING. VOID VISIBLE' --1007
SELECT @OBSEVKEY06 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BRK HOLE. SOIL VISIBLE' --1012
SELECT @OBSEVKEY07 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BRK DEFORMED. OVAL' --1013
SELECT @OBSEVKEY08 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BRK HOLE. VOID VISIBLE' --1014
SELECT @OBSEVKEY09 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'BRK COLLAPSED' --1015
SELECT @OBSEVKEY10 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'DS MISSING WALL. HOLE' --1046
SELECT @OBSEVKEY11 = OBSEVKEY FROM HA8_SMNSERVINSPTYPEOBSEV WHERE SEVDESC = 'DS MISSING WALL. HOLE W/VOID' --1047
SELECT @OBSEVKEY12 = -1--OBSEVKEY FROM [HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPTYPEOBSEV] WHERE SEVDESC = 'LT DEFECTIVE. ADD COMMENT' --1081
SELECT @OBSEVKEY13 = -1--OBSEVKEY FROM [HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPTYPEOBSEV] WHERE SEVDESC = 'LT DEFECTIVE+VOID. ADD COMMENT' --1082
SELECT @OBSEVKEY14 = -1--OBSEVKEY FROM [HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPTYPEOBSEV] WHERE SEVDESC = 'LT DEFECTIVE LATERAL PLUG' --1085
SELECT @OBSEVKEY15 = -1--OBSEVKEY FROM [HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPTYPEOBSEV] WHERE SEVDESC = 'LT DEFECTIVE LATERAL PLUG+VOID' --1086

/**************************************************/          
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
EXEC dbo.COST_ESTIMATOR
EXEC dbo.COST_ESTIMATOR_WHOLE
EXEC dbo.COST_ESTIMATOR_SIMPLIFY

--Basic consequence of failure calculations (only doing this for segments)
CREATE TABLE #COF_COSTS (ID int, GLOBALID int, COST float)

INSERT INTO #COF_COSTS (ID, GLOBALID)
SELECT  A.ID, A.GLOBALID 
FROM    dbo.COSTEST_PIPE AS A
        INNER JOIN 
        dbo.REHAB_RedundancyTable AS B 
        ON  A.ID = B.ID 
            AND 
            A.[Type] = 'S'
--1
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence 
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0115 Cost of Emergency Repair] AS B
      ON A.ID = B.ID
--2      
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0145 Separated Area Regulatory Fine] AS B
      ON A.GLOBALID = B.GLOBALID

--3
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0155 Basement Flooding] AS B
      ON A.GLOBALID = B.GLOBALID
      
      --4
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      (SELECT GLOBALID, SUM(Consequence) AS Consequence FROM dbo.[COF-0165 Public Health Safety Mainline] GROUP BY GLOBALID) AS B
      ON A.GLOBALID = B.GLOBALID
      
      --5-17595
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0215a Spill Street] AS B
      ON A.ID = B.ID
      --6
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0215b Spill Minor Arterial] AS B
      ON A.ID = B.ID
      --7
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0215c Spill Major Arterial] AS B
      ON A.ID = B.ID
      --8
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0215d Spill Freeway] AS B
      ON A.ID = B.ID
      --9
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0160h Sinkhole Minor Arterial] AS B
      ON A.GLOBALID = B.GLOBALID
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0156a Traffic Impacts Freeway] AS B
      ON A.ID = B.ID  
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0156b Traffic Impacts Major Arterial] AS B
      ON A.ID = B.ID 
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0156c Traffic Impacts Arterial] AS B
      ON A.ID = B.ID 
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0156d Traffic Impacts Street] AS B
      ON A.ID = B.ID    
-------------------------------------------------------
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0315a Surface Flooding Traffic Hazard Street] AS B
      ON A.ID = B.ID
      
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0315b Surface Flooding Traffic Hazard Arterial] AS B
      ON A.ID = B.ID
      
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0315c Surface Flooding Traffic Hazard Major Arterial] AS B
      ON A.ID = B.ID
      
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0315d Surface Flooding Traffic Hazard Freeway] AS B
      ON A.ID = B.ID
      
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0160h Emergency Bypass Pumping] AS B
      ON A.ID = B.ID      
      
UPDATE #COF_COSTS
SET COST = ISNULL(COST,0) + Consequence
FROM  #COF_COSTS AS A
      INNER JOIN 
      dbo.[COF-0160i Emergency PlateBaricade] AS B
      ON A.ID = B.ID      

UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Consequence_Failure = #COF_COSTS.COST 
FROM    REHAB_RedundancyTable 
        INNER JOIN  
        #COF_COSTS
        ON  REHAB_RedundancyTable.ID = #COF_COSTS.ID
        
UPDATE  REHAB_RedundancyTableWhole
SET     REHAB_RedundancyTableWhole.Consequence_Failure = B.MAXCOF
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN  
        (
          SELECT COMPKEY, MAX(Consequence_Failure) AS MAXCOF
          FROM   REHAB_RedundancyTable
          WHERE  CompKey > 0
          GROUP BY CompKey
        )  AS B
        ON A.CompKey = B.COMPKEY

DROP TABLE #COF_COSTS 

------------------------------------------------------------------------------------------
--Identify all the laterals
--Lateral inspections are not cut off by date, considering that 
--
TRUNCATE TABLE dbo.REHAB_LATERALS
 
INSERT INTO dbo.REHAB_LATERALS
              (
                COMPKEY, 
                COMPDTTM, 
                MEASFROM, 
                DISTFROM, 
                OBSEVKEY,
                OBSKEY
              )
SELECT  A.COMPKEY, 
        A.COMPDTTM,
        Observations.MEASFROM, 
        Observations.DISTFROM, 
        Observations.OBSEVKEY,
        Observations.OBSKEY
FROM    (
          SELECT  COMPKEY, 
                  Observations.INSPKEY, 
                  COMPDTTM, 
                  RANK() OVER(PARTITION BY COMPKEY ORDER BY COMPDTTM DESC) AS theRank, 
                  COUNT(*) AS TheCount
          FROM    --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVICEINSP] AS InspHist
                  HA8_SMNSERVICEINSP AS InspHist
                  INNER JOIN
                  HA8_SMNSERVINSPOB AS Observations
                  ON  InspHist.INSPKEY = Observations.INSPKEY
                      AND
                      OBSEVKEY NOT IN (1083, 1084, 1085, 1086)
          GROUP BY COMPKEY, Observations.INSPKEY, COMPDTTM
        ) AS A
        INNER JOIN 
        --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPOB] AS Observations
        HA8_SMNSERVINSPOB AS Observations
        ON  A.INSPKEY = Observations.INSPKEY
            AND
            Observations.OBKEY = 1012
WHERE   A.theRank = 1
ORDER BY COMPKEY, COMPDTTM

-------------------------------------------------------------------------------------------
--Update the spot repair construction cost for segments
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Replacement_Cost = [COSTEST_PIPE].TotalConstructionCost-- - (91.5*1.4*1.7375)*REHAB_RedundancyTable.[Length],
        --REHAB_RedundancyTable.Consequence_Failure = REHAB_RedundancyTable.Consequence_Failure +@EmergencyRepairFactor* [COSTEST_PIPE].TotalConstructionCost-- - (91.5*1.4*1.7375)*REHAB_RedundancyTable.[Length]
FROM    REHAB_RedundancyTable 
        INNER JOIN  
        [COSTEST_PIPE]
        ON  REHAB_RedundancyTable.ID = [COSTEST_PIPE].ID
            AND 
            [COSTEST_PIPE].Type = @COSTESTIMATOR_FLAG_SPOTREPAIR--'S'
            
UPDATE  REHAB_RedundancyTableWhole 
SET     REHAB_RedundancyTableWhole.Replacement_Cost = [COSTEST_PIPE].TotalConstructionCost-- - (91.5*1.4*1.7375)*REHAB_RedundancyTable.[Length],
        --REHAB_RedundancyTableWhole.Consequence_Failure = REHAB_RedundancyTableWhole.Consequence_Failure + @EmergencyRepairFactor * [COSTEST_PIPE].TotalConstructionCost-- - (91.5*1.4*1.7375)*REHAB_RedundancyTable.[Length]
FROM    REHAB_RedundancyTableWhole 
        INNER JOIN  
        [COSTEST_PIPE]
        ON  REHAB_RedundancyTableWhole.ID = [COSTEST_PIPE].ID
            AND 
            [COSTEST_PIPE].Type = @COSTESTIMATOR_FLAG_WHOLEPIPE--'W'

--Adding laterals to 'Total' values
UPDATE  A 
SET     A.Gen3SpotRepairCost = SumTotalConstructionCost
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN
        (
          SELECT  COMPKEY, SUM(Replacement_Cost * SpotRepairCount) AS SumTotalConstructionCost
          FROM    REHAB_RedundancyTable
          WHERE   SpotRepairCount = 1
                  AND
                  cutno > 0
          GROUP BY Compkey
        ) AS B
        ON A.Compkey = B.Compkey

UPDATE  REHAB_RedundancyTableWhole 
SET     REHAB_RedundancyTableWhole.ReplaceCostTotal = REHAB_RedundancyTableWhole.Replacement_Cost + (@CostOfLaterals*@EmergencyRepairFactor*@ENR)*ISNULL(CountOfLaterals,0),
        REHAB_RedundancyTableWhole.SpotCostTotal = REHAB_RedundancyTableWhole.Gen3SpotRepairCost + (@CostOfLaterals*@EmergencyRepairFactor*@ENR)*ISNULL(CountOfLaterals,0)
FROM    REHAB_RedundancyTableWhole
        LEFT JOIN
        ( 
          SELECT REHAB_RedundancyTableWhole.Compkey, COUNT(*) AS CountOfLaterals
          FROM   REHAB_RedundancyTableWhole
                 INNER JOIN 
                 REHAB_LATERALS
                 ON  REHAB_RedundancyTableWhole.CompKey = dbo.REHAB_LATERALS.COMPKEY
          GROUP BY REHAB_RedundancyTableWhole.Compkey
        ) AS A
        ON  REHAB_RedundancyTableWhole.Compkey = A.Compkey

-------------------------------------------------------------------------------------------
--Update the liner cost for all pipes.
UPDATE  REHAB_RedundancyTable
SET     REHAB_RedundancyTable.Liner_Cost = [COSTEST_PIPE].TotalConstructionCost -- - (91.5*1.4*1.7375)*REHAB_RedundancyTable.[Length]
FROM    REHAB_RedundancyTable 
        INNER JOIN  
        [COSTEST_PIPE]
        ON  REHAB_RedundancyTable.ID = [COSTEST_PIPE].ID
            AND 
            [COSTEST_PIPE].Type = @COSTESTIMATOR_FLAG_LINER

UPDATE  REHAB_RedundancyTableWhole
SET     REHAB_RedundancyTableWhole.Liner_Cost = [COSTEST_PIPE].TotalConstructionCost -- - (91.5*1.4*1.7375)*REHAB_RedundancyTable.[Length]
FROM    REHAB_RedundancyTableWhole 
        INNER JOIN  
        [COSTEST_PIPE]
        ON  REHAB_RedundancyTableWhole.GLOBALID = [COSTEST_PIPE].GLOBALID
            AND 
            [COSTEST_PIPE].Type = @COSTESTIMATOR_FLAG_LINER

UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.LineCostTotal = REHAB_RedundancyTable.Liner_Cost + (@CostOfLaterals*@EmergencyRepairFactor*@ENR)*ISNULL(CountOfLaterals,0),
        REHAB_RedundancyTable.LineCostNoSegsNoLats = REHAB_RedundancyTable.Liner_Cost,
        LateralCount = ISNULL(CountOfLaterals,0),
        TotalLateralCost = (@CostOfLaterals*@EmergencyRepairFactor*@ENR)*ISNULL(CountOfLaterals,0),
        SegmentLateralCost = (@CostOfLaterals*@EmergencyRepairFactor*@ENR)*ISNULL(CountOfLaterals,0)
FROM    REHAB_RedundancyTable
        LEFT JOIN
        ( 
          SELECT REHAB_RedundancyTable.ID, COUNT(*) AS CountOfLaterals
          FROM   REHAB_RedundancyTable
                 INNER JOIN 
                 REHAB_LATERALS
                 ON  REHAB_RedundancyTable.CompKey = dbo.REHAB_LATERALS.COMPKEY
                     AND
                     REHAB_RedundancyTable.FM <= dbo.REHAB_LATERALS.DISTFROM
                     AND
                     REHAB_RedundancyTable.[TO] > dbo.REHAB_LATERALS.DISTFROM
          GROUP BY REHAB_RedundancyTable.ID
        ) AS A
        ON  REHAB_RedundancyTable.ID = A.ID
        
UPDATE  REHAB_RedundancyTableWhole 
SET     REHAB_RedundancyTableWhole.LineCostTotal = REHAB_RedundancyTableWhole.Liner_Cost + (@CostOfLaterals*@EmergencyRepairFactor*@ENR)*ISNULL(CountOfLaterals,0),
        REHAB_RedundancyTableWhole.LineCostNoSegsNoLats = REHAB_RedundancyTableWhole.Liner_Cost,
        LateralCount = ISNULL(CountOfLaterals,0),
        TotalLateralCost = (@CostOfLaterals*@EmergencyRepairFactor*@ENR)*ISNULL(CountOfLaterals,0),
        SegmentLateralCost = (@CostOfLaterals*@EmergencyRepairFactor*@ENR)*ISNULL(CountOfLaterals,0)
FROM    REHAB_RedundancyTableWhole
        LEFT JOIN
        ( 
          SELECT REHAB_RedundancyTableWhole.Compkey, COUNT(*) AS CountOfLaterals
          FROM   REHAB_RedundancyTableWhole
                 INNER JOIN 
                 REHAB_LATERALS
                 ON  REHAB_RedundancyTableWhole.CompKey = dbo.REHAB_LATERALS.COMPKEY
          GROUP BY REHAB_RedundancyTableWhole.Compkey
        ) AS A
        ON  REHAB_RedundancyTableWhole.Compkey = A.Compkey
        
-------------------------------------------------------------------------------------------
--Finally, the manholes
UPDATE  REHAB_RedundancyTable   
SET     REHAB_RedundancyTable.ManholeCost = [COSTEST_PIPEDETAILS].Manhole
FROM    REHAB_RedundancyTable 
        INNER JOIN  
        [COSTEST_PIPEDETAILS]
        ON  REHAB_RedundancyTable.ID = [COSTEST_PIPEDETAILS].ID
            
UPDATE  REHAB_RedundancyTableWhole 
SET     REHAB_RedundancyTableWhole.ManholeCost = [COSTEST_PIPEDETAILS].Manhole
FROM    REHAB_RedundancyTableWhole 
        INNER JOIN  
        [COSTEST_PIPEDETAILS]
        ON  REHAB_RedundancyTableWhole.ID = [COSTEST_PIPEDETAILS].ID

/*
UPDATE  REHAB_RedundancyTable   
SET     REHAB_RedundancyTable.Liner_Cost = Liner_Cost ,--- ManholeCost,
        REHAB_RedundancyTable.Replacement_Cost = Replacement_Cost,-- - ManholeCost,
        REHAB_RedundancyTable.Consequence_Failure = Consequence_Failure-- - ManholeCost*/
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
UPDATE  REHAB_RedundancyTable 
SET     SpotCostTotal = SpotCostTotal * SpotRepairCount
FROM    REHAB_RedundancyTable

UPDATE  REHAB_RedundancyTableWhole 
SET     SpotCostTotal = TotalSpotCostTotal
FROM    REHAB_RedundancyTableWhole
        INNER JOIN
        (
          SELECT Compkey, SUM(SpotCostTotal * SpotRepairCount) AS TotalSpotCostTotal
          FROM REHAB_RedundancyTable
          GROUP BY COMPKEY
        ) AS A
        ON A.CompKey = REHAB_RedundancyTableWhole.Compkey


--------------------------------------------------------------------------
--UPDATE Liner Cost
UPDATE  REHAB_RedundancyTable 
SET     Liner_Cost = A.Liner_Cost + A.Replacement_Cost 
FROM    REHAB_RedundancyTable AS A 
WHERE   A.[ACTION] = 3

UPDATE  REHAB_RedundancyTableWhole 
SET     Liner_Cost = A.Liner_Cost + B.SpotCosts 
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN
        (
          SELECT   COMPKEY, SUM(Replacement_Cost) AS SpotCosts
          FROM     REHAB_RedundancyTable
          WHERE    Compkey > 0
                   AND
                   [ACTION] = 3
          GROUP BY Compkey
        ) AS B
        ON A.CompKey = B.Compkey


UPDATE  REHAB_RedundancyTable
SET     LineCostTotal = LineCostTotal + SpotCost - (SegmentLateralCost * SpotRepairCount)
FROM    REHAB_RedundancyTable

UPDATE  REHAB_RedundancyTableWhole
SET     LineCostTotal = LineCostTotal + SpotCostSum - SegLatCost
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN
        (
          SELECT COmpkey, SUM(SegmentLateralCost * SpotRepairCount) AS SegLatCost, SUM(SpotCost *SpotRepairCount) AS SpotCostSum
          FROM   REHAB_RedundancyTable
          WHERE COMPKEY > 0
          GROUP BY COMPKEY
        ) AS B
        ON A.CompKey = B.Compkey


END

GO

