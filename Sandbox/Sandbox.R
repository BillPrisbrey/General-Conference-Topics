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

###############
## LOAD HTML ##
###############

talk_files <- list.files(here::here("Data", "Raw HTML"))

talk_list <- lapply(talk_files, function(x) {readRDS(here::here("Data","Raw HTML", x))} )
names(talk_list) <- gsub(".rds","", talk_files)

talk_text <- lapply(talk_list, function(con) {
  
  con_talks <- lapply(con, function(talk){ 
  
  text <- talk$html |>
    read_html() |>
    html_elements("p[data-aid]") |>
    html_text2() |>
    paste(collapse = "\n\n");
  return(text)
  
  })
  
  return(con_talks)
  
})

# Time to bring in "purrr" and "quanteda"

substr(talk_text[[1]][[10]], 1, 10)

sapply(talk_text[[1]], function(x){ substr(x,1,2)}) |> table()

# By Pr 
# 6 41  2 

talk_list[[1]][[9]]$html |>
  read_html() |>
  html_elements("h1, h2, h3, p[data-aid]") |>
  head(10)
  

> talk_list[[1]][[9]]$html |>
  +     read_html() |>
  +     html_elements("h1, h2, h3, p[data-aid]") |>
  +     head(10)
{xml_nodeset (10)}
[1] <h1 data-aid="28743647" id="title1">Church Finan ...
[2] <p class="author-name" data-aid="28743648" id="p ...
 [3] <p class="author-role" data-aid="149936726" id=" ...
[4] <p data-aid="28743649" id="kicker1">To the First ...
[5] <p data-aid="28743650" id="p2">We have reviewed  ...
[6] <p data-aid="28743651" id="p3">Modern accounting ...
[7] <p data-aid="28743652" id="p4">The Auditing Depa ...
[8] <p data-aid="28743653" id="p5">Based on our revi ...
[9] <p class="closing" data-aid="28743654" id="closi ...
[10] <p class="closing" data-aid="28743655" id="closi ...

# This is much better:

html <- talk$html |> read_html()

title <- html |>
  html_element("h1[data-aid]") |>
  html_text2()

author <- html |>
  html_element("p.author-name") |>
  html_text2()

author_role <- html |>
  html_element("p.author-role") |>
  html_text2()

text <- html |>
  html_elements("p[data-aid]") |>
  keep(~ !html_attr(.x, "class") %in% c("author-name", "author-role")) |>
  html_text2() |>
  paste(collapse = "\n\n")


talk_text <- lapply(talk_list, function(con) {
  
  con_talks <- lapply(con, function(talk){ 
    
    html <- talk$html |> read_html()
    
    title <- html |>
      html_element("h1[data-aid]") |>
      html_text2()
    
    author <- html |>
      html_element("p.author-name") |>
      html_text2()
    
    author_role <- html |>
      html_element("p.author-role") |>
      html_text2()
    
    text <- html |>
      html_elements("p[data-aid]") |>
      keep(~ !html_attr(.x, "class") %in% c("author-name", "author-role")) |>
      html_text2() |>
      paste(collapse = "\n\n")
    
    return(list(title=title, author=author, role=author_role, text=text))
    
  })
  
  return(con_talks)
  
})

sapply(talk_text[[1]], function(x) {x$role}) |> table()

# dang -- looking much better than what I had before!

# looking for more meta-data to extract:

html <- talk$html |> read_html()

html <- talk_list[[1]][[9]]$html |>
       read_html()

# Check meta tags
html |>
  html_elements("meta") |>
  head(20)

# Check the <head> section more broadly
html |>
  html_element("head") |>
  as.character() |>
  substr(1, 3000) |>
  cat()

html |>
  html_elements("[class*='session'], [class*='conference'], [class*='date']") |>
  head(10)

url <- html |>
  html_element("meta[property='og:url']") |>
  html_attr("content")

year  <- stringr::str_extract(url, "(?<=/general-conference/)\\d{4}")
month <- stringr::str_extract(url, "(?<=/general-conference/\\d{4}/)\\d{2}")



# possible list of titles by session
# in the first scrape

html_toc <- talk_list[[1]][[1]]$html |> read_html()

> html_toc |>
  +     html_elements("h2, h3, h4, a") |>
  +     head(30)
{xml_nodeset (30)}
[1] <a class="backText-x1fGy" href="/study/general-c ...
 [2] <a class="sectionTitle-_Dn99 item-U_5Ca" href="/ ...
[3] <a class="sectionTitle-_Dn99" href="/study/gener ...
 [4] <a class="item-U_5Ca" href="/study/general-confe ...
[5] <a class="item-U_5Ca" href="/study/general-confe ...
 [6] <a class="item-U_5Ca" href="/study/general-confe ...
[7] <a class="item-U_5Ca" href="/study/general-confe ...
 [8] <a class="item-U_5Ca" href="/study/general-confe ...
[9] <a class="sectionTitle-_Dn99" href="/study/gener ...
[10] <a class="item-U_5Ca" href="/study/general-confe ...
[11] <a class="item-U_5Ca" href="/study/general-confe ...
[12] <a class="item-U_5Ca" href="/study/general-confe ...
[13] <a class="item-U_5Ca" href="/study/general-confe ...
[14] <a class="item-U_5Ca" href="/study/general-confe ...
[15] <a class="item-U_5Ca" href="/study/general-confe ...
[16] <a class="item-U_5Ca" href="/study/general-confe ...
[17] <a class="item-U_5Ca" href="/study/general-confe ...
[18] <a class="item-U_5Ca" href="/study/general-confe ...
[19] <a class="item-U_5Ca" href="/study/general-confe ...
[20] <a class="sectionTitle-_Dn99" href="/study/gener ...
...

html_toc |>
  html_elements("a.sectionTitle-_Dn99, a.item-U_5Ca") |>
  purrr::map_df(~ tibble(
    class = html_attr(.x, "class"),
    text  = html_text2(.x),
    href  = html_attr(.x, "href")
  ))

# a faster version

nodes <- html_toc |> html_elements("a.sectionTitle-_Dn99, a.item-U_5Ca")

tibble(
  class = nodes |> html_attr("class"),
  text  = nodes |> html_text2(),
  href  = nodes |> html_attr("href")
)

nodes <- html_toc |> html_elements("a.sectionTitle-_Dn99, a.item-U_5Ca")

data.frame(
  class = nodes |> html_attr("class"),
  text  = nodes |> html_text2(),
  href  = nodes |> html_attr("href")
)

## Extracting session

library(dplyr)

toc <- data.frame(
  class = nodes |> html_attr("class"),
  text  = nodes |> html_text2(),
  href  = nodes |> html_attr("href")
) |>
  filter(class != "sectionTitle-_Dn99 item-U_5Ca") |>  # remove row 1 (Contents)
  mutate(
    is_session = grepl("sectionTitle-_Dn99", class),
    session = ifelse(is_session, text, NA)
  ) |>
  tidyr::fill(session, .direction = "down") |>
  filter(!is_session) |>                               # keep only talk rows
  mutate(
    # clean up talk slug for joining
    href = stringr::str_remove(href, "\\?lang=eng")
  ) |>
  select(session, text, href)



# Then you can join to your talk data by matching the href to the URL you extract from each talk's og:url meta tag. The session names also encode day and time ("Saturday Morning", "Sunday Afternoon", "Priesthood", etc.) so you can parse those out with stringr after joining.


# Fantastic!  Really getting close to building something here!





## Old and abandoned

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

