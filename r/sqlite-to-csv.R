#!/usr/bin/env Rscript
# Load sqlite file and export aggregated data to csv
#
# Input: witl.db
# Output:
# - csv/users.csv: all users
# - csv/d.csv: 
# - csv/dh.csv: by hour
# - csv/dw.csv: by week
#
# Schema of witl.db:
# https://testpilot.mozillalabs.com/testcases/a-week-life-2/aggregated-data.html

library(RSQLite)

# Connect to database
conn <- dbConnect("SQLite", "witl.db")

################################################################################
# d: data by user
################################################################################

################################################################################
# d: add users
################################################################################
users <- dbGetQuery(conn, "
  SELECT
    id AS user_id,
    os,
    fx_version,
    version AS pilot_ver,
    number_extensions AS num_extensions
  FROM users
;")
d <- users
write.csv(users, file="csv/users.csv")

################################################################################
# d: add survey
################################################################################

# TODO multiple answers with free-text: q3, q9, q10, q11, q12, q13
survey <- dbGetQuery(conn, "
  SELECT
    user_id,
    CAST(q1 AS INTEGER) AS r_fx_use,
    CAST(q2 AS INTEGER) AS r_other_browser_use,
    CAST(q4 AS INTEGER) AS r_primary_browser,
    CAST(q5 AS INTEGER) AS r_gender,
    CAST(q6 AS INTEGER) AS r_age, 
    CAST(q7 AS INTEGER) AS r_time_on_web,
    CAST(q8 AS INTEGER) AS skill,
    q3 AS other_browser,
    q9 AS r_place,
    q10 AS smartphone,
    q11 AS reason_web_use,
    q12 AS freq_website,
    q13 AS news
  FROM survey
;")
d <- merge(d, survey)
remove(survey)

################################################################################
# d: add BOOKMARK_STATUS (8)
################################################################################

bookmark_stats <- dbGetQuery(conn, "
  SELECT
    user_id,
    AVG(CAST(data1 AS INTEGER)) AS bookmarks,
    AVG(CAST(data2 AS INTEGER)) AS folders,
    AVG(CAST(SUBSTR(data3, 14) AS INTEGER)) AS folder_max_depth,
    MIN(timestamp) AS bookmark_status_first,
    MAX(timestamp) AS bookmark_status_last,
    COUNT(timestamp) AS bookmark_status_records
  FROM events
  WHERE event_code = 8
  GROUP BY user_id
;")
d <- merge(d, bookmark_stats)
remove(bookmark_stats)

################################################################################
# d: add BOOKMARK_CHOOSE (10)
################################################################################

bookmark_choose_stats <- dbGetQuery(conn, "
  SELECT
    user_id,
    MIN(timestamp) AS bookmark_choose_first,
    MAX(timestamp) AS bookmark_choose_last,
    COUNT(timestamp) AS bookmark_choose
  FROM events
  WHERE event_code = 10
  GROUP BY user_id
;")
d <- merge(d, bookmark_choose_stats)
remove(bookmark_choose_stats)

################################################################################
# d: add HISTORY_STATUS (23)
################################################################################
history_stats <- dbGetQuery(conn, "
  SELECT
    user_id,
    AVG(CAST(data1 AS INTEGER)) AS history_items,
    MIN(timestamp) AS history_status_first,
    MAX(timestamp) AS history_status_last,
    COUNT(timestamp) AS history_status_records
  FROM events
  WHERE event_code = 23
  GROUP BY user_id
;")
d <- merge(d, history_stats)
remove(history_stats)

################################################################################
# d: add NUM_TABS (26)
################################################################################

num_of_tabs <- dbGetQuery(conn, "
  SELECT
    user_id,
    AVG(CAST(data1 AS INTEGER)) AS num_windows,
    AVG(CAST(data2 AS INTEGER)) AS num_tabs,
    COUNT(timestamp) AS num_tabs_records
  FROM events
  WHERE event_code = 26
  GROUP BY user_id
;")
d <- merge(d, num_of_tabs)
remove(num_of_tabs)

################################################################################
# d: add MEMORY_USAGE (19)
################################################################################

# memory_usage <- dbGetQuery(conn, "
#   SELECT
#     user_id,
#     AVG(CAST(data2 AS INTEGER))/1024 as kbytes
#   FROM events
#   WHERE event_code = 19
#   GROUP BY user_id
# ;")
# d <- merge(d, memory_usage)

################################################################################
# d: add PRIVATE_ON (17)
################################################################################
private_users_stats <- dbGetQuery(conn, "
  SELECT
    user_id,
    MIN(timestamp) AS private_on_first,
    MAX(timestamp) AS private_on_last,
    COUNT(timestamp) AS private_on_records
  FROM events
  WHERE event_code = 17
  GROUP BY user_id
;")
d <- merge(d, private_users_stats)
remove(private_users_stats)

################################################################################
# d: add PROFILE_AGE (24)
################################################################################
profile_age_stats <- dbGetQuery(conn, "
  SELECT
    user_id,
    MIN(DATE(CAST(data1 AS INTEGER)/1000, 'unixepoch')) AS profile_age_oldest,
    MIN(timestamp) AS profile_age_first,
    MAX(timestamp) AS profile_age_last,
    COUNT(timestamp) AS profile_age_records
  FROM events
  WHERE event_code = 24
  GROUP BY user_id
;")
d <- merge(d, profile_age_stats)
remove(profile_age_stats)

write.csv(d, file="csv/d.csv")


################################################################################
# dw: data by weekday
################################################################################

bookmark_choose_stats_wd <- dbGetQuery(conn, "
  SELECT
    CAST(strftime('%w', DATE(timestamp/1000, 'unixepoch')) AS INTEGER) AS r_wd,
    COUNT(timestamp) AS bookmark_choose_wd
  FROM events
  WHERE event_code = 10
  GROUP BY r_wd
;")
dw <- bookmark_choose_stats_wd
remove(bookmark_choose_stats_wd)

num_of_tabs_wd <- dbGetQuery(conn, "
  SELECT
    CAST(strftime('%w', DATE(timestamp/1000, 'unixepoch')) AS INTEGER) AS r_wd,
    AVG(CAST(data1 AS INTEGER)) AS num_windows_wd,
    AVG(CAST(data2 AS INTEGER)) AS num_tabs_wd
  FROM events
  WHERE event_code = 26
  GROUP BY r_wd
;")
dw <- merge(dw, num_of_tabs_wd)
remove(num_of_tabs_wd)

write.csv(dw, file="csv/dw.csv")

################################################################################
# dh: data by hour (0-23)
################################################################################

bookmark_choose_stats_h24 <- dbGetQuery(conn, "
  SELECT
    CAST(strftime('%H', DATETIME(timestamp/1000, 'unixepoch')) AS INTEGER) AS h24,
    COUNT(timestamp) AS bookmark_choose_h24
  FROM events
  WHERE event_code = 10
  GROUP BY h24
;")
dh <- bookmark_choose_stats_h24
remove(bookmark_choose_stats_h24)

num_of_tabs_h24 <- dbGetQuery(conn, "
  SELECT
    CAST(strftime('%H', DATETIME(timestamp/1000, 'unixepoch')) AS INTEGER) AS h24,
    AVG(CAST(data1 AS INTEGER)) AS num_windows_h24,
    AVG(CAST(data2 AS INTEGER)) AS num_tabs_h24
  FROM events
  WHERE event_code = 26
  GROUP BY h24
;")
dh <- merge(dh, num_of_tabs_h24)
remove(num_of_tabs_h24)

write.csv(dh, file="csv/dh.csv")
