# Project set up
  getwd()
  library(dplyr)
  library(reshape2)

# 1. Read all the .csv files (; delimited) and consolidate them in a single data frame
  # Path: folder containing the .csv files, in this example "IPAM-Raw"
  # The data in "IPAM-Raw"can be separated in subfolders, recursive = TRUE will find the .csv inside the subfolders
  # You can use the subfolders names to later extract information with the option full.names=TRUE, in this 
  # example the subfolders are the differents sampling dates, but it could be treatments, locations...
  
IPAM.data<-ldply(list.files(path="example", pattern=".csv", 
                           full.names=TRUE, recursive = TRUE),
             function(filename) {
      dum=(read.csv(filename, sep = ";", blank.lines.skip=T))
      dum$filename=filename
    return(dum)
})

# 2. Select the columns that contain the file path and the YII values

IPAM.data<-IPAM.data[,grep("filename|Y.II.", names(IPAM.data))]

# Change to long format
IPAM.data <- na.omit(melt(IPAM.data, id=c("filename")))
  
# 3.separate folder and file information contained in "filename"
  # In this example each subfolder correspond to different dates, but it could be treatments, locations...
  # Followed for the specific file name

file.picture <- rbind.fill(lapply(strsplit(as.character(IPAM.data$filename), split="/"), 
                                         function(X) data.frame(t(X))))
                colnames(file.picture) <- c("Folder", "Date", "File")

IPAM.data <- cbind(file.picture[,-1], IPAM.data[,-1])
  
# 4. Merge with sample information and check for missing data
  # Import a csv file containing the specific ID for each AOI in each file 
  # In this case the subfolder will be matched with the date (optional)
  # Same file names can be repeated in different subfolders

  ID_AOI<-read.csv("ID_AOI.csv")
  ID_AOI$variable<-paste("Y.II.",ID_AOI$AOI, sep = "")
  
  IPAM.data<-join(ID_AOI, IPAM.data, by =c("Date", "File", "variable"), type="inner")
  
# 5. Check for missing data (Optional)
  
  ErrorI<-anti_join(ID_AOI, IPAM.data, by =c("Date", "File", "variable"))
  # The file+AOI specified in the sample information was not found 
  ErrorII<-anti_join(IPAM.data, ID_AOI, by =c("Date", "File", "variable"))
  # There are file+AOI without ID information

# 6. get rid of file info and rename columns  
  IPAM.data<-select(IPAM.data, Date, ID, value)
  colnames(IPAM.data) <- c("Date","ID", "YII")
  

  
  