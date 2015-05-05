# Purpose of Document #
Detailed scheme Description of 10FtSegsmentsFeatures table

**Note: This table has been depreciate.**

### Field Details ###
```
Field: objectID                        Alias: OBJECTID             Data Type: int
                                       Nulls: No                   Unique: Yes
                                       Index: Yes                  Default Value: none
                                       Domain {}                   Source: ESRI
       ArcMap field, assigned and managed by ArcGIS.  See ArcMap documentation for further information.


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

Field: shape                           Alias: SHAPE                Data Type: geometry           
                                       Nulls: no                   Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: ESRI
       ArcGIS geometry field. Controlled and edited by ArcGIS and is not editable outside of ArcGIS.

Field: globalId                        Alias: globalId             Data Type: uniqueidentifier   
                                       Nulls: No                   Unique: Yes                 
                                       Index: no                   Default Value:
                                       Domain: {}                  Source: DME
       DME Field -  Controlled by DME and should not edited
```