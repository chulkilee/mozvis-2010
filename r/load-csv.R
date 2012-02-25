#!/usr/bin/env Rscript

# Load files
d <- read.csv(file="csv/d.csv")
dw <- read.csv(file="csv/dw.csv")
dh <- read.csv(file="csv/dh.csv")

# Recode d
d$fx_use <- factor(d$r_fx_use, labels=c("<3M", "3-6M", "6-12M", "1-2yr", "2-3yr", "3-5yr", ">5yr"))
d$other_browser_use <- factor(d$r_other_browser_use, labels=c("Only FF", "More"))
d$primary_browser <- factor(d$r_primary_browser, labels=c("Only FF", "FF", "Chrome", "Safari", "Opera", "IE"))
d$gender <- factor(d$r_gender, labels=c("Male", "Female"))
d$age <- factor(d$r_age, labels=c("<18", "18-25", "26-35", "36-45", "46-55", ">55"))
d$time_on_web <- factor(d$r_time_on_web, labels=c("<1", "1-2", "2-4", "4-6", "6-8", "8-10", "> 10"))

# Recode place: [Home, Work, School, Mobile]
# If you want to include "0|<freeform-text removed>" as answer "0",
# use conditions like [grep("^0(\\|<freeform-text removed>)?$", d$r_place)]

d$place <- "Other"
d$place[d$r_place == "0"] <- "H"
d$place[d$r_place == "0|1"] <- "H,W"
d$place[d$r_place == "0|1|2"] <- "H,W,S"
d$place[d$r_place == "0|1|2|3"] <- "H,W,S,M"
d$place[d$r_place == "0|2"] <- "H,S"
d$place[d$r_place == "0|2|3"] <- "H,S,M"
d$place[d$r_place == "0|3"] <- "H,M"
# table(d$place, d$r_place)

# Recode dw
dw$wd <- factor(dw$r_wd, labels=c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"))

################################################################################
# New variables
################################################################################

d$bookmark_use_ratio <- (d$bookmark_choose / d$bookmarks)
d$bookmarks_in_folder_ratio <- (d$bookmarks / d$folders)

################################################################################
# Groups
################################################################################

d$many_folders <- 0
d$many_folders[d$folders > 28] <- 1
d$many_folders <- factor(d$many_folders, labels=c("<= 28", "> 28"))

d$many_bookmarks <- 0
d$many_bookmarks[d$bookmarks > 75] <- 1
d$many_bookmarks <- factor(d$many_bookmarks, labels=c("<= 75", "> 75"))

d$many_history_items <- 0
d$many_history_items[d$history_items > 7429] <- 1 # 7429 -> median
d$many_history_items <- factor(d$many_history_items, labels=c("<= 7429", "> 7429"))

d$much_time_on_web <- 0
d$much_time_on_web[d$r_time_on_web > mean(d$r_time_on_web, na.rm=TRUE)] <- 1
d$much_time_on_web <- factor(d$much_time_on_web, labels=c("<= mean", "> mean"))

d$long_fx_use <- 0
d$long_fx_use[d$r_fx_use > 5] <- 1
d$long_fx_use <- factor(d$long_fx_use, labels=c("<= 5", "> 5"))

d$high_bookmark_use_ratio <- 0
d$high_bookmark_use_ratio[d$bookmark_use_ratio > 0.75] <- 1
d$high_bookmark_use_ratio <- factor(d$high_bookmark_use_ratio, labels=c("<= 0.75", "> 0.75"))
