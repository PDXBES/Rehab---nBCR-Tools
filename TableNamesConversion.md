## Purpose of Document ##
Table Name Conversions from SQL Code to Pseudo Code
Code repository uses different table names other that those used in the Pseudo Code.  This is the conversion table.

## Rehab Table Details ##
```
REHAB10ftsegs is rehab10FtSegments table            needs to be renamed to 10ftSegments
Rehab10Ftsegs_Source is source10FtSegments table

REHAB_RedundancyTable is segmentRedundancy table
REHAB_RedundancyTableWhole is pipeRedundancy table
REHAB_Conversion1 is sanitaryInspection table
REHAB_Conversion2 is stormInspection table
REHAB_Conversion3 is newestSanitaryInspectionDate table
REHAB_Conversion4 is newestStormInspectionDate table
REHAB_Conversion5 is newestSanitaryInspection table
REHAB_Conversion6 is newestStormInspection table
REHAB_Conversion is newestInspection table
REHAB_point_defect_group is pointDefect table
REHAB_linear_defect_groupbysegment is linearSegmentDefect table
REHAB_Material_Changes is materialChanges table
REHAB_MLA_05FtBrk_VariesTable
REHAB_AA_Records_With_VSP is masterVSP table        (vsp & all material type)    AA=AB+AC
REHAB_AB_Records_That_Patch_VSP is otherVSP table   (vsp & Other)
REHAB_AC_Remaining_Records is VSP table             (pure vsp)
REHAB_Attribute_changes_ac is updatedVSP table      (updated vsp records)
REHAB_NON_VSP_PRIMARIES is preVSP table             (preVSP)
REHAB_AD_Records_With_No_VSP is nonVSP table        (no vsp)
REHAB_SmallResultsTable is smallResults table
REHAB_Longest_Material_Per_Compkey is longestMaterialCompkey table
REHAB_RemainingYearsTable is remainingYears table
REHAB_ConstructionExport is constructionExport table
REHAB_MortalityExport is mortalityExport table
REHAB_tblPipeTypeRosetta is pipeTypeRosetta
REHAB_tblRemainingUsefulLifeLookup is remainingLife table
REHAB_PeakScore_Lookup is peakScore table
REHAB_SegFuture is segmentFuture table
REHAB_RemainingYearsTable.YearsToFailure
```
## Data Source Details ##
These are documented by existing system and have minimal documentation here
```
[HANSEN8].[ASSETMANAGEMENT_STORM].COMPSTMN AS A
[HANSEN8].[ASSETMANAGEMENT_SEWER].COMPSMN AS C1
[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVICEINSP] AS C2
[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNSERVINSPOB] AS C3
[HANSEN8].[ASSETMANAGEMENT_SEWER].[SMNINDHIST] AS C4
```
## Rehab Table Field Details ##
```
REHAB_RedundancyTable.Point_Defect_Score is pointDefect table pointDefectScore field
REHAB_RedundancyTable.Last_TV_Inspection is segmentRedundancy table lastInspectionDate field
REHAB_RedundancyTable.INSP_CURR is segmentRedundancy table inspectionCurrent field
REHAB_RedundancyTable.inspdate is segmentRedundancy table inspectionDate field
REHAB_RedundancyTable.Consequence_Failure is segmentRedundancy table consequenceFailure
REHAB_RedundancyTable.Material is segmentRedundancy table material
REHAB_RedundancyTable.Total_Defect_Score is segmentRedundancy table defectScore
REHAB_RedundancyTable.Years_Since_Inspection is segmentRedundancy table inspectionYrsAgo
REHAB_tblPipeTypeRosetta.Hansen Material is pipeType table material
REHAB_tblPipeTypeRosetta.Useful Life Curve is pipeType table lifeCurve
REHAB_MortalityExport.Consequence is mortalityExport table consequence
REHAB_tblRemainingUsefulLifeLookup.Score_Lower_Bound is remainingLife table lowerBound
REHAB_tblRemainingUsefulLifeLookup.Score_Upper_Bound is remainingLife table upperBound
REHAB_tblRemainingUsefulLifeLookup.Material is remainingLife table material
```

## Rehab Table Conversion Field Detail ##
```
Existing Field Name                Data Type           Index         Nulls      Changed Field Name
[DWN Address]                      nvarchar(255)                 Nulls Allowed
[DWN Type]                         nvarchar(255)                 Nulls Allowed
[Main Type]                        nvarchar(255)                 Nulls Allowed
[UPS Address]                      nvarchar(255)                 Nulls Allowed
[UPS Type]                         nvarchar(255)                 Nulls Allowed
A                                  float                         Nulls Allowed
ACCUM_RISK_INSPECT_YEAR            smallint                      Nulls Allowed  accumRiskInspectionYr
ACCUM_RISK_REPLACE_YEAR            smallint                      Nulls Allowed  accumRiskYr
ACTION                             int                           Nulls Allowed  action
action                             smallint                      Nulls Allowed  action
ADDBY                              nvarchar(30)                  Nulls Allowed  addBy
ADDDTTM                            datetime                      Nulls Allowed  addDate
ADDRKEY                            int                           Nulls Allowed  addressKey
Age                                float                         Nulls Allowed
AGE_years_                         int                           Nulls Allowed
APW                                bigint                        Nulls Allowed  altWorth
APW                                int                           Nulls Allowed  altWorth
APW_Seg                            bigint                        Nulls Allowed  segmentAltWorth
APW_Seg                            int                           Nulls Allowed  segmentAltWorth
AREA                               nvarchar(255)                 Nulls Allowed
ASBLT                              nvarchar(10)                  Nulls Allowed
ASBLT_averageGrade                 float                         Nulls Allowed
AsBuilt                            nvarchar(14)                  Nulls Allowed
AuditDups                          nvarchar(30)                  Nulls Allowed
AuditNodeID                        nvarchar(20)                  Nulls Allowed
AuditOK2Go                         smallint                      Nulls Allowed
AuditProcTimestamp                 nvarchar(30)                  Nulls Allowed
AuditSpatial                       nvarchar(30)                  Nulls Allowed
B2010                              float                         Nulls Allowed  b2010
B2010_Seg                          float                         Nulls Allowed  segmentB2010
B2150                              float                         Nulls Allowed  b2150
B2150_Seg                          float                         Nulls Allowed  segmentB2150
BASIN                              nvarchar(10)                  Nulls Allowed
BASIN_averageGrade                 float                         Nulls Allowed
BPW                                int                           Nulls Allowed  baseWorth
bpw                                float                         Nulls Allowed  baseWorth
BPW_Seg                            int                           Nulls Allowed  segmentBaseWorth
bsnrun                             nvarchar(5)                   Nulls Allowed  basinRun
c_perc                             float                         Nulls Allowed
CADKey                             nvarchar(14)                  Nulls Allowed
Category                           nvarchar(255)                 Nulls Allowed
CBR                                float                         Nulls Allowed  costBenfit
cbr                                numeric(38, 8)                Nulls Allowed  costBenfit
CBR_Seg                            float                         Nulls Allowed  segmentCostBenfit
cbr_seg                            numeric(38, 8)                Nulls Allowed  segmentCostBenfit
CHDATE                             datetime                      Nulls Allowed  changeDate
CHDETAIL                           nvarchar(12)                  Nulls Allowed  changeDetail
CheckedForSpot                     bit                           Nulls Allowed
CHTYPE                             nvarchar(12)                  Nulls Allowed  changeType
cof                                int                           Nulls Allowed  consequenceFailure
Comment                            nvarchar(254)                 Nulls Allowed  comment
COMPCODE                           nvarchar(4)                   Nulls Allowed
COMPDTTM                           datetime                      Nulls Allowed  compDate
COMPKEY                            int                           Nulls Allowed  compKey
COMPKEY                            float                         Nulls Allowed  compKey
Compkey                            int                           No Nulls       compKey
Consequence of Failure             int                           Nulls Allowed  consequenceFailure
Consequence_Failure                int                           Nulls Allowed  consequenceFailure
convert_setdwn                     float                         Nulls Allowed
convert_setdwn_from                float                         Nulls Allowed
convert_setdwn_to                  float                         Nulls Allowed
CostPerFoot                        float                         Nulls Allowed
CountofRepairsSinceTVI             int                           Nulls Allowed
CutNO                              int                           Nulls Allowed  cutNo
DataFlagSynth                      int                           Nulls Allowed
DataQual                           nvarchar(15)                  Nulls Allowed
def_lat_count                      int                           Nulls Allowed
Def_LIN                            smallint                      Nulls Allowed  linearDefectScore
def_lin                            int                           Nulls Allowed  linearDefectScore
Def_PTS                            smallint                      Nulls Allowed  pointDefectScore
def_pts                            int                           Nulls Allowed  pointDefectScore
Def_TOT                            smallint                      Nulls Allowed  defectScore
def_tot                            int                           Nulls Allowed  defectScore
defpipelngth                       float                         Nulls Allowed
Description                        nvarchar(50)                  Nulls Allowed  description
Description                        nvarchar(255)                 Nulls Allowed  description
DiamWidth                          float                         Nulls Allowed  diameter
diamwidth                          numeric(8, 2)                 Nulls Allowed  diameter
DiamWidth                          numeric(38,8)                 Nulls Allowed  diameter
DirectConstructionCost             int                           Nulls Allowed
DisplayName                        nvarchar(255)                 No Nulls
DISTFROM                           float                         Nulls Allowed  distanceFrom
DISTTO                             float                         Nulls Allowed  distanceTo
DME_GlobalID                       int                           Nulls Allowed  globalId
DSIE                               numeric(38,8)                 Nulls Allowed
DsNode                             nvarchar(255)                 Nulls Allowed  downstreamNode
dsnode                             nvarchar(6)                   Nulls Allowed  downstreamNode
dwndpth                            numeric(38,8)                 Nulls Allowed
DWNTYPE                            nvarchar(6)                   Nulls Allowed
Exceptions                         nvarchar(1000)                Nulls Allowed  exceptions
Fail_NEAR                          smallint                      Nulls Allowed  failNear
fail_near                          int                           Nulls Allowed  failNear
Fail_PCT                           float                         Nulls Allowed  failurePercent
fail_pct                           numeric(8, 2)                 Nulls Allowed  failurePercent
Fail_PREV                          smallint                      Nulls Allowed  failPrevious
fail_prev                          int                           Nulls Allowed  failPrevious
Fail_TOT                           smallint                      Nulls Allowed  failure
fail_tot                           int                           Nulls Allowed  failure
fail_yr                            smallint                      Nulls Allowed  failureYr
Fail_YR_Seg                        smallint                      Nulls Allowed  segmentFailureYr
Fail_Yr_Seg                        int                           Nulls Allowed  segmentFailureYr
fail_yr_seg                        smallint                      Nulls Allowed  segmentFailureYr
fail_yr_seg                        float                         Nulls Allowed  segmentFailureYr
fail_yr_whole                      smallint                      Nulls Allowed  pipeFailureYr
Failure_Year                       int                           Nulls Allowed  failureYr
flowtype                           nvarchar(2)                   Nulls Allowed  flowType
FM                                 float                         Nulls Allowed  fm
fm                                 int                           Nulls Allowed  fm
fm                                 numeric(8, 2)                 Nulls Allowed  fm
FROMDIST                           float                         Nulls Allowed  fmDistance
FromX                              numeric(38,8)                 Nulls Allowed
FromY                              numeric(38,8)                 Nulls Allowed
GDETLKEY                           float                         Nulls Allowed
GDETLKEY                           float                         Nulls Allowed
GlobalID                           uniqueidentifier              No Nulls       globalId
Grade                              nvarchar(50)                  Nulls Allowed
Grade                              float                         Nulls Allowed
grade_h5                           smallint                      Nulls Allowed
GradeQualifier                     nvarchar(50)                  Nulls Allowed
Hansen Material                    nvarchar(255)                 Nulls Allowed
Height                             float                         Nulls Allowed  height
height                             numeric(8, 2)                 Nulls Allowed  height
Height                             numeric(38,8)                 Nulls Allowed  height
hservstat                          nvarchar(255)                 Nulls Allowed  serviceStatus
Hservstat                          nvarchar(4)                   Nulls Allowed  serviceStatus
ID                                 int                 Index     No Nulls
ID                                 int                           No Nulls
ID                                 float                         Nulls Allowed
InsFREQ                            int                           Nulls Allowed
Insp_Curr                          int                           Nulls Allowed  inspectionCurrent
insp_curr                          smallint                      Nulls Allowed  inspectionCurrent
insp_date                          datetime                      Nulls Allowed  lastInspectionDate
insp_yrsago                        smallint                      Nulls Allowed  inspectionYrsAgo
Inspection_Cost                    smallint                      Nulls Allowed  instpectionCost
Inspection_Year_BRE                smallint                      Nulls Allowed
INSPECTIONGrade                    float                         Nulls Allowed
INSPECTIONSpot                     int                           Nulls Allowed
INSPKEY                            int                           Nulls Allowed  inspectionKey
INSPNO                             int                           Nulls Allowed  inspectionNumber
Instdate                           datetime                      Nulls Allowed  installDate
IsSpecLink                         bit                           Nulls Allowed  specLink
j_perc                             float                         Nulls Allowed
Last_TV_Inspection                 datetime                      Nulls Allowed  lastInspectionDate
LatestRepairDate                   datetime                      Nulls Allowed  lastRepairDate
Length                             float                         Nulls Allowed  length
length                             numeric(38, 8)                Nulls Allowed  length
limited                            nvarchar(50)                  Nulls Allowed
Linear_Defect_Score                float                         Nulls Allowed  linearDefectScore
linktype                           nvarchar(2)                   Nulls Allowed  linkType
LOC                                nvarchar(255)                 Nulls Allowed  location
LOC_DESCRIPT                       nvarchar(255)                 Nulls Allowed  locationDescription
LOC_ERRORS                         nvarchar(50)                  Nulls Allowed  locationError
MAINKEY1                           int                           Nulls Allowed
MAINKEY2                           int                           Nulls Allowed
MAPINFO_ID                         int                 Index     No Nulls       mapInfoId
MAPINFO_ID                         int                           Nulls Allowed  mapInfoId
MAT_FmTo                           nvarchar(10)                  Nulls Allowed  materialFmTo
mat_fmto                           nvarchar(21)                  Nulls Allowed  materialFmTo
Material                           nvarchar(10)                  Nulls Allowed  material
Material                           nvarchar(255)                 Nulls Allowed  material
Material                           nvarchar(6)                   Nulls Allowed  material
MAX_LENGTHS                        float                         Nulls Allowed  maxLength
MaxDates                           datetime                      Nulls Allowed  maxDate
MLinkID                            int                           No Nulls       mLinkId
mlinkid                            int                           Nulls Allowed  mLinkId
MODBY                              nvarchar(30)                  Nulls Allowed  modifiedBy
MODDTTM                            datetime                      Nulls Allowed  modifiedDate
mortalityExport                    float                         Nulls Allowed  mortalityExport
Name                               nvarchar(255)                 No Nulls
NewScore                           float                         Nulls Allowed  newScore
OBDEGREE                           nvarchar(255)                 Nulls Allowed
OBDEGREE                           nvarchar(6)                   Nulls Allowed
OBJECTID                           float                         Nulls Allowed  objectId
OBJECTID                           int                           Nulls Allowed  objectId
OBJECTID                           int                           No Nulls       objectId
OBKEY                              int                           Nulls Allowed
OBSEVKEY                           int                           Nulls Allowed
OLD_MLID                           int                           Nulls Allowed  oldMlId
old_mlid                           int                           Nulls Allowed
Over36in                           bit                           Nulls Allowed
OWN                                nvarchar(4)                   Nulls Allowed  ownership
P                                  float                         Nulls Allowed
Peak_Score                         float                         Nulls Allowed  peakScore
PIPEDIAM                           float                         Nulls Allowed  diameter
PipeFlowType                       nvarchar(1)                   Nulls Allowed  pipeFlowType
PIPEHT                             float                         Nulls Allowed  pipeheight
PIPELEN                            float                         Nulls Allowed  pipeLength
pipeshape                          nvarchar(255)                 Nulls Allowed  pipeShape
PipeShape                          nvarchar(4)                   Nulls Allowed  pipeShape
PIPETYPE                           nvarchar(6)                   Nulls Allowed  pipeType
Point_Defect_Score                 float                         Nulls Allowed  pointDefectScore
pr_count                           int                           Nulls Allowed
pressure                           bit                           Nulls Allowed
Qdes                               numeric(38,8)                 Nulls Allowed
R2010                              float                         Nulls Allowed
R2010_Seg                          float                         Nulls Allowed
R2150                              float                         Nulls Allowed
R2150_Seg                          float                         Nulls Allowed
RATING                             float                         Nulls Allowed  rating
ReadingKey                         int                           Nulls Allowed  readingKey
ReadingKey                         int                           Nulls Allowed  readingKey
RECOMND                            nvarchar(254)                 Nulls Allowed  recommendation
remarks                            nvarchar(100)                 Nulls Allowed  remarks
REPAIR_LENGTH                      int                           Nulls Allowed
replacecost                        int                           Nulls Allowed  replaceCost
Replacement_Cost                   bigint                        Nulls Allowed  replaceCost
replacement_cost                   int                           Nulls Allowed  replaceCost
RootCount                          int                           Nulls Allowed
RootScore                          float                         Nulls Allowed
Roughness                          numeric(38,8)                 Nulls Allowed
RUL_Age                            int                           Nulls Allowed
RUL_AsbuiltAverage                 float                         Nulls Allowed
RUL_BasinAverage                   float                         Nulls Allowed
RUL_Final                          int                           Nulls Allowed
rul_flag                           smallint                      Nulls Allowed  remainLifeFlag
RUL_InspectionGradeNOAdjustment    int                           Nulls Allowed
RUL_InspectionGradeTimeAdjusted    int                           Nulls Allowed
RUL_source                         nvarchar(50)                  Nulls Allowed
RUL_Source_Flag                    smallint            Index     No Nulls
RUL_source_id                      smallint                      Nulls Allowed
RULife                             smallint                      Nulls Allowed  remainLife
rulife                             smallint                      Nulls Allowed  remainLife
RULife                             float                         Nulls Allowed  remainLife
s_perc                             float                         Nulls Allowed
SchedFLAG                          int                           Nulls Allowed
SchedYR                            int                           Nulls Allowed
Score_Lower_Bound                  float                         Nulls Allowed
Score_Upper_Bound                  float                         Nulls Allowed
seg_count                          smallint                      Nulls Allowed  segmentCount
SegLen                             float                         Nulls Allowed  segmentLength
seglen                             numeric(8, 2)                 Nulls Allowed  segmentLength
ServStat                           varchar(4)                    Nulls Allowed  serviceStatus
Shape                              nvarchar(255)                 Nulls Allowed  shape
SHAPE                              int                           Nulls Allowed  shape
SHAPE_LEN                          float                         Nulls Allowed  shape_len
SplitID                            int                           Nulls Allowed  splitId
SplitTyp                           int                           Nulls Allowed  splitType
Spot                               nvarchar(50)                  Nulls Allowed
SSMA_TimeStamp                     timestamp                     No Nulls
STARTDTTM                          datetime                      Nulls Allowed  startDate
std_dev                            int                           Nulls Allowed  stdDev
Std_Dev_Coeff_RUL                  float                         Nulls Allowed
std_dev_seg                        int                           Nulls Allowed  segmentStdDev
std_dev_seg                        float                         Nulls Allowed  segmentStdDev
std_dev_whole                      smallint                      Nulls Allowed  pipeStdDev
Std_Dev_Years_Insp                 float                         Nulls Allowed
str_avg_each                       float                         Nulls Allowed
str_avg_ft                         float                         Nulls Allowed
str_peak                           float                         Nulls Allowed
str_total                          float                         Nulls Allowed
struct_rate                        float                         Nulls Allowed
struct_score                       float                         Nulls Allowed
SumOfNewScore                      float                         Nulls Allowed
TimeFrame                          nvarchar(2)                   Nulls Allowed
TO                                 float                         Nulls Allowed  to
to -> [to]                         int                           Nulls Allowed  to
to -> [TO]                         float                         Nulls Allowed  to
to -> [TO]                         float                         Nulls Allowed  to
to -> [TO]                         float                         Nulls Allowed  to
to_                                numeric(8, 2)                 Nulls Allowed  to
TODIST                             float                         Nulls Allowed  toDistance
Tool image                                                       Nulls Allowed
total_defect_score                 float                         Nulls Allowed  defectScore
Total_Defect_Score_x15             float                         Nulls Allowed  defectScoreX15
TotalConstructionCost              int                           Nulls Allowed  constructionCost
ToX                                numeric(38,8)                 Nulls Allowed
ToY                                numeric(38,8)                 Nulls Allowed
TV_AGE_years                       int                           Nulls Allowed
TV_COMPLETE                        datetime                      Nulls Allowed
TV_START                           datetime                      Nulls Allowed
Type                               smallint                      No Nulls
UNITID                             nvarchar(16)                  Nulls Allowed  unitId
UNITID                             nvarchar(255)                 Nulls Allowed  unitId
UNITID2                            nvarchar(16)                  Nulls Allowed  unitId2
UNITID2                            nvarchar(255)                 Nulls Allowed  unitId2
UNITTYPE                           nvarchar(6)                   Nulls Allowed  unitType
upsdpth                            numeric(38,8)                 Nulls Allowed
UPSTYPE                            nvarchar(6)                   Nulls Allowed
Useful Life Curve                  nvarchar(255)                 Nulls Allowed
USIE                               numeric(38,8)                 Nulls Allowed
UsNode                             nvarchar(255)                 Nulls Allowed  upStreamNode
usnode                             nvarchar(6)                   Nulls Allowed  upStreamNode
ValidFromDate                      nvarchar(8)                   Nulls Allowed
ValidToDate                        nvarchar(8)                   Nulls Allowed
year                               int                           Nulls Allowed
Years_Since_Inspection             int                           Nulls Allowed  inspectionYrsAgo
Years_Since_Last_Inspect           float                         Nulls Allowed  inspectionYrsAgo
YearsToFailure                     int                           Nulls Allowed  yrToFailure
YearsToFailure                     float                         Nulls Allowed  yrToFailure
YRBUILT                            int                           Nulls Allowed
z                                  numeric(18,2)       Index     No Nulls
```