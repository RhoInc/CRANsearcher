
## function to get packages
getPackages <- function() {
  contrib.url(getOption("repos")["CRAN"], "source")
  description <- sprintf("%s/web/packages/packages.rds", getOption("repos")["CRAN"])
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
#' @import shiny
#' @import miniUI
#' @importFrom shinyjs hide useShinyjs
#' @importFrom stringr str_detect
#'
#' @export
CRANsearcher <- function(){

  ui <- miniPage(

    shinyjs::useShinyjs(),

    # Loading message
    div(
      id = "loading-content",
      h2("Loading CRAN package database..."),
      style = "text-align: center;
                position: absolute;
                background: #000000;
                opacity: 0.3;
                left: 0;
                right: 0;
                top: 50px;
                height: 100%;
                text-align: center;
                color: #FFFFFF;"
                    ),

    gadgetTitleBar(a(href="https://github.com/agstn/CRANsearcher", "CRAN Package Searcher"),
                   left = miniTitleBarCancelButton(),
                   right = miniTitleBarButton("done", "Install selected package(s)", primary = TRUE)),
    miniContentPanel(
      fillCol(
        flex=c(1,6,0.5),
        textInput("search","Enter search terms separated by commas (e.g. latent class, longitudinal)"),
        div(DT::dataTableOutput("table"), style = "font-size: 90%"),
        fillRow(
          div(textOutput("n"), style = "font-weight: bold")
          )
      )
    )
  )


  server <- function(input, output, session){

    crandb <- reactiveValues(a=NULL)

    observeEvent(!is.null(crandb$a),{
      shinyjs::hide(id = "loading-content", anim = TRUE, animType = "fade")
    })

    ## determine if internet access & manage data
    if(curl::has_internet()){
      crandb$a <- getPackages() %>%
            data.frame %>%
            mutate(name = Package %>% as.character,
                  Package = paste0('<a href="','http://www.rpackages.io/package/',Package,'">',Package,'</a>',
                                   '<sub> <a href="','http://rdrr.io/cran/',Package,'">',2,'</a></sub>')
                  )
    } else {
      crandb$a <- cran_inventory %>%
        data.frame %>%
        mutate(name = Package %>% as.character,
               Package = paste0('<a href="','http://www.rpackages.io/package/',Package,'">',Package,'</a>',
                                '<sub> <a href="','http://rdrr.io/cran/',Package,'">',2,'</a></sub>')
               )
    }

    a_sub <- reactive({

      search <- input$search %>%
        tolower %>%
        strsplit(.,",") %>%
        unlist %>%
        trimws

      search2 <- search[which(nchar(search) >1)]

      a <- crandb$a

      if(nchar(input$search)<3){
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

      if(nchar(input$search)<3){
        return()
      } else{
        DT::datatable(a_sub()[,-7],
                       rownames = FALSE,
                       escape = FALSE,
                       style="bootstrap",
                       class='compact stripe hover row-border order-column',
                       selection="multiple",
                       extensions = c('Scroller','Buttons'),
                       options= list(dom = 'Btip',
                                     scrollX=FALSE,
                                     scrollY=450,
                                     buttons = I('colvis')))
      }
    })

    output$n <- renderText({

      if(nchar(input$search)<3){
        if (!is.null(crandb$a)){
          paste("There are",dim(crandb$a)[1],"packages on CRAN.")
        } else{
          paste("")
        }
      } else{
        n <- dim(a_sub())[1]
        if (n>1){
          paste0("There are ",n," packages related to '",input$search,"' on CRAN.")
        } else {
          paste0("There is ",n," package related to '",input$search,"' on CRAN.")
        }
      }
    })


    observeEvent(input$done, {
      rows_selected = input$table_rows_selected
     # select = rows_selected[!(rows_selected %in% installed)]
      for (i in rows_selected){
        install.packages(a_sub()[rows_selected,"name"])
      }

      stopApp()
    })
  }

  viewer <- dialogViewer("Search packages in CRAN database based on keywords", width = 1200, height = 900)
  runGadget(ui, server, viewer = viewer)
}



