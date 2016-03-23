USE [REHAB]
GO

/****** Object:  StoredProcedure [dbo].[__USP_REHAB_XX_SpotShim]    Script Date: 03/23/2016 14:11:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Issac Gardner>
-- Create date: <2/12/2016>
-- Description:	<Shim for spot repairs>
-- =============================================
CREATE PROCEDURE [dbo].[__USP_REHAB_XX_SpotShim] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE  ZZ1
    SET     [CapitalNonMobilization] = ISNULL([CapitalNonMobilization], 0)
            +CASE
              WHEN  Z.DiamWidth <= 12
              THEN  5121
              WHEN  Z.DiamWidth <= 21
              THEN  7058
              WHEN  Z.DiamWidth <= 36
              THEN  11280
              ELSE  17784
            END
    FROM    REHAB.GIS.REHAB_Segments AS Z
            INNER JOIN
            [COSTEST_CapitalCostsMobilizationRatesAndTimes] AS ZZ1
            ON  Z.ID = ZZ1.ID
                AND
				ZZ1.[type] = 'Spot'
                AND
                Z.cutno > 0
                
    
   
END


GO

