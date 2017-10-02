# CRANsearcher 1.1.1
- Added bug fix contributed via PR by [Eric Nantz](https://github.com/thercast) to accommodate zero search results.  
- Fixed bug in message following search of multiple terms.

# CRANsearcher 1.1.0

- Added functionality courtesy of [Eric Nantz](https://github.com/thercast)'s pull request: ability to export filtered search results to a data frame in R environment
- Added minor tweaks to facilitate data frame export
- Removed date format for the CRAN "as of" date 
- Added NEWS.md file to track changes and version updates

# CRANsearcher 1.0.1

Merged pull request from [Eric Nantz](https://github.com/thercast) - enhancement of user experience by imposing a delay on the retrieval of search results (using shiny::debounce).   

# CRANsearcher 1.0.0

Create version 1.0.0 corresponding to first CRAN submission.  Also added the snapshot date of the CRAN inventory (today's date for internet connection, date of dataset creation for offline use).

# CRANsearcher 0.3.0

- Add link to CRAN
- Change color of links
- update gif in README

# CRANsearcher 0.2.1

Fixes to pass R CMD check + tweak search for CRAN mirror:
- more generalized search for CRAN [mirror](https://github.com/RhoInc/CRANsearcher/issues/3)
- fixes according to R CMD check NOTES

# CRANsearcher 0.2.0

Improvement of UI:
- Selected row triggers install button highlight
- User can continue to browse packages after an installation is triggered
- Reformat loading message
- Add filter for release date

# CRANsearcher 0.1.0

Initial release for CRANsearcher: an R-studio add-in.  Features include:
- Real-time exploration of the CRAN package database
- Search package name, title, and description based on multiple keywords 
- Explore search results within a sortable table
- Link to external websites providing package metadata, specifically www.rpackages.io and rdrr.io
- Install package(s) with the click of a button
