# Purpose of Document #
Detailed Scheme Description of newestSanitaryInspection table
### Field Details ###
```
Field: compKey                         Alias: compkey              Data Type: int
                                       Nulls: no                   Unique: Yes
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo version,
       but have not been assigned a match in the Hansen version, this number will be 0.

Field: inspectionKey                   Alias: inspkey              Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: newScore                        Alias: newScore             Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: downFrom                        Alias: downfm               Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: downTo                          Alias: downto               Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: readKey                         Alias: readingKey           Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [description]


Field: startDate                       Alias: startDtTm            Data Type: datetime
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: compDate                        Alias: compDtTm             Data Type: datetime
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: installDate                     Alias: instDate             Data Type: datetime
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Hansen
       The date that the pipe was installed.  For some pipes, this may be null, in which case the install date
       is unknown.  Although this is technically an input field, it has been shown that install dates in
       HANSEN are not compatible with install dates in MstLinks.  The temporary solution for this conflict is
       to populate the field with the install dates from HANSEN for those pipes that can be matched in the
       HANSEN database, while retaining the MstLinks install date for pipes that cannot be matched up with an
       equivalent in the HANSEN database.

Field: obDegree                        Alias: obDegree             Data Type: nvarchar(6)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: obKey                           Alias: obKey                Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: rating                          Alias: rating               Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]

Field: ownership                       Alias: own                  Data Type: nvarchar(4)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {BES, CLAK, CWS, DNRV, MILW, MIX, PARK, PORT, PRIV, UNKN, NULL}
                                       Source: Hansen
       Corporation ownership of facility
                                        Ownership Jursdiction Description
                                             BES  ENVIRONMENTAL SERVICES (City of Portland)
                                             CLAK CLACKAMAS COUNTY
                                             CWS  CLEAN WATER SERVICES (WAS USA)
                                             DNRV RIVERVIEW SANITARY SEWER DIST
                                             MILW CITY OF MILWAUKIE
                                             MIX  MIXED OWNER - SEE DETAIL GRID
                                             PARK PARK BUREAU (City of Portland)
                                             PORT PORT OF PORTLAND
                                             PRIV PRIVATE
                                             UNKN UNDETERMINED AT THIS TIME

Field: unitType                        Alias: unittype             Data Type: nvarchar(6)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {A, ABML, AB-ML, C, CSCC, CS-CC, CSDET, CS-DET, CSINT, CS-INT,
                                                CSML, CS-ML, CSOC, CSOTN,CSPINT, CSPL,CS-PL, D, DET, EMBPG,
                                                EMBPP, EMERBP, F, FD, IC, ID, IS, IT, O, PC, PD, PS,S, SAINT,
                                                SA-INT, SAML,SA-ML, SAPINT, SAPL, SA-PL, SPCNX, STCV, ST-CV,
                                                STCX, ST-CX,STDET, ST-DET, STFC, ST-FC, STFD, ST-FD,STINF,
                                                ST-INF, STINT, ST-INT, STML, ST-ML, STPL,ST-PL, V, X, Z}
                     Source: Hansen
       DME & Hansen Unit Type for Linear Features
                     Code    Description                             Code    Description
                     A       Abandoned                               PS      Pressure Line-Sanitary
                     ABML    Abandoned Main                          S       Sanitary Sewer
                     AB-ML   Abandoned Mainline                      SAINT   Sanitary Interceptor
                     C       Combined Sanitary & Drainage            SA-INT  Sanitary Interceptor
                     CSCC    Combined Consolidation Conduit          SAML    Sanitary Gravity Main
                     CS-CC   Combined Consolidation Conduit          SA-ML   Sanitary Gravity Main
                     CSDET   Combined Detention Pipe                 SAPINT  Sanitary Pressure Interceptor
                     CS-DET  Combined Detention Pipe                 SAPL    Sanitary Pressure Line
                     CSINT   Combined Interceptor                    SA-PL   Sanitary Pressure Line
                     CS-INT  Combined Interceptor                    SPCNX   Special Connection
                     CSML    Combined Gravity Main                   STCV    Storm Culvert (Generic)
                     CS-ML   Combined Gravity Main                   ST-CV   Storm Culvert (Generic)
                     CSOC    CSO Conduit                             STCX    Storm Crossing Culvert
                     CSOTN   Combined Sewer Overflow Tunnel          ST-CX   Storm Crossing Culvert
                     CSPINT  Combined Pressure Interceptor           STDET   Storm Detention Pipe
                     CSPL    Combined Pressure Line                  ST-DET  Storm Detention Pipe
                     CS-PL   Combined Pressure Line                  STFC    Storm Frontage Culvert
                     D       Drainage                                ST-FC   Storm Frontage Culvert
                     DET     Detention Tank/Pipe                     STFD    Storm French Drain
                     EMBPG   Emergency Bypass - Gravity              ST-FD   Storm French Drain
                     EMBPP   Emergency Bypass - Pressure             STINF   Storm Infiltration Trench
                     EMERBP  Emergency Bypass Line                   ST-INF  Storm Infiltration Trench
                     F       Frontage Culvert                        STINT   Storm Interceptor
                     FD      French Drain                            ST-INT  Storm Interceptor
                     IC      Interceptor-Combined                    STML    Storm Gravity Main
                     ID      Interceptor-Drainage                    ST-ML   Storm Gravity Main
                     IS      Interceptor-Sanitary                    STPL    Storm Pressure Line
                     IT      Infiltration Trench                     ST-PL   Storm Pressure Line
                     O       Open Drainage Channel                   V       Culvert (Generic/Unknown)
                     PC      Pressure Line-Combined                  X       Crossing Culvert
                     PD      Pressure Line-Drainage                  Z       Deleted Line Segment

Field: serviceStatus                   Alias: servStat             Data Type: nvarchar(4)        
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {ABAN, IN, DEL, NEW, REPR, TBAB, TBRH, PEND, CNS}
                                       Source: Hansen
       DME & Hansen service status descriptions
                     CODE    DESCRIPTION
                     ABAN    ABANDONED
                     IN      ASSET IS IN SERVICE
                     DEL     TO BE DELETED BY DBA
                     NEW     NEW CONSTRUCTION-NOT YET ASBUILT
                     REPR    OUT OF SERVICE FOR REPAIR
                     TBAB    TO BE ABANDONED
                     TBRH    TO BE REHABILITATED
                     PEND    PENDING REHABILITATION
                     CNS     CONSTRUCTED BUT NOT IN SERVICE
```