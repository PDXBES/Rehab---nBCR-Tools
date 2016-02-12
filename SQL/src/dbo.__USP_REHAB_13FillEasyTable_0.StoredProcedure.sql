USE [REHAB]
GO
/****** Object:  StoredProcedure [dbo].[__USP_REHAB_13FillEasyTable_0]    Script Date: 02/12/2016 09:07:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[__USP_REHAB_13FillEasyTable_0] @AsOfDate datetime = NULL
AS
BEGIN
  SET NOCOUNT ON;
  IF @AsOfDate IS NULL
   SET @AsOfDate = GETDATE()
   
  DECLARE @MaxFailHorizon int = 20--40
  DECLARE @MaxFailYear int = YEAR(@AsOfDate) + @MaxFailHorizon
  DECLARE @HoursPerDay float = 8.0
  
  
  TRUNCATE TABLE REHAB.GIS.[nBCR_Data]
  
  --Insert the data from the old rehab10ftsegs table
  INSERT INTO REHAB.GIS.[nBCR_Data]
  (
  [ID]						,[XBJECTID]				,[GLOBALID]					,[compkey]
  ,[usnode]					,[dsnode]				,[UNITTYPE]					,[length]
  ,[diamWidth]				,[height]				,[pipeShape]				,[material]
  ,[newMaterial]			,[instdate]				,[hservstat]				,[cutno]
  ,[fm]						,[to_]					,[segmentLength]			,[grade_h5]
  ,[segmentCount]			,[failNear]				,[failPrev]					,[failTot]
  ,[failPct]				,[defPts]				,[defLin]					,[defTot]
  ,[FailureYear]			,[StdDev]				,[cof]						,[inspDate]
  ,[inspCurrent]			,[ownership]			,[SpotsToRepairBeforeLining],[lateralCount]			
  ,[lateralCost]			,[CostToSpotOnly]		,[CostToWholePipeOnly]		,[CostToLineOnly]			
  ,[spotRepairCount]		,[manholeCost]			,[ASMFailureAction]			,[ASMRecommendedAction]					  
  ,[ASMRecommendednBCR]		,[SpotCapitalCost]		,[WholePipeCapitalCost]		,[LinerCapitalCost]						
  ,[SpotCapitalRate]		,[WholePipeCapitalRate]	,[LinerCapitalRate]			,[SpotBaseTime]							 
  ,[WholePipeBaseTime]		,[LinerBaseTime]		,[SpotMobilizationTime]		,[WholePipeMobilizationTime]				
  ,[LinerMobilizationTime]	,[SpotnBCR]				,[LinernBCR]				,[WholenBCR]		
  ,[BPW]					,[APWSpot]				,[APWLiner]					,[APWWhole]			
  ,[problems]				,[geom]
  )
  SELECT 
  [ID],						[XBJECTID],				[GLOBALID],					[compkey]
 ,[usnode],					[dsnode],				[UNITTYPE],					[length]
 ,[diamwidth],				[height],				[pipeshape],				[material]
 ,[mat_fmto],				[instdate],				[hservstat],				[cutno]
 ,[fm],						[to_],					[seglen],					[grade_h5]
 ,[seg_count],				[fail_near],			[fail_prev],				[fail_tot]
 ,[fail_pct],				[def_pts],				[def_lin],					[def_tot]
 ,[fail_yr],				[std_dev],				[cof],						[insp_date]
 ,[insp_curr],				[remarks],				CASE WHEN [action] = 3 THEN 1 ELSE 0 END, [lateralCount] --Update spotsTo... as sum for whole pipes in next query
 ,[TotalLateralCost],		NULL,					NULL,						NULL
 ,[spotRepairCount],		[manholeCost],			NULL,						NULL
 ,NULL,						NULL,					NULL,						NULL
 ,NULL,						NULL,					NULL,						NULL
 ,NULL,						NULL,					NULL,						NULL
 ,NULL,						NULL,					NULL,						NULL
 ,NULL,						NULL,					NULL,						NULL
 ,NULL,						geom
  FROM Rehab.GIS.REHAB_Segments
  
  UPDATE  A
  SET     A.SpotsToRepairBeforeLining = SumOfSpots
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN
          ( 
            SELECT  Compkey,
                    SUM(SpotsToRepairBeforeLining) AS SumOfSpots    
		    FROM    REHAB.GIS.[nBCR_Data] 
		    WHERE   Cutno > 0
		    GROUP BY Compkey
		  ) AS B
          ON  A.Compkey = B.Compkey
              AND
              A.Cutno = 0
  
  --SpotCosts
  UPDATE  A
  SET     A.SpotCapitalCost = B.CapitalNonMobilization,
          A.SpotCapitalRate = B.CapitalMobilizationRate,
          A.SpotBaseTime = B.BaseTime/@HoursPerDay,
          A.SpotMobilizationTime = B.MobilizationTime/@HoursPerDay
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN
          [REHAB].[dbo].[COSTEST_CapitalCostsMobilizationRatesAndTimes] AS B
          ON  A.ID = B.ID
              AND
              B.[Type] = 'Spot'

  
  --WholePipe costs         
  UPDATE  A
  SET     A.WholePipeCapitalCost = B.CapitalNonMobilization,
          A.WholePipeCapitalRate = B.CapitalMobilizationRate,
          A.WholePipeBaseTime = B.BaseTime/@HoursPerDay,
          A.WholePipeMobilizationTime = B.MobilizationTime/@HoursPerDay
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN
          [REHAB].[dbo].[COSTEST_CapitalCostsMobilizationRatesAndTimes] AS B
          ON  A.ID = B.ID
              AND
              B.[Type] = 'Dig'
              
  --Liner costs         
  UPDATE  A
  SET     A.LinerCapitalCost = B.CapitalNonMobilization,
          A.LinerCapitalRate = B.CapitalMobilizationRate,
          A.LinerBaseTime = B.BaseTime/@HoursPerDay,
          A.LinerMobilizationTime = B.MobilizationTime/@HoursPerDay
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN
          [REHAB].[dbo].[COSTEST_CapitalCostsMobilizationRatesAndTimes] AS B
          ON  A.ID = B.ID
              AND
              B.[Type] = 'Line'
                
  UPDATE  A
  SET     A.CostToSpotOnly = A.SpotCapitalCost + SpotCapitalRate * (SpotBaseTime + SpotMobilizationTime),
          A.CostToWholePipeOnly = A.WholePipeCapitalCost + WholePipeCapitalRate * (WholePipeBaseTime + WholePipeMobilizationTime),
          A.CostToLineOnly = A.LinerCapitalCost + LinerCapitalRate * (LinerBaseTime + LinerMobilizationTime)
  FROM    REHAB.GIS.[nBCR_Data] AS A
              
  --Transfer the data from branches to the main table
  UPDATE  A
  SET     A.[problems] = B.[problems],
          A.MaxSegmentCOFwithoutReplacement = B.MaxSegmentCOFwithoutReplacement
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN
          REHAB.GIS.[REHAB_Branches] AS B
          ON  A.Compkey = B.Compkey 
  
  UPDATE  A
  SET     [ASMFailureAction] = 'Do nothing',
          [ASMRecommendedAction] = 'Do nothing'
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN
          REHAB.GIS.[nBCR_Data] AS B
          ON  A.Compkey = B.Compkey
              AND
              A.cutno > 0
              AND
              B.cutno = 0
              AND
              B.[FailureYear] > @MaxFailYear
  
  UPDATE  REHAB.GIS.[nBCR_Data]
  SET     [ASMFailureAction] = NULL
  WHERE   [grade_h5] > 3
          AND
          [ownership] IN ('BES')
          AND
          [FailureYear] <= @MaxFailYear
  
  UPDATE  REHAB.GIS.[nBCR_Data]
  SET     [ASMRecommendedAction] = 'Do Nothing'
          
  UPDATE  REHAB.GIS.[nBCR_Data]
  SET     [ASMRecommendedAction] = B.ASM_Gen3Solution
          ,[ASMRecommendednBCR] = B.ASM_Gen3SolutionnBCR
          ,[SpotnBCR] = CASE
                          WHEN ASM_Gen3Solution = 'OC Sandwich'
                          THEN NULL
                          WHEN ASM_Gen3Solution = 'Do Nothing'
                          THEN NULL
                          WHEN ASM_Gen3Solution = 'OC'
                          THEN B.nBCR_OC_SP
                          WHEN ASM_Gen3Solution = 'SP'
                          THEN B.nBCR_SP_SP
                          WHEN ASM_Gen3Solution = 'CIPP'
                          THEN B.nBCR_CIPP_SP
                          WHEN ASM_Gen3Solution = 'Not linable'
                          THEN B.nBCR_OC_SP
                        END
          ,[LinernBCR] = CASE
                          WHEN ASM_Gen3Solution = 'OC Sandwich'
                          THEN NULL
                          WHEN ASM_Gen3Solution = 'Do Nothing'
                          THEN NULL
                          WHEN ASM_Gen3Solution = 'OC'
                          THEN B.nBCR_OC_CIPP
                          WHEN ASM_Gen3Solution = 'SP'
                          THEN B.nBCR_SP_CIPP
                          WHEN ASM_Gen3Solution = 'CIPP'
                          THEN B.nBCR_CIPP_CIPP
                          WHEN ASM_Gen3Solution = 'Not linable'
                          THEN NULL
                        END
          ,[WholenBCR] = CASE
                          WHEN ASM_Gen3Solution = 'OC Sandwich'
                          THEN B.nBCR_OC_OC
                          WHEN ASM_Gen3Solution = 'Do Nothing'
                          THEN NULL
                          WHEN ASM_Gen3Solution = 'OC'
                          THEN B.nBCR_OC_OC
                          WHEN ASM_Gen3Solution = 'SP'
                          THEN B.nBCR_SP_OC
                          WHEN ASM_Gen3Solution = 'CIPP'
                          THEN B.nBCR_CIPP_OC
                          WHEN ASM_Gen3Solution = 'Not linable'
                          THEN B.nBCR_OC_OC
                        END
          ,[BPW] = CASE   
                          WHEN ASM_Gen3Solution = 'Do Nothing'
                          THEN NULL
                          WHEN ASM_Gen3Solution = 'OC'
                          THEN B.BPWOC
                          WHEN ASM_Gen3Solution = 'SP'
                          THEN B.BPWSP
                          WHEN ASM_Gen3Solution = 'CIPP'
                          THEN B.BPWCIPP
                          WHEN ASM_Gen3Solution = 'Not linable'
                          THEN B.BPWOC
                          WHEN ASM_Gen3Solution = 'OC Sandwich'
                          THEN B.BPWOC
                        END
          ,[APWSpot] = B.APWSP
          ,[APWLiner] = B.APWCIPP
          ,[APWWhole] = B.APWOC
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN
          REHAB.GIS.REHAB_Branches AS B
          ON  A.COMPKEY = B.COMPKEY
  WHERE   [grade_h5] > 3
          AND
          [ownership] IN ('BES')
          AND
          B.InitialFailYear <= @MaxFailYear
          AND
          SpotRepairCount > 0
          AND
          cutno = 0
          
  UPDATE  REHAB.GIS.[nBCR_Data]
  SET     [ASMFailureAction] = ISNULL([ASMFailureAction],'') + '(PEND)'        
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN
          REHAB.GIS.REHAB_Segments AS B
          ON  A.COMPKEY = B.COMPKEY
  WHERE   B.hSERVSTAT = 'PEND'
  
  --If the nBCR is less than 0.1 and grade > 3, recommend 'Watch Me'
  UPDATE  REHAB.GIS.[nBCR_Data]
  SET     [ASMRecommendedAction] = 'Watch me'
  FROM    REHAB.GIS.[nBCR_Data] AS A
  WHERE   grade_h5 > 3
          AND
          (
            [ASMRecommendednBCR] < 0.1
            OR
            FailureYear > @MaxFailYear
            OR
            [ASMFailureAction] like '%(PEND)%'
            OR
            SpotRepairCount = 0
          )
          
  
          
  --Make sure any segments of a pipe reflect the whole pipe.
  UPDATE  A
  SET     A.[ASMRecommendedAction] = B.[ASMRecommendedAction]
          ,A.[ASMRecommendednBCR] = B.[ASMRecommendednBCR]
          ,A.[SpotnBCR] = B.[SpotnBCR]
          ,A.[LinernBCR] = B.[LinernBCR]
          ,A.[WholenBCR] = B.[WholenBCR]
          ,A.[BPW] = B.[BPW]
          ,A.[APWSpot] = B.[APWSpot]
          ,A.[APWLiner] = B.[APWLiner]
          ,A.[APWWhole] = B.[APWWhole]
  FROM    REHAB.GIS.[nBCR_Data] AS A
          INNER JOIN     
          REHAB.GIS.[nBCR_Data] AS B
          ON  A.Compkey = B.Compkey
              AND
              B.Cutno = 0
              AND
              A.Cutno > 0
  
         
  

          
  
  
END
GO
