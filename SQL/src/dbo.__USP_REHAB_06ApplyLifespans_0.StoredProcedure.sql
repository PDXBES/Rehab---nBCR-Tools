USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[__USP_REHAB_06ApplyLifespans_0]    Script Date: 03/23/2016 14:10:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[__USP_REHAB_06ApplyLifespans_0] @recreateLookupTables INT = 0, @AsOfDate datetime = null
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


--If we are doing quickcalcs, don't recreate the lookup tables
IF @recreateLookupTables = 1
BEGIN
  ----------------------------------------------------------------------------------------------
  --The unit multiplier table is a way to speed up the query process. 
  TRUNCATE TABLE REHAB_UnitMultiplierTable

  ----------------------------------------------------------------------------------------------
  --We wont be considering years prior to 1975 as failure years.  It is very very unlikely
  --That any failure year could be assumed to be before 1975.
  SET @iterativeYear = @SimulationStartYear

  ----------------------------------------------------------------------------------------------
  --Fill the unit multiplier table with the appropriate values.  We won't be considering
  --contributions following the year 2250.  This is about 50 years beyond any appreciable
  --contribution due to standard deviations.
  WHILE @iterativeYear <= year(@AsOfDate)+ @CountOfYearsToPlanFor
  BEGIN
    --------------------------------------------------------------------------------------------
    --We will assume that the range of possible standard deviations is 1 to 50.  I'm fairly
    --certain the standard deviation doesn't go much higher than 24, but just in case.
    SET @replaceSDev = 1
    WHILE @replaceSDev <= @MaxStandardDeviation
    BEGIN
      ----------------------------------------------------------------------------------------
      --Fill the unitMultiplier table with the base data.
      INSERT INTO REHAB_UnitMultiplierTable 
      SELECT      @iterativeYear as failure_yr, 
                  @replaceSDev as std_dev, 
                  0 as unit_multiplier
      SET @replaceSDev = @replaceSDev + 1
    END
    SET @iterativeYear = @iterativeYear + 1
  END

  ----------------------------------------------------------------------------------------------
  --Prepare the temporary variables with the base data
  SET @ReplaceYear = year(@AsOfDate)+@SegmentReplacementRUL
  SET @ReplaceYear_Whole = year(@AsOfDate)+@PipeReplacementRUL
  SET @ReplaceSDev = @ReplacementStandardDeviation
  SET @thisYear = year(@AsOfDate)
  SET @iterativeYear = year(@AsOfDate)

  --Set the initial unit multiplier value
  UPDATE  REHAB_UnitMultiplierTable 
  SET     unit_multiplier = CASE WHEN (1-dbo.NORMDIST(@thisYear, Failure_Yr, Std_Dev, 1)) <= 0 THEN 1 ELSE
          (dbo.NORMDIST(@iterativeYear+1, Failure_Yr, Std_Dev, 1)
          -dbo.NORMDIST(@iterativeYear, Failure_Yr, Std_Dev, 1))
          /(1-dbo.NORMDIST(@thisYear, Failure_Yr, Std_Dev, 1))
          END

  SET @iterativeYear = @iterativeYear+1

  ----------------------------------------------------------------------------------------------
  --This is the loop that fills the unitMultiplierTable with the actual Unit Multipliers
  WHILE @iterativeYear <= year(@AsOfDate)+ @CountOfYearsToPlanFor
  BEGIN
    ----------------------------------------------------------------------------------------------
    --Of course we need to temper our unit multipliers with the effects of inflation
    SET    @yearExponent = Power(@interestValue, @thisYear - @iterativeYear)
    ----------------------------------------------------------------------------------------------
    UPDATE  REHAB_UnitMultiplierTable 
    SET     unit_multiplier = unit_multiplier + CASE WHEN (1-dbo.NORMDIST(@thisYear, Failure_Yr, Std_Dev, 1)) <= 0 THEN 0 ELSE
            POWER(@interestValue,-(@iterativeYear-@thisYear))
            *(dbo.NORMDIST(@iterativeYear+1, Failure_Yr, Std_Dev, 1)
            -dbo.NORMDIST(@iterativeYear, Failure_Yr, Std_Dev, 1))
            /(1-dbo.NORMDIST(@thisYear, Failure_Yr, Std_Dev, 1))
    END
    ---------------------------------------------------------------------------------------------- 
    SET @iterativeYear = @iterativeYear+1
  END
