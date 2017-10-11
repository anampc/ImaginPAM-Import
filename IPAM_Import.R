Import_YII<- function (dir, data.files="*.csv")  {

 # 1. Get multiple .csv files and pool the data
  
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
  
# 3.separate folder and file information contained in "filename"
  # In this example each subfolder correspond to different dates, but it could be treatments, locations...
  # Followed for the specific file name
  
  file.picture <- plyr::rbind.fill(lapply(strsplit(as.character(IPAM.data$filename), split="/"), 
                                    function(X) data.frame(t(X))))
  colnames(file.picture) <- c("Folder", "Date", "File")
  
  result <- cbind(file.picture[,-1], IPAM.data[,-1])
  
  
# 4. Return final data fraem
  return(result)

} 
