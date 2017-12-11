# dependencies ####

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
packages <- c("rgdal","raster","sp","foreign","gdalUtils","maptools","curl","devtools","archive")
ipak(packages)
# install_github("jimhester/archive") # get rid of archives


# Download gridded data from Chelsa 

grab_chelsa <- function(extent, set, var, path="", buf=0, download=F, i){
  
  # working directory and creating output folder 
  path <- .getDataPath(path)
  path <- paste0(path, paste0("CHELSA_", var))
  dir.create(path, showWarnings=T)
  
  
  
  
  # Check variable specification ####
  stopifnot(var %in% c("tmean", "tmin", "tmax", "prec", "bio"))
  
  
  
  
  # write URLs ####
  # will become obsolete with look-up-table
  
  if(var == "bio"){
  zip <- paste0("CHELSA_",var,"10_",i,"_land.7z")
  zippath <- file.path(path,paste0("CHELSA_",var,"10_",i,"_land.7z"))
  tiffiles <- paste0("CHELSA_",var,"10_",i,".tif")
  theurl <- paste0("https://www.wsl.ch/lud/chelsa/data/bioclim/integer/", zip)
  }
  if(var == "tmin"){
    zip <- paste0("CHELSA_",var,"10_",i,"_land.7z")
    zippath <- file.path(path,paste0("CHELSA_",var,"10_",i,"_land.7z"))
    tiffiles <- paste0("CHELSA_",var,"10_",i,".tif")
    theurl <- paste0("https://www.wsl.ch//lud/chelsa/data/climatologies/temp/integer/tmin/", zip)
  }
  
  
  
  
  # Check whether file extists ####
  # insert load_cache() here
  
  file.exists(paste0("CHELSA_",var,"/",tiffiles))
  file.exists(zippath)
  
  
  
  # download data ####
  # Add message/query to user before downloading
  .download(theurl[i], zippath[i])
  
  
  
  # unzipping ####
  # need for alternatives to "archive" package 
  
  archive_extract(archive=zippath[i],dir=path)
  
  
  
  # Cropping raster to extent
  
  if(var=="tmin"){
    tif <- raster(paste0(path,"/CHELSA_",var,"10_",i,"_1979-2013_V1.2_land.tif"))
    tif <- crop(tif,extent(extent)+c(-buf,buf,-buf,buf))
  }
  if(var =="bio"){
    tif<- raster(file.path(path,tiffiles[i]))
    tif <- crop(tif,extent(extent)+c(-buf,buf,-buf,buf))
  }
  
  
  
  # Overwrite tif file (optional?) ####
  # writeRaster(tif,file.path(path,tiffiles[i]), overwrite=T)
  
  # Output raster ####
  return(tif)
}


# sample data ####

set ="CHELSA"
var = "tmin"
load("fagus1.RData") 
path=""
buf= 1
download=T
i <- 1

tif1 <- grab_chelsa(extent = fagus1, set = "CHELSA", var = "tmin", buf = 1,
     download = T, i = 1)
plot(tif1)
plot(fagus1, add=T)


