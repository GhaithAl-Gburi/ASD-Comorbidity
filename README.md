# README — Co-occurring conditions in Iraqi children with ASD (R)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16917998.svg)](https://doi.org/10.5281/zenodo.16917998)

**Repository author:** Ghaith Al‑Gburi

**Study DOI / citation:** Toman AK, AbdulRasool HR, Lami F, et al. Exploring co-occurring conditions in Iraqi children with autism spectrum disorder: prevalence, characteristics, and potential risk factors. Front Psychiatry. 2025;16. doi:`10.3389/fpsyt.2025.1592374`.

[![Read the Study](https://img.shields.io/badge/Read%20the%20Study-blue)](https://doi.org/10.3389/fpsyt.2025.1592374)

## Quick view
Click to view the full analysis results and visualizations:
[Open rendered report](https://rawcdn.githack.com/GhaithAl-Gburi/ASD-Comorbidity/main/analysis_report.pdf)

---

## Purpose
This repository contains `compute_effect_size.R` — an R script used to analyse co‑occurring epilepsy, sleep, and weight issues in a multicenter clinic sample of Iraqi children with autism spectrum disorder. The script performs non‑parametric group comparisons (Kruskal–Wallis), categorical tests (Chi‑square), pairwise Mann–Whitney (Wilcoxon) tests, and computes effect‑size measures (ε², Cramér’s V, Wilcoxon *r*).

> **Data privacy:** this repository does **not** include participant‑level identifiable data.

---

## Files in this repo
- `compute_effect_size.R` — R script.  
- `compute_effect_size.Rmd` — R Markdown dpcument (script + narrative + plots).  
- `analysis_report.pdf` — Rendered PDF report for the complete analysis workflow.  
- `ASD_comobidity_dataset.csv` — CSV file containing the data used for statistical analysis (see *Expected data format*).
- `survey.docx` — Doc file containing the arabic and english version of the research survey.
- `README.md` — This file.
- `LICENSE` — AGPL-3.0 License (reuse and citation conditions).

---

## Required R version & packages
- R (>= 4.0 recommended)  
- Required packages:  
  - `rcompanion` (ε², Cramér’s V, wilcoxonR helpers)  
  - `ggplot2` (plots)  
  - `scales` (percent formatting for bar plots)  

`kruskal.test`, `chisq.test`, and `wilcox.test` are base R functions (stats package).

---

## Expected data format (column names)

The script expects a CSV file with the following columns:

| Category                                   | Variable names                                                                 |
|--------------------------------------------|----------------------------------------------------------------------------------|
| Continuous samples characteristics | `age`, `dx_age`, `bmi`                                                          |
| Centre grouping variable                   | `source` (al_subtain, al_hussein, baghdad)                                |
| Categorical samples characteristics | `gender`, `asd_fhx`, `epilepsy`, `sleep_disorder`                              |
| Binary grouping variables                  | `chronic_condition`, `family_hx`, `excessive_screentime`, `resperidone` |
| Multi-level grouping variables             | `calorie`, `daytime_activity`, `family_lifestyle` (Low, Moderate, High)  |


Notes / expectations:
- Missing rows (NAs) are removed with `na.omit()` before each test.  
- Some variables are treated as factors with explicit level ordering in the script — keep values consistent (e.g., `source` spelled exactly as `al_subtain`, `al_hussein`, `baghdad`, and binary groups as `No`/`Yes`).

---

## What the script does (high-level)
1. **Reads** the dataset.  

2. **Centre comparisons (sample characteristics):**  
   - Compares continuous variables (`age`, `dx_age`, `bmi`) across healthcare centres using Kruskal–Wallis tests.  
   - Computes ε² effect sizes with bootstrap confidence intervals (`rcompanion::epsilonSquared`).  
   - Produces jitter + median crossbar plots for each centre.  

3. **Categorical comparisons across centres:**  
   - Tests categorical variables (`gender`, `asd_fhx`, `epilepsy`, `sleep_disorder`) using Chi-square tests.  
   - Computes Cramér’s V effect sizes with bootstrap confidence intervals (`rcompanion::cramerV`).  
   - Produces proportional stacked bar charts.  

4. **BMI group comparisons:**  
   - **Binary group comparisons:**  
     - Uses Mann–Whitney (Wilcoxon) tests to compare BMI across binary variables.  
     - Computes Wilcoxon *r* effect sizes with bootstrap confidence intervals (`rcompanion::wilcoxonR`).  
     - Produces jitter + median crossbar plots for each group.  
   - **Multi-level group comparisons:**  
     - Uses Kruskal–Wallis tests for multi-level variables.  
     - Computes ε² effect sizes with bootstrap confidence intervals.  
     - Produces jitter + median crossbar plots for each group.  

5. **Outputs:**  
   - `results_char1` — summary of continuous centre comparisons  
   - `results_char2` — summary of categorical centre comparisons  
   - `results_binary` — summary of binary BMI comparisons  
   - `results_multi` — summary of multi-level BMI comparisons 

---

## How to run
From R (repository root):

```r
# open an R session in the project folder:
source("compute_effect_size.R")
```

From the command line:

```bash
Rscript compute_effect_size.R
```

---

## Typical outputs produced by the script (what to expect)
- Printed data frames in the R console:
  - `results_char1` — Kruskal–Wallis results for continuous variables (H, df, p, ε²).  
  - `results_char2` — Chi‑square & Cramér’s V results for categorical variables.  
  - `results_binary` — Wilcoxon/Mann–Whitney results for binary predictors of BMI.  
  - `results_multi` — Kruskal–Wallis results for multi‑level predictors of BMI.  
- Plots printed to the active graphics device:
  - Jitter + median crossbar plots for continuous comparisons.  
  - Proportion stacked bar charts for categorical distributions.

- **Note:** the provided `Analysis_code.R` prints objects and plots but does **not** automatically save CSVs or figure files. If you want to persist outputs, add lines such as:

```r
write.csv(results_char1, "results_char1.csv", row.names = FALSE)
ggsave("bmi_by_risperidone.png")  # after a specific plot call
```

---

## Reproducibility & recommended tweaks
- The script sets `set.seed(123)` — keep this for reproducible bootstrap CIs.  
- If you plan to run the script unattended (e.g., on a remote server), add explicit `ggsave()` calls to persist plots, and `write.csv()` for results.  
- Consider adding `check.packages <- function(pkgs) { ... }` helper to install missing packages programmatically.

---

## Notes about the study
- The study is a multicenter cross‑sectional survey of children with ASD recruited from three specialized centres in Iraq (Al‑Subtain Academy, Imam Hussein Centre, Baghdad’s National Centre) between January and August 2024. Sample size reported in the article is 240 (clinic sample).
- Key results relevant to this script include prevalence estimates for epilepsy, sleep problems, and weight issues, and small but significant associations observed between BMI and risperidone use, sleep duration, and diet.

---

## License & citation

**License:** This repository is released under the **AGPL-3.0 License**.

**How to cite this code:**  

```
Al-Gburi, G. (2025). Analysis code for: Exploring co-occurring conditions in Iraqi children with ASD. Zenodo. https://doi.org/10.5281/zenodo.16917998
```

---

## Contact
- **Author:** Ghaith Al‑Gburi
- **Email:** ghaith.ali.khaleel@gmail.com 
- **GitHub:** `https://github.com/GhaithAl-Gburi`  
- **ORCID:** `0000-0001-7427-8310` 

---
