using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Data.SQLite;

namespace PipXP
{
    /// <summary>
    /// Designer class of the dockable window add-in. It contains user interfaces that
    /// make up the dockable window.
    /// </summary>
    public partial class PipXP : UserControl
    {
        [SQLiteFunction(Arguments = 2, FuncType = FunctionType.Scalar, Name = "power")]
        class power : SQLiteFunction
        {
            public override object Invoke(object[] args)
            {
                return Math.Pow(Double.Parse(args[0].ToString()), Double.Parse(args[0].ToString()));
            }
        }

        string inputDatabase = "";
        string sqliteConnectionString = "";
        string sourceDatabase = "";
        string sqliteSourceConnectionString = "";
        string inputPipeDatabase = "";
        string inputPipeConnectionString = "";
        string pipXPSourceDatabase="";
        string sqlitepipXPSourceDatabaseConnectionString = "";
        SQLiteConnection workingDbConnection = null;
        SQLiteConnection CostEstimateConnection = null;
        string pipXPSourceDatabaseAlias = "pipXPSourceDatabaseAlias";

        public PipXP(object hook)
        {
            InitializeComponent();
            this.Hook = hook;
        }

        /// <summary>
        /// Host object of the dockable window
        /// </summary>
        private object Hook
        {
            get;
            set;
        }

        /// <summary>
        /// Implementation class of the dockable window add-in. It is responsible for 
        /// creating and disposing the user interface class of the dockable window.
        /// </summary>
        public class AddinImpl : ESRI.ArcGIS.Desktop.AddIns.DockableWindow
        {
            private PipXP m_windowUI;

            public AddinImpl()
            {
            }

            protected override IntPtr OnCreateChild()
            {
                m_windowUI = new PipXP(this.Hook);
                return m_windowUI.Handle;
            }

            protected override void Dispose(bool disposing)
            {
                if (m_windowUI != null)
                    m_windowUI.Dispose(disposing);

                base.Dispose(disposing);
            }

        }

        //This function calls a procedure that loads up a SQLite database that contains pipes.
        //This database should look just like the DEM to keep things simple.
        private void loadFromDatabaseToolStripMenuItem_Click(object sender, EventArgs e)
        {
            loadFromDatabase();
        }

        private void loadFromDatabase()
        {
            //First identify the input database (sqlite database) using a fileOpenDialog
            //We will allow for a person to modify a source database.
            OpenFileDialog theInputDatabaseFileDialog = new OpenFileDialog();
            theInputDatabaseFileDialog.InitialDirectory = "c:\\";
            theInputDatabaseFileDialog.Filter = "SQLite files (*.sqlite)|*.sqlite|db files (*.db)|*.db|All files (*.*)|*.*";
            theInputDatabaseFileDialog.FilterIndex = 1;
            theInputDatabaseFileDialog.RestoreDirectory = true;

            if (theInputDatabaseFileDialog.ShowDialog() == DialogResult.OK)
            {
                if(theInputDatabaseFileDialog.FileName != "")
                {
                    inputDatabase = theInputDatabaseFileDialog.FileName;
                    sqliteConnectionString = "Data Source='" + theInputDatabaseFileDialog.FileName + "';Version=3;";
                }
            }


        }

        private void saveAsDatabaseToolStripMenuItem_Click(object sender, EventArgs e)
        {
            saveAsDatabase();
        }

        private void saveAsDatabase()
        {
            //This proceddure needs to know where the person wants to save the database,
            //and will also need to reassign the sqliteConnectionString for the source database
            //First identify the input database (sqlite database) using a fileOpenDialog
            //We will allow for a person to modify a source database.

            //For now, we will avoid the problem of completing updates on primary files by simply updating the primary files
            //and saving the secondary files to the new location, then changing the connection string
            SaveFileDialog theSaveDatabaseFileDialog = new SaveFileDialog();
            theSaveDatabaseFileDialog.InitialDirectory = "c:\\";
            theSaveDatabaseFileDialog.Filter = "SQLite files (*.sqlite)|*.sqlite|db files (*.db)|*.db|All files (*.*)|*.*";
            theSaveDatabaseFileDialog.FilterIndex = 1;
            theSaveDatabaseFileDialog.RestoreDirectory = true;

            if (theSaveDatabaseFileDialog.ShowDialog() == DialogResult.OK && theSaveDatabaseFileDialog.FileName != "")
            {
                if(theSaveDatabaseFileDialog.FileName != "")
                {
                    updateDatabase();
                    try
                    {
                        //This is where we try to save the database and relocate the main source file
                        using (var inputStream = File.OpenRead(inputDatabase))
                        using (var outputStream = File.OpenWrite(theSaveDatabaseFileDialog.FileName))
                        {
                            inputStream.CopyTo(outputStream);
                        }
                    }
                    catch (Exception ex)
                    {
                        //This is where we tell people something went wrong
                        MessageBox.Show("Error saving database in location " + theSaveDatabaseFileDialog.FileName);
                        return;
                    }

                    inputDatabase = theSaveDatabaseFileDialog.FileName;
                    sqliteConnectionString = "Data Source='" + theSaveDatabaseFileDialog + "';Version=3;";
                }
            }
        }

