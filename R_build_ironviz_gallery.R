
### Step 0: Load libraries and functions
# Load Libraries
# if one is missing you can install it with install.packages("package_name")
library(rtweet)
library(dplyr)
library(longurl)
library(stringr)
library(tidyr)

# Add in "not in" function
'%not in%' <- Negate('%in%')

# Add in created functions
source("R/function_get_and_save_tweets.R")

### Step 1: Collect data from Twitter

# Search Twitter for #Ironviz and #IronViz2022 and save the tweets under /data folder
get_and_save_tweets(text = "#ironviz", count = 10000, path = "data")
get_and_save_tweets(text = "#ironviz2022", count = 10000, path = "data")

# Notice a tweet is missing - add it in the dateset using the script:
# R/ironviz_get_missed_tweets.R

### Step 2: Find Iron Viz submissions from Tweets

# Load data
ironviz <- readRDS("data/#ironviz_tweets.RDS")
ironviz2022 <- readRDS("data/#ironviz2022_tweets.RDS")
ironviz <- unique(rbind(ironviz,ironviz2022))

# Tweet is sharing a viz not a submission 
non_submissions <- c(
  '1482537691132542976',
  '1483670703551381504'
)
ironviz <- ironviz %>% filter(status_id %not in% non_submissions)

# Flatten list in data.frame
df <- ironviz[,c('status_id','screen_name','urls_expanded_url')]
df <- unnest(df,urls_expanded_url)
df$tweet_url <- paste0('https://twitter.com/',df$screen_name,'/status/',df$status_id)

# Case 0: not NA
submission_df <- filter(df,!is.na(urls_expanded_url))

# Expand short urls
short_urls <- submission_df$urls_expanded_url[nchar(submission_df$urls_expanded_url)<35]
expanded_urls <- unique((longurl::expand_urls(short_urls)))

# Join longurls back to original dataset and replace if a longurl is available
url_df <- dplyr::left_join(submission_df,expanded_urls, by = c("urls_expanded_url" = "orig_url"))
submission_df$urls <- ifelse(!is.na(url_df$expanded_url),url_df$expanded_url,url_df$urls_expanded_url)

# remove links not to tableau public
submission_df <- submission_df %>% filter(grepl('public.tableau',urls))

# links to vizzes will include either "views", "app/profile" or "vizhome"
submission_df <- submission_df %>% filter(grepl('(views)|(app\\/profile)|(vizhome)',urls))

# extract workbook & view name from URL to make image URL
submission_df$workbook_and_view_name <- str_extract(submission_df$urls,'views\\/.*|viz\\/.*|vizhome\\/.*')

# Clean up workbook & view name URL
# remove views/, viz/, vizhome/ from front of string
submission_df$workbook_and_view_name <- gsub("^views/|^viz/|^vizhome/","",submission_df$workbook_and_view_name)

# remove any trailing characters after & including "?", e.g. '?publish=yes'
submission_df$workbook_and_view_name <- gsub("\\?.*$","",submission_df$workbook_and_view_name)

# create viz image
submission_df$viz_image <- paste0('https://public.tableau.com/views/',submission_df$workbook_and_view_name,'.png?%3Adisplay_static_image=y&:showVizHome=n')

# reducing submissions to tweet and image URLs
submission_df <- submission_df[,c('tweet_url','viz_image')]

# create the html code to show the image and link to the submission tweet
submission_df$img_and_tweet_link <- paste0("<a href='",submission_df$tweet_url,"'>
                                           <img src='",submission_df$viz_image,"'>
                                           </a>")

# for creating creating data frame of excluded tweets
remaining_df <- filter(df,df$tweet_url %not in% submission_df$tweet_url)

# write data frames to csv
write.csv(submission_df,"data/ironviz_submissions.csv",row.names = F)
write.csv(remaining_df,"data/ironviz_non_submissions.csv",row.names = F)

#### Step 3: build the HTML page

source("R/update_html_files.R")

# check the file: 'gallery/ironviz.html' has been updated (via a browsers like Chrome)
# then upload it to a blog, Amazon S3 bucket, or static website hosting service
# you'll need to re-upload this file with each update.
