library(plotly)
dashboardPage(skin = 'blue', dashboardHeader(title='The Magnificent Seven (2020-2024)', titleWidth = 380),
              
              #Sidebar Items              
              dashboardSidebar( sidebarUserPanel("Joe Sferra: NYCDSA",
                                                 image = './NYCDSA.png' ),
                                sidebarMenu(
                                  menuItem("Intro", tabName = 'intro', icon = icon("house")),
                                  menuItem("Stock Prices 2020-2024", tabName = "prices", icon = icon("dollar-sign")),
                                  menuItem("Percent Change in Prices", tabName = 'pct', icon = icon("percent")),
                                  menuItem("About Me", tabName = 'me', icon = icon("address-book"))
                                )),
              
              #Dashboard Body              
              dashboardBody(
                tabItems(
                  #Welcome
                  tabItem(tabName = 'intro', #h1('Understanding the Magnificent Seven', style='text-align:center'),
                  div(img(src='Artboard 1.png', height="100%", width="100%"), style="text-align: left;")
                  ),
                  
                  #
                  tabItem(tabName = 'prices', h2('Closing Prices 2020-2024'),
                          
                            
                            mainPanel(
                              fluidRow(column(12, plotlyOutput('ts1')),
                              ),
                            )
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
                             plotlyOutput("pctplot")
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