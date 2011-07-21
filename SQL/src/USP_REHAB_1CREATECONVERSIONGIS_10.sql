USE [SANDBOX]
GO

/****** Object:  StoredProcedure [ROSE\issacg].[USP_REHAB_1CREATECONVERSIONGIS_10]    Script Date: 07/21/2011 08:22:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [ROSE\issacg].[USP_REHAB_1CREATECONVERSIONGIS_10] AS
BEGIN

--------------------------------------------------------------
--Empty segment redundancy table
DELETE FROM REHAB_RedundancyTable

--------------------------------------------------------------
--Fill redundancy table with segment data from Rehab10FtSegs
INSERT INTO  REHAB_RedundancyTable 
SELECT 
		0,				[UsNode],		[DsNode],		[MLinkID],
		[CompKey],		[Length],		[DiamWidth],	[Height],
		[Shape],		[Material],		[Instdate],		NULL,
		[HServStat],	[OLD_MLID],		0,				NULL,
		[CutNO],		[FM],			[TO_],			[SegLen],
		'',				seg_count,		0,				0,
		0,				0,				0,				0,
		0,				0,				0,				0,
		0,				0,				NULL,			NULL,
		NULL,			NULL,			NULL,			NULL,
		NULL,			NULL,			NULL,			NULL,
		NULL,			0,				0,				0,
		0,				0,				0,				0
FROM  GIS.Rehab10Ftsegs 
WHERE	MLINKID >= 40000000 
		AND 
		COMPKEY <> 0
	
---------------------------------------------------------------
--Empty whole pipe redundancy table
DELETE 
FROM	REHAB_RedundancyTableWhole

---------------------------------------------------------------
--Fill Whole pipe redundancy table with data from Rehab10FtSegs
INSERT INTO  REHAB_RedundancyTableWhole
SELECT 
		0,				[UsNode],		[DsNode],		[MLinkID],
		[CompKey],		[Length],		[DiamWidth],	[Height],
		[Shape],		[Material],		[Instdate],		NULL,
		[HServStat],	[OLD_MLID],		0,				NULL,
		[CutNO],		[FM],			[TO_],			[SegLen],
		'',				0,				0,				0,
		0,				0,				0,				0,
		0,				0,				0,				0,
		0,				0,				NULL,			NULL,
		NULL,			NULL,			NULL,			NULL,
		NULL,			NULL,			NULL,			NULL,
		NULL,			0,				0,				0,
		0,				0,				0,				0
FROM	GIS.Rehab10Ftsegs 
WHERE	MLINKID < 40000000 
		AND 
		COMPKEY <> 0

----------------------------------------------------------------------
--Update the SERVSTAT value for the sanitary pipes using HANSEN values
UPDATE	REHAB_RedundancyTable 
SET		HServStat = A.SERVSTAT 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS A 
ON		REHAB_RedundancyTable.COMPKEY = A.COMPKEY

----------------------------------------------------------------------
--Update the SERVSTAT value for the storm pipes using HANSEN values
UPDATE	REHAB_RedundancyTable 
SET		HServStat = A.SERVSTAT 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS A 
ON		REHAB_RedundancyTable.COMPKEY = A.COMPKEY

-----------------------------------------------------------------------
--Empty Conversion1
DELETE FROM  REHAB_Conversion1

-----------------------------------------------------------------------
--Fill Conversion1 with all of the valid sanitary inspections for structural
--and lateral damage
INSERT INTO  REHAB_Conversion1 
SELECT C2.COMPKEY AS COMPKEY,
       C2.INSPKEY AS INSPKEY, 
       CASE WHEN (C3.OBKEY = 1005 OR 
				C3.OBKEY = 1006 OR 
				C3.OBKEY = 1008 OR 
				C3.OBKEY = 1010 OR 
				C3.OBKEY = 1015 OR 
				C3.OBKEY = 1016
                ) THEN OBRATING ELSE 0 END AS NewScore, 
       /*REL*/DISTFROM	AS convert_setdwn_from, 
       /*REL*/DISTTO	AS convert_setdwn_to, 
       TVOBKEY			AS ReadingKey, 
       STARTDTTM,	COMPDTTM,	INSTDATE,	OBDEGREE, 
	   OBKEY,		RATING,		OWN,		UnitType,
	   ServStat
FROM	(
			[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
			INNER JOIN 
			(
				[SIRTOBY].[HANSEN].[IMSV7].INSMNFT AS C2 
				INNER JOIN 
				[SIRTOBY].[HANSEN].[IMSV7].INSMNFO AS C3
				ON C2.INSPKEY=C3.INSPKEY
				--AND C2.COMPDTTM IS NOT NULL
			) 
			ON C1.COMPKEY=C2.COMPKEY
		) 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].INSMNFR AS C4 
		ON C3.INSPKEY = C4.INSPKEY 
		AND 
		RATINGKEY = 1001;

-----------------------------------------------------------------------
--Empty Conversion2
DELETE FROM  REHAB_Conversion2

