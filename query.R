# load required libraries -------------------------------------------------
library("googleAnalyticsR")
library("writexl")

options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/analytics.readonly")
ga_auth("readonly.oauth")

Sys.Date() - 1 -> dateEnd
dateEnd - 7 -> dateStart

accountId <- "INSERT_GA_ACCOUNT_ID"
viewId <- "INSERT_GA_VIEW_ID" 
uaId <- "INSERT_GA_PROFILE_ID"

# Get custom dimension information ----------------------------------------
ga_custom_vars_list(accountId, webPropertyId = uaId, type = "customDimensions") -> cd_index

# Return all active custom dimensions -------------------------------------
cd_index <- cd_index[ which(cd_index$active==TRUE), ]
unique(cd_index$index) -> dimensions

# Query all custom dimensions that are configured and enabled -------------
for(i in dimensions){
df <- google_analytics(viewId, 
                       date_range = c(dateStart, dateEnd),
                       dimensions=c(paste0("dimension",i)), 
                       metrics = c("users","sessions","pageviews", "totalEvents"),
                       max = 10000)
assign(paste0("dimension", i), df)
print(paste0("finished with custom dimension ", i))
}

# Get all custom dimension values in a list -------------------------------
#list <- mget( ls( pattern ="^dimension[1-9][0-9]?$|^100$" ) )
list <- mget( ls( pattern ="([1-9]|[1-8][0-9]|9[0-9]|1[0-9]{2}|200)" ) )
Filter(length, list) -> list_new

data.frame(sapply(list_new, nrow)) -> summary_data
summary_data$names <- rownames(summary_data)

# Return only empty custom dimensions -------------------------------------
as.data.frame(setdiff(cd_index$index,gsub("dimension","",summary_data$names))) -> dimensions_empty
colnames(dimensions_empty) <- c("index")

colnames(summary_data) <- c("number_results", "index")
summary_data[,c(2,1)] -> summary_data

gsub("dimension", "", summary_data$index) -> summary_data$index
merge(x = summary_data, y = cd_index, by = "index", all.x = TRUE) -> summary_data
merge(x = dimensions_empty, y = cd_index, by = "index", all.x = TRUE) -> summary_data_empty

# Clean up summary data ---------------------------------------------------
as.numeric(summary_data$index) -> summary_data$index
summary_data[order(summary_data$index),,drop=FALSE] -> summary_data
summary_data[,c("index", "name", "scope", "number_results", "created", "updated")] -> summary_data

# Clean up Summary Empty data ---------------------------------------------
as.numeric(summary_data_empty$index) -> summary_data_empty$index
summary_data_empty[order(summary_data_empty$index),,drop=FALSE] -> summary_data_empty
summary_data_empty[,c("index", "name", "scope", "created", "updated")] -> summary_data_empty

# Create list for Export --------------------------------------------------
c(list(summary_data,summary_data_empty), list_new) -> list_new

# Write to Excel ----------------------------------------------------------
write_xlsx(list_new, paste0("customDimensions_",uaId,".xlsx"))
