# Purpose of Document #
Detailed Schema Description of segmentFuture table

### Field Details ###
```
Field: mLinkID                         Alias: mlinkid              Data Type: int
                                       Nulls: yes                  Unique: yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: MapInfo
       Relates to the MapInfo origins of the object.  For whole pipes, this number will be below or equal to
       40,000,000.  For segments, this number will be above 40,000,000.

Field: consequenceFailure              Alias: cof                  Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       The consequence of failure.  This is the dollar value of financial repercussions that the city may
       endure if the whole pipe experiences a failure.  For segments this value should be NULL.

Field: segmentStdDev                   Alias: std_dev_seg          Data Type: float
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       For a segment, this indicates the standard deviation of possible failure years about the given failure
       year.  For a whole pipe, this value should be NULL.

Field: segmentFailureYr                Alias: fail_yr_seg          Data Type: float
                                       Nulls: yes                  Unique: no                       
                                       Index: no                   Default Value: none        
                                       Domain: {}                  Source: Derived
       This is the estimated failure year of the segment in question.  This value ignores any engineers
       estimate.

Field: years                           Alias: years                Data Type: int                
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]

Field: baseWorth                       Alias: bpw                  Data Type: int                
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       BPW is acronym for Base Present Worth.  The base present worth for a segment is NULL.  The base present worth
       for a whole pipe is calculated as the sum of the base present worth of its child segments (bpw_seg).
```