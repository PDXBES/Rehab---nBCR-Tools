# Purpose of Document #
Detailed Scheme Description of constructionCostsDelete table

### Field Details ###
```
Field: mLinkID                         Alias: mlinkid              Data Type: int
                                       Nulls: yes                  Unique: yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: MapInfo
       Relates to the MapInfo origins of the object.  For whole pipes, this number will be below or equal to
       40,000,000.  For segments, this number will be above 40,000,000.

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

Field: directConstructionCost          Alias: directConstructionCost  Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Derived
       [Description]

Field: totalConstructionCost           Alias: totalConstructionCost Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Derived
       [Description]

Field: compKey                         Alias: compkey              Data Type: int
                                       Nulls: yes                  Unique: Yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo
       version, but have not been assigned a match in the Hansen version, this number will be 0.

Field: length                          Alias: length               Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: mstLinks, derived (segmentation)
       The horizontal flow dimension, in feet.  For whole pipes, this describes the length of the whole pipe
       as known by MstLinks.  For pipe segments, this describes a 10 foot or less length of a theoretic
       segment of pipe.  Segments with less that 10 feet of length should always be at the extreme downstream
       end of the series
```