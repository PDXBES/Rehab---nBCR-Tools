USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[FinalTimesBPW]    Script Date: 03/23/2016 14:14:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[FinalTimesBPW] AS
BEGIN

DECLARE @Tr INT = 20
DECLARE @Ts INT = 40
DECLARE @LinerRUL INT = 60


--In order to create window A for BPW, we need to know where window A starts.
--This would be the minimum failure year of the segments of a pipe.
SELECT  Compkey, COUNT(*) AS WindowA, min(fail_yr_seg) AS minFailYr INTO #BPWWindowAStartingYear
FROM    [REHAB].[GIS].[REHAB_Segments]
WHERE   cutno > 0
        AND
        def_tot >= 1000
        AND
        (
          fail_yr_seg <= YEAR(GETDATE()) + @Tr
          AND
          fail_yr_seg > 0
        )
GROUP BY COMPKEY

--Count of segments that fail in window A
--(can this be changed to just identify the segments in window A?)
SELECT  A.Compkey, COUNT(*) AS WindowA, min(fail_yr_seg) AS minfailYr INTO #MM1
FROM    [REHAB].[GIS].[REHAB_Segments] AS A
        INNER JOIN
        #BPWWindowAStartingYear AS B
        ON  A.Compkey = B.Compkey
WHERE   A.cutno > 0
        AND
        A.def_tot >= 1000
        AND
        (
          A.fail_yr_seg <= B.minFailYr + @Tr
          AND
          fail_yr_seg > 0
        )
GROUP BY A.COMPKEY

--Identify the segments in window A
SELECT  A.Compkey, cutno, fail_yr_seg INTO #WindowA
FROM    [REHAB].[GIS].[REHAB_Segments] AS A
        INNER JOIN
        #BPWWindowAStartingYear AS B
        ON  A.Compkey = B.Compkey
WHERE   cutno > 0
        AND
        def_tot >= 1000
        AND
        (
          fail_yr_seg <= B.minFailYr + @Tr
          AND
          fail_yr_seg > 0
        )
        


--Segments with small defects but low RUL
SELECT  A.Compkey, cutno, B.minFailYr + @Tr + 1 AS fail_yr_seg INTO #SegSmallDefects
FROM    [REHAB].[GIS].[REHAB_Segments] AS A
        INNER JOIN
        #BPWWindowAStartingYear AS B
        ON  A.Compkey = B.Compkey
WHERE   cutno > 0
        AND
        def_tot < 1000
        AND
        (
          fail_yr_seg <= B.minFailYr + @Tr
          AND
          fail_yr_seg > 0
        )



--Segments with fail_yr_seg that actually fall in window B
SELECT  A.Compkey, cutno, fail_yr_seg AS fail_yr_seg INTO #SegWindowB
FROM    [REHAB].[GIS].[REHAB_Segments] AS A
        INNER JOIN
        #BPWWindowAStartingYear AS B
        ON  A.Compkey = B.Compkey
WHERE   cutno > 0
        AND
        (
          fail_yr_seg > B.minFailYr + @Tr
          AND
          fail_yr_seg <= B.minFailYr + @Tr*2
          AND
          fail_yr_seg > 0
        )
        
--Segments that were repaired in Window A do not need to be spotted again, but do need to be lined at least at the end
--of Ts years (remember window B is a Spot AND line window, any spot work in window B is accompanied by a liner)
--also remember that this is in the spot repair tree, and we do not care about action on pipes that do not have segments failing in the next Tr years 
--for line/spot repair work, the date of this work should be the lowest of fail_yr_seg
SELECT  A.compkey, cutno, B.minFailYr + @Ts AS fail_yr_seg INTO #SegWindowAReturns
FROM    [REHAB].[GIS].[REHAB_Segments] AS A
        INNER JOIN
        #BPWWindowAStartingYear AS B
        ON  A.Compkey = B.Compkey
WHERE   cutno > 0
        AND
        def_tot >= 1000
        AND
        (
          fail_yr_seg <= B.minFailYr + @Tr --Should this be YEAR(GETDATE()) + @Tr?
          AND
          fail_yr_seg > 0
        )

--Now for a test, we look up the counts of repairs in window A and the count of repairs in window B
--But these counts are not useful.  What we need is to identify the spots that are in window A 
--and the spots that are in window B.
SELECT  #MM1.compkey, windowA, (windowB-windowA) AS windowB INTO #WindowTotals
FROM    #MM1
        INNER JOIN
        (
          SELECT A.COMPKEY, COUNT(*) AS WindowB
          FROM
          (
            SELECT Compkey, MIN(fail_yr_seg) AS lineAtYear
            FROM
            (
              SELECT * FROM #SegSmallDefects
              UNION ALL     
              SELECT * FROM #SegWindowB
              UNION ALL
              SELECT * FROM #SegWindowAReturns
            )AS X GROUP BY COMPKEY
          )AS A
          INNER JOIN
          (
            SELECT * FROM #SegSmallDefects
            UNION ALL        
            SELECT * FROM #SegWindowB
            UNION ALL
            SELECT * FROM #SegWindowAReturns
          ) AS B
          ON A.compkey = B.COMPKEY
          GROUP BY A.COMPKEY
        )
        AS MM2
        ON #MM1.compkey = MM2.COMPKEY

TRUNCATE TABLE GIS.COSTEST_BPWActionYears
INSERT INTO  GIS.COSTEST_BPWActionYears (Compkey, cutno, BPWWindowBSegFailureYear, BPWLineAtYear, BPWReplaceAtYear)
SELECT A.COMPKEY, B.cutno, B.fail_yr_seg AS BPWWindowBSegFailureYear, A.lineAtYear AS BPWLineAtYear, A.lineAtYear + @LinerRUL AS BPWReplaceAtYear 
FROM
(
SELECT Compkey, MIN(fail_yr_seg) AS lineAtYear
FROM
(
SELECT * FROM #SegSmallDefects
UNION ALL    
SELECT * FROM #SegWindowB
UNION ALL
SELECT * FROM #SegWindowAReturns
)AS X GROUP BY COMPKEY
)AS A
INNER JOIN
(
SELECT * FROM #SegSmallDefects
UNION ALL   
SELECT * FROM #SegWindowB
UNION ALL
SELECT * FROM #SegWindowAReturns
) AS B
ON A.compkey = B.COMPKEY
LEFT OUTER JOIN
#WindowA
ON B.Compkey = #WindowA.compkey
   AND
   B.cutno = #windowA.cutno
ORDER BY A.Compkey, B.cutno


SELECT  B.*, A.windowA, A.windowB INTO #validActionPipes
FROM    #WindowTotals AS A
        LEFT JOIN
        GIS.COSTEST_BPWActionYears AS B
        ON  A.compkey = B.Compkey

--Now that we have these numbers, we need to apply them to the cost estimator
--Easiest is OC, just import the OC capitalCost 
--Do I need to determine if something is a bore/jack before I do these calcs? I think I do.
SELECT  B.compkey, B.baseOpenCutRepairTime, B.baseBoreJackRepairTime, B.manholeReplacement,  B.trafficControl, B.mainlineBypass, B.lateralBypass, B.boreJackPitExcavation
INTO    #BPWOpenCutWorkTable1
FROM    dbo.COSTEST_ConstructionDurations AS B
WHERE   COMPKEY IN (SELECT COMPKEY FROM #validActionPipes)
        AND
        B.cutno = 0

            

--Next up is the case where we just need to line (remember we are only concerned with things that fail in the next 20 years).
/*SELECT  B.compkey, B.baseCIPPRepairTime, B.trafficControl, B.mainlineBypass, B.lateralBypass, A.cutno, A.APWWindowBSegFailureYear, A.APWLineAtYear, APWReplaceAtYear
FROM    #validActionPipes AS A
        INNER JOIN
        dbo.COSTEST_ConstructionDurations AS B
        ON  A.compkey = B.compkey 
            AND
            B.cutno = 0*/

--And to round out the simple calculations, the time for singular spot repairs
/*SELECT  B.compkey, B.baseSPRepairTime, B.trafficControl, B.mainlineBypass, A.cutno, A.APWWindowBSegFailureYear, A.APWLineAtYear, APWReplaceAtYear
FROM    #validActionPipes AS A
        INNER JOIN
        dbo.COSTEST_ConstructionDurations AS B
        ON  A.compkey = B.compkey 
            AND
            B.cutno > 0 
            AND
            A.cutno = B.cutno*/


--------------------------------------------
--APW results
--Now is the time to finally mesh spots with spots (then after that nastiness is figured out, we mesh spots with liners)
--What are the spots that are due in window A, and what are their failure years?
--SELECT * FROM #WindowA
--What are the spots in window B, and what are their failure years?
--SELECT * FROM #SegWindowB
--What does it look like when I join these two?
--We also need a lineAtYear, which is the lowest of windowBFailureYear OR GETDATE() + 2*Tr
SELECT  WindowFailureYearsSubQuery.Compkey,
        WindowFailureYearsSubQuery.cutno,
        WindowFailureYearsSubQuery.windowAFailureYear,
        WindowFailureYearsSubQuery.windowBFailureYear,
        MinimumLineAtYearsSubquery.lineAtYear 
INTO    #WindowBasedReplaceYears
FROM    (
           SELECT  compkey, cutno, fail_yr_seg AS windowAFailureYear, NULL AS windowBFailureYear
           FROM    #WindowA
           UNION ALL
           SELECT  compkey, cutno, NULL AS windowAFailureYear, fail_yr_seg AS windowBFailureYear
           FROM    #SegWindowB
           WHERE   compkey IN (SELECT compkey FROM #WindowA)
         ) AS WindowFailureYearsSubQuery
         INNER JOIN
         (
           SELECT  compkey, MIN(LineAtYearSets) AS lineAtYear
           FROM    (
                     SELECT  compkey, fail_yr_seg + @Ts AS LineAtYearSets
                     FROM    #WindowA AS A
                     UNION ALL
                     SELECT  compkey, fail_yr_seg AS LineAtYearSets
                     FROM    #SegWindowB
                     WHERE   compkey IN (SELECT compkey FROM #WindowA)
                   ) AS LineAtYearSubQuery
           GROUP BY COMPKEY
         ) AS MinimumLineAtYearsSubquery
         ON WindowFailureYearsSubQuery.compkey = MinimumLineAtYearsSubquery.compkey
ORDER BY WindowFailureYearsSubQuery.compkey, cutno

--Now we need to assign construction times to each spot repair
SELECT  #WindowBasedReplaceYears.compkey,
        #WindowBasedReplaceYears.cutno,
        #WindowBasedReplaceYears.windowAFailureYear,
        #WindowBasedReplaceYears.windowBFailureYear,
        #WindowBasedReplaceYears.lineAtYear,
        dbo.COSTEST_ConstructionDurations.baseSPRepairTime,
        dbo.COSTEST_ConstructionDurations.trafficControl,
        dbo.COSTEST_ConstructionDurations.mainlineBypass
INTO    #spotRepairConstructionDurations
FROM    #WindowBasedReplaceYears
        INNER JOIN
        dbo.COSTEST_ConstructionDurations
        ON  #WindowBasedReplaceYears.compkey = dbo.COSTEST_ConstructionDurations.compkey
            AND
            #WindowBasedReplaceYears.cutno = dbo.COSTEST_ConstructionDurations.cutno
ORDER BY #WindowBasedReplaceYears.compkey, #WindowBasedReplaceYears.cutno


SELECT  compkey,
        SUM(ISNULL(windowAFailureYear, 0)/ISNULL(windowAFailureYear, 1) * baseSPRepairTime) AS sumBaseSPRepairTimeWindowA,
        MAX(ISNULL(windowAFailureYear, 0)/ISNULL(windowAFailureYear, 1) * trafficControl) AS maxTrafficControlWindowA,
        MAX(ISNULL(windowAFailureYear, 0)/ISNULL(windowAFailureYear, 1) * mainlineBypass) AS maxMainlineBypassWindowA
INTO    #WindowASpotsAggregateDurations
FROM    #spotRepairConstructionDurations
GROUP BY compkey

SELECT  compkey,
        SUM(ISNULL(windowBFailureYear, 0)/ISNULL(windowBFailureYear, 1) * baseSPRepairTime) AS sumBaseSPRepairTimeWindowB,
        MAX(ISNULL(windowBFailureYear, 0)/ISNULL(windowBFailureYear, 1) * trafficControl) AS maxTrafficControlWindowB,
        MAX(ISNULL(windowBFailureYear, 0)/ISNULL(windowBFailureYear, 1) * mainlineBypass) AS maxMainlineBypassWindowB
INTO    #WindowBSpotsAggregateDurations
FROM    #spotRepairConstructionDurations
GROUP BY compkey

--These times are all well and good, but we also need to have the liner times as well
--Every single pipe in this set of windowA, windowB needs a liner time (no baseCIPPRepairTimes can be 0)
SELECT  A.compkey, 
        B.baseCIPPRepairTime, 
        B.trafficControl, 
        B.mainlineBypass, 
        B.lateralBypass,
        C.sumBaseSPRepairTimeWindowB,
        C.maxTrafficControlWindowB,
        C.maxMainlineBypassWindowB
INTO    #BPWWindowBLinersWorkTable1
FROM    (
          SELECT compkey
          FROM   #validActionPipes
          GROUP BY compkey
        ) AS A
        INNER JOIN
        dbo.COSTEST_ConstructionDurations AS B
        ON  A.compkey = B.compkey 
            AND
            B.cutno = 0
        LEFT OUTER JOIN
        #WindowBSpotsAggregateDurations AS C
        ON A.compkey = C.compkey
ORDER BY b.compkey

SELECT  Compkey,
        ISNULL(baseCIPPRepairTime, 0) + ISNULL(sumBaseSPRepairTimeWindowB, 0) AS SumSpotLineBaseRepairTime,
        CASE
          WHEN trafficControl > maxTrafficControlWindowB THEN trafficControl
          ELSE maxTrafficControlWindowB
        END AS maxTrafficControl,
        CASE
          WHEN mainlineBypass > maxMainlineBypassWindowB THEN mainlineBypass
          ELSE maxMainlineBypassWindowB
        END AS mainlineBypass,
        lateralBypass
INTO    #BPWWindowBLinersWorkTable2
FROM    #BPWWindowBLinersWorkTable1

UPDATE  #BPWWindowBLinersWorkTable2
SET     lateralBypass = lateralBypass * (CASE WHEN (ISNULL(B.countxArt, 0) + ISNULL(B.countxMJArt, 0)) > 0 THEN 1 ELSE 0 END)
FROM    #BPWWindowBLinersWorkTable2 AS A
        LEFT JOIN
        dbo.COSTEST_PIPEXP_WHOLE AS B
        ON  A.compkey = B.compkey
            

SELECT  Compkey,
        ISNULL(SumSpotLineBaseRepairTime, 0)
        + ISNULL(maxTrafficControl, 0)
        + ISNULL(mainlineBypass, 0)
        + ISNULL(lateralBypass, 0) AS SpotLineTimeB
INTO    #BPWWindowBLinersFinalTimes
FROM    #BPWWindowBLinersWorkTable2

SELECT  Compkey,
        ISNULL(sumBaseSPRepairTimeWindowA, 0)
        + ISNULL(maxTrafficControlWindowA,0)
        + ISNULL(maxMainlineBypassWindowA,0) AS SpotTimeA
INTO    #BPWWindowASpotsFinalTimes
FROM    #WindowASpotsAggregateDurations


SELECT  Compkey,
        ISNULL(baseOpenCutRepairTime, baseBoreJackRepairTime)
        + ISNULL(manholeReplacement,0)
        + ISNULL(trafficControl,0) 
        + ISNULL(mainlineBypass,0) 
        + ISNULL(boreJackPitExcavation,0)
        + CASE WHEN baseOpenCutRepairTime IS NULL THEN 0 ELSE ISNULL(lateralBypass,0) END AS WholePipeTime
INTO    #BPWOpenCutFinalTimes
FROM    #BPWOpenCutWorkTable1


SELECT  A.compkey, 
        B.baseCIPPRepairTime, 
        B.trafficControl, 
        B.mainlineBypass, 
        B.lateralBypass,
        C.sumBaseSPRepairTimeWindowA,
        C.maxTrafficControlWindowA,
        C.maxMainlineBypassWindowA
INTO    #BPWWindowALinersWorkTable1
FROM    (
          SELECT compkey
          FROM   #validActionPipes
          GROUP BY compkey
        ) AS A
        INNER JOIN
        dbo.COSTEST_ConstructionDurations AS B
        ON  A.compkey = B.compkey 
            AND
            B.cutno = 0
        LEFT OUTER JOIN
        #WindowASpotsAggregateDurations AS C
        ON A.compkey = C.compkey
ORDER BY b.compkey

SELECT  Compkey,
        ISNULL(baseCIPPRepairTime, 0) + ISNULL(sumBaseSPRepairTimeWindowA, 0) AS SumSpotLineBaseRepairTime,
        CASE
          WHEN trafficControl > maxTrafficControlWindowA THEN trafficControl
          ELSE maxTrafficControlWindowA
        END AS maxTrafficControl,
        CASE
          WHEN mainlineBypass > maxMainlineBypassWindowA THEN mainlineBypass
          ELSE maxMainlineBypassWindowA
        END AS mainlineBypass,
        lateralBypass
INTO    #BPWWindowALinersWorkTable2
FROM    #BPWWindowALinersWorkTable1

UPDATE  #BPWWindowALinersWorkTable2
SET     lateralBypass = lateralBypass * (CASE WHEN (ISNULL(B.countxArt, 0) + ISNULL(B.countxMJArt, 0)) > 0 THEN 1 ELSE 0 END)
FROM    #BPWWindowALinersWorkTable2 AS A
        LEFT JOIN
        dbo.COSTEST_PIPEXP_WHOLE AS B
        ON  A.compkey = B.compkey

SELECT  Compkey,
        ISNULL(SumSpotLineBaseRepairTime, 0)
        + ISNULL(maxTrafficControl, 0)
        + ISNULL(mainlineBypass, 0)
        + ISNULL(lateralBypass, 0) AS SpotLineTimeA
INTO    #BPWWindowALinersFinalTimes
FROM    #BPWWindowALinersWorkTable2




--These are our final times for window A spots
--SELECT  * FROM #APWWindowASpotsFinalTimes
--These are our final times for window B liners and spotliners
--SELECT  * FROM #APWWindowBLinersFinalTimes
--These are our final times for open cut jobs (that have work in window A)
--SELECT  * FROM #APWOpenCutFinalTimes
--These are our final times for straight liner jobs (that have work in window A)
--SELECT  * FROM #APWWindowALinersFinalTimes
TRUNCATE TABLE COSTEST_FinalTimeTableBPW
INSERT INTO COSTEST_FinalTimeTableBPW
(
  Compkey,
  SpotTimeA,
  SpotLineTimeB,
  WholePipeTime,
  SpotLineTimeA
)
SELECT  A.Compkey,
        A.SpotTimeA,
        B.SpotLineTimeB,
        C.WholePipeTime,
        D.SpotLineTimeA

FROM    #BPWWindowASpotsFinalTimes AS A
        INNER JOIN
        #BPWWindowBLinersFinalTimes AS B
        ON A.compkey = B.compkey
        INNER JOIN
        #BPWOpenCutFinalTimes AS C
        ON A.compkey = C.compkey
        INNER JOIN
        #BPWWindowALinersFinalTimes AS D
        ON A.compkey = D.compkey
        
        
/*        
SELECT  A.*, B.GLOBALID, C.PipelineBuildDuration * 8 AS OriginalCostEstimatorTime
FROM    #FinalTimeTable AS A
        INNER JOIN
        GIS.REHAB_Segments AS B
        ON  A.compkey = B.compkey
            AND
            B.cutno = 0
        INNER JOIN
        [REHAB].[dbo].[COSTEST_PIPE] AS C
        ON  B.GLOBALID = C.GLOBALID
            AND
            C.ID < 40000000
*/
DROP TABLE #MM1
DROP TABLE #SegSmallDefects
DROP TABLE #SegWindowB
DROP TABLE #SegWindowAReturns
DROP TABLE #WindowTotals

DROP TABLE #validActionPipes
DROP TABLE #WindowA
DROP TABLE #WindowBasedReplaceYears
DROP TABLE #spotRepairConstructionDurations
DROP TABLE #WindowASpotsAggregateDurations
DROP TABLE #WindowBSpotsAggregateDurations
DROP TABLE #BPWWindowBLinersWorkTable1
DROP TABLE #BPWWindowBLinersWorkTable2
DROP TABLE #BPWWindowBLinersFinalTimes
DROP TABLE #BPWOpenCutWorkTable1
DROP TABLE #BPWOpenCutFinalTimes
DROP TABLE #BPWWindowASpotsFinalTimes
DROP TABLE #BPWWindowALinersWorkTable1
DROP TABLE #BPWWindowALinersWorkTable2
DROP TABLE #BPWWindowALinersFinalTimes
DROP TABLE #BPWWindowAStartingYear


END
GO

