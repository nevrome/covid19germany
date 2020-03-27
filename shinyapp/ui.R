# here goes the user-interface were you define input elemetns and
# call the plots or tables as output

fluidPage(
    
    navbarPage("Covid19 Meldungen in Deutschland",

        tabPanel("Gemeldete Daten",
            sidebarLayout(
                sidebarPanel(
            
                # input slider to limit date range of ts plot
                dateRangeInput(inputId = "dateInput",
                               label = "Date",
                               start = substr((as.character(min(rki_pre_df$Meldedatum, na.rm = TRUE))),1,10),
                               end = substr((as.character(max(rki_pre_df$Meldedatum, na.rm = TRUE))),1,10),
                               min = substr((as.character(min(rki_pre_df$Meldedatum, na.rm = TRUE))),1,10),
                               max = substr((as.character(max(rki_pre_df$Meldedatum, na.rm = TRUE))),1,10),
                               format = "yyyy-mm-dd",
                               startview = "month",
                               weekstart = 1
                               ),
            
                # select grouping variabel for plot
                selectInput(inputId = "group_varInput",
                            label = "Gruppierung",
                            choices = c("Bundesland", "Landkreis", "Geschlecht",
                                        "Altersgruppe")),
            
                # select y-axis variable for plot
                selectInput(inputId = "typeInput",
                            label = "Zeige",
                            choices = c("KumAnzahlFall", "KumAnzahlTodesfall", "AnzahlFall",
                                        "AnzahlTodesfall")),
            
                # select axis transformation
                radioButtons(inputId = "logyInput",
                             label = "Darstellung y-Achse",
                            choices = c("linear", "logarithmisch")),
            
                # select labels
                radioButtons(inputId = "labelInput",
                             label = "Beschriftungen",
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
            
                        HTML(paste("Data accessed on",
                                    Sys.time(),
                                    tags$a(href="https://npgeo-corona-npgeo-de.hub.arcgis.com/search?groupIds=b28109b18022405bb965c602b13e1bbc",
                                           "from RKI"))))
                )
            
                ),
            
                # Show a plot of the generated distribution
                mainPanel(
                   plotOutput(outputId ="rki_tsPlot")
                )
            )
        ),
        
        tabPanel("Hochrechnungen",
            sidebarLayout(
                sidebarPanel(
                    
                    selectInput(
                        inputId = "est_group",
                        label = "Gruppierung",
                        choices = c("Keine", "Bundesland", "Landkreis", "Geschlecht", "Altersgruppe"),
                        selected = "Keine"
                    ),
                    
                    selectInput(
                        inputId = "est_unit",
                        label = "Zeige",
                        choices = "Keine"
                    ),
                    
                    numericInput(
                        inputId = "prop_death",
                        label = "Sterbewahrscheinlichkeit",
                        value = 0.01
                    ),
                    
                    sliderInput(
                        inputId = "mean_days_until_death",
                        label = "Durchschnittliche Zeit von Infektion bis Tod (im Todesfall)",
                        min = 14, max = 20, value = 17
                    ),
                    
                    numericInput(
                        inputId = "doubling_time",
                        label = "Verdopplungszeit: Zeit (in Tagen) in der sich die Zahl der Infizierten verdoppelt",
                        value = 4
                    ),

                    actionButton("estimate_doubling_time", "Verdopplungszeit abschätzen"),

                    radioButtons(inputId = "logyInput",
                                 label = "Darstellung y-Achse",
                                 choices = c("linear", "logarithmisch"))
                    
                ),
                mainPanel(
                    plotOutput(outputId = "rki_est_plot")
                )
            )
        )
    
    )

)

