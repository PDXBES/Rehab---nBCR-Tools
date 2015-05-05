# Purpose of Document #
Detailed Schema Description of linearSegmentDefect table

### Field Details ###
```
Field: compKey                         Alias: compkey              Data Type: int               
                                       Nulls: yes                  Unique: Yes                 
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo
       version, but have not been assigned a match in the Hansen version, this number will be 0.

Field: cutNo                           Alias: CutNO                Data Type: int              
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]

Field: to                              Alias: to                   Data Type: float              
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most downstream point of 
       the segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: fm                              Alias: fm                   Data Type: float              
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       (SEGMENT ORIENTED FIELD) For segments, this designates the distance from the most upstream point of 
       segment to the most upstream point of the parent pipe.  For parent pipes, this should always be 0.
*****Check this description*****

Field: sumNewScore                     Alias: SumOfNewScore        Data Type: float              
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]
```