library(stringr)
library(tidyverse)
library(lubridate)


#get each data frame from 1987 to 2016
url1 <- "http://www.ndbc.noaa.gov/view_text_file.php?filename=mlrf1h"
url2 <- ".txt.gz&dir=data/historical/stdmet/"

years <- c(1987:2016)

urls <- str_c(url1, years, url2, sep ="")

filenames <- str_c("mr", years, sep = "")

N <- length(urls)


for (i in 1:N){
  suppressMessages(
    assign(filenames[i], read.table(urls[i], header = TRUE,fill = T))
  )
  file <- get(filenames[i])
  
}

# add 19 in front of year
for (i in 1:12){
  file <- get(filenames[i])
  file$YY <- file$YY +1900
  assign(filenames[i],file)
}

#throw out the last column
for (i in 14:18){
  file <- get(filenames[i])
  assign(filenames[i],file[,1:16])
}

#throw out the "mm" column and the lasr column
for (i in 19:30){
  file <- get(filenames[i])
  assign(filenames[i],file[,c(1:4,6:17)])
}

#combine all the data frame and unify the column name
for (i in 1:30){
  file <- get(filenames[i])
  
  colnames(file) <- c("YYYY", "MM", "DD", "hh", "WD", "WSPD", "GST", "WVHT", "DPD", "APD", "MWD", "BAR", "ATMP", "WTMP", "DEWP", "VIS")
  
  if(i==1){
    MR <- file
  }
  else{
    MR <- rbind.data.frame(MR, file)
  }
}

#select columns that are not 99, 999
MR <- MR[,c(1:7,12:14)]

#filter rows that ATMP and WTMP are larger than 100
MR <- filter(MR,MR$ATMP<100&MR$WTMP<100)

write.csv(MR,"MR.csv")

#combine all the time into one column using lubridate package
MR_DATE <- MR %>%
  mutate(DATETIME = make_datetime(YYYY,MM,DD,hh))

#change the order of each column, put the time into first place.
MR_DATE <- MR_DATE[,5:11]
cols <- colnames(MR_DATE)
new_cols <- c(cols[7],cols[1:6])
MR_DATE <- MR_DATE[,new_cols]

write.csv(MR_DATE,"MR_DATE.CSV")