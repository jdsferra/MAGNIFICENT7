library(treemap)
library(plotly)
dashboardPage(skin = 'blue', dashboardHeader(title='The Magnificent Seven (2015-2024)', titleWidth = 380),
              
              #Sidebar Items              
              dashboardSidebar( sidebarUserPanel("Joe Sferra: NYCDSA",
                                                 image = './NYCDSA.png' ),
                                sidebarMenu(
                                  menuItem("Intro", tabName = 'intro', icon = icon("house")),
                                  menuItem("Price Data", tabName = "prices", icon = icon("dollar-sign")),
                                  menuItem("P/E Ratios", tabName = 'pe', icon = icon("divide")),
                                  menuItem("Market Cap", tabName = 'mc', icon = icon("square")),
                                  menuItem("vs. World GDP's", tabName = 'gdp', icon = icon("earth-asia")),
                                  menuItem("Contact", tabName = 'me', icon = icon("address-book"))
                                )),
              
              #Dashboard Body              
              dashboardBody(
                tabItems(
                  #Welcome
                  tabItem(tabName = 'intro', h1('Understanding the Magnificent Seven', style='text-align:center'),
                  div("In 2013, Jim Cramer of CNBC's 'Mad Money' popularized the term FANG to describe the high-performing stocks of Facebook, Amazon, Netflix, and Google.\
                       In 2017, Apple joined this group to make FAANG. Since 2023, a similar group of stocks has captured investors' attention with another term popularized\
                       by Cramer, The Magnificent Seven. Apple (AAPL), Amazon (AMZN), Alphabet (GOOG), Meta (META), Microsoft (MSFT), Nvidia (NVDA), and Tesla (TSLA) are have significant\
                       players in the tech world and the ongoing AI boom."),
                  br(),
                  div("While the S&P 500 is a common indicator of the health of the stock market, its performance needs to be understood largely as the\
                       performance of the Magnificent Seven. The S&P 500's metrics are calculated with a weighted average based on share of market cap.\
                          This means that the Seven's recent success has given them a significant share of the overall market cap\
                          and may be artificially inflating the S&P 500's overall performance.\
                          The index, representing 503 businesses, is usually regarded as a general indicator for economic health. The Seven's\
                          dominance raises concerns for investors and businesses alike. Is the sucess of the Seven masking an otherwise stagnating S&P 500?\
                          Is a business that has to report their progress to the SEC via against the S&P making a flawed comparison? Examine these questions through the plots and\
                          data provided in this R Shiny App."),
                  div(img(src='mag7logo.png', height = '50%', width = '50%'), style = 'text-align: center;')
                  ),
                  
                  #Closing Prices
                  tabItem(tabName = 'prices', h3('Closing Prices vs. % Price Change'),
                          h6("Price data vs. percent change in price. Specifying the starting date can create vastly\
                          different plots, which serve as important visualizations in news coverage of the stock market. The second tab allows individual stocks and calculates\
                          the standard deviation from start date to present, a common measure of stock volatility.\
                          Significant dates to isolate here may be early 2020 during the rise of Covid-19, early 2023 when\
                          Jim Cramer popularized the term 'Magnificent Seven', or early 2024 as Nvidia skyrockets as Cramer\
                          suggested dropping Tesla from this group and instead supporting the 'Super Six'."),
                          
                            
                            mainPanel(width ='100%',
                              tabBox(
                                title = " ", id = 'tabset1', height = '100%', width = '100%',
                                
                              tabPanel("Mag7 vs S&P",  
                                       dateInput('pricesdate', label = 'Starting Date:\
                                        (2015-01-02 to 2024-03-11)',
                                                 value = as.Date("2015-01-02"), min = as.Date("2015-01-02"),
                                                 max = as.Date("2024-03-11")),                              
                              wellPanel(fluidRow(plotlyOutput('ts1', height = '260px'))),
                              wellPanel(fluidRow(plotlyOutput('pctplot', height = '260px'))),

                              div('Source: Google Finance')),
                              
                              
                              tabPanel("Invidual Stocks/Volatility",
                                       fluidRow(
                                         column(width = 6,
                                                
                                                dateRangeInput('pricesdaterange2', label = 'Date range input:\
                                        (2015-01-02 to Present)',
                                                               start = as.Date('2015-01-02', "%Y-%m-%d"),
                                                               end = as.Date("2024-03-11"),
                                                               min = as.Date("2015-01-02"),
                                                               max = as.Date("2024-03-11"))
                                         ),
                                         column(width = 6,
                                                
                                                selectizeInput('colselect', label = 'Select a stock:',
                                                               choices = mag7subset,
                                                               selected = mag7subset[1])),
                                       ),                                       
                              wellPanel(fluidRow(plotlyOutput('ts2', height = '260px'))),
                              wellPanel(fluidRow(plotlyOutput('pctplot2', height = '260px'))),
                              

                              div('Source: Google Finance'),
                              
                              width = 12),
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
                          h6("As the S&P 500's market cap has grown from $20.59T to $51.57T in the past ten years, so has\
                          the Magnificent 7's share of it, with their share approaching one-third of the overall market cap.\
                          The S&P 500's published metrics are calculated via a weighted average based on share of market cap, so the performance of the Seven\
                          has a strong bearing in these metrics."),
                          h6("All breakdowns are calculated at year end (2024 is estimated for March '24)."),
                          
                          sidebarLayout(
                            sidebarPanel(
                              sliderInput("format", "Select year:",
                                          min = 2014, max = 2024,
                                          value = 2014, step = 1,
                                          sep = "", animate = TRUE
                                          ),
                            ),
                          
                          mainPanel(
                            wellPanel(fluidRow(column(12, plotOutput('mc1')))),
                            
                            
                            wellPanel(
                              fluidRow(
                                column(12, plotOutput('mc2')),
                                )
                            ),
                            wellPanel(
                              fluidRow(
                                column(12, plotOutput('mc3')),
                              )
                            ),
                            div('Source: Macrotrends.net')
                          )
                       )
                    ),
                  
                  #World GDPs
                  tabItem(tabName = 'gdp', h2("The Magnificent Seven's Market Cap Rivals World GDPs"),
                          h6("The Magnificent 7's market cap has grown to eclipse many world GDPs, moving from twelfth place\
                             up to fourth in the nine-year span outlined. Since 2019, the Seven has placed fourth behind\
                             the USA, China, and the Euro Area. The performance of the Seven in the future will have worldwide\
                             consequences, both good and bad."),
                          h6("All breakdowns are calculated at year end (2024 is estimated for Feb '24)."),
                          
                          sidebarLayout(
                            sidebarPanel(
                              sliderInput("format2", "Select year:",
                                          min = 2014, max = 2024,
                                          value = 2014, step = 1,
                                          sep = "", animate = TRUE
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
                   as a musician and college professor into the data science world."),
                          strong('Find Me On:'),
                          uiOutput('tab1'),
                          uiOutput('tab2'),
                          uiOutput('tab3')
                  )
                )
              )
)
