pacman::p_load(snippet, dplyr, rvest, purrr, tidyr, tidyverse, magrittr, editrules, deducorrect, VIM, tidyquant, wbstats, jsonlite, stringr)

# scrap the grades only on the first page
reviews = "https://www.metacritic.com/game/switch/animal-crossing-new-horizons/user-reviews"
reviews %>% read_html() %>% html_nodes("div.review_grade") %>% html_text() %>% data.frame()-> grades

# prepare to the loop, set the pages first
pages = seq(1, 31, 1) # the end page is 31 because there are 31 pages in total
# set the matrix to 1 because we only need the grades now
dfgrades = matrix(ncol = 1) %>% data.frame()
colnames(dfgrades) = colnames(grades)

# start to loop
for (i in 1:length(pages)){
  reviewsURL = paste("https://www.metacritic.com/game/switch/animal-crossing-new-horizons/user-reviews?page=", pages[i], sep = "")
  reviewsURL %>% read_html() %>% html_nodes("div.review_grade") %>% html_text() %>% data.frame() -> grades
  dfgrades = rbind(dfgrades, grades)
}
# set the colnames to grades
colnames(dfgrades) = "Grades" 
# change the data type to numbers
dfgrades$Grades = dfgrades$Grades %>% as.numeric()
dfgrades = dfgrades %>% data.frame()
# delete the value larger than 10 because the max points that the regular users can give is 10(the critics can give an 80 or 90 to the game btw)
deleteRow = which(dfgrades$Grades > 10)
dfgrades = dfgrades[-deleteRow,]
dfgrades = dfgrades[-1,]
dfgrades = dfgrades %>% data.frame()


# repeat what we have done, but now I need the reviews(words)
# the nodes is longer in this part because I want to exclude the reviews by the crtics now, which would be hard for me to exclude that later
reviews %>% read_html() %>% html_nodes("#main > div.partial_wrap > div.module.reviews_module.user_reviews_module > div > ol >li > div > div > div > div > div > div:nth-child(1) > div.review_body") %>% html_text() %>% data.frame() -> userReviews
# create a new data frame to record the reviews
dfreviews = matrix(ncol = 1) %>% data.frame()
# set the colname of the df
colnames(dfreviews) = colnames(userReviews)
View(dfgrades)
# start to loop
for (i in 1:length(pages)){
  reviewsURL = paste("https://www.metacritic.com/game/switch/animal-crossing-new-horizons/user-reviews?page=", pages[i], sep = "")
  reviewsURL %>% read_html() %>% html_nodes("#main > div.partial_wrap > div.module.reviews_module.user_reviews_module > div > ol >li > div > div > div > div > div > div:nth-child(1) > div.review_body") %>% html_text() %>% data.frame() -> userReviews
  dfreviews = rbind(dfreviews, userReviews)
}
# set the colnames to Reviews
colnames(userReviews) = "Reviews"
dfreviews = dfreviews[-1,]
dfreviews = dfreviews %>% data.frame()

summary(is.na(dfreviews))

# combine both df togather
userR = cbind(dfgrades, dfreviews)

# export
write.csv(userR, "F:\\Senior Spring\\ISA 401\\ACNH\\user reviews.csv", row.names = TRUE)
