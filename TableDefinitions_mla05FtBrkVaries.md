# Purpose of Document #
Detailed Scheme Description of mla05FtBrkVaries table

### Field Details ###
```
Field: mapInfoId                       Alias: MAPINFO_ID           Data Type: int
                                       Nulls: yes                  Unique: yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: MapInfo
       [Description]

Field: mLinkId                         Alias: mlinkid              Data Type: int
                                       Nulls: yes                  Unique: yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: MapInfo
       Relates to the MapInfo origins of the object.  For whole pipes, this number will be below or equal to
       40,000,000.  For segments, this number will be above 40,000,000.

Field: compKey                         Alias: compkey              Data Type: int
                                       Nulls: yes                  Unique: Yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo
       version, but have not been assigned a match in the Hansen version, this number will be 0.

Field: upStreamNode                    Alias: usnode               Data Type: nvarchar(6)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source:
       The name of the point at which the pipe or pipe segment terminates.  For whole pipes, the USNode will
       be of the type “ABC123”.  For segments with a USNode in common with its parent pipe, the USNode will
       be of the type “ABC123”. For all other segments, the USNode will be of the type “123ABC”.

Field: downStreamNode                  Alias: dsnode               Data Type: nvarchar(6)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source:
       The name of the point at which the pipe or pipe segment terminates.  For whole pipes, the DSNode will
       be of the type “ABC123”.  For segments with a DSNode in common with its parent pipe, the DSNode will
       be of the type “ABC123”. For all other segments, the DSNode will be of the type “123ABC”.

Field: length                          Alias: length               Data Type: numeric(38, 8)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: masterLinks
       The horizontal flow dimension, in feet.  For whole pipes, this describes the length of the whole pipe
       as known by MstLinks.  For pipe segments, this describes a 10 foot or less length of a theoretic
       segment of pipe.  Segments with less that 10 feet of length should always be at the extreme downstream
       end of the series

Field: diameter                        Alias: diamwidth            Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Hansen
       The diameter or width of the object, in inches.

Field: height                          Alias: height               Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Hansen
       The height of the object, in inches.  For cases where this is 0, the pipe is considered to be circular.

Field: SHAPE                           Alias: SHAPE                Data Type: geometry
                                       Nulls: no                   Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: ESRI
       ArcGIS geometry field. Controlled and edited by ArcGIS and is not editable outside of ArcGIS.

Field: material                        Alias: pipetype             Data Type: nvarchar(10)
                                       Nulls: Yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {ABS,ASBES,BRICK,BRKSTN,CCP,CHDPE,CIP,CIPP,CMP,CONBRK,CONSTN,
                                                CSP,CTG,DIP,ERTH,FBR,FRP,HDPE,MONO,NCP,NREENC,OTHER,PCV,PERF,
                                                PERFDR,PVC,RCBOX,RCP,RCSP,REIENC,ROCK,RRAP,SDR,SP,STEEL,
                                                STEELE,STEENC,STL,SWALE,TCP,UNK,UNSPEC,VARIES,VCP,VEG,VSP,WOOD}
                                       Source: Hansen
??? material ??? 0,1,5042,6348,6482,7338
       The material that the pipe is made of.  For pipes that are made of more than one material type, if the
       original material is not identified, it is assumed to be VSP if that is one of the possible material
       types.  Original materials are identified with a “1_XXX”, while patch materials are identified with a
       “2_XXX”. Other information can be found in MstLinks or Hansen documentation.
                   Attribute Desc: Material Code        Description
                                            ABS         ACRYLONITRILE BUTADIENE STYR.
                                            ASBES       ASBESTOS CEMENT
                                            BRKSTN      BRICK W/STONE INVERT
                                            BRICK       BRICK
                                            CONBRK      CONCRETE W/BRICK INVERT
                                            CONSTN      CONCRETE W/STONE INVERT
                                            CCP         CONCRETE CYLINDER
                                            CIP         CAST IRON
                                            CMP         CORRUGATED METAL
                                            MONO        CONCRETE - MONOLITHIC
                                            CIPP        CURED-IN-PLACE
                                            CSP         CONCRETE - UNKNOWN REINFORCING
                                            CTG         CONCRETE - TONGUE AND GROOVE
                                            DIP         DUCTILE IRON
                                            NREENC      ENCASED - NONREINFORCED
                                            REIENC      ENCASED - REINFORCED
                                            REIFBR      FIBERGLASS REINFORCED
                                            HDPE        HIGH DENSITY POLYETHYLENE
                                            NCP         CONCRETE - NONREINFORCED
                                            PERFDR      PERFORATED DRAIN PIPE
                                            PVC         POLYVINYLCHLORIDE
                                            RCBOX       REINFORCED CONCRETE BOX
                                            RCP         CONCRETE - REINFORCED
                                            REINPM      PLASTIC MORTAR REINFORCED
                                            UNSPEC      UNSPECIFIED - UPDATE AT INSPECTION
                                            STEEL       STEEL
                                            VARIES      VARIABLE MATERIAL
                                            VSP         VITRIFIED CLAY SEWER PIPE
                                            WOOD        WOOD
                                            RHDPE       REINFORCED HDPE PIPE
                                            FBR         FIBER REINFORCED RESIN PIPE
                                            STEENC      ENCASED - STEEL
                                            GCP         GASKETED CLAY PIPE
                                            SLIP        SLIP LINED - SEE COMMENTS
                                            VCP         VITRIFIED CLAY PIPE (NEW)
                                            CHDPE       CORRUGATED HDPE PIPE

Field: installDate                     Alias: instDate             Data Type: datetime
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Hansen
       The date that the pipe was installed.  For some pipes, this may be null, in which case the install date
       is unknown.  Although this is technically an input field, it has been shown that install dates in
       HANSEN are not compatible with install dates in MstLinks.  The temporary solution for this conflict is
       to populate the field with the install dates from HANSEN for those pipes that can be matched in the
       HANSEN database, while retaining the MstLinks install date for pipes that cannot be matched up with an
       equivalent in the HANSEN database.

Field: specLink                        Alias: IsSpecLink           Data Type: bit
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [Description]

Field: serviceStatus                   Alias: servstat             Data Type: nvarchar(255)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {ABAN,CNS,DEL,IN,NEW,PEND,REPR,TBAB,TBRH}
                                       Source: Hansen
       The service status of the pipe as identified in Hansen.  See Hansen documentation for more info.
                     Attribute Desc: Service Status    Description
                                              ABAN     ABANDONED
                                              CNS      CONSTRUCTED BUT NOT IN SERVICE
                                              DEL      TO BE DELETED BY DBA
                                              IN       ASSET IS IN SERVICE
                                              NEW      NEW CONSTRUCTION-NOT YET ASBUILT
                                              PEND     PENDING REHABILITATION
                                              REPR     OUT OF SERVICE FOR REPAIR
                                              TBAB     TO BE ABANDONED
                                              TBRH     TO BE REHABILITATED

Field: oldMlId                         Alias: old_mlid             Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: MapInfo
       (SEGMENT ORIENTED FIELD) This number is applied to segments.  Considering that segments are given a new
       MLinkID greater than or equal to 40,000,000 and that some pipes have a COMPKEY of 0 or share compkeys,
       this number is used to relate segments to their parent pipe.

Field: splitId                         Alias: SplitID              Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [Description]
Field: splitType                       Alias: SplitTyp             Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [Description]

Field: cutNo                           Alias: cutno                Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) The order in which a segment falls.  The most upstream segment of a pipe will
       have a cutno of 1, the most downstream segment will have the highest cutno.  The parent pipe will have
       a cutno of 0

Field: fm                              Alias: fm                   Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most upstream point of
       segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.

Field: to                              Alias: to                   Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most downstream point of
       the segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.

Field: segmentLength                   Alias: seglen               Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: MapInfo
       (SEGMENT ORIENTED FIELD) For segments, this designates the length of the pipe segment as a MapInfo
       Object. This field is of no use to the Rehab processing.  For whole pipes, this should always be 0.

Field: materialFmTo                    Alias: mat_fmto             Data Type: nvarchar(21)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For repaired pipes, this indicates the assumed original material of the pipe.

Field: segmentCount                    Alias: seg_count            Data Type: smallint
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       The integer count of segments that comprise the pipe in question.  Pipe segments will always share the
       seg_count of their parents.  Parent pipes that have a seg_count of 0 are those that have not undergone
       the segmentation process, and therefore do not have any segments.

Field: failNear                        Alias: fail_near            Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       The integer count of segments comprising the parent pipe that have def_tot values greater than or equal
       to 1000.

Field: failPrevious                    Alias: fail_prev            Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       The integer count of segments that have been replaced previously in the parent pipe.  This number is
       identified by the count of segments that have a Material field that begins with “2_”.

Field: failure                         Alias: fail_tot             Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       This is the total number of failed or previously failed segments of the parent pipe.  Segments are
       only counted once for this tally, so if a segment has been replaced in the past AND is currently
       failing, that segment will only count as 1 for this tally.

Field: failurePercent                  Alias: fail_pct             Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       The percent, on a scale of 0 to 100, of failed segments to total number of segments of the parent pipe.

Field: pointDefect                     Alias: def_pts              Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]
Field: linearDefect                    Alias: def_lin              Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]

Field: defect                          Alias: def_tot              Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]

Field: baseWorth                       Alias: bpw                  Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       bpw acronym for Base Present Worth.  The base present worth for a segment is NULL.  The base present
       worth for a whole pipe is calculated as the sum of the base present worth of its child segments
       (bpw_seg).

Field: altWorth                        Alias: apw                  Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       apw acronym for Alternate Present Worth.  The alternate present worth for a segment is NULL.  The
       alternate present worth for a whole pipe is calculated as the sum of the alternate present worth of
       its child segments (apw_seg).

Field: costBenfit                      Alias: cbr                  Data Type: numeric(38, 8)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       cbr acronym for Cost Benefit Ratio.  Not to be confused with the actual financial concept of cost
       benefit ratio. The CBR for a segment is NULL.  The CBR for a whole pipe is calculated from its child
       segments as such: CBR = SUM(bpw_seg – apw_seg)/ SUM(replacement_cost).

Field: remainLife                      Alias: rulife               Data Type: smallint
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       This is the integer number of years that the pipe has remaining (measuring from 2010) until failure.

Field: remainLifeFlag                  Alias: rul_flag             Data Type: smallint
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       This indicates the source of the rulife value.  This value could have come from an engineering estimate
       or from the RUL tables.

Field: pointDefectScore                Alias: Point_Defect_Score   Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For segments, this indicates the scored value of point defects that are attributed to the segment.  For
       Whole pipes, this indicates the sum of all of the point defects of that whole pipe’s child segments.

Field: linearDefectScore               Alias: Linear_Defect_Score  Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For segments, this indicates the scored value of linear defects that are attributed to the segment.
       For whole pipes, this indicates the sum of all of the linear defects of that whole pipe’s child
       segments.

Field: defectScore                     Alias: Total_Defect_Score   Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       Sum of the point defects and linear defects.

Field: defectScoreX15                  Alias: Total_Defect_ScoreX15 Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       Sum of the point defects and linear defects.

Field: inspectionDate                  Alias: Last_TV_Inspection   Data Type: datetime
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Hansen
       the most recent date that inspection on this pipe was initiated.  As there is currently no associative
       algorithm to link when an inspection was prematurely terminated to its resumptive inspection, a very
       small number of these inspections will be partial.

Field: inspectionYrsAgo                Alias: Years_Since_Inspection Data Type: smallint
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived from Hansen
       The number of years between the inspection date, and the year 2010.  2010 is referred to often as the
       current year, even though we have since passed 2010.

Field: inspectionCurrent               Alias: insp_curr            Data Type: smallint
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {1, 2, 3, 4}        Source: Derived from Hansen
       Indicates the quality of the most recent inspection, if there happens to be one.  The codes for
       insp_curr are:
            1: (Inspection date is not null and install date is null) OR (inspection date after install date)
            2: install date is null AND (servstat is TBAB, or ABAN)
            3: install date is after the last inspection or servstat is PEND
            4: inspection date is null

Field: failureYr                       Alias: failure_year         Data Type: smallint
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For a whole pipe, this is the projected failure year.  For a segment, this should be NULL.

Field: stdDev                          Alias: std_dev              Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For a whole pipe, this indicates the standard deviation of possible failure years about the given
       failure year.  For a segment, this value should be NULL.

Field: pipeConsequenceFailure          Alias: Consequence_Failure  Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       The consequence of failure.  This is the dollar value of financial repercussions that the city may
       endure if the whole pipe experiences a failure.  For segments this value should be NULL.

Field: pipeReplaceCost                 Alias: replacecost          Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       The cost to replace a whole pipe.  This is the dollar value that the city would have to spend to
       replace the whole pipe in question.

Field: segmentBaseWorth                Alias: bpw_seg              Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For whole pipes, this value is NULL.  For segments, this is the base present worth of the segment in
       question.

Field: segmentAltWorth                 Alias: apw_seg              Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For whole pipes, this value is NULL.  For segments, this is the alternate present worth of the segment
       in question.

Field: segmentCostBenfit               Alias: cbr_seg              Data Type: numeric(38, 8)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For whole pipes, this value is NULL.  For segments, this is the cost benefit ratio of replacing the
       segment in question.

Field: segmentStdDev                   Alias: std_dev_seg          Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For a segment, this indicates the standard deviation of possible failure years about the given failure
       year.  For a whole pipe, this value should be NULL.

Field: segmentFailureYr                Alias: fail_yr_seg          Data Type: smallint
                                       Nulls: yes                  Unique:
                                       Index:                      Default Value:  none
                                       Domain: {}                  Source: Derived
       This is the estimated failure year of the segment in question.  This value ignores any engineers
       estimate.

Field: rating                          Alias: RATING               Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]

Field: action                          Alias: action               Data Type: smallint
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
                                       Source: Derived
       The action flag indicates what the recommended action should be taken with the pipe and all of its
       segments. The codes for action are:
       Action: Description
            0: Inspection is not current.
            1: Hansen Grade is less than or equal to 3 (no immediate action predicted to be necessary).
            2: Hansen Grade is 4 or 5 AND more than 10% failed segments AND greater than 1 near failed
               segments due to scoring (Whole pipe replacement).
            3: Hansen Grade is 4 or 5 AND <less than 10% failed segments OR only one failed segment> (patch
               failing segments).
            4: Hansen Grade is 4 or 5 AND no failed segments (engineers discretion).
            5: Info does not exist in MapInfo (This score is soon to be deprecated).
            6: Action 3 pipe that has 4 or more failed laterals.
            7: Action 4 pipe that has 4 or more failed laterals.
            8: Pipes that exist in between two action 2, 6, or 7 pipes.
            9:
           10:
           11:
           12:

           There is not an appropriate action flag for RUL_flag = 3 that may have an insp_current flag =
           3(IG) RUL_flag 3 states 'no tv inspection', insp_curr flag 3 states install date after last
           inspection or service status pend.  Both of these situations indicate an action flag of 0
           (inspection not current).
```