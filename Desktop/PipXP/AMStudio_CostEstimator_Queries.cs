using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PipXP
{
    class AMStudio_CostEstimator_Queries
    {
        public static string prepCostEstimator()
        {
            return "DROP TABLE IF EXISTS AMStudio_PipeDetails; " +
  "CREATE TABLE AMStudio_PipeDetails( " +
    "ID integer NULL, " +
    "Compkey integer NULL, " +
    "GlobalID integer NULL, " +
    "Type text NULL, " +
    "USNode text NULL, " +
    "DSNode text NULL, " +
    "Cost real NULL, " +
    "Factor real NULL, " +
    "Pipe real NULL, " +
    "Lateral real NULL, " +
    "SawcuttingAC real NULL, " +
    "AsphaltRemoval real NULL, " +
    "TruckHaul real NULL, " +
    "TrenchShoring real NULL, " +
    "AsphaltBaseCourse real NULL, " +
    "AsphaltTrenchPatch real NULL, " +
    "PipeZoneBackfill real NULL, " +
    "FillAbovePipeZone real NULL, " +
    "PipeMaterial real NULL, " +
    "PipeDepthDifficultyFactor real NULL, " +
    "PipeMaterialBaseCostPerFoot real NULL, " +
    "TrenchExcavation real NULL, " +
    "LinerTVCleaning real NULL, " +
    "Manhole real NULL, " +
    "ManholeSize real NULL, " +
    "ManholeBaseCost real NULL, " +
    "ManholeCostPerFootBeyondMinimum real NULL, " +
    "ManholeDepthFactor real NULL, " +
    "ManholeRimFrameCost real NULL, " +
    "BoringJacking real NULL, " +
    "Microtunneling real NULL, " +
    "TrafficControl real NULL, " +
    "ParallelWaterRelocation real NULL, " +
    "CrossingRelocation real NULL, " +
    "EnvironmentalMitigation real NULL, " +
    "HazardousMaterials real NULL, " +
    "BypassPumping real NULL, " +
    "BypassFlow real NULL, " +
    "ExcavationVolume real NULL, " +
    "TrenchBaseWidth real NULL, " +
    "length real NULL, " +
    "outsideDiameter real NULL, " +
    "diamWidth real NULL, " +
    "height real NULL, " +
    "cutno integer NULL, " +
    "DifficultArea real NULL, " +
    "DirectConstructionCost real NULL, " +
    "CapitalCost real NULL, " +
    "StandardPipeFactorCost real NULL, " +
    "ContingencyCost real NULL, " +
    "LinerTrafficControl real NULL, " +
    "LinerBypassPumping real NULL, " +
    "LinerLaterals real NULL, " +
    "LinerPipeMaterial real NULL, " +
    "LinerManhole real NULL, " +
    "LinerDirectConstructionCost real NULL, " +
    "LinerStandardPipeFactorCost real NULL, " +
    "LinerContingencyCost real NULL, " +
    "LinerCapitalCost real NULL, " +
    "OpenCutBuildDuration real NULL, " +
    "SegmentBuildDuration real NULL, " +
    "SpotLineBuildDuration real NULL, " +
    "ManholeBuildDuration real NULL, " +
    "fm real NULL, " +
    "[to] real NULL, " +
    "mobilizationTimeCost real NULL, " +
    "nonMobilizationTimeCost real NULL, " +
    "mobilizationTimeCostCapital real NULL, " +
    "nonMobilizationTimeCostCapital real NULL, " +
    "mobilizationLinerTimeCost real NULL, " +
    "nonMobilizationLinerTimeCost real NULL, " +
    "mobilizationLinerTimeCostCapital real NULL, " +
    "nonMobilizationLinerTimeCostCapital real NULL, " +
    "mobilizationConstructionDuration real NULL, " +
    "nonMobilizationConstructionDuration real NULL, " +
    "mobilizationLinerDuration real NULL, " +
    "nonMobilizationLinerDuration real NULL, " +
    "prejudiceSpot real NULL, " +
    "prejudiceLine real NULL, " +
    "prejudiceDig real NULL); " +
" CREATE UNIQUE INDEX IDX_PipeDetails_ID ON AMStudio_PipeDetails (ID); " +
" CREATE INDEX IDX_PipeDetails_COMPKEY ON AMStudio_PipeDetails (compkey); " +
    "CREATE INDEX IDX_PipeDetails_GLOBALID ON AMStudio_PipeDetails (GLOBALID); " +
    "DROP TABLE IF EXISTS AMStudio_ConstructionDurations; " +
  "CREATE TABLE AMStudio_ConstructionDurations( " +
    "ID integer NULL, " +
    "globalID integer NULL, " +
"compkey integer NULL, " +
"cutno integer NULL, " +
"[fm] real NULL, " +
"[to] real NULL, " +
"trafficControl real NULL, " +
"mainlineBypass real NULL, " +
"manholeReplacement real NULL, " +
"lateralBypass real NULL, " +
"pipeBurstPitExcavation real NULL, " +
"boreJackPitExcavation real NULL, " +
"baseOpenCutRepairTime real NULL, " +
"basePipeBurstRepairTime real NULL, " +
"baseBoreJackRepairTime real NULL, " +
"baseCIPPRepairTime real NULL, " +
"baseSPRepairTime real NULL, " +
"ocConstructionDuration real NULL, " +
"pbConstructionDuration real NULL, " +
"BJMicroTConstructionDuration real NULL, " +
"cippConstructionDuration real NULL, " +
"spOnlyConstructionDuration real NULL);" +
" CREATE UNIQUE INDEX IDX_ConstructionDurations_ID ON AMStudio_ConstructionDurations (ID); " +
" CREATE INDEX IDX_ConstructionDurations_COMPKEY ON AMStudio_ConstructionDurations (compkey); " +
    "CREATE INDEX IDX_ConstructionDurations_GLOBALID ON AMStudio_ConstructionDurations (GLOBALID); ";
        }

        //This is were we transfer the base data to the working table
        public static string transferBase()
        {
            return "INSERT INTO AMStudio_PipeDetails (ID, GLOBALID, USnode, DSNode, [length], diamWidth, height, cutno, compkey) " +
                "SELECT OBJECTID, GLOBALID, us_node_id, ds_node_id, [length], pipesize, pipeheight, cutno, hansen_compkey FROM REHABSegments; " +
                "INSERT INTO AMStudio_ConstructionDurations(ID, globalID, compkey, cutno, [fm], [to]) " +
                "SELECT OBJECTID, globalID, hansen_compkey, cutno, [fm], [to_] FROM RehabSegments; ";
        }

        public static string SetOutsideDiameter()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    OutsideDiameter = ( "+
                     "SELECT MIN(outsideDiameterInches) " +
                     "FROM   InsideOutsideDiameterRosetta " +
                     "WHERE insideDiameterInches >= AMStudio_PipeDetails.diamWidth); ";
        }

        public static string setTrenchBaseWidth()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [TrenchBaseWidth] = ( " +
                     "SELECT MIN(widthFeet) " +
                     "FROM   TrenchWidthByPipeDiameter " +
                     "WHERE  outsideDiameterInches >= AMStudio_PipeDetails.OutsideDiameter); ";
        }

        // ExcavationVolume (yd^3/ft)= Average pipe depth (ft) * Trench Base width (ft) * (1yd^3/27ft^3)
        public static string setExcavationVolume()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [ExcavationVolume] = ( " +
                     "SELECT ((uDepth + dDepth)/2.0)*[TrenchBaseWidth]/27.0 " + //27 cubic feet per cubic yard
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setWaterRelocation(double relocationCostPerInchDiameter, double relocationCostBase)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [ParallelWaterRelocation] = ( " +
                     "SELECT pWtrMaxD *" + relocationCostPerInchDiameter.ToString() + "+ "+relocationCostBase.ToString()+" " + 
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID AND pWtr > 0); ";
        }

        public static string setCrossingRelocation(double utilityCrossingCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [CrossingRelocation] = ( " +
                     "SELECT (IFNULL(xSewer,0)+IFNULL(xWtr,0)+IFNULL(xGas,)+IFNULL(xFiber,0)) *" + utilityCrossingCost.ToString() + " " + 
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setHazardousMaterials(double hazardousMaterialsCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [HazardousMaterials] = ( " +
                     "SELECT (CASE WHEN [length] > 50 THEN 50 ELSE [length] END) * A.[ExcavationVolume] * " + hazardousMaterialsCost.ToString() + " " +
                     "FROM   XPData " +
                     "WHERE  xECSI > 0 AND XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setEnvironmentalMitigation(double envMitigationCost, double envMitigationWidth)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [EnvironmentalMitigation] = ( " +
                     "SELECT " + envMitigationCost.ToString() + "*((IFNULL(xFtEzonC,0) + IFNULL(xFtEzonP,0)) *" + envMitigationWidth.ToString() + ")/43560.0  " + //43560 squre feet per acre
                     "FROM   XPData " +
                     "WHERE  (IFNULL(xFtEzonC,0) + IFNULL(xFtEzonP,0)) > 0 AND XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setAsphaltRemoval(double asphaltRemovalCost, double excessAsphaltWidth)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [AsphaltRemoval] = ( " +
                     "SELECT " + asphaltRemovalCost.ToString() + "*((TrenchBaseWidth + " + excessAsphaltWidth.ToString() + ") / 9.0) * [length]  " + //9 square feet per square yard
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setAsphaltBaseCourse(double asphaltBaseCourseDepth, double excessAsphaltWidth, double asphaltTrenchPatchBaseCourseCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [AsphaltBaseCourse] = ( " +
                     "SELECT ((TrenchBaseWidth + " + excessAsphaltWidth.ToString() + ")*" + asphaltBaseCourseDepth.ToString() + "/27.0) * " + asphaltTrenchPatchBaseCourseCost.ToString() + "* [length]  " + //27 cubic feet per cubic yard
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setTrenchPatch(double excessAsphaltWidth, double eightInchPatchCost, double sixInchPatchCost, double fourInchPatchCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [AsphaltTrenchPatch] = ( " +
                     "SELECT ((TrenchBaseWidth + " + excessAsphaltWidth.ToString() + ") /9.0) * "+//9 square feet per square yard
                     "(CASE WHEN IFNULL(HardArea,0)> 0 THEN " + eightInchPatchCost.ToString() + " "+
                     "WHEN pStrtText = 'A' THEN " + eightInchPatchCost.ToString() + " " +
                     "WHEN pStrtText = 'S' THEN " + sixInchPatchCost.ToString() + " " +
                     "WHEN pStrtText = 'H' THEN " + fourInchPatchCost.ToString() + " " +
                     ") * [length]  " + 
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setFillAbovePipeZone(double asphaltBaseCourseDepth, double pipeZoneDepthAdditionalInches, double fillAbovePipeZoneCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [FillAbovePipeZone] = ( " +
                     "SELECT  (ExcavationVolume - " +
                     "  TrenchBaseWidth*((" + asphaltBaseCourseDepth.ToString() + "+OutsideDiameter+" + pipeZoneDepthAdditionalInches.ToString() + ")/12.0)/27.0 "+//12 inches per foot, 27 cubic feet per cubic yard
                     "       )*[length]*" + fillAbovePipeZoneCost.ToString() + " " +
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setPipeZoneBackfill(double pipeZoneDepthAdditionalInches, double pipeZoneBackfillCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [PipeZoneBackfill] = ( " +
                     "SELECT  (TrenchBaseWidth * ((OutsideDiameter + " + pipeZoneDepthAdditionalInches.ToString() + ")/12.0) "+//12 inches per foot
                     "        /36 - (((OutsideDiameter*OutsideDiameter) * 12.0 * (3.14159/4.0))/46656.0) " +//12 inches per foot, 36 cubic feet per cubic yard, 46656 cubic inches per cubic yard
                     "        ) * [length] * " + pipeZoneBackfillCost.ToString() + " " +
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setAsphaltSawCutting(double sawcutPavementLength, double sawcutPavementUnitCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [SawcuttingAC] = ( " +
                     "SELECT  " + sawcutPavementLength.ToString() + " * " + sawcutPavementUnitCost.ToString() + " * [length]"+
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setTrenchExcavation()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [TrenchExcavation] = ( " +
                     "SELECT costPerCuYd " +
                     "FROM   DepthToTrenchExcavationCostRecord INNER JOIN XPData ON (uDepth+dDepth)/2.0 <= depthFt " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID ORDER BY depthFt ASC LIMIT 1); ";
        }

        public static string setTruckHaul(double excavationVolumeFactor, double truckHaulSpoilsUnitCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [TruckHaul] = ( " +
                     "SELECT (ExcavationVolume * " + excavationVolumeFactor.ToString() + ") * " + truckHaulSpoilsUnitCost.ToString() + " * [length] " +
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setTrenchShoring(double shoringSquareFeetPerFoot, double ShoringCostPerSquareFoot, double minShoringDepth)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [TrenchShoring] = IFNULL(( " +
                     "SELECT " + shoringSquareFeetPerFoot.ToString() + " * " + ShoringCostPerSquareFoot.ToString() + " * [length] * (uDepth+dDepth)/2.0 " +
                     "FROM   DepthToTrenchExcavationCostRecord INNER JOIN XPData ON (uDepth+dDepth)/2 >= depthFt " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID AND (uDepth+dDepth)/2.0 >= " + minShoringDepth.ToString() + "),0); ";
        }

        public static string setPipeMaterialBaseCostPerFoot(string material)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [PipeMaterialBaseCostPerFoot] = IFNULL(( " +
                     "SELECT Cost " +
                     "FROM   PipeMaterialCosts INNER JOIN XPData ON diamWidth >= minDiameter " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID AND PipeMaterialCosts like '"+material+"' ORDER BY minDiameter DESC LIMIT 1),0); ";
        }

        public static string setPipeDepthDifficultyFactor()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    [PipeDepthDifficultyFactor] = IFNULL(( " +
                     "SELECT DifficultyFactor " +
                     "FROM   DiameterDepthDifficultyFactor INNER JOIN XPData ON diamWidth >= smallestDiameter AND (uDepth+dDepth)/2.0 >= Depth " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID ORDER BY smallestDiameter DESC Depth DESC LIMIT 1),1); ";
        }

        public static string setPipeMaterial()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    PipeMaterial = IFNULL(( " +
                     "SELECT PipeMaterialBaseCostPerFoot * PipeDepthDifficultyFactor * [length] " +
                     "FROM   XPData " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID ),0); ";
        }

        public static string setManholeSize()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    ManholeSize = IFNULL(( " +
                     "SELECT manholeDiameterInches " +
                     "FROM   InsideDiameterToManholeDiameterTable " +
                     "WHERE  AMStudio_PipeDetails.DiamWidth <= insideDiameterInches ORDER BY insideDiameterInches ASC LIMIT 1),0); ";
        }

        public static string setManholeBaseCost()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    ManholeBaseCost = IFNULL(( " +
                     "SELECT BaseCost " +
                     "FROM   ManholeCostTable " +
                     "WHERE  AMStudio_PipeDetails.ManholeSize <= manholeDiameter ORDER BY manholeDiameter ASC LIMIT 1 ),0); ";
        }

        public static string setManholeCostPerFootBeyondMinimum()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    ManholeCostPerFootBeyondMinimum = IFNULL(( " +
                     "SELECT CostPerFootAbove8Ft " +
                     "FROM   ManholeCostTable " +
                     "WHERE  AMStudio_PipeDetails.ManholeSize <= manholeDiameter ORDER BY manholeDiameter ASC LIMIT 1),0); ";
        }

        public static string setManholeRimFrameCost()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    ManholeRimFrameCost = IFNULL(( " +
                     "SELECT RimFrameCost " +
                     "FROM   ManholeCostTable " +
                     "WHERE  AMStudio_PipeDetails.ManholeSize <= manholeDiameter ORDER BY manholeDiameter ASC LIMIT 1),0); ";
        }

        public static string setManholeDepthFactor()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    ManholeDepthFactor = IFNULL(( " +
                     "SELECT Factor " +
                     "FROM   ManholeCostDepthFactorTable INNER JOIN XPData ON (uDepth+dDepth)/2 >= manholeMinDepth " +
                     "WHERE  XPData.ID = AMStudio_PipeDetails.ID AND AMStudio_PipeDetails.ManholeSize >= manholeMinSize ORDER BY manholeMinSize DESC, manholeMinDepth DESC LIMIT 1),0); ";
        }

        public static string setManhole()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    Manhole = ( "+
                   "SELECT ManholeDepthFactor*(ManholeBaseCost * ManholeCostPerFootBeyondMinimum * CASE WHEN (uDepth +dDepth)/2.0 - 8.0 <= 0 THEN 0 ELSE (uDepth +dDepth)/2.0 - 8.0 END + ManholeRimFrameCost) " +
                   "FROM   XPData " +
                   "WHERE  XPData.ID = AMStudio_PipeDetails.ID); ";
        }

        public static string setBaseOpenCutRepairTime(double workingHoursPerDay, double excavationDuration, double paveDuration, double utilityCrossingDuration)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    baseOpenCutRepairTime = ( " +
                   "SELECT (((((uDepth + dDepth)/2)*TrenchBaseWidth/27.0)/" + excavationDuration.ToString() + ") + (XPData.[length]/" + paveDuration.ToString() + "))*" + workingHoursPerDay.ToString() + " " +//27 cubic feet per cubic yard
                   "FROM   XPData INNER JOIN AMStudio_PipeDetails ON XPData.ID = AMStudio_PipeDetails.ID " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID); " +

                   "UPDATE AMStudio_ConstructionDurations " +
                   "SET    baseOpenCutRepairTime = ( " +
                   "SELECT baseOpenCutRepairTime + ("+utilityCrossingDuration.ToString()+" * " + workingHoursPerDay.ToString() + " * (IFNULL(xWtr, 0) + IFNULL(xGas, 0) + IFNULL(xFiber, 0) + IFNULL(xSewer, 0))) " +
                   "FROM   XPData INNER JOIN AMStudio_PipeDetails ON XPData.ID = AMStudio_PipeDetails.ID " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID); ";
        }

        public static string setBasePipeBurstRepairTime(double workingHoursPerDay)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    basePipeBurstRepairTime = " + workingHoursPerDay.ToString()+ " WHERE cutno = 0; ";
        }

        public static string setBaseBoreJackRepairTime(double smallBoreJackDiameter, double largeBoreJackDiameter, double fastBoreRate, double slowBoreRate, double workingHoursPerDay, double boreJackCasingAndGroutingDays)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    baseBoreJackRepairTime =  ( " +
                   "SELECT CASE " +
                   "         WHEN  XPData.diamWidth < " + smallBoreJackDiameter.ToString() + " " +
                   "         THEN  XPData.[length]/" + fastBoreRate.ToString() + " + " + boreJackCasingAndGroutingDays.ToString() + " * " + workingHoursPerDay.ToString() + " " +  //1 day to install pipe in casing and 1 day for grouting
                   "         WHEN  XPData.diamWidth >= " + smallBoreJackDiameter.ToString() + " AND XPData.diamWidth <= " + largeBoreJackDiameter.ToString() + " " +
                   "         THEN  XPData.[length]/" + slowBoreRate.ToString() + " + " + boreJackCasingAndGroutingDays.ToString() + " * " + workingHoursPerDay.ToString() + " " +  //1 day to install pipe in casing and 1 day for grouting
                   "         WHEN  XPData.diamWidth > " + largeBoreJackDiameter.ToString() + " " +
                   "         THEN  XPData.[length]/" + slowBoreRate.ToString() + " " + //at this size, the casing will be the host pipe, so the 2 days is not applicable
                   "       END " +
                   "FROM   XPData INNER JOIN AMStudio_PipeDetails ON XPData.ID = AMStudio_PipeDetails.ID " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID) WHERE cutno = 0; ";
        }

        public static string setBaseCIPPRepairTime(double workingHoursPerDay, double CIPPRepairDays)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    baseCIPPRepairTime = " + workingHoursPerDay.ToString() + " * " + CIPPRepairDays.ToString() + "WHERE cutno = 0; ";
        }

        public static string setBaseSPRepairTime(double shallowSpotDepthCutoff, double shallowSpotRepairTime, double deepSpotRepairTime)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    baseSPRepairTime =  ( " +
                   "SELECT CASE " +
                   "         WHEN  (uDepth + dDepth)/2 < " + shallowSpotDepthCutoff.ToString() + " " +
                   "         THEN  " + shallowSpotRepairTime.ToString() + " " +
                   "         WHEN  (uDepth + dDepth)/2 >= " + shallowSpotDepthCutoff.ToString() + " " +
                   "         THEN  " + deepSpotRepairTime.ToString() + " " +
                   "       END " +
                   "FROM   XPData INNER JOIN AMStudio_PipeDetails ON XPData.ID = AMStudio_PipeDetails.ID " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID) WHERE cutno > 0; ";
        }

        public static string setTrafficControlMobilization(double streetTypeStreetTrafficControlMobilization, double streetTypeArterialTrafficControlMobilization, double streetTypeMajorArterialTrafficControlMobilization)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    trafficControl =  ( " +
                   "SELECT CASE " +
                   "         WHEN  pStrtText like 'S' " +
                   "         THEN " + streetTypeStreetTrafficControlMobilization.ToString() + " " +
                   "         WHEN  pStrtText like 'A' " +
                   "         THEN  " + streetTypeArterialTrafficControlMobilization.ToString() + " " +
                   "         WHEN  pStrtText like 'M' " +
                   "         THEN " + streetTypeMajorArterialTrafficControlMobilization.ToString() + " " +
                   "         ELSE  0 " +
                   "       END " +
                   "FROM   XPData INNER JOIN AMStudio_PipeDetails ON XPData.ID = AMStudio_PipeDetails.ID " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID); " +

                   "UPDATE AMStudio_ConstructionDurations " +
                   "SET    trafficControl =  ( " +
                   "SELECT MAX(ifnull(trafficControl,0)) " +
                   "FROM   AMStudio_ConstructionDurations AS A " +
                   "WHERE  A.compkey = AMStudio_ConstructionDurations.compkey GROUP BY A.compkey) WHERE cutno = 0; ";
        }

        public static string setMainlineBypassMobilization(double shallowTrenchDepthCutoff, double smallMainlineBypassCutoff, double workingHoursPerDay)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    mainlineBypass =  ( " +
                   "SELECT CASE " +
                   "         WHEN  (uDepth + dDepth)/2.0 < " + shallowTrenchDepthCutoff.ToString() + " AND diamwidth <= " + smallMainlineBypassCutoff.ToString() + " " +
                   "         THEN  " + workingHoursPerDay.ToString() + "/2.0 " +
                   "         ELSE  " + workingHoursPerDay.ToString() + " " +
                   "       END " +
                   "FROM   XPData INNER JOIN AMStudio_PipeDetails ON XPData.ID = AMStudio_PipeDetails.ID " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID); ";
        }

        public static string setManholeReplacement(double manholeBuildRate, double workingHoursPerDay)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    manholeReplacement =  ( " +
                   "SELECT (( "+
                   "         CASE "+
                   "           WHEN (uDepth + dDepth)/2.0 < 10.0 "+
                   "           THEN 10.0 "+
                   "           ELSE (uDepth + dDepth)/2.0 "+
                   "         END "+
                   "       )/" + manholeBuildRate.ToString() + ") * " + workingHoursPerDay.ToString() + " " +
                   "FROM   XPData INNER JOIN AMStudio_PipeDetails ON XPData.ID = AMStudio_PipeDetails.ID " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID AND XPData.Cutno = 0); "+

                   "UPDATE AMStudio_ConstructionDurations " +
                   "SET    manholeReplacement =  ( " +
                   "SELECT manholeReplacement " +
                   "FROM   AMStudio_ConstructionDurations AS A  " +
                   "WHERE  A.Compkey = AMStudio_ConstructionDurations.Compkey AND A.Cutno = 0) WHERE AMStudio_ConstructionDurations.Cutno = 1; ";
        }

        public static string setLateralBypass(double lateralTrenchWidth, double lateralShoringLength, double excavationDuration, double paveDuration)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    lateralBypass =  ( " +
                   "SELECT LateralCount * " +
                          "( " +
                          "  ( " +
                          "    (" + lateralTrenchWidth.ToString() + "*" + lateralShoringLength.ToString() + "*((uDepth + dDepth)/2.0))/(27.0*" + excavationDuration.ToString() + ") " +//27 cubic feet per cubic yard
                          "  ) " +
                          "  + "+
                          "  ( " +
                          "    " + lateralShoringLength.ToString() + "/" + paveDuration.ToString() + " " +
                          "  ) " +
                          ") " +
                   "FROM   XPData  " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID ); " ;
        }

        public static string setBoreJackPitExcavation(double boreJackArea, double excavationDuration)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    lateralBypass =  ( " +
                   "SELECT boreJackPitExcavation = LateralCount * " +
                          "( " +
                          "  (" + boreJackArea.ToString() + "*(uDepth+dDepth)/2.0)/(27.0*" + excavationDuration.ToString() + ") " +//27 cubic feet per cubic yard
                          ") " +
                   "FROM   XPData  " +
                   "WHERE  XPData.ID = AMStudio_ConstructionDurations.ID ); ";
        }

        public static string setocConstructionDuration()
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    ocConstructionDuration =  IFNULL(baseOpenCutRepairTime,0) + IFNULL(manholeReplacement,0) + IFNULL(trafficControl,0) + IFNULL(mainlineBypass,0) WHERE cutno = 0; ";
        }

        public static string setBJMicroTConstructionDuration()
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    BJMicroTConstructionDuration =  IFNULL(baseBoreJackRepairTime,0) + IFNULL(trafficControl,0) + IFNULL(mainlineBypass,0) + IFNULL(lateralBypass,0) + IFNULL(boreJackPitExcavation,0) WHERE cutno = 0; ";
        }

        public static string setcippConstructionDuration()
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    cippConstructionDuration =  IFNULL(baseCIPPRepairTime,0) + IFNULL(baseSPRepairTime,0) + IFNULL(trafficControl,0) + IFNULL(mainlineBypass,0) + IFNULL(lateralBypass,0) WHERE cutno = 0; ";
        }

        public static string setspOnlyConstructionDuration()
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                   "SET    spOnlyConstructionDuration =  IFNULL(baseSPRepairTime,0) + IFNULL(trafficControl,0) + IFNULL(mainlineBypass,0); ";
        }

        //remove open cut options from cases where bore/jack is required
        public static string removeOpenCutOptions(double boreJackDepth)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                       "SET    ocConstructionDuration =  IFNULL( " +
                       "(SELECT 0 " +
                       " FROM   XPData  " +
                       " WHERE  XPData.ID = AMStudio_ConstructionDurations.ID AND XPData.Cutno = 0 " +
                       "        AND " +
                       "        ( " +
                       "         (uDepth + dDepth)/2.0 > " + boreJackDepth.ToString() + " " +
                       "         OR " +
                       "         xBldg > 0 " +
                       "         OR " +
                       "         xLRT > 0 " +
                       "         OR " +
                       "         xRail > 0 " +
                       "         OR " +
                       "         countxFrwy > 0 " +
                       "        ) " +
                       "),ocConstructionDuration) ; " +

                       "UPDATE AMStudio_ConstructionDurations " +
                       "SET    baseOpenCutRepairTime = NULL WHERE ocConstructionDuration = 0; " +

                       "UPDATE AMStudio_ConstructionDurations " +
                       "SET    ocConstructionDuration = NULL WHERE ocConstructionDuration = 0; ";
        }

        //remove open cut options from cases where bore/jack is required
        public static string removeBoreJackOptions(double boreJackDepth)
        {
            return "UPDATE AMStudio_ConstructionDurations " +
                       "SET    baseBoreJackRepairTime =  IFNULL( " +
                       "(SELECT 0 " +
                       " FROM   XPData  " +
                       " WHERE  XPData.ID = AMStudio_ConstructionDurations.ID AND XPData.Cutno = 0 " +
                       "        AND " +
                       "        ( " +
                       "         (uDepth + dDepth)/2.0 <= " + boreJackDepth.ToString() + " " +
                       "         AND " +
                       "         xBldg = 0 " +
                       "         AND " +
                       "         xLRT = 0 " +
                       "         AND " +
                       "         xRail = 0 " +
                       "         AND " +
                       "         countxFrwy = 0 " +
                       "        ) " +
                       "),baseBoreJackRepairTime) ; " +

                       "UPDATE AMStudio_ConstructionDurations " +
                       "SET    boreJackPitExcavation = NULL WHERE baseBoreJackRepairTime = 0; " +

                       "UPDATE AMStudio_ConstructionDurations " +
                       "SET    BJMicroTConstructionDuration = NULL WHERE baseBoreJackRepairTime = 0; " +

                       "UPDATE AMStudio_ConstructionDurations " +
                       "SET    baseBoreJackRepairTime = NULL WHERE baseBoreJackRepairTime = 0; ";
        }

        public static string setnonMobilizationConstructionDuration()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    nonMobilizationConstructionDuration = IFNULL(( " +
                     "SELECT BaseOpenCutRepairTime + ManholeReplacement " +
                     "FROM   AMStudio_ConstructionDurations " +
                     "WHERE  AMStudio_PipeDetails.ID = AMStudio_ConstructionDurations.ID AND AMStudio_ConstructionDurations.cutno = 0),0); ";
        }

        public static string setMobilizationConstructionDuration()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    MobilizationConstructionDuration = IFNULL(( " +
                     "SELECT trafficControl + mainlineBypass " +
                     "FROM   AMStudio_ConstructionDurations " +
                     "WHERE  AMStudio_PipeDetails.ID = AMStudio_ConstructionDurations.ID AND AMStudio_ConstructionDurations.cutno = 0),0); ";
        }

        public static string setBypassPumping(double fractionalFlow, double Kn, double manningsN, double assumedSlope)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    BypassFlow = IFNULL(( " +
                     "SELECT CASE WHEN xPipSlope > 0 THEN " + fractionalFlow.ToString() + " * " + Kn.ToString() + "/" + manningsN.ToString() + " * power(IFNULL(diamWidth,0)/(4.0*12.0), 2.0/3.0) * power( xPipSlope, 0.5) " +
                     "                               ELSE " + fractionalFlow.ToString() + " * " + Kn.ToString() + "/" + manningsN.ToString() + " * power(IFNULL(diamWidth,0)/(4.0*12.0), 2.0/3.0) * power( " + assumedSlope.ToString() + ", 0.5) " +
                     "FROM   AMStudio_ConstructionDurations " +
                     "WHERE  AMStudio_PipeDetails.ID = AMStudio_ConstructionDurations.ID AND AMStudio_ConstructionDurations.cutno = 0),0); " +

                     "UPDATE AMStudio_PipeDetails " +
                     "SET    BypassPumping = IFNULL( SELECT BypassCost * (nonMobilizationConstructionDuration + mobilizationConstructionDuration) " +
                     "FROM   BypassPumpingUnitRates " +
                     "WHERE  AMStudio_PipeDetails.BypassFlow > BypassPumpingUnitRates.BypassFlowGPM ORDER BY BypassFlowGPM DESC LIMIT 1),0); ";
        }

        public static string setTrafficControl(double streetTypeStreetTrafficControlCost, double streetTypeArterialTrafficControlCost, double streetTypeMajorArterialTrafficControlCost, double streetTypeFreewayTrafficCost)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    trafficControl =  ( " +
                   "SELECT CASE " +
                   "         WHEN  pStrtText like 'F' " +
                   "         THEN " + streetTypeFreewayTrafficCost.ToString() + " " +
                   "         WHEN  pStrtText like 'A' " +
                   "         THEN " + streetTypeArterialTrafficControlCost.ToString() + " " +
                   "         WHEN  pStrtText like 'M' " +
                   "         THEN  " + streetTypeMajorArterialTrafficControlCost.ToString() + " " +
                   "         WHEN  pStrtText like 'S' " +
                   "         THEN " + streetTypeStreetTrafficControlCost.ToString() + " " +
                   "         ELSE  0 " +
                   "       END * ((CASE WHEN IFNULL(uxCLx,0) <2 THEN 0 ELSE uxCLX - 2 END)/2 + 1) " + //assumes at least 2 streets at every intersection and bases cost on every additional street.
                   "FROM   XPData  " +
                   "WHERE  XPData.ID = AMStudio_PipeDetails.ID); " +

                   "UPDATE AMStudio_ConstructionDurations " +
                   "SET    trafficControl =  IFNULL(trafficControl,0) * (nonMobilizationConstructionDuration + mobilizationConstructionDuration); ";
        }

        public static string setBoringJacking(double boringJackingCost, double baseENR, double jackingENR)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    boringJacking =  IFNULL(( " +
                   "SELECT " + boringJackingCost.ToString() + " * (" + baseENR.ToString() + " / " + jackingENR.ToString() + ")* power(2.71828, (0.0119*diamWidth)) * [length] " +
                   "FROM   XPData  " +
                   "WHERE  XPData.ID = AMStudio_PipeDetails.ID " +
                   "       AND " +
                   "       ( " +
                   "         (uDepth + dDepth)/2.0 > 25) " +
                   "         OR " +
                   "         xFrwy > 0 " +
                   "         OR " +
                   "         xBldg > 0 " +
                   "         OR " +
                   "         xLRT > 0 " +
                   "         OR " +
                   "         xRail > 0 " +
                   "       ) " +
                   "),0); ";
        }

        public static string setDifficultArea(double difficultAreaFactor)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    DifficultArea = IFNULL( " +
                   "       SELECT power( " + difficultAreaFactor.ToString() + ", " +
                   "                    CASE WHEN IFNULL(HardArea,0) > 0 THEN 1 ELSE 0 END + " +
                   "                    CASE WHEN IFNULL(pRail, 0) > 0 THEN 1 ELSE 0 END + " +
                   "                    CASE WHEN IFNULL(pLRT, 0) > 0 THEN 1 ELSE 0 END + " +
                   "                    CASE WHEN ABS(IFNULL(gSlope, 0)) >= 0.1 AND (pStrt = 0 OR pStrt IS NULL) THEN 1 ELSE 0 END " +
                   "               ) " +
                   "        FROM   XPData " +
                   "        WHERE  XPData.ID = AMStudio_PipeDetails.ID),0); ";
        }

        public static string setLaterals()
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    Lateral = IFNULL(( " +
                   "       SELECT LateralCount " +
                   "       FROM   XPData " +
                   "       WHERE  AMStudio_PipeDetails.ID = XPData.ID),0);";
        }

        public static string DirectConstructionCost(double currentENR, double BaseENR)
        {
            return "UPDATE AMStudio_PipeDetails " +
                   "SET    DirectConstructionCost = (IFNULL(DifficultArea, 1) * (" + currentENR.ToString() + "/" + BaseENR.ToString() + ")) " +
                                                   "*" +
                                                   "(" +
                                                     "IFNULL(TrafficControl,0) " +
                                                     "+ IFNULL(BypassPumping, 0) " +
                                                     "+ IFNULL(TrenchShoring, 0) " +
                                                     "+ IFNULL(TrenchExcavation, 0 ) " +
                                                     "+ IFNULL(TruckHaul, 0) " +
                                                     "+ IFNULL(PipeMaterial, 0) " +
                                                     "+ IFNULL(Manhole, 0) " +
                                                     "+ IFNULL(FillAbovePipeZone, 0) " +
                                                     "+ IFNULL(PipeZoneBackfill, 0) " +
                                                     "+ IFNULL(SawcuttingAC, 0) " +
                                                     "+ IFNULL(AsphaltRemoval, 0) " +
                                                     "+ IFNULL(AsphaltTrenchPatch, 0) " +
                                                     "+ IFNULL(AsphaltBaseCourse, 0) " +
                                                     "+ IFNULL(ParallelWaterRelocation, 0) " +
                                                     "+ IFNULL(CrossingRelocation, 0) " +
                                                     "+ IFNULL(HazardousMaterials, 0) " +
                                                     "+ ISNULL(EnvironmentalMitigation, 0) " +
                                                   ") ";
        }

        public static string standardPipeFactorCosts(double generalConditionsFactor, double wasteAllowanceFactor)
        {
            return "UPDATE AMStudio_PipeDetails SET StandardPipeFactorCost = DirectConstructionCost * ( 1.0 + " + generalConditionsFactor.ToString() + " + " + wasteAllowanceFactor.ToString() + ");";
        }

        public static string contingencyCost(double contingencyFactor)
        {
            return "UPDATE AMStudio_PipeDetails SET ContingencyCost = StandardPipeFactorCost * ( 1.0 + "+contingencyFactor.ToString() + ");";
        }

        public static string setCapitalCost(double ConstructionManagementInspectionTestingFactor, double designFactor, double PublicInvolvementInstrumentationAndControlsEasementEnvironmentalFactor, double StartupCloseoutFactor)
        {
            return "UPDATE AMStudio_PipeDetails SET CapitalCost = ContingencyCost * (1.0 + " + ConstructionManagementInspectionTestingFactor.ToString() +
                    " + " + designFactor.ToString() + " + " + PublicInvolvementInstrumentationAndControlsEasementEnvironmentalFactor.ToString() + " + " + StartupCloseoutFactor.ToString() + ");";
        }

        public static string saveResultsAsCSV(string csvPath)
        {
            return ".headers on; .mode csv;.output '" + csvPath + "'; SELECT * FROM AMStudio_PipeDetails; .output stdout;";
        }
    }
}
