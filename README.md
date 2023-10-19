## Yan Bo's Coding Samples
Subfolders in this repository contain Stata, Python, and R coding samples I made during my previous RAship at UCLA Anderson. Thanks for visiting!

#### Stata:
- `MinWage_sample1.do` and `MinWage_sample2.do` are intermediate steps for the paper "Minimum Wages and Employment Composition" (https://ucla.app.box.com/v/MWComposition), where I calculated each employee's tenure, defined by the total hours worked before the start of the fiscal year, and then divided them into terciles. I am also responsible for creating and updating all regression tables and event study figures in the paper.
- `NEJM_sample.do` creates all figures in "Nursing Home Staff Vaccination and Covid-19 Outcomes" (https://www.nejm.org/doi/full/10.1056/NEJMc2115674).
- `JAMA_sample1.do` and `JAMA_sample2.do` create Figures 1 and 2 in "Association of Nursing Home Characteristics With Staff and Resident COVID-19 Vaccination Coverage" (https://jamanetwork.com/journals/jamainternalmedicine/fullarticle/2784414), respectively.

#### Python
- `Python_functions.py` defines the core machine learning functions we use to predict the occupancy rate for each facility based on the patient's and facility's characteristics for the paper "Picking Your Patients: Selective Admissions in the Nursing Home Industry" (https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3613950).
- **HCRIS** is a technical Python project I wrote recently. Functions defined in HCRIScleaning.py are designed to convert the raw, long-format Healthcare Provider Cost Reporting Information System (HCRIS, https://www.cms.gov/data-research/statistics-trends-and-reports/cost-reports) data into a usable, wide-format panel. Please see `make_HCRIS_raw.py` as an example of how the functions work.

#### R - Bayesian Interpretation of Ratings
This project folder contains a research note excerpt from a project on how a Bayesian consumer should interpret the star ratings for General Practitioners in the UK. Please see `RA_Sample_Exercise.pdf` for a detailed description and `RA_Exercise_report.Rmd` for my write-up in R Markdown.

#### R - Generalized Linear Models
`Generalized Linear Models.ipynb` was my final project for Stanford MS&E 311 Optimization, where I implemented the OLS, logit, and probit models with different optimization algorithms in R.
