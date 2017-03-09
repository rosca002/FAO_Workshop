
####Install and import  packages#### 
install.packages("raster")
library(raster)
install.packages("sp")
library(sp)
install.packages("rgdal")
library(rgdal)
install.packages("utils")
library(utils)
#in order to install bfast spatial the following packages are also necessary
install.packages("devtools")
library(devtools)
install.packages('zoo')
library(zoo)
install.packages('strucchange')
install.packages('forecast')
install.packages('foreach')
install.packages('R.utils')
install_github('loicdtx/bfastSpatial')
library(bfastSpatial)
#### ####


####Pre-processing####

# #1.Set paths of the project 
# 
# # tmp dir is for storing 'invisible' temporary files
# # We can use the tmp directory of the raster package
# tmpDir <- rasterOptions()$tmpdir
# 
# # StepDir is where we store intermediary outputs
# stepDir <- file.path(path, 'step')
# 
# # ndmiDir is a subdirectory of stepDir
# # it is where individual NDVI layers will be stored before being cropped
# ndmiDir <- file.path(stepDir, 'ndvi')
# 
# #ndmiCropDiris where the individul cropped (with the extent of the test area
# #ndmi layers will be storred before being masked
# ndmiCropDir <- file.path(stepDir, 'ndmi_croped')
# 
# #ndmiMaskDir is where the individul masked (with the forest mask and extent of the test area)
# #ndmi layers will be storred before being stacked
# ndmiMaskDir <- file.path(stepDir, 'ndmi_masked')
# 
# # Ouput directory
# outDir <- file.path(path, 'out')
# 
# #Create all the folders in the specified path
# for (i in c(stepDir, ndmiDir, ndmiCropDir, ndmiMaskDir, outDir)) {
#   dir.create(i, showWarnings = FALSE)
# }
# # Check that we have the right data in the inDir folder
# head(getSceneinfo(list.files(inDir)))
# 
# 
# #2.Process NDVI for all scenes of inDir
# 
# processLandsatBatch(x = inDir, outdir = ndmiDir, srdir = tmpDir,
#                     delete = TRUE, mask = 'fmask', vi = 'ndmi')
# 
# #3. Load  extent for the AOI 
# #The raster also represents a forest mask (value 1), masking the non-forest areas (value NA)
# ForestMask <- raster("D:/...")
# 
# #4. Crop the Landsat scenes to the same extent 
# # Get list of test data files
# list <- list.files(ndmiDir,pattern=glob2rx('*.grd'), full.names=TRUE)
# list
# for (i in 1:length(list)) {crop(raster(list[i]),ForestMask,
#                                 filename=file.path(ndmiCropDir,(substr(list[i],start=51, stop=nchar(list[i])))))}
# 
# #5. Mask the cropped Landsat scenes with the Forest mask (all areas with no forest in 2010 will be masked)
# list <- list.files(ndmiCropDir, pattern=glob2rx('*.grd'), full.names=TRUE)
# for (i in 1:length(list)) {mask(raster(list[i]),ForestMask,
#                                 filename=file.path(ndmiMaskDir,(substr(list[i],start=71, stop=nchar(list[i])))))}
# 
# list <- list.files(ndmiMaskDir, pattern=glob2rx('*.grd'), full.names=TRUE)
# 
# check_layer <- raster(list[124])
# plot(check_layer)
# 
# #6.Create the ndmi rasterBrik 
# ndmiStack <- timeStack(x = ndmiSelected, pattern = glob2rx('*.grd'),
#                        filename = file.path(path, 'Peru_ndmi_stack.grd'),
#                        datatype = 'INT2S',overwrite=TRUE)
# 
# ndmiStack <- brick("D:/.../Peru_ndmi_stack.grd")
# names(ndmiStack)
#### ####

####Load the input data for the analysis#### 
#Change the path to the correct location 
#(probably you just need to change the user name in the below given path)

ndmiStack <- brick("/data/home/sabina.rosca/data/Peru_ndmi_stack.grd")
ndviStack <- brick("/data/home/sabina.rosca/data/Peru_ndvi_stack.grd")

####Apply bfastSpatial####
out <-file.path("/data/home/sabina.rosca/data/Peru_bfm_ndmi.grd") 

bfmSpatial()

bfm_ndmi <- brick(out)
#### ####

####Post-processing####
#Change
change <- raster(bfm_ndmi,1)
plot(change, col=rainbow(7),breaks=c(2010:2016))

#Magnitude
magnitude <- raster(bfm_ndmi,2)
magn_bkp <- magnitude
magn_bkp[is.na(change)] <- NA
plot(magn_bkp,breaks=c(-5:5*1000),col=rainbow(length(c(-5:5*1000))))
plot(magnitude, breaks=c(-5:5*1000),col=rainbow(length(c(-5:5*1000))))

#Error
error <- raster(bfm_ndmi,3)
plot(error)

#Detect deforestation
def_ndmi <- magn_bkp
def_ndmi[def_ndmi>0]=NA
plot(def_ndmi)
plot(def_ndmi,col="black", main="NDMI_deforestation")
writeRaster(def_ndmi,filename = file.path("/data/home/sabina.rosca/data/Peru_def_magn.grd"))
  
def_years <- change
def_years[is.na(def_ndmi)]=NA

years <- c(2010,2011,2012,2013,2014,2015,2016,2017)
plot(def_years, col=rainbow(length(years)),breaks=years, main="Detecting deforestation after 2010")
writeRaster(def_years,filename = file.path("/data/home/sabina.rosca/data/Peru_def_dates.grd"))
