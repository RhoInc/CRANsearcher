# CRANsearcher
RStudio addin to search CRAN packages titles and descriptions

# About 
One of the strengths of R is its vast [package ecosystem](https://cran.r-project.org/web/packages/available_packages_by_name.html). Indeed, R packages extend from visualization to bayesian inference and from spatial analyses to pharmacokinetics (https://cran.r-project.org/web/views/). There is probably not an area of quantitative research that isn't represented by at least one R package. At the time of this writing, there are more than [10,000](https://rdrr.io/all/cran/) active CRAN packages. Because of this massive ecosystem, it is important to have tools to search and learn about packages related to your personal R needs. For this reason, we developed an RStudio addin capable of searching available CRAN packages directly within RStudio.

# Installation
```devtools::install_github("RhoInc/CRANsearcher")```

# Use
After installation, the add-in will be available in your Rstudio add-in dropdown menu.  Simply select "CRANsearcher" from the menu to run the application.  

![](/inst/image/CRANsearcher_addin.gif)

# Inspiration

Ideas behind this addin are inspired by Dean Attali's [addinslist](https://github.com/daattali/addinslist) and Mikhail Popov's taskviewr Shiny [app](https://github.com/bearloga/taskviewr). 
