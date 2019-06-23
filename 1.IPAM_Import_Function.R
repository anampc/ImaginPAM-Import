# This function gets the YII values from different .csv files exported from ImagingPAM machines, and
# consolidates the values in a single data frame

# To run the function and add the specific sample information run the second script (2.example.R)

      Import_YII<- function (dir)  {
       
      # 1. Read all the .csv files (; delimited) and consolidate them in a single data frame
        # * If some .csv files are not imported check if they are indeed ; delimited
        # * dir: folder containing the .csv files
        # * .csv files in the "dir" can be separated in subfolders if you keep recursive = TRUE locations...
      
         IPAM.data<-plyr::ldply (list.files(path=dir, pattern="*.csv", 
                                      full.names=TRUE, recursive = TRUE),
                              function(filename) {
                              dum=(read.csv(filename, sep = ";", blank.lines.skip=T))
                              dum$filename=filename
                              return(dum)
                           })  
           
      # 2. Select the columns that contain the file path and the YII values (remove F0 and Fm values)
        YII.data<-IPAM.data[,grep("filename|Y.II.", names(IPAM.data))]
        
        # Change to long format
        YII.data <- na.omit(reshape2::melt(YII.data, id=c("filename")))
        
        return(YII.data)
        
      }
