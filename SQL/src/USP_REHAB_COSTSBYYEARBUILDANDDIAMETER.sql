USE [SANDBOX]
GO
/****** Object:  StoredProcedure [ROSE\issacg].[USP_REHAB_COSTSBYYEARBUILDANDDIAMETER]    Script Date: 06/28/2011 16:31:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [ROSE\issacg].[USP_REHAB_COSTSBYYEARBUILDANDDIAMETER]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @theQuery nvarchar(max)
DECLARE @theIterator int

SET @theIterator = 1900
SET @theQuery = 'SELECT SUM(CAST(replacecost AS float)) AS Total_replace_cost, Dia'
WHILE @theIterator < 2011
BEGIN
	SET @theQuery = @theQuery + ',SUM(CAST([' + convert(nvarchar(10), @theIterator) + '] AS float)) AS [' + convert(nvarchar(10), @theIterator) + ']'
	SET @theIterator = @theIterator + 1
END

SET @theQuery = @theQuery + 'FROM (SELECT replacecost, CASE WHEN diamwidth <= 12 THEN ''<= 12'' WHEN diamwidth <= 18 AND diamwidth > 12 THEN ''>12 <= 18'' WHEN diamwidth <= 24 AND diamwidth > 18 THEN ''>18 <= 24'' WHEN diamwidth <= 36 AND diamwidth > 24 THEN ''>24 <= 36'' WHEN diamwidth <= 54 AND diamwidth > 36 THEN ''>36 <= 54'' ELSE ''>54'' END AS Dia'
SET @theIterator = 1900
WHILE @theIterator < 2011
BEGIN
	SET @theQuery = @theQuery + ', CASE WHEN instdate between '''+convert(nvarchar(10), @theIterator) +'-01-01'' AND  ''' + convert(nvarchar(10), @theIterator+1) + '-01-01'' THEN replacecost ELSE 0 END AS [' + convert(nvarchar(10), @theIterator) + ']'
	SET @theIterator = @theIterator + 1
END
SET @theQuery = @theQuery + 'FROM GIS.REHAB10FTSEGS WHERE (mlinkid < 40000000)) AS derivedtbl_1 GROUP BY Dia'

     Exec sp_Executesql @theQuery
                  
END
