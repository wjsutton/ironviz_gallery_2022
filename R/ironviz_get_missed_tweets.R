library(rtweet)
library(dplyr)

# Load data
ironviz <- readRDS("data/#ironviz_tweets.RDS")

# Find missing tweet by status_id, e.g.
missing <- lookup_tweets(c('1485989270200463370'))

# Merge with ironviz tweets
ironviz <- rbind(ironviz,missing)
ironviz <- unique(ironviz)

# Save data
saveRDS(ironviz,"data/#ironviz_tweets.RDS")

