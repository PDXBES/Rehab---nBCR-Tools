USE [REHAB]
GO

/****** Object:  StoredProcedure [GIS].[USP_REHAB_3PREPARETRANSFERTABLEGIS_10]    Script Date: 01/25/2012 15:31:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [GIS].[USP_REHAB_3PREPARETRANSFERTABLEGIS_10] AS
BEGIN

--------------------------------------------------------------------------
--UPDATE mat_fmto
--If the segment has been repaired in the past, this column identifies
--the material
UPDATE  REHAB_RedundancyTable 
SET		MAT_FmTo = REHAB_RedundancyTable.Material 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		REHAB10FTSEGS AS C 
		ON  REHAB_RedundancyTable.MLinkID = C.MLinkID 
WHERE	C.Material <> REHAB_RedundancyTable.Material

--------------------------------------------------------------------------
--UPDATE segcount
--Just counting the number of segments in the pipe
UPDATE  REHAB_RedundancyTable 
SET		seg_count = theCount 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		(
			SELECT	COMPKEY, 
					COUNT(*) AS theCount 
			FROM	REHAB_RedundancyTable 
			GROUP BY COMPKEY
		) AS B 
		ON  REHAB_RedundancyTable.COMPKEY = B.COMPKEY 
WHERE	B.COMPKEY <> 0

--------------------------------------------------------------------------
--UPDATE fail_near
UPDATE  REHAB_RedundancyTable 
SET		Fail_near = theCount 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		(
			SELECT	COMPKEY, 
					COUNT(*) AS theCount 
			FROM	REHAB_RedundancyTable 
			WHERE	Total_Defect_Score >= 1000 
			GROUP BY COMPKEY
		) AS A 
		ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--------------------------------------------------------------------------
--UPDATE fail_prev
UPDATE  REHAB_RedundancyTable 
SET		Fail_prev = theCount 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		(
			SELECT	COMPKEY, 
					COUNT(*) AS theCount 
			FROM	REHAB_RedundancyTable 
			WHERE	Material like '2_%' 
			GROUP BY COMPKEY
		) AS A 
		ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--------------------------------------------------------------------------
--UPDATE fail_TOT
UPDATE  REHAB_RedundancyTable 
SET		Fail_tot = theCount 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		(
			SELECT	COMPKEY, 
					COUNT(*) AS theCount 
			FROM	REHAB_RedundancyTable 
			WHERE	Total_Defect_Score >=1000 
					OR 
					Material like '2_%' 
			GROUP BY COMPKEY
		) AS A 
		ON  REHAB_RedundancyTable.COMPKEY = A.COMPKEY

--------------------------------------------------------------------------
--UPDATE fail_PCT
UPDATE  REHAB_RedundancyTable 
SET		Fail_pct =	CASE	WHEN	seg_count = 0 
							THEN	0 
							ELSE	CAST(fail_tot AS FLOAT)/CAST(seg_count AS FLOAT)*100 
					END 
WHERE COMPKEY <> 0

--------------------------------------------------------------------------
--UPDATE Def_PTS
UPDATE  REHAB_RedundancyTable 
SET		Def_PTS = theCount 
FROM	(
			SELECT	MLinkID, 
					Count(*) AS theCount
			FROM	(
						SELECT	compkey,
								convert_setdwn_to, 
								convert_setdwn_from 
						FROM	REHAB_Conversion
					) AS A 
					INNER JOIN  
					REHAB_RedundancyTable 
					ON A.compkey= REHAB_RedundancyTable.CompKey
					AND
					(  
						(   
							A.convert_setdwn_from >= REHAB_RedundancyTable.fm 
							AND 
							A.convert_setdwn_from < REHAB_RedundancyTable.[to]
						) 
						AND 
						(   
							A.convert_setdwn_to Is Null 
							OR  A.convert_setdwn_to = 0 
							OR  A.convert_setdwn_to = A.convert_setdwn_from
						)
					)
			GROUP BY MLinkID
		) AS B 
		INNER JOIN  
		REHAB_RedundancyTable 
		ON B.MLinkID =  REHAB_RedundancyTable.MLinkID

--------------------------------------------------------------------------
--UPDATE Def_LIN
UPDATE  REHAB_RedundancyTable 
SET		Def_LIN = theCount
FROM	(
			SELECT	MLinkID, 
					Count(*) AS theCount
			FROM	(
						SELECT	compkey,
								convert_setdwn_to, 
								convert_setdwn_from 
						FROM	REHAB_Conversion
					) AS A 
					INNER JOIN  
					REHAB_RedundancyTable 
					ON A.compkey = REHAB_RedundancyTable.CompKey
					AND
					(
						(
							A.convert_setdwn_from > 0 
							AND 
							A.convert_setdwn_from < REHAB_RedundancyTable.[to]
						) 
						AND 
						(
							A.convert_setdwn_to > 0 
							AND 
							A.convert_setdwn_to > REHAB_RedundancyTable.[fm]
						)
						AND 
						A.convert_setdwn_to <> A.convert_setdwn_from
					)
					GROUP BY MLinkID
		) AS B 
		INNER JOIN  
		REHAB_RedundancyTable 
		ON B.MLinkID = REHAB_RedundancyTable.MLinkID 

--------------------------------------------------------------------------
--UPDATE Def_TOT
UPDATE	REHAB_RedundancyTable 
SET		Def_TOT = Def_LIN + Def_PTS

--------------------------------------------------------------------------
--UPDATE BPW
--BPW stands for base present worth.  This value refers to the cost of
--leaving the pipe alone and possibly having it fail and be replaced.
--The consequence of failure usually includes lawsuits, damages, etc.
UPDATE  REHAB_RedundancyTable 
SET		BPW = B2010 + B2150 
FROM	REHAB_RedundancyTable AS A 
		INNER JOIN  
		REHAB_SmallResultsTable AS B 
		ON	A.COMPKEY = B.COMPKEY 
			AND 
			A.CUTNO = B.CUTNO

--------------------------------------------------------------------------	
--Update BPW_seg
--The BPW seg is the sum of the bpw prior to the current year and
--the discounted bpw of future years.
UPDATE  REHAB_RedundancyTable 
SET		BPW_Seg = B2010_Seg + B2150_Seg 
FROM	REHAB_RedundancyTable AS A 
		INNER JOIN  
		REHAB_SmallResultsTable AS B 
		ON	A.COMPKEY = B.COMPKEY 
			AND 
			A.CUTNO = B.CUTNO

--------------------------------------------------------------------------			
--UPDATE APW
--Alternate present worth is the value of repairing the whole pipe
--now, and then again 120 years from now.
UPDATE  REHAB_RedundancyTable 
SET		APW = R2010 + R2150 
FROM	REHAB_RedundancyTable AS A 
		INNER JOIN  
		REHAB_SmallResultsTable AS B 
		ON	A.COMPKEY = B.COMPKEY 
			AND 
			A.CUTNO = B.CUTNO

--------------------------------------------------------------------------
--Update APW_seg
--APW_seg is the value of repairing the segment now, and then the
--whole pipe 30 years from now.
UPDATE  REHAB_RedundancyTable 
SET		APW_Seg = R2010_Seg + R2150_seg 
FROM	REHAB_RedundancyTable AS A 
		INNER JOIN  
		REHAB_SmallResultsTable AS B 
		ON	A.COMPKEY = B.COMPKEY 
			AND 
			A.CUTNO = B.CUTNO

--------------------------------------------------------------------------
--Update CBR
--CBR is a bit of a misnomer, as it actually refers to the benefit/cost ratio,
--and not the cost/benefit ratio.  This is the benefit/cost ratio of replacing
--the whole pipe now, as opposed to just waiting for it to fail and then
--replacing.
UPDATE  REHAB_RedundancyTable 
SET		CBR =	CASE	WHEN Replacement_Cost <> 0 
						THEN CAST((BPW-APW) AS FLOAT)/CAST(Replacement_Cost AS FLOAT) 
						ELSE 0 
				END

--------------------------------------------------------------------------
--Update CBR_seg
--CBR_seg is a bit of a misnomer, as it actually refers to the benefit/cost ratio,
--and not the cost/benefit ratio.  This is the benefit/cost ratio of replacing
--a segment of the pipe now, as opposed to just waiting for it to fail and
--then replacing.
UPDATE  REHAB_RedundancyTable 
SET		CBR_Seg =	CASE	WHEN Replacement_Cost <> 0 
							THEN CAST((BPW_Seg-APW_seg) AS FLOAT)/CAST(Replacement_Cost AS FLOAT) 
							ELSE 0 
					END

END


GO

