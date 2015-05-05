# Purpose of Document #
Detailed Scheme Description of newestStormInspectionDate table
### Field Details ###
```
Field: compKey                         Alias: compkey              Data Type: int               
                                       Nulls: no                   Unique: Yes                 
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source: Hansen
       Relates to the Hansen database source of the pipe information.  For pipes that exist in the MapInfo 
       version, but have not been assigned a match in the Hansen version, this number will be 0.

Field: maxDate                         Alias: maxDates             Data Type: datetime           
                                       Nulls: yes                  Unique: no                  
                                       Index: no                   Default Value: none
                                       Domain: {}                  Source:
       [description]
```