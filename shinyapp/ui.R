# here goes the user-interface were you define input elemetns and
# call the plots or tables as output

fluidPage(
    
    navbarPage("COVID-19 in Germany/Deutschland",

        tabPanel("Reported Data / Gemeldete Daten",
            sidebarLayout(
                sidebarPanel(
            
                # input slider to limit date range of ts plot
                dateRangeInput(inputId = "dateInput",
                               label = "Date / Datum",
                               start = substr((as.character(min(rki_pre_df$Date, na.rm = TRUE))),1,10),
                               end = substr((as.character(max(rki_pre_df$Date, na.rm = TRUE))),1,10),
                               min = substr((as.character(min(rki_pre_df$Date, na.rm = TRUE))),1,10),
                               max = substr((as.character(max(rki_pre_df$Date, na.rm = TRUE))),1,10),
                               format = "yyyy-mm-dd",
                               startview = "month",
                               weekstart = 1
                               ),
            
                # select grouping variabel for plot
                selectInput(inputId = "group_varInput",
                            label = "Grouping / Gruppierung",
                            choices = c("Bundesland", "Landkreis", "Gender",
                                        "Age")),
            
                # select y-axis variable for plot
                selectInput(inputId = "typeInput",
                            label = "Count type / Zählinformation",
                            choices = c("CumNumberTestedIll", "CumNumberDead", "NumberNewTestedIll",
                                        "NumberNewDead")),
            
                # select axis transformation
                radioButtons(inputId = "logyInput",
                             label = "y-axis / y-Achse",
                            choices = c("linear", "logarithmisch")),
            
                # select labels
                radioButtons(inputId = "labelInput",
                             label = "Labels / Beschriftungen",
                             choices = c("ja", "nein")),
            
                # wirvsvirus logo
                tags$img(src = "Logo_Projekt_02.png",
                         width = "275px", height = "100px"),
            
                #tags$p(class="header", checked=NA,
                #
            
                # adding the new div tag to the sidebar
                tags$div(class="header", checked=NA,
                    list(
                        tags$p(
                        tags$a(href="https://github.com/nevrome/covid19germany", "GitHub")),
            
                        tags$p(
                            tags$a(href="https://devpost.com/software/0999_zahlenundkurven_prognosedashboard",
                                   "DevPost")),
            
                        HTML(paste("Data accessed on / Daten abgerufen am",
                                    Sys.time(),
                                    tags$a(href="https://npgeo-corona-npgeo-de.hub.arcgis.com/search?groupIds=b28109b18022405bb965c602b13e1bbc",
                                           "from / vom RKI"))))
                )
            
                ),
            
                # Show a plot of the generated distribution
                mainPanel(
                   plotOutput(outputId ="rki_tsPlot")
                )
            )
        ),
        
        tabPanel("Hochrechnungen / Estimations",
            sidebarLayout(
                sidebarPanel(
                    
                    selectInput(
                        inputId = "est_group",
                        label = "Grouping / Gruppierung",
                        choices = c("Keine", "Bundesland", "Landkreis", "Gender", "Age"),
                        selected = "Keine"
                    ),
                    
                    selectInput(
                        inputId = "est_unit",
                        label = "Unit / Einheit",
                        choices = "Keine"
                    ),
                    
                    numericInput(
                        inputId = "prop_death",
                        label = "Probability of death / Sterbewahrscheinlichkeit",
                        value = 0.01,
                        step = 0.01
                    ),
                    
                    sliderInput(
                        inputId = "mean_days_until_death",
                        label = "Number of days from infection to death / Durchschnittliche Zeit von Infektion bis Tod (im Todesfall)",
                        min = 14, max = 56, value = 17
                    ),
                    
                    numericInput(
                        inputId = "doubling_time",
                        label = "Doubling time of the number of infections (days) / Zeit in der sich die Zahl der Infizierten verdoppelt (in Tagen)",
                        value = 4
                    ),

                    radioButtons(inputId = "est_logy",
                                 label = "y-axis / y-Achse",
                                 choices = c("linear", "logarithmisch"))
                    
                ),
                mainPanel(
                    plotOutput(outputId = "rki_est_plot")
                )
            )
        )
    
    )

)

