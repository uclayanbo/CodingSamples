library(readr)
library(tidyr)
library(dplyr)

## Read in dataset
newspapers <- read_delim("newspapers.txt", "\t", escape_double = FALSE, trim_ws = TRUE)

## This "headquarter" data frame is an index for the purpose of finding out which
## newspaper is headquartered in which county, using countycode and newspaper ID
headquarter <- aggregate(dailycirc ~ membernumber, data = newspapers, FUN = "max")

## Initialize a vector of the length of "headquarter" index.
## This vector will contain headquarter counties in the next step
stcntyfp_1 <- rep(1, nrow(headquarter))

## Use newspaper ID and its highest countywide circulation to match the countycode of
## its headquarter
for (i in 1:nrow(headquarter)) {
  stcntyfp_1[i] <- newspapers$stcntyfp[newspapers$membernumber==headquarter$membernumber[i]
                               & newspapers$dailycirc==headquarter$dailycirc[i]]
}

## Add the headquarter countycode into the index
headquarter$stcntyfp_1 <- stcntyfp_1

## This data frame is where the final output comes from. It is just a copy of the original
## "newspapers" file, to prevent messing up the original dataset
sum_index <- cbind(newspapers, rep(1, nrow(newspapers)))

## Rename the variables
names(sum_index) <- c("membernumber","newspaper","stcntyfp_2","cnty_2","state_2",
                      "dailycirc","stcntyfp_1")

## Match every newspaper ID with its headquarter counties
## Now this dataset contains all headquarter-county pairs but has not yet been summed up
for (i in headquarter$membernumber) {
  sum_index$stcntyfp_1[sum_index$membernumber==i] <- headquarter$stcntyfp_1[headquarter$membernumber==i]
}

## Sum daily circulation across headquarters and counties which
## newspapers are circulated in
output <- aggregate(dailycirc ~ stcntyfp_1 + stcntyfp_2, data = sum_index, FUN = sum)

## Match all the states and county names for headquarters and counties where newspapers
## are circulated in.
output$cnty_1 <- rep(1, nrow(output))
output$cnty_2 <- rep(1, nrow(output))
output$state_1 <- rep(1, nrow(output))
output$state_2 <- rep(1, nrow(output))

## Here I use unique() to avoid refering to multiple entries with the same countycode
for (i in unique(output$stcntyfp_1)) {
  output$cnty_1[output$stcntyfp_1==i] <- unique(newspapers$cnty[newspapers$stcntyfp==i])
  output$state_1[output$stcntyfp_1==i] <- unique(newspapers$state[newspapers$stcntyfp==i])
}
for (i in unique(output$stcntyfp_2)) {
  output$cnty_2[output$stcntyfp_2==i] <- unique(newspapers$cnty[newspapers$stcntyfp==i])
  output$state_2[output$stcntyfp_2==i] <- unique(newspapers$state[newspapers$stcntyfp==i])
}

## Rearrange and sort the final output
output <- output[,c("stcntyfp_1","cnty_1","state_1","stcntyfp_2","cnty_2","state_2",
                    "dailycirc")]
output <- arrange(output, stcntyfp_1, stcntyfp_2)

## final output
write_csv(output, "circulation.csv")