-----------------------------------------------------------------------
--Fill Conversion2 with all of the valid storm inspections for structural
--and lateral damage
INSERT INTO  REHAB_Conversion2 
SELECT C2.COMPKEY AS COMPKEY,
       C2.INSPKEY AS INSPKEY, 
       CASE WHEN (C3.OBKEY = 1005 OR 
				C3.OBKEY = 1006 OR 
				C3.OBKEY = 1008 OR 
				C3.OBKEY = 1010 OR 
				C3.OBKEY = 1015 OR 
				C3.OBKEY = 1016
                ) THEN OBRATING ELSE 0 END AS NewScore, 
       /*REL*/DISTFROM	AS convert_setdwn_from, 
       /*REL*/DISTTO	AS convert_setdwn_to, 
       TVOBKEY			AS ReadingKey, 
       STARTDTTM,	COMPDTTM,	INSTDATE,	OBDEGREE,
	   OBKEY,		RATING,		OWN,		UnitType,
	   ServStat
FROM	(
			[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS C1 
			INNER JOIN 
			(
				[SIRTOBY].[HANSEN].[IMSV7].INSTMNFT AS C2 
				INNER JOIN 
				[SIRTOBY].[HANSEN].[IMSV7].INSTMNFO AS C3
				ON C2.INSPKEY=C3.INSPKEY
				--AND C2.COMPDTTM IS NOT NULL
			) 
			ON C1.COMPKEY=C2.COMPKEY
		) 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].INSTMNFR AS C4 
		ON	C3.INSPKEY = C4.INSPKEY 
			AND 
			RATINGKEY = 1001;

-----------------------------------------------------------------------
--Empty Conversion2
DELETE FROM  REHAB_Conversion3

-----------------------------------------------------------------------
--Fill Conversion3 with only the latest inspection dates for sanitary pipes
INSERT INTO  REHAB_Conversion3 SELECT COMPKEY, MAX(STARTDTTM) AS MaxDates
       FROM  REHAB_Conversion1
       GROUP BY COMPKEY;

-----------------------------------------------------------------------
--Empty Conversion4
DELETE FROM  REHAB_Conversion4

-----------------------------------------------------------------------
--Fill Conversion4 with only the latest inspection dates for storm pipes
INSERT INTO  REHAB_Conversion4 SELECT COMPKEY, MAX(STARTDTTM) AS MaxDates
       FROM  REHAB_Conversion2
       GROUP BY COMPKEY;

-----------------------------------------------------------------------
--Empty Conversion5
DELETE FROM  REHAB_Conversion5

-----------------------------------------------------------------------
--Fill Conversion5 with all of the data from the latest inspection dates for sanitary pipes
INSERT INTO  REHAB_Conversion5 
SELECT  REHAB_Conversion1.*
FROM	REHAB_Conversion1, REHAB_Conversion3
WHERE	REHAB_Conversion1.COMPKEY = REHAB_Conversion3.COMPKEY 
		AND  
		REHAB_Conversion1.StartDTTM = REHAB_Conversion3.MaxDates;

-----------------------------------------------------------------------
--Empty Conversion6
DELETE FROM  REHAB_Conversion6

-----------------------------------------------------------------------
--Fill Conversion6 with all of the data from the latest inspection dates for storm pipes
INSERT INTO  REHAB_Conversion6 
SELECT	REHAB_Conversion2.*
FROM	REHAB_Conversion2,  REHAB_Conversion4
WHERE	REHAB_Conversion2.COMPKEY = REHAB_Conversion4.COMPKEY 
		AND 
		REHAB_Conversion2.StartDTTM = REHAB_Conversion4.MaxDates;

-----------------------------------------------------------------------
--Empty Conversion
DELETE FROM  REHAB_CONVERSION

-----------------------------------------------------------------------
--Fill Conversion with the combined data from Conversion6 and Conversion5
INSERT INTO  REHAB_CONVERSION 
SELECT	A.*
FROM	(
			SELECT	*
			FROM	REHAB_Conversion5
			UNION ALL 
			SELECT	* 
			FROM	REHAB_Conversion6
		)AS A


-----------------------------------------------------------------------
--Empty the point defect table
DELETE FROM  REHAB_point_defect_group

-----------------------------------------------------------------------
--Fill the table of point defect groups and give the last segment all of the point defects 
--that run off the end of the virtual pipes extents.  Some inspections are given distance
--values that are greater than the length of the pipe.  Applying these inspections to the last 
--segment is a way of capturing these point defects.
INSERT INTO  REHAB_point_defect_group 
SELECT  REHAB_RedundancyTable.CompKey,  
		REHAB_RedundancyTable.CutNO,  
		REHAB_RedundancyTable.FM,  
		REHAB_RedundancyTable.[TO], 
		CASE	WHEN Sum(REHAB_CONVERSION.NewScore) IS NOT NULL 
				THEN Sum(REHAB_CONVERSION.NewScore) 
				ELSE 0 
		END AS SumOfNewScore 
FROM	REHAB_CONVERSION 
		INNER JOIN  
		REHAB_RedundancyTable 
		ON REHAB_CONVERSION.compkey= REHAB_RedundancyTable.CompKey
WHERE	(
			CutNo = Seg_Count 
			AND 
			REHAB_CONVERSION.convert_setdwn_from >= REHAB_RedundancyTable.fm
		) 
		OR 
		(
			(
				REHAB_CONVERSION.convert_setdwn_from >= REHAB_RedundancyTable.fm 
				AND  
				REHAB_CONVERSION.convert_setdwn_from < REHAB_RedundancyTable.[to]
			) 
			AND 
			(
				REHAB_CONVERSION.convert_setdwn_to Is Null 
				OR 
				REHAB_CONVERSION.convert_setdwn_to = 0 
				OR  
				REHAB_CONVERSION.convert_setdwn_to = REHAB_CONVERSION.convert_setdwn_from
			)
		)
