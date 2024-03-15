shinyServer(function(input, output) {
  
#Closing Prices + % Change
datefilter <- eventReactive(input$pricesdate, {
  req(input$pricesdate) #make sure input$pricesdate is not NULL
  closingprices %>% 
    filter(Date >= input$pricesdate)
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

output$ts1 <- renderPlotly(
  ts_plot(datefilter()[-9], title = 'Magnificent 7 Closing Prices', Xtitle = 'Date', Ytitle = 'Price per share ($)', slider = TRUE)
)  
  
output$pctplot <- renderPlotly({
  req(addpctchg())
  ts_plot(addpctchg(), title = '% Change in Price vs. S&P 500', Xtitle = 'Date', Ytitle = '% Change in Price', slider = TRUE)
})

ts2_data <- reactive({
  req(input$pricesdaterange2, input$colselect)  # Ensure both inputs are available
  
  # Filter data based on input$pricesdate2
  filtered_data <- closingprices %>% 
    filter(Date >= input$pricesdaterange2[1] & Date <= input$pricesdaterange2[2])
  
  # Select the desired column based on input$colselect
  if (!is.null(filtered_data)) {
    filtered_data <- filtered_data %>% 
      select(Date, !!input$colselect)  # Use !! to unquote input$colselect
  }
  
  return(filtered_data)
})

output$ts2 <- renderPlotly({
  p <- ts_plot(ts2_data(), title = paste(input$colselect, 'Prices'), Xtitle = 'Date', Ytitle= 'Price per share ($)', slider = TRUE)
  sd_value <- sd(ts2_data()[[input$colselect]], na.rm = TRUE)
  mean_value <- mean(ts2_data()[[input$colselect]], na.rm = TRUE)
  p <- p %>%
    layout(
      title = list(
        text = paste0(input$colselect, ' Prices (Mean: $', round(mean_value, 2), ' SD: ', round(sd_value, 2), ')')
      )
    )
  return(p)
})

pctplot2_data <- reactive({
  req(input$pricesdaterange2, input$colselect)  # Ensure both inputs are available
  
  # Filter data based on input$pricesdate2
  filtered_data <- closingprices %>% 
    filter(Date >= input$pricesdaterange2[1] & Date <= input$pricesdaterange2[2])
  
  # Select the desired column based on input$colselect
  if (!is.null(filtered_data)) {
    filtered_data <- filtered_data %>% 
      select(Date, !!input$colselect, S.P500) %>% mutate(across(where(is.numeric), pctchange)) # Use !! to unquote input$colselect
  }
  return(filtered_data)
})

output$pctplot2 <- renderPlotly({
  ts_plot(pctplot2_data(), title = paste0(input$colselect, ' vs. S&P500 % Change'), Xtitle = 'Date', Ytitle= '% Change in Price per share ($)', slider = TRUE)
})

#------------

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
                  palette = c('#008FDF', '#008FDF','#008FDF','#008FDF','#008FDF','#008FDF','#ADD8E6', '#008FDF'), fontcolor.labels = 'black', border.col = 'gray',
                  title = paste0('S&P 500 ', input$format, ' Market Cap ($', sum(yearcheck()$SP), 'T)'), force.print.labels = TRUE,
                  padding.labels = c(5, 5, 50, 5),
                  aspRatio = NA)
  
  plot
})

#MC2
expmc <- mc %>% mutate('MAG7' = rowSums(mc[2:8])) %>% select(YearEnd, 'S&P493', MAG7)

expmc <- expmc %>% pivot_longer(2:3, names_to='biz', values_to = 'marketcap')


custom_colors <- c("S&P493" = "#ADD8E6", "MAG7" = "#008FDF")

output$mc2 <- renderPlot({
  ggplot(expmc, aes(x = YearEnd, y = marketcap, fill = biz)) + geom_col() + theme(axis.text.x = element_text(size = 10, angle = 45, vjust = .5), panel.background = element_rect(fill = '#708090')) + 
    scale_x_discrete(name = 'Year', limits = 2014:2024) + 
    labs(title = "Mag7's Share of S&P 500's Overall Market Cap", y = "Trillions USD", fill = '') + 
    scale_fill_manual(values = custom_colors)
})

#MC3
just7 <- mc %>% select(1:8)
just7 <- just7 %>% pivot_longer(2:8, names_to='biz', values_to = 'marketcap')

output$mc3 <- renderPlot({
  ggplot(just7, aes(x = YearEnd, y = marketcap, fill = biz)) + geom_col() + 
  theme(axis.text.x = element_text(size = 10, angle = 45, vjust = .5), panel.background = element_rect(fill = '#708090')) + 
  scale_x_discrete(name = 'Year', limits = 2014:2024) + 
  labs(title = "Mag7's Market Cap Breakdown", y = "Trillions USD", fill = '') + 
  scale_fill_brewer(palette = "Blues")
})





#GDP
gdpyearcheck <- eventReactive(input$format2, {
  req(input$format2)
  gdptoplot %>%
    filter(Year == input$format2)
})

format_labels <- function(labels) {
  if ("MAG7" %in% labels) {
    labels[labels == "MAG7"] <- as.expression(bquote(bold(.(labels[labels == "MAG7"]))))
  }
  return(labels)
}

output$gdp1 <- renderPlot({
  req(gdpyearcheck())
  
  GDPs <- gdpyearcheck() %>% 
    ggplot() + geom_col(aes(x= reorder(Country, -GDP), y=GDP, fill = GDP)) +
    labs(title = "Mag7 Market Cap Rivals World GDPs", x = "Country", y = "Billions USD") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = 'none', panel.background = element_rect(fill = '#708090')) +
    scale_x_discrete(labels = format_labels)
  
  return(GDPs)
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
