# This script will pair the ID information of your samples 
# with YII values that you would obtain running 1.IPAM_ImportFunction (Step 3)

# 3. Get and save the YII values as a single data frame  
    source("1.IPAM_Import_Function.R")
    YII<-Import_YII("example") # example is the name of my folder (dir) coitaining the .csv files


# 4.If you have your csv data in subfolders run these, if not, you can go to # 5
    # you can separate "folder" and "file" names contained in "filename" path.
    # In this example each subfolder corresponds to different sampling dates
    # Followed by the specific file name
    file.picture <- plyr::rbind.fill(lapply(strsplit(as.character(YII$filename), split="/"), 
                                            function(X) data.frame(t(X))))
    colnames(file.picture) <- c("Folder", "SubFolder", "File")
    
    YII <- cbind(file.picture[,-1], YII[,-1])

# 5. Get and save the sample identification info as a data frame  
    # This is a file that you should create, containing the filename and area of interest
    # that correspond to each one of your samples
    # The SubFolder column is not required if you do not have your .csv files in subfolders
    ID_AOI<-read.csv("ID_AOI.csv")
    ID_AOI$variable<-paste("Y.II.",ID_AOI$AOI, sep = "")

# 6. Merge YII and sample information
    # Remove "SubFolder"from the next line if all your data is in one folder
    YII.data<-plyr::join(ID_AOI, YII, by =c("SubFolder", "File", "variable"), type="inner")

#7. Select the information of interest and rename your columns
    YII.data<-dplyr::select(YII.data, SubFolder, ID, value)
    colnames(YII.data) <- c("Date","ID", "YII")


