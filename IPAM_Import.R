Import_YII<- function (dir, data.files="*.csv")  {
 
# 1. Read all the .csv files (; delimited) and consolidate them in a single data frame
  # dir: folder containing the .csv files. The data in the dir can be separated in subfolders, recursive = TRUE will find the .csv files inside the subfolders
  # You can use the subfolders names to later extract information with the option full.names=TRUE, in this 
  # example the subfolders are the differents sampling dates, but it could be treatments, locations...

   IPAM.data<-plyr::ldply (list.files(path=dir, pattern=data.files, 
                                full.names=TRUE, recursive = TRUE),
                     function(filename) {
                       dum=(read.csv(filename, sep = ";", blank.lines.skip=T))
                       dum$filename=filename
                       return(dum)
                     })  
     
# 2. Select the columns that contain the file path and the YII values (remove F0 and Fm values)
  IPAM.data<-IPAM.data[,grep("filename|Y.II.", names(IPAM.data))]
  
  # Change to long format
  IPAM.data <- na.omit(reshape2::melt(IPAM.data, id=c("filename")))
  
# 3.If you have subfolders separate folder and file information contained in "filename"
  # In this example each subfolder correspond to different dates, but it could be treatments, locations...
  # Followed for the specific file name
  file.picture <- plyr::rbind.fill(lapply(strsplit(as.character(IPAM.data$filename), split="/"), 
                                    function(X) data.frame(t(X))))
  colnames(file.picture) <- c("Folder", "Date", "File")
  
  YII <- cbind(file.picture[,-1], IPAM.data[,-1])
  
# 4. Get and save the ID info as a data frame  
  ID_AOI<-read.csv("ID_AOI.csv")
  ID_AOI$variable<-paste("Y.II.",ID_AOI$AOI, sep = "")
  
# 5. Merge YII and sample info (optional)
  YII.data<-plyr::join(ID_AOI, YII, by =c("Date", "File", "variable"), type="inner")
  
#6. Remove file info 
  YII.data<-dplyr::select(YII.data, Date, ID, value)
  colnames(YII.data) <- c("Date","ID", "YII")
  
  return(YII.data)
  
}