GROUP BY	REHAB_RedundancyTable.CompKey,  
			REHAB_RedundancyTable.CutNO,  
			REHAB_RedundancyTable.FM,  
			REHAB_RedundancyTable.[TO]
ORDER BY	REHAB_RedundancyTable.CompKey,  
			REHAB_RedundancyTable.CutNO;

-----------------------------------------------------------------------
--Empty the linear defect table
DELETE FROM  REHAB_linear_defect_groupbysegment

-----------------------------------------------------------------------
--Fill the table of linear defects.  Currently the linear defects that extend
--beyond the last segment are not applied to the last segment, although
--that should be considered.
--Connect  REHAB_RedundancyTable and TABLE A by compkey, FM, convert_setdwn_from, [TO], and convert_setdwn_to.
INSERT INTO  REHAB_linear_defect_groupbysegment 
SELECT	B.CompKey,
		B.CutNO, 
		B.[TO], 
		B.FM, 
		Sum(newScore) AS SumOfNewScore 
FROM	(
			SELECT	M.CompKey, 
					M.CutNO, 
					M.[TO], 
					M.FM, 
					(
						CASE	WHEN	(
											M.FM >= A.convert_setdwn_from 
											AND 
											M.[TO] <= A.convert_setdwn_to
										) 
								THEN 10 * A.peak_score 
								ELSE CASE WHEN	(
													M.FM < A.convert_setdwn_from 
													AND 
													M.[TO] > A.convert_setdwn_to
												) 
								THEN (A.convert_setdwn_to - A.convert_setdwn_from) * A.peak_score 
								ELSE CASE WHEN	(
													M.[TO] > A.convert_setdwn_to
												) 
								THEN (A.convert_setdwn_to - M.[FM]) * A.peak_score 
								ELSE CASE WHEN (
													M.FM < A.convert_setdwn_from
												) 
								THEN (M.[TO] - A.convert_setdwn_from) * A.peak_score 
								ELSE 0 
								END 
								END 
								END 
								END
					) AS newScore
			FROM	REHAB_RedundancyTable AS M 
					INNER JOIN 
					(
						SELECT	compkey, 
								convert_setdwn_from, 
								convert_setdwn_to,  
								REHAB_CONVERSION.obdegree, 
								peak_score 
						FROM	REHAB_CONVERSION 
								INNER JOIN  
								REHAB_PeakScore_Lookup 
								ON REHAB_CONVERSION.obdegree =  REHAB_PeakScore_Lookup.obdegree
					) AS A 
					ON M.Compkey = A.Compkey
			WHERE /*(CutNo = Seg_Count AND convert_setdwn_to>= M.[to]) OR*/ 
					(
						(
							A.convert_setdwn_from >= 0 
							AND 
							A.convert_setdwn_from < M.[to]
						) 
						AND
						(
							A.convert_setdwn_to >= 0 
							AND 
							A.convert_setdwn_to > M.[fm]
						)
					)
		) AS B 
GROUP BY B.CompKey, B.CutNO, B.FM, B.[TO]

----------------------------------------------------------------------------
--Apply the point defect scores to the segments in the redundancy table
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Point_Defect_Score = 
		(
			CASE WHEN	SumOfNewScore Is Not Null 
						THEN [SumOfNewScore] 
						ELSE 0 
						END
		) 
FROM	REHAB_point_defect_group 
		INNER JOIN  
		REHAB_RedundancyTable 
		ON 
		REHAB_point_defect_group.CompKey = REHAB_RedundancyTable.CompKey 
		AND 
		REHAB_point_defect_group.CutNO = REHAB_RedundancyTable.CutNO

-------------------------------------------------------------------------------
--Apply the linear defect scores to the segments in the redundancy table
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Linear_Defect_Score = 
		(
			CASE WHEN	SumOfNewScore Is Not Null 
						THEN [SumOfNewScore] 
						ELSE 0 
						END
		) 
FROM	REHAB_linear_defect_groupbysegment 
		INNER JOIN  
		REHAB_RedundancyTable 
		ON 
		REHAB_linear_defect_groupbysegment.CompKey = REHAB_RedundancyTable.CompKey
		AND
		REHAB_linear_defect_groupbysegment.CutNO = REHAB_RedundancyTable.CutNO

-------------------------------------------------------------------------------
--Give segments that have a null value for point defect score a zero.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Point_defect_score = 0
WHERE	REHAB_RedundancyTable.Point_defect_score Is Null

--------------------------------------------------------------------------------
--Give segments that have a null value for linear defect score a zero.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Linear_defect_score = 0
WHERE	REHAB_RedundancyTable.Linear_defect_score Is Null

--------------------------------------------------------------------------------
--Set the total defect score for segments equal to the sum of the linear defect
--score and the point defect score
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Total_defect_score = [Point_defect_score]+[Linear_defect_score]

--------------------------------------------------------------------------------
--Set the Total_defect_scoreX15 to be equal to the Total_defect_score multiplied by 15.
--I'm not sure this column is used any more.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Total_Defect_Score_x15 = [Total_Defect_Score]*15

