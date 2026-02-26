# Scrape General Conference Talks

library(rvest)

# Storage for raw HTML
all_html <- list()
failed_links <- list()

for(year in 1971:1979) {
  for(month in c("04", "10")) {
    
    # Get conference index page
    conf_url <- paste0("https://www.churchofjesuschrist.org/study/general-conference/",
                       year, "/", month, "?lang=eng")
    conf_page <- read_html(conf_url)
    
    # Extract all talk links
    talk_links <- conf_page |>
      html_elements("a.list-tile") |>
      html_attr("href")
    
    talk_links <- paste0("https://www.churchofjesuschrist.org", talk_links)
    
    cat("Found", length(talk_links), "talks for", year, "-", month, "\n")
    
    Sys.sleep(round(runif(1, min=2, max=10), 0))
    
    # Scrape each talk's HTML
    for(i in seq_along(talk_links)) {
      link <- talk_links[i]
      
      tryCatch({
        talk_page <- read_html(link)
        
        # Store the raw HTML object
        talk_name <- paste0(year, "_", month, "_", sprintf("%02d", i))
        all_html[[talk_name]] <- list(
          url = link,
          year = year,
          month = month,
          html = talk_page  # Save the entire HTML object
        )
        
        cat("  ✓ Downloaded:", link, "\n")
        
      }, error = function(e) {
        cat("  ✗ FAILED:", link, "\n")
        cat("    Error:", conditionMessage(e), "\n")
        failed_links[[length(failed_links) + 1]] <- list(
          url = link,
          year = year,
          month = month,
          index = i,
          error = conditionMessage(e)
        )
      })
      
      Sys.sleep(round(runif(1, min=2, max=10), 0))
    }
  }
}

# Save the raw HTML
saveRDS(all_html, here::here("Data", "Raw HTML", "raw_html_1970s.rds"))

# Save failed links
if(length(failed_links) > 0) {
  failed_df <- bind_rows(failed_links)
  write.csv(failed_df, 
            here::here("Data", "Raw HTML", "failed_links_1970s.csv"), 
            row.names = FALSE)
}
