load('/data/safegraph/safegraph.Rdata')


library(tidyverse)


zippy <- read.csv("April_1_pos_tests.csv")

zippy <- zippy %>% mutate(postal_code = MODZCTA)


#zippy$postal_code <- as.numeric(zippy$postal_code)
safegraph <- inner_join(safegraph, zippy, by="postal_code")


safegraph <- safegraph[, -c(7:9)]


baseline_df <- safegraph %>% filter(grepl("^2020-02-", date))


baseline_df <- baseline_df %>% group_by(postal_code) %>% summarize(base_med = median(avg_visits_per_day))

#vz 


safegraph <- inner_join(safegraph, baseline_df, by= "postal_code") 

safegraph<- safegraph %>% mutate(change_base = (avg_visits_per_day - base_med) / base_med)

safegraph$date <- as.factor(safegraph$date)

#safegraph$change_base <- as.numeric(safegraph$change_base)


#filter out feb
safegraph <- safegraph %>% filter(grepl("^2020-03-", date) | grepl("^2020-04-", date))

#get median of all zips
dates_listy <- safegraph %>% group_by(date) %>% summarise(all_zip_med = median(change_base, na.rm=TRUE), 
                                                          all_zip_quant_low = quantile(change_base, .25 ,na.rm=TRUE),
                                                          all_zip_quant_high = quantile(change_base, .75 ,na.rm=TRUE))




ggplot() +
  geom_violin(data = safegraph, aes(x = change_base, y = date), color = "orange") +
  geom_pointrange(data = dates_listy, aes(x = all_zip_med, y = date, xmin = all_zip_quant_low, xmax = all_zip_quant_high), color = "red") +
  xlim(-1,2)









