USE [REHAB]
GO
/****** Object:  StoredProcedure [dbo].[__USP_REHAB_10Gen3nBCR_0]    Script Date: 02/12/2016 09:07:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[__USP_REHAB_10Gen3nBCR_0] 
AS
BEGIN
  SET NOCOUNT ON;
  
  DECLARE @thisYear int = YEAR(GETDATE())
  DECLARE @SpotRotationFrequency int = 20
  DECLARE @EmergencyFactor float = 1.4
  DECLARE @StdDevWholePipeAt120Years int = 12
  DECLARE @MaxStdDev int = 12
  DECLARE @StdDevNewLiner int = 6
  DECLARE @RULNewWholePipe int = 120
  DECLARE @RULNewLiner int = 60
  DECLARE @LineAtYearNoSpots int = 20
  DECLARE @LineAtYearSpots int = 30
  DECLARE @StdDevNewSpot int = 4
  DECLARE @RULNewSpot int = 30
  DECLARE @HoursPerDay float = 8.0
  
  CREATE TABLE #Costs
  (
    Compkey INT,
    NonMobCap FLOAT,
    Rate FLOAT,
    BaseTime FLOAT,
    MobTime FLOAT
  )
  
  /*
  TRUNCATE TABLE REHAB.GIS.REHAB_Branches
  
  INSERT INTO REHAB.GIS.REHAB_Branches(COMPKEY, [InitialFailYear], std_dev, ReplaceCost, SpotCost, /*LineCostwSpots,*/ LineCostNoSpots)
  SELECT  compkey, fail_yr, std_dev, replaceCost, SpotCost, /*LineCostNoSegsNoLats + SpotCost ,*/ LineCostNoSegsNoLats
  FROM    REHAB.GIS.REHAB_Segments AS A
  WHERE   cutno = 0
  */
  
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
                    Z.fail_yr_seg <= @thisYear + @SpotRotationFrequency
                    AND
                    (
                      Z.def_tot >= 1000
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
                      OR
                      [action] = 3
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
            SELECT  Z.compkey, @EmergencyFactor*SUM([CapitalNonMobilization]) + MAX([CapitalMobilizationRate])*(SUM(BaseTime) + MAX([MobilizationTime]))/@HoursPerDay AS TotalSecondSpotRepairs
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
 ----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------
 --APW
 ----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------
 UPDATE   REHAB.GIS.REHAB_Branches
  SET     APWOC01 = A.ReplaceCost
  FROM    REHAB.GIS.REHAB_Branches AS A

  
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
						)
				GROUP BY Z.compkey
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
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     LineAtYearAPW = @LineAtYearSpots
  FROM    REHAB.GIS.REHAB_Branches AS A
  WHERE   A.SpotCost02 > 0
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     LineAtYearAPW = @LineAtYearNoSpots
  FROM    REHAB.GIS.REHAB_Branches AS A
  WHERE   ISNULL(A.SpotCost02,0) = 0
   
  --This is a reactive liner year after a proactive spot year.  Replace only type 3 spots           
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
  --------------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------------
  --nBCR Section
  --The nBCR names start with nBCR, then underscore, and the assumed ASM solution, then underscore, then the possible alternatives
  --------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------- 
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_OC = ((BPWOCfail01+ISNULL(BPWOCfail02,0)) - (APWOC01+ISNULL(APWOC02,0)))/(APWOC01+ISNULL(APWOC02,0)),
          BPWOC = BPWOCfail01+ISNULL(BPWOCfail02,0),
          BPWCIPP = BPWCIPPfail01+BPWCIPPfail02+ISNULL(BPWCIPPfail03,0),
          BPWSP = BPWSPfail01+BPWSPfail02+ISNULL(BPWSPfail03,0)+ISNULL(BPWSPfail04,0),
          APWOC = APWOC01+ISNULL(APWOC02,0),
          APWCIPP = APWCIPP01+APWCIPP02+ISNULL(APWCIPP03,0),
          APWSP = APWSP01+APWSP02+ISNULL(APWSP03,0)+ISNULL(APWSP04,0)    
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_CIPP = ISNULL(((BPWOCfail01+ISNULL(BPWOCfail02,0))-(APWCIPP01+APWCIPP02+ISNULL(APWCIPP03,0)))/APWCIPP, -10)       
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_OC_SP = ISNULL(((BPWOCfail01+ISNULL(BPWOCfail02,0))-(APWSP01+APWSP02+ISNULL(APWSP03,0)+ISNULL(APWSP04,0)))/APWSP, -10)
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_OC = ISNULL(((BPWCIPPfail01+BPWCIPPfail02+ISNULL(BPWCIPPfail03,0)) - (APWOC01+ISNULL(APWOC02,0)))/APWOC, -10)
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_CIPP = ISNULL(((BPWCIPPfail01+BPWCIPPfail02+ISNULL(BPWCIPPfail03,0)) - (APWCIPP01+APWCIPP02+ISNULL(APWCIPP03,0)))/APWCIPP, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_CIPP_SP = ISNULL(((BPWCIPPfail01+BPWCIPPfail02+ISNULL(BPWCIPPfail03,0)) - (APWSP01+APWSP02+ISNULL(APWSP03,0)+ISNULL(APWSP04,0)))/APWSP, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_OC = ISNULL(((BPWSPfail01+BPWSPfail02+ISNULL(BPWSPfail03,0)+ISNULL(BPWSPfail04,0)) - (APWOC01+ISNULL(APWOC02,0)))/APWOC, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_CIPP = ISNULL(((BPWSPfail01+BPWSPfail02+ISNULL(BPWSPfail03,0)+ISNULL(BPWSPfail04,0)) - (APWCIPP01+APWCIPP02+ISNULL(APWCIPP03,0)))/APWCIPP, -10)           
  
  UPDATE  REHAB.GIS.REHAB_Branches
  SET     nBCR_SP_SP = ISNULL(((BPWSPfail01+BPWSPfail02+ISNULL(BPWSPfail03,0)+ISNULL(BPWSPfail04,0)) - (APWSP01+APWSP02+ISNULL(APWSP03,0)+ISNULL(APWSP04,0)))/APWSP, -10)           
  

DROP TABLE #Costs
  
END
GO
