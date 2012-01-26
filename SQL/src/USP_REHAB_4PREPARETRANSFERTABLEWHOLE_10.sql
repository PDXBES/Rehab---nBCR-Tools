USE [REHAB]
GO

/****** Object:  StoredProcedure [GIS].[USP_REHAB_4PREPARETRANSFERTABLEWHOLE_10]    Script Date: 01/25/2012 15:31:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [GIS].[USP_REHAB_4PREPARETRANSFERTABLEWHOLE_10] AS
BEGIN

DELETE FROM  REHAB_RedundancyTableWhole

INSERT INTO  REHAB_RedundancyTableWhole 
SELECT 
	MAX(OLD_MLID)	AS	MAPINFO_ID, 
	MAX(UsNode)		AS	USNode, 
	MAX(DSNode)		AS	DSNode, 
	MIN(MLinkID)	AS	MLinkID, 
	MAX(REHAB_RedundancyTable.CompKey)		AS	Compkey, 
	SUM(REHAB_RedundancyTable.[Length])		AS	[Length], 
	MAX(REHAB_RedundancyTable.DiamWidth)	AS	DiamWidth, 
	MAX(REHAB_RedundancyTable.Height)		AS	Height, 
	MAX(REHAB_RedundancyTable.Shape)		AS	Shape, 
	MAX(REHAB_RedundancyTable.Material)		AS	Material, 
	MAX(REHAB_RedundancyTable.Instdate)		AS	Instdate, 
	NULL As IsSpecLink, 
	MAX(REHAB_RedundancyTable.HServStat)	AS	HServStat, 
	MAX(REHAB_RedundancyTable.OLD_MLID)		AS	OLD_MLID, 
	0 AS SplitID, 
	MAX(REHAB_RedundancyTable.SplitTyp)		AS	SplitTyp, 
	0	AS	CutNo, 
	0	AS	FM, 
	SUM(REHAB_RedundancyTable.[Length])		AS	[TO], 
	SUM(REHAB_RedundancyTable.[SegLen])		AS	SegLen, 
	''	AS	MAT_FmTo, 
	MAX(REHAB_RedundancyTable.Seg_Count)	AS	Seg_Count, 
	MAX(REHAB_RedundancyTable.Fail_NEAR)	AS	Fail_NEAR, 
	MAX(REHAB_RedundancyTable.Fail_PREV)	AS	Fail_PREV,
	MAX(REHAB_RedundancyTable.Fail_TOT)		AS	Fail_TOT, 
	MAX(REHAB_RedundancyTable.Fail_PCT)		AS	Fail_PCT, 
	SUM(REHAB_RedundancyTable.Def_PTS)		AS	Def_PTS, 
	SUM(REHAB_RedundancyTable.Def_LIN)		AS	Def_LIN, 
	SUM(REHAB_RedundancyTable.Def_TOT)		AS	Def_TOT, 
	SUM(REHAB_RedundancyTable.BPW)			AS	BPW, 
	SUM(REHAB_RedundancyTable.APW)			AS	APW, 
	(CASE WHEN SUM(CAST(REHAB_RedundancyTable.Replacement_Cost AS FLOAT)) = 0 THEN NULL ELSE SUM(CAST(REHAB_RedundancyTable.BPW_Seg-REHAB_RedundancyTable.APW_Seg AS FLOAT))/SUM(CAST(REHAB_RedundancyTable.Replacement_Cost AS FLOAT)) END) AS CBR,
	MIN(REHAB_RedundancyTable.RULife)		AS	RULife, 
	MAX(REHAB_RedundancyTable.RUL_Flag)		AS	RUL_Flag, 
	SUM(REHAB_RedundancyTable.Point_Defect_Score)		AS	Point_Defect_Score, 
	SUM(REHAB_RedundancyTable.Linear_Defect_Score)		AS	Linear_Defect_Score, 
	SUM(REHAB_RedundancyTable.Total_Defect_Score)		AS	Total_Defect_Score,
	SUM(REHAB_RedundancyTable.Total_Defect_Score_x15)	AS	Total_Defect_Score_x15, 
	MAX(REHAB_RedundancyTable.Last_TV_Inspection)		AS	Last_TV_Inspection, 
	MAX(REHAB_RedundancyTable.Years_Since_Inspection)	AS	Years_Since_Inspection, 
	MAX(REHAB_RedundancyTable.Insp_Curr)	AS	Insp_Curr, 
	MIN(REHAB_RedundancyTable.Failure_Year) AS	Failure_Year, 
	MIN(REHAB_RedundancyTable.Std_Dev)		AS	Std_Dev, 
	SUM(REHAB_RedundancyTable.Consequence_Failure)		AS	Consequence_Failure, 
	SUM(REHAB_RedundancyTable.Replacement_Cost)			AS	Replacement_Cost, 
	SUM(BPW_Seg)		AS	BPW_Seg, 
	SUM(APW_Seg)		AS	APW_Seg, 
	AVG(CBR_Seg)		AS	CBR_Seg, 
	AVG(Std_Dev_Seg)	AS	Std_Dev_Seg, 
	AVG(Fail_YR_Seg)	AS	Fail_YR_Seg, 
	MAX(REHAB_RedundancyTable.RATING)	AS	RATING, 
	MAX(REHAB_RedundancyTable.[ACTION]) AS	[ACTION]
FROM  REHAB_RedundancyTable WHERE COMPKEY <> 0 GROUP BY COMPKEY 

UPDATE  REHAB_RedundancyTableWhole SET CBR = CASE WHEN Replacement_Cost = 0 THEN NULL ELSE CAST((BPW -APW) AS FLOAT)/CAST(Replacement_Cost AS FLOAT) END
UPDATE  REHAB_RedundancyTableWhole SET  REHAB_RedundancyTableWhole.MLinkID = D.MLinkID FROM (SELECT A.COMPKEY, B.MLinkID FROM  REHAB_RedundancyTableWhole AS A INNER JOIN REHAB10FTSEGS AS B ON A.COMPKEY = B.COMPKEY AND B.MLinkID < 40000000) AS D INNER JOIN  REHAB_RedundancyTableWhole ON D.COMPKEY =  REHAB_RedundancyTableWhole.COMPKEY
END
GO