--------------------------------------------------------------------------------
--Set the last tv inspection to be the date stated in the conversion table
--that the scores were read
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Last_TV_Inspection = [STARTDTTM] 
FROM	REHAB_CONVERSION 
		INNER JOIN  
		REHAB_RedundancyTable 
		ON  REHAB_CONVERSION.COMPKEY = REHAB_RedundancyTable.COMPKEY

--------------------------------------------------------------------------------
--Give the segment the HANSEN grade as given to the pipe when the pipe was
--inspected.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.RATING = REHAB_CONVERSION.[RATING] 
FROM	REHAB_CONVERSION 
		INNER JOIN  
		REHAB_RedundancyTable 
		ON  REHAB_CONVERSION.COMPKEY = REHAB_RedundancyTable.COMPKEY

-------------------------------------------------------------------------------
--Update the years since inspection.  Years since inspection is based upon the year 2010.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Years_Since_Inspection = 2010-Year([Last_Tv_Inspection])

-------------------------------------------------------------------------------
--Update the sanitary pipe size.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.DiamWidth = [PIPEDIAM] 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON  REHAB_RedundancyTable.CompKey = C1.COMPKEY

-------------------------------------------------------------------------------
--Update the storm pipe size.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.DiamWidth = [PIPEDIAM] 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS C1 
		ON C1.COMPKEY = REHAB_RedundancyTable.CompKey

-------------------------------------------------------------------------------
--Update the sizes of the pipes in rehab10ftSegs.  Since
--Rehab10FtSegs is based on master links, we need to just update it
--here and forget about whatever master links says the pipe
--size is
UPDATE	SANDBOX.GIS.Rehab10FtSegs 
SET		SANDBOX.GIS.Rehab10FtSegs.Diamwidth = [PIPEDIAM]
FROM	SANDBOX.GIS.Rehab10FtSegs 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON  SANDBOX.GIS.Rehab10FtSegs.CompKey = C1.COMPKEY 
		
-------------------------------------------------------------------------------
--Update the sizes of the pipes in rehab10ftSegs.  Since
--Rehab10FtSegs is based on master links, we need to just update it
--here and forget about whatever master links says the pipe
--size is
UPDATE	SANDBOX.GIS.Rehab10FtSegs 
SET		SANDBOX.GIS.Rehab10FtSegs.Diamwidth = [PIPEDIAM]
FROM	SANDBOX.GIS.Rehab10FtSegs 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS C1 
		ON  SANDBOX.GIS.Rehab10FtSegs.CompKey = C1.COMPKEY 

-------------------------------------------------------------------------------
--Update the sanitary pipe material.  The pipe material is the assumed original material
--that the pipe is made of.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Material = [PIPETYPE] 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON  REHAB_RedundancyTable.CompKey = C1.COMPKEY

-------------------------------------------------------------------------------
--Update the storm pipe material.  The pipe material is the assumed original material
--that the pipe is made of.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Material = [PIPETYPE] 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS C1 
		ON C1.COMPKEY = REHAB_RedundancyTable.CompKey
-------------------------------------------------------------------------------
--Update the install dates of the sanitary pipes.  We are going to go by the HANSEN
--install dates, so the install dates from MapInfo data are invalid.
--This query will  only affect those pipes that exist in MapInfo AND
--Hansen, so grade 5 pipes should not be affected by this update.
--This query should definitely be done before the redundancy table is
--filled, so move it.
UPDATE	SANDBOX.GIS.Rehab10FtSegs 
SET		SANDBOX.GIS.Rehab10FtSegs.instdate = C1.instdate
FROM	SANDBOX.GIS.Rehab10FtSegs 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON  SANDBOX.GIS.Rehab10FtSegs.CompKey = C1.COMPKEY 

-------------------------------------------------------------------------------
--Update the install dates of the storm pipes.  We are going to go by the HANSEN
--install dates, so the install dates from MapInfo data are invalid.
--This query will  only affect those pipes that exist in MapInfo AND
--Hansen, so grade 5 pipes should not be affected by this update.
--This query should definitely be done before the redundancy table is
--filled, so move it.
UPDATE	REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.instdate = C1.instdate
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON  REHAB_RedundancyTable.CompKey = C1.COMPKEY 

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 1 for sanitary pipes for the following cases:
--	I: install date is before the inspection date
-- II: install date is NULL, but inspection date is not NULL
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.INSP_CURR = 1 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON  REHAB_RedundancyTable.CompKey = C1.COMPKEY 
WHERE	REHAB_RedundancyTable.Last_TV_Inspection >= C1.instdate
		OR 
		( 
			REHAB_RedundancyTable.Last_TV_Inspection Is Not Null 
			AND 
			C1.instdate Is Null
		)

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 1 for storm pipes for the following cases:
--	I: install date is before the inspection date
-- II: install date is NULL, but inspection date is not NULL
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.INSP_CURR = 1 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS C1 
		ON  REHAB_RedundancyTable.CompKey = C1.COMPKEY 
WHERE	REHAB_RedundancyTable.Last_TV_Inspection >= C1.instdate 
		OR 
		( 
			REHAB_RedundancyTable.Last_TV_Inspection Is Not Null 
			AND 
			C1.instdate Is Null
		)

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 2 for sanitary pipes for the following cases:
--	I: install date is null and servstat is 'TBAB'
-- II: install date is null and servstat is 'ABAN'
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.INSP_CURR = 2 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON  REHAB_RedundancyTable.CompKey = C1.COMPKEY 
WHERE	C1.instdate Is Null 
		AND 
		(
			servstat Like 'TBAB' 
			OR 
			servstat Like 'ABAN'
		)

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 2 for storm pipes for the following cases:
--	I: install date is null and servstat is 'TBAB'
-- II: install date is null and servstat is 'ABAN'
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.INSP_CURR = 2 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS C1 
		ON REHAB_RedundancyTable.CompKey = C1.COMPKEY 
WHERE	C1.instdate Is Null 
		AND 
		(
			servstat Like 'TBAB' 
			OR 
			servstat Like 'ABAN'
		)

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 3 for sanitary pipes for the following cases:
--	I: install date is after the last inspection
-- II: servstat is 'PEND'
UPDATE	REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.INSP_CURR = 3 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON REHAB_RedundancyTable.CompKey = C1.COMPKEY 
WHERE	C1.instdate > REHAB_RedundancyTable.Last_TV_Inspection 
		OR 
		servstat Like 'PEND'

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 3 for storm pipes for the following cases:
--	I: install date is after the last inspection
-- II: servstat is 'PEND'
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.INSP_CURR = 3 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS C1 
		ON REHAB_RedundancyTable.CompKey = C1.COMPKEY 
WHERE	C1.instdate > REHAB_RedundancyTable.Last_TV_Inspection 
		OR 
		servstat Like 'PEND'

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 4 for sanitary pipes for the following cases:
--	I: last tv inpsection date is NULL
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.INSP_CURR = 4 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS C1 
		ON REHAB_RedundancyTable.CompKey = C1.COMPKEY 
WHERE	REHAB_RedundancyTable.Last_TV_Inspection Is Null

