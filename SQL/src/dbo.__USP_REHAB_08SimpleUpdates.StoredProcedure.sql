USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[__USP_REHAB_08SimpleUpdates]    Script Date: 03/23/2016 14:10:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[__USP_REHAB_08SimpleUpdates] AS
BEGIN


--------------------------------------------------------------------------
--UPDATE mat_fmto
--If the segment has been repaired in the past, this column identifies
--the material
UPDATE  REHAB_RedundancyTable 
SET		MAT_FmTo = REHAB_RedundancyTable.Material 
FROM	REHAB_RedundancyTable 
		INNER JOIN 
		GIS.REHAB_Segments AS C 
		ON  REHAB_RedundancyTable.ID = C.ID 
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

UPDATE  REHAB_RedundancyTableWhole
SET		seg_count = B.Seg_Count 
FROM	REHAB_RedundancyTableWhole
		INNER JOIN 
		REHAB_RedundancyTable AS B
		ON  REHAB_RedundancyTableWhole.COMPKEY = B.COMPKEY 
WHERE	B.COMPKEY <> 0

--SpotRepairCount should include all 1000+ segments even if they are not spot repair
--problems.  That way we know all of the segments that would go into BPW (We
--identify spot repair only segments by whether they have an action 3 value).
UPDATE  REHAB_RedundancyTable 
SET		SpotCost =	Replacement_Cost*SpotRepairCount
FROM    REHAB_RedundancyTable



END



GO

