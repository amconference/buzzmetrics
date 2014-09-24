Buzzmetrics
===========

Stage 1:
  * Collect title and AM score
  * output: CSV: doi,title,score,tweetcount,...

Stage 2: Sanitisation / filtering
  * input: CSV as per stage 1
  * ouput: CSV as per stage 1, minus duplicates, spam, unparsables etc

Stage 3: Analysis
  * input: CSV from stage 2
  * output: CSV doi,x
    * where x will depend on the feature being analysed

Stage 4: Regression
  * input: CSVs from stage 3
  * output: t.b.c
    * Currently publishing to http://rpubs.com/jdleesmiller/30864