-------------------------------------------------------------------------------
--Set the INSP_CURR flag to 4 for storm pipes for the following cases:
--	I: last tv inpsection date is NULL
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.INSP_CURR = 4 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		[SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS C1 
		ON  REHAB_RedundancyTable.CompKey=C1.COMPKEY 
WHERE	REHAB_RedundancyTable.Last_TV_Inspection Is Null

-------------------------------------------------------------------------------
--Empty the Varies table for the segments
DELETE FROM  REHAB_MLA_05FtBrk_VariesTable

-------------------------------------------------------------------------------
--Fill the varies table with all of the segments that have a material
--type of 'VARIES'
INSERT INTO  REHAB_MLA_05FtBrk_VariesTable 
SELECT	*
FROM	REHAB_RedundancyTable
WHERE	Material like 'VARIES'

-------------------------------------------------------------------------------
--Empty the material changes table
DELETE FROM  REHAB_Material_Changes

-------------------------------------------------------------------------------
--Fill the material changes table with all of the segments that have 
--been identified as having a material change.  This is an unfortunate
--table since currently the only way to update is is manually
INSERT INTO  REHAB_Material_Changes 
SELECT	*
FROM	REHAB_Attribute_changes_ac
WHERE	CHTYPE like 'MATERIAL'

-------------------------------------------------------------------------------
--For pipes already in the material varies table, set the material to unknown
--when the graphic length of the pipe differs from the recorded length of the
--pipe by more than 10 feet.  This query is no longer important.
/*UPDATE  REHAB_MLA_05FtBrk_VariesTable 
SET		MATERIAL = 'UNKNOWN'
WHERE	Compkey IN 
		(
			SELECT	COMPKEY
			FROM 
			(
				SELECT	Material_Changes_TotalLength.*
				FROM 
				(
					SELECT	REHAB_Material_Changes.Compkey, 
							SUM(ABS(REHAB_Material_Changes.DISTTO - REHAB_Material_Changes.DISTFROM)) AS SUM_LENGTH
					FROM	REHAB_Material_Changes
					GROUP BY  REHAB_Material_Changes.Compkey
				) AS Material_Changes_TotalLength, GIS.DME_Links_ac
			WHERE	Material_Changes_TotalLength.Compkey = GIS.DME_Links_ac.Compkey 
					AND 
					ABS(Material_Changes_TotalLength.SUM_LENGTH - GIS.DME_Links_ac.SRVY_LEN) >= 10
			) AS A
		)
*/
-------------------------------------------------------------------------------
--Empty the pipes with VSP table
DELETE 
FROM	REHAB_AA_Records_With_VSP

-------------------------------------------------------------------------------
--Place pipes that have VSP in them into the 'Records_with_VSP' table
INSERT INTO  REHAB_AA_Records_With_VSP 
SELECT	REHAB_MLA_05FtBrk_VariesTable.MLINKID,  
		REHAB_MLA_05FtBrk_VariesTable.Compkey,  
		REHAB_MLA_05FtBrk_VariesTable.FM,  
		REHAB_Material_Changes.DISTFROM,  
		REHAB_MLA_05FtBrk_VariesTable.[TO],  
		REHAB_Material_Changes.DISTTO,  
		REHAB_Material_Changes.CHDETAIL 
FROM	REHAB_MLA_05FtBrk_VariesTable,  
		REHAB_Material_Changes
WHERE	REHAB_MLA_05FtBrk_VariesTable.Compkey = REHAB_Material_Changes.Compkey 
		AND 
		(
			(
				REHAB_MLA_05FtBrk_VariesTable.FM >= REHAB_Material_Changes.DISTFROM 
				AND  
				REHAB_MLA_05FtBrk_VariesTable.[TO] <= REHAB_Material_Changes.DISTTO
			) 
			OR 
			( 
				REHAB_MLA_05FtBrk_VariesTable.FM <= REHAB_Material_Changes.DISTFROM 
				AND  
				REHAB_MLA_05FtBrk_VariesTable.[TO] >= REHAB_Material_Changes.DISTFROM
			) 
			OR 
			( 
				REHAB_MLA_05FtBrk_VariesTable.FM <= REHAB_Material_Changes.DISTTO 
				AND  
				REHAB_MLA_05FtBrk_VariesTable.[TO] >= REHAB_Material_Changes.DISTTO
			)
		) 
		AND  
		REHAB_Material_Changes.CHDETAIL Like 'MAT-VSP'

-------------------------------------------------------------------
--Remove the records from the 'records_that_patch_vsp' table
DELETE 
FROM	REHAB_AB_Records_That_Patch_VSP

-------------------------------------------------------------------
--Gets all of the 'jellybeans' that are in a pipe that has been 
--designated as having VSP materials associated with it.
INSERT INTO  REHAB_AB_Records_That_Patch_VSP 
SELECT	REHAB_MLA_05FtBrk_VariesTable.MLINKID,  
		REHAB_MLA_05FtBrk_VariesTable.Compkey,  
		REHAB_MLA_05FtBrk_VariesTable.FM,  
		REHAB_Material_Changes.DISTFROM,  
		REHAB_MLA_05FtBrk_VariesTable.[TO],  
		REHAB_Material_Changes.DISTTO,  
		REHAB_Material_Changes.CHDETAIL 
FROM	REHAB_MLA_05FtBrk_VariesTable,  
		REHAB_Material_Changes
WHERE	REHAB_Material_Changes.Compkey  
		IN 
		(
			SELECT	Compkey 
			FROM	REHAB_AA_Records_With_VSP
		) 
		AND 
		REHAB_MLA_05FtBrk_VariesTable.Compkey = REHAB_Material_Changes.Compkey 
		AND
		(
			(
				REHAB_MLA_05FtBrk_VariesTable.FM >= REHAB_Material_Changes.DISTFROM 
				AND 
				REHAB_MLA_05FtBrk_VariesTable.[TO] <= REHAB_Material_Changes.DISTTO
			) 
			OR 
			(
				REHAB_MLA_05FtBrk_VariesTable.FM <= REHAB_Material_Changes.DISTFROM 
				AND 
				REHAB_MLA_05FtBrk_VariesTable.[TO] >= REHAB_Material_Changes.DISTFROM
			) 
			OR 
			(
				REHAB_MLA_05FtBrk_VariesTable.FM <= REHAB_Material_Changes.DISTTO 
				AND 
				REHAB_MLA_05FtBrk_VariesTable.[TO] >= REHAB_Material_Changes.DISTTO
			)
		) 
		AND 
		REHAB_Material_Changes.CHDETAIL Not Like 'MAT-VSP'

------------------------------------------------------------------------
--Empty the remaining records table.
DELETE 
FROM	REHAB_AC_Remaining_Records

------------------------------------------------------------------------
--This query is used for finding the records that have 'varies'
--but do not have any VSP
INSERT INTO	REHAB_AC_Remaining_Records 
SELECT		REHAB_MLA_05FtBrk_VariesTable.CompKey 
FROM		REHAB_MLA_05FtBrk_VariesTable 
			LEFT JOIN  
			REHAB_AA_Records_With_VSP 
			ON  REHAB_MLA_05FtBrk_VariesTable.CompKey = REHAB_AA_Records_With_VSP.Compkey
WHERE		REHAB_AA_Records_With_VSP.Compkey Is Null
GROUP BY	REHAB_MLA_05FtBrk_VariesTable.Compkey

------------------------------------------------------------------------
--Empty the table 'Records_with_no_vsp'
DELETE FROM  REHAB_AD_Records_With_No_VSP

------------------------------------------------------------------------
--Place the records that have no VSP at all in the Records_with_no_vsp table
INSERT INTO	REHAB_AD_Records_With_No_VSP 
SELECT		REHAB_MLA_05FtBrk_VariesTable.MLINKID,  
			REHAB_MLA_05FtBrk_VariesTable.Compkey,  
			REHAB_MLA_05FtBrk_VariesTable.FM,  
			REHAB_Material_Changes.DISTFROM,  
			REHAB_MLA_05FtBrk_VariesTable.[TO],  
			REHAB_Material_Changes.DISTTO,  
			REHAB_Material_Changes.CHDETAIL 
FROM		REHAB_MLA_05FtBrk_VariesTable,  
			REHAB_Material_Changes
WHERE		REHAB_Material_Changes.Compkey 
			IN 
			(
				SELECT	Compkey 
				FROM	REHAB_AC_Remaining_Records
			) 
			AND 
			REHAB_MLA_05FtBrk_VariesTable.Compkey = REHAB_Material_Changes.Compkey 
			AND 
			(
				(
					REHAB_MLA_05FtBrk_VariesTable.FM >= REHAB_Material_Changes.DISTFROM 
					AND 
					REHAB_MLA_05FtBrk_VariesTable.[TO] <= REHAB_Material_Changes.DISTTO
				) 
				OR 
				(
					REHAB_MLA_05FtBrk_VariesTable.FM <= REHAB_Material_Changes.DISTFROM 
					AND 
					REHAB_MLA_05FtBrk_VariesTable.[TO] >= REHAB_Material_Changes.DISTFROM
				) 
				OR 
				(
					REHAB_MLA_05FtBrk_VariesTable.FM <= REHAB_Material_Changes.DISTTO 
					AND
					REHAB_MLA_05FtBrk_VariesTable.[TO] >= REHAB_Material_Changes.DISTTO
				)
			)

--------------------------------------------------------------------------------------------
--Stamps original VSP 'jellybeans' as original VSP 'jellybeans'.
UPDATE  REHAB_MLA_05FtBrk_VariesTable 
SET		MATERIAL = '1_VSP'
WHERE	MLINKID 
		IN 
		(
			SELECT	MLINKID 
			FROM	REHAB_AA_Records_With_VSP
		)

--------------------------------------------------------------------------------------------
--Stamps secondary materials of VSP pipes as secondary material 'jellybeans'
UPDATE	A 
SET		A.MATERIAL = '2_' + replace(CHDETAIL,'MAT-','') 
FROM	(
			SELECT	MATERIAL, 
					CHDETAIL 
			FROM	REHAB_MLA_05FtBrk_VariesTable
					INNER JOIN  
					REHAB_AB_Records_That_Patch_VSP 
					ON REHAB_MLA_05FtBrk_VariesTable.MLINKID = REHAB_AB_Records_That_Patch_VSP.MLINKID
		) AS A

-------------------------------------------------------------------------------------------
--Empty the longest material per compkey table
DELETE FROM  REHAB_Longest_Material_Per_Compkey

--------------------------------------------------------------------------------------------
--since we don't know what the primary material of non-VSP pipes would be 
--considered, we just assume that the longest
--material in the pipe is the primary material.
INSERT INTO	REHAB_Longest_Material_Per_Compkey 
SELECT		MAX_TABLE.COMPKEY, 
			MAX_TABLE.MAX_LENGTHS, 
			ALL_LENGTHS.CHDETAIL 
FROM		(
				SELECT	COMPKEY, 
						MAX(SUM_LENGTHS) AS MAX_LENGTHS
				FROM	(
							SELECT	COMPKEY, 
									CHDETAIL, 
									SUM(ABS(DISTTO-DISTFROM)) AS SUM_LENGTHS
							FROM	REHAB_Material_Changes
							GROUP BY	COMPKEY, 
										CHDETAIL
						) AS A
				GROUP BY COMPKEY
			) AS MAX_TABLE 
			INNER JOIN 
			(
				SELECT	COMPKEY, 
						CHDETAIL, 
						SUM(ABS(DISTTO-DISTFROM)) AS SUM_LENGTHS
				FROM	REHAB_Material_Changes
				GROUP BY	COMPKEY, 
							CHDETAIL
			) AS ALL_LENGTHS
			ON	ALL_LENGTHS.COMPKEY = MAX_TABLE.COMPKEY 
				AND 
				MAX_TABLE.MAX_LENGTHS = ALL_LENGTHS.SUM_LENGTHS

-------------------------------------------------------------------------------------------
--Empty out the table that tracks pipes whose primary materials are not VSP
DELETE FROM  REHAB_NON_VSP_PRIMARIES

-------------------------------------------------------------------------------------------
--Pipes that do not have vsp primaries are pipes that do not contain vsp, 
--this may not always be the case, but it is the rule that
--we assume that all pipes that contain VSP started out as VSP

--!ATTENTION! This query may be better designed using only 
--redundancy table and REHAB_AA_Records_With_VSP
INSERT INTO  REHAB_NON_VSP_PRIMARIES 
SELECT	MLINKID,  
		REHAB_AD_Records_With_No_VSP.CHDETAIL AS CHDETAIL 
FROM	REHAB_Longest_Material_Per_Compkey
		INNER JOIN
		REHAB_AD_Records_With_No_VSP
		ON	REHAB_Longest_Material_Per_Compkey.Compkey = REHAB_AD_Records_With_No_VSP.Compkey 
			AND  
			REHAB_Longest_Material_Per_Compkey.CHDETAIL = REHAB_AD_Records_With_No_VSP.CHDETAIL

-------------------------------------------------------------------------------------------
--Update the material column for primary materials that are not VSP
--(Because we already did the VSP primaries about 5 queries ago)
UPDATE  REHAB_MLA_05FtBrk_VariesTable 
SET		REHAB_MLA_05FtBrk_VariesTable.MATERIAL = '1_' + replace(CHDETAIL,'MAT-','') 
FROM	REHAB_MLA_05FtBrk_VariesTable 
		INNER JOIN  
		REHAB_NON_VSP_PRIMARIES 
		ON  REHAB_MLA_05FtBrk_VariesTable.MLINKID = REHAB_NON_VSP_PRIMARIES.MLINKID

-------------------------------------------------------------------------------------------
--Update the material column for secondary materials.  
UPDATE  REHAB_MLA_05FtBrk_VariesTable 
SET		REHAB_MLA_05FtBrk_VariesTable.MATERIAL = '2_' + replace(CHDETAIL,'MAT-','')
FROM	REHAB_MLA_05FtBrk_VariesTable 
		INNER JOIN  
		REHAB_AD_Records_With_No_VSP 
		ON  
		REHAB_MLA_05FtBrk_VariesTable.MLINKID = REHAB_AD_Records_With_No_VSP.MLINKID 
WHERE	REHAB_MLA_05FtBrk_VariesTable.MATERIAL like 'VARIES'

-------------------------------------------------------------------------------------------
--Update all the Materials in REHAB_RedundancyTable to match the corresponding entries 
--in the REHAB_MLA_05FtBrk_VariesTable.  
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.MATERIAL = REHAB_MLA_05FtBrk_VariesTable.MATERIAL 
FROM	REHAB_RedundancyTable 
		INNER JOIN  
		REHAB_MLA_05FtBrk_VariesTable 
		ON REHAB_MLA_05FtBrk_VariesTable.MLinkID = REHAB_RedundancyTable.MLinkID

-------------------------------------------------------------------------------------------
--Get the estimated remaining useful life of a pipe segment based on the scores and material of the current segment
DELETE FROM  REHAB_RemainingYearsTable

-------------------------------------------------------------------------------------------
--Update the remaining years table based upon the segment material and the score of the pipe.
INSERT INTO  REHAB_RemainingYearsTable 
SELECT	MLINKID, 
		Convert(INT,  REHAB_tblRemainingUsefulLifeLookup.YearsToFailure) AS YearsToFailure 
FROM	REHAB_tblRemainingUsefulLifeLookup,  
		REHAB_RedundancyTable,  
		REHAB_tblPipeTypeRosetta
WHERE	( 
			REHAB_RedundancyTable.Total_Defect_Score >= REHAB_tblRemainingUsefulLifeLookup.Score_Lower_Bound 
			AND  
			REHAB_RedundancyTable.Total_Defect_Score < REHAB_tblRemainingUsefulLifeLookup.Score_Upper_Bound
		) 
		AND  
		REHAB_RedundancyTable.Material = REHAB_tblPipeTypeRosetta.[Hansen Material] 
		AND  
		REHAB_tblPipeTypeRosetta.[Useful Life Curve] = 
		REHAB_tblRemainingUsefulLifeLookup.Material

-------------------------------------------------------------------------------------------
--Set the estimated failure year based upon whether or not the inspection date is useful 
--information.  
UPDATE	REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Failure_Year = YEAR(DateAdd("yyyy", REHAB_RemainingYearsTable.YearsToFailure, REHAB_RedundancyTable.Last_TV_Inspection)) 
FROM	REHAB_RedundancyTable 
		INNER JOIN  
		REHAB_RemainingYearsTable 
		ON REHAB_RedundancyTable.MLINKID = REHAB_RemainingYearsTable.MLINKID 
WHERE	REHAB_RedundancyTable.INSP_CURR = 1 
		OR 
		INSP_CURR = 2

-------------------------------------------------------------------------------------------
--Update the standard deviation for segments based upon whether the segment has a useful 
--inspection date (INSP_CURR).  This is similar tot he previous query, and could 
--probably be combined with it.
UPDATE	REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Std_dev = 
		CASE	WHEN (0.1* REHAB_RemainingYearsTable.YearsToFailure+0.25* REHAB_RedundancyTable.Years_Since_Inspection) > 1 
				THEN (0.1* REHAB_RemainingYearsTable.YearsToFailure+0.25* REHAB_RedundancyTable.Years_Since_Inspection) 
				ELSE 1 
		END 
FROM	REHAB_RedundancyTable 
		INNER JOIN  
		REHAB_RemainingYearsTable 
		ON  REHAB_RedundancyTable.MLINKID = REHAB_RemainingYearsTable.MLINKID 
WHERE	REHAB_RedundancyTable.INSP_CURR = 1 
		OR 
		INSP_CURR = 2

-------------------------------------------------------------------------------------------
--Update the consequence of failure for all pipes.
UPDATE	REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Consequence_Failure = REHAB_MortalityExport.Consequence 
FROM	REHAB_RedundancyTable 
		INNER JOIN  
		REHAB_MortalityExport 
		ON REHAB_RedundancyTable.Compkey = REHAB_MortalityExport.Compkey

-------------------------------------------------------------------------------------------
--Update the construction cost for all pipes.
UPDATE	REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.Replacement_Cost = REHAB_ConstructionExport.CostPerFoot*REHAB_RedundancyTable.[Length] 
FROM	REHAB_RedundancyTable 
		INNER JOIN  
		REHAB_ConstructionExport 
		ON REHAB_RedundancyTable.Compkey = REHAB_ConstructionExport.Compkey

-------------------------------------------------------------------------------------------
--If the inspection is absolutely not current, then the Hansen rating for that pipe
--is absolutley not valid.
UPDATE  REHAB_RedundancyTable 
SET		REHAB_RedundancyTable.RATING = 0 
WHERE	Insp_Curr = 3
		OR
		Insp_Curr = 4

END

GO

