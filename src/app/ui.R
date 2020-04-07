validPages <- c('surge-model', 'sensitivity')
names(validPages) <- c('Run Model', 'Sensitivity Analysis')
navbarStr <- readr::read_file('./templates/navbar.html')
headerStr <- ''

# Build up header HTML
for (i in 1:length(validPages)) {
    headerStr <- paste(
        headerStr, 
        sprintf(
            '<li id="%s"><a href="?%s">%s</a></li>', 
            validPages[[i]],
            validPages[[i]],
            names(validPages)[[i]]
        )
    )
}

# Fill-in header
navbarStr <- sprintf(navbarStr, headerStr)

ui <- shiny::tagList(
    shinyjs::useShinyjs(),
    shiny::bootstrapPage(
        shiny::HTML(navbarStr),
        shiny::uiOutput('pageStub')
    )
)