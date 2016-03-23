USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[__USP_REHAB_09RedundancyToSegments]    Script Date: 03/23/2016 14:10:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[__USP_REHAB_09RedundancyToSegments] @TableSize INT = -1
AS
BEGIN

IF (@TableSize = -1)
BEGIN
UPDATE GIS.REHAB_Segments  SET 
	[MAT_FmTo]		= A.[MAT_FmTo],
	[Seg_Count]		= A.[Seg_Count],
	[Fail_NEAR]		= A.[Fail_NEAR],
	[Fail_PREV]		= A.[Fail_PREV],
	[Fail_TOT]		= A.[Fail_TOT],
	[Fail_PCT]		= A.[Fail_PCT],
	[Def_PTS]		= A.[Point_Defect_Score],
	[Def_LIN]		= A.[Linear_Defect_Score],
	[Def_TOT]		= A.[Total_Defect_Score],
	[BPW]			= A.[BPW],
	[APW]			= A.[APW],
	[CBR]			= A.[CBR],
	[INSP_DATE]		= A.[Last_TV_Inspection],
	[INSP_YRSAGO]	= A.[Years_Since_Inspection],
	[INSP_CURR]		= A.[Insp_Curr],
	[Fail_YR]		= A.[Failure_Year],
	[RULife]		= A.[RULife],
	[RUL_Flag]		= A.[RUL_Flag],
	[Std_DEV]		= A.[Std_dev],
	[COF]			= A.[Consequence_Failure],
	[ReplaceCost]	= A.[Replacement_Cost],
    [bpw_seg]		= A.[bpw_seg],
	[apw_seg]		= A.[apw_seg],
	[cbr_seg]		= A.[cbr_seg],
	[std_dev_seg]	= A.[std_dev_seg],
	[fail_yr_seg]	= A.[fail_yr_seg],
	[grade_h5]		= A.[RATING],
	[HSERVSTAT]		= A.[HSERVSTAT],
	[ACTION]		= A.[ACTION],
	[fail_yr_whole] = NULL,
	[std_dev_whole] = NULL,
	[LPW] = A.LPW,
	[cbr_Liner] = A.cbr_Liner,
	[TotalLateralCost] = A.[TotalLateralCost],
	[SegmentLateralCost] = A.[SegmentLateralCost] ,
	[RepairLateralCost] = A.[RepairLateralCost] ,
	[LateralCount] = A.[LateralCount] ,
	[SpotRepairCount] = A.[SpotRepairCount] ,
	[LineCostTotal] = A.[LineCostTotal] ,
	[SpotCostTotal] = A.[SpotCostTotal] ,
	[ReplaceCostTotal] = A.[ReplaceCostTotal] ,
	SpotCost = A.SpotCost,
	LineCostNoSegsNoLats = A.LineCostNoSegsNoLats,
	ManholeCost = A.ManholeCost
FROM	REHAB_RedundancyTable AS A 
		INNER JOIN 
		GIS.REHAB_Segments AS B 
		ON	A.ID = B.ID 
END
ELSE
BEGIN
UPDATE GIS.Rehab10FtSegs_Subset_out  SET 
	[MAT_FmTo]		= A.[MAT_FmTo],
	[Seg_Count]		= A.[Seg_Count],
	[Fail_NEAR]		= A.[Fail_NEAR],
	[Fail_PREV]		= A.[Fail_PREV],
	[Fail_TOT]		= A.[Fail_TOT],
	[Fail_PCT]		= A.[Fail_PCT],
	[Def_PTS]		= A.[Point_Defect_Score],
	[Def_LIN]		= A.[Linear_Defect_Score],
	[Def_TOT]		= A.[Total_Defect_Score],
	[BPW]			= A.[BPW],
	[APW]			= A.[APW],
	[CBR]			= A.[CBR],
	[INSP_DATE]		= A.[Last_TV_Inspection],
	[INSP_YRSAGO]	= A.[Years_Since_Inspection],
	[INSP_CURR]		= A.[Insp_Curr],
	[Fail_YR]		= A.[Failure_Year],
	[RULife]		= A.[RULife],
	[RUL_Flag]		= A.[RUL_Flag],
	[Std_DEV]		= A.[Std_dev],
	[COF]			= A.[Consequence_Failure],
	[ReplaceCost]	= A.[Replacement_Cost],
    [bpw_seg]		= A.[bpw_seg],
	[apw_seg]		= A.[apw_seg],
	[cbr_seg]		= A.[cbr_seg],
	[std_dev_seg]	= A.[std_dev_seg],
	[fail_yr_seg]	= A.[fail_yr_seg],
	[grade_h5]		= A.[RATING],
	[HSERVSTAT]		= A.[HSERVSTAT],
	[ACTION]		= A.[ACTION],
	[fail_yr_whole] = NULL,
	[std_dev_whole] = NULL,
	[LPW] = A.LPW,
	[cbr_Liner] = A.cbr_Liner,
	[TotalLateralCost] = A.[TotalLateralCost],
	[SegmentLateralCost] = A.[SegmentLateralCost] ,
	[RepairLateralCost] = A.[RepairLateralCost] ,
	[LateralCount] = A.[LateralCount] ,
	[SpotRepairCount] = A.[SpotRepairCount] ,
	[LineCostTotal] = A.[LineCostTotal] ,
	[SpotCostTotal] = A.[SpotCostTotal] ,
	[ReplaceCostTotal] = A.[ReplaceCostTotal] ,
	SpotCost = A.SpotCost,
	LineCostNoSegsNoLats = A.LineCostNoSegsNoLats,
	ManholeCost = A.ManholeCost