        private void createCostEstimateDatabase()
        {
            File.Delete("C:\\SQLite\\Arc\\CostEstimates.sqlite");
            CostEstimateConnection = new SQLiteConnection("Data Source='C:\\SQLite\\Arc\\CostEstimates.sqlite';Version=3;");
            CostEstimateConnection.Open();

            //transfer PipXP table and REHABSegments to CostEstimates
            nqsqlite(SQLiteBasicStrings.attachDatabase("C:\\SQLite\\Arc\\Arc01.sqlite", "PipeXPResults"), CostEstimateConnection);
            nqsqlite("CREATE TABLE XPData AS SELECT * FROM PipeXPResults.AMStudio_PIPEXP;", CostEstimateConnection);
            nqsqlite("CREATE TABLE RehabSegments AS SELECT * FROM PipeXPResults.REHABSegments;", CostEstimateConnection);
            //Drop attached database
            nqsqlite("DETACH DATABASE 'PipeXPResults';", CostEstimateConnection);
        }

        private void updateDatabase()
        {
            //This is the main procedure that updates all of the changes to the database
        }

        private void designateSourceTablesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            designateSourceTables();

        }

        private void designateSourceTables()
        {
            OpenFileDialog theSourceDatabaseFileDialog = new OpenFileDialog();
            theSourceDatabaseFileDialog.InitialDirectory = "c:\\";
            theSourceDatabaseFileDialog.Filter = "SQLite files (*.sqlite)|*.sqlite|db files (*.db)|*.db|All files (*.*)|*.*";
            theSourceDatabaseFileDialog.FilterIndex = 1;
            theSourceDatabaseFileDialog.RestoreDirectory = true;

            if (theSourceDatabaseFileDialog.ShowDialog() == DialogResult.OK)
            {
                if (theSourceDatabaseFileDialog.FileName != "")
                {
                    sourceDatabase = theSourceDatabaseFileDialog.FileName;
                    sqliteSourceConnectionString = "Data Source='" + theSourceDatabaseFileDialog + "';Version=3;";
                }
            }
        }

        private void runPipXPToolStripMenuItem_Click(object sender, EventArgs e)
        {
            runPipXP();

        }

        private void runPipXP()
        {
            //start by making sure we have valid connections to sqlite databases
            if (sqliteSourceConnectionString == "" || sqliteConnectionString == "")
            {
                MessageBox.Show("Databases are invalid");
                return;
            }

            

            //Before we even get to this function, we would have had to figure out if we are using the base 
            //Rehab_10FtSegs table or an import from EMGAATS
            //check to see if we did that
            if (checkForValidPipeData() != 0)
            {
                MessageBox.Show("No valid pipe data selected (File->Assign pipe data)");
                return;
            }

            //start by creating a new PipXP output table
            //createNewPipXPOutputTable();
        }

        private void assignPipeDataToolStripMenuItem_Click(object sender, EventArgs e)
        {
            assignPipeData();
        }

        private void assignPipeData()
        {
            //In this function, we assign a source sqlite database for our pipeData.
            //This might be from the pulltables database, or it could be from
            //an export from EMGAATS, or it could be from a selection from ArcGIS

            //Wherever the pipe data comes from, we just copy the table from the
            //pipe data source database and put it in our working database.
            //This ensures that when we cross check against parallel/intersecting pipes, 
            //we can just use the pulltables pipes as the main 'Big data' and our little selection as
            //the working data

            //SO, first designate where that database is
            OpenFileDialog theSourceDatabaseFileDialog = new OpenFileDialog();
            theSourceDatabaseFileDialog.InitialDirectory = "c:\\";
            theSourceDatabaseFileDialog.Filter = "SQLite files (*.sqlite)|*.sqlite|db files (*.db)|*.db|All files (*.*)|*.*";
            theSourceDatabaseFileDialog.FilterIndex = 1;
            theSourceDatabaseFileDialog.RestoreDirectory = true;

            if (theSourceDatabaseFileDialog.ShowDialog() == DialogResult.OK)
            {
                if (theSourceDatabaseFileDialog.FileName != "")
                {
                    pipXPSourceDatabase = theSourceDatabaseFileDialog.FileName;
                    sqlitepipXPSourceDatabaseConnectionString = "Data Source='" + theSourceDatabaseFileDialog + "';Version=3;";
                }
            }

            //Now try to copy the pipXPSource table from the pipXPSourceDatabase to the working database
            nqsqlite(SQLiteBasicStrings.attachDatabase(pipXPSourceDatabase, pipXPSourceDatabaseAlias));

            //Now that they are attached, copy the source to the working
            //nqsqlite(SQLiteBasicStrings.transferSpatialTable(sourceTable, destinationTable));
        }

