## Purpose of Document ##
Detailed Schema Description of mortalityExport table

### Field Details ###
```
Field: compKey                         Alias: compkey              Data Type: int
                                       Nulls: yes                  Unique: Yes
                                       Index: no                   Default Value: none
                                       Domain {}                   Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo
       version, but have not been assigned a match in the Hansen version, this number will be 0.

Field: yrsToFailure                     Alias: YearsToFailure       Data Type: int
                                       Nulls: yes                  Unique: no
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Derived
       [Description]
```