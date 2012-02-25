# How Do People Use Bookmarks?

This work is a result by [Chulki Lee](http://www.ischool.berkeley.edu/people/students/chulkilee) and [Travis Yoo](http://www.ischool.berkeley.edu/people/students/travisyoo) for [Mozilla Open Data Visualization Competition: How Do People Use Firefox?](http://design-challenge.mozillalabs.com/open-data/OpenDataCompetition.php).

Most parts are unchanged, except following changes.

- Regenerated All CSV files and graphs
- Add comments on R files
- Use the latest version of [HTML5 Reset](http://html5reset.org/)

## How to reproduce data

1. Download data from [A Week in the Life of a Browser - Version 2: Aggregated Data Samples](https://testpilot.mozillalabs.com/testcases/a-week-life-2/aggregated-data.html)

    wget https://testpilot.mozillalabs.com/testcases/a-week-life-2/witl.db.gz
    gunzip witl.db.gz

2. Generate csv files at csv/*.csv from sqlite db
    ./r/sqlite-to-csv.R

3. Generate graphs at graphs/*
    ./r/generate-graphs.R
