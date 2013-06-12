USE [REHAB]
GO
/****** Object:  StoredProcedure [dbo].[USP_REHAB_6UPDATEFROMTRANSFERTABLE_2_10]    Script Date: 06/12/2013 12:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER procedure [dbo].[USP_REHAB_6UPDATEFROMTRANSFERTABLE_2_10] AS
BEGIN
--These checks are to prevent overflow.  If someone enters ridiculous values for pipe worth or repair costs,
--the entire process would break.  Setting the values to max allows us to query out the ridiculous numbers
--while allowing the process to continue on the data that is valid.
UPDATE REHAB_RedundancyTableWhole SET [APW] = 2147483647 WHERE [APW] > 2147483647
UPDATE REHAB_RedundancyTableWhole SET apw_seg = 2147483647 WHERE apw_seg > 2147483647
UPDATE REHAB_RedundancyTableWhole SET [Replacement_Cost] = 2147483647 WHERE [Replacement_Cost] > 2147483647


--UPDATE REHAB_RedundancyTableWhole SET apw_seg = 2147483647 WHERE apw_seg > 2147483647
UPDATE GIS.REHAB10FTSEGS  SET 
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
FROM  REHAB_RedundancyTableWhole AS A INNER JOIN GIS.REHAB10FTSEGS AS B ON A.MLinkID = B.MLinkID AND A.MlinkID < 40000000

--Joe requested that this be the process for action 3 whole pipes
UPDATE	GIS.REHAB10FTSEGS 
SET		BPW = BPW_SEG,  
		APW = APW_SEG, 
		[CBR] = CBR_SEG 
WHERE	ACTION = 3 
		AND 
		MLINKID < 40000000

UPDATE	GIS.REHAB10FTSEGS 
SET		remarks = ''

--Identify ownership of all pipes.  
--Use an underscore because later we will give a special precendence to some BES pipes
UPDATE	GIS.REHAB10FTSEGS 
SET		remarks = '_' + ISNULL(B.OWN, 'NULL') 
FROM	GIS.REHAB10FTSEGS AS A 
		INNER JOIN 
		HA8_COMPSMN AS B	
		ON	A.COMPKEY = B.COMPKEY 

--Identify the sanitary pipes as BES owned
UPDATE	GIS.REHAB10FTSEGS 
SET		remarks = ISNULL(B.OWN, 'NULL')
FROM	GIS.REHAB10FTSEGS AS A 
		INNER JOIN 
		HA8_COMPSMN AS B	
		ON	A.COMPKEY = B.COMPKEY 
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
UPDATE	GIS.REHAB10FTSEGS 
SET		remarks = 'BES' 
FROM	GIS.REHAB10FTSEGS AS A 
		INNER JOIN 
		HA8_COMPSTMN AS B 
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
			A.COMPKEY IN (
							SELECT	HA8_COMPSTMN.COMPKEY
							FROM	HA8_COMPSTMN 
									INNER JOIN
									HA8_COPSTORMMAIN 
									ON	HA8_COMPSTMN.COMPKEY = HA8_COPSTORMMAIN.COMPKEY 
									INNER JOIN
									HA8_COPSTMNALTGRD 
									ON	HA8_COPSTORMMAIN.COPSTORMMAINKEY = HA8_COPSTMNALTGRD.COPSTORMMAINKEY
							WHERE	HA8_COMPSTMN.COMPKEY > 1
									AND
									HA8_COPSTMNALTGRD.ALTIDTYP='OFID'
						)

--Just in case the previous 'BES' queries missed something based
--upon the differences in whole pipes and segments...
--I don't think this query is necessary, it should probably be removed.
UPDATE B SET remarks = 'BES' FROM GIS.REHAB10FTSEGS AS A INNER JOIN GIS.REHAB10FTSEGS AS B ON A.COMPKEY = B.COMPKEY AND A.MlinkID < 40000000 AND B.MlinkID >=40000000 AND A.remarks = 'BES'

--These are action based fail_yr_whole and rulife values that 
--Joe requested be placed in the table.  These override any
--calculated values from earlier.  Thankfully, Fail_yr_whole and RUlife aren't actually source
--for any calculations (yet).
UPDATE GIS.REHAB10FTSEGS  SET Fail_yr_whole = year(getdate())+30, RULife = 30 WHERE ACTION = 3 AND MlinkID < 40000000
UPDATE GIS.REHAB10FTSEGS  SET Fail_yr_whole = year(getdate())+120, RULife = 0 WHERE ACTION = 2 AND MlinkID < 40000000
UPDATE GIS.REHAB10FTSEGS  SET Fail_yr_whole = year(getdate())+120, RULife = 120 WHERE ACTION = 6 AND MlinkID < 40000000
UPDATE GIS.REHAB10FTSEGS  SET Fail_yr_whole = year(getdate())+120, RULife = 120 WHERE ACTION = 7 AND MlinkID < 40000000
UPDATE GIS.REHAB10FTSEGS  SET Fail_yr_whole = year(getdate())+120, RULife = 120 WHERE ACTION = 8 AND MlinkID < 40000000

--This query has been moved to USP_REHAB_2IDENTIFYSPOTREPAIRSFASTER_10 because that is where the 
--Action flags are now being updated.
--UPDATE SANDBOX.dbo.GIS.REHAB10FTSEGS SET [ACTION] = 5 FROM SANDBOX.dbo.GIS.REHAB10FTSEGS INNER JOIN REHAB_Flag5Table ON SANDBOX.dbo.GIS.REHAB10FTSEGS.COMPKEY = REHAB_Flag5Table.COMPKEY

UPDATE GIS.REHAB10FTSEGS SET ACTION = 12 WHERE ACTION = 3 AND MLINKID >40000000 AND def_tot < 1000

UPDATE GIS.REHAB10FTSEGS SET CBR_RANK = NULL, CBRSEG_RANK = NULL, BPW_RANK = NULL, BPWSEG_RANK = NULL

UPDATE GIS.REHAB10FTSEGS SET CBR_RANK = POS
FROM	GIS.REHAB10FTSEGS INNER JOIN
		(
			SELECT MLinkID, ROW_NUMBER() OVER(ORDER BY CBR DESC) AS POS
			FROM GIS.REHAB10FTSEGS
			WHERE   MLinkID < 40000000
					AND action in (2,6,7,8)
					AND REMARKS = 'BES'
		) AS A ON GIS.REHAB10FTSEGS.MLinkID = A.MLinkID

UPDATE GIS.REHAB10FTSEGS SET CBRSEG_RANK = POS
FROM	GIS.REHAB10FTSEGS INNER JOIN
		(
			SELECT MLinkID, ROW_NUMBER() OVER(ORDER BY CBR_Seg DESC) AS POS
			FROM GIS.REHAB10FTSEGS
			WHERE   MLinkID >= 40000000
					AND action in (2,3,6,7,8)
					AND REMARKS = 'BES'
		) AS A ON GIS.REHAB10FTSEGS.MLinkID = A.MLinkID

UPDATE GIS.REHAB10FTSEGS SET BPW_RANK = POS
FROM	GIS.REHAB10FTSEGS INNER JOIN
		(
			SELECT MLinkID, ROW_NUMBER() OVER(ORDER BY BPW/[length] DESC) AS POS
			FROM GIS.REHAB10FTSEGS
			WHERE   MLinkID < 40000000
					AND action in (2,6,7,8)
					AND REMARKS = 'BES'
		) AS A ON GIS.REHAB10FTSEGS.MLinkID = A.MLinkID

UPDATE GIS.REHAB10FTSEGS SET BPWSEG_RANK = POS
FROM	GIS.REHAB10FTSEGS INNER JOIN
		(
			SELECT MLinkID, ROW_NUMBER() OVER(ORDER BY BPW_SEG/[length] DESC) AS POS
			FROM GIS.REHAB10FTSEGS
			WHERE   MLinkID >= 40000000
					AND action in (2,3,6,7,8)
					AND REMARKS = 'BES'
		) AS A ON GIS.REHAB10FTSEGS.MLinkID = A.MLinkID

END



