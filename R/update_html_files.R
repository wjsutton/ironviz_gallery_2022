submission_df <- read.csv('data/ironviz_submissions.csv',stringsAsFactors = F)

# randomise vizzes
ironviz_links <- sample(submission_df$img_and_tweet_link
                        ,length(submission_df$img_and_tweet_link))

number_of_vizzes <- length(submission_df$img_and_tweet_link)

# Update html files

# Write list of images to a text file for now
fileConn <- file("html/img_list.txt")
writeLines(ironviz_links, fileConn)
close(fileConn)

blurb_temp_file <- file("html/blurb_template.txt")
blurb <- readLines(blurb_temp_file)
blurb <- gsub('NUM_OF_VIZZES',number_of_vizzes,blurb)

blurb_file <- file("html/blurb.txt")
writeLines(blurb, blurb_file)
close(blurb_file)
close(blurb_temp_file)

# create full html
header_file <- file("html/header.txt")
blurb_file <- file("html/blurb.txt")
images_file <- file("html/img_list.txt")
footer_file <- file("html/footer.txt")

header <- readLines(header_file)
blurb <- readLines(blurb_file)
images <- readLines(images_file)
footer <- readLines(footer_file)

full_html <- c(header,blurb,images,footer)

html_file <- file("gallery/ironviz.html")
writeLines(full_html, html_file)
close(html_file)
