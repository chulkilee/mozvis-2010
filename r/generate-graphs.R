#!/usr/bin/env Rscript
library(ggplot2)

source(file="r/load-csv.R")

attach(d)

################################################################################
# I. how demographic distribution
################################################################################

# gender
g <- ggplot(d, aes(gender))
g <- g + geom_histogram(aes(fill=gender)) + stat_bin(aes(label=..count..), vjust=0, geom="text", position="identity")
g <- g + opts(title = "Gender", legend.position="none")
g <- g + xlab("Gender")
ggsave("graphs/survey/gender.png", g)

# age
g <- ggplot(d, aes(age))
g <- g + geom_histogram(aes(fill=age)) + stat_bin(aes(label=..count..), vjust=0, geom="text", position="identity")
g <- g + opts(title = "Age", legend.position="none")
g <- g + xlab("Age")
ggsave("graphs/survey/age.png", g)

# time_on_web
g <- ggplot(d, aes(time_on_web))
g <- g + geom_histogram(aes(fill=time_on_web)) + stat_bin(aes(label=..count..), vjust=0, geom="text", position="identity")
g <- g + opts(title = "Time on web", legend.position="none")
g <- g + xlab("Time on web")
ggsave("graphs/survey/time_on_web.png", g)

# fx_use
g <- ggplot(d, aes(fx_use))
g <- g + geom_histogram(aes(fill=fx_use)) + stat_bin(aes(label=..count..), vjust=0, geom="text", position="identity")
g <- g + opts(title = "Firefox experience", legend.position="none")
g <- g + xlab("Firefox experience")
ggsave("graphs/survey/fx_use.png", g)

# other_browser_use
g <- ggplot(d, aes(other_browser_use))
g <- g + geom_histogram(aes(fill=other_browser_use)) + stat_bin(aes(label=..count..), vjust=0, geom="text", position="identity")
g <- g + opts(title = "Other browser", legend.position="none")
g <- g + xlab("Other browser")
ggsave("graphs/survey/other_browser_use.png", g)

# primary_browser
g <- ggplot(d, aes(primary_browser))
g <- g + geom_histogram(aes(fill=primary_browser)) + stat_bin(aes(label=..count..), vjust=0, geom="text", position="identity")
g <- g + opts(title = "Primary browser", legend.position="none")
g <- g + xlab("Primary browser")
ggsave("graphs/survey/primary_browser.png", g)

################################################################################
# II. Questions
################################################################################

g <- ggplot(d, aes(bookmark_use_ratio)) + scale_x_log10()
g <- g + geom_histogram() + stat_bin(aes(label=..count..), vjust=0, geom="text", position="identity")
g <- g + opts(title = "Bookmark use ratio")
g <- g + xlab("Bookmark use ratio")
ggsave("graphs/etc/bookmark_use_ratio.png", g)

################################################################################
# Q1. Active bookmark users have less organization efforts
# (less bookmarks? less folders? less max_depth?)
################################################################################


# folder_max_depth ~ bookmark_use_ratio
corr <- cor(folder_max_depth, bookmark_use_ratio) # -0.201031
g <- ggplot(d, aes(folder_max_depth, bookmark_use_ratio))
g <- g + geom_point(alpha=1/5)
g <- g + opts(title = "How Firefox Users Use Bookmarks")
g <- g + xlab("Max depth of folders") + ylab("Bookmark use ratio")
ggsave("graphs/q1/folder_max_depth-vs-bookmark_use_ratio.png", g)

## subset & recode
d_folder_max <- subset(d, round(folder_max_depth) < 6)
d_folder_max$folder_max_depth <- factor(round(d_folder_max$folder_max_depth))

g <- ggplot(d_folder_max, aes(folder_max_depth, bookmark_use_ratio)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=folder_max_depth)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "How Firefox Users Use Bookmarks", legend.position="none")
g <- g + xlab("Max depth of folders") + ylab("Bookmark use ratio")
ggsave("graphs/q1/folder_max_depth-vs-bookmark_use_ratio(log)-boxplot.png", g)

# folders ~ bookmark_use_ratio
corr <- cor(folders, bookmark_use_ratio) # -0.1294575
ggplot(d, aes(folders, bookmark_use_ratio)) + geom_point(alpha=1/5) + scale_x_log10()

## subset & recode
d_folders <- subset(d, round(log(folders)) > -1)
d_folders <- subset(d_folders, round(log(folders)) < 7)

