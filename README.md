# Newborn Screening Study Code: HPLC and POCT

This repository contains R code for performing analyses related to the SickleInAfrica **Newborn Screening Study**. The study evaluates the accuracy of POCT (Point-of-Care Testing) compared to the gold standard HPLC/IEF method across different sites. The code calculates key performance metrics, including sensitivity, specificity, positive predictive value (PPV), and negative predictive value (NPV).

---

## Repository Structure

- **`HPLC/`**: Contains code for performance calculations, with HPLC/IEF as the gold standard.
- **`POCT/`**: Contains code for performance calculations, with POCT as the gold standard.
- **`Quantitative/`**: Contains scripts and outputs for the quantitative analysis phase, focusing on large-scale data integration and statistical modeling.

---

## Purpose

This repository supports the full lifecycle of newborn screening data analysis:
- Ensuring **data integrity and completeness**
- Performing **imputation for missing values**
- Conducting **quality control and diagnostics**
- Enabling **statistical analysis by genotype**
- Producing **reproducible outputs and reports**
- Extending into a **quantitative phase** for pooled, multi-country analyses

---

## Key Metrics

The following performance metrics are calculated as part of the study:
1. **Sensitivity**: Proportion of true positives correctly identified by DBS/POCT.
2. **Specificity**: Proportion of true negatives correctly identified by DBS/POCT.
3. **Positive Predictive Value (PPV)**: Proportion of positive results by DBS/POCT that are true positives.
4. **Negative Predictive Value (NPV)**: Proportion of negative results by DBS/POCT that are true negatives.
5. **Quantitative Measures** (new phase): Cross-site pooled performance estimates, confidence intervals, heterogeneity tests, and regression-based modeling.

---

## Data Requirements

- **Input Data**: 
  - Screening results for both HPLC and POCT.
  - Quantitative data aggregated across sites and cohorts.
  - Site-specific data files in `.csv` or `.xlsx` format.
- **Folder Structure**: Place input data in the appropriate `data/` subfolder.

---

## How to Use

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo-link.git
   cd newborn-screening-study

  Report: https://wilson-afk.github.io/newborn-docs/
