# here you put the backend stuff

shinyserver <- function(input, output, session) {

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

        rki_pre_df %>%
            filter(
                Meldedatum >= min_meldedatum,
                Meldedatum <= strptime(input$dateInput[2], format="%Y-%m-%d")
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
            labs(x="")#+
            # annotate("text", x = min_meldedatum,
            #          y = 25, label = "Some text")
    })
    
    output$rki_est_plot <- renderPlot({
        
        rki_sel <- rki_df
        if (input$est_group != "Keine") {
            rki_sel <- rki_sel[rki_sel[[input$est_group]] == input$est_unit, ]
        }
        
        de <- estimatepast_RKI_timeseries(
                rki_sel,
                prop_death = input$prop_death, 
                mean_days_until_death = input$mean_days_until_death, 
                doubling_time = input$doubling_time
            ) %>%
            dplyr::select(-AnzahlFall, -AnzahlTodesfall) %>%
            tidyr::pivot_longer(cols = c(
                "KumAnzahlFall", "HochrechnungInfektionennachToden", "HochrechnungDunkelziffer",
                "KumAnzahlTodesfall", "HochrechnungTodenachDunkelziffer"
            ), names_to = "Anzahltyp"
        )
        
        p1 <- de %>% dplyr::filter(Anzahltyp %in% c("KumAnzahlFall", "HochrechnungInfektionennachToden", "HochrechnungDunkelziffer")) %>% 
            ggplot() + geom_line(
                ggplot2::aes(Meldedatum, value, color = Anzahltyp), size = 2, alpha = 0.7
            ) + theme_minimal() + guides(color = guide_legend(nrow = 3)) + scale_y_continuous(labels = scales::comma) + 
            scale_color_brewer(palette = "Set2") + xlab("") + ylab("")
        p2 <- de %>% dplyr::filter(Anzahltyp %in% c("KumAnzahlTodesfall", "HochrechnungTodenachDunkelziffer")) %>% 
            ggplot() + geom_line(
                ggplot2::aes(Meldedatum, value, color = Anzahltyp), size = 2, alpha = 0.7
            ) + theme_minimal() + guides(color = guide_legend(nrow = 2)) + scale_y_continuous(labels = scales::comma) +
            scale_color_brewer(palette = "Accent") + xlab("") + ylab("")
        
        logy <- ifelse(input$est_logy == "logarithmisch" , TRUE, FALSE)
        if (logy) {
            p1 <- p1 + ggplot2::scale_y_log10() 
            p2 <- p2 + ggplot2::scale_y_log10() 
        }
        
        cowplot::plot_grid(p1, p2, align = "hv", nrow = 2)
    })
    
    observeEvent(input$estimate_doubling_time, {
        est_doubling_time <- optim(par = 4, min_doubling_time)$par
        shiny::updateNumericInput(session, "doubling_time", value = est_doubling_time)
    })
    
    min_doubling_time <- function(x) {
        
        rki_sel <- rki_df
        if (input$est_group != "Keine") {
            rki_sel <- rki_sel[rki_sel[[input$est_group]] == input$est_unit, ]
        }
        
        es <- estimatepast_RKI_timeseries(
            rki_sel, 
            prop_death = input$prop_death, 
            mean_days_until_death = input$mean_days_until_death, 
            doubling_time = x
        )
        sum(abs(es$KumAnzahlTodesfall - es$HochrechnungTodenachDunkelziffer), na.rm = T)
    }
    
    observeEvent(input$est_group, {
        if (input$est_group == "Keine") {
            shiny::updateSelectInput(session, "est_unit", choices = "Keine")
        } else {
            shiny::updateSelectInput(session, "est_unit", choices = unique(rki_df[[input$est_group]]))
        }
    })
    
}
