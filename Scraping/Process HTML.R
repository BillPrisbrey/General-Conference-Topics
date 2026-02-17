# Process HTML

library(rvest)
library(dplyr)

# Load the raw HTML
all_html <- readRDS(here::here("Data", "raw_html_1970s.rds"))

# Process each HTML page
all_talks <- list()

for(talk_name in names(all_html)) {
  talk_data <- all_html[[talk_name]]
  talk_page <- talk_data$html
  
  # Extract everything you want
  title <- talk_page |> html_element("h1[id^='title']") |> html_text2()
  speaker <- talk_page |> html_element("p.author-name") |> html_text2()
  office <- talk_page |> html_element("p.author-role") |> html_text2()
  session_info <- talk_page |> html_element("p.kicker") |> html_text2()
  
  talk_text <- talk_page |>
    html_elements("p[data-aid]") |>
    html_text2() |>
    paste(collapse = "\n\n")
  
  scripture_refs <- talk_page |>
    html_elements("a.scripture-ref") |>
    html_text2() |>
    paste(collapse = "; ")
  
  # Citations from <cite> tags
  cite_tags <- talk_page |>
    html_elements("cite") |>
    html_text2() |>
    paste(collapse = "; ")
  
  # Citations from <em> tags
  em_tags <- talk_page |>
    html_elements("em") |>
    html_text2() |>
    paste(collapse = "; ")
  
  cited_works <- paste(c(cite_tags, em_tags), collapse = "; ")
  
  all_paragraphs <- talk_page |>
    html_elements("p[data-aid]") |>
    html_text2()
  
  citation_paragraphs <- all_paragraphs[grepl("^\\(.*\\)\\s*$", all_paragraphs)]
  citations <- paste(citation_paragraphs, collapse = "; ")
  
  # Combine all data
  all_talks[[talk_name]] <- list(
    url = talk_data$url,
    year = talk_data$year,
    month = talk_data$month,
    title = title,
    speaker = speaker,
    office = office,
    session_info = session_info,
    talk_text = talk_text,
    scripture_refs = scripture_refs,
    cited_works = cited_works,
    citations = citations
  )
}

# Convert to dataframe
talks_df <- bind_rows(all_talks, .id = "talk_id")

# Save processed data
write.csv(talks_df, 
          here::here("Data", "general_conference_1970s.csv"), 
          row.names = FALSE)