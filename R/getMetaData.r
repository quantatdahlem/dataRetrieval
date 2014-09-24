#' Import Metadata for USGS Data
#'
#' This function is being deprecated for \code{\link{getNWISInfo}}.
#'
#' @param siteNumber string USGS site number.  This is usually an 8 digit number
#' @param parameterCd string USGS parameter code.  This is usually an 5 digit number.
#' @param interactive logical Option for interactive mode.  If true, there is user interaction for error handling and data checks.
#' @keywords data import USGS web service WRTDS
#' @export
#' @return INFO dataframe with agency, site, dateTime, value, and code columns
#' @examples
#' # These examples require an internet connection to run
#' # Automatically gets information about site 05114000 and temperature, no interaction with user
#' INFO <- getMetaData('05114000','00010')
getMetaData <- function(siteNumber="", parameterCd="",interactive=TRUE){
  
  warning("This function is being deprecated, please use getNWISInfo")
  
  if (nzchar(siteNumber)){
    INFO <- getNWISSiteInfo(siteNumber)
  } else {
    INFO <- as.data.frame(matrix(ncol = 2, nrow = 1))
    names(INFO) <- c('site.no', 'shortName')    
  }
  INFO <- populateSiteINFO(INFO, siteNumber, interactive=interactive)
  
  if (nzchar(parameterCd)){
    parameterData <- getNWISPcodeInfo(parameterCd,interactive=interactive)
    INFO$param.nm <- parameterData$parameter_nm
    INFO$param.units <- parameterData$parameter_units
    INFO$paramShortName <- parameterData$srsname
    INFO$paramNumber <- parameterData$parameter_cd
  } 
  
  INFO <- populateParameterINFO(parameterCd, INFO, interactive=interactive)
  INFO$paStart <- 10
  INFO$paLong <- 12
  
  return(INFO)
}

#' Import Metadata for USGS Data
#'
#' Populates INFO data frame for WRTDS study.  If either station number or parameter code supplied, imports data about a particular USGS site from NWIS web service. 
#' This function gets the data from here: \url{http://waterservices.usgs.gov/}
#' A list of parameter codes can be found here: \url{http://nwis.waterdata.usgs.gov/nwis/pmcodes/}
#' If either station number or parameter code is not supplied, the user will be asked to input data.
#' Additionally, the user will be asked for:
#' staAbbrev - station abbreviation, will be used in naming output files and for structuring batch jobs
#' constitAbbrev - constitute abbreviation
#'
#' @param siteNumber string USGS site number.  This is usually an 8 digit number
#' @param parameterCd string USGS parameter code.  This is usually an 5 digit number.
#' @param interactive logical Option for interactive mode.  If true, there is user interaction for error handling and data checks.
#' @keywords data import USGS web service WRTDS
#' @export
#' @return INFO dataframe with agency, site, dateTime, value, and code columns
#' @examples
#' # These examples require an internet connection to run
#' # Automatically gets information about site 05114000 and temperature, no interaction with user
#' INFO <- getNWISInfo('05114000','00010')
getNWISInfo <- function(siteNumber, parameterCd,interactive=TRUE){
  if (nzchar(siteNumber)){
    INFO <- getNWISSiteInfo(siteNumber)
  } else {
    INFO <- as.data.frame(matrix(ncol = 2, nrow = 1))
    names(INFO) <- c('site.no', 'shortName')    
  }
  INFO <- populateSiteINFO(INFO, siteNumber, interactive=interactive)
  
  if (nzchar(parameterCd)){
    parameterData <- getNWISPcodeInfo(parameterCd,interactive=interactive)
    INFO$param.nm <- parameterData$parameter_nm
    INFO$param.units <- parameterData$parameter_units
    INFO$paramShortName <- parameterData$srsname
    INFO$paramNumber <- parameterData$parameter_cd
  } 
  
  INFO <- populateParameterINFO(parameterCd, INFO, interactive=interactive)
  INFO$paStart <- 10
  INFO$paLong <- 12
  
  return(INFO)
}

#' Import Metadata for USGS Data
#'
#' Populates INFO data frame for WRTDS study.  If either station number or parameter code supplied, imports data about a particular USGS site from NWIS web service. 
#' This function gets the data from here: \url{http://waterservices.usgs.gov/}
#' A list of parameter codes can be found here: \url{http://nwis.waterdata.usgs.gov/nwis/pmcodes/}
#' If either station number or parameter code is not supplied, the user will be asked to input data.
#' Additionally, the user will be asked for:
#' staAbbrev - station abbreviation, will be used in naming output files and for structuring batch jobs
#' constitAbbrev - constitute abbreviation
#'
#' @param siteNumber string site number. 
#' @param parameterCd string USGS parameter code or characteristic name.
#' @param interactive logical Option for interactive mode.  If true, there is user interaction for error handling and data checks.
#' @keywords data import USGS web service WRTDS
#' @export
#' @return INFO dataframe with agency, site, dateTime, value, and code columns
#' @examples
#' # These examples require an internet connection to run
#' # Automatically gets information about site 01594440 and temperature, no interaction with user
#' nameToUse <- 'Specific conductance'
#' pcodeToUse <- '00095'
#' INFO <- getWQPInfo('USGS-04024315',pcodeToUse)
#' INFO2 <- getWQPInfo('WIDNR_WQX-10032762',nameToUse)
#' # To adjust the label names:
#' INFO2$shortName <- "Pheasent Branch"
#' INFO2$paramShortName <- "SC"
#' INFO2$drainSqKm <- 100
#' INFO2$param.units <- "
getWQPInfo <- function(siteNumber, parameterCd){
  
  #Check for pcode:
  pCodeLogic <- (all(nchar(parameterCd) == 5) & all(!is.na(as.numeric(parameterCd))))

  if (pCodeLogic){
    
#     siteInfo <- getWQPSites(siteid=siteNumber, pcode=parameterCd)
    siteInfo <- do.call(getWQPSites, args=list(siteid=eval(siteNumber), pcode=eval(parameterCd)))
    parameterData <- getNWISPcodeInfo(parameterCd = parameterCd)
    siteInfo$param.nm <- parameterData$parameter_nm
    siteInfo$param.units <- parameterData$parameter_units
    siteInfo$paramShortName <- parameterData$srsname
    siteInfo$paramNumber <- parameterData$parameter_cd
  } else {
    siteInfo <- do.call(getWQPSites, args=list(siteid=eval(siteNumber), characteristicName=eval(parameterCd)))
    siteInfo$param.nm <- parameterCd
    siteInfo$param.units <- ""
    siteInfo$paramShortName <- parameterCd
    siteInfo$paramNumber <- ""
  }
  
  siteInfo$station.nm <- siteInfo$MonitoringLocationName
  siteInfo$shortName <- siteInfo$station.nm 
  siteInfo$site.no <- siteInfo$MonitoringLocationIdentifier
  
  if(siteInfo$DrainageAreaMeasure.MeasureUnitCode == "sq mi"){
    siteInfo$drainSqKm <- as.numeric(siteInfo$DrainageAreaMeasure.MeasureValue) * 2.5899881 
  } else {
    warning("Please check the units for drainage area. The value for INFO$drainSqKm needs to be in square kilometers,")
    siteInfo$drainSqKm <- as.numeric(siteInfo$DrainageAreaMeasure.MeasureValue)
  }
  
  siteInfo$paStart <- 10
  siteInfo$paLong <- 12
  
  return(siteInfo)
}

