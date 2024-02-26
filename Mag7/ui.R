library(treemap)
library(plotly)
dashboardPage(skin = 'blue', dashboardHeader(title='The Magnificent Seven (2020-2024)', titleWidth = 380),
              
              #Sidebar Items              
              dashboardSidebar( sidebarUserPanel("Joe Sferra: NYCDSA",
                                                 image = './NYCDSA.png' ),
                                sidebarMenu(
                                  menuItem("Intro", tabName = 'intro', icon = icon("house")),
                                  menuItem("Stock Prices 2020-2024", tabName = "prices", icon = icon("dollar-sign")),
                                  menuItem("Percent Change in Prices", tabName = 'pct', icon = icon("percent")),
                                  menuItem("P/E Ratios", tabName = 'pe', icon = icon("divide")),
                                  menuItem("Market Cap", tabName = 'mc', icon = icon("square")),
                                  menuItem("vs. World GDP's", tabName = 'gdp', icon = icon("earth-asia")),
                                  menuItem("About Me", tabName = 'me', icon = icon("address-book"))
                                )),
              
              #Dashboard Body              
              dashboardBody(
                tabItems(
                  #Welcome
                  tabItem(tabName = 'intro', #h1('Understanding the Magnificent Seven', style='text-align:center'),
                  div(img(src='Artboard 1.png', height="100%", width="100%"), style="text-align: left;")
                  ),
                  
                  #Closing Prices
                  tabItem(tabName = 'prices', h2('Closing Prices 2020-2024'),
                          
                            
                            mainPanel(
                              wellPanel(fluidRow(plotlyOutput('ts1'))),
                              div('Source: Google Finance'),
                              ),
                            ),
                  
                  #Percent Change
                  
                  tabItem(tabName = 'pct', h2('Percent Change in Prices'),
                          sidebarLayout(
                           sidebarPanel(
                             dateRangeInput('dateRange',
                                label = 'Date range input: yyyy-mm-dd',
                                start = as.Date("2020-01-02", "%Y-%m-%d"),
                                end = as.Date("2024-02-22", "%Y-%m-%d"),
                                min = as.Date("2020-01-02"),
                                max = as.Date("2024-02-22")
                             )
                           ),
                           mainPanel(
                             wellPanel(plotlyOutput("pctplot")),
                             div('Source: Google Finance', style ='textalign:right'),
                             )
                           )
                          ),
                  
                  #P/E Ratios
                  tabItem(tabName = 'pe', h2('Quarterly Reported P/E Ratios 2020-2024'),
                  
                          mainPanel(
                            wellPanel(fluidRow(plotlyOutput('pe1'))),
                            div('Source: Macrotrends.net, Multpl.com'),
                          ),
                  ),
                  
                  #Market Cap
                  tabItem(tabName = 'mc', h2('The Magnificent Seven Dominate S&P500 Market Cap'),
                          h6("All breakdowns are calculated at year end (2024 is estimated for Feb '24)."),
                          h6("As the S&P 500's Market Cap has grown from $26T to $40T, so has the Magnificent 7's share of it, with their\
                          share currently hovering at around one third."),
                          
                          sidebarLayout(
                            sidebarPanel(
                              sliderInput("format", "Select year:",
                                          min = 2019, max = 2024,
                                          value = 2019, step = 1,
                                          sep = ""
                                          )
                            ),
                          
                          mainPanel(
                            wellPanel(fluidRow(column(12, plotOutput('mc1')))),
                            div('Source: Macrotrends.net'),
                          )
                       )
                    ),
                  
                  #World GDPs
                  tabItem(tabName = 'gdp', h2("The Magnificent Seven's Market Cap Rivals World GDPs"),
                          h6("The Magnificent 7's market cap eclipses many world GDPs, consistently placing fourth behind the USA, China, and the Euro Area."),
                          h6("All breakdowns are calculated at year end (2024 is estimated for Feb '24)."),
                          
                          sidebarLayout(
                            sidebarPanel(
                              sliderInput("format2", "Select year:",
                                          min = 2020, max = 2024,
                                          value = 2020, step = 1,
                                          sep = ""
                              )
                            ),
                            
                            mainPanel(
                              wellPanel(fluidRow(column(12, plotOutput('gdp1', width = '100%')))),
                              div('Source: IMF World Economic Outlook Database, Macrotrends.net'),
                            )
                          )
                  ), 


                  #About Me
                  tabItem(tabName = 'me', h2("Joe Sferra"),
                          div(img(src='Joe Sferra Headshot.jpg', height="40%", width="40%"), style="text-align: left;"),
                          h5("I'm excited about taking my creative problem-solving and storytelling skills that I've developed\
                   as a musician and college professor into the data science world. I love games, puzzles, jokes, and learning something new!"),
                          strong('Find Me On:'),
                          uiOutput('tab1'),
                          uiOutput('tab2'),
                          uiOutput('tab3')
                  )
                )
              )
)
