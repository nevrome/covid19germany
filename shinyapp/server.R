# here you put the backend stuff

shinyserver <- function(input, output) {

    # # time series plot grouping federal states
    # output$rki_tsPlot_states <- renderPlot({
    #
    #     rki_pre_df %>%
    #         filter(
    #             Meldedatum >= strptime(input$dateInput[1], format="%Y-%m-%d"),
    #             Meldedatum <= strptime(input$dateInput[2], format="%Y-%m-%d")
    #         ) %>%
    #         group_RKI_timeseries("Bundesland") %>%
    #
    #         ggplot(aes(x = Meldedatum, y = KumAnzahlFall,
    #                    color = Bundesland))+
    #         geom_line()+
    #         #facet_grid(Altersgruppe~.)+
    #         labs(title = "Anzahl von offiziell gemeldeten Fällen in Deutschland")+
    #         theme_minimal()
    # })
    #
    output$rki_tsPlot <- renderPlot({

        # define date of the next monday as limit for x axis
        # in R weekday of monday is 2
        min_meldedatum <- strptime(input$dateInput[1], format="%Y-%m-%d")
        if (wday(min_meldedatum) != 2) {
            tmp_wday <- 8 - (min_meldedatum %>% wday())
            min_meldedatum <- min_meldedatum + tmp_wday*(3600*24)
        }

        # vars for plotting
        logy <- ifelse(input$logyInput == "logarithmisch" , TRUE, FALSE)
        label <- ifelse(input$labelInput == "ja" , TRUE, FALSE)

        gg <- rki_pre_df %>%
                filter(
                    Meldedatum >= min_meldedatum,
                    Meldedatum <= strptime(input$dateInput[2], format="%Y-%m-%d"),
                    Bundesland %in% input$bundeslandInput
                ) %>%
                plot_RKI_timeseries(
                    group = input$group_varInput,
                    type = input$typeInput,
                    label = label,
                    logy = logy) +
    
                scale_x_datetime(date_breaks = "1 week",
                                 date_minor_breaks = "1 week")+
                theme_minimal()+
                theme(axis.text.x.bottom = element_text(angle = 45, hjust = 1))+
                labs(x="")
        
        if (input$predInput != 0) {
            gg <- gg %>% 
                    plot_RKI_add_modelpredictions(n_days_future = input$predInput)
        }
        
        return(gg)
        
    })
}
