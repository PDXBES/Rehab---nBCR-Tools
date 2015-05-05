# Purpose of Document #
Detailed Schema Description of remainingYears table

### Field Details ###
```
Field: mLinkID                         Alias: mlinkid              Data Type: int
                                       Nulls: yes                  Unique: yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: MapInfo
       Relates to the MapInfo origins of the object.  For whole pipes, this number will be below or equal to
       40,000,000.  For segments, this number will be above 40,000,000.

Field: yrToFailure                     Alias: YearsToFailure       Data Type: int                
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]
```