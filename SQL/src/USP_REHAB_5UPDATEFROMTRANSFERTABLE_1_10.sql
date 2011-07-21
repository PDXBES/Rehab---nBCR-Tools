USE [SANDBOX]
GO

/****** Object:  StoredProcedure [ROSE\issacg].[USP_REHAB_5UPDATEFROMTRANSFERTABLE_1_10]    Script Date: 07/21/2011 08:23:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [ROSE\issacg].[USP_REHAB_5UPDATEFROMTRANSFERTABLE_1_10] AS
BEGIN


UPDATE SANDBOX.GIS.REHAB10FTSEGS  SET 
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
	[ACTION]		= A.[ACTION],/*CASE WHEN A.[ACTION] > 5 
					THEN A.[ACTION] 
					ELSE CASE	WHEN	A.[Last_TV_Inspection] IS NULL 
										OR 
										A.[Insp_Curr] = 3 
										OR 
										A.[Insp_Curr] = 4  
								THEN 0 
								ELSE CASE	WHEN A.[RATING] <= 3 
											THEN 1 
											ELSE CASE	WHEN	A.[Fail_PCT] >= 10 
																AND 
																A.[Fail_NEAR] >= 2 
														THEN 2 
														ELSE CASE	WHEN A.[Fail_NEAR] = 0 
																	THEN 4 
																	ELSE 3 
															 END 
												 END 
									 END 
						 END 
				 END*/
	[fail_yr_whole] = NULL,
	[std_dev_whole] = NULL
FROM	REHAB_RedundancyTable AS A 
		INNER JOIN 
		SANDBOX.GIS.REHAB10FTSEGS AS B 
		ON	A.MLinkID = B.MLinkID 
			AND 
			A.MlinkID >= 40000000


END


GO

