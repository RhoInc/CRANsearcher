# for R CMD check NOTE about global vars
if(getRversion() >= "2.15.1")  utils::globalVariables(c(".", "Package","Published","name",
                                                        "Title","Description","term","months_since",
                                                        "snapshot_date","cran_inventory"))

## function to get packages
getPackages <- function() {
  repo <- ifelse(is.na(getOption("repos")["CRAN"]), getOption("repos")[[1]], getOption("repos")["CRAN"])
  description <- sprintf("%s/web/packages/packages.rds", repo)
  con <- if(substring(description, 1L, 7L) == "file://") {
    file(description, "rb")
  } else {
    url(description, "rb")
  }
  on.exit(close(con))
  db <- readRDS(gzcon(con))
  rownames(db) <- NULL
  db[, c("Package", "Version","Title","Description","Published","License")]
}


#' CRANsearcher
#'
#' Addin for searching packages in CRAN database based on keywords
#' @import dplyr
#' @importFrom curl has_internet
#' @import shiny
#' @import miniUI
#' @importFrom lubridate interval
#' @importFrom shinyjs hide useShinyjs
#' @importFrom stringr str_detect
#' @importFrom utils contrib.url install.packages
#'
#' @examples
#' \dontrun{
#' CRANsearcher()
#' }
#'
#' @export
CRANsearcher <- function(){

  ui <- miniPage(
    shinyjs::useShinyjs(),

    # Loading message
    div(
      id = "loading-content",
      h2("Loading CRAN package database..."),
      style = "margin: auto;
      position: absolute;
      top: 35%;
      left: 30%;
      text-align: left;"),

    gadgetTitleBar(a(href="https://github.com/RhoInc/CRANsearcher", "CRAN Package Searcher"),
                   left = miniTitleBarCancelButton("close","Close"),
                   right = uiOutput("install")),
    miniContentPanel(
      fillCol(
        flex=c(1,6),
        fillRow(
          flex=c(2,1),
          textInput("search","Enter search terms separated by commas (e.g. latent class, longitudinal)", width="90%"),
          selectInput("dates","Last release date range",choices=c("1 month","3 months","6 months","12 months","All time"), selected="All time", width="80%")
        ),
        div(DT::dataTableOutput("table"), style = "font-size: 90%")
      )
    ),
    miniButtonBlock(
      div(textOutput("n"), style = "font-weight: bold")
    ),
    miniButtonBlock(
      shinyjs::disabled(
        actionButton("export", "Export Filtered Results")
      )
    )
  )


  server <- function(input, output, session){

    crandb <- reactiveValues(a=NULL, snapshot_date=NULL)

    observeEvent(!is.null(crandb$a),{
      shinyjs::hide(id = "loading-content", anim = TRUE, animType = "fade")
    })

    # determine if internet access & manage data
    if(curl::has_internet()){
      crandb$a <- getPackages() %>%
            data.frame %>%
            mutate(Published = as.Date(Published),
                   months_since = lubridate::interval(Published, Sys.Date())/months(1),
                   name = Package %>% as.character,
                  Package = paste0('<a href="','https://cran.r-project.org/web/packages/',Package,'" style="color:#000000">',Package,'</a>',
                                   '<sub> <a href="','http://www.rpackages.io/package/',Package,'" style="color:#000000">',1,'</a></sub>',
                                   '<sub> <a href="','http://rdrr.io/cran/',Package,'" style="color:#000000">',2,'</a></sub>')) %>%
           rename(`Last release`=Published)

      crandb$snapshot_date <- format(Sys.Date(), "%m/%d/%y")

    } else {
      a <- cran_inventory %>%
        mutate(Published = as.Date(Published),
               months_since = lubridate::interval(Published, Sys.Date())/months(1),
               name = Package %>% as.character,
               Package =paste0('<a href="','https://cran.r-project.org/web/packages/',Package,'" style="color:#000000">',Package,'</a>',
                               '<sub> <a href="','http://www.rpackages.io/package/',Package,'" style="color:#000000">',1,'</a></sub>',
                               '<sub> <a href="','http://rdrr.io/cran/',Package,'" style="color:#000000">',2,'</a></sub>')) %>%
              rename(`Last release`=Published)

      crandb$a <- a
      crandb$snapshot_date <- format(a$snapshot_date, "%m/%d/%y")

    }


    a_sub1 <- reactive({

      dat <- crandb$a

      if(input$dates=="All time"){
        return(dat)
      } else {
        nmos <- gsub("[^0-9\\.]", "", input$dates)

        return(filter(dat, months_since < nmos))
      }

    })

    search <- reactive({
      input$search %>%
        tolower %>%
        strsplit(.,",") %>%
        unlist %>%
        trimws
    })

    search_d <- search %>% debounce(500)

    a_sub2 <- reactive({

      search2 <- search_d()[which(nchar(search_d()) >1)]

      a <- a_sub1()

      if(identical(search_d(), character(0)) || nchar(search_d())<2){
        s <- 0
      } else{
        s <- a %>%
          mutate(term = tolower(paste(name, Title, Description, sep=","))) %>%
          rowwise %>%
          mutate(match = all(stringr::str_detect(term, search2))) %>%
          filter(match==TRUE) %>%
          select(-c(term, match)) %>%
          data.frame
      }
      return(s)
    })


    output$table <- DT::renderDataTable({

      if(identical(search_d(), character(0)) || nchar(search_d())<2){
        if(!is.null(crandb$a)){
          if (input$dates=="All time"){
            DT::datatable(crandb$a[c(1:10),c(1:6)],
                          rownames = FALSE,
                          escape = FALSE,
                          style="bootstrap",
                          class='compact stripe hover row-border order-column',
                          selection="multiple",
                          extensions = "Buttons",
                          options= list(dom = 'Btip',
                                        buttons = I('colvis')))
          } else{
            DT::datatable(a_sub1()[,c(1:6)],
                          rownames = FALSE,
                          escape = FALSE,
                          style="bootstrap",
                          class='compact stripe hover row-border order-column',
                          selection="multiple",
                          extensions = "Buttons",
                          options= list(dom = 'Btip',
                                        buttons = I('colvis')))
          }
        } else{
          return()
        }
      } else{
        DT::datatable(a_sub2()[,c(1:6)],
                       rownames = FALSE,
                       escape = FALSE,
                       style="bootstrap",
                       class='compact stripe hover row-border order-column',
                       selection="multiple",
                       extensions = "Buttons",
                       options= list(dom = 'Btip',
                                     buttons = I('colvis')))
      }
    })

    output$n <- renderText({

      note <- ifelse(!is.null(crandb$snapshot_date), paste0(" (as of ", crandb$snapshot_date,")", ""))

      if(identical(search_d(), character(0)) || nchar(search_d())<2){
        if (!is.null(crandb$a)){

          if (input$dates=="All time"){
          paste0("There are ",dim(crandb$a)[1]," packages on CRAN", note, ". Displaying first 10.")
          } else{
          paste0("There are ",dim(a_sub1())[1]," packages on CRAN released within the past ",input$dates,note,".")
          }
        } else{
          paste("")
        }
      } else{
        n <- dim(a_sub2())[1]

        if (!n==1){
          if (input$dates=="All time"){
            paste0("There are ",n," packages related to '",search_d(),"' on CRAN", note,".")
          } else {
            paste0("There are ",n," packages related to '",search_d(),"' on CRAN released within the past ",input$dates,note,".")
          }
        } else {
          if (input$dates=="All time"){
            paste0("There is ",n," package related to '",search_d(),"' on CRAN", note, ".")
          } else {
            paste0("There is ",n," package related to '",search_d(),"' on CRAN released within the past ",input$dates,note,".")
          }
        }
      }
    })


   output$install <- renderUI({
     if (!is.null(input$table_rows_selected)){
       miniTitleBarButton("install", "Install selected package(s)", primary=TRUE)
     } else{
       miniTitleBarButton("install", "Install selected package(s)")
     }
   })

    observeEvent(input$install, {
      rows <- input$table_rows_selected
      pkgs <- as.vector(a_sub2()[rows, "name"])
      utils::install.packages(pkgs)
    })

    observeEvent(input$close,{
      stopApp()
    })

    observe({
      if (a_sub2() != 0) {
        shinyjs::enable("export")
      }
    })

    observeEvent(input$export, {
      CRANsearcher_export <<- a_sub2() %>%
        mutate(Package = name) %>%
        select(., -name)
      stopApp()
    })
  }

  viewer <- dialogViewer("Search packages in CRAN database based on keywords", width = 1200, height = 900)
  runGadget(ui, server, viewer = viewer)
}



