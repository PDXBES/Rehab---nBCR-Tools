# Purpose of Document #
Detailed Schema Description of otherVSP table

### Field Details ###
```
Field: mLinkId                         Alias: mlinkid              Data Type: int
                                       Nulls: yes                  Unique: yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: MapInfo
       Relates to the MapInfo origins of the object.  For whole pipes, this number will be below or equal to
       40,000,000.  For segments, this number will be above 40,000,000.

Field: compKey                         Alias: compkey              Data Type: int
                                       Nulls: yes                  Unique: Yes
                                       Index: no                    Default Value: none
                                       Domain {}                   Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo
       version, but have not been assigned a match in the Hansen version, this number will be 0.

Field: fm                              Alias: fm                   Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most upstream point of
       segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: distanceFrom                    Alias: distFrom             Data Type: float              
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most upstream point of
       segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: to                              Alias: to                   Data Type: float              
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most downstream point of
       the segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: distanceTo                      Alias: distTo               Data Type: float              
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most downstream point of
       the segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: changeDetail                    Alias: chDetail             Data Type: nvarchar(12)       
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [Description]
```