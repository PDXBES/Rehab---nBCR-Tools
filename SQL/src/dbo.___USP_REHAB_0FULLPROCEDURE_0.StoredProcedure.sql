USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[___USP_REHAB_0FULLPROCEDURE_0]    Script Date: 03/23/2016 14:09:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Issac Gardner>
-- Create date: <7/30/2013>
-- Description:	<REHAB GO PROCESS>
-- =============================================
CREATE PROCEDURE [dbo].[___USP_REHAB_0FULLPROCEDURE_0] @UpToDate datetime = null
AS
BEGIN

IF @UpToDate IS NULL
   SET @UpToDate = GETDATE()
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @intErrorCode INT
	
	SET NOCOUNT ON;
	--BEGIN TRAN
		EXEC __USP_REHAB_01CREATECONVERSIONGIS @UpToDate
		--SELECT @intErrorCode = @@ERROR
		--IF (@intErrorCode <> 0) GOTO PROBLEM
		
		EXEC __USP_REHAB_06ApplyLifespans_0 @recreateLookupTables = 1, @AsOfDate = @UpToDate
		--SELECT @intErrorCode = @@ERROR
		--IF (@intErrorCode <> 0) GOTO PROBLEM
		
		EXEC __USP_REHAB_07ApplyCosts_0 @recreateLookupTables = 1, @AsOfDate = @UpToDate
		--SELECT @intErrorCode = @@ERROR
		--IF (@intErrorCode <> 0) GOTO PROBLEM
		
		EXEC __USP_REHAB_08SimpleUpdates
		--SELECT @intErrorCode = @@ERROR
		--IF (@intErrorCode <> 0) GOTO PROBLEM
		
		EXEC __USP_REHAB_09RedundancyToSegments
		--SELECT @intErrorCode = @@ERROR
		--IF (@intErrorCode <> 0) GOTO PROBLEM
		
		EXEC __USP_REHAB_10Gen3nBCR_0
		--SELECT @intErrorCode = @@ERROR
		--IF (@intErrorCode <> 0) GOTO PROBLEM
		
		
		
		EXEC __USP_REHAB_12CreatenBCRMatrix @AsOfDate = @UpToDate
		--SELECT @intErrorCode = @@ERROR
		--IF (@intErrorCode <> 0) GOTO PROBLEM
		
		
		EXEC __USP_REHAB_13FillEasyTable_0 @AsOfDate = @UpToDate
		--SELECT @intErrorCode = @@ERROR
		--IF (@intErrorCode <> 0) GOTO PROBLEM
		
	--COMMIT TRAN
	
	/*PROBLEM:
		IF (@intErrorCode <> 0) 
		BEGIN
			PRINT 'Unexpected error occurred!'
			ROLLBACK TRAN
		END*/
END

GO

