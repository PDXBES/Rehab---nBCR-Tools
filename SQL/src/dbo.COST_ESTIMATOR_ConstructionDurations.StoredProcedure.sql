USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[COST_ESTIMATOR_ConstructionDurations]    Script Date: 03/23/2016 14:12:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:    Gardner, Issac
-- Create date: 1/6/2016
-- Description:  Computes construction durations and mobilization
-- values for the nBCR tool.  This procedure is intended to run in the cost estimator,
-- after basic dimensional values are computed and before time based costs are computed
--
-- =============================================

CREATE PROCEDURE [dbo].[COST_ESTIMATOR_ConstructionDurations]
AS
BEGIN
  
  --Establish variables
  DECLARE @spotIDsStartPoint AS INT = 40000000
  DECLARE @utilityCrossingDuration AS FLOAT = 0.5 --days per utility
  DECLARE @excavationDuration AS FLOAT = 140 --cubic yards per day
  DECLARE @paveDuration AS FLOAT = 250 --feet per day
  DECLARE @hoursPerDay AS FLOAT = 8 --assumed hours in a work day
  DECLARE @slowBoreRate AS FLOAT = 50 -- feet per day
  DECLARE @fastBoreRate AS FLOAT = 100 -- feet per day
  DECLARE @boreJackcasingAndGroutingDays AS FLOAT = 2
  DECLARE @CIPPRepairDays AS FLOAT = 3
  DECLARE @smallBoreJackDiameter AS FLOAT = 24 -- inches
  DECLARE @largeBoreJackDiameter AS FLOAT = 60 -- inches
  DECLARE @shallowTrenchDepthCutoff AS FLOAT = 20 --feet
  DECLARE @shallowSpotDepthCutoff AS FLOAT = 20 -- feet
  DECLARE @shallowSpotRepairTime AS FLOAT = 4 --hours
  DECLARE @deepSpotRepairTime AS FLOAT = 8 --hours
  DECLARE @streetTypeStreet AS NVARCHAR(255) = 'Strt'
  DECLARE @streetTypeArterial AS NVARCHAR(255) = 'Art'
  DECLARE @streetTypeMajorArterial AS NVARCHAR(255) = 'MajArt'
  DECLARE @streetTypeStreetTrafficControlMobilization FLOAT = 1 --hours
  DECLARE @streetTypeArterialTrafficControlMobilization FLOAT = 2 --hours
  DECLARE @streetTypeMajorArterialTrafficControlMobilization FLOAT = 3 --hours
  DECLARE @manholeBuildRate FLOAT = 10 -- feet per day
  DECLARE @smallMainlineBypassCutoff FLOAT = 15 --inches
  DECLARE @lateralTrenchWidth FLOAT = 4 --feet
  DECLARE @lateralShoringLength FLOAT = 10 --feet
  DECLARE @cubicFeetPerCubicYard FLOAT = 27 --cubic feet per cubic yard
  DECLARE @boreJackArea FLOAT = 460 --square feet
  
  --Build the table:
  TRUNCATE TABLE COSTEST_ConstructionDurations
  INSERT INTO COSTEST_ConstructionDurations
  (
	[ID],
	[globalID],
	[compkey],
	[cutno],
	[fm],
	[to]
  )
  SELECT  ID,
          globalID,
          compkey,
          cutno,
          fm,
          [to_]
  FROM    GIS.REHAB_Segments
  
  -----------------------------------------------------------------------------------------
  --Update durations:
  -----------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------
  --baseOCRepairTime
  UPDATE  COSTEST_ConstructionDurations
  SET     baseOpenCutRepairTime = (((((uDepth + dDepth)/2)*GIS.COSTEST_Interpolate_TrenchWidth(B.diamwidth, B.height)/@CubicFeetPerCubicYard)/@excavationDuration) + (B.[length]/@paveDuration))*@hoursPerDay
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID
             AND
             A.ID < @spotIDsStartPoint
  
  UPDATE  COSTEST_ConstructionDurations
  SET     baseOpenCutRepairTime = baseOpenCutRepairTime + (@utilityCrossingDuration * @hoursPerDay * (ISNULL(xWtr, 0) + ISNULL(xGas, 0) + ISNULL(xFiber, 0) + ISNULL(xSewer, 0)))
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID
             AND
             A.ID < @spotIDsStartPoint
          
  -----------------------------------------------------------------------------------------
  --BasePBRepairTime:
  UPDATE  COSTEST_ConstructionDurations
  SET     basePipeBurstRepairTime = @hoursPerDay --Technically 2 hours to burst plus 12 to relax, but this translates into 1 workday
  WHERE   cutno = 0
  
  -----------------------------------------------------------------------------------------
  --BaseBorejackRepairTime:
  UPDATE  COSTEST_ConstructionDurations
  SET     baseBoreJackRepairTime = 
          CASE
            WHEN  B.diamWidth < @smallBoreJackDiameter
            THEN  B.[length]/@fastBoreRate + @boreJackcasingAndGroutingDays * @hoursPerDay  --1 day to install pipe in casing and 1 day for grouting
            WHEN  B.diamWidth >= @smallBoreJackDiameter AND B.diamWidth <= @largeBoreJackDiameter
            THEN  B.[length]/@slowBoreRate + @boreJackcasingAndGroutingDays * @hoursPerDay  --1 day to install pipe in casing and 1 day for grouting
            WHEN  B.diamWidth > @largeBoreJackDiameter
            THEN  B.[length]/@slowBoreRate --at this size, the casing will be the host pipe, so the 2 days is not applicable
          END
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID
             AND
             A.ID < @spotIDsStartPoint
  
  -----------------------------------------------------------------------------------------
  --BaseCIPPRepairTime:
  UPDATE  COSTEST_ConstructionDurations
  SET     baseCIPPRepairTime = @CIPPRepairDays * @hoursPerDay
  WHERE   cutno = 0
  
  -----------------------------------------------------------------------------------------
  --BaseSPRepairTime:
  UPDATE  COSTEST_ConstructionDurations
  SET     baseSPRepairTime = 
          CASE
            WHEN  (B.uDepth + B.dDepth)/2 < @shallowSpotDepthCutoff
            THEN  @shallowSpotRepairTime
            WHEN  (B.uDepth + B.dDepth)/2 >= @shallowSpotDepthCutoff
            THEN  @deepSpotRepairTime
          END
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID 
             AND
             A.ID >= @spotIDsStartPoint
             
  -----------------------------------------------------------------------------------------
  --TrafficControlMobilization, segments:             
  UPDATE  COSTEST_ConstructionDurations
  SET     trafficControl = 
          CASE
            WHEN  C.Street_Grp = @streetTypeStreet
            THEN  @streetTypeStreetTrafficControlMobilization
            WHEN  C.Street_Grp = @streetTypeArterial
            THEN  @streetTypeArterialTrafficControlMobilization
            WHEN  C.Street_Grp = @streetTypeMajorArterial
            THEN  @streetTypeMajorArterialTrafficControlMobilization
            ELSE  0
          END
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID 
             AND
             A.ID >= @spotIDsStartPoint 
          INNER JOIN
          [REHAB].[dbo].[Street Type] AS C
          ON C.Street_Number = B.pStrtTyp
  
  --TrafficControlMobilization, whole pipes:    
  UPDATE  COSTEST_ConstructionDurations
  SET     trafficControl = maxTrafficControl
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          (
            SELECT  COMPKEY, MAX(trafficControl) AS maxTrafficControl
            FROM    COSTEST_ConstructionDurations
            WHERE   ID >= @spotIDsStartPoint
            GROUP BY COMPKEY 
          ) AS B
          ON  A.compkey = B.Compkey 
              AND
              A.ID < @spotIDsStartPoint
              
              
  -----------------------------------------------------------------------------------------
  --MainlineBypassMobilization:                  
  UPDATE  COSTEST_ConstructionDurations
  SET     mainlineBypass = 
          CASE
            WHEN  (uDepth + dDepth)/2.0 < @shallowTrenchDepthCutoff AND diamwidth <= @smallMainlineBypassCutoff
            THEN  @hoursPerDay/2.0
            ELSE  @hoursPerDay
          END
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID 
          
  -----------------------------------------------------------------------------------------
  --ManholeReplacement:
  UPDATE  COSTEST_ConstructionDurations
  SET     ManholeReplacement = 
          ((
            CASE
              WHEN (uDepth + dDepth)/2.0 < 10.0
              THEN 10.0
              ELSE (uDepth + dDepth)/2.0
            END
          )/@manholeBuildRate) * @hoursPerDay
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID   
             AND
             B.cutno = 0 
             
  UPDATE  A
  SET     A.ManholeReplacement = B.ManholeReplacement
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_ConstructionDurations AS B
          ON A.compkey = B.compkey
             AND
             A.cutno = 1
             AND
             B.cutno = 0
  
  -----------------------------------------------------------------------------------------
  --LateralBypassMobilization:
  UPDATE  COSTEST_ConstructionDurations
  SET     lateralBypass = LateralCount *
          (
            (
              (@lateralTrenchWidth*@lateralShoringLength*((uDepth + dDepth)/2.0))/(@cubicFeetPerCubicYard*@excavationDuration)
            )
            +
            (
              @lateralShoringLength/@paveDuration
            )
          )
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID   
        
  -----------------------------------------------------------------------------------------
  --PipeBurst Pit excavation:
          
  -----------------------------------------------------------------------------------------
  --Bore/Jack Pit excavation:        
  UPDATE  COSTEST_ConstructionDurations
  SET     boreJackPitExcavation = LateralCount *
          (
            (@boreJackArea*(uDepth+dDepth)/2.0)/(@cubicFeetPerCubicYard*@excavationDuration)
          )
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP AS B
          ON A.ID = B.ID  
          AND A.cutno = 0         
              
  -----------------------------------------------------------------------------------------
  --OC construction duration:  
  UPDATE  COSTEST_ConstructionDurations
  SET     ocConstructionDuration = baseOpenCutRepairTime
          +manholeReplacement
          +trafficControl
          +mainlineBypass     
  
  -----------------------------------------------------------------------------------------
  --BoringJacking construction duration:          
  UPDATE  COSTEST_ConstructionDurations
  SET     BJMicroTConstructionDuration = baseBoreJackRepairTime
          --+manholeReplacement
          +trafficControl
          +mainlineBypass
          +lateralBypass
          +boreJackPitExcavation
  WHERE   cutno = 0
  
  -----------------------------------------------------------------------------------------
  --CIPP construction duration:  
  UPDATE  COSTEST_ConstructionDurations
  SET     cippConstructionDuration = baseCIPPRepairTime
          +baseSPRepairTime
          +trafficControl
          +mainlineBypass
          +lateralBypass
  WHERE   cutno = 0
  
  
  -----------------------------------------------------------------------------------------
  --OC construction duration:  
  UPDATE  COSTEST_ConstructionDurations
  SET     spOnlyConstructionDuration = baseSPRepairTime
          +trafficControl
          +mainlineBypass
  
  --Remove open cut options from cases where bore/jack is required:
  UPDATE  COSTEST_ConstructionDurations
  SET     ocConstructionDuration = NULL
          ,baseOpenCutRepairTime = NULL
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP_WHOLE AS B
          ON A.COMPKEY = B.COMPKEY 
             AND
             A.ID < 40000000--@spotIDsStartPoint
  WHERE   (
               (B.uDepth + B.dDepth)/2.0 > 25
               OR
               B.xBldg > 0
               OR
               B.xLRT > 0
               OR
               B.xRail > 0
               OR
               B.countxFrwy > 0
             )
  --Remove boring/jacking options from cases where open cut is required:
  UPDATE  COSTEST_ConstructionDurations
  SET     BJMicroTConstructionDuration = NULL,
          baseBoreJackRepairTime = NULL,
          boreJackPitExcavation = NULL
  FROM    COSTEST_ConstructionDurations AS A
          INNER JOIN
          COSTEST_PIPEXP_WHOLE AS B
          ON A.COMPKEY = B.COMPKEY 
             AND
             A.ID < 40000000--@spotIDsStartPoint
  WHERE   (
               (B.uDepth + B.dDepth)/2.0 <= 25
               AND
               ISNULL(B.xBldg,0) = 0
               AND
               ISNULL(B.xLRT ,0) = 0
               AND
               ISNULL(B.xRail ,0) = 0
               AND
               ISNULL(B.countxFrwy ,0) = 0
             )
  
EXEC REHAB.dbo.FinalTimesAPW
EXEC REHAB.dbo.FinalTimesBPW  
          
          
          
          
          
END


GO

