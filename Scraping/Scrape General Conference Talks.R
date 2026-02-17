# Scrape General Conference Talks

library(rvest)
library(dplyr)

# Storage
genCon73_79 <- list()
failed_links <- list()  # Track failures


for(year in 1973:1979) {
  for(month in c("04", "10")) {
    
    # STAGE 1: Get conference index page
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
    
    # STAGE 2: Scrape each talk
    for(i in seq_along(talk_links)) {
      link <- talk_links[i]
      
      tryCatch({
        
      talk_page <- read_html(link)
      
      # Extract metadata
      title <- talk_page |> html_element("h1[id^='title']") |> html_text2()
      speaker <- talk_page |> html_element("p.author-name") |> html_text2()
      office <- talk_page |> html_element("p.author-role") |> html_text2()
      session_info <- talk_page |> html_element("p.kicker") |> html_text2()
      
      # Extract all talk text paragraphs (includes inline citations)
      talk_text <- talk_page |>
        html_elements("p[data-aid]") |>
        html_text2() |>
        paste(collapse = "\n\n")
      
      # Extract scripture references
      scripture_refs <- talk_page |>
        html_elements("a.scripture-ref") |>
        html_text2() |>
        paste(collapse = "; ")
      
      # Store everything
      talk_data <- list(
        url = link,
        year = year,
        month = month,
        title = title,
        speaker = speaker,
        office = office,
        session_info = session_info,
        talk_text = talk_text,
        scripture_refs = scripture_refs
      )
      
      talk_name <- paste0(year, "_", month, "_", sprintf("%02d", i))
      genCon73_79[[talk_name]] <- talk_data
      
      cat("  Scraped:", title, "\n")
      
      }, error = function(e) {
        # Log the failure and continue
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

# Convert to data frame
talks_df <- bind_rows(genCon73_79, .id = "talk_id")

# Save the results
saveRDS(talks_df, here::here("Data", "general_conference_1973_1979.rds"))
saveRDS(failed_links, here::here("Data", "failed_1973_1979.rds"))

write.csv(talks_df, here::here("Data", "general_conference_1973_1979.csv"), row.names = FALSE)