        private int checkForValidPipeData()
        {
            if (inputPipeConnectionString == "")
            {
                return 1;
            }

            if (inputPipeDatabase == "")
            {
                return 2;
            }

            return 0;

        }

        public void nqsqlite(string command, SQLiteConnection m_dbConnection)
        {
            SQLiteCommand cmd = new SQLiteCommand(command, m_dbConnection);
            cmd.ExecuteNonQuery();
        }

        public void nqsqlite(string command)
        {
            SQLiteCommand cmd = new SQLiteCommand(command, workingDbConnection);
            cmd.ExecuteNonQuery();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            //Make sure we let the user know that stuff is being workinged on
            ESRI.ArcGIS.Framework.IMouseCursor theCursor = new ESRI.ArcGIS.Framework.MouseCursor();
            theCursor.SetCursor(2);

            //this button is just going to load up the segments table, then perform basic pipXP queries on it.
            //This is just a test system right now
            loadFromDatabase();

            workingDbConnection = new SQLiteConnection(sqliteConnectionString);
            MessageBox.Show(sqliteConnectionString);
            workingDbConnection.Open();

            //get the spatial abilities
            nqsqlite(SQLiteBasicStrings.enableSpatial());
            //Attach PullTables_PipeXP
            nqsqlite(SQLiteBasicStrings.attachDatabase("C:\\SQLite\\Arc\\PullTables_PipeXP.sqlite", "PullTables"));


            //Now that we have loaded our database, which can be found in inputDatabase as the path and sqliteConnectionString as the connection string,
            //we get to perform our first queries on that data
            //Of course to start, it looks like the first thing we do is transfer that data to a new table, GOLEM_PIPEXP.
            //Lets change the name of that to AMStudio_PIPEXP
            //Prep pipexp table
            nqsqlite(AMStudio_PIPXP_Queries.prepPIPEXP());

            //Then we do our first insert
            nqsqlite(AMStudio_PIPXP_Queries.transferBase());

            //Proximity to hardAreas
            nqsqlite(AMStudio_PIPXP_Queries.ProximityToHardAreas());
            nqsqlite(AMStudio_PIPXP_Queries.ProximityToHydrants_pdx(25.0));
            //nqsqlite(AMStudio_PIPXP_Queries.ProximityToBuildings(10));
            nqsqlite(AMStudio_PIPXP_Queries.RandomStats());
            nqsqlite(AMStudio_PIPXP_Queries.ResultsUIC());
            nqsqlite(AMStudio_PIPXP_Queries.ResultsMS4());
            nqsqlite(AMStudio_PIPXP_Queries.ResultsEMT(50.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsFire(250.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsPolice(250.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsHospital(250.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsSchool(250.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsECSI());
            nqsqlite(AMStudio_PIPXP_Queries.ResultsResidential());
            nqsqlite(AMStudio_PIPXP_Queries.ResultsPZone(12.5));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsCZone(12.5));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsGas(10.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsFiber(10.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsLRT(25.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsRail(25.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsIntersections(30.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsStreetType(30.0));
            nqsqlite(AMStudio_PIPXP_Queries.ResultsxStreet());
            nqsqlite(AMStudio_PIPXP_Queries.ResultsSewer(12.0));
            nqsqlite(AMStudio_PIPXP_Queries.ProximityToPoverty());
            nqsqlite(AMStudio_PIPXP_Queries.ResultsWater(12));
            nqsqlite(AMStudio_PIPXP_Queries.CountLaterals());


            theCursor.SetCursor(0);
        }

        private void buttonRunCostEstimator_Click(object sender, EventArgs e)
        {
            double relocationCostPerInchDiameter = 7.9126; //dollars
            double relocationCostBase = 74.093;//dollars
            double utilityCrossingCost = 5000;//dollars
            double hazardousMaterialsCost = 50;//dollars
            double envMitigationCost = 150000; //dollars.  Should this really be 150,000?
            double envMitigationWidth = 25; //feet
            double asphaltRemovalCost = 8.12; //dollars
            double excessAsphaltWidth = 1; //feet
            double asphaltBaseCourseDepth = 0.6666667; //feet
            double asphaltTrenchPatchBaseCourseCost = 29.52; //dollars
            double eightInchPatchCost = 55.77;  //dollars
            double sixInchPatchCost = 44.27; //dollars
            double fourInchPatchCost = 28.62; //dollars
            double pipeZoneDepthAdditionalInches = 18; //inches
            double fillAbovePipeZoneCost = 27.3; //dollars
            double pipeZoneBackfillCost = 70.55; //dollars
            double sawcutPavementLength = 4; //inches?
            double sawcutPavementUnitCost = 4.21; //dollars
            double excavationVolumeFactor = 1.2; //unitless
            double truckHaulSpoilsUnitCost = 4.72; //dollars
            double shoringSquareFeetPerFoot = 2; //
            double ShoringCostPerSquareFoot = 2.57; //dollars
            double minShoringDepth = 18;//feet
            string material = "";
            double workingHoursPerDay = 8; //hours
            double excavationDuration = 140; //cubic yards per day
            double paveDuration = 250; //feet per day
            double utilityCrossingDuration = 0.5;// working days
            double smallBoreJackDiameter = 24; //inches
            double largeBoreJackDiameter = 60; //inches
            double fastBoreRate = 100; //feet/day
            double slowBoreRate = 50;//feet/day
            double boreJackCasingAndGroutingDays = 2; //days
            double CIPPRepairDays = 3;//days
            double shallowSpotDepthCutoff = 20; //feet
            double shallowSpotRepairTime = 4;//hours
            double deepSpotRepairTime = 8;//hours
            double streetTypeStreetTrafficControlMobilization = 1;//hours 
            double streetTypeArterialTrafficControlMobilization = 2; //hours
            double streetTypeMajorArterialTrafficControlMobilization = 3;//hours
            double shallowTrenchDepthCutoff = 1; 
            double smallMainlineBypassCutoff = 15; //inches
            double manholeBuildRate = 10; //feet per day
            double lateralTrenchWidth = 4; //feet
            double lateralShoringLength = 10; //feet
            double boreJackArea = 460; //square feet
            double boreJackDepth = 1;
            double fractionalFlow = 0.2; //things per thing
            double Kn = 1.486; //
            double manningsN = 0.013; //general assumption
            double assumedSlope = 0.005; //slope assumed for negative, null, or 0 slope pipes
            double streetTypeStreetTrafficControlCost = 500; //dollars
            double streetTypeArterialTrafficControlCost = 1000; // dollars 
            double streetTypeMajorArterialTrafficControlCost = 3000; //dollars
            double streetTypeFreewayTrafficCost = 0; //dollars
            double boringJackingCost = 566.95; //dollar bills
            double baseENR = 8090; //unitless
            double jackingENR = 9500;//unitless
            double difficultAreaFactor = 1;
            double currentENR = 9835; // unitless
            double generalConditionsFactor = 0.1; //fraction
            double wasteAllowanceFactor = 0.05;//fraction
            double contingencyFactor = 0.25; //fraction
            double ConstructionManagementInspectionTestingFactor = 0.15; //fraction
            double designFactor = 0.2;//fraction
            double PublicInvolvementInstrumentationAndControlsEasementEnvironmentalFactor = 0.03; //fraction
            double StartupCloseoutFactor = 0.1;//fraction
            string csvPath = "";
            //Make sure we let the user know that stuff is being workinged on
            ESRI.ArcGIS.Framework.IMouseCursor theCursor = new ESRI.ArcGIS.Framework.MouseCursor();
            theCursor.SetCursor(2);
            SQLiteFunction.RegisterFunction(typeof(power));
            //Since we are doint an EMGAATS cost estimator, for now,
            //we assume that the database we used for PipeXP will be in the same location.
            //But we still need to create the new Cost Estimator working database
            //CostEstimator does not need to be spatially enabled.

            //Transfer REHABSegments and PipeXP
            createCostEstimateDatabase();
            //Attach PullTables_CostEstimator
            nqsqlite(SQLiteBasicStrings.attachDatabase("C:\\SQLite\\Arc\\PullTables_CostEstimator.sqlite", "CostEstimator"), CostEstimateConnection);

            //Now that we have loaded our database, which can be found in inputDatabase as the path and sqliteConnectionString as the connection string,
            //we get to perform our first queries on that data
            //Prep Costestimator table
            nqsqlite(AMStudio_CostEstimator_Queries.prepCostEstimator(), CostEstimateConnection);

            //Then we do our first insert
            nqsqlite(AMStudio_CostEstimator_Queries.transferBase(), CostEstimateConnection);

            //Proximity to hardAreas
            nqsqlite(AMStudio_CostEstimator_Queries.SetOutsideDiameter(), CostEstimateConnection);

            nqsqlite(AMStudio_CostEstimator_Queries.setTrenchBaseWidth(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setExcavationVolume(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setWaterRelocation(relocationCostPerInchDiameter, relocationCostBase), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setCrossingRelocation( utilityCrossingCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setHazardousMaterials( hazardousMaterialsCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setEnvironmentalMitigation( envMitigationCost,  envMitigationWidth), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setAsphaltRemoval( asphaltRemovalCost,  excessAsphaltWidth), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setAsphaltBaseCourse( asphaltBaseCourseDepth,  excessAsphaltWidth,  asphaltTrenchPatchBaseCourseCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setTrenchPatch( excessAsphaltWidth,  eightInchPatchCost,  sixInchPatchCost,  fourInchPatchCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setFillAbovePipeZone( asphaltBaseCourseDepth,  pipeZoneDepthAdditionalInches,  fillAbovePipeZoneCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setPipeZoneBackfill( pipeZoneDepthAdditionalInches,  pipeZoneBackfillCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setAsphaltSawCutting( sawcutPavementLength,  sawcutPavementUnitCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setTrenchExcavation(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setTruckHaul( excavationVolumeFactor,  truckHaulSpoilsUnitCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setTrenchShoring( shoringSquareFeetPerFoot,  ShoringCostPerSquareFoot,  minShoringDepth), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setPipeMaterialBaseCostPerFoot( material), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setPipeDepthDifficultyFactor(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setPipeMaterial(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setManholeSize(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setManholeBaseCost(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setManholeCostPerFootBeyondMinimum(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setManholeRimFrameCost(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setManholeDepthFactor(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setManhole(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBaseOpenCutRepairTime( workingHoursPerDay,  excavationDuration,  paveDuration,  utilityCrossingDuration), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBasePipeBurstRepairTime( workingHoursPerDay), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBaseBoreJackRepairTime( smallBoreJackDiameter,  largeBoreJackDiameter,  fastBoreRate,  slowBoreRate,  workingHoursPerDay,  boreJackCasingAndGroutingDays), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBaseCIPPRepairTime( workingHoursPerDay,  CIPPRepairDays), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBaseSPRepairTime( shallowSpotDepthCutoff,  shallowSpotRepairTime,  deepSpotRepairTime), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setTrafficControlMobilization( streetTypeStreetTrafficControlMobilization,  streetTypeArterialTrafficControlMobilization,  streetTypeMajorArterialTrafficControlMobilization), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setMainlineBypassMobilization( shallowTrenchDepthCutoff,  smallMainlineBypassCutoff,  workingHoursPerDay), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setManholeReplacement( manholeBuildRate,  workingHoursPerDay), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setLateralBypass( lateralTrenchWidth,  lateralShoringLength,  excavationDuration,  paveDuration), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBoreJackPitExcavation( boreJackArea,  excavationDuration), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setocConstructionDuration(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBJMicroTConstructionDuration(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setcippConstructionDuration(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setspOnlyConstructionDuration(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.removeOpenCutOptions( boreJackDepth), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.removeBoreJackOptions( boreJackDepth), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setnonMobilizationConstructionDuration(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setMobilizationConstructionDuration(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBypassPumping( fractionalFlow,  Kn,  manningsN,  assumedSlope), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setTrafficControl( streetTypeStreetTrafficControlCost,  streetTypeArterialTrafficControlCost,  streetTypeMajorArterialTrafficControlCost,  streetTypeFreewayTrafficCost), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setBoringJacking( boringJackingCost,  baseENR,  jackingENR), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setDifficultArea( difficultAreaFactor), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setLaterals(), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.DirectConstructionCost( currentENR,  baseENR), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.standardPipeFactorCosts( generalConditionsFactor,  wasteAllowanceFactor), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.contingencyCost( contingencyFactor), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.setCapitalCost( ConstructionManagementInspectionTestingFactor,  designFactor,  PublicInvolvementInstrumentationAndControlsEasementEnvironmentalFactor,  StartupCloseoutFactor), CostEstimateConnection);
            nqsqlite(AMStudio_CostEstimator_Queries.saveResultsAsCSV( csvPath), CostEstimateConnection);
        }
    }
}
