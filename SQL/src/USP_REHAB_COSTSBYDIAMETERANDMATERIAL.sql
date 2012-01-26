USE [REHAB]
GO

/****** Object:  StoredProcedure [GIS].[USP_REHAB_COSTSBYDIAMETERANDMATERIAL]    Script Date: 01/25/2012 15:33:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GIS].[USP_REHAB_COSTSBYDIAMETERANDMATERIAL]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @theQuery nvarchar(max)
DECLARE @theIterator int

SET @theIterator = 0
SET @theQuery = 'SELECT SUM(CAST(replacecost AS float)) AS Total_replace_cost, Dia, SUM(csp) as csp, SUM(csplength) as cspft, SUM(rcp) as rcp, SUM(rcplength) as rcpft, SUM(vsp) as vsp, SUM(vsplength) as vspft, SUM(pvc) as pvc, SUM(pvclength) as pvcft, SUM(mono) as mono, SUM(monolength) as monoft, SUM(brick) as brick, SUM(bricklength) as brickft,SUM(others) as others, SUM(otherslength) as othersft '
WHILE @theIterator < 6
BEGIN
	--SET @theQuery = @theQuery + ',SUM(CAST([' + convert(nvarchar(10), @theIterator) + '] AS float)) AS [' + convert(nvarchar(10), @theIterator) + ']'
	--SET @theQuery = @theQuery + ',SUM(CAST([' + convert(nvarchar(10), @theIterator) + 'length] AS float)) AS [' + convert(nvarchar(10), @theIterator) + 'length]'
	
	SET @theIterator = @theIterator + 1
END

SET @theQuery = @theQuery + 'FROM (SELECT A.replacecost, CASE WHEN A.diamwidth <= 12 THEN ''<= 12'' WHEN A.diamwidth <= 18 AND A.diamwidth > 12 THEN ''>12 <= 18'' WHEN A.diamwidth <= 24 AND A.diamwidth > 18 THEN ''>18 <= 24'' WHEN A.diamwidth <= 36 AND A.diamwidth > 24 THEN ''>24 <= 36'' WHEN A.diamwidth <= 54 AND A.diamwidth > 36 THEN ''>36 <=54'' WHEN A.diamwidth > 54 THEN ''>54'' END AS Dia'
--SET @theIterator = 0
--WHILE @theIterator < 6
--BEGIN
--CSP
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''CSP'' THEN replacecost ELSE 0 END AS [CSP]'
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''CSP'' THEN A.length ELSE 0 END AS [CSPlength]'
--RCP
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''RCP'' THEN replacecost ELSE 0 END AS [RCP]'
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''RCP'' THEN A.length ELSE 0 END AS [RCPlength]'
--VCP
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''VSP'' THEN replacecost ELSE 0 END AS [VSP]'
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''VSP'' THEN A.length ELSE 0 END AS [VSPlength]'
--PVC
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''PVC'' THEN replacecost ELSE 0 END AS [PVC]'
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''PVC'' THEN A.length ELSE 0 END AS [PVClength]'
--MONO
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''MONO'' THEN replacecost ELSE 0 END AS [MONO]'
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''MONO'' THEN A.length ELSE 0 END AS [MONOlength]'
--BRICK
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''BRICK'' THEN replacecost ELSE 0 END AS [BRICK]'
	SET @theQuery = @theQuery + ', CASE WHEN A.material = ''BRICK'' THEN A.length ELSE 0 END AS [BRICKlength]'
--OTHERS
	SET @theQuery = @theQuery + ', CASE WHEN (A.material <> ''CSP'' AND A.material <> ''RCP'' AND A.material <> ''VSP'' AND A.material <> ''PVC'' AND A.material <> ''MONO'' AND A.material <> ''BRICK'') THEN replacecost ELSE 0 END AS [OTHERS]'
	SET @theQuery = @theQuery + ', CASE WHEN (A.material <> ''CSP'' AND A.material <> ''RCP'' AND A.material <> ''VSP'' AND A.material <> ''PVC'' AND A.material <> ''MONO'' AND A.material <> ''BRICK'') THEN A.length ELSE 0 END AS [OTHERSlength]'
	--SET @theIterator = @theIterator + 1
--END
--COMBINED system pipes
  /*SET @theQuery = @theQuery + ' FROM	GIS.REHAB10FTSEGS AS A'
  SET @theQuery = @theQuery + '			INNER JOIN '
  SET @theQuery = @theQuery + '			[HANSEN8].[ASSETMANAGEMENT_SEWER].[COMPSMN] AS B '
  SET @theQuery = @theQuery + '			ON	A.COMPKEY = B.COMPKEY '
  SET @theQuery = @theQuery + ' WHERE	A.mlinkid < 40000000 '
  SET @theQuery = @theQuery +         ' AND '
  SET @theQuery = @theQuery +         ' (	A.REMARKS = ''BES'' '
  SET @theQuery = @theQuery +			  ' OR '
  SET @theQuery = @theQuery +			  ' A.REMARKS = ''UNKN'' '
  SET @theQuery = @theQuery +			  ' OR '
  SET @theQuery = @theQuery +			  ' A.REMARKS = ''NULL'' '
  SET @theQuery = @theQuery +         ' ) '
  SET @theQuery = @theQuery +         ' AND '
  SET @theQuery = @theQuery +         ' ( '
  SET @theQuery = @theQuery +              ' A.COMPKEY IN '
  SET @theQuery = @theQuery +					'(SELECT  COMPKEY ' 
  SET @theQuery = @theQuery +					' FROM    [SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS X'
  SET @theQuery = @theQuery +					' WHERE	  X.UNITTYPE = ''CSML'' '
  SET @theQuery = @theQuery +							' OR '
  SET @theQuery = @theQuery +							' X.UNITTYPE = ''CSINT'' '
  SET @theQuery = @theQuery +							' OR '
  SET @theQuery = @theQuery +							' X.UNITTYPE = ''CSDET'' '
  SET @theQuery = @theQuery +							' OR '
  SET @theQuery = @theQuery +							' X.UNITTYPE = ''CSOTN'' '
  SET @theQuery = @theQuery +                    ')' 
  SET @theQuery = @theQuery +              ' OR '
  SET @theQuery = @theQuery +              ' A.COMPKEY IN '
  SET @theQuery = @theQuery +                  ' (SELECT  COMPKEY '
  SET @theQuery = @theQuery +                  '  FROM    [SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS Z'
  SET @theQuery = @theQuery +                  '  WHERE   Z.UNITTYPE = ''CSO_OUTFALLS'' '
  SET @theQuery = @theQuery +                  '  ) '
  SET @theQuery = @theQuery +          ') '*/
--SANITARY system pipes
  SET @theQuery = @theQuery + ' FROM	GIS.REHAB10FTSEGS AS A'
  SET @theQuery = @theQuery + '			INNER JOIN '
  SET @theQuery = @theQuery + '			[HANSEN8].[ASSETMANAGEMENT_SEWER].[COMPSMN] AS B '
  SET @theQuery = @theQuery + '			ON	A.COMPKEY = B.COMPKEY '
  SET @theQuery = @theQuery + ' WHERE	A.mlinkid < 40000000 '
  SET @theQuery = @theQuery +         ' AND '
  SET @theQuery = @theQuery +         ' (	A.REMARKS = ''BES'' '
  SET @theQuery = @theQuery +			  ' OR '
  SET @theQuery = @theQuery +			  ' A.REMARKS = ''UNKN'' '
  SET @theQuery = @theQuery +			  ' OR '
  SET @theQuery = @theQuery +			  ' A.REMARKS = ''NULL'' '
  SET @theQuery = @theQuery +         ' ) '
  SET @theQuery = @theQuery +         ' AND '
  SET @theQuery = @theQuery +         ' ( '
  SET @theQuery = @theQuery +				' A.COMPKEY IN '
  SET @theQuery = @theQuery +					'(SELECT	COMPKEY '
  SET @theQuery = @theQuery +                   ' FROM		[SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS X'
  SET @theQuery = @theQuery +                   ' WHERE		X.UNITTYPE = ''SAML'' '
  SET @theQuery = @theQuery +                             ' OR '
  SET @theQuery = @theQuery +                             ' X.UNITTYPE = ''SAINT'' '
  SET @theQuery = @theQuery +                             ' OR '
  SET @theQuery = @theQuery +                             ' X.UNITTYPE = ''EMBPG'' '
  SET @theQuery = @theQuery +                   ' ) '
  SET @theQuery = @theQuery +         ' ) '
--Special query that Joe asked for 
  /*SET @theQuery = @theQuery + ' FROM	GIS.REHAB10FTSEGS AS A'
  --Comment the following out for overall costs
  SET @theQuery = @theQuery + '			INNER JOIN '
  SET @theQuery = @theQuery + '			GIS.MST_LINKS AS B '
  SET @theQuery = @theQuery + '			ON	A.mlinkID = B.mlinkID '
  ---End of commentable part
  SET @theQuery = @theQuery + ' WHERE	A.mlinkid < 40000000 '
  SET @theQuery = @theQuery +         ' AND '
  SET @theQuery = @theQuery +         ' (	A.REMARKS = ''BES'' '
  SET @theQuery = @theQuery +			  ' OR '
  SET @theQuery = @theQuery +			  ' A.REMARKS = ''UNKN'' '
  SET @theQuery = @theQuery +			  ' OR '
  SET @theQuery = @theQuery +			  ' A.REMARKS = ''NULL'' '
  SET @theQuery = @theQuery +         ' ) '
  SET @theQuery = @theQuery +         ' AND '
  SET @theQuery = @theQuery +         ' ( '
  SET @theQuery = @theQuery +              ' A.COMPKEY IN '
  SET @theQuery = @theQuery +					'(SELECT  COMPKEY ' 
  SET @theQuery = @theQuery +					' FROM    [SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS X'
  SET @theQuery = @theQuery +					' WHERE	(  X.UNITTYPE = ''CSML'' '
  SET @theQuery = @theQuery +							' OR '
  SET @theQuery = @theQuery +							' X.UNITTYPE = ''CSINT'' '
  SET @theQuery = @theQuery +							' OR '
  SET @theQuery = @theQuery +							' X.UNITTYPE = ''CSDET'' '
  SET @theQuery = @theQuery +                          ') '
  SET @theQuery = @theQuery +                         ' AND A.LINKTYPE <> ''CC'' '
  SET @theQuery = @theQuery +                    ')' 
  SET @theQuery = @theQuery +              ' OR '
  SET @theQuery = @theQuery +              ' A.COMPKEY IN '
  SET @theQuery = @theQuery +                  ' (SELECT  COMPKEY '
  SET @theQuery = @theQuery +                  '  FROM    [SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS Z'
  SET @theQuery = @theQuery +                  '  WHERE   Z.UNITTYPE = ''CSO_OUTFALLS'' '
  SET @theQuery = @theQuery +                           ' AND A.LINKTYPE <> ''CC'' '
  SET @theQuery = @theQuery +                  '  ) '
  SET @theQuery = @theQuery +               ') '*/
--Second special query that joe asked for
  /*SET @theQuery = @theQuery + ' FROM	GIS.REHAB10FTSEGS AS A '
  SET @theQuery = @theQuery + '			INNER JOIN '
  SET @theQuery = @theQuery + '			GIS.MST_LINKS AS B '
  SET @theQuery = @theQuery + '			ON	A.mlinkID = B.mlinkID '
  SET @theQuery = @theQuery + ' WHERE	A.mlinkid < 40000000 '
  SET @theQuery = @theQuery +         ' AND '
  SET @theQuery = @theQuery +         ' (	A.REMARKS = ''AGRE'' '
  SET @theQuery = @theQuery +			  ' OR '
  SET @theQuery = @theQuery +			  ' A.REMARKS = ''DNRV'' '
  SET @theQuery = @theQuery +         ' ) '*/
  --Third special query that joe asked for
  /*SET @theQuery = @theQuery + ' FROM	GIS.REHAB10FTSEGS AS A '
  SET @theQuery = @theQuery + '			INNER JOIN '
  SET @theQuery = @theQuery + '			GIS.MST_LINKS AS B '
  SET @theQuery = @theQuery + '			ON	A.mlinkID = B.mlinkID '*/
  --Query for all the pipes we don't care about
  /*SET @theQuery = @theQuery + ' FROM	GIS.REHAB10FTSEGS AS A'
  SET @theQuery = @theQuery + '			INNER JOIN '
  SET @theQuery = @theQuery + '			[HANSEN8].[ASSETMANAGEMENT_SEWER].[COMPSMN] AS B '
  SET @theQuery = @theQuery + '			ON	A.COMPKEY = B.COMPKEY '
  SET @theQuery = @theQuery + ' WHERE	A.mlinkid < 40000000 '
  SET @theQuery = @theQuery +         ' AND '
  SET @theQuery = @theQuery +         ' (	A.REMARKS <> ''BES'' '
  SET @theQuery = @theQuery +			  ' AND '
  SET @theQuery = @theQuery +			  ' A.REMARKS <> ''UNKN'' '
  SET @theQuery = @theQuery +			  ' AND '
  SET @theQuery = @theQuery +			  ' A.REMARKS <> ''NULL'' '
  SET @theQuery = @theQuery +         ' ) '*/
  -------------------------------------
  --To exclude consolidation conduit projects:
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''6181'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''6182'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''6183'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''6680'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''7669'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''7317'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''7512'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''7070'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''7360'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''E05510'' '
  SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'B.ASBLT <> ''E05516'' '
  --To include consolidation conduit projects:
  /*SET @theQuery = @theQuery +				'AND '
  SET @theQuery = @theQuery +				'(B.ASBLT = ''6181'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''6182'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''6183'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''6680'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''7669'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''7317'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''7512'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''7070'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''7360'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''E05510'' '
  SET @theQuery = @theQuery +				'OR '
  SET @theQuery = @theQuery +				'B.ASBLT = ''E05516'') '*/
  --For all of the above queries
  SET @theQuery = @theQuery + ') AS derivedtbl_1 GROUP BY Dia'

   Exec sp_Executesql @theQuery                  
END
GO

