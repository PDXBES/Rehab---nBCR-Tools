USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[COST_ESTIMATOR_SIMPLIFY]    Script Date: 03/23/2016 14:12:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:    Gardner, Issac
-- Create date: 12/4/2015
-- Description:  This stored procedure will be the launching point
-- for the SQL version of the Cost Estimator.  If possible, all of the Cost Estimator
-- algorithms will be referenced in or placed within this stored procedure.

--Tables used by this stored procedure:
--
--[Rehab10FtSegs]
--
-- =============================================

CREATE PROCEDURE [dbo].[COST_ESTIMATOR_SIMPLIFY] @inputCOMPKEY INT = 0
AS
BEGIN
  DECLARE @FactorA INT = 1.5
  DECLARE @CubicFeetPerCubicYard FLOAT = 27
  DECLARE @SquareFeetPerSquareYard  FLOAT = 9
  DECLARE @SquareFeetPerAcre FLOAT = 43560
  DECLARE @InchesPerYard FLOAT = 36
  DECLARE @InchesPerFoot FLOAT = 12
  DECLARE @PipeZoneDepthAdditionalInches FLOAT = 18
  DECLARE @MaxManholeDepth FLOAT = 25
  DECLARE @PipeMainlineBuildRate FLOAT = 140.0 --cubic yards per day
  DECLARE @ManholeBuildRate FLOAT = 10.0 --ft per day
  DECLARE @UtilityCrossingRate FLOAT = 0.5 --days/crossing
  DECLARE @PavementRepairRate FLOAT = 250 -- Ft/day
  DECLARE @SlowBoreRate FLOAT = 75 -- Ft/day
  DECLARE @FastBoreRate FLOAT = 125 -- Ft/day
  DECLARE @BoringJackingCost FLOAT = 566.95 -- Dollars/thing
  DECLARE @BaseENR FLOAT = 8090
  DECLARE @CurrentENR FLOAT = 9835
  DECLARE @JackingENR FLOAT = 9500
  DECLARE @GeneralConditionsFactor FLOAT = 0.1
  DECLARE @WasteAllowanceFactor FLOAT = 0.05
  DECLARE @ContingencyFactor FLOAT = 0.25
  DECLARE @ConstructionManagementInspectionTestingFactor FLOAT = 0.15
  DECLARE @DesignFactor FLOAT = 0.2
  DECLARE @PublicInvolvementInstrumentationAndControlsEasementEnvironmentalFactor FLOAT = 0.03
  DECLARE @StartupCloseoutFactor FLOAT = 0.01
  DECLARE @MinShoringDepth FLOAT = 18.0
  DECLARE @daysForSegmentLinerConstruction FLOAT = 1.0
  DECLARE @daysForWholePipeLinerConstruction FLOAT = 3.0
  DECLARE @hoursPerDay FLOAT = 8.0
  
  TRUNCATE TABLE COSTEST_PIPE
  
  INSERT INTO COSTEST_PIPE 
    (
       [ID]
      ,[Type]
      ,[GLOBALID]
      ,[USNode]
      ,[DSNode]
      ,[DirectConstructionCost]
      ,[TotalConstructionCost]
      ,[PipelineBuildDuration]
    )
  SELECT 
       [ID]
      ,'S'
      ,[GLOBALID]
      ,NULL--[USNode]
      ,NULL--[DSNode]
      ,0
      ,CapitalNonMobilization + CapitalMobilizationRate * (MobilizationTime + BaseTime)/@hoursPerDay
      ,(MobilizationTime + BaseTime)/@hoursPerDay
  FROM COSTEST_CapitalCostsMobilizationRatesAndTimes
  WHERE ID >= 40000000
  
  INSERT INTO COSTEST_PIPE 
    (
       [ID]
      ,[Type]
      ,[GLOBALID]
      ,[USNode]
      ,[DSNode]
      ,[DirectConstructionCost]
      ,[TotalConstructionCost]
      ,[PipelineBuildDuration]
    )
  SELECT 
       [ID]
      ,'W'
      ,[GLOBALID]
      ,NULL--[USNode]
      ,NULL--[DSNode]
      ,0
      ,CapitalNonMobilization + CapitalMobilizationRate * (MobilizationTime + BaseTime)/@hoursPerDay
      ,(MobilizationTime + BaseTime)/@hoursPerDay
  FROM COSTEST_CapitalCostsMobilizationRatesAndTimes
  WHERE ID < 40000000
        AND
        [Type] = 'Dig'
  
  INSERT INTO COSTEST_PIPE 
    (
       [ID]
      ,[Type]
      ,[GLOBALID]
      ,[USNode]
      ,[DSNode]
      ,[DirectConstructionCost]
      ,[TotalConstructionCost]
      ,[PipelineBuildDuration]
    )
  SELECT 
       [ID]
      ,'L'
      ,[GLOBALID]
      ,NULL--[USNode]
      ,NULL--[DSNode]
      ,0
      ,CapitalNonMobilization + CapitalMobilizationRate * (MobilizationTime + BaseTime)/@hoursPerDay
      ,(MobilizationTime + BaseTime)/@hoursPerDay
  FROM COSTEST_CapitalCostsMobilizationRatesAndTimes
  WHERE ID < 40000000
        AND
        [Type] = 'Line'
  
END


GO

