~~~
$quill: usace_report_appendix@0.0
$kind: main
appendix_letter: B
appendix_title: Cost Engineering
project_name: Cougar Dam Downstream Passage
cui_enabled: true
cui_controlled_by_component: USACE
cui_controlled_by_office: CENWP-EC
cui_categories:
  - CTI
  - CEII
  - PROPIN
cui_distribution:
  value: Other
  detail: DL ONLY
cui_poc: Jane Q. Engineer, CENWP-EC-C, 503-555-0142
~~~
This appendix presents the cost estimate for the recommended plan.

# Basis of Estimate

The estimate is a Class 3 estimate prepared in MCACES MII.

## Quantities

Quantities come from the 60 percent design.

### Concrete

Mass concrete is priced by the cubic yard.

#### Unit prices

Unit prices are from the 2026 RSMeans data.

##### Escalation.

Costs escalate to the midpoint of construction.

###### Contingency.

Contingency comes from the Abbreviated Risk Analysis.

- Labor rates are Davis-Bacon rates for Lane County.
- Equipment rates are from EP 1110-1-8.
  - Region 9 rates apply.
  - Standby is priced at half rate.

1. Price the direct costs.
   1. Price labor.
      1. Apply the crew rates.
         1. Check the overtime premium.
            1. Confirm the shift schedule.
               1. Record the source.
2. Add the indirect costs.

| Feature | Quantity | Unit | Cost ($) |
| --- | ---: | :---: | ---: |
| Mass concrete | 12,400 | CY | 9,920,000 |
| Reinforcing steel | 1,100 | TON | 2,860,000 |
| Gate hoists | 2 | EA | 4,300,000 |

**Note.** Costs are at the FY26 price level.

# Schedule

## Construction duration

The duration follows from the critical path.

$$ C_{\text{mid}} = C_0 (1 + e)^{t} $$

**Where:**

- $C_0$ = the FY26 cost
- $e$ = the annual escalation rate
- $t$ = years to the construction midpoint

| Phase | Start | Finish |
| --- | --- | --- |
| Design | FY27 | FY28 |
| Construction | FY29 | FY32 |

$$ R = \frac{C_{\text{total}}}{C_{\text{base}}} $$

# Risk

## Abbreviated Risk Analysis

The analysis covers cost and schedule risk.

> The PDT accepts the 25 percent contingency.

The contingency is applied to direct costs.
