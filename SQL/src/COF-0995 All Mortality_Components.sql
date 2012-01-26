USE [REHAB]
GO

/****** Object:  View [GIS].[COF-0995 All Mortality_Components]    Script Date: 01/25/2012 15:58:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [GIS].[COF-0995 All Mortality_Components]
AS
SELECT     TOP (100) PERCENT CompKey, Consequence, SFM, TBLF, Reason
FROM         (SELECT     CompKey, Consequence, SFM, TBLF, Reason
                       FROM          GIS.[COF-0105 Replacement Cost of Pipe]
                       UNION
                       SELECT     CompKey, Consequence, SFM, TBLF, Reason
                       FROM         GIS.[COF-0115 Cost of Emergency Repair]
                       UNION
                       SELECT     CompKey, Consequence, SFM, TBLF, Reason
                       FROM         GIS.[COF-0125 Emergency Lateral Repair]
                       UNION
                       SELECT     CompKey, Consequence, SFM, TBLF, Reason
                       FROM         GIS.[COF-0145 Separated Area Regulatory Fine]
                       UNION
                       SELECT     CompKey, Consequence, SFM, TBLF, Reason
                       FROM         GIS.[COF-0155 Basement Flooding]
                       UNION
                       SELECT     CompKey, Consequence, SFM, TBLF, Reason
                       FROM         GIS.[COF-0161 All Public Health Safety Mainline]
                       UNION
                       SELECT     CompKey, Consequence, SFM, TBLF, Reason
                       FROM         GIS.[COF-0175 Basement Flooding]
                       UNION
                       SELECT     CompKey, Consequence, SFM, TBLF, Reason
                       FROM         GIS.[COF-0185 Basement Flooding]) AS a
ORDER BY CompKey, Reason

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[18] 4[20] 2[52] 3) )"
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
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
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
' , @level0type=N'SCHEMA',@level0name=N'GIS', @level1type=N'VIEW',@level1name=N'COF-0995 All Mortality_Components'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'GIS', @level1type=N'VIEW',@level1name=N'COF-0995 All Mortality_Components'
GO

