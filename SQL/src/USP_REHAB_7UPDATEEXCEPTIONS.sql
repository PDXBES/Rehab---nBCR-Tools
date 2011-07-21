USE [SANDBOX]
GO

/****** Object:  StoredProcedure [ROSE\issacg].[USP_REHAB_7UPDATEEXCEPTIONS]    Script Date: 07/21/2011 08:24:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [ROSE\issacg].[USP_REHAB_7UPDATEEXCEPTIONS] AS
BEGIN
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS = null

--identify the object (seriously, some people can't do this themselves)
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  'Whole pipe' WHERE MLinkID <40000000
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  'Pipe segment' WHERE MLinkID >= 40000000

--identify if this was a BES pipe (Yes, I know this is already a column)
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', not a BES pipe' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] WHERE remarks <> 'BES'

--identify if the compkey is zero
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', compkey is zero' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] WHERE compkey =  0

--identify if the mlinkid is zero
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', mlinkid is zero' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] WHERE mlinkid =  0
	
--identify if the parent mlinkid is zero 
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', old_mlid is zero' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] WHERE old_mlid =  0
	
--identify if the length is zero
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', length is zero' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] WHERE [length] =  0
	
--identify if the pipe has only one segment and the length of that segment is zero
UPDATE B SET B.EXCEPTIONS =  B.EXCEPTIONS + ', pipe segment has zero length' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] AS A INNER JOIN [SANDBOX].[GIS].[REHAB10FTSEGS] AS B ON A.COMPKEY = B.COMPKEY AND A.MlinkID <> B.MLinkID and A.[length] = 0 and A.MlinkID >= 40000000 and A.seg_count = 1
--if multiple links in mst_links share the same compkey number, then that should be noted
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', multiple mst_links matches on compkey'
	FROM [SANDBOX].[GIS].[REHAB10FTSEGS]
	INNER JOIN ([SANDBOX].[GIS].[MST_LINKS] AS A INNER JOIN [SANDBOX].[GIS].[MST_LINKS] AS B ON  A.COMPKEY = B.COMPKEY AND A.MLInkID <> B.MLInkID) 
	ON A.COMPKEY = [SANDBOX].[GIS].[REHAB10FTSEGS].COMPKEy 

--if there is no match in the COMPSMN or STMN tables, then identify that.
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS = EXCEPTIONS + ', no match in COMPSMN OR COMPSTMN' 
FROM ([SANDBOX].[GIS].[REHAB10FTSEGS] AS C LEFT JOIN [SIRTOBY].[HANSEN].[IMSV7].COMPSMN AS A ON C.COMPKEY = A.COMPKEY ) 
	LEFT JOIN [SIRTOBY].[HANSEN].[IMSV7].COMPSTMN AS B ON C.COMPKEY = B.COMPKEY WHERE B.COMPKEY IS NULL AND A.COMPKEY is null

--if there is no match in the consequence of failure table...
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS = EXCEPTIONS + ', no consequence of failure given' 
FROM [SANDBOX].[GIS].[REHAB10FTSEGS] LEFT JOIN [SANDBOX].[ROSE\issacg].REHAB_MortalityExport on [SANDBOX].[ROSE\issacg].REHAB_MortalityExport.COMPKEY = [SANDBOX].[GIS].[REHAB10FTSEGS].COMPKEY WHERE [SANDBOX].[ROSE\issacg].REHAB_MortalityExport.COMPKEY is null

--if there is no match in the construction cost table...
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS = EXCEPTIONS + ', no construction cost given' 
FROM [SANDBOX].[GIS].[REHAB10FTSEGS] LEFT JOIN [SANDBOX].[ROSE\issacg].REHAB_ConstructionExport on [SANDBOX].[ROSE\issacg].REHAB_ConstructionExport.COMPKEY = [SANDBOX].[GIS].[REHAB10FTSEGS].COMPKEY WHERE [SANDBOX].[ROSE\issacg].REHAB_ConstructionExport.COMPKEY is null

--identify if the pipe's inspection was before the last replacement, or the servstat is 'PEND'
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', pipe was replaced after last inspection or servstat is PEND' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] WHERE insp_curr =  3

--identify if the pipe's inspection does not exist 
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', no valid inspection' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] WHERE insp_curr =  4
	
--identify if the install date is null and the pipe is tbab or aban 
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', pipe has no install date and is tbab or aban' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] WHERE mlinkid =  2

--identify if the the inspection was not completed in one pass
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', inspection not completed in one pass' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] INNER JOIN REHAB_CONVERSION ON [SANDBOX].[GIS].[REHAB10FTSEGS].COMPKEY = REHAB_CONVERSION.COMPKEY WHERE COMPDTTM is null

--identify if the the inspection goes beyond the mst_links length of the pipe
UPDATE [SANDBOX].[GIS].[REHAB10FTSEGS] SET EXCEPTIONS =  EXCEPTIONS + ', inspection is longer than known length of pipe' FROM 
	[SANDBOX].[GIS].[REHAB10FTSEGS] INNER JOIN REHAB_CONVERSION ON [SANDBOX].[GIS].[REHAB10FTSEGS].COMPKEY = REHAB_CONVERSION.COMPKEY WHERE convert_setdwn_from > [length] or convert_setdwn_to > [length]
END

GO

