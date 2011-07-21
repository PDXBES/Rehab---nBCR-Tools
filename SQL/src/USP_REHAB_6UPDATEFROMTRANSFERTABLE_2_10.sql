USE [SANDBOX]
GO

/****** Object:  StoredProcedure [ROSE\issacg].[USP_REHAB_6UPDATEFROMTRANSFERTABLE_2_10]    Script Date: 07/21/2011 08:23:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [ROSE\issacg].[USP_REHAB_6UPDATEFROMTRANSFERTABLE_2_10] AS
BEGIN
--These checks are to prevent overflow.  If someone enters ridiculous values for pipe worth or repair costs,
--the entire process would break.  Setting the values to max allows us to query out the ridiculous numbers
--while allowing the process to continue on the data that is valid.
UPDATE REHAB_RedundancyTableWhole SET [APW] = 2147483647 WHERE [APW] > 2147483647
UPDATE REHAB_RedundancyTableWhole SET apw_seg = 2147483647 WHERE apw_seg > 2147483647
UPDATE REHAB_RedundancyTableWhole SET [Replacement_Cost] = 2147483647 WHERE [Replacement_Cost] > 2147483647


--UPDATE REHAB_RedundancyTableWhole SET apw_seg = 2147483647 WHERE apw_seg > 2147483647
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
	[ACTION] 		= A.[ACTION],/*CASE WHEN A.[ACTION] > 5 THEN A.[ACTION] ELSE CASE WHEN A.[Last_TV_Inspection] IS NULL OR A.[Insp_Curr] = 3 OR A.[Insp_Curr] = 4  THEN 0 ELSE CASE WHEN ( A.[RATING] <= 3) THEN 1 ELSE CASE WHEN A.[Fail_PCT] >= 10 AND A.[Fail_NEAR] >= 2 THEN 2 ELSE CASE WHEN A.[Fail_NEAR] = 0 THEN 4 ELSE 3 END END END END END,*/
	[fail_yr_whole] = A.[failure_year] + 120,
	[std_dev_whole] = 12
FROM  REHAB_RedundancyTableWhole AS A INNER JOIN SANDBOX.GIS.REHAB10FTSEGS AS B ON A.MLinkID = B.MLinkID AND A.MlinkID < 40000000

--Joe requested that this be the process for action 3 whole pipes
--He was pretty caffeinated and not using complete sentences, so you're
--going to have to ask him about this one.
UPDATE	SANDBOX.GIS.REHAB10FTSEGS 
SET		BPW = BPW_SEG,  
		APW = APW_SEG, 
		[CBR] = CBR_SEG 
WHERE	ACTION = 3 
		AND 
		MLINKID < 40000000

UPDATE	SANDBOX.GIS.REHAB10FTSEGS 
SET		remarks = ''

--Identify the sanitary pipes as BES owned
UPDATE	SANDBOX.GIS.REHAB10FTSEGS 
SET		remarks = 'BES' 
FROM	SANDBOX.GIS.REHAB10FTSEGS AS A 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS B	
		ON	A.COMPKEY = B.COMPKEY 
			AND 
			B.OWN = 'BES'
			AND 
			(
				B.UnitType = 'saml' 
				OR 
				B.UnitType = 'csml' 
				OR 
				B.UnitType = 'csint' 
				OR 
				B.UnitType = 'saint' 
				OR 
				B.UnitType = 'csdet' 
				OR 
				B.UnitType = 'csotn' 
				OR 
				B.UnitType = 'embpg'
			) 
			AND 
			B.ServStat <> 'ABAN' 
			AND 
			B.ServStat <> 'TBAB' 
			AND 
			PATINDEX('[A-Z][A-Z][A-Z][0-9][0-9][0-9]',USNODE) > 0 
			AND 
			PATINDEX('[A-Z][A-Z][A-Z][0-9][0-9][0-9]',DSNODE) > 0 

--Identify the storm pipes as BES owned
UPDATE	SANDBOX.GIS.REHAB10FTSEGS 
SET		remarks = 'BES' 
FROM	SANDBOX.GIS.REHAB10FTSEGS AS A 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS B 
		ON	A.COMPKEY = B.COMPKEY 
			AND 
			B.OWN = 'BES' 
			AND 
			(B.UnitType = 'stml' OR B.UnitType = 'csml' OR B.UnitType = 'csint' OR B.UnitType = 'saint' OR B.UnitType = 'csdet' OR B.UnitType = 'csotn' OR B.UnitType = 'embpg') 
			AND 
			B.ServStat <> 'ABAN' 
			AND 
			B.ServStat <> 'TBAB' 
			AND 
			PATINDEX('[A-Z][A-Z][A-Z][0-9][0-9][0-9]',USNODE) > 0 
			AND 
			PATINDEX('[A-Z][A-Z][A-Z][0-9][0-9][0-9]',DSNODE) > 0 
			AND  
			A.COMPKEY IN (SELECT COMPKEY FROM [SIRTOBY].[HANSEN].[IMSV7].VARGALT WHERE ALTIDTYP='OFID')

--Just in case the previous 'BES' queries missed something based
--upon the differences in whole pipes and segments...
--I don't think this query is necessary, it should probably be removed.
UPDATE B SET remarks = 'BES' FROM SANDBOX.GIS.REHAB10FTSEGS AS A INNER JOIN SANDBOX.GIS.REHAB10FTSEGS AS B ON A.COMPKEY = B.COMPKEY AND A.MlinkID < 40000000 AND B.MlinkID >=40000000 AND A.remarks = 'BES'

--These are action based fail_yr_whole and rulife values that 
--Joe requested be placed in the table.  These override any
--calculated values from earlier.  Thankfully, Fail_yr_whole and RUlife aren't actually source
--for any calculations (yet).
UPDATE SANDBOX.GIS.REHAB10FTSEGS  SET Fail_yr_whole =2040, RULife = 30 WHERE ACTION = 3 AND MlinkID < 40000000
UPDATE SANDBOX.GIS.REHAB10FTSEGS  SET Fail_yr_whole =2130, RULife = 0 WHERE ACTION = 2 AND MlinkID < 40000000
UPDATE SANDBOX.GIS.REHAB10FTSEGS  SET Fail_yr_whole =2130, RULife = 120 WHERE ACTION = 6 AND MlinkID < 40000000
UPDATE SANDBOX.GIS.REHAB10FTSEGS  SET Fail_yr_whole =2130, RULife = 120 WHERE ACTION = 7 AND MlinkID < 40000000
UPDATE SANDBOX.GIS.REHAB10FTSEGS  SET Fail_yr_whole =2130, RULife = 120 WHERE ACTION = 8 AND MlinkID < 40000000

--This query has been moved to USP_REHAB_2IDENTIFYSPOTREPAIRSFASTER_10 because that is where the 
--Action flags are now being updated.
--UPDATE SANDBOX.GIS.REHAB10FTSEGS SET [ACTION] = 5 FROM SANDBOX.GIS.REHAB10FTSEGS INNER JOIN REHAB_Flag5Table ON SANDBOX.GIS.REHAB10FTSEGS.COMPKEY = REHAB_Flag5Table.COMPKEY


END


GO

