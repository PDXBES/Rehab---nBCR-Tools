# Purpose of Document #
Detailed Scheme Description of materialChanges table

### Field Details ###
```
Field: mapInfoId                       Alias: MAPINFO_ID           Data Type: int
                                       Nulls: No                   Unique: Yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: MAPINFO
       MapInfo ID

Field: objectId                        Alias: OBJECTID             Data Type: float
                                       Nulls: yes                  Unique: Yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: ESRI
       ArcMap field, assigned and managed by ArcGIS.  See ArcMap documentation for further information.

Field: compKey                         Alias: compkey              Data Type: float
                                       Nulls: yes                  Unique: Yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo
       version, but have not been assigned a match in the Hansen version, this number will be 0.

Field: gDetLKey                        Alias: GDETLKEY             Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source:
       [Discription]

Field: addBy                           Alias: ADDBY                Data Type: nvarchar(30)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: internal
       [Description]

Field: addDate                         Alias: ADDDTTM              Data Type: datetime
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: internal
       [Description]

Field: modifiedBy                      Alias: MODBY                Data Type: nvarchar(30)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: internal
       [Description]

Field: modifiedDate                    Alias: MODDTTM              Data Type: datetime
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: internal
       [Description]

Field: fm                              Alias: fm                   Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most upstream point of 
       segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: to                              Alias: to                   Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most downstream point of 
       the segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: distanceFm                      Alias: FROMDIST             Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most upstream point of 
       segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: distanceTo                      Alias: TODIST               Data Type: numeric(8, 2)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most downstream point of 
       the segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: changeType                      Alias: chtype               Data Type: nvarchar(12)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source:
       [Description]

Field: changeDetail                    Alias: chdetail             Data Type: nvarchar(12)
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source:
       [Description]

Field: changeDate                      Alias: chdate               Data Type: datetime
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source:
       [Description]

Field: locationErrors                  Alias: LOC_ERRORS           Data Type: nvarchar(50)      
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain {}                   Source:
       [Description]

Field: SHAPE_LEN                       Alias: SHAPE_LEN            Data Type: geometry           
                                       Nulls: no                   Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: ESRI
       ArcGIS geometry field. Derived by ArcGIS and is automatically update by ArcGIS is some cases. Editing
       field outside of ArcGIS is not recommended.
```