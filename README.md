# covid-nyc-2022-group-4
Created by: Navpreet Kaur and Warren Ball

The covid testing data taken originally from:
https://github.com/nychealth/coronavirus-data/blob/097cbd70aa00eb635b17b177bc4546b2fce21895/tests-by-zcta.csv
(You don't need to download this, it's already here)

To replicate the data from the paper (add link), you can run the Warren_Navpreet_turn_in.Rmd file in RStudio. To obtain the data sets used in the paper we retrived data from: -------
The data sets are already loaded into the markdown file/added to the github file (except the SafeGraph data file, which will need to be obtained independently). 


The purpose of this repository is to complete a project given by Microsoft's Data Science SUmmer School.
Our main goal is to be able to replicate the findings of this article:
https://onlinelibrary.wiley.com/doi/full/10.1111/irv.12816

This article delves into the connections between positive COVID cases and various factors such as age, income, use of public transportation, etc.

This repository is dedicated to being able to gather the proper data in order to replicate their various maps on Figure 1, their plot on Figure 2, and their linear model results on their Table 1 and Table 2.

The first goal of the Rmd file (and the HTML file created from it) is to gather the data from the ACS in order to recreate the Figure 1 maps and the Table 1. It then shifts to getting the data and recreating Figure 2. It then brings the various data frames together to recreate the Table 2.

At the very end there are code blocks dedicated to finding the linear model results for the entirety of New York State, contrast to the majority of the Rmd, which is focused only on Mew York City.

EXPLANATIONS OF DATA FILES
- _Covid Positivity Data_
