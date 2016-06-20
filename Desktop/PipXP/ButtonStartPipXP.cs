using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using ESRI.ArcGIS.Framework;

namespace PipXP
{
    public class ButtonStartPipXP : ESRI.ArcGIS.Desktop.AddIns.Button
    {
        public ButtonStartPipXP()
        {
        }

        protected override void OnClick()
        {
            //
            //  TODO: Sample code showing how to access button host
            //
            ArcMap.Application.CurrentTool = null;
            ESRI.ArcGIS.esriSystem.UID dockWinID = new ESRI.ArcGIS.esriSystem.UIDClass();
            dockWinID.Value = ThisAddIn.IDs.PipXP;

            // Use GetDockableWindow directly as we want the client IDockableWindow not the internal class  
            IDockableWindow dockWindow = ArcMap.DockableWindowManager.GetDockableWindow(dockWinID);
            dockWindow.Show(true);
            dockWindow.Caption = "PipXP";
        }
        protected override void OnUpdate()
        {
            Enabled = ArcMap.Application != null;
        }
    }

}
