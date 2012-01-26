USE [REHAB]
GO

/****** Object:  StoredProcedure [GIS].[USP_REHAB_9HIDEDATATHATGETSUSEDINCORRECTLY_10]    Script Date: 01/25/2012 15:32:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [GIS].[USP_REHAB_9HIDEDATATHATGETSUSEDINCORRECTLY_10] AS
BEGIN

UPDATE REHAB10FTSEGS
SET 
	[BPW]			= NULL,
	[APW]			= NULL,
	[CBR]			= NULL,
	[Fail_YR]		= NULL,
	[RULife]		= NULL,
	[RUL_Flag]		= NULL,
	[Std_DEV]		= NULL,
	[fail_yr_whole] = NULL,
	[std_dev_whole] = NULL
WHERE MLinkID >= 40000000
	
UPDATE REHAB10FTSEGS
SET 
	[BPW_seg]			= NULL,
	[APW_seg]			= NULL,
	[CBR_seg]			= NULL,
	[Fail_YR_seg]		= NULL,
	[Std_DEV_seg]		= NULL
WHERE MLinkID < 40000000

END
GO

