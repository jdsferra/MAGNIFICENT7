shinyServer(function(input, output) {
  
#Closing Prices

output$ts1 <- renderPlotly(
  ts_plot(closingprices[-9], title = 'Magnificent 7 Closing Prices', Xtitle = 'Date', Ytitle = 'Price per share ($)', slider = TRUE)
  )

#Add Percent Change

datefilter <- eventReactive(input$dateRange, {
  req(input$dateRange) #make sure input$dateRange is not NULL
  closingprices %>% 
    filter(Date >= input$dateRange[1] & Date <= input$dateRange[2])
})


pctchange = function(x){
  (x - first(x))/first(x)*100
}

addpctchg <- reactive({
  data <- datefilter()
  if(!is.null(data)) {
    data %>% mutate(across(where(is.numeric), pctchange))
  } else {
    NULL
  }
})
  
  
output$pctplot <- renderPlotly({
  req(addpctchg())
  ts_plot(addpctchg(), title = 'Mag7 % Change in Price', Xtitle = 'Date', Ytitle = '% Change in Price')
})

#P/E Ratios

output$pe1 <- renderPlotly({
ts_plot(peratios, title = 'P/E Ratios of Mag7 vs. S&P500 (Reported Quarterly)', Xtitle = 'Date', Ytitle = 'Stock Price/Earnings per share', slider = TRUE)
})

  
#Market Cap
yearcheck <- eventReactive(input$format, {
  req(input$format)
  mc %>%
    filter(YearEnd == input$format)
})

pivotyearcheck <- eventReactive(yearcheck(), {
  req(yearcheck())
  yearcheck() %>% pivot_longer(2:10, names_to = 'biz', values_to = 'marketcap') %>% group_by(biz) %>%
  mutate(fulllabel=paste(biz, paste0('$',marketcap,'T'), sep = '\n'))
})

output$mc1 <- renderPlot({
  req(pivotyearcheck())
  
  plot <- treemap(pivotyearcheck()[-9, ], index = 'fulllabel', vSize = 'marketcap',
                  palette = rep('#008FDF', times = 8), fontcolor.labels = '#000000', border.col = 'gray',
                  title = paste0('S&P 500 ', input$format, ' Market Cap ($', sum(yearcheck()$SP), 'T)'),
                  title.legend = "Caption goes here",
                  padding.labels = c(5, 5, 50, 5),
                  aspRatio = 0.8)
  
  plot
})


  
  
  #About Me
  linkedin = a("LinkedIn", href="https://linkedin.com/in/joe-sferra/")
  github = a("GitHub", href="https://github.com/jdsferra")
  blog = a("NYCDSA Blog", href="https://nycdatascience.com/blog/author/jdsferra/")
  
  output$tab1 <- renderUI({
    tagList(linkedin)
  })
  
  output$tab2 <- renderUI({
    tagList(github)
  })
  
  output$tab3 <- renderUI({
    tagList(blog)
  })
})
