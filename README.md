# covid-nyc-2022-group-4
Created by: Navpreet Kaur and Warren Ball

**PURPOSE**
The purpose of this repository is to complete a project given by Microsoft's Data Science Summer School.
Our main goal is to be able to replicate the findings of this article:
https://onlinelibrary.wiley.com/doi/full/10.1111/irv.12816

This article delves into the connections between positive COVID cases and various factors such as age, income, use of public transportation, etc.

This repository is dedicated to being able to gather the proper data in order to replicate their various maps on Figure 1, their plot on Figure 2, and their linear model results on their Table 1 and Table 2.

The first goal of the Rmd file (and the HTML file created from it) is to gather the data from the ACS in order to recreate the Figure 1 maps and the Table 1. It then shifts to getting the data and recreating Figure 2. It then brings the various data frames together to recreate the Table 2.

At the very end there are code blocks dedicated to finding the linear model results for the entirety of New York State, contrast to the majority of the Rmd, which is focused only on Mew York City.

**EXPLANATIONS OF DATA FILES**
The data sets are already loaded into the markdown file/added to the github file (except the SafeGraph data file, which will need to be obtained independently). 

01_download_2016_censis_data.R = Gathers all necessary data needed for the replication in separate dataframes. In order to reproduce you will need to use your own API key. In order to just access the data directly we have saved the data to the census_2016_data.RData file for easy access.

April_1_pos_tests.csv = This csv file contains the NYC zipcodes, the total number of tests administered per zipcodes, and the number of positive results in each zipcode. This data is obtained from https://github.com/nychealth/coronavirus-data/blob/097cbd70aa00eb635b17b177bc4546b2fce21895/tests-by-zcta.csv .

Warren_Navpreet_turn_in.Rmd = This is the Rmarkdown file in which all of the code for the replication (and extension) is done. All data needed (except for safegraphs data which you will need to obtain yourself). This is the main file for the repository and you can go through each of the reproduced results from the article. 

Warren.Navpreet_turn_in.html = This is the html file for the Rmarkdown containing all the results. 

apr_1st_NY.csv = This is the dataset for all of New York State (in comparison to the April_1_pos_tests.csv file). The important columns from this dataset are the zipcodes, the total number of tests administered per zipcodes, and the number of positive results in each zipcode. The data is obtained from https://health.data.ny.gov/Health/New-York-State-Statewide-COVID-19-Testing-by-Zip-C/e7te-hhb2 . In order to produce the same csv file, it is best to filter the results for April 1, 2020 data before saving the file and running it.

census_2016_data.RData = This is the 2016 census data that was downloaded from the 01_download_2016_census_data.R.

**REPLICATIONS**
All the code from the replications is done in the Warren_Navpreet_turn_in.Rmd file. Our results and conclusions are written in the markdown and html file. They were very close to accurate for Figure 1, Table 1, and Table 2. For Figure 2 you may see some contrasts since we did not have the complete dataset that was used in the paper.

**EXTENSION**
For an extension on this paper we decided to expand the question to the entire New York State instead of New York City alone. We compared regression values with the ones obtained from NYC alone. The last section in the Warren_Navpreet_turn_in.Rmd file explains our results from this extension.
