library(rtweet)

get_and_save_tweets <- function(text,count,path){
  # Get Tweets
  tweets <- rtweet::search_tweets(
    text, n = count, include_rts = FALSE
  )
  
  # Check if a file exists
  if(file.exists(paste0(path,"/",text,"_tweets.RDS"))){
    old_tweets <- readRDS(paste0(path,"/",text,"_tweets.RDS")
    )
    new_tweet_ids <- tweets$status_id
    previous_tweets <- subset(old_tweets, !(status_id %in% new_tweet_ids))
    
    if(nrow(previous_tweets)>0){
      tweets <- rbind(tweets,previous_tweets)
    }
  }
  saveRDS(tweets,paste0(path,"/",text,"_tweets.RDS"))
}