d_folders$folders_cat <- 0
d_folders$folders_cat[d_folders$folders > 10] <- 1
d_folders$folders_cat[d_folders$folders > 100] <- 2
d_folders$folders_cat <- factor(d_folders$folders_cat, labels=c("0-10", "10-100", ">100"))

g <- ggplot(d_folders, aes(folders_cat, bookmark_use_ratio)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=folders_cat)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "How Firefox Users Use Bookmarks", legend.position="none")
g <- g + xlab("# of folders") + ylab("Bookmark use ratio")
ggsave("graphs/q1/folders-vs-bookmark_use_ratio(log)-boxplot.png", g)

# bookmarks ~ bookmark_use_ratio
corr <- cor(bookmarks, bookmark_use_ratio) # -0.1019514
ggplot(d, aes(bookmarks, bookmark_use_ratio)) + geom_point(alpha=1/5) + scale_x_log10()

## subset & recode
d_bookmarks <- subset(d, round(log(bookmarks)) < 9)

d_bookmarks$bookmarks_cat <- 0
d_bookmarks$bookmarks_cat[d_bookmarks$bookmarks > 10] <- 1
d_bookmarks$bookmarks_cat[d_bookmarks$bookmarks > 100] <- 2
d_bookmarks$bookmarks_cat[d_bookmarks$bookmarks > 1000] <- 3
d_bookmarks$bookmarks_cat <- factor(d_bookmarks$bookmarks_cat, labels=c("0-10", "10-100", "100-1000", ">1000"))

g <- ggplot(d_bookmarks, aes(bookmarks_cat, bookmark_use_ratio)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=bookmarks_cat)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "How Firefox Users Use Bookmarks", legend.position="none")
g <- g + xlab("# of Bookmarks") + ylab("Bookmark use ratio")
ggsave("graphs/q1/bookmarks-vs-bookmark_use_ratio(log)-boxplot.png", g)

################################################################################
# Q1-b. high_bookmark_use_ratio ~ ?
################################################################################

