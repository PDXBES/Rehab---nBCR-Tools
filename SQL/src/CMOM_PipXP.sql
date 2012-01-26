USE [REHAB]
GO

/****** Object:  View [GIS].[CMOM_PipXP]    Script Date: 01/25/2012 15:36:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GIS].[CMOM_PipXP]
AS
SELECT     GIS.[CMOM-Trace].CompKey, GIS.mdl_pipxp_ac.MLinkID, GIS.mdl_pipxp_ac.USNode, GIS.mdl_pipxp_ac.DSNode, GIS.mdl_pipxp_ac.MLinkID_2, 
                      GIS.mdl_pipxp_ac.COMPKEY AS Expr1, GIS.mdl_pipxp_ac.xWtr, GIS.mdl_pipxp_ac.xWMinD, GIS.mdl_pipxp_ac.xWMaxD, GIS.mdl_pipxp_ac.pWtr, 
                      GIS.mdl_pipxp_ac.pWtrMaxD, GIS.mdl_pipxp_ac.pFt2Wtr, GIS.mdl_pipxp_ac.xSewer, GIS.mdl_pipxp_ac.xSwrMinD, GIS.mdl_pipxp_ac.xSwrMaxD, 
                      GIS.mdl_pipxp_ac.pSewer, GIS.mdl_pipxp_ac.pSwrMaxD, GIS.mdl_pipxp_ac.pFt2Swr, GIS.mdl_pipxp_ac.xStrt, GIS.mdl_pipxp_ac.xArt, 
                      GIS.mdl_pipxp_ac.xMJArt, GIS.mdl_pipxp_ac.xFrwy, GIS.mdl_pipxp_ac.pStrt, GIS.mdl_pipxp_ac.pStrtTyp, GIS.mdl_pipxp_ac.pFt2Strt, 
                      GIS.mdl_pipxp_ac.pTraffic, GIS.mdl_pipxp_ac.uxCLx, GIS.mdl_pipxp_ac.uxFt2CLx, GIS.mdl_pipxp_ac.dxCLx, GIS.mdl_pipxp_ac.dxFt2CLx, 
                      GIS.mdl_pipxp_ac.xFiber, GIS.mdl_pipxp_ac.pFiber, GIS.mdl_pipxp_ac.pFt2Fiber, GIS.mdl_pipxp_ac.xGas, GIS.mdl_pipxp_ac.pGas, 
                      GIS.mdl_pipxp_ac.pFt2Gas, GIS.mdl_pipxp_ac.xRail, GIS.mdl_pipxp_ac.pRail, GIS.mdl_pipxp_ac.pFt2Rail, GIS.mdl_pipxp_ac.xLRT, 
                      GIS.mdl_pipxp_ac.pLRT, GIS.mdl_pipxp_ac.pFt2LRT, GIS.mdl_pipxp_ac.xEmt, GIS.mdl_pipxp_ac.pEmt, GIS.mdl_pipxp_ac.pFt2Emt, 
                      GIS.mdl_pipxp_ac.xEzonC, GIS.mdl_pipxp_ac.xEzonP, GIS.mdl_pipxp_ac.xFtEzonC, GIS.mdl_pipxp_ac.xFtEzonP, GIS.mdl_pipxp_ac.xEzAreaC, 
                      GIS.mdl_pipxp_ac.xEzAreaP, GIS.mdl_pipxp_ac.uxMS4, GIS.mdl_pipxp_ac.uxUIC, GIS.mdl_pipxp_ac.uDepth, GIS.mdl_pipxp_ac.dDepth, 
                      GIS.mdl_pipxp_ac.xPipSlope, GIS.mdl_pipxp_ac.gSlope, GIS.mdl_pipxp_ac.xEcsi, GIS.mdl_pipxp_ac.xFt2Ecsi, GIS.mdl_pipxp_ac.xEcsiLen, 
                      GIS.mdl_pipxp_ac.xEcsiVol, GIS.mdl_pipxp_ac.xSchl, GIS.mdl_pipxp_ac.xFt2Schl, GIS.mdl_pipxp_ac.xHosp, GIS.mdl_pipxp_ac.xFt2Hosp, 
                      GIS.mdl_pipxp_ac.xPol, GIS.mdl_pipxp_ac.xFt2Pol, GIS.mdl_pipxp_ac.xFire, GIS.mdl_pipxp_ac.xFt2Fire, GIS.mdl_pipxp_ac.xBldg, 
                      GIS.mdl_pipxp_ac.xFt2Bldg, GIS.mdl_pipxp_ac.xHyd, GIS.mdl_pipxp_ac.xFt2Hyd, GIS.mdl_pipxp_ac.HardArea
FROM         GIS.mdl_Links_ac INNER JOIN
                      GIS.mdl_pipxp_ac ON GIS.mdl_Links_ac.MLinkID = GIS.mdl_pipxp_ac.MLinkID INNER JOIN
                      GIS.[CMOM-Trace] ON GIS.mdl_pipxp_ac.MLinkID = GIS.[CMOM-Trace].MLinkID

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "mdl_Links_ac"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mdl_pipxp_ac"
            Begin Extent = 
               Top = 6
               Left = 241
               Bottom = 114
               Right = 406
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CMOM-Trace"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'GIS', @level1type=N'VIEW',@level1name=N'CMOM_PipXP'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'GIS', @level1type=N'VIEW',@level1name=N'CMOM_PipXP'
GO