--End lookup table reconstruction
END 

----------------------------------------------------------------------------------------------
--CompkeyTable was originally intended to keep track of the
--Grade 4 and 5 pipes and the amount of damage they had
--sustained. It is possible
--that this table is no longer necessary.
TRUNCATE TABLE REHAB_CompkeyTable

----------------------------------------------------------------------------------------------
--Truncating tables is faster than deleting.
TRUNCATE TABLE  REHAB_SmallResultsTable

----------------------------------------------------------------------------------------------
--first make a list of compkeys 
INSERT INTO REHAB_CompkeyTable 
  SELECT    COMPKEY, 
            0 AS numSegments, 
            0 AS numBroke, 
            0 AS numFixed, 
            0 AS Fail_tot, 
            MAX(Consequence_Failure) AS Consequence_Failure, 
            MAX(Replacement_Cost) AS Replacement_Cost,
            MAX(Liner_Cost) AS Liner_Cost
  FROM      REHAB_RedundancyTable 
  WHERE     CompKey IS NOT NULL
  GROUP BY  COMPKEY

--The number of broken segments is the count of segments that
--have OBSEVKEYs that indicate the need for a spot repair
UPDATE REHAB_CompkeyTable 
SET    REHAB_CompkeyTable.numBroke = A.numBroke 
FROM   REHAB_CompkeyTable 
       INNER JOIN 
       (   
         SELECT  COMPKEY, 
                 COUNT(*) AS numBroke
         FROM    (
                   SELECT  M.CompKey, 
                           M.CutNO
                   FROM    REHAB_RedundancyTable AS M 
                           INNER JOIN 
                           (
                             SELECT  compkey, 
                                     convert_setdwn_from, 
                                     convert_setdwn_to,  
                                     REHAB_CONVERSION.OBSEVKEY
                             FROM    REHAB_CONVERSION 
                             WHERE   OBSEVKEY IN
                                     (
                                       @OBSEVKEY01,
                                       @OBSEVKEY02,
                                       @OBSEVKEY03,
                                       @OBSEVKEY04,
                                       @OBSEVKEY05,
                                       @OBSEVKEY06,
                                       @OBSEVKEY07,
                                       @OBSEVKEY08,
                                       @OBSEVKEY09,
                                       @OBSEVKEY10,
                                       @OBSEVKEY11,
                                       @OBSEVKEY12,
                                       @OBSEVKEY13,
                                       @OBSEVKEY14,
                                       @OBSEVKEY15
                                     )
                           ) AS A 
                           ON  M.Compkey = A.Compkey
                   WHERE   /*(CutNo = Seg_Count AND convert_setdwn_to>= M.[to]) OR*/ 
                           (
                             --segment left inside damage
                             (
                               M.[fm] >= convert_setdwn_from
                               AND
                               M.[fm] < convert_setdwn_to
                             )
                             OR
                             --segment right inside damage
                             (
                               M.[to] >= convert_setdwn_from
                               AND
                               M.[to] < convert_setdwn_to
                             )
                             OR
                             --damage inside segment
                             (
                               M.[fm] <= convert_setdwn_from
                               AND
                               M.[to] > convert_setdwn_to
                             )
                             OR
                             (
                               M.[fm] = A.convert_setdwn_from
                               AND
                               M.[fm] = A.convert_setdwn_to
                             )
                           )
                   GROUP BY M.COMPKEY, CUTNO
                 ) AS B GROUP BY COMPKEY
       ) AS A 
ON REHAB_CompkeyTable.compkey = A.Compkey

----------------------------------------------------------------------------------------------
--The compkey table needs to know how many segments are in each pipe
--(rehabredundancytable contains only segments, so don't worry about
--the whole pipe being counted as a segment in this query).
UPDATE  REHAB_CompkeyTable 
SET     REHAB_CompkeyTable.numSegments = A.numSegments 
FROM    REHAB_CompkeyTable 
        INNER JOIN 
        (
          SELECT  COMPKEY,
                  COUNT(*) AS numSegments 
          FROM    REHAB_RedundancyTable 
          GROUP BY COMPKEY
        ) AS A 
        ON  REHAB_CompkeyTable.compkey = A.Compkey

----------------------------------------------------------------------------------------------
--Compkeytable needs to know how many segments we think have been fixed 
--or replaced
UPDATE  REHAB_CompkeyTable 
SET     REHAB_CompkeyTable.numFixed = A.numFixed 
FROM    REHAB_CompkeyTable 
        INNER JOIN 
        (
          SELECT  COMPKEY, 
                  COUNT(*) AS numFixed 
          FROM    REHAB_RedundancyTable
          WHERE   Material like @ReplacingMaterialPrefixSEARCH 
          GROUP BY COMPKEY
        ) AS A 
        ON  REHAB_CompkeyTable.compkey = A.Compkey

----------------------------------------------------------------------------------------------
--Create table REHAB_DEFECTS, this table may eventually replace CONVERSION
--due to its greater amount of information available
TRUNCATE TABLE [dbo].[REHAB_DEFECTS]

INSERT INTO [dbo].[REHAB_DEFECTS]
            (
              [COMPKEY] ,
              [INSPKEY] ,
              [NewScore] ,
              [CutNo] ,
              [convert_setdwn_from] ,
              [convert_setdwn_to] ,
              [ReadingKey] ,
              [STARTDTTM] ,
              [COMPDTTM] ,
              [INSTDATE] ,
              [OBSEVKEY] ,
              [OBKEY] ,
              [RATING] ,
              [OWN] ,
              [UnitType] ,
              [ServStat] 
            )
SELECT  M.CompKey, 
        INSPKEY,
        (
          CASE 
            WHEN  (
                    M.FM >= A.convert_setdwn_from
                    AND 
                    M.[TO] <= A.convert_setdwn_to
                  ) 
            THEN  [Length] * A.peak_score 
            ELSE  CASE 
                    WHEN  (
                            M.FM < A.convert_setdwn_from
                            AND 
                            M.[TO] > A.convert_setdwn_to
                          ) 
                    THEN (A.convert_setdwn_to - A.convert_setdwn_from) * A.peak_score 
                    ELSE  CASE 
                            WHEN  (
                                    M.[TO] > A.convert_setdwn_to
                                  ) 
                            THEN (A.convert_setdwn_to - M.[FM]) * A.peak_score 
                            ELSE  CASE 
                                    WHEN (
                                           M.FM < A.convert_setdwn_from
                                         ) 
                                    THEN (M.[TO] - A.convert_setdwn_from) * A.peak_score 
                                    ELSE 0 
                                  END 
                          END 
                  END 
          END
        ) AS newScore,
        M.CutNO, 
        A.[convert_setdwn_from], 
        A.[convert_setdwn_to],
        [ReadingKey],
        [STARTDTTM],
        [COMPDTTM],
        A.[INSTDATE],
        [OBSEVKEY],
        [OBKEY],
        A.[RATING],
        [OWN],
        [UnitType],
        NULL 
FROM    REHAB_RedundancyTable AS M 
        INNER JOIN 
        (
          SELECT  REHAB_CONVERSION.*,
                  peak_Score
          FROM    REHAB_CONVERSION 
                  INNER JOIN  
                  REHAB_PeakScore_Lookup
                  ON  REHAB_CONVERSION.OBSEVKEY = REHAB_PeakScore_Lookup.OBSEVKEY
        ) AS A 
        ON  M.Compkey = A.Compkey
            AND
            ( 
              (
                --segment left inside damage
                (
                  M.[fm] >= convert_setdwn_from
                  AND
                  M.[fm] <= convert_setdwn_to
                )
                OR
                --segment right inside damage
                (
                  M.[to] > convert_setdwn_from
                  AND
                  M.[to] < convert_setdwn_to
                )
                OR
                --damage inside segment
                (
                  M.[fm] <= convert_setdwn_from
                  AND
                  M.[to] > convert_setdwn_to
                )
              )
            )
            AND
            [convert_setdwn_from] <> [convert_setdwn_to]


INSERT INTO [dbo].[REHAB_DEFECTS]
            (
              [COMPKEY] ,
              [INSPKEY] ,
              [NewScore] ,
              [CutNo] ,
              [convert_setdwn_from] ,
              [convert_setdwn_to] ,
              [ReadingKey] ,
              [STARTDTTM] ,
              [COMPDTTM] ,
              [INSTDATE] ,
              [OBSEVKEY] ,
              [OBKEY] ,
              [RATING] ,
              [OWN] ,
              [UnitType] ,
              [ServStat] 
            )
SELECT  REHAB_RedundancyTable.CompKey, 
        INSPKEY, 
        REHAB_CONVERSION.NewScore,
        REHAB_RedundancyTable.CutNO,  
        [convert_setdwn_from],
        [convert_setdwn_to],
        [ReadingKey] ,
        [STARTDTTM] ,
        [COMPDTTM] ,
        REHAB_RedundancyTable.[INSTDATE] ,
        [OBSEVKEY] ,
        [OBKEY] ,
        REHAB_CONVERSION.[RATING] ,
        [OWN] ,
        [UnitType] ,
        [ServStat] 
FROM    REHAB_CONVERSION 
        INNER JOIN
        REHAB_RedundancyTable 
        ON  REHAB_CONVERSION.compkey = REHAB_RedundancyTable.CompKey
WHERE   [convert_setdwn_from] = [convert_setdwn_to]
        AND
        (
          (
            CutNo = Seg_Count 
            AND 
            REHAB_CONVERSION.convert_setdwn_from >= REHAB_RedundancyTable.fm
          ) 
          OR 
          (
            (
              REHAB_CONVERSION.convert_setdwn_from >= REHAB_RedundancyTable.fm 
              AND  
              REHAB_CONVERSION.convert_setdwn_from < REHAB_RedundancyTable.[to]
            )
            AND 
            (
              REHAB_CONVERSION.convert_setdwn_to Is Null 
              OR 
              REHAB_CONVERSION.convert_setdwn_to = 0 
              OR 
              REHAB_CONVERSION.convert_setdwn_to = REHAB_CONVERSION.convert_setdwn_from
            )
          )
        )
----------------------------------------------------------------------------------------------
--Compkey table needs to know how many segments we think either
--have been replaced or still need to be replaced.
--This query is separate from the other two counting
--queries because we want to only count a segment that has
--already been replaced AND needs to be replaced again
--as just one segment.

UPDATE  REHAB_CompkeyTable 
SET     Fail_tot = theCount   
FROM    REHAB_CompkeyTable 
        INNER JOIN 
        (
          SELECT  COMPKEY, 
                  COUNT(*) AS theCount
          FROM    (
                    SELECT  COMPKEY, 
                            CUTNO
                    FROM    (
                              SELECT  A.[COMPKEY]
                                      ,[INSPKEY]
                                      ,[NewScore]
                                      ,A.[CutNo]
                                      ,[convert_setdwn_from]
                                      ,[convert_setdwn_to]
                                      ,[ReadingKey]
                                      ,[STARTDTTM]
                                      ,[COMPDTTM]
                                      ,A.[INSTDATE]
                                      ,[OBSEVKEY]
                                      ,[OBKEY]
                                      ,B.[RATING]
                                      ,[OWN]
                                      ,[UnitType]
                                      ,[ServStat]
                              FROM    /*[REHAB].[dbo].*/REHAB_RedundancyTable AS A
                                      LEFT JOIN
                                      /*[REHAB].[dbo].*/[REHAB_DEFECTS] AS B
                                      ON  A.COMPKEY = B.COMPKEY
                                          AND
                                          A.CutNo = B.CutNo
                              WHERE   Material LIKE @ReplacingMaterialPrefixSEARCH
                                      OR
                                      OBSEVKEY IN  (
                                                     @OBSEVKEY01,
                                                     @OBSEVKEY02,
                                                     @OBSEVKEY03,
                                                     @OBSEVKEY04,
                                                     @OBSEVKEY05,
                                                     @OBSEVKEY06,
                                                     @OBSEVKEY07,
                                                     @OBSEVKEY08,
                                                     @OBSEVKEY09,
                                                     @OBSEVKEY10,
                                                     @OBSEVKEY11,
                                                     @OBSEVKEY12,
                                                     @OBSEVKEY13,
                                                     @OBSEVKEY14,
                                                     @OBSEVKEY15
                                                   ) 
                            ) AS X GROUP BY COMPKEY, CUTNO
                  ) AS Y
                  GROUP BY COMPKEY
        ) AS AX
        ON  REHAB_CompkeyTable.compkey = AX.CompKey

----------------------------------------------------------------------------------------------
--Move the std_dev and failure year to the segment columns, because the
--standard deviation and failure year are currently describing the
--state of the segments.
UPDATE  REHAB_RedundancyTable 
SET     Fail_YR_Seg = Failure_Year, 
        Std_DEV_Seg = Std_Dev 
WHERE   Failure_Year <> 0
        AND
        Std_Dev <>0
        
UPDATE  REHAB_RedundancyTableWhole 
SET     Failure_Year = MINFail_YR_Seg, 
        Std_DEV = MINStd_Dev_Seg 
FROM    REHAB_RedundancyTableWhole
        INNER JOIN
        (
          SELECT Compkey, MIN(fail_YR_Seg) AS MINFail_YR_Seg, MIN(Std_DEV_Seg) AS MINStd_Dev_Seg
          FROM   REHAB_RedundancyTable
          WHERE  Failure_Year <> 0
                 AND
                 Std_Dev <>0
          GROUP BY COMPKEY
        ) AS A
        ON A.CompKey = REHAB_RedundancyTableWhole.Compkey


----------------------------------------------------------------------------------------------
--Identify the action 1 pipes
--Default all segments to action flag 1
UPDATE  REHAB_RedundancyTable 
SET     [ACTION] = @ActionFlag_DoNothing--1 
FROM    REHAB_RedundancyTable 

UPDATE  REHAB_RedundancyTableWhole 
SET     [ACTION] = @ActionFlag_DoNothing--1 
FROM    REHAB_RedundancyTableWhole

----------------------------------------------------------------------------------------------
--Identify the action 3 pipes.
--Action 3 pipes simply require a few spot repairs and the whole pipe
--should be replaced in 30 years if there are spot repairs that need to be done.
--I wonder if it is a good idea to limit spot repair pipes to those
--that have hansen grades of 4 or more.  There does exist ONE case as
--of 07-12-2011 that is grade_h5 of 3 and total defect score of 1002, 
--compkey 131818.

UPDATE  REHAB_RedundancyTable 
SET     [ACTION] = @ActionFlag_SpotRepair,--3
        SpotRepairCount = 1
FROM    REHAB_RedundancyTable
        INNER JOIN
        (
          SELECT  M.CompKey,
                  M.CutNO,
                  M.[TO],
                  M.FM
          FROM    REHAB_RedundancyTable AS M 
                  INNER JOIN 
                  (
                    SELECT  compkey, 
                            convert_setdwn_from,
                            convert_setdwn_to,
                            REHAB_CONVERSION.OBSEVKEY
                    FROM    REHAB_CONVERSION 
                    WHERE   OBSEVKEY IN  (
                                           @OBSEVKEY01,
                                           @OBSEVKEY02,
                                           @OBSEVKEY03,
                                           @OBSEVKEY04,
                                           @OBSEVKEY05,
                                           @OBSEVKEY06,
                                           @OBSEVKEY07,
                                           @OBSEVKEY08,
                                           @OBSEVKEY09,
                                           @OBSEVKEY10,
                                           @OBSEVKEY11,
                                           @OBSEVKEY12,
                                           @OBSEVKEY13,
                                           @OBSEVKEY14,
                                           @OBSEVKEY15
                                         )
                  ) AS A 
                  ON  M.Compkey = A.Compkey
          WHERE   (
                    --segment left inside damage
                    (
                      M.[fm] >= convert_setdwn_from
                      AND
                      M.[fm] <= convert_setdwn_to
                    )
                    OR
                    --segment right inside damage
                    (
                      M.[to] >= convert_setdwn_from
                      AND
                      M.[to] <= convert_setdwn_to
                    )
                    OR
                    --damage inside segment
                    (
                      M.[fm] <= convert_setdwn_from
                      AND
                      M.[to] >= convert_setdwn_to
                    )
                  )
        ) AS B 
        ON  B.CompKey = REHAB_RedundancyTable.CompKey
            AND
            B.CutNO = dbo.REHAB_RedundancyTable.CutNo
        INNER JOIN
        REHAB_CompkeyTable
        ON
        REHAB_RedundancyTable.Compkey = REHAB_CompkeyTable.Compkey  

UPDATE  REHAB_RedundancyTable 
SET     SpotRepairCount = 1
FROM    REHAB_RedundancyTable
WHERE   Total_Defect_Score >= 1000
           
UPDATE  REHAB_RedundancyTableWhole
SET     SpotRepairCount = SumSpots
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN
        (
          SELECT COMPKEY, SUM(SpotRepairCount) AS SumSPots
          FROM   REHAB_RedundancyTable
          GROUP BY Compkey
        ) AS B
        ON A.CompKey = B.COMPKEY
  
----------------------------------------------------------------------------------------------
--For cases where action = 0
UPDATE  REHAB_RedundancyTableWhole
SET     Std_Dev = CASE 
                    WHEN (@StandardDeviationFactor_High*RULife) < @StandardDeviationMinimum_General --0.2
                    THEN @StandardDeviationMinimum_General 
                    ELSE @StandardDeviationFactor_High*RULife 
                  END, 
        [ACTION] = @ActionFlag_PipeInProcessOfReplacement
WHERE   (
          Insp_Curr = @InspectionFlag_InstallDateIsAfterLastInspection 
          OR  
          Insp_Curr = @InspectionFlag_InspectionDateIsNULL
        )
        AND
        hservstat <> @HSERVSTAT_NEW--'NEW'
        AND
        (
          YEAR(@AsOfDate) - YEAR(instdate) > @MinAgeOfPipeForReplacement
          OR
          instdate IS NULL
        )

--UPDATE segcount
UPDATE  REHAB_RedundancyTable 
SET     seg_count = theCount 
FROM    REHAB_RedundancyTable 
        INNER JOIN 
        (
          SELECT  COMPKEY, 
                  COUNT(*) AS theCount 
          FROM    REHAB_RedundancyTable
          GROUP BY COMPKEY
        ) AS B 
        ON  REHAB_RedundancyTable.COMPKEY = B.COMPKEY 
WHERE   B.COMPKEY <> 0

UPDATE  REHAB_RedundancyTableWhole
SET     seg_count = B.seg_count
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN 
        REHAB_RedundancyTable AS B
        ON A.Compkey = B.CompKey
           AND
           A.COMPKEY <> 0

--UPDATE fail_near
UPDATE  REHAB_RedundancyTable 
SET     Fail_near = B.numBroke 
FROM    REHAB_RedundancyTable 
        INNER JOIN 
        dbo.REHAB_CompkeyTable AS B 
        ON REHAB_RedundancyTable.CompKey = B.COMPKEY
        
UPDATE  REHAB_RedundancyTableWhole
SET     Fail_near = B.Fail_near
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN 
        REHAB_RedundancyTable AS B
        ON A.Compkey = B.CompKey
           AND
           A.COMPKEY <> 0


--UPDATE fail_prev
UPDATE  REHAB_RedundancyTable 
SET     Fail_prev = B.numFixed 
FROM    REHAB_RedundancyTable 
        INNER JOIN 
        dbo.REHAB_CompkeyTable AS B 
        ON  REHAB_RedundancyTable.CompKey = B.COMPKEY
        
UPDATE  REHAB_RedundancyTableWhole
SET     Fail_prev = B.Fail_prev
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN 
        REHAB_RedundancyTable AS B
        ON A.Compkey = B.CompKey
           AND
           A.COMPKEY <> 0
        
--UPDATE fail_TOT
UPDATE  REHAB_RedundancyTable 
SET     Fail_tot = B.Fail_tot 
FROM    REHAB_RedundancyTable 
        INNER JOIN 
        dbo.REHAB_CompkeyTable AS B 
        ON  REHAB_RedundancyTable.CompKey = B.COMPKEY
        
UPDATE  REHAB_RedundancyTableWhole
SET     Fail_tot = B.Fail_tot
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN 
        REHAB_RedundancyTable AS B
        ON A.Compkey = B.CompKey
           AND
           A.COMPKEY <> 0
        
--UPDATE fail_PCT
UPDATE  REHAB_RedundancyTable 
SET     Fail_pct = CASE 
                     WHEN seg_count = 0 
                     THEN 0 
                     ELSE CAST(fail_tot AS FLOAT)/CAST(seg_count AS FLOAT)*100 
                   END 
WHERE COMPKEY <> 0

UPDATE  REHAB_RedundancyTableWhole
SET     Fail_pct = B.Fail_pct
FROM    REHAB_RedundancyTableWhole AS A
        INNER JOIN 
        REHAB_RedundancyTable AS B
        ON A.Compkey = B.CompKey
           AND
           A.COMPKEY <> 0


END

GO

