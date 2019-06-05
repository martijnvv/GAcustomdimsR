# GA custom dimension export to Excel with R
Using the googleanalyticsR and writexl R package, I pull all the data from a Google Analytics view.
It exports all the data in a summarised tab, and each custom dimension is also exported to each own Excel tab.

![summary output tab in export](https://github.com/martijnvv/GAcustomdimsR/blob/master/customdims.PNG)

## Output in Excel

The script returns several tabs in the Excel:
* Summary tab with a list of all custom dimensions with their names, scope, number of results, creation date, last update date
* Summary of custom dimensions with zero results (including creation date, update date, etc.)
* A tab for each custom dimension, returning metrics (users, sessions, pageviews, total events) for each value. 

## Usecases

This has been helpful to me for several usecases:
* Validation of dataquality
* Startingpoint of basic analysis and/or reporting
