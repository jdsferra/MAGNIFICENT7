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
