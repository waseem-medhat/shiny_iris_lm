library(shiny)
library(ggplot2)

theme_set(theme_bw(base_size = 16))

pval_format <- function(p) {
  ifelse(p < 0.05, paste0(format(p, digits = 3), "*"), format(p, digits = 3))
}

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
      )
    ),
    
    mainPanel(
      plotOutput("scatter"),
      tableOutput("summary")
    )
    
  )
)

server <- function(input, output) {
  
  output$scatter <- renderPlot({
    
    validate(
      need(input$x != input$y, "Error: the same variable is chosen twice.")
    )
    
    if (input$x == "Species") {
      ggplot(NULL, aes(x = iris[,input$x], y = iris[,input$y])) +
        geom_boxplot() +
        labs(x = input$x, y = input$y)
    } else {
      ggplot(NULL, aes(x = iris[,input$x], y = iris[,input$y])) +
        geom_point() +
        geom_smooth(method = "lm", se = FALSE) +
        labs(x = input$x, y = input$y)
    }
    
  })
  
  output$summary <- renderTable({
    
    if (input$x == input$y) {
      NULL
    } else if (input$x == "Species") {
      
      iris_lm <- lm(as.formula(paste0(input$y, "~", input$x)), data = iris)
      
      data.frame(
        intercept = coef(iris_lm)[[1]],
        versicolor_vs_setosa = coef(iris_lm)[[2]],
        virginica_vs_setosa = coef(iris_lm)[[3]],
        R_squared = summary(iris_lm)$r.squared,
        F_statistic = summary(iris_lm)$fstatistic[1],
        F_pvalue =  pval_format( summary(aov(iris_lm))[[1]]$`Pr(>F)`[1] )
      )
      
    } else {
      
      iris_lm <- lm(as.formula(paste0(input$y, "~", input$x)), data = iris)
      
      data.frame(
        intercept = coef(iris_lm)[[1]],
        slope = coef(iris_lm)[[2]],
        R_squared = summary(iris_lm)$r.squared,
        F_statistic = summary(iris_lm)$fstatistic[1],
        F_pvalue = pval_format( summary(aov(iris_lm))[[1]]$`Pr(>F)`[1] )
      )
      
    }
    
  })
  
}

shinyApp(ui, server)