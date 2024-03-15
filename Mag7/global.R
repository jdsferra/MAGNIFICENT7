#mag7 global- import libraries, import data and do relevant preprocessing
library(shiny)
library(shinydashboard)
library(tidyverse)
library(TSstudio)

#import data and do relevant preprocessing 
#closing prices
closingprices <- read.csv(file = "./closingprices15-24.csv")
closingprices$Date = gsub(" 16:00:00","",closingprices$Date)
closingprices$Date = as.Date(closingprices$Date, "%m/%d/%Y")
mag7subset <- c('AAPL', 'AMZN', 'GOOG', 'META', 'MSFT', 'NVDA', 'TSLA') 

#market cap
mc <- read.csv(file = "./marketcap14-24.csv")
mc <- mc %>% mutate('S&P493' = SP- rowSums(mc[2:8])) %>% relocate('S&P493', .before= 'SP') %>% mutate_if(is.numeric, round, digits = 2)

#p/e ratios
peratios <- read.csv("./PERatios.csv", skip = 1)
peratios$X = as.Date(peratios$X, "%Y-%m-%d")
peratios[16:18,1] = as.Date(c('2023-10-01', '2024-01-01', '2024-02-23'))
peratios <- peratios %>% relocate(S.P, .after = TSLA) %>% rename('SP500' = S.P)

#GDP Data
gdptoplot <- read.csv(file = "./GDPMAG714-24toplot.csv")

#library(rsconnect)
#rsconnect::setAccountInfo(name='jdsferra', token='A18422E31BBAE76540799647FAABF7E9', secret='pnNFKl2L5ZSiJs2zm9L39XEjzU5x9vnUYjlSC2di')



