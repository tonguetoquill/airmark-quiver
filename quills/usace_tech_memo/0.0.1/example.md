~~~
$quill: usace_tech_memo
memo_number: ENC-22-001
location_lines:
  - COWLITZ RIVER
  - COLUMBIA RIVER BASIN
  - WASHINGTON
study_name: Lower Columbia Stage Frequency Study
subject: Peak flow frequency at Castle Rock, Washington
prepared_for: Federal Emergency Management Agency
prepared_by: U.S. Army Corps of Engineers, Portland District
date: 2022-04-19
include_summary: true
cui_enabled: true
cui_cover: true
cui_controlled_by_component: USACE
cui_controlled_by_office: CENWP-EC
cui_categories:
  - CTI
  - CEII
cui_distribution: FED ONLY
cui_distribution_reason:
  - Controlled Technical Information
cui_distribution_date: 2022-04-19
cui_poc: Jane Q. Engineer, CENWP-EC-H, 503-555-0142
appendices:
  - letter: A
    title: PLATES
  - letter: B
    title: HYDROLOGIC CALCULATIONS
pertinent_data: |
  Drainage area at Castle Rock: 2,240 square miles

  Period of record: water years 1928–2021

  Project datum: NAVD88
previous_memos:
  - number: ENC-21-004
    title: Hydrology methodology for the Lower Columbia Stage Frequency Study
    date: 2021-06-15
  - number: ENC-21-009
    title: Rating curve at Castle Rock
    date: 2021-11-02
acronyms:
  - acronym: AEP
    description: Annual Exceedance Probability
  - acronym: CEII
    description: Critical Energy Infrastructure Information
  - acronym: CTI
    description: Critical Infrastructure Information
  - acronym: cfs
    description: cubic feet per second
  - acronym: PDT
    description: Project Delivery Team
  - acronym: USACE
    description: U.S. Army Corps of Engineers
~~~

# Purpose

This memorandum documents peak-flow frequency at the Cowlitz River near Castle Rock, Washington, for use in the Lower Columbia Stage Frequency Study. It states the recommended 10-, 2-, 1-, and 0.2-percent annual exceedance probability (AEP) discharges and the stages that go with them.

# Summary

The recommended 1-percent AEP peak flow at Castle Rock is 226,000 cubic feet per second (cfs), at a stage of 54.0 feet NAVD88. The estimate uses the systematic record from water years 1928 through 2021, with the 2008 event treated as a historic peak. Bulletin 17C procedures, as implemented in HEC-SSP, are the computational method.

# Discussion

## Streamgage record

The Castle Rock gage has a systematic peak-flow record of 94 years. The 2008 peak of 142,000 cfs is the flood of record in the systematic sample. Two earlier peaks, in 1933 and 1996, exceed 100,000 cfs.

The rating in effect for water years 2012 through 2021 is the rating adopted in ENC-21-009. High-flow measurements in 1996 and 2008 anchor the upper end.

##### Record period.

The systematic record starts in water year 1928, when the gage was established, and ends in water year 2021, the last year on the hydrograph used for this memorandum.

## Frequency analysis

Bulletin 17C expected moments algorithm estimates, with a regional skew of −0.21 and a mean-square error of 0.14, are the adopted frequencies. Low outliers were not identified.

1. Screen the systematic peaks for low outliers and for peaks affected by regulation.
   1. Compare each peak to the Multiple Grubbs-Beck threshold.
   2. Flag a peak that is not a natural flow.
      1. Document the regulation or break in the station history.
      2. Decide whether the peak stays in the sample.
         1. Keep it when the regulation is minor at the flood peak.
         2. Remove it when the peak is not a natural Cowlitz flow.
            1. Record the decision in the hydrologic calculations in Appendix B.
            2. Recalculate the EMA fit without that peak.
2. Fit the log-Pearson Type III distribution with the expected moments algorithm.
3. Plot the adopted frequency curve against the plotting positions.

The adopted peaks are:

| AEP | Peak flow (cfs) | Stage (ft, NAVD88) |
| --- | ---: | ---: |
| 0.10 | 142,000 | 48.2 |
| 0.02 | 198,000 | 52.1 |
| 0.01 | 226,000 | 54.0 |
| 0.002 | 278,000 | 56.8 |

**Note.** Peak flows are unregulated. Stages are read from the ENC-21-009 rating.

The 1-percent AEP unit discharge used in the channel-forming check is

$$ p = 0.875 W a_c H y $$

**Where:**

- $p$ = unit discharge, in cubic feet per second per foot
- $W$ = water-surface width, in feet
- $a_c$ = conveyance coefficient
- $H$ = hydraulic depth, in feet
- $y$ = energy slope, in feet per foot

The results compare with the 2012 FEMA study to within 6 percent at the 1-percent AEP. The difference is the longer systematic record and the Bulletin 17C treatment of the 2008 peak.

# Recommendation

The PDT should adopt the peak flows and stages in this memorandum for the Lower Columbia Stage Frequency Study at Castle Rock. Appendix A holds the plates; Appendix B holds the hydrologic calculations.

# References

England, J. F., Jr., T. A. Cohn, B. A. Faber, J. R. Stedinger, W. O. Thomas Jr., A. G. Veilleux, J. E. Kiang, and R. R. Mason Jr. 2019. *Guidelines for Determining Flood Flow Frequency—Bulletin 17C.* Techniques and Methods 4-B5. Reston, VA: U.S. Geological Survey.

U.S. Army Corps of Engineers. 2021. *Hydrology methodology for the Lower Columbia Stage Frequency Study.* Technical Memorandum ENC-21-004. Portland, OR: Portland District.

U.S. Army Corps of Engineers. 2021. *Rating curve at Castle Rock.* Technical Memorandum ENC-21-009. Portland, OR: Portland District.