FROM	REHAB_RedundancyTable AS A 
		INNER JOIN 
		GIS.Rehab10FtSegs_Subset_out AS B 
		ON	A.ID = B.ID 
END

UPDATE GIS.REHAB_Segments  SET 
	[MAT_FmTo]		= A.[MAT_FmTo],
	[Seg_Count]		= A.[Seg_Count],
	[Fail_NEAR]		= A.[Fail_NEAR],
	[Fail_PREV]		= A.[Fail_PREV],
	[Fail_TOT]		= A.[Fail_TOT],
	[Fail_PCT]		= A.[Fail_PCT],
	[Def_PTS]		= A.[Point_Defect_Score],
	[Def_LIN]		= A.[Linear_Defect_Score],
	[Def_TOT]		= A.[Total_Defect_Score],
	[BPW]			= A.[BPW],
	[APW]			= A.[APW],
	[CBR]			= A.[CBR],
	[INSP_DATE]		= A.[Last_TV_Inspection],
	[INSP_YRSAGO]	= A.[Years_Since_Inspection],
	[INSP_CURR]		= A.[Insp_Curr],
	[Fail_YR]		= A.[Failure_Year],
	[RULife]		= A.[RULife],
	[RUL_Flag]		= A.[RUL_Flag],
	[Std_DEV]		= A.[Std_dev],
	[COF]			= A.[Consequence_Failure],
	[ReplaceCost]	= A.[Replacement_Cost],
    [bpw_seg]		= A.[bpw_seg],
	[apw_seg]		= A.[apw_seg],
	[cbr_seg]		= A.[cbr_seg],
	[std_dev_seg]	= A.[std_dev_seg],
	[fail_yr_seg]	= A.[fail_yr_seg],
	[grade_h5]		= A.[RATING],
	[HSERVSTAT]		= A.[HSERVSTAT],
	[ACTION] 		= A.[ACTION],
	[fail_yr_whole] = A.[failure_year] + 120,
	[std_dev_whole] = 12,
	[LPW] = A.LPW,
	[cbr_Liner] = A.cbr_Liner, 
	LinerCost = A.Liner_Cost,
	[TotalLateralCost] = A.[TotalLateralCost],
	[SegmentLateralCost] = A.[SegmentLateralCost] ,
	[RepairLateralCost] = A.[RepairLateralCost] ,
	[LateralCount] = A.[LateralCount] ,
	[SpotRepairCount] = A.[SpotRepairCount] ,
	[LineCostTotal] = A.[LineCostTotal] ,
	[SpotCostTotal] = A.[SpotCostTotal] ,
	[ReplaceCostTotal] = A.[ReplaceCostTotal] ,
	SpotCost = A.SpotCost,
	LineCostNoSegsNoLats = A.LineCostNoSegsNoLats,
	ManholeCost = A.ManholeCost
FROM  REHAB_RedundancyTableWhole AS A INNER JOIN GIS.REHAB_Segments AS B ON A.GLOBALID = B.GLOBALID AND B.ID < 40000000

END



GO