# high_bookmark_use_ratio ~ folder_max_depth
g <- ggplot(d, aes(high_bookmark_use_ratio, folder_max_depth))
g <- g + geom_boxplot(aes(fill=high_bookmark_use_ratio)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Bookmark use ratio - Max depth of folders", legend.position="none")
g <- g + xlab("Bookmark use ratio") + ylab("Max depth of folders")
ggsave("graphs/q1/high_bookmark_use_ratio-vs-folder_max_depth-boxplot.png", g)

# high_bookmark_use_ratio ~ olders
g <- ggplot(d, aes(high_bookmark_use_ratio, folders)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=high_bookmark_use_ratio)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Bookmark use ratio - # of folders", legend.position="none")
g <- g + xlab("Bookmark use ratio") + ylab("# of folders")
ggsave("graphs/q1/high_bookmark_use_ratio-vs-folders(log)-boxplot.png", g)

# high_bookmark_use_ratio ~ bookmarks
g <- ggplot(d, aes(high_bookmark_use_ratio, bookmarks)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=high_bookmark_use_ratio)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Bookmark use ratio - # of bookmarks", legend.position="none")
g <- g + xlab("Bookmark use ratio") + ylab("# of bookmarks")
ggsave("graphs/q1/high_bookmark_use_ratio-vs-bookmarks(log)-boxplot.png", g)

g <- ggplot(d, aes(bookmarks, folders)) + scale_y_log10() + scale_x_log10()
g <- g + geom_point(alpha=1/3, aes(color=high_bookmark_use_ratio))
g <- g + opts(title = "# of bookmarks - # of folders", legend.position="none")
g <- g + xlab("# of bookmarks") + ylab("# of folders")
ggsave("graphs/q1/bookmarks(log)-vs-folders(log)-color-high_bookmark_use_ratio.png", g)

################################################################################
# Q2. fx_use ~ ?
################################################################################

# To hide NA
d_fx_use <- subset(d, fx_use != 'NA')

# fx_use ~ folders
corr <- cor(r_fx_use, folders, use="pairwise.complete.obs") #
g <- ggplot(d_fx_use, aes(fx_use, folders)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of folders", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of folders")
ggsave("graphs/q2/fx_use-vs-folders(log).png", g)

# fx_use ~ num_tabs
corr <- cor(r_fx_use, num_tabs, use="pairwise.complete.obs") #
g <- ggplot(d_fx_use, aes(fx_use, num_tabs)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of tabs", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of tabs")
ggsave("graphs/q2/fx_use-vs-num_tabs(log).png", g)

# fx_use ~ bookmarks
corr <- cor(r_fx_use, bookmarks, use="pairwise.complete.obs") #
g <- ggplot(d_fx_use, aes(fx_use, bookmarks)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of bookmarks", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of bookmarks")
ggsave("graphs/q2/fx_use-vs-bookmarks(log).png", g)

# fx_use ~ bookmarks
corr <- cor(r_fx_use, bookmarks, use="pairwise.complete.obs") #
g <- ggplot(d_fx_use, aes(fx_use, bookmarks)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of bookmarks", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of bookmarks")
ggsave("graphs/q2/fx_use-vs-bookmarks(log).png", g)

# fx_use ~ bookmark_choose
corr <- cor(r_fx_use, bookmark_choose, use="pairwise.complete.obs") #
g <- ggplot(d_fx_use, aes(fx_use, bookmark_choose)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of bookmark_choose", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of bookmark_choose")
ggsave("graphs/q2/fx_use-vs-bookmark_choose(log).png", g)

# fx_use ~ bookmark_use_ratio
corr <- cor(r_fx_use, bookmark_use_ratio, use="pairwise.complete.obs") #
g <- ggplot(d_fx_use, aes(fx_use, bookmark_use_ratio)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - Bookmark use ratio", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("Bookmark use ratio")
ggsave("graphs/q2/fx_use-vs-bookmark_use_ratio(log).png", g)

# fx_use ~ private_on_records
corr <- cor(r_fx_use, private_on_records, use="pairwise.complete.obs") #
g <- ggplot(d_fx_use, aes(fx_use, private_on_records)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of private mode on", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of private mode on")
ggsave("graphs/q2/fx_use-vs-private_on_records(log).png", g)

################################################################################
# Q1-b. long_fx_use ~ ?
################################################################################

# long_fx_use ~ folders
g <- ggplot(d_fx_use, aes(long_fx_use, folders)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=long_fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of folders", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of folders")
ggsave("graphs/q2/long_fx_use-vs-folders(log).png", g)

# long_fx_use ~ num_tabs
g <- ggplot(d_fx_use, aes(long_fx_use, num_tabs)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=long_fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of tabs", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of tabs")
ggsave("graphs/q2/long_fx_use-vs-num_tabs(log).png", g)

# long_fx_use ~ bookmarks
g <- ggplot(d_fx_use, aes(long_fx_use, bookmarks)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=long_fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of bookmarks", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of bookmarks")
ggsave("graphs/q2/long_fx_use-vs-bookmarks(log).png", g)

# long_fx_use ~ bookmark_choose
g <- ggplot(d_fx_use, aes(long_fx_use, bookmark_choose)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=long_fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of bookmark_choose", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of bookmark_choose")
ggsave("graphs/q2/long_fx_use-vs-bookmark_choose(log).png", g)

# long_fx_use ~ bookmark_use_ratio
g <- ggplot(d_fx_use, aes(long_fx_use, bookmark_use_ratio)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=long_fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - Bookmark use ratio", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("Bookmark use ratio")
ggsave("graphs/q2/long_fx_use-vs-bookmark_use_ratio(log).png", g)

# long_fx_use ~ private_on_records
g <- ggplot(d_fx_use, aes(long_fx_use, private_on_records)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=long_fx_use)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Firefox experience - # of private mode on", legend.position="none")
g <- g + xlab("Firefox experience") + ylab("# of private mode on")
ggsave("graphs/q2/long_fx_use-vs-private_on_records(log).png", g)

################################################################################
# ETC
################################################################################

corr <- cor(r_age, num_tabs, use="pairwise.complete.obs") #
g <- ggplot(d, aes(age, num_tabs)) + scale_y_log10()
g <- g + geom_boxplot(aes(fill=age)) + geom_jitter(alpha=1/5)
g <- g + opts(title = "Age - # of tabs", legend.position="none")
g <- g + xlab("Age") + ylab("# of tabs")
ggsave("graphs/etc/age-vs-num_tabs(log).png", g)

corr <- cor(num_tabs, bookmarks, use="pairwise.complete.obs") #
g <- ggplot(d, aes(num_tabs, bookmarks)) + scale_x_log10()
g <- g + geom_point(alpha=1/2, aes(color=age)) + facet_grid(age ~.) 
g <- g + opts(title = "# of tabs - # of bookmarks")
g <- g + xlab("# of tabs") + ylab("# of bookmarks")
ggsave("graphs/etc/num_tabs(log)-vs-bookmarks(log)-by-age-color-age.png", g)

detach(d)
