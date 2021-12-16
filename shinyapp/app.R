library(shiny)
library(rcademy)
library(dplyr)

# Define UI for dataset viewer application
ui <- shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Journal Rankings"),

  # Sidebar with controls to select a dataset and specify the number
  # of observations to view
  sidebarPanel(
    selectInput("dataset", "Choose a rankings database:",
                choices = c("All", "ABDC", "ERA2010", "CORE", "SCImago", "Monash")),
    textInput("title", "Title to search for:", ""),
    checkboxInput("fuzzy", "Fuzzy matching?", TRUE),
    checkboxInput("only_best", "Only return the best match?", FALSE),
    width=5,
),
  # Show an HTML table with the requested
  # number of observations
  mainPanel(tableOutput("view"), width=7)
))

# Define server logic required to summarize and view the selected dataset
server <- shinyServer(function(input, output) {

  # Return the requested dataset
  datasetInput <- reactive({
    if(input$title=="")
      NULL
    else
      journal_ranking(title=input$title, source=tolower(input$dataset), fuzzy=input$fuzzy, only_best=input$only_best)
  })

  # Show the data
  output$view <- renderTable({datasetInput()})
})

shinyApp(ui = ui, server = server)
