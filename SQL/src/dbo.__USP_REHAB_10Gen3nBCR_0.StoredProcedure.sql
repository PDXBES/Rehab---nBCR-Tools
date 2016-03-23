USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[__USP_REHAB_10Gen3nBCR_0]    Script Date: 03/23/2016 14:11:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[__USP_REHAB_10Gen3nBCR_0] 
AS
BEGIN
  SET NOCOUNT ON;
  
  DECLARE @unacceptableSurchargeFootage FLOAT = 4.0--1.0
  DECLARE @unacceptableOvallingFraction FLOAT = 0.1
  DECLARE @unacceptableSagFraction FLOAT = 0.1
  
  DECLARE @thisYear int = YEAR(GETDATE())
  DECLARE @SpotRotationFrequency int = 30
  DECLARE @EmergencyFactor float = 1.4
  DECLARE @StdDevWholePipeAt120Years int = 12
  DECLARE @MaxStdDev int = 12
  DECLARE @StdDevNewLiner int = 6
  DECLARE @RULNewWholePipe int = 120
  DECLARE @RULNewLiner int = 60
  DECLARE @LineAtYearNoSpots int = 30
  DECLARE @LineAtYearSpots int = 30
  DECLARE @StdDevNewSpot int = 4
  DECLARE @RULNewSpot int = 30
  DECLARE @HoursPerDay float = 8.0
  DECLARE @PresentValueCap float = 0.6
  
  CREATE TABLE #Costs
  (
    Compkey INT,
    NonMobCap FLOAT,
    Rate FLOAT,
    BaseTime FLOAT,
    MobTime FLOAT
  )
  
  
  TRUNCATE TABLE REHAB.GIS.REHAB_Branches
  
  INSERT INTO REHAB.GIS.REHAB_Branches(COMPKEY, [InitialFailYear], std_dev, ReplaceCost, SpotCost, /*LineCostwSpots,*/ LineCostNoSpots)
  SELECT  compkey, fail_yr, std_dev, replaceCost, SpotCost, /*LineCostNoSegsNoLats + SpotCost ,*/ LineCostNoSegsNoLats
  FROM    REHAB.GIS.REHAB_Segments AS A
  WHERE   cutno = 0
  
  --(1) Is the pipe surcharged? (Open cut or spot)
  --(2) Is the pipe sagging more than 10%? (OC only)
  --(3) Is the pipe ovaling more than 10% (OC only)
  --sagging and ovaling mean no present value of existing assets
  --surcharging may need some of its own modifications in the future
  
  
  --Surcharging
  UPDATE  A
  SET     problems = ISNULL(problems, '') + ', extensive surcharge'
  FROM    GIS.REHAB_Branches AS A
          INNER JOIN
          REHAB_SURCHARGE AS B
          ON  B.COMPKEY = A.COMPKEY
              AND
              CAST(B.USSurch AS FLOAT) >= @unacceptableSurchargeFootage
  
  --Sagging
  UPDATE  A
  SET     problems = ISNULL(problems, '') + ', extensive sagging'
FROM    GIS.REHAB_Branches AS A
INNER JOIN
(
SELECT A.*, B.[Length], A.LengthSag/B.[length] AS SagFraction
FROM
(
SELECT COMPKEY, SUM(SumOfLength) AS LengthSag
FROM
(
SELECT B.GlobalID, MAX(A.COMPKEY) AS COMPKEY, MAX(SumOfLength) AS SumOfLength
FROM
(
  SELECT  COMPKEY, 
          DISTFROM,
          SumOfLength
  FROM    
  (
    SELECT  A.COMPKEY, 
            A.COMPDTTM,
            Observations.DISTFROM, 
            Observations.DISTTO, 
            CASE 
              WHEN Observations.DISTTO - Observations.DISTFROM < 10 
              THEN 10 
              ELSE Observations.DISTTO - Observations.DISTFROM 
            END AS SumOfLength, 
            Observations.OBSEVKEY, 
            TypeOB.OBCODE, 
            TYPEOBSEV.SEVERITY
    FROM    
    (
       SELECT  COMPKEY, 
               Observations.INSPKEY, 
               COMPDTTM, 
               RANK() OVER(PARTITION BY COMPKEY ORDER BY COMPDTTM DESC) AS theRank, 
               COUNT(*) AS TheCount
       FROM    --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVICEINSP] AS InspHist
               HA8_SMNSERVICEINSP AS InspHist
               INNER JOIN
               --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPOB] AS Observations
               HA8_SMNSERVINSPOB AS Observations
               ON  InspHist.INSPKEY = Observations.INSPKEY
       GROUP BY COMPKEY, 
                Observations.INSPKEY, 
                COMPDTTM
    ) AS A
    INNER JOIN 
    --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPOB] AS Observations
    HA8_SMNSERVINSPOB AS Observations
    ON  A.INSPKEY = Observations.INSPKEY
        INNER JOIN
        --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPTYPEOB] AS TYPEOB
        HA8_SMNSERVINSPTYPEOB AS TYPEOB
        ON  TYPEOB.OBKEY = Observations.OBKEY
            INNER JOIN
            HA8_SMNSERVINSPTYPEOBSEV AS TYPEOBSEV
            ON  TYPEOBSEV.OBSEVKEY = Observations.OBSEVKEY
    WHERE   A.theRank = 1
  ) AS GroupDefects
  WHERE  GroupDefects.SEVERITY='A25' 
         OR 
         GroupDefects.SEVERITY='B50'
         OR 
         GroupDefects.SEVERITY='CUW'
) AS A
INNER JOIN 
[GIS].[REHAB_Segments] AS B 
ON  A.COMPKEY = B.COMPKEY
    AND 
    B.ID >= 40000000
    AND 
    B.fm <= A.DISTFROM
    AND
    B.to_ > A.DISTFROM
WHERE (
        remarks = 'BES'
        OR
        remarks = '_BES'
      )
GROUP BY GLOBALID
) AS X
GROUP BY COMPKEY
) AS A
INNER JOIN
[GIS].[REHAB_Segments] AS B
ON A.COMPKEY = B.compkey
AND B.ID < 40000000
WHERE A.LengthSag/B.[length] > @unacceptableSagFraction
) AS Results
ON Results.COMPKEY = A.COMPKEY

  --Ovaling
  UPDATE  A
  SET     problems = ISNULL(problems, '') + ', extensive ovaling'
FROM    GIS.REHAB_Branches AS A
INNER JOIN
(
SELECT A.*, B.[Length], A.LengthOval/B.[length] AS OvalFraction
FROM
(
SELECT COMPKEY, SUM(SumOfLength) AS LengthOval
FROM
(
SELECT B.GlobalID, MAX(A.COMPKEY) AS COMPKEY, MAX(SumOfLength) AS SumOfLength
FROM
(
  SELECT  COMPKEY, 
          DISTFROM,
          SumOfLength
  FROM    
  (
    SELECT  A.COMPKEY, 
            A.COMPDTTM,
            Observations.DISTFROM, 
            Observations.DISTTO, 
            CASE 
              WHEN Observations.DISTTO - Observations.DISTFROM < 10 
              THEN 10 
              ELSE Observations.DISTTO - Observations.DISTFROM 
            END AS SumOfLength, 
            Observations.OBSEVKEY, 
            TypeOB.OBCODE, 
            TYPEOBSEV.SEVERITY
    FROM    
    (
       SELECT  COMPKEY, 
               Observations.INSPKEY, 
               COMPDTTM, 
               RANK() OVER(PARTITION BY COMPKEY ORDER BY COMPDTTM DESC) AS theRank, 
               COUNT(*) AS TheCount
       FROM    --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVICEINSP] AS InspHist
               HA8_SMNSERVICEINSP AS InspHist
               INNER JOIN
               --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPOB] AS Observations
               HA8_SMNSERVINSPOB AS Observations
               ON  InspHist.INSPKEY = Observations.INSPKEY
       GROUP BY COMPKEY, 
                Observations.INSPKEY, 
                COMPDTTM
    ) AS A
    INNER JOIN 
    --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPOB] AS Observations
    HA8_SMNSERVINSPOB AS Observations
    ON  A.INSPKEY = Observations.INSPKEY
        INNER JOIN
        --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPTYPEOB] AS TYPEOB
        HA8_SMNSERVINSPTYPEOB AS TYPEOB
        ON  TYPEOB.OBKEY = Observations.OBKEY
            INNER JOIN
            --[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPTYPEOBSEV] AS TYPEOBSEV
            HA8_SMNSERVINSPTYPEOBSEV AS TYPEOBSEV
            ON  TYPEOBSEV.OBSEVKEY = Observations.OBSEVKEY
    WHERE   A.theRank = 1
  ) AS GroupDefects
  WHERE  GroupDefects.SEVERITY='BRKO' 
         OR 
         GroupDefects.SEVERITY='OS'
) AS A
INNER JOIN 
[GIS].[REHAB_Segments] AS B 
ON  A.COMPKEY = B.COMPKEY
    AND 
    B.ID >= 40000000
    AND 
    B.fm <= A.DISTFROM
    AND
    B.to_ > A.DISTFROM
WHERE (
        remarks = 'BES'
        OR
        remarks = '_BES'
      )
GROUP BY GLOBALID
) AS X
GROUP BY COMPKEY
) AS A
INNER JOIN
[GIS].[REHAB_Segments] AS B
ON A.COMPKEY = B.compkey
AND B.ID < 40000000
WHERE A.LengthOval/B.[length] > @unacceptableOvallingFraction
) AS Results
ON Results.COMPKEY = A.COMPKEY
  
  --Create present value table
  
  CREATE TABLE #PresentValue(Compkey int, WholePipe float, Liner float, Spot float, ReplaceCost float, LineCostNoSegsNoLats float, [Length] FLOAT)
  INSERT INTO #PresentValue (Compkey, ReplaceCost, LineCostNoSegsNoLats, [Length])
  SELECT  COMPKEY, ReplaceCost, LineCostNoSegsNoLats, [Length]
  FROM    REHAB.GIS.REHAB_Segments AS A
  WHERE   cutno = 0
  
  DECLARE @MaxWholeValue float = @PresentValueCap
  --Present value destroyed when replacing with a whole pipe
  UPDATE  A
  SET     WholePipe = CASE WHEN SumCost > @MaxWholeValue * ReplaceCost THEN ReplaceCost * @MaxWholeValue ELSE SumCost END
  FROM    #PresentValue AS A
          INNER JOIN
          (
            SELECT  COMPKEY, SUM((ReplaceCost*0.25) * CASE WHEN def_tot >= 1000 THEN 0 ELSE (1000.0-def_tot)/1000.0 END * CASE WHEN [action] = 3 THEN 0 ELSE 1 END) AS SumCost
            FROM    REHAB.GIS.REHAB_Segments
            WHERE   Cutno > 0
                    --AND
                    --fail_yr > @thisYear + @RULNewSpot
            GROUP BY COMPKEY
          )  AS B
          ON  A.Compkey = B.Compkey
          
  --Present value destroyed when replacing a sagging or ovaling whole pipe
  UPDATE  A
  SET     WholePipe = 0
  FROM    #PresentValue AS A
          INNER JOIN
          REHAB.GIS.REHAB_Branches  AS B
          ON  A.Compkey = B.Compkey
  WHERE   problems like '%sagging%'
          OR
          problems like '%ovaling%'
          
  --Present value destroyed when replacing with a liner
  UPDATE  A
  SET     Liner = CASE WHEN SumCost > @MaxWholeValue * ReplaceCost THEN ReplaceCost * @MaxWholeValue ELSE SumCost END
  FROM    #PresentValue AS A
          INNER JOIN
          (
            SELECT  COMPKEY, SUM((ReplaceCost*0.36) * CASE WHEN def_tot >= 1000 THEN 0 ELSE 1 * (1000.0-def_tot)/1000.0 END * CASE WHEN [action] = 3 THEN 0 ELSE 1 END * CASE WHEN fail_yr < @thisYear + @RULNewLiner*0.66 THEN 1 ELSE 3 END * CASE WHEN fail_yr < @thisYear + @RULNewLiner THEN 1 ELSE 3 END) AS SumCost
            FROM    REHAB.GIS.REHAB_Segments
            WHERE   Cutno > 0
                    --AND
                    --fail_yr > @thisYear + @RULNewSpot
            GROUP BY COMPKEY
          )  AS B
          ON  A.Compkey = B.Compkey
         
  --Present value destroyed when replacing with a spot (only affects linable defects that expire in this window)
  /*UPDATE  A
  SET     Spot = SumCost
  FROM    #PresentValue AS A
          INNER JOIN
          (
            SELECT  COMPKEY, SUM((ReplaceCost * 0.5) * CASE WHEN ([action] <> 3) THEN 1 ELSE 0 END ) AS SumCost
            FROM    REHAB.GIS.REHAB_Segments
            WHERE   Cutno > 0
                    AND
                    (
                      fail_yr_seg <= @thisYear + @SpotRotationFrequency
                      AND
                      def_tot >= 1000
                    )
            GROUP BY COMPKEY
          )  AS B
          ON  A.Compkey = B.Compkey*/
  
  
  --This probably could be average instead of max.  This might need some work after cost estimator is finished
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     MaxSegmentCOFwithoutReplacement = B.maxSegCofWithoutReplacement
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN
          (  
            SELECT  compkey, MAX(COF-@EmergencyFactor*ReplaceCost) AS maxSegCofWithoutReplacement
            FROM    REHAB.GIS.REHAB_Segments AS Z
            WHERE   cutno > 0
            GROUP BY COMPKEY
          ) AS B
          ON  A.COMPKEY = B.compkey
          
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     SpotCost01 = ISNULL(B.TotalFirstSpotRepairs,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN
          (  
            SELECT  Z.compkey, SUM([CapitalNonMobilization]) + MAX([CapitalMobilizationRate])*(SUM(BaseTime) + MAX([MobilizationTime]))/@HoursPerDay AS TotalFirstSpotRepairs
            FROM    REHAB.GIS.REHAB_Segments AS Z
                    INNER JOIN
                    [COSTEST_CapitalCostsMobilizationRatesAndTimes] AS ZZ1
                    ON  Z.ID = ZZ1.ID
                        AND
						ZZ1.[type] = 'Spot'
            WHERE   Z.cutno > 0
                    AND
                    (
                      (
                        Z.fail_yr_seg <= @thisYear + @SpotRotationFrequency
                        AND
                        Z.def_tot >= 1000
                      )
                      OR
                      [action] = 3
                    )
            GROUP BY Z.COMPKEY
          ) AS B
          ON  A.COMPKEY = B.compkey
          
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     SpotCost02 = (ISNULL(B.TotalSecondSpotRepairs,0))
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN
          (  
            SELECT  Z.compkey, ((SUM([CapitalNonMobilization]) + MAX([CapitalMobilizationRate])*(SUM(BaseTime) + MAX([MobilizationTime]))/@HoursPerDay)) AS TotalSecondSpotRepairs
            FROM    REHAB.GIS.REHAB_Segments AS Z
                    INNER JOIN
                    [COSTEST_CapitalCostsMobilizationRatesAndTimes] AS ZZ1
                    ON  Z.ID = ZZ1.ID
                        AND
						ZZ1.[type] = 'Spot'
            WHERE   cutno > 0
                    AND
                    --fail_yr_seg <= @thisYear + 2*@SpotRotationFrequency
                    --AND
                    fail_yr_seg > @thisYear + @SpotRotationFrequency
                    AND
                    (
                      Z.def_tot >= 1000
                      --OR
                      --[action] = 3
                    )
            GROUP BY Z.COMPKEY
          ) AS B
          ON  A.COMPKEY = B.compkey
  
                      
  --Cost to replace all of the near failing spots after the initial failure year     
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     SpotCostFail01 = ISNULL(B.TotalFirstSpotRepairs,0) 
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN
          (  
            SELECT  Z.compkey, (SUM([CapitalNonMobilization]) + MAX([CapitalMobilizationRate])*(SUM(BaseTime) + MAX([MobilizationTime]))/@HoursPerDay) AS TotalFirstSpotRepairs
            FROM    REHAB.GIS.REHAB_Segments AS Z
                    INNER JOIN
                    [COSTEST_CapitalCostsMobilizationRatesAndTimes] AS ZZ1
                    ON  Z.ID = ZZ1.ID
                        AND
						ZZ1.[type] = 'Spot'
                    INNER JOIN
                    REHAB.GIS.REHAB_Branches AS X
                    ON  Z.compkey = X.compkey 
            WHERE   Z.cutno > 0
                    AND
                    Z.fail_yr_seg <= X.[InitialFailYear] + @SpotRotationFrequency
                    AND
                    (
                      Z.def_tot >= 1000
                      OR
                      [action] = 3
                    )
            GROUP BY Z.compkey
          ) AS B
          ON  A.COMPKEY = B.compkey
  
          
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     SpotCostFail02 = ISNULL(B.TotalSecondSpotRepairs,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN
          (  
            SELECT  Z.compkey, SUM([CapitalNonMobilization]) + MAX([CapitalMobilizationRate])*(SUM(BaseTime) + MAX([MobilizationTime]))/@HoursPerDay AS TotalSecondSpotRepairs
            FROM    REHAB.GIS.REHAB_Segments AS Z
                    INNER JOIN
                    [COSTEST_CapitalCostsMobilizationRatesAndTimes] AS ZZ1
                    ON  Z.ID = ZZ1.ID
                        AND
						ZZ1.[type] = 'Spot'
                    INNER JOIN
                    REHAB.GIS.REHAB_Branches AS X
                    ON  Z.compkey = X.compkey 
            WHERE   Z.cutno > 0
                    AND
                    --Z.fail_yr_seg <= X.[InitialFailYear] + 2*@SpotRotationFrequency
                    --AND
                    Z.fail_yr_seg > X.[InitialFailYear] + @SpotRotationFrequency
                    AND
                    (
                      Z.def_tot >= 1000
                      OR
                      [action] = 3
                    )
            GROUP BY Z.compkey
          ) AS B
          ON  A.COMPKEY = B.compkey       
          
          
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWOCFail01 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  A.std_dev = B.std_dev
              AND 
              A.InitialFailYear = B.failure_yr 
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWOCFail02 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              A.InitialFailYear + @RULNewWholePipe= B.failure_yr 
  
  
  --On a reactive lining job, all bad spots are replaced
  
    
  TRUNCATE TABLE #Costs
  INSERT INTO #Costs ( Compkey, NonMobCap, Rate, BaseTime, MobTime )
  SELECT  Z.compkey, 
						SUM([CapitalNonMobilization]) AS SpotNonMobCap,
						MAX([CapitalMobilizationRate]) AS SpotRate,
						SUM(BaseTime) AS SpotBaseTime,
						MAX([MobilizationTime]) AS SpotMobTime
				FROM    REHAB.GIS.REHAB_Segments AS Z
						INNER JOIN
						[COSTEST_CapitalCostsMobilizationRatesAndTimes] AS ZZ1
						ON  Z.ID = ZZ1.ID
						    AND
						    ZZ1.[type] = 'Spot'
						INNER JOIN
						REHAB.GIS.REHAB_Branches AS X
						ON  Z.compkey = X.compkey 
				WHERE   Z.cutno > 0
						AND
						(
						  [action] = 3
						  OR
						  (
						    Z.def_tot >= 1000
						    AND
						    Z.fail_yr_seg <= X.[InitialFailYear] + @SpotRotationFrequency
						  )
						)
				GROUP BY Z.compkey
				
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWCIPPfail01 = (TotalSpotLineCost*@EmergencyFactor+C.MaxSegmentCOFwithoutReplacement)*ISNULL(B.unit_multiplier,0) 
  FROM    (
            SELECT Table1.COMPKEY, 
                   (ISNULL(NonMobCap,0) + LineNonMobCap) 
                   + (CASE WHEN ISNULL(Rate,0) > ISNULL(LineRate,0) THEN ISNULL(Rate,0) ELSE ISNULL(LineRate,0) END)
                   * (
                       CASE WHEN ISNULL(MobTime,0) > ISNULL(LineMobTime,0) THEN ISNULL(MobTime,0) ELSE ISNULL(LineMobTime,0) END
                       +
                       (ISNULL(BaseTime,0) + LineBaseTime)
                     )/@HoursPerDay AS TotalSpotLineCost
            FROM #Costs AS Table1
            INNER JOIN
            (
              SELECT  Compkey,
                      [CapitalNonMobilization] AS LineNonMobCap,
				      [CapitalMobilizationRate] AS LineRate,
					  BaseTime AS LineBaseTime,
					  [MobilizationTime] AS LineMobTime
              FROM    [COSTEST_CapitalCostsMobilizationRatesAndTimes]
              WHERE   [type] = 'Line'
                      AND 
                      ID < 40000000
            ) AS Table2
            ON Table1.Compkey = Table2.Compkey
          ) AS A
          INNER JOIN  
          REHAB.GIS.REHAB_Branches AS C
          ON  A.Compkey = C.Compkey
          INNER JOIN
          REHAB_UnitMultiplierTable AS B
          ON  C.std_dev = B.std_dev
              AND 
              C.InitialFailYear = B.failure_yr
  
  
               
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWCIPPfail02 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @StdDevNewLiner = B.std_dev
              AND 
              A.InitialFailYear + @RULNewLiner = B.failure_yr
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWCIPPfail03 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              A.InitialFailYear + @RULNewLiner +@RULNewWholePipe = B.failure_yr
              
  --Alternative whole pipe if BPWCIPPfail01 is greater than whole pipe
  --------------------------------------------------------------------
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWCIPPfail03 = CASE
                            WHEN  BPWCIPPfail01 > BPWOCFail01
                            THEN  0
                            ELSE  BPWCIPPfail03
                          END
  FROM    REHAB.GIS.REHAB_Branches AS A
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWCIPPfail02 = CASE
                            WHEN  BPWCIPPfail01 > BPWOCFail01
                            THEN  BPWOCFail02
                            ELSE  BPWCIPPfail02
                          END
  FROM    REHAB.GIS.REHAB_Branches AS A
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWCIPPfail01 = CASE
                            WHEN  BPWCIPPfail01 > BPWOCFail01
                            THEN  BPWOCFail01
                            ELSE  BPWCIPPfail01
                          END
  FROM    REHAB.GIS.REHAB_Branches AS A
  
  --End of whole pipe alternative to spot repair
  -----------------------------------------------------
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWSPfail01 = (A.SpotCostFail01*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)*ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  A.std_dev = B.std_dev
              AND 
              A.InitialFailYear = B.failure_yr
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     LineAtYear = @LineAtYearSpots
  FROM    REHAB.GIS.REHAB_Branches AS A
  WHERE   A.SpotCostFail02 > 0
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     LineAtYear = @LineAtYearNoSpots
  FROM    REHAB.GIS.REHAB_Branches AS A
  WHERE   ISNULL(A.SpotCostFail02,0) = 0
  
  
  TRUNCATE TABLE #Costs
  INSERT INTO #Costs ( Compkey, NonMobCap, Rate, BaseTime, MobTime )
  SELECT  X.COMPKEY, 
						--Z.*, 
						ISNULL(SUM([CapitalNonMobilization]),0) AS SpotNonMobCap,
						ISNULL(MAX([CapitalMobilizationRate]),0) AS SpotRate,
						ISNULL(SUM(BaseTime),0) AS SpotBaseTime,
						ISNULL(MAX([MobilizationTime]),0) AS SpotMobTime
				FROM    REHAB.GIS.REHAB_Branches AS X
						LEFT JOIN 
						(
						  [COSTEST_CapitalCostsMobilizationRatesAndTimes] AS Z
				          INNER JOIN
						  REHAB.GIS.REHAB_Segments AS Y
						  ON  Z.ID = Y.ID
						      AND
						      Y.cutno > 0
						      --@LineAtYearSpots
						      AND
						      (
							    def_tot >= 1000
							    OR
							    [action] = 3
							  )
						)
						ON  X.Compkey = Z.COMPKEY
							AND
							Z.[type] = 'Spot'
							AND
							Y.fail_yr_seg  > X.[InitialFailYear] + X.LineAtYear
				GROUP BY X.COMPKEY
				
  --On a reactive liner job after a reactive spot job, only type 3 spots are replaced          
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWSPfail02 = (TotalSpotLineCost*@EmergencyFactor+C.MaxSegmentCOFwithoutReplacement)*ISNULL(B.unit_multiplier,0) 
  FROM    (
            SELECT Table1.COMPKEY, 
                   (ISNULL(NonMobCap,0) + LineNonMobCap) 
                   + (CASE WHEN ISNULL(Rate,0) > ISNULL(LineRate,0) THEN ISNULL(Rate,0) ELSE ISNULL(LineRate,0) END)
                   * (
                       CASE WHEN ISNULL(MobTime,0) > ISNULL(LineMobTime,0) THEN ISNULL(MobTime,0) ELSE ISNULL(LineMobTime,0) END
                       +
                       (ISNULL(BaseTime,0) + LineBaseTime)
                     )/@HoursPerDay AS TotalSpotLineCost
            FROM   #Costs AS Table1
            INNER JOIN
            (
              SELECT  Compkey,
                      [CapitalNonMobilization] AS LineNonMobCap,
				      [CapitalMobilizationRate] AS LineRate,
					  BaseTime AS LineBaseTime,
					  [MobilizationTime] AS LineMobTime
              FROM    [COSTEST_CapitalCostsMobilizationRatesAndTimes]
              WHERE   [type] = 'Line'
                      AND 
                      ID < 40000000
            ) AS Table2
            ON Table1.Compkey = Table2.Compkey
          ) AS A
          INNER JOIN  
          REHAB.GIS.REHAB_Branches AS C
          ON  A.Compkey = C.Compkey
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @StdDevNewSpot = B.std_dev
              AND 
              C.InitialFailYear + C.LineAtYear = B.failure_yr
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWSPfail03 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @StdDevNewLiner = B.std_dev
              AND 
              A.InitialFailYear + A.LineAtYear + @RULNewLiner = B.failure_yr  

  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWSPfail04 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              A.InitialFailYear + A.LineAtYear + @RULNewLiner + @RULNewWholePipe = B.failure_yr 
              
  --Alternative whole pipe if BPWSPfail02 is greater than whole pipe
  --------------------------------------------------------------------
  --Set them all to 0 if it is more expensive to do liner than whole pipe
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWSPfail04 = CASE
                          WHEN  BPWSPfail02 > (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
                          THEN  0
                          ELSE  BPWSPfail04
                        END,
          BPWSPfail03 = CASE
                          WHEN  BPWSPfail02 > (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
                          THEN  0
                          ELSE  BPWSPfail03
                        END,
          BPWSPfail02 = CASE
                          WHEN  BPWSPfail02 > (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
                          THEN  0
                          ELSE  BPWSPfail02
                        END
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              A.InitialFailYear + A.LineAtYear = B.failure_yr
  
  --Now just update the ones that are 0
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWSPfail04 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              A.InitialFailYear + A.LineAtYear + @RULNewWholePipe * 2 = B.failure_yr
              AND
              BPWSPFail04 = 0
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWSPfail03 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              A.InitialFailYear + A.LineAtYear + @RULNewWholePipe = B.failure_yr
              AND
              BPWSPFail03 = 0
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWSPfail02 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A 
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              A.InitialFailYear + A.LineAtYear = B.failure_yr   
              AND
              BPWSPFail02 = 0 
 ----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------
 --APW
 ----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------
 UPDATE   REHAB.GIS.REHAB_Branches
  SET     APWOC01 = A.ReplaceCost
  FROM    REHAB.GIS.REHAB_Branches AS A
  
  
  --PresentValue
  UPDATE   REHAB.GIS.REHAB_Branches
  SET     APWOC01 = ISNULL(APWOC01,0) + ISNULL(WholePipe,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN
          #PresentValue AS B
          ON A.Compkey = B.Compkey

  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWOC02 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              @thisYear + @RULNewWholePipe= B.failure_yr 
  
  --On a proactive liner job, just replace all type 3 spots
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWCIPP01 = (TotalSpotLineCost)
  FROM    (
            SELECT Table1.COMPKEY, 
                   (ISNULL(SpotNonMobCap,0) + LineNonMobCap) 
                   + (CASE WHEN ISNULL(SpotRate,0) > ISNULL(LineRate,0) THEN ISNULL(SpotRate,0) ELSE ISNULL(LineRate,0) END)
                   * (
                       CASE WHEN ISNULL(SpotMobTime,0) > ISNULL(LineMobTime,0) THEN ISNULL(SpotMobTime,0) ELSE ISNULL(LineMobTime,0) END
                       +
                       (ISNULL(SpotBaseTime,0) + LineBaseTime)
                     )/@HoursPerDay AS TotalSpotLineCost
            FROM
            (
				/*SELECT  Z.compkey, 
						SUM([CapitalNonMobilization]) AS SpotNonMobCap,
						MAX([CapitalMobilizationRate]) AS SpotRate,
						SUM(BaseTime) AS SpotBaseTime,
						MAX([MobilizationTime]) AS SpotMobTime
				FROM    REHAB.GIS.REHAB_Segments AS Z
						INNER JOIN
						[COSTEST_CapitalCostsMobilizationRatesAndTimes] AS ZZ1
						ON  Z.ID = ZZ1.ID
						    AND
						    ZZ1.[type] = 'Spot'
						INNER JOIN
						REHAB.GIS.REHAB_Branches AS X
						ON  Z.compkey = X.compkey 
				WHERE   Z.cutno > 0
						AND
						(
						  [action] = 3
						)
				GROUP BY Z.compkey*/
				SELECT  X.compkey, 
						ISNULL(SUM([CapitalNonMobilization]),0) AS SpotNonMobCap,
						ISNULL(MAX([CapitalMobilizationRate]),0) AS SpotRate,
						ISNULL(SUM(BaseTime),0) AS SpotBaseTime,
						ISNULL(MAX([MobilizationTime]),0) AS SpotMobTime
				FROM    REHAB.GIS.REHAB_Branches AS X
				        LEFT OUTER JOIN
				        (
				          REHAB.GIS.REHAB_Segments AS Z
				          INNER JOIN
						  [COSTEST_CapitalCostsMobilizationRatesAndTimes] AS ZZ1
						  ON  Z.ID = ZZ1.ID
						      AND
						      ZZ1.[type] = 'Spot'
						      AND
						      [action] = 3
						      AND
						      Z.cutno = 0
						)
						ON  X.compkey = Z.compkey
                GROUP BY X.compkey
            ) AS Table1
            INNER JOIN
            (
              SELECT  Compkey,
                      [CapitalNonMobilization] AS LineNonMobCap,
				      [CapitalMobilizationRate] AS LineRate,
					  BaseTime AS LineBaseTime,
					  [MobilizationTime] AS LineMobTime
              FROM    [COSTEST_CapitalCostsMobilizationRatesAndTimes]
              WHERE   [type] = 'Line'
                      AND 
                      ID < 40000000
            ) AS Table2
            ON Table1.Compkey = Table2.Compkey
          ) AS A
          INNER JOIN  
          REHAB.GIS.REHAB_Branches AS C
          ON  A.Compkey = C.Compkey
          
  --PresentValue
  UPDATE   REHAB.GIS.REHAB_Branches
  SET     APWCIPP01 = ISNULL(APWCIPP01,0) + ISNULL(Liner,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN
          #PresentValue AS B
          ON A.Compkey = B.Compkey
               
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWCIPP02 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @StdDevNewLiner = B.std_dev
              AND 
              @thisYear + @RULNewLiner = B.failure_yr
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWCIPP03 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              @thisYear + @RULNewLiner +@RULNewWholePipe = B.failure_yr
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWSP01 = A.SpotCost01
  FROM    REHAB.GIS.REHAB_Branches AS A
  
  --PresentValue
  UPDATE   REHAB.GIS.REHAB_Branches
  SET     APWSP01 = ISNULL(APWSP01,0) + ISNULL(Spot,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN
          #PresentValue AS B
          ON A.Compkey = B.Compkey
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     LineAtYearAPW = @LineAtYearSpots
  FROM    REHAB.GIS.REHAB_Branches AS A
  WHERE   A.SpotCost02 > 0
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     LineAtYearAPW = @LineAtYearNoSpots
  FROM    REHAB.GIS.REHAB_Branches AS A
  WHERE   ISNULL(A.SpotCost02,0) = 0
   
  --This is a reactive liner year after a proactive spot year.  Replace only type 3 spots  
  --because we are assumed to have replaced any really bad 1000+ point segments during the spot repair portion         
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWSP02 = (TotalSpotLineCost*@EmergencyFactor+C.MaxSegmentCOFwithoutReplacement)*ISNULL(B.unit_multiplier,0) 
  FROM    (
            SELECT Table1.COMPKEY, 
                   (ISNULL(SpotNonMobCap,0) + LineNonMobCap) 
                   + (CASE WHEN ISNULL(SpotRate,0) > ISNULL(LineRate,0) THEN ISNULL(SpotRate,0) ELSE ISNULL(LineRate,0) END)
                   * (
                       CASE WHEN ISNULL(SpotMobTime,0) > ISNULL(LineMobTime,0) THEN ISNULL(SpotMobTime,0) ELSE ISNULL(LineMobTime,0) END
                       +
                       (ISNULL(SpotBaseTime,0) + LineBaseTime)
                     )/@HoursPerDay AS TotalSpotLineCost
            FROM
            (
				SELECT  X.COMPKEY, 
        --Z.*, 
        ISNULL(SUM([CapitalNonMobilization]),0) AS SpotNonMobCap,
		ISNULL(MAX([CapitalMobilizationRate]),0) AS SpotRate,
		ISNULL(SUM(BaseTime),0) AS SpotBaseTime,
		ISNULL(MAX([MobilizationTime]),0) AS SpotMobTime
FROM    REHAB.GIS.REHAB_Branches AS X
        LEFT JOIN 
        (
          [COSTEST_CapitalCostsMobilizationRatesAndTimes] AS Z
          INNER JOIN
          REHAB.GIS.REHAB_Segments AS Y
		  ON  Z.ID = Y.ID
		  AND
		  Y.cutno > 0
		  --@LineAtYearSpots
		  AND
          (
            def_tot >= 1000
            OR
            [action] = 3
          )
		)
		ON  X.Compkey = Z.COMPKEY
            AND
            Z.[type] = 'Spot'
            AND
		    Y.fail_yr_seg > @thisYear + @SpotRotationFrequency
GROUP BY X.COMPKEY
            ) AS Table1
            INNER JOIN
            (
              SELECT  Compkey,
                      [CapitalNonMobilization] AS LineNonMobCap,
				      [CapitalMobilizationRate] AS LineRate,
					  BaseTime AS LineBaseTime,
					  [MobilizationTime] AS LineMobTime
              FROM    [COSTEST_CapitalCostsMobilizationRatesAndTimes]
              WHERE   [type] = 'Line'
                      AND 
                      ID < 40000000
            ) AS Table2
            ON Table1.Compkey = Table2.Compkey
          ) AS A
          INNER JOIN  
          REHAB.GIS.REHAB_Branches AS C
          ON  A.Compkey = C.Compkey
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @StdDevNewSpot = B.std_dev
              AND 
              @thisYear + C.LineAtYearAPW = B.failure_yr
			
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWSP03 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @StdDevNewLiner = B.std_dev
              AND 
              @thisYear + A.LineAtYearAPW + @RULNewLiner = B.failure_yr  

  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWSP04 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              @thisYear + A.LineAtYearAPW + @RULNewLiner + @RULNewWholePipe = B.failure_yr   
              
  --Check to see if it is more expensive to line in   APWSP02 than it is to whole pipe replace.
  --Alternative whole pipe if BPWSPfail02 is greater than whole pipe
  --------------------------------------------------------------------
  --Set them all to 0 if it is more expensive to do liner than whole pipe
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWSP04 = CASE
                          WHEN  APWSP02 > (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
                          THEN  0
                          ELSE  APWSP04
                        END,
          APWSP03 = CASE
                          WHEN  APWSP02 > (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
                          THEN  0
                          ELSE  APWSP03
                        END,
          APWSP02 = CASE
                          WHEN  APWSP02 > (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
                          THEN  0
                          ELSE  APWSP02
                        END
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              @thisYear + A.LineAtYear = B.failure_yr
  
  --Now just update the ones that are 0
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWSP04 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              @thisYear + A.LineAtYear + @RULNewWholePipe * 2 = B.failure_yr
              AND
              APWSP04 = 0
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWSP03 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              @thisYear + A.LineAtYear + @RULNewWholePipe = B.failure_yr
              AND
              APWSP03 = 0
              
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     APWSP02 = (A.ReplaceCost*@EmergencyFactor+A.MaxSegmentCOFwithoutReplacement)* ISNULL(B.unit_multiplier,0)
  FROM    REHAB.GIS.REHAB_Branches AS A 
          INNER JOIN  
          REHAB_UnitMultiplierTable AS B
          ON  @MaxStdDev = B.std_dev
              AND 
              @thisYear + A.LineAtYear = B.failure_yr   
              AND
              APWSP02 = 0       
  --------------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------------
  --nBCR Section
  --The nBCR names start with nBCR, then underscore, and the assumed ASM solution, then underscore, then the possible alternatives
  --------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------- 
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWOC = BPWOCfail01+ISNULL(BPWOCfail02,0),
          BPWCIPP = BPWCIPPfail01+BPWCIPPfail02+ISNULL(BPWCIPPfail03,0),
          BPWSP = BPWSPfail01+BPWSPfail02+ISNULL(BPWSPfail03,0)+ISNULL(BPWSPfail04,0),
          APWOC = APWOC01+ISNULL(APWOC02,0),
          APWCIPP = APWCIPP01+APWCIPP02+ISNULL(APWCIPP03,0),
          APWSP = APWSP01+APWSP02+ISNULL(APWSP03,0)+ISNULL(APWSP04,0) 
          
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     BPWOC = (
                    SELECT  MIN(v) 
                    FROM   (VALUES (BPWOC),(BPWCIPP),(BPWSP)) AS value(v)
                  )
 
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_OC = ((BPWOC - APWOC))//*APWOC01*/(APWOC)
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_CIPP = ISNULL((BPWOC-APWCIPP)//*APWCIPP01*/APWCIPP, -10)       
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_SP = ISNULL((BPWOC-APWSP)//*APWSP01*/APWSP, -10)
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_OC = ISNULL((BPWOC - APWOC)//*APWOC01*/APWOC, -10)
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_CIPP = ISNULL((BPWOC - APWCIPP)//*APWCIPP01*/APWCIPP, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_SP = ISNULL((BPWOC - APWSP)//*APWSP01*/APWSP, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_OC = ISNULL((BPWOC - APWOC)//*APWOC01*/APWOC, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_CIPP = ISNULL((BPWOC - APWCIPP)//*APWCIPP01*/APWCIPP, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_SP = ISNULL((BPWOC - APWSP)//*APWSP01*/APWSP, -10) 
 /* 
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_OC = ((BPWOC - APWOC))//*APWOC01*/(APWOC01)
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_CIPP = ISNULL((BPWOC-APWCIPP)//*APWCIPP01*/APWCIPP01, -10)       
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_SP = ISNULL((BPWOC-APWSP)//*APWSP01*/APWSP01, -10)
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_OC = ISNULL((BPWOC - APWOC)//*APWOC01*/APWOC01, -10)
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_CIPP = ISNULL((BPWOC - APWCIPP)//*APWCIPP01*/APWCIPP01, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_SP = ISNULL((BPWOC - APWSP)//*APWSP01*/APWSP01, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_OC = ISNULL((BPWOC - APWOC)//*APWOC01*/APWOC01, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_CIPP = ISNULL((BPWOC - APWCIPP)//*APWCIPP01*/APWCIPP01, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_SP = ISNULL((BPWOC - APWSP)//*APWSP01*/APWSP01, -10)          
 */ 

UPDATE A
SET    PVLostWhole = WholePipe,
       PVLostLiner = Liner,
       PVLostSpot  = Spot
FROM   GIS.REHAB_Branches AS A
       INNER JOIN
       #PresentValue AS B
       ON  A.Compkey = B.Compkey

DROP TABLE #Costs
DROP TABLE #PresentValue
  
END




GO

