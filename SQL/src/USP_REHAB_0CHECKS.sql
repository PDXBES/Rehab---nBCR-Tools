USE [REHAB]
GO

/****** Object:  StoredProcedure [GIS].[USP_REHAB_0CHECKS]    Script Date: 08/12/2011 12:40:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GIS].[USP_REHAB_0CHECKS]
AS
BEGIN
	SELECT TOP (1) STARTDTTM FROM [SIRTOBY].[HANSEN].[IMSV7].INSMNFT order by STARTDTTM desc
END

GO

