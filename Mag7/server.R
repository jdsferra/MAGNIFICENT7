shinyServer(function(input, output) {
#Server logic for Price Data Tab

#Tab1
  #Checkbox to use daily or monthly price dataframe
  selected_df <- reactive({
    if (input$monthlyAvg1) {
      monthavg
    } else {
      closingprices
    }
  })
  
  #Filters selected_df by date
  datefilter <- reactive({
    req(input$pricesdate) 
    req(selected_df())
      selected_df() %>% filter(Date >= input$pricesdate)
  })
  
  #Defines percent change function
  pctchange = function(x){
    (x - first(x))/first(x)*100
  }  
  
  #Applies percent change function
  addpctchg <- reactive({
    data <- datefilter()
    if(!is.null(data)) {
      data %>% mutate(across(where(is.numeric), pctchange))
    } else {NULL}
  })
  
  #Plots- ts1: Closing Prices, pctplot: Percent Change Plot
  output$ts1 <- renderPlotly({
    req(datefilter())
    ts_plot(datefilter()[-9], title = if (input$monthlyAvg1) 'Monthly Average Magnificent 7 Closing Prices' else 'Magnificent 7 Closing Prices', Xtitle = 'Date', Ytitle = 'Price per share ($)', slider = TRUE)
  })  
  
  output$pctplot <- renderPlotly({
    req(addpctchg())
    ts_plot(addpctchg(), title = if (input$monthlyAvg1) '% Change in Average Monthly Price vs. S&P 500' else '% Change in Price vs. S&P 500', Xtitle = 'Date', Ytitle = '% Change in Price', slider = TRUE)
  })
  
#Tab2
  #(similar to selected_df)
  selected_df2 <- reactive({
    if (input$monthlyAvg2) {
      monthavg
    } else {closingprices}
  })  
  
  #Filters selected_df2 by date and selects individual column to plot
  ts2_data <- reactive({
    req(input$pricesdaterange2, input$colselect, selected_df2())
    
    #Filter on date
    filtered_data <- selected_df2() %>% 
      filter(Date >= input$pricesdaterange2[1] & Date <= input$pricesdaterange2[2])
    
    #Select column
    if (!is.null(filtered_data)) {
      filtered_data <- filtered_data %>% 
        select(Date, !!input$colselect)  # Use !! to unquote input$colselect
                                  }
    return(filtered_data)
  })
  
  #Plot- ts2: Closing Prices of Selected Stock with Mean and SD in Title
  output$ts2 <- renderPlotly({
    #Basic plot
    p <- ts_plot(ts2_data(), Xtitle = 'Date', Ytitle= 'Price per share ($)', slider = TRUE)
    
    #Calculate mean and sd
    mean_value <- mean(ts2_data()[[input$colselect]], na.rm = TRUE)
    sd_value <- sd(ts2_data()[[input$colselect]], na.rm = TRUE)
    
    #Conditional formatting for title
    p <- p %>%
      layout(
        title = if (input$monthlyAvg2) paste0('Monthly Average ', input$colselect, ' Closing Prices (Mean: $', round(mean_value, 2), ' SD: ', round(sd_value, 2), ')')
          else paste0(input$colselect, ' Prices (Mean: $', round(mean_value, 2), ' SD: ', round(sd_value, 2), ')')
            )
      return(p)
    })
  
  #Filters selected_df2 by date and selects individual column and S&P for comparison plot
  pctplot2_data <- reactive({
    req(input$pricesdaterange2, input$colselect, selected_df2())  # Ensure both inputs are available
    
    # Filter on date
    filtered_data <- selected_df2() %>% 
      filter(Date >= input$pricesdaterange2[1] & Date <= input$pricesdaterange2[2])
    
    # Select desired column and S&P
    if (!is.null(filtered_data)) {
      filtered_data <- filtered_data %>% 
        select(Date, !!input$colselect, S.P500) %>% mutate(across(where(is.numeric), pctchange)) # Use !! to unquote input$colselect
    }
      return(filtered_data)
    })
  
  #Plot - pctplot2: % Change in Closing Prices of Selected Stock vs. S&P
  output$pctplot2 <- renderPlotly({
    
    #Basic plot
    p <- ts_plot(pctplot2_data(), title = paste0(input$colselect, ' vs. S&P500 % Change'), Xtitle = 'Date', Ytitle= '% Change in Price per share ($)', slider = TRUE)
    
    #Conditional formatting for title
    p <- p %>%
      layout(
        title = if (input$monthlyAvg2) paste0('% Change in ', input$colselect, ' Average Monthly Price vs. S&P500')
        else paste0('% Change in ', input$colselect, ' Price vs. S&P500')
      )
    return(p)
    })
  
#Server Logic for Market Cap Tab
#Tab1- MAG7 vs. S&P
  #Filters mc by slider year for treemap plot
  yearcheck <- eventReactive(input$format, {
    req(input$format)
    mc %>%
      filter(YearEnd == input$format)
  })
  
  #Pivots filtered mc for plotting
  pivotyearcheck <- eventReactive(yearcheck(), {
    req(yearcheck())
    yearcheck() %>% pivot_longer(2:10, names_to = 'biz', values_to = 'marketcap') %>% group_by(biz) %>%
    mutate(fulllabel=paste(biz, paste0('$',marketcap,'T'), sep = '\n'))
  })

  #Plot: mc1: Treemap showing breakdown of S&P Market Cap
  output$mc1 <- renderPlot({
    req(pivotyearcheck())
    
    plot <- treemap(pivotyearcheck()[-9, ], index = 'fulllabel', vSize = 'marketcap',
                    palette = c('#008FDF', '#008FDF','#008FDF','#008FDF','#008FDF','#008FDF','#ADD8E6', '#008FDF'), fontcolor.labels = 'black', border.col = 'gray',
                    title = paste0('S&P 500 ', input$format, ' Market Cap ($', sum(yearcheck()$SP), 'T)'), force.print.labels = TRUE,
                    padding.labels = c(5, 5, 50, 5),
                    aspRatio = NA)
    plot
  })

  #Processing for second plot
  expmc <- mc %>% mutate('MAG7' = rowSums(mc[2:8])) %>% select(YearEnd, 'S&P493', MAG7)
  expmc <- expmc %>% pivot_longer(2:3, names_to='biz', values_to = 'marketcap')
  custom_colors <- c("S&P493" = "#ADD8E6", "MAG7" = "#008FDF")
  
  #Plot: mc2: Stacked bar chart comparing S&P vs. MAG7 as one unit
  output$mc2 <- renderPlot({
    ggplot(expmc, aes(x = YearEnd, y = marketcap, fill = biz)) + geom_col() + theme(axis.text.x = element_text(size = 10, angle = 45, vjust = .5), panel.background = element_rect(fill = '#708090')) + 
      scale_x_discrete(name = 'Year', limits = 2014:2024) + 
      labs(title = "Mag7's Share of S&P 500's Overall Market Cap", y = "Trillions USD", fill = '') + 
      scale_fill_manual(values = custom_colors)
  })

  #Processing for third plot
  just7 <- mc %>% select(1:8)
  just7 <- just7 %>% pivot_longer(2:8, names_to='biz', values_to = 'marketcap')

  #Plot: mc3: Stacked bar chart of MAG7 separated
  output$mc3 <- renderPlot({
    ggplot(just7, aes(x = YearEnd, y = marketcap, fill = biz)) + geom_col() + 
    theme(axis.text.x = element_text(size = 10, angle = 45, vjust = .5), panel.background = element_rect(fill = '#708090')) + 
    scale_x_discrete(name = 'Year', limits = 2014:2024) + 
    labs(title = "Mag7's Market Cap Breakdown", y = "Trillions USD", fill = '') + 
    scale_fill_brewer(palette = "Blues")
  })

#Tab2- MAG7 vs. World GDP's
  #Filters GDP data by year slider
  gdpyearcheck <- eventReactive(input$format2, {
    req(input$format2)
    gdptoplot %>%
      filter(Year == input$format2)
  })
  
  #Function to bold "MAG7" in bar chart
  format_labels <- function(labels) {
    if ("MAG7" %in% labels) {
      labels[labels == "MAG7"] <- as.expression(bquote(bold(.(labels[labels == "MAG7"]))))
    }
    return(labels)
  }
  
  #Plot: gdp1: Bar chart comparing MAG7 to World GDPs
  output$gdp1 <- renderPlot({
    req(gdpyearcheck())
    
    GDPs <- gdpyearcheck() %>% 
      ggplot() + geom_col(aes(x= reorder(Country, -GDP), y=GDP, fill = GDP)) +
      labs(title = paste0(input$format2, ": Mag7 Market Cap Rivals World GDPs"), x = "Country", y = "Billions USD") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = 'none', panel.background = element_rect(fill = '#708090')) +
      scale_x_discrete(labels = format_labels) +
      scale_y_continuous(limits = c(0, 30000))
    
    return(GDPs)
  })

#Server Logic for Contact
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
