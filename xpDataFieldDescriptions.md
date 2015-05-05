# Purpose of Document #
Detailed Scheme Description of constructionCostsDelete table

### Field Naming Convention ###

```
PREFIX  TYPE    VALUES    INDICATION
  x*     n/a    varies    Crossing, Intersecting or Within
  p*     n/a    varies    Parallel or adjacent
 ?u*     n/a    varies    Upstream Node Information
 ?d*     n/a    varies    Downstream Node Information
```

### Fields and Description Details ###

```
Index & Unique ID Fields
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    MlinkID         Integer         >0           n/a     (indexed) ; MST_LINKS_AC unique ID
    CompKey         Integer         >0           n/a     (indexed) ; Matching Component Key from Hansen

Proximity to Water Utilities & Facilities
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    xWtr            Integer         0 - n                No. of Water Line Crossings  /  0=FALSE
    xWMinD          Integer         0 - n        inches  Smallest Diameter of Crossing Water Lines (Diam Only)
    xWMaxD          Integer         0 - n        inches  Largest Diameter of Crossing Water Lines (Diam Only)
    pWtr            Integer         0, 1                 1-Parallel Water Line Existing at 10 FT or less / 0=FALSE
    pWtrMaxD        Integer         0 - n        inches  Maximum Diameter of Parallel Water Line  (Diam Only)
    pFt2Wtr         Integer         0 - n        Feet    Approx. Distance of a Parallel Water Line
                                                           (2 FT increments, 10 Ft Max)
Proximity to Crossing & Parallel Swrs: Mst_Links
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    xSewer          Integer         0, 1                 <n> Number of Crossing Pipes (Source: MLA)  /  0=FALSE (0-1)
    xSwrMinD        Integer         0 - n        inches  Smallest Diameter of Crossing Sewer    (changes ?)
    xSwrMaxD        Integer         0 - n        inches  Largest Diameter of Crossing Sewer Pipes    (changes ?)
    pSewer          Integer         0, 1                 Existing PARALLEL Sewer Pipe
    pSwrMaxD        Integer         0 - n        Feet    Largest Diameter of Parallel Sewer Pipes
    pFt2Swr         Integer         0 - n                Approx. Distance to Parallel Sewer Pipe if Existing (nearest)

Proximity to Transportation Facilities, Streets And Centerline
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    xStrt           Integer         0 - n                <n> represents the number of Street Crossings /  0=FALSE
                                                           (0-1 only)
    xArt            Integer         0 - n                <n> represents the number of Arterial Crossings /  0=FALSE
                                                           (0-1 only)
    xMJArt          Integer         0 - n                <n> represents the number of Major Arterial Crossings /  0=FALSE
                                                            (0-1 only)
    xFrwy           Integer         0,1                  <n> represents the number of Freeway crossing /  0=FALSE
                                                            (0-1 only)
    pStrt           Integer         0,1                  <1> Line is in FREEWAY street surface  /  0=FALSE
    pStrtTyp        Integer         0 - n                Type of Street if line is in street surface
                                                           (same as Transportation Codes)
    pFt2Strt        Integer         0 - n        Feet    Distance of Line to Street Centerline (5 FT increments; 25 max)
    pTraffic        Integer         0 - n                Average daily traffic volume (vehicle count per day)
    uxCLx           Integer         0 - n                <n> No. of streets IF UPSTREAM Node of Line is in Street
                                                            Intersection (15 FT radius)
    uxFt2CLx        Integer         0 - n        Feet    Dist. of  Upstream Node to Point of Street Intersection
    dxCLx           Integer         0 - n                <n> No. of streets IF DOWNSTREAM Node of Line is in Street
                                                            Intersection
    dxFt2CLx        Integer         0 - n        Feet    Dist. of  Downstream Node to Point of Street Intersection

Proximity to Railroads And Light Rail Transit
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    xRail           Integer         0,1                  No. of Railroad Crossings  /  0=FALSE (30 FT rr buffer)
    pRail           Integer         0,1                  Existing Parallel Railroad /  0=FALSE
    pFt2Rail        Integer         0 - n        Feet    Dist. To Parallel Railroad  0 - 10 Feet
    xLRT            Integer         0,1                  No. of Lignt Rail Crossings  /  0=FALSE (30 FT rr buffer)
    pLRT            Integer         0,1                  Existing Parallel  Lignt Rail  /  0=FALSE
    pFt2LRT         Integer         0 - n        Feet    Dist. To Parallel Railroad  0 - 10 Feet

Proximity to Other Utilities : Fiber Routes & Gas Lines
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    xFiber          Integer         0 - n                No. of Fiber Optic Lines Crossings  /  0=FALSE
    pFiber          Integer         0,1                  Existing Parallel Fiber Optic Line /  0=FALSE
    pFt2Fiber       Integer         0 - n        Feet    Dist. To Parallel Fiber Optic Line
    xGas            Integer         0,1                  No. of Major Gas Line Crossings  /  0=FALSE
    pGas            Integer         0,1                  Existing Parallel Major Gas Line /  0=FALSE
    pFt2Gas         Integer         0 - n        Feet    Dist. To Parallel Major Gas Line

Proximity to Environmental Zoning And Contamination
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    xEzonC          Integer         0,1                  Line is within Environmental Conservation Zoning  /  0=FALSE
    xEzLenC         Integer         0 - n        Feet    Length of Pipe within Environmental Conservation Zoning
    xEzonP          Integer         0,1                  Line is within Environmental Preservation Zoning  /  0=FALSE
    xEzLenP         Integer         0 - n        Feet    Length of Pipe within Environmental Preservation Zoning
                                                           (no. of segments * 5)
    xEzAreaC        Integer         0 - n        Sq Ft   Overlapping area of 12.5 FT pipe buffer and "C" Env. Zoning
    xEzAreaP        Integer         0 - n        Sq Ft   Overlapping area of 12.5 FT pipe buffer and "P" Env. Zoning
    xEcsi           Integer         0,1                  Line is within 50 FT of an Environmental Contaminated 
                                                            Site / 0=FALSE
    xFt2Ecsi        Integer         0 - n        Feet    Distance of Nearest ECSI Increments of 10 (max. 50 FT)
    xEcsiLen        Integer         0 - n        Feet    Length of Pipe within ECSI 50 FT buffer
    xEcsiVol        Integer         0 - n        cu yd   Volume: Avg. PipeDepth *(overlap of 12.5 FT
                                                           pipe buffer and 50 ft ECSI FT buffer)

Proximity to Public Safety
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    xSchl           Integer         0,1                  Line is within 250 Ft of a SCHOOL
    xFt2Schl        Integer         0 - n        Feet    Distance of Nearest School (50 FT increments)
    xHosp           Integer         0,1                  Line is within 250 Ft of a HOSPITAL
    xFt2Hosp        Integer         0 - n        Feet    Distance of Nearest HOSPITAL (50 FT increments)
    xPol            Integer         0,1                  Line is within 250 Ft of a POLICE STATION
    xFt2Pol         Integer         0 - n        Feet    Distance of Nearest POLICE STATION (50 FT increments)
    xFire           Integer         0,1                  Line is within 250 Ft of a FIRE STATION
    xFt2Fire        Integer         0 - n        Feet    Distance of Nearest FIRE STATION (50 FT increments)
    xEmt            Integer         0,1                  No. of Emergency Route Crossings
    pEmt            Integer         0,1                  Line is along Emergency Route
    pFt2Emt         Integer         0 - n        Feet    Dist. Of Line to Emergency Route Street Centerline

Other Proximity Considerations
    Field Name      Field Type   Valid Values    Units   Description / Explanation
    uxMS4           Integer         0,1                  Upstream Node of Line is within a MS4 Boundary
    uxUIC           Integer         0,1                  Upstream Node of Line is within a UIC Drainage Subcatchment
    uDepth          float           0 - n                Upstream Node Depth
    dDepth          float           0 - n                Downstream Node Depth
    gSlope          Integer         0 - n        pct     Pct Slope of Surface; negative indicates US lower than DS
    xPipSlope       float           0 - n                PipeSlope   [(usie-dsie) / pipelen]
    xBldg           Integer         0,1                  Line is within 10 Ft of a BUILDING
    xFt2Bldg        Integer         0 - n        Feet    Distance of Nearest BUILDING (Increments of 2 feet)
    xHyd            Integer         0,1                  Line is within 25 Ft of a HYDRANT
    xFt2Hyd         Integer         0 - n        Feet    Distance of Nearest HYDRANT (Increments of 5 feet)
    HardArea        Integer         0,1                  Pipe is within/intersecting areas defined in table HardAreas.tab
```

### Transportation Codes and Description Details ###

```
    Code Description                                            Mapping Categories
    1110 Freeway (Default Freeway Code)                           Freeway
    1120 Ramps, Interchanges & Feeders                            Freeway
    1121 On-Ramp (Freeway/Highway to Freeway/Highway)             Freeway
    1122 Off-Ramp (Freeway/Highway to Freeway/Highway)            Freeway
    1123 On and Off Ramp (Freeway/Highway to Freeway/Highway)     Freeway
    1200 Highway                                                  Highway
    1221 Local Street to Freeway/Highway On-Ramp                  Primary Arterial
    1222 Freeway/Highway to Local Street Off-Ramp                 Primary Arterial
    1223 Freeway/Highway to Local Street On and Off-Ramp          Primary Arterial
    1300 Primary (Arterial)                                       Primary Arterial
    1400 Secondary (Residential Collector)                        Secondary Arterial
    1450 Major Residential                                        Major Residential
    1500 Minor Residential (Unclassified)                         Residential
    1521 Local Street to Local Street Connector                   Residential
    1700 Private Named Road                                       Residential
    1740 Private Road with Valid Address Range and Street Name    Residential
    1750 Private Road with NO Valid Address Range or Street Name  Residential
    1800 Driveways and Private Unnamed Roads                      Residential
    1950 Unimproved Rights-of-Way in the Development Process      Residential
            (Usually Addressed, will be Active Soon)
    5201 Highway with Rapid Transit
    5301                                                          Secondary Arterial
    5401 Secondary with Rapid Transit                             Secondary Arterial
    5500 Minor with Railroad
    5501 Minor with Rapid Transit
    9000 Forest Service Road
```