# Investigating html sandbox
# Goals: 
#  - Extract the text from the html and save in a more stable format
#  - Determine what metadata I can extract  

# Notes:
# So saving the html as an rds file failed.
# Looks like I'll have to re-scrape, and conver to character
# before saving.

# library
library(rvest)
library(xml2)

#############
# LOAD HTML #
#############

raw_html_1970s <- readRDS(here::here("Data","Raw HTML", "raw_html_1970s.rds"))

text1 <- rvest::html_text2(raw_html_1970s[[1]][["html"]])

gorf <- raw_html_1970s[[1]]$html |> 
  read_html() |> 
  html_text2()

text1 <- raw_html_1970s[[1]]$html |>
  as.character() |>
  read_html() |>
  html_text2()

> raw_html_1970s[[4]]
$url
[1] "https://www.churchofjesuschrist.org/study/general-conference/1971/04/love-of-the-right?lang=eng"

$year
[1] 1971

$month
[1] "04"

$html
Error in doc_type(x) : external pointer is not valid

# It's all failing

raw_html_1980s <- readRDS(here::here("Data","Raw HTML", "raw_html_1980s.rds"))


raw_html_1977 <- readRDS(here::here("Data","Raw HTML", "raw_html_1977.rds"))

raw_html_1977[[1]]

gorf <- raw_html_1977[[1]]$html |> 
  read_html() |> 
  html_text2()


theThree <- raw_html_1977[[3]]$html |>
  read_html() |>
  html_elements("article") |>
  html_text2()

gorf3 <- raw_html_1977[[3]]$html |>
  read_html() |>
  html_elements("p[data-aid]") |>
  html_text2() |>
  paste(collapse = "\n\n")

#GOOD!

