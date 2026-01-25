source("../../../diyabcGUI/R-pkg/R/22_historical_model_display.R")
source("../../../diyabcGUI/R-pkg/R/21_historical_model.R")
source("../../../diyabcGUI/R-pkg/R/02_regex.R")
source("../../../diyabcGUI/R-pkg/R/22_historical_model_display.R")
source("../../../diyabcGUI/R-pkg/R/21_historical_model.R")
text <- str_c("N1 N2 N3 N4 N5",
              "0 sample 1",
              "0 sample 2",
              "0 sample 3",
              "0 sample 4",
              "0 sample 5",
              "t15 merge 1 2",
              "t15-db varNe 1 N5b",
              "t23 merge 3 4",
              "t23-db varNe 3 N3b",
              "t12 merge 1 5",
              "t12-db varNe 1 N2b",
              "t14 merge 1 3",
              "t14-db varNe 1 N4b", sep = "\n")
parsed_scenario <- parse_scenario(text)
data2plot <- prepare_hist_model_display(parsed_scenario, 3)
g1 <- display_hist_model(data2plot)
g1$data$text = NA
g1 = g1 + scale_colour_manual(values = c("orange","gold","black", "cornflowerblue","black","purple","black", "darkgreen","black")) + theme(legend.position = "")
text <- str_c("N1 N2 N3 N4 N5",
              "0 sample 1",
              "0 sample 2",
              "0 sample 3",
              "0 sample 4",
              "0 sample 5",
              "t15 merge 1 2",
              "t15-db varNe 1 N5b",
              "t23 merge 3 4",
              "t23-db varNe 3 N3b",
              "t12 merge 3 5",
              "t12-db varNe 3 N2b",
              "t14 merge 1 3",
              "t14-db varNe 1 N4b", sep = "\n")
parsed_scenario <- parse_scenario(text)
data2plot <- prepare_hist_model_display(parsed_scenario, 3)
g2 <- display_hist_model(data2plot)
g2$data$text = NA
g2 = g2 + scale_colour_manual(values = c("orange","gold","black", "cornflowerblue","black","purple","black", "darkgreen","black")) + theme(legend.position = "")
text <- str_c("N1 N2 N3 N4 N5",
              "0 sample 1",
              "0 sample 2",
              "0 sample 3",
              "0 sample 4",
              "0 sample 5",
              "t15 split 5 2 4 r1",
              "t23 merge 2 1",
              "t23-db varNe 2 N3b",
              "t12 merge 4 3",
              "t12-db varNe 4 N2b",
              "t14 merge 2 4",
              "t14-db varNe 2 N4b", sep = "\n")
parsed_scenario <- parse_scenario(text)
data2plot <- prepare_hist_model_display(parsed_scenario, 3)
g3 <- display_hist_model(data2plot)
g3$data$text = NA
g3 = g3 + scale_colour_manual(values = c("orange","gold","black", "cornflowerblue","black","purple","black", "darkgreen","black")) + theme(legend.position = "")
text <- str_c("N1 N2 N3 N4 N5",
              "0 sample 1",
              "0 sample 2",
              "0 sample 3",
              "0 sample 4",
              "0 sample 5",
              "t15 split 5 1 3 r1",
              "t23 merge 4 3",
              "t23-db varNe 4 N3b",
              "t12 merge 2 1",
              "t12-db varNe 2 N2b",
              "t14 merge 2 4",
              "t14-db varNe 2 N4b", sep = "\n")
parsed_scenario <- parse_scenario(text)
data2plot <- prepare_hist_model_display(parsed_scenario, 3)
g4 <- display_hist_model(data2plot)
g4$data$text = NA
g4 = g4 + scale_colour_manual(values = c("orange","gold","black", "cornflowerblue","black","purple","black", "darkgreen","black")) + theme(legend.position = "")
text <- str_c("N1 N2 N3 N4 N5",
              "0 sample 1",
              "0 sample 2",
              "0 sample 3",
              "0 sample 4",
              "0 sample 5",
              "t15 merge 1 2",
              "t15-db varNe 1 N5b",
              "t23 merge 3 4",
              "t23-db varNe 3 N3b",
              "t12 split 5 1 3 r1",
              "t14 merge 1 3",
              "t14-db varNe 1 N4b", sep = "\n")
parsed_scenario <- parse_scenario(text)
data2plot <- prepare_hist_model_display(parsed_scenario, 5)
g5 <- display_hist_model(data2plot)
g5$data$text = NA
g5 = g5 + scale_colour_manual(values = c("orange","gold", "cornflowerblue","black", "purple","black", "darkgreen","black")) + theme(legend.position = "")
pdf("../Figures/diyabc.pdf", width = 8, height = 4)
plot_grid(plotlist = c(g1,g2,g3,g4,g5))