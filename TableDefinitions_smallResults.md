# Purpose of Document #
Detailed Scheme Description of smallResults table
### Field Details ###
```
Field: compkey       Alias: compkey              Data Type: int               Nulls: no
                     Unique: Yes                 Index: no                    Default Value: none
                     Domain: {}                  Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo version,
       but have not been assigned a match in the Hansen version, this number will be 0.

Field: cutno         Alias: cutno                Data Type: int                Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) The order in which a segment falls.  The most upstream segment of a pipe will have
       a cutno of 1, the most downstream segment will have the highest cutno.  The parent pipe will have a cutno of 0


Field: fm            Alias: fm                   Data Type: numeric(8, 2)      Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most upstream point of segment
       to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.


Field: to            Alias: to                   Data Type: numeric(8, 2)      Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most downstream point of the
       segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.

Field: failYr        Alias: failureYear          Data Type: int                Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       For a whole pipe, this is the projected failure year.  For a segment, this should be NULL.

Field: failYrSeg   Alias: failureYearSeg         Data Type: int                Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       For a pipe segment, this is the projected failure year.  For a whole pipe, this should be NULL.


Field: stdDev        Alias: standardDeviation    Data Type: int                Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       For a whole pipe, this indicates the standard deviation of possible failure years about the given failure
       year.  For a segment, this value should be NULL.

Field: stdDevSeg     Alias: standardDeviationSeg Data Type: int                Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       For a pipe segment, this indicates the standard deviation of possible failure years about the given failure
       year.  For a whole pipe, this value should be NULL.

Field: consequenceFailure       Alias: consequenceFailure   Data Type: int                Nulls: yes
                                Unique: no                  Index: no                     Default Value: none
                                Domain: {}                  Source: Derived
       [description]

Field: replacementCost          Alias: replacementCost      Data Type: int                Nulls: yes
                                Unique: no                  Index: no                     Default Value: none
                                Domain: {}                  Source: Derived
       [description]

Field: r2010         Alias: r2010                Data Type: float              Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       [description]

Field: r2150         Alias: r2150                Data Type: float              Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       [description]

Field: b2010         Alias: r2010                Data Type: float              Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       [description]

Field: b2150         Alias: r2150                Data Type: float              Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       [description]

Field: r2010Seg      Alias: r2010                Data Type: float              Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       [description]

Field: r2150Seg      Alias: r2150                Data Type: float              Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       [description]

Field: b2010Seg      Alias: r2010                Data Type: float              Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       [description]

Field: b2150Seg      Alias: r2150                Data Type: float              Nulls: yes
                     Unique: no                  Index: no                     Default Value: none
                     Domain: {}                  Source: Derived
       [description]
```