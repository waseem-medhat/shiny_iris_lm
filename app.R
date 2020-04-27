library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Simple Linear Regression on the Iris dataset"),
  sidebarLayout(
    
    sidebarPanel(
      selectInput(
        "y",
        "Dependent/response variable",
        choices = names(iris)[1:4]
      ),
      selectInput(
        "x",
        "Inependent/explanatory variable",
        choices = names(iris),
        selected = "Sepal.Width"
      ),
      textOutput("error")
    ),
    
    mainPanel(
      plotOutput("scatter"),
      tableOutput("summary")
    )
    
  )
)

server <- function(input, output) {
  
  output$scatter <- renderPlot({
    if (input$x == input$y) {
      ggplot()
    } else {
      ggplot(NULL, aes(x = iris[,input$x], y = iris[,input$y])) +
        geom_point() +
        geom_smooth(method = "lm", se = FALSE)
    }
  })
  
  output$summary <- renderTable({
    data.frame(
      intercept = 0,
      slope = 0,
      R_squared = 0,
      F_statistic = 0,
      F_pvalue = 0
    )
  })
  
  output$error <- renderText({
    ifelse(input$x == input$y, "Error: the same variable is chosen twice.", "")
  })
  
}

shinyApp(ui, server)