USE [REHAB]
GO
/****** Object:  StoredProcedure [GIS].[USP_REHAB_0CHECKS]    Script Date: 07/29/2011 16:35:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [GIS].[USP_REHAB_0CHECKS]
AS
BEGIN
	SELECT TOP (1) STARTDTTM FROM [SIRTOBY].[HANSEN].[IMSV7].INSMNFT order by STARTDTTM desc
END
