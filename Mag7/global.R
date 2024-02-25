#mag7 global- import libraries, import data and do relevant preprocessing
library(shiny)
library(shinydashboard)
library(tidyverse)
library(TSstudio)


#import data and do relevant preprocessing
closingprices <- read.csv(file = "./closingprices20-24.csv", skip = 1)
closingprices$Date = gsub(" 16:00:00","",closingprices$Date)
closingprices$Date = as.Date(closingprices$Date, "%m/%d/%Y")



#---------------------------------


#getwd()
#setwd('/Users/joesferra/Desktop/NYCDSA/RWork/Mag7')
