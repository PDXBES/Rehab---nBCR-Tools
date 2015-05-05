Forcasting Rehabilation Cost Model 07-18-2011.

```
    file name: Visio-Forecasting Rehab Costs20110718.pdf
       Object:
   Written by: Gail Luthy
Documented by: Neil Revello
   Created on: 7/29/2011 1:00PM
  Modified on: 9/12/2011 4:28PM
     argument:
       output:
      purpose:
        scope:
    revisions:
        notes: Action 0, 9, 10, 11, 12 get RUL with current inspections
               Action 8 - Pipes (whole pipe replacement) start as Action 4 pipes between Action 2, 6 or 7 pipes
               (whole pipe replacement)
        logic: Process Step (PS)
               1 Data from Hansen Sanitary, Combined Sewers and CSO Outfalls have [service status] {IN, NEW, PEND}
                 With an [ownership] of {BES}  Is this data in the model
                                                - True Condition data to PS 2
                                                - False Condition data to ACT 5
               2 Data from PS 1 is [service status] {IN, NEW, PEND}
                                                - True Condition data {NEW, PEND} to PS 3
                                                - False Condition data {IN} to PS 4
               3 Data from PS 2 is [service status] {NEW, PEND}
                                                - True Condition data {PEND} to Act 10
                                                - False Condition data {NEW} to Act 4
               4 Data from PS 2 is current TV
                                                - True Condition data to PS 7
                                                - False Condition data to PS 5
               5 Data from PS 4 is pressure line
                                                - True Condition data to Act 12
                                                - False Condition data to PS 6
               6 Data from PS 5 is pipe age less than 40 years
                                                - True Condition data to Act 9
                                                - False Condition data Act 0
               7 Data from PS 4 is grade {1, 2, 3}
                                                - True Condition data to Act 1
                                                - False Condition
                                                      - (count) previously failed [pf] & near failed [nf] segments
                                                      - data to PS 8
               8 Data from PS 7 is [count] greater than or equal to {10%} of [total] and [nf] is greater than or
                 equal to {2}
                                                - True Condition data to Act 2
                                                - False Condition data to PS 9
               9 Data from PS 8  is [count] LESS than {10%} of [total] and [nf] is {0}
                                                - True Condition data to Act 11
                                                - False Condition data to Act 10
              10 Data from PS 9 is number of defective laterals greater than or equal to {4}
                                                - True Condition data to Act 2, 6, 7
                                                - False Condition data to Act 3
              11 Data from PS 9 is number of defective laterals greater than or equal to {4}
                                                - True Condition data to Act 2, 6 ,7
                                                - False Condition data to Act 4

               Action Status (Act)
               0 no current inspection and greater than or equal to 40 years old or no installation date
                        Use RULmla_ac - fail_yr from RUlmla_ac but not less than NOW
                                   std_dev = 0.2 * RUL NLT 5
               1 Grade 1, 2, 3
                        Determine remaining useful life and failure year of whole pipe from literature curves and
                        inspection date
                                   fail_yr = insp_year + RUL ; std_dev = (0.1 * RUL) + (0.15 * insp_yrsago)
                                   replacement cost at fail_yr with std_dev
               2 Grade 4 or 5 whole pipe
                        Whole Pipe Replacement - Assume whole pipe replacement in current year (NOW)
                        (no standard deviation) + whole pipe replacement in 120 years std_dev = 12
               3 Grade 4 or 5 spot repair
                        Spot Repair - Assume spot repair cost in current year (no standard deviation)
                        (no standard deviation) + whole pipe replacement in 30 years with std_dev
                                   fail_yr_whole = (NOW) + 30 = 2040   std_dev_whole = 12
               4 Grade 5 or 5 "watch me"
                        Continue Monitoring - fail_yr = insp_year + RUL (based on structural score and literature
                        curve
                                   replacement cost at fail_yr with std_dev
                                   std_dev = (0.1 * RUL) + (0.15 * insp_yrsago)
               5 No Data to process
               6 Grade 4 or 5 whole pipe
                        Whole Pipe Replacement - Assume whole pipe replacement in current year (NOW)
                        (no standard deviation) + whole pipe replacement in 120 years std_dev = 12
               7 Grade 4 or 5 whole pipe
                        Whole Pipe Replacement - Assume whole pipe replacement in current year (NOW)
                        (no standard deviation) + whole pipe replacement in 120 years std_dev = 12
               8 Whole pipe replacement - see Notes for Action 8
               9 No current inspection and less than 40 years old
                        RUL base on age and max RUL for material
                                   fail_yr = install_date + maxRUL ; std_dev = 0.1 * maxRUL
              10 Service status {pend} - replacement material assumed to be concrete
                        RUL = 120
                                   fail_yr = (NOW) + 120 ; std_dev = 12
              11 Serice status {new} - material known
                        RUL equal to the maxRul for pipe material
                                   fail_yr = (NOW) + maxRUL ; std_dev = 0.1 * maxRUL
              12 No current inspection - Pressure Main
                        RUL base on age and max RUL for material pressure main
                                   max RUL = 90 years
                                   fail_yr = install_date + maxRUL ; std_dev = 0.1 * expected RUL = 9

       errors:
```