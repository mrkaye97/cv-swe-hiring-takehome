library(shiny)
library(dplyr)
library(jsonlite)
library(radiant.data)
library(maps)
library(mapdata)
library(viridis)
library(shinyjs)
library(see)
library(shinyWidgets)

state <- map_data("state")

locs <- read_json('locations.json') %>%
    bind_rows()

ui <- fluidPage(
    useShinyjs(),
    setBackgroundColor(
        color = "ghostwhite",
        shinydashboard = FALSE
    ),
    titlePanel("CollegeVine SWE Hiring Project"),

    sidebarLayout(
        sidebarPanel(
            selectInput('rendertype', label = 'What do you want to see?', choices = c('Table', 'Map')),
            numericInput('lat', label = "Latitude", value = 40, min = -90, max = 90),
            numericInput('long', label = "Longitude", value = -110, min = -180, max = 180),
            numericInput('maxmiles', label = "Maximum Distance", value = 100, min = 0, max = 100000),
            actionButton('renderbutton', label = 'Render', width = '100%')
        ),
        mainPanel(
           DT::dataTableOutput("dists"),
           plotOutput('map')
        )
    )
)

server <- function(input, output) {

    data <- reactiveValues()
    observeEvent(input$renderbutton, {
        data[['rendertype']] <- input$rendertype
        data[['lat']] <- input$lat
        data[['long']] <- input$long
        data[['maxmiles']] <- input$maxmiles

        if (data$rendertype == 'Table') {
            output$dists <- DT::renderDataTable({
                locs %>%
                    mutate(dist = as_distance(data$lat, data$long, address__latitude, address__longitude, unit = 'miles') %>% round()) %>%
                    arrange(dist) %>%
                    filter(dist < data$maxmiles) %>%
                    transmute(School = name,
                              City = address__city,
                              State = address__state,
                              Distance = dist)
            })
            hide('map')
            show('dists')
        } else {
            output$map <- renderPlot({
                x <- locs %>%
                    mutate(dist = as_distance(data$lat, data$long, address__latitude, address__longitude, unit = 'miles')) %>%
                    arrange(dist) %>%
                    filter(dist < data$maxmiles,
                           !address__state %in% c('Hawaii', 'Alaska'))

                ggplot(data=state, aes(x=long, y=lat, group=group)) +
                    geom_polygon(color = "black", fill = 'white') +
                    geom_point(mapping = aes(x = data$long, y = data$lat), inherit.aes = F, shape = 4, size = 6, color = 'coral') +
                    geom_point(data = x, mapping = aes(x = address__longitude, y = address__latitude, color = dist), size = 4, inherit.aes = F) +
                    guides(fill=FALSE) +
                    coord_fixed(1.3) +
                    theme_blackboard() +
                    theme(axis.line=element_blank(),axis.text.x=element_blank(),
                            axis.text.y=element_blank(),axis.ticks=element_blank(),
                            axis.title.x=element_blank(),
                            axis.title.y=element_blank(),legend.position="none",
                            panel.border=element_blank(),panel.grid.major=element_blank(),
                            panel.grid.minor=element_blank()) +
                    scale_color_viridis_c(end = .9) +
                    labs(color = 'Distance',
                         caption = 'The red X marks your location. Dots are schools. \nThe color of the dots corresponds to the distance to the school from you.')
            })
            hide('dists')
            show('map')
        }
    })


}

shinyApp(ui = ui, server = server)
