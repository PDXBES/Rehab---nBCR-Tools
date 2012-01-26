USE [REHAB]
GO

/****** Object:  View [GIS].[COF-0160g Spill Far School]    Script Date: 01/25/2012 15:57:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GIS].[COF-0160g Spill Far School]
AS
SELECT     GIS.[CMOM-Trace-Aggregated].CompKey, SUM(GIS.Constants.IllicitSpillFarSchool) AS Consequence, 1 AS SFM, 12 AS TBLF, 
                      'PUBHEALTHSPILLNEARSCH' AS Reason
FROM         GIS.Constants CROSS JOIN
                      GIS.[CMOM-Trace-Aggregated] INNER JOIN
                      GIS.CMOM_PipXP ON GIS.[CMOM-Trace-Aggregated].CompKey = GIS.CMOM_PipXP.CompKey
GROUP BY GIS.[CMOM-Trace-Aggregated].CompKey, GIS.CMOM_PipXP.xSchl
HAVING      (GIS.CMOM_PipXP.xSchl = 0)

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[3] 2[64] 3) )"
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
         Begin Table = "Constants"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 304
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CMOM-Trace-Aggregated"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 207
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CMOM_PipXP"
            Begin Extent = 
               Top = 114
               Left = 250
               Bottom = 222
               Right = 417
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
      Begin ColumnWidths = 12
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
' , @level0type=N'SCHEMA',@level0name=N'GIS', @level1type=N'VIEW',@level1name=N'COF-0160g Spill Far School'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'GIS', @level1type=N'VIEW',@level1name=N'COF-0160g Spill Far School'
GO

