# README — Co-occurring conditions in Iraqi children with ASD (R)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16917998.svg)](https://doi.org/10.5281/zenodo.16917998)

**Repository author:** Ghaith Al‑Gburi

**Study DOI / citation:** Toman AK, AbdulRasool HR, Lami F, Jasim SM, Jaber OA, Nayeri ND, Sabet MS, Al‑Gburi G. *Exploring co‑occurring conditions in Iraqi children with autism spectrum disorder: prevalence, characteristics, and potential risk factors.* Frontiers in Psychiatry. 2025. DOI: `10.3389/fpsyt.2025.1592374`.

## Quick view
Click to view the full analysis results and visualizations:
[Open rendered report — result.html](https://rawcdn.githack.com/GhaithAl-Gburi/ASD-Comorbidity/main/result.html)

---

## Purpose
This repository contains `Analysis_code.R` — an R script used to analyse co‑occurring epilepsy, sleep, and weight issues in a multicenter clinic sample of Iraqi children with autism spectrum disorder (ASD). The script performs non‑parametric group comparisons (Kruskal–Wallis), categorical tests (Chi‑square), pairwise Mann–Whitney (Wilcoxon) tests, and computes effect‑size measures (ε², Cramér’s V, Wilcoxon *r*). The analyses reflect the variables and design reported in the published study.

> **Data privacy:** this repository does **not** include participant‑level identifiable data.

---

## Files in this repo
- `Analysis_code.R` — the main analysis script.  
- `Analysis_code.Rmd` — R Markdown source (script + narrative + plots).  
- `result.html` — rendered report (clickable summary of results & plots).  
- `input.csv` — the dataset expected by the script (see *Expected data format*).
- `survey.docx` — the doc file containing the arabic and english version of the research survey
- `README.md` — this file.
- `LICENSE` — MIT License (reuse and citation conditions).

---

## Required R version & packages
- R (>= 4.0 recommended)  
- Required packages (used in `Analysis_code.R`):  
  - `rcompanion` (ε², Cramér’s V, wilcoxonR helpers)  
  - `ggplot2` (plots)  
  - `scales` (percent formatting for bar plots)  

Install packages in R with:

```r
install.packages(c("rcompanion","ggplot2","scales"))
```

`kruskal.test`, `chisq.test`, and `wilcox.test` are base R functions (stats package).

---

## Expected data format (column names)
`Analysis_code.R` expects a CSV (`input.csv`) with the following columns (exact names used in the script):

- Continuous / scale vars used for centre comparisons:
  - `age`, `dx_age`, `bmi`
- Grouping (centre) variable:
  - `source` — expected factor levels used in the script: `al_subtain`, `al_hussein`, `baghdad`
- Categorical variables used for centre comparisons:
  - `gender`, `asd_fhx`, `epilepsy`, `sleep_disorder`
- Outcome & grouping vars for BMI analyses:
  - `bmi` (outcome)
  - Binary groups: `chronic_condition`, `family_hx`, `excessive_screentime`, `resperidone`  
    *script expects levels `No` and `Yes`*
  - Multi‑category groups: `calorie`, `daytime_activity`, `family_lifestyle`  
    *script sets factor levels to `Low`, `Moderate`, `High`*

Notes / expectations:
- Missing rows (NAs) are removed with `na.omit()` before each test.  
- Some variables are treated as factors with explicit level ordering in the script — keep values consistent (e.g., `source` spelled exactly as `al_subtain`, `al_hussein`, `baghdad`, and binary groups as `No`/`Yes`).

---

## What the script does (high-level)
- Reads `input.csv`.  
- Compares continuous sample characteristics across healthcare centres (`age`, `dx_age`, `bmi`) using Kruskal–Wallis; computes ε² with bootstrap CIs (via `rcompanion::epsilonSquared`) and plots jitter + median crossbar per centre.  
- Tests categorical differences across centres (`gender`, `asd_fhx`, `epilepsy`, `sleep_disorder`) using Chi‑square tests and reports Cramér’s V (with bootstrap CIs). Plots are stacked/proportion bar charts.  
- Tests potential factors associated with BMI:
  - For binary groupings: Mann–Whitney (Wilcoxon) tests and Wilcoxon *r* with CIs (`rcompanion::wilcoxonR`).
  - For multi‑level groupings: Kruskal–Wallis and ε² effect sizes.
- Prints result data frames: `results_char1`, `results_char2`, `results_binary`, `results_multi` to the console.

---

## How to run
From R (repository root):

```r
# open an R session in the project folder:
source("Analysis_code.R")
```

From the command line:

```bash
Rscript Analysis_code.R
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

## Notes about the study (short)
- The study is a multicenter cross‑sectional survey of children with ASD recruited from three specialized centres in Iraq (Al‑Subtain Academy, Imam Hussein Centre, Baghdad’s National Centre) between January and August 2024. Sample size reported in the article is 240 (clinic sample).
- Key results relevant to this script include prevalence estimates for epilepsy, sleep problems, and weight issues, and small but significant associations observed between BMI and risperidone use, sleep duration, and diet.

---

## License & citation
**License:** This repository is released under the **MIT License**.

**How to cite the study using this code:**  

```
Toman AK, AbdulRasool HR, Lami F, Jasim SM, Jaber OA, Nayeri ND, Sabet MS, Al‑Gburi G. Exploring co‑occurring conditions in Iraqi children with autism spectrum disorder: prevalence, characteristics, and potential risk factors. Frontiers in Psychiatry. 2025. DOI: 10.3389/fpsyt.2025.1592374
```

**How to cite this code:**  

```
Al-Gburi G. Analysis code for: Exploring co-occurring conditions in Iraqi children with ASD. Zenodo. 2025. DOI: 10.5281/zenodo.16917998
```

---

## Contact
- **Author:** Ghaith Al‑Gburi
- **Email:** ghaith.ali.khaleel@gmail.com 
- **GitHub:** `https://github.com/GhaithAl-Gburi`  
- **ORCID:** `0000-0001-7427-8310` 


---


