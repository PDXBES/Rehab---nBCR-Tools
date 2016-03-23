USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[__USP_REHAB_01CREATECONVERSIONGIS]    Script Date: 03/23/2016 14:09:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[__USP_REHAB_01CREATECONVERSIONGIS] @AsOfDate DATETIME = NULL, @TableSize INT = -1, @Subset AS [GIS].Rehab10FtSegs_Subset READONLY
AS
BEGIN

IF @AsOfDate IS NULL
   SET @AsOfDate = GETDATE()
   
DECLARE @tvp2 AS [GIS].Rehab10FtSegs_Subset
IF @TableSize = -1
BEGIN
  

  INSERT INTO @tvp2
  SELECT * 
  FROM GIS.REHAB_Segments
END
ELSE
BEGIN
  INSERT INTO @tvp2
  SELECT * 
  FROM @Subset
END
   
DECLARE @REPORT_YEAR int
--The following variables identify the HANSEN observation codes, as of HANSEN 8
DECLARE @CODE_SEWERBROKENPIPE int
DECLARE @CODE_SEWERBRICKWORK int
DECLARE @CODE_SEWERCRACK int
DECLARE @CODE_SEWERSTRUCTURALDAMAGE int
DECLARE @CODE_SEWERJOINTDEFECTS int

DECLARE @CODE_STORMBROKENPIPE int
DECLARE @CODE_STORMBRICKWORK int
DECLARE @CODE_STORMCRACK int
DECLARE @CODE_STORMSTRUCTURALDAMAGE int
DECLARE @CODE_STORMJOINTDEFECTS int

DECLARE @CODE_SEWERCOMPTYPE int
DECLARE @CODE_STORMCOMPTYPE int
DECLARE @CODE_SEWERINSPNDXKEY int
DECLARE @CODE_STORMINSPNDXKEY int

DECLARE @CODE_SEWERINDEXKEY int
DECLARE @CODE_STORMINDEXKEY INT

DECLARE @MinimumSegmentID INT = 40000000
DECLARE @STRING_MATERIAL NVARCHAR(255) = 'MATERIAL'
DECLARE @STRING_VARIES NVARCHAR(255) = 'VARIES'
DECLARE @STRING_MATVSP NVARCHAR(255) = 'MAT-VSP'
DECLARE @STRING_EMPTYSTRING NVARCHAR(255) = ''
DECLARE @STRING_SEARCHMATERIALPREFIX NVARCHAR(255) = 'MAT-'
DECLARE @STRING_ORIGINALLYVSP NVARCHAR(255) = '1_VSP'
DECLARE @ReplacingMaterialPrefix NVARCHAR(255) = '2_'
DECLARE @OriginalMaterialPrefix NVARCHAR(255) = '1_'
DECLARE @HSERVSTAT_TBAB NVARCHAR(255) = 'TBAB'
DECLARE @HSERVSTAT_ABAN NVARCHAR(255) = 'ABAN'
DECLARE @HSERVSTAT_PEND NVARCHAR(255) = 'PEND'
DECLARE @StandardDeviationFactor1 FLOAT = 0.1
DECLARE @StandardDeviationFactor2 FLOAT = 0.25
DECLARE @StandardDeviationMinimum_NoProblems FLOAT = 5
DECLARE @COSTESTIMATOR_FLAG_WHOLEPIPE NVARCHAR(255) = 'W'
DECLARE @COSTESTIMATOR_FLAG_LINER NVARCHAR(255) = 'L'
DECLARE @COSTESTIMATOR_FLAG_SPOTREPAIR NVARCHAR(255) = 'S'

DECLARE @InspectionFlag_InspectionDateIsNotNullAndInstallDateIsLessThanInspectionDateOrNullOrServstatIsPEND INT = 1
DECLARE @InspectionFlag_InstallDateIsNullAndServstatIsTBABOrABAN INT = 2
DECLARE @InspectionFlag_InstallDateIsAfterLastInspection INT = 3
DECLARE @InspectionFlag_InspectionDateIsNULL INT = 4

DECLARE @CostOfLaterals INT
SELECT @CostOfLaterals = EMLateralRepairCost FROM Constants

DECLARE @ENR FLOAT = 1.7375
DECLARE @EmergencyRepairFactor FLOAT = 1.4

--Apply the codes to those variables
SELECT @CODE_SEWERBROKENPIPE = OBKEY FROM HA8_SMNSERVINSPTYPEOB WHERE OBCODE = 'BP'
SELECT @CODE_SEWERBRICKWORK = OBKEY FROM HA8_SMNSERVINSPTYPEOB WHERE OBCODE = 'BRK'
SELECT @CODE_SEWERCRACK = OBKEY FROM HA8_SMNSERVINSPTYPEOB WHERE OBCODE = 'CR'
SELECT @CODE_SEWERSTRUCTURALDAMAGE = OBKEY FROM HA8_SMNSERVINSPTYPEOB WHERE OBCODE = 'DS'
SELECT @CODE_SEWERJOINTDEFECTS = OBKEY FROM HA8_SMNSERVINSPTYPEOB WHERE OBCODE = 'JT'

SELECT @CODE_STORMBROKENPIPE = OBKEY FROM HA8_STMNSERVINSPTYPEOB WHERE OBCODE = 'BP'
SELECT @CODE_STORMBRICKWORK = OBKEY FROM HA8_STMNSERVINSPTYPEOB WHERE OBCODE = 'BRK'
SELECT @CODE_STORMCRACK = OBKEY FROM HA8_STMNSERVINSPTYPEOB WHERE OBCODE = 'CR'
SELECT @CODE_STORMSTRUCTURALDAMAGE = OBKEY FROM HA8_STMNSERVINSPTYPEOB WHERE OBCODE = 'DS'
SELECT @CODE_STORMJOINTDEFECTS = OBKEY FROM HA8_STMNSERVINSPTYPEOB WHERE OBCODE = 'JT'

SELECT @CODE_SEWERCOMPTYPE = COMPTYPE FROM HA8_COMPTYPE WHERE COMPDESC = 'SEWER MAIN'
SELECT @CODE_STORMCOMPTYPE = COMPTYPE FROM HA8_COMPTYPE WHERE COMPDESC = 'STORM MAIN'

SELECT @CODE_SEWERINSPNDXKEY = INSPNDXKEY FROM HA8_ASSETINSPINDEX WHERE IndexDesc = 'Structural Rating' AND CompType = @CODE_SEWERCOMPTYPE
SELECT @CODE_STORMINSPNDXKEY = INSPNDXKEY FROM HA8_ASSETINSPINDEX WHERE IndexDesc = 'Structural Rating' AND CompType = @CODE_STORMCOMPTYPE


SET @REPORT_YEAR = year(@AsOfDate)

--------------------------------------------------------------
--Empty segment redundancy table
TRUNCATE TABLE REHAB_RedundancyTable


IF (@TableSize = -1)
BEGIN
  --------------------------------------------------------------
  --Fill redundancy table with segment data from GIS.REHAB_Segments
  INSERT INTO  REHAB_RedundancyTable 
  SELECT 
          0,              [UsNode],       [DsNode],       ID,
          [CompKey],      [Length],       [DiamWidth],    [Height],
          [pipeshape],    [Material],     [Instdate],     NULL,
          /*[HServStat]*/NULL,    GLOBALID,       0,              NULL,
          [CutNO],        [FM],           [TO_],          [SegLen],
          '',             seg_count,      0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           0,              0,              0,
          0,              0,              0,              0, 
          0,              0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0
  FROM    GIS.REHAB_Segments 
  WHERE   ID >= @MinimumSegmentID 

  ---------------------------------------------------------------
  --Empty whole pipe redundancy table
  TRUNCATE TABLE  REHAB_RedundancyTableWhole
  
  ---------------------------------------------------------------
  --Fill Whole pipe redundancy table with data from GIS.REHAB_Segments
  INSERT INTO  REHAB_RedundancyTableWhole
  SELECT 
          0,              [UsNode],       [DsNode],       ID,
          [CompKey],      [Length],       [DiamWidth],    [Height],
          [pipeshape],    [Material],     [Instdate],     NULL,
          /*[HServStat]*/NULL,    GLOBALID,       0,              NULL,
          [CutNO],        [FM],           [TO_],          [SegLen],
          '',             0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           0,              0,              0,
          0,              0,              0,              0, 
          0,              0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0
  FROM    GIS.REHAB_Segments 
  WHERE   ID < @MinimumSegmentID 
END
ELSE
BEGIN
DELETE FROM GIS.REHAB_Segments_SUBSET_OUT
  --------------------------------------------------------------
  --Fill redundancy table with segment data from GIS.REHAB_Segments
  INSERT INTO  GIS.REHAB_Segments_SUBSET_OUT
  SELECT 
          ID, XBJECTID, GLOBALID, COMPKEY, [UsNode],       [DsNode],       UNITTYPE,
          COMPTYPE,      [Length],       [DiamWidth],    [Height],
          [pipeshape],    [Material],     [Instdate],     HSERVSTAT,
          bsnrun,    old_mlid,       cutno,              [FM],           [TO_],          [SegLen],
          grade_h5,       mat_fmto,       seg_count,      0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           0,              0,              0,
          0,              0,              0,              0, 
          0,              0,              0,              0,
          0,              0,              0,              geom,
          0,              0,              0,              0,
          0,              0,              0,NULL,NULL,NULL,NULL,NULL,NULL
  FROM    @tvp2
  --------------------------------------------------------------
  --Fill redundancy table with segment data from GIS.REHAB_Segments
  INSERT INTO  REHAB_RedundancyTable 
  SELECT 
          0,              [UsNode],       [DsNode],       ID,
          [CompKey],      [Length],       [DiamWidth],    [Height],
          [pipeshape],    [Material],     [Instdate],     NULL,
          /*[HServStat]*/NULL,    GLOBALID,       0,              NULL,
          [CutNO],        [FM],           [TO_],          [SegLen],
          '',             seg_count,      0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           0,              0,              0,
          0,              0,              0,              0, 
          0,              0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0
  FROM    @tvp2
  WHERE   ID >= @MinimumSegmentID 

  ---------------------------------------------------------------
  --Empty whole pipe redundancy table
  TRUNCATE TABLE  REHAB_RedundancyTableWhole
  
  ---------------------------------------------------------------
  --Fill Whole pipe redundancy table with data from GIS.REHAB_Segments
  INSERT INTO  REHAB_RedundancyTableWhole
  SELECT 
          0,              [UsNode],       [DsNode],       ID,
          [CompKey],      [Length],       [DiamWidth],    [Height],
          [pipeshape],    [Material],     [Instdate],     NULL,
          /*[HServStat]*/NULL,    GLOBALID,       0,              NULL,
          [CutNO],        [FM],           [TO_],          [SegLen],
          '',             0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           NULL,           NULL,           NULL,
          NULL,           0,              0,              0,
          0,              0,              0,              0, 
          0,              0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0,
          0,              0,              0,              0
  FROM    @tvp2 
  WHERE   ID < @MinimumSegmentID 
END

-----------------------------------------------------------------------
--UPDATE HServStat with current Hansen values
UPDATE  dbo.REHAB_RedundancyTable
SET     HServStat = ServStat
FROM    dbo.REHAB_RedundancyTable
        INNER JOIN 
        HA8_COMPSMN
        ON  dbo.REHAB_RedundancyTable.Compkey = HA8_COMPSMN.Compkey
        
UPDATE  dbo.REHAB_RedundancyTableWhole
SET     HServStat = ServStat
FROM    dbo.REHAB_RedundancyTableWhole
        INNER JOIN 
        HA8_COMPSMN
        ON  dbo.REHAB_RedundancyTableWhole.Compkey = HA8_COMPSMN.Compkey

UPDATE  dbo.REHAB_RedundancyTable
SET     HServStat = ServStat
FROM    dbo.REHAB_RedundancyTable
        INNER JOIN 
        HA8_COMPSTMN
        ON  dbo.REHAB_RedundancyTable.Compkey = HA8_COMPSTMN.Compkey
        
UPDATE  dbo.REHAB_RedundancyTableWhole
SET     HServStat = ServStat
FROM    dbo.REHAB_RedundancyTableWhole
        INNER JOIN 
        HA8_COMPSTMN
        ON  dbo.REHAB_RedundancyTableWhole.Compkey = HA8_COMPSTMN.Compkey


-----------------------------------------------------------------------
--Empty Conversion1
TRUNCATE TABLE  REHAB_Conversion1

-----------------------------------------------------------------------
--Fill Conversion1 with all of the valid sanitary inspections for structural
--and lateral damage


INSERT INTO  REHAB_Conversion1 
SELECT C2.COMPKEY AS COMPKEY,
       C2.INSPKEY AS INSPKEY, 
       CASE WHEN (
                   C3.OBKEY = @CODE_SEWERBROKENPIPE 
                   OR 
                   C3.OBKEY = @CODE_SEWERBRICKWORK 
                   OR 
                   C3.OBKEY = @CODE_SEWERCRACK 
                   OR 
                   C3.OBKEY = @CODE_SEWERSTRUCTURALDAMAGE 
                   OR 
                   C3.OBKEY = @CODE_SEWERJOINTDEFECTS 
                 ) 
            THEN OBRATING 
            ELSE 0
       END AS NewScore, 
       DISTFROM AS convert_setdwn_from, 
       DISTTO AS convert_setdwn_to, 
       null AS ReadingKey, 
       STARTDTTM,   COMPDTTM,  INSTDATE,   OBSEVKEY, 
       OBKEY,       INDEXVAL,       OWN,   UnitType,
       ServStat
FROM   (
         HA8_COMPSMN AS C1 
         INNER JOIN 
         (
           HA8_SMNSERVICEINSP AS C2 
           INNER JOIN 
           HA8_SMNSERVINSPOB AS C3
           ON  C2.INSPKEY=C3.INSPKEY
         ) 
         ON  C1.COMPKEY=C2.COMPKEY
        ) 
        INNER JOIN 
        HA8_SMNINDHIST AS C4 
        ON  C3.INSPKEY = C4.INSPKEY 
            AND 
            INDEXKEY = @CODE_SEWERINSPNDXKEY
WHERE   STARTDTTM <= @AsOfDate
        AND
        C2.COMPKEY IN (SELECT COMPKEY FROM @tvp2);

-----------------------------------------------------------------------
--Empty Conversion2
TRUNCATE TABLE  REHAB_Conversion2

-----------------------------------------------------------------------
--Fill Conversion2 with all of the valid storm inspections for structural
--and lateral damage
INSERT INTO  REHAB_Conversion2 
SELECT  C2.COMPKEY AS COMPKEY,
        C2.INSPKEY AS INSPKEY, 
        CASE WHEN  (
                     C3.OBKEY = @CODE_STORMBROKENPIPE 
                     OR 
                     C3.OBKEY = @CODE_STORMBRICKWORK 
                     OR 
                     C3.OBKEY = @CODE_STORMCRACK 
                     OR 
                     C3.OBKEY = @CODE_STORMSTRUCTURALDAMAGE 
                     OR 
                     C3.OBKEY = @CODE_STORMJOINTDEFECTS 
                   ) 
             THEN OBRATING 
             ELSE 0 
        END AS NewScore, 
        DISTFROM AS convert_setdwn_from, 
        DISTTO AS convert_setdwn_to, 
        null AS ReadingKey, 
        STARTDTTM,  COMPDTTM,  INSTDATE,  OBSEVKEY,
        OBKEY,      INDEXVAL,       OWN,  UnitType,
        ServStat
FROM    (
          HA8_COMPSTMN AS C1 
          INNER JOIN 
          (
            HA8_STMNSERVICEINSP AS C2 
            INNER JOIN 
            HA8_STMNSERVINSPOB AS C3
            ON  C2.INSPKEY=C3.INSPKEY
          ) 
          ON  C1.COMPKEY=C2.COMPKEY
        ) 
        INNER JOIN 
        HA8_STMNINDHIST AS C4 
        ON  C3.INSPKEY = C4.INSPKEY 
            AND 
            INDEXKEY = @CODE_STORMINSPNDXKEY
WHERE   STARTDTTM <= @AsOfDate;

-----------------------------------------------------------------------
--Empty Conversion3
TRUNCATE TABLE  REHAB_Conversion3

-----------------------------------------------------------------------
--Fill Conversion3 with only the latest inspection dates for sanitary pipes
INSERT INTO  REHAB_Conversion3 SELECT COMPKEY, MAX(STARTDTTM) AS MaxDates
       FROM  REHAB_Conversion1
       GROUP BY COMPKEY;

-----------------------------------------------------------------------
--Empty Conversion4
TRUNCATE TABLE  REHAB_Conversion4

-----------------------------------------------------------------------
--Fill Conversion4 with only the latest inspection dates for storm pipes
INSERT INTO  REHAB_Conversion4 SELECT COMPKEY, MAX(STARTDTTM) AS MaxDates
       FROM  REHAB_Conversion2
       GROUP BY COMPKEY;

-----------------------------------------------------------------------
--Empty Conversion5
TRUNCATE TABLE  REHAB_Conversion5

-----------------------------------------------------------------------
--Fill Conversion5 with all of the data from the latest inspection dates for sanitary pipes
INSERT INTO  REHAB_Conversion5 
SELECT  REHAB_Conversion1.*
FROM    REHAB_Conversion1, REHAB_Conversion3
WHERE   REHAB_Conversion1.COMPKEY = REHAB_Conversion3.COMPKEY 
        AND  
        REHAB_Conversion1.StartDTTM = REHAB_Conversion3.MaxDates;

-----------------------------------------------------------------------
--Empty Conversion6
TRUNCATE TABLE  REHAB_Conversion6

-----------------------------------------------------------------------
--Fill Conversion6 with all of the data from the latest inspection dates for storm pipes
INSERT INTO  REHAB_Conversion6 
SELECT  REHAB_Conversion2.*
FROM    REHAB_Conversion2,  REHAB_Conversion4
WHERE   REHAB_Conversion2.COMPKEY = REHAB_Conversion4.COMPKEY 
        AND 
        REHAB_Conversion2.StartDTTM = REHAB_Conversion4.MaxDates;

-----------------------------------------------------------------------
--Empty Conversion
TRUNCATE TABLE  REHAB_CONVERSION

-----------------------------------------------------------------------
--Fill Conversion with the combined data from Conversion6 and Conversion5
INSERT INTO  REHAB_CONVERSION 
SELECT  A.*
FROM    (
          SELECT  *
          FROM    REHAB_Conversion5
          UNION ALL 
          SELECT  * 
          FROM    REHAB_Conversion6
        )AS A

-----------------------------------------------------------------------
--Empty the point defect table
TRUNCATE TABLE  REHAB_point_defect_group

-----------------------------------------------------------------------
--Fill the table of point defect groups and give the last segment all of the point defects 
--that run off the end of the virtual pipes extents.  Some inspections are given distance
--values that are greater than the length of the pipe.  Applying these inspections to the last 
--segment is a way of capturing these point defects.
INSERT INTO  REHAB_point_defect_group 
SELECT  REHAB_RedundancyTable.CompKey,  
        REHAB_RedundancyTable.CutNO,  
        REHAB_RedundancyTable.FM,  
        REHAB_RedundancyTable.[TO], 
        --ISNULL (Sum(REHAB_CONVERSION.NewScore),0) AS SumOfNewScore 
        ISNULL(SUM(REHAB_PeakScore_Lookup.Peak_Score),0) AS SumOfNewScore 
FROM    REHAB_CONVERSION 
        INNER JOIN  
        REHAB_RedundancyTable 
        ON  REHAB_CONVERSION.compkey = REHAB_RedundancyTable.CompKey
        INNER JOIN
        REHAB_PeakScore_Lookup
        ON  REHAB_CONVERSION.OBSEVKEY =  REHAB_PeakScore_Lookup.OBSEVKEY
WHERE   (
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
GROUP BY  REHAB_RedundancyTable.CompKey,  
          REHAB_RedundancyTable.CutNO,  
          REHAB_RedundancyTable.FM,  
          REHAB_RedundancyTable.[TO]
ORDER BY  REHAB_RedundancyTable.CompKey,  
          REHAB_RedundancyTable.CutNO;

-----------------------------------------------------------------------
--Empty the linear defect table
TRUNCATE TABLE  REHAB_linear_defect_groupbysegment

-----------------------------------------------------------------------
--Fill the table of linear defects.  Currently the linear defects that extend
--beyond the last segment are not applied to the last segment, although
--that should be considered.
--Connect  REHAB_RedundancyTable and TABLE A by compkey, FM, convert_setdwn_from, [TO], and convert_setdwn_to.
INSERT INTO  REHAB_linear_defect_groupbysegment 
SELECT  B.CompKey,
        B.CutNO, 
        B.[TO], 
        B.FM, 
        Sum(newScore) AS SumOfNewScore 
FROM    (
          SELECT  M.CompKey, 
                  M.CutNO, 
                  M.[TO], 
                  M.FM, 
                  (
                    CASE WHEN (
                                M.FM >= A.convert_setdwn_from 
                                AND 
                                M.[TO] <= A.convert_setdwn_to
                              ) 
                         THEN [Length] * A.peak_score 
                         ELSE 
                           CASE WHEN (
                                       M.FM < A.convert_setdwn_from 
                                       AND 
                                       M.[TO] > A.convert_setdwn_to
                                     ) 
                                THEN (A.convert_setdwn_to - A.convert_setdwn_from) * A.peak_score 
                                ELSE 
                                  CASE WHEN (
                                              M.[TO] > A.convert_setdwn_to
                                             ) 
                                       THEN (A.convert_setdwn_to - M.[FM]) * A.peak_score 
                                       ELSE
                                         CASE WHEN (
                                                     M.FM < A.convert_setdwn_from
                                                   ) 
                                              THEN (M.[TO] - A.convert_setdwn_from) * A.peak_score 
                                              ELSE 0
                                         END 
                                  END 
                           END 
                    END
                  ) AS newScore
          FROM    REHAB_RedundancyTable AS M 
                  INNER JOIN 
                  (
                    SELECT  compkey, 
                            convert_setdwn_from, 
                            convert_setdwn_to,  
                            REHAB_CONVERSION.OBSEVKEY, 
                            peak_score 
                    FROM    REHAB_CONVERSION 
                            INNER JOIN  
                            REHAB_PeakScore_Lookup 
                            ON  REHAB_CONVERSION.OBSEVKEY =  REHAB_PeakScore_Lookup.OBSEVKEY
                  ) AS A 
                  ON  M.Compkey = A.Compkey
          WHERE /*(CutNo = Seg_Count AND convert_setdwn_to>= M.[to]) OR*/ 
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
        ) AS B 
GROUP BY  B.CompKey, 
          B.CutNO, 
          B.FM, 
          B.[TO]

----------------------------------------------------------------------------
--Apply the point defect scores to the segments in the redundancy table
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Point_Defect_Score = ISNULL(SumOfNewScore, 0) 
FROM    REHAB_point_defect_group 
        INNER JOIN  
        REHAB_RedundancyTable 
        ON  REHAB_point_defect_group.CompKey = REHAB_RedundancyTable.CompKey 
            AND 
            REHAB_point_defect_group.CutNO = REHAB_RedundancyTable.CutNO

UPDATE REHAB_RedundancyTableWhole
SET     REHAB_RedundancyTableWhole.Point_Defect_Score = Score
FROM    (
          SELECT  COMPKEY, SUM(ISNULL(SumOfNewScore, 0)) AS Score
          FROM    REHAB_point_defect_group 
          GROUP BY CompKey
        ) AS A 
        INNER JOIN  
        REHAB_RedundancyTableWhole 
        ON  A.CompKey = REHAB_RedundancyTableWhole.CompKey  

-------------------------------------------------------------------------------
--Apply the linear defect scores to the segments in the redundancy table
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Linear_Defect_Score = ISNULL(SumOfNewScore, 0)
FROM    REHAB_linear_defect_groupbysegment 
        INNER JOIN  
        REHAB_RedundancyTable 
        ON  REHAB_linear_defect_groupbysegment.CompKey = REHAB_RedundancyTable.CompKey
            AND
            REHAB_linear_defect_groupbysegment.CutNO = REHAB_RedundancyTable.CutNO
            
UPDATE  REHAB_RedundancyTableWhole
SET     REHAB_RedundancyTableWhole.Linear_Defect_Score = A.Score
FROM    (
          SELECT  COMPKEY, SUM(ISNULL(SumOfNewScore, 0)) AS Score
          FROM    REHAB_linear_defect_groupbysegment 
          GROUP BY CompKey
        ) AS A
        INNER JOIN  
        REHAB_RedundancyTableWhole 
        ON  A.CompKey = REHAB_RedundancyTableWhole.CompKey

-------------------------------------------------------------------------------
--Give segments that have a null value for point or linear defect score a zero.
--The old way was faster, but this way makes the code appear cleaner
--and only takes 2 seconds for the entire db.  This query is really not much different
--from the 2 preceding it, but this ensures 0 scores for segments and pipes that 
--didn’t get a score due to not being in the inspection records.
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Point_defect_score = ISNULL(REHAB_RedundancyTable.Point_defect_score, 0),
        REHAB_RedundancyTable.Linear_defect_score = ISNULL(REHAB_RedundancyTable.Linear_defect_score, 0)
        
UPDATE  REHAB_RedundancyTableWhole
SET     REHAB_RedundancyTableWhole.Point_defect_score = ISNULL(REHAB_RedundancyTableWhole.Point_defect_score, 0),
        REHAB_RedundancyTableWhole.Linear_defect_score = ISNULL(REHAB_RedundancyTableWhole.Linear_defect_score, 0)

--------------------------------------------------------------------------------
--Set the total defect score for segments equal to the sum of the linear defect
--score and the point defect score
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Total_defect_score = [Point_defect_score]+[Linear_defect_score]

UPDATE  REHAB_RedundancyTableWhole
SET     REHAB_RedundancyTableWhole.Total_defect_score = [Point_defect_score]+[Linear_defect_score]

---------------------------------------------------------------------------------
--If the user is guiding this calc session, update any scores they want changed
/*UPDATE  dbo.REHAB_RedundancyTable
SET     REHAB_RedundancyTable.Total_defect_score = NewScore
FROM    dbo.REHAB_RedundancyTable AS A
        INNER JOIN
        dbo.REHAB_USERVARIABLES_NewScore AS B
        ON  A.GLOBALID = B.GLOBALID
            AND
            A.CutNO = B.Cutno*/
--------------------------------------------------------------------------------
--Set the last tv inspection and inspection grade to be the date and grade stated 
--in the conversion table.  Set Years_Since_Inspection as well, even though 
--technically Years_Since_Inspection should be part of a view.  Report year is a 
--variable, but has often been referred to as 2010
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Last_TV_Inspection = [STARTDTTM],
        REHAB_RedundancyTable.Years_Since_Inspection = @REPORT_YEAR-Year([STARTDTTM]),
        REHAB_RedundancyTable.RATING = REHAB_CONVERSION.[RATING]
FROM    REHAB_CONVERSION 
        INNER JOIN  
        REHAB_RedundancyTable 
        ON  REHAB_CONVERSION.COMPKEY = REHAB_RedundancyTable.COMPKEY
        
UPDATE  REHAB_RedundancyTableWhole
SET     REHAB_RedundancyTableWhole.Last_TV_Inspection = [STARTDTTM],
        REHAB_RedundancyTableWhole.Years_Since_Inspection = @REPORT_YEAR-Year([STARTDTTM]),
        REHAB_RedundancyTableWhole.RATING = REHAB_CONVERSION.[RATING]
FROM    REHAB_CONVERSION 
        INNER JOIN  
        REHAB_RedundancyTableWhole 
        ON  REHAB_CONVERSION.COMPKEY = REHAB_RedundancyTableWhole.COMPKEY


-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 1 for pipes for the following cases:
--  I: install date is before the inspection date
-- II: install date is NULL, but inspection date is not NULL
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.INSP_CURR = @InspectionFlag_InspectionDateIsNotNullAndInstallDateIsLessThanInspectionDateOrNullOrServstatIsPEND
FROM    REHAB_RedundancyTable 
WHERE   REHAB_RedundancyTable.Last_TV_Inspection >= REHAB_RedundancyTable.Instdate
        OR 
        ( 
          REHAB_RedundancyTable.Last_TV_Inspection Is Not Null 
          AND 
          REHAB_RedundancyTable.Instdate Is Null
        )
        OR
        HServStat = @HSERVSTAT_PEND
       

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 2 for pipes for the following cases:
--  I: install date is null and servstat is 'TBAB'
-- II: install date is null and servstat is 'ABAN'
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.INSP_CURR = @InspectionFlag_InstallDateIsNullAndServstatIsTBABOrABAN 
FROM    REHAB_RedundancyTable AS A
WHERE   A.instdate Is Null 
        AND 
        (
          A.hservstat Like @HSERVSTAT_TBAB
          OR 
          A.hservstat Like @HSERVSTAT_ABAN
        )

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 3 for pipes for the following cases:
--  I: install date is after the last inspection
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.INSP_CURR = @InspectionFlag_InstallDateIsAfterLastInspection
FROM    REHAB_RedundancyTable AS A
WHERE   A.instdate > A.Last_TV_Inspection 
        --OR 
        --A.hservstat Like @HSERVSTAT_PEND

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 4 for pipes for the following cases:
--  I: last tv inpsection date is NULL
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.INSP_CURR = @InspectionFlag_InspectionDateIsNULL
FROM    REHAB_RedundancyTable AS A
WHERE   A.Last_TV_Inspection Is Null

UPDATE REHAB_RedundancyTableWhole
SET    REHAB_RedundancyTableWhole.Insp_Curr = REHAB_RedundancyTable.Insp_Curr
FROM   REHAB_RedundancyTableWhole
       INNER JOIN
       REHAB_RedundancyTable
       ON REHAB_RedundancyTable.CompKey = REHAB_RedundancyTableWhole.CompKey

-------------------------------------------------------------------------------
--Empty the Varies table for the segments
TRUNCATE TABLE  REHAB_MLA_05FtBrk_VariesTable

-------------------------------------------------------------------------------
--Fill the varies table with all of the segments that have a material
--type of 'VARIES'
INSERT INTO  REHAB_MLA_05FtBrk_VariesTable 
SELECT  *
FROM    REHAB_RedundancyTable
WHERE   Material like @STRING_VARIES

-------------------------------------------------------------------------------
--Empty the material changes table
TRUNCATE TABLE  REHAB_Material_Changes

-------------------------------------------------------------------------------
--Fill the material changes table with all of the segments that have 
--been identified as having a material change.  This is an unfortunate
--table since currently the only way to update is is manually
INSERT INTO  REHAB_Material_Changes 
SELECT  *
FROM    REHAB_Attribute_changes_ac
WHERE   CHTYPE like @STRING_MATERIAL

-------------------------------------------------------------------------------
--Empty the pipes with VSP table
TRUNCATE TABLE  REHAB_AA_Records_With_VSP

-------------------------------------------------------------------------------
--Place pipes that have VSP in them into the 'Records_with_VSP' table
INSERT INTO  REHAB_AA_Records_With_VSP 
SELECT  REHAB_RedundancyTable.ID,  
        REHAB_RedundancyTable.Compkey,  
        REHAB_RedundancyTable.FM,  
        REHAB_Attribute_changes_ac.DISTFROM,  
        REHAB_RedundancyTable.[TO],  
        REHAB_Attribute_changes_ac.DISTTO,  
        REHAB_Attribute_changes_ac.CHDETAIL 
FROM    REHAB_RedundancyTable
        INNER JOIN  
        REHAB_Attribute_changes_ac
        ON  REHAB_RedundancyTable.COMPKEY = REHAB_Attribute_changes_ac.COMPKEY
WHERE   REHAB_RedundancyTable.Compkey = REHAB_Attribute_changes_ac.Compkey 
        AND 
        (
          (
            REHAB_RedundancyTable.FM >= REHAB_Attribute_changes_ac.DISTFROM 
            AND  
            REHAB_RedundancyTable.[TO] <= REHAB_Attribute_changes_ac.DISTTO
          ) 
          OR 
          ( 
            REHAB_RedundancyTable.FM <= REHAB_Attribute_changes_ac.DISTFROM 
            AND  
            REHAB_RedundancyTable.[TO] >= REHAB_Attribute_changes_ac.DISTFROM
          ) 
          OR 
          ( 
            REHAB_RedundancyTable.FM <= REHAB_Attribute_changes_ac.DISTTO 
            AND  
            REHAB_RedundancyTable.[TO] >= REHAB_Attribute_changes_ac.DISTTO
          )
        ) 
        AND  
        CHDETAIL Like @STRING_MATVSP
        AND 
        CHTYPE like @STRING_MATERIAL
        AND
        REHAB_RedundancyTable.Material like @STRING_VARIES
        

-------------------------------------------------------------------
--Remove the records from the 'records_that_patch_vsp' table
TRUNCATE TABLE  REHAB_AB_Records_That_Patch_VSP

-------------------------------------------------------------------
--Gets all of the 'jellybeans' that are in a pipe that has been 
--designated as having VSP materials associated with it.
INSERT INTO  REHAB_AB_Records_That_Patch_VSP 
SELECT  REHAB_RedundancyTable.ID,  
        REHAB_RedundancyTable.Compkey,  
        REHAB_RedundancyTable.FM,  
        REHAB_Attribute_changes_ac.DISTFROM,  
        REHAB_RedundancyTable.[TO],  
        REHAB_Attribute_changes_ac.DISTTO,  
        REHAB_Attribute_changes_ac.CHDETAIL 
FROM    REHAB_RedundancyTable
        INNER JOIN 
        REHAB_Attribute_changes_ac
        ON  REHAB_RedundancyTable.COMPKEY = REHAB_Attribute_changes_ac.COMPKEY
WHERE   REHAB_Attribute_changes_ac.Compkey  
        IN 
        (
          SELECT  Compkey 
          FROM    REHAB_AA_Records_With_VSP
        ) 
        AND 
        REHAB_RedundancyTable.Compkey = REHAB_Attribute_changes_ac.Compkey 
        AND
        (
          (
            REHAB_RedundancyTable.FM >= REHAB_Attribute_changes_ac.DISTFROM 
            AND 
            REHAB_RedundancyTable.[TO] <= REHAB_Attribute_changes_ac.DISTTO
          ) 
          OR 
          (
            REHAB_RedundancyTable.FM <= REHAB_Attribute_changes_ac.DISTFROM 
            AND 
            REHAB_RedundancyTable.[TO] >= REHAB_Attribute_changes_ac.DISTFROM
          ) 
          OR 
          (
            REHAB_RedundancyTable.FM <= REHAB_Attribute_changes_ac.DISTTO 
            AND 
            REHAB_RedundancyTable.[TO] >= REHAB_Attribute_changes_ac.DISTTO
          )
        ) 
        AND 
        REHAB_Attribute_changes_ac.CHDETAIL Not Like @STRING_MATVSP
        AND
        CHTYPE like @STRING_MATERIAL
        AND 
        Material like @STRING_VARIES

------------------------------------------------------------------------
--Empty the remaining records table.
TRUNCATE TABLE  REHAB_AC_Remaining_Records

------------------------------------------------------------------------
--This query is used for finding the records that have 'varies'
--but do not have any VSP
INSERT INTO  REHAB_AC_Remaining_Records 
SELECT  REHAB_RedundancyTable.CompKey 
FROM    REHAB_RedundancyTable 
        LEFT JOIN  
        REHAB_AA_Records_With_VSP 
        ON  REHAB_RedundancyTable.CompKey = REHAB_AA_Records_With_VSP.Compkey
WHERE   REHAB_AA_Records_With_VSP.Compkey Is Null
        AND
        Material like @STRING_VARIES
GROUP BY  REHAB_RedundancyTable.Compkey

------------------------------------------------------------------------
--Empty the table 'Records_with_no_vsp'
TRUNCATE TABLE  REHAB_AD_Records_With_No_VSP

------------------------------------------------------------------------
--Place the records that have no VSP at all in the Records_with_no_vsp table
INSERT INTO  REHAB_AD_Records_With_No_VSP 
SELECT  REHAB_RedundancyTable.ID,  
        REHAB_RedundancyTable.Compkey,  
        REHAB_RedundancyTable.FM,  
        REHAB_Attribute_changes_ac.DISTFROM,  
        REHAB_RedundancyTable.[TO],  
        REHAB_Attribute_changes_ac.DISTTO,  
        REHAB_Attribute_changes_ac.CHDETAIL 
FROM    REHAB_RedundancyTable
        INNER JOIN  
        REHAB_Attribute_changes_ac
        ON  REHAB_RedundancyTable.COMPKEY = REHAB_Attribute_changes_ac.COMPKEY
WHERE   REHAB_Attribute_changes_ac.Compkey 
        IN 
        (
          SELECT  Compkey 
          FROM    REHAB_AC_Remaining_Records
        ) 
        AND 
        REHAB_RedundancyTable.Compkey = REHAB_Attribute_changes_ac.Compkey 
        AND 
        (
          (
            REHAB_RedundancyTable.FM >= REHAB_Attribute_changes_ac.DISTFROM 
            AND 
            REHAB_RedundancyTable.[TO] <= REHAB_Attribute_changes_ac.DISTTO
          ) 
          OR 
          (
            REHAB_RedundancyTable.FM <= REHAB_Attribute_changes_ac.DISTFROM 
            AND 
            REHAB_RedundancyTable.[TO] >= REHAB_Attribute_changes_ac.DISTFROM
          ) 
          OR 
          (
            REHAB_RedundancyTable.FM <= REHAB_Attribute_changes_ac.DISTTO 
            AND
            REHAB_RedundancyTable.[TO] >= REHAB_Attribute_changes_ac.DISTTO
          )
        )
        AND
        REHAB_Attribute_changes_ac.CHTYPE like @STRING_MATERIAL
        AND 
        Material like @STRING_VARIES

--------------------------------------------------------------------------------------------
--Stamps original VSP 'jellybeans' as original VSP 'jellybeans'.
UPDATE  REHAB_RedundancyTable 
SET     MATERIAL = @STRING_ORIGINALLYVSP--'1_VSP'
WHERE   ID 
        IN 
        (--AA Table Replaced
          SELECT  REHAB_RedundancyTable.ID
          FROM    REHAB_RedundancyTable
                  INNER JOIN 
                  REHAB_Attribute_changes_ac
                  ON  REHAB_RedundancyTable.COMPKEY = REHAB_Attribute_changes_ac.COMPKEY
          WHERE   REHAB_RedundancyTable.Compkey = REHAB_Attribute_changes_ac.Compkey 
                  AND 
                  (
                    (
                      REHAB_RedundancyTable.FM >= REHAB_Attribute_changes_ac.DISTFROM 
                      AND  
                      REHAB_RedundancyTable.[TO] <= REHAB_Attribute_changes_ac.DISTTO
                    ) 
                    OR 
                    ( 
                      REHAB_RedundancyTable.FM <= REHAB_Attribute_changes_ac.DISTFROM 
                      AND  
                      REHAB_RedundancyTable.[TO] >= REHAB_Attribute_changes_ac.DISTFROM
                    ) 
                    OR 
                    ( 
                      REHAB_RedundancyTable.FM <= REHAB_Attribute_changes_ac.DISTTO 
                      AND  
                      REHAB_RedundancyTable.[TO] >= REHAB_Attribute_changes_ac.DISTTO
                    )
                  ) 
                  AND  
                  CHDETAIL Like @STRING_MATVSP
                  AND 
                  CHTYPE like @STRING_MATERIAL
                  AND
                  Material like @STRING_VARIES
        )

--------------------------------------------------------------------------------------------
--Stamps secondary materials of VSP pipes as secondary material 'jellybeans'
UPDATE  REHAB_MLA_05FtBrk_VariesTable
SET     MATERIAL = @ReplacingMaterialPrefix + replace(CHDETAIL,@STRING_SEARCHMATERIALPREFIX,@STRING_EMPTYSTRING) 
FROM    REHAB_MLA_05FtBrk_VariesTable
        INNER JOIN  
        REHAB_AB_Records_That_Patch_VSP 
        ON  REHAB_MLA_05FtBrk_VariesTable.ID = REHAB_AB_Records_That_Patch_VSP.ID

-------------------------------------------------------------------------------------------
--Empty the longest material per compkey table
TRUNCATE TABLE  REHAB_Longest_Material_Per_Compkey

--------------------------------------------------------------------------------------------
--since we don't know what the primary material of non-VSP pipes would be 
--considered, we just assume that the longest
--material in the pipe is the primary material.
INSERT INTO  REHAB_Longest_Material_Per_Compkey 
SELECT  MAX_TABLE.COMPKEY, 
        MAX_TABLE.MAX_LENGTHS, 
        ALL_LENGTHS.CHDETAIL 
FROM    (
          SELECT  COMPKEY, 
                  MAX(SUM_LENGTHS) AS MAX_LENGTHS
          FROM    (
                    SELECT  COMPKEY, 
                            CHDETAIL, 
                            SUM(ABS(DISTTO-DISTFROM)) AS SUM_LENGTHS
                    FROM    REHAB_Attribute_changes_ac
                    WHERE   CHTYPE like @STRING_MATERIAL
                    GROUP BY  COMPKEY, 
                              CHDETAIL
                  ) AS A
          GROUP BY COMPKEY
        ) AS MAX_TABLE 
        INNER JOIN 
        (
          SELECT  COMPKEY, 
                  CHDETAIL,
                  SUM(ABS(DISTTO-DISTFROM)) AS SUM_LENGTHS
          FROM    REHAB_Attribute_changes_ac
          WHERE   CHTYPE like @STRING_MATERIAL
          GROUP BY  COMPKEY,
                    CHDETAIL
        ) AS ALL_LENGTHS
        ON  ALL_LENGTHS.COMPKEY = MAX_TABLE.COMPKEY 
            AND 
            MAX_TABLE.MAX_LENGTHS = ALL_LENGTHS.SUM_LENGTHS

-------------------------------------------------------------------------------------------
--Empty out the table that tracks pipes whose primary materials are not VSP
TRUNCATE TABLE  REHAB_NON_VSP_PRIMARIES

-------------------------------------------------------------------------------------------
--Pipes that do not have vsp primaries are pipes that do not contain vsp, 
--this may not always be the case, but it is the rule that
--we assume that all pipes that contain VSP started out as VSP

--!ATTENTION! This query may be better designed using only 
--redundancy table and REHAB_AA_Records_With_VSP
INSERT INTO  REHAB_NON_VSP_PRIMARIES 
SELECT  ID,
        REHAB_AD_Records_With_No_VSP.CHDETAIL AS CHDETAIL 
FROM    REHAB_Longest_Material_Per_Compkey
        INNER JOIN
        REHAB_AD_Records_With_No_VSP
        ON  REHAB_Longest_Material_Per_Compkey.Compkey = REHAB_AD_Records_With_No_VSP.Compkey 
            AND  
            REHAB_Longest_Material_Per_Compkey.CHDETAIL = REHAB_AD_Records_With_No_VSP.CHDETAIL

-------------------------------------------------------------------------------------------
--Update the material column for primary materials that are not VSP
--(Because we already did the VSP primaries about 5 queries ago)
UPDATE  REHAB_MLA_05FtBrk_VariesTable 
SET     REHAB_MLA_05FtBrk_VariesTable.MATERIAL = @OriginalMaterialPrefix + replace(CHDETAIL,@STRING_SEARCHMATERIALPREFIX,@STRING_EMPTYSTRING) 
FROM    REHAB_MLA_05FtBrk_VariesTable 
        INNER JOIN  
        REHAB_NON_VSP_PRIMARIES 
        ON  REHAB_MLA_05FtBrk_VariesTable.ID = REHAB_NON_VSP_PRIMARIES.ID

-------------------------------------------------------------------------------------------
--Update the material column for secondary materials.  
UPDATE  REHAB_MLA_05FtBrk_VariesTable 
SET     REHAB_MLA_05FtBrk_VariesTable.MATERIAL = @ReplacingMaterialPrefix + replace(CHDETAIL,@STRING_SEARCHMATERIALPREFIX,@STRING_EMPTYSTRING)
FROM    REHAB_MLA_05FtBrk_VariesTable 
        INNER JOIN  
        REHAB_AD_Records_With_No_VSP 
        ON  REHAB_MLA_05FtBrk_VariesTable.ID = REHAB_AD_Records_With_No_VSP.ID 
WHERE   REHAB_MLA_05FtBrk_VariesTable.MATERIAL like @STRING_VARIES

-------------------------------------------------------------------------------------------
--Update all the Materials in REHAB_RedundancyTable to match the corresponding entries 
--in the REHAB_MLA_05FtBrk_VariesTable.  
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.MATERIAL = REHAB_MLA_05FtBrk_VariesTable.MATERIAL 
FROM    REHAB_RedundancyTable 
        INNER JOIN  
        REHAB_MLA_05FtBrk_VariesTable 
        ON  REHAB_MLA_05FtBrk_VariesTable.ID = REHAB_RedundancyTable.ID

-------------------------------------------------------------------------------------------
--Get the estimated remaining useful life of a pipe segment based on the scores and material of the current segment
TRUNCATE TABLE  REHAB_RemainingYearsTable

-------------------------------------------------------------------------------------------
--Update the remaining years table based upon the segment material and the score of the pipe.
INSERT INTO  REHAB_RemainingYearsTable 
SELECT  REHAB_RedundancyTable.ID, 
        CONVERT(INT,  REHAB_tblRemainingUsefulLifeLookup.YearsToFailure) AS YearsToFailure 
FROM    REHAB_tblRemainingUsefulLifeLookup,  
        REHAB_RedundancyTable,  
        REHAB_tblPipeTypeRosetta
WHERE   ( 
          REHAB_RedundancyTable.Total_Defect_Score >= REHAB_tblRemainingUsefulLifeLookup.Score_Lower_Bound 
          AND  
          REHAB_RedundancyTable.Total_Defect_Score < REHAB_tblRemainingUsefulLifeLookup.Score_Upper_Bound
        ) 
        AND  
        REHAB_RedundancyTable.Material = REHAB_tblPipeTypeRosetta.[Hansen Material] 
        AND  
        REHAB_tblPipeTypeRosetta.[Useful Life Curve] = REHAB_tblRemainingUsefulLifeLookup.Material

-------------------------------------------------------------------------------------------
--Set the estimated failure year based upon whether or not the inspection date is useful 
--information.  
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Failure_Year = YEAR(DateAdd("yyyy", REHAB_RemainingYearsTable.YearsToFailure, REHAB_RedundancyTable.Last_TV_Inspection)) 
FROM    REHAB_RedundancyTable 
        INNER JOIN  
        REHAB_RemainingYearsTable 
        ON  REHAB_RedundancyTable.ID = REHAB_RemainingYearsTable.ID 
WHERE   REHAB_RedundancyTable.INSP_CURR = @InspectionFlag_InspectionDateIsNotNullAndInstallDateIsLessThanInspectionDateOrNullOrServstatIsPEND 
        OR 
        INSP_CURR = @InspectionFlag_InstallDateIsNullAndServstatIsTBABOrABAN
-------------------------------------------------------------------------------------------
--Update the standard deviation for segments based upon whether the segment has a useful 
--inspection date (INSP_CURR).  This is similar to the previous query, and could 
--probably be combined with it.
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.Std_dev = 
        CASE WHEN (@StandardDeviationFactor1* REHAB_RemainingYearsTable.YearsToFailure+@StandardDeviationFactor2* REHAB_RedundancyTable.Years_Since_Inspection) > @StandardDeviationMinimum_NoProblems 
             THEN (@StandardDeviationFactor1* REHAB_RemainingYearsTable.YearsToFailure+@StandardDeviationFactor2* REHAB_RedundancyTable.Years_Since_Inspection) 
             ELSE @StandardDeviationMinimum_NoProblems 
        END 
FROM    REHAB_RedundancyTable 
        INNER JOIN  
        REHAB_RemainingYearsTable 
        ON  REHAB_RedundancyTable.ID = REHAB_RemainingYearsTable.ID 
WHERE   REHAB_RedundancyTable.INSP_CURR = @InspectionFlag_InspectionDateIsNotNullAndInstallDateIsLessThanInspectionDateOrNullOrServstatIsPEND
        OR 
        INSP_CURR = @InspectionFlag_InstallDateIsNullAndServstatIsTBABOrABAN



-------------------------------------------------------------------------------------------
--Move everything below this to the end of USP_REHAB_02IDENTIFYSPOTREPAIRSFASTER_0
--UPDATE the consequence of failure for all pipes.


-------------------------------------------------------------------------------------------
--If the inspection is absolutely not current, then the Hansen rating for that pipe
--is absoluteley not valid.
UPDATE  REHAB_RedundancyTable 
SET     REHAB_RedundancyTable.RATING = 0 
WHERE   --Insp_Curr = @InspectionFlag_InstallDateIsAfterLastInspection
        --OR
        Insp_Curr = @InspectionFlag_InspectionDateIsNULL
        
UPDATE  REHAB_RedundancyTableWhole 
SET     REHAB_RedundancyTableWhole.RATING = REHAB_RedundancyTable.RATING
FROM    REHAB_RedundancyTableWhole
        INNER JOIN
        REHAB_RedundancyTable
        ON  REHAB_RedundancyTableWhole.CompKey = REHAB_RedundancyTable.Compkey

END





GO

