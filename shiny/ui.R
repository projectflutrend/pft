#ui
require(shiny)
require(ggplot2)

available_inputs=NULL; available_outcomes=NULL
for(i in 1:length(list_of_inputs)){
  available_inputs[i]=length(list_of_inputs[[i]][[1]][[1]])==4
}
for(i in 1:length(list_of_outcomes)){
  available_outcomes[i]=sum(!is.na(list_of_outcomes[[i]]$dependents[,-1]))>0
}
list_of_inputs<-list_of_inputs[available_inputs]
list_of_outcomes<-list_of_outcomes[available_outcomes]
language_table<-language_table[language_table$ISO_639_1 %in% names(list_of_inputs),]
country_list<-country_list[country_list$description %in% names(list_of_outcomes),]

shinyUI(fluidPage(
  titlePanel("WikipediaFluTrend.alpha"),
  
  navbarPage("-->",
             tabPanel("Model Setup",
                      sidebarPanel("Select:", 
                                   
                                   # Country
                                   selectInput("pft_model.country", "Country", 
                                               choices = country_list$description,selected="netherlands"),
                                   
                                   selectInput("pft_model.type_of_outcome", "Type of outcome", 
                                               choices = names(list_of_outcomes[[1]]$dependents[,-1])),
                                   
                                   
                                   # Wiki language 
                                   selectInput("pft_model.lang", "Wikipedia language code", 
                                               choices = language_table$language,selected="Dutch; Flemish"),
                                   # Type of input
                                   selectInput("pft_model.type_of_input", "type of input", multiple = T,
                                               choices = names(list_of_inputs$de),
                                               selected = "wiki_primary"),
                                   # Start and End date selector
                                   dateRangeInput("pft_model.start.end.dates", "Set Time period",
                                                  #start = "2010-01-01",end="2016-12-31",
                                                  min="2010-01-01",max=Sys.Date(),
                                                  startview = "year"),
                                   # method
                                   selectInput("pft_model.method","choose a modelling method",
                                               choices=c("cv","simple.lm","cubic.lm"), selected = "simple.lm"),
                                   br(),
                                   # training period
                                   textInput("pft_model.training_period","On how many days should the model be trained?",
                                             value="past"),
                                   # detrend
                                   checkboxInput("pft_model.detrending", "Seasonal decomposition?",
                                                 value=T),
                                   # detrend
                                   checkboxInput("pft_model.detrend_robust", "robust detrending?",
                                                 value=T),
                                   # detrend window
                                   numericInput("pft_model.detrend_window","loess t.window (multiple of 7)",
                                                value=21),
                                   # time_lag
                                   numericInput("pft_model.time_lag","time lag in days",
                                                value=0),
                                   br(),br(),
                                   "Futher options:",
                                   # cv_fold
                                   textInput("pft_model.cv_fold","cv by (M,Y or a number of days)",
                                             value="M"),
                                   # cv_lambda
                                   selectInput("pft_model.lambda","CV lamda",
                                             choices = c("1se","min"),selected = "1se"),
                                  
                                   # Normalization
                                   checkboxInput("pft_model.wiki_normalization", "random normalization",
                                                 value=F),
                                   actionButton("do", "Run model 1!"),
                                   actionButton("do2", "Run model 2!")
                                   
                      ),
                      mainPanel("Model 1 evaluation statistic",
                                tableOutput("summary.stats1"),
                                br(),
                                "-------------------------------------------------------------------------",
                                br(),
                                "Model 2 evaluation statistic",
                                tableOutput("summary.stats2"))
             ), # tab panel 1 end here
             
             tabPanel("Evaluation plots",
                      sidebarPanel("Evaluate model performance",br(), br(),
                                   "Plot 1 options:",
                                   sliderInput("zoom",  
                                               "ZOOM in/out", min=as.Date("2010-01-01"),
                                               max=as.Date("2017-01-01"),
                                               value=c(as.Date("2010-02-02"),as.Date("2014-01-01") ),timeFormat="%F"), 
                                   
                                   selectInput("plot.selection", "Select diagnostic plot:", 
                                               choices = c("test_actual_rate",
                                                           "test_actual_vs_pred_all",
                                                           "test_actual_vs_pred_d7",
                                                           "test_actual_vs_pred_d14",
                                                           "test_actual_vs_pred_d21",
                                                           "test_actual_vs_pred_d28",
                                                           "training_actual_rate",
                                                           "training_actual_vs_pred",
                                                           "training_diff_plot"    ),
                                               selected ="test_actual_rate" ),
                                   
                                   ##### 2nd plot
                                   br(),br(),
                                   
                                   "Plot 2 options:",
                                   sliderInput("zoom2",  
                                               "ZOOM in/out", min=as.Date("2010-01-01"),
                                               max=as.Date("2017-01-01"),
                                               value=c(as.Date("2010-02-02"),as.Date("2014-01-01") ),timeFormat="%F"), 
                                   
                                   selectInput("plot.selection2", "Select diagnostic plot:", 
                                               choices = c("test_actual_rate",
                                                           "test_actual_vs_pred_all",
                                                           "test_actual_vs_pred_d7",
                                                           "test_actual_vs_pred_d14",
                                                           "test_actual_vs_pred_d21",
                                                           "test_actual_vs_pred_d28",
                                                           "training_actual_rate",
                                                           "training_actual_vs_pred",
                                                           "training_diff_plot"    ),
                                               selected ="test_actual_rate" )
                                   
                      ),
                      mainPanel(plotOutput("e1_plot"),
                                plotOutput("e2_plot"))
             ), # tab panel 2 ends here
             
             tabPanel("single date plots",
                      sidebarPanel("Select date of last data input to see how the model would hvae performed over the following 28 days.",br(), br(),
                                   sliderInput("pickdate",  
                                               "Evaluate Model 1", min=as.Date("2010-01-01"),
                                               max=as.Date("2017-01-01"), 
                                               value=as.Date("2010-02-02"),timeFormat="%F"),
                                   br(),br(),br(),
                                   "Select date of last data input to see how the model would hvae performed over the following 28 days.",br(), br(),
                                   sliderInput("pickdate2",  
                                               "Evaluate Model 2", min=as.Date("2010-01-01"),
                                               max=as.Date("2017-01-01"), 
                                               value=as.Date("2010-02-02"),timeFormat="%F")
                                   ),
                      mainPanel(plotOutput("pick"),plotOutput("pick2"))
             ),
             tabPanel("Nowcast",
                      sidebarPanel("'Nowcasting' today's Influenza activity",
                                   br(),br(),
                                   actionButton("nowcast","nowcast for model 1"),
                                   br(),br(),
                                   actionButton("nowcast2","nowcast for model 2")),
                      
                      mainPanel(plotOutput("nowcast.plot"),plotOutput("nowcast.plot2"))
             ),
             tabPanel("Forecast",
                      sidebarPanel("Facebook's 'Prophet' Forecasting,",br(),"Based on the Influenza incidence data.",br(),"Please make sure you have sufficient (>2 years) training data",
                                   br(),br(),
                                   actionButton("forecast","forecast for model 1"),
                                   selectInput("days.forecast","Days forecast",
                                                choices =c("28","56","182","365"),selected = "28"),
                                   br(),br(),
                                   actionButton("forecast2","forecast for model 2"),
                                   selectInput("days.forecast2","Days forecast",
                                               choices =c("28","56","182","365"),selected = "28")),
                                   
                      
                                  # actionButton("nowcast2","nowcast for model 2")),
                      
                      mainPanel(plotOutput("forecast.plot"),plotOutput("forecast.plot2")
                                )
             ),
             tabPanel("Comparison",
                      sidebarPanel("Comparing Wikipedia Nowcast with Prophet forecast",
                                   br(),br(),
                                   actionButton("comparison","Comparison for model 1"),
                                   br(),br(),
                                   actionButton("comparison2","Comparison for model 2")
                                  ),
                      
                      mainPanel(plotOutput("comparison.plot"),plotOutput("comparison.plot2")
                                )
             ),
             tabPanel("Examples",sidebarPanel( "You can store examples using \n",
                                               br(),"\n",                                             
                                               br(),"\n",
                                               "'list1<-list(e1,m1,info1)'",br(),
                                               "'list2<-list(e2,m2,info2)'",br(),
                                               "'example1a<-list1' \n",br(),
                                               "'example1b<-list2' \n etc...",
                                               br(),"\n",                                             
                                               br(),"\n",
                                               actionButton("example.1","load Example.1"),
                                               br(),br(),
                                               actionButton("example.2","load Example.2"),
                                               br(),br(),
                                               actionButton("example.3","load Example.3"))
                                               
                                               )# tab panel 3 ends here
             
             
  ),
  
  
  
  title = "WikiFLuTrend"
  
  
  
)) 
