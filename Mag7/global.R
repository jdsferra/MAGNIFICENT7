#import libraries, import data, relevant preprocessing
library(shiny)
library(shinydashboard)
library(tidyverse)
library(TSstudio)
library(treemap)
library(plotly)

#closing prices and monthly averages
closingprices <- read.csv(file = "./closingprices15-24.csv")
closingprices$Date = gsub(" 16:00:00","",closingprices$Date)
closingprices$Date = as.Date(closingprices$Date, "%m/%d/%Y")
mag7subset <- c('AAPL', 'AMZN', 'GOOG', 'META', 'MSFT', 'NVDA', 'TSLA')

monthavg <- closingprices %>% 
  mutate(Date = format(Date, '%Y-%m')) %>% 
  group_by(Date) %>% summarize_if(is.numeric, mean, na.rm = TRUE) %>%
  ungroup()
monthavg$Date <- as.Date(paste(monthavg$Date, '-28', sep=''))

#market cap
mc <- read.csv(file = "./marketcap14-24.csv")
mc <- mc %>% mutate('S&P493' = SP- rowSums(mc[2:8])) %>% relocate('S&P493', .before= 'SP') %>% mutate_if(is.numeric, round, digits = 2)

#GDP Data (pre-processed)
gdptoplot <- read.csv(file = "./GDPMAG714-24toplot.csv")