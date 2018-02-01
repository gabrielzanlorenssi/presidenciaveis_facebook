# ---
# Autor: Gabriel Zanlorenssi
# ---


# Bibliotecas -------------------------------------------------------------

library(stringr)
library(wordcloud)
library(tm)



# Rfacebook ---------------------------------------------------------------

devtools::install_github("Rfacebook", "pablobarbera", subdir = "Rfacebook")
library(Rfacebook)


# Funcoes adicionais ------------------------------------------------------

## Escritas pelo Pablo Barbera

## Funcao 1: convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}
## Funcao 2: aggregate metric counts over month
aggregate.metric <- function(metric) {
  m <- aggregate(page[[paste0(metric, "_count")]], list(month = page$month), 
                 mean)
  m$month <- as.Date(paste0(m$month, "-15"))
  m$metric <- metric
  return(m)
} 



# Autenticação ------------------------------------------------------------

# Necessario criar um token na secao de desenvolvedores, no Facebook

fb_oauth <-
  fbOAuth(
    app_id = "XXXXXXX",
    app_secret = "YYYYYYYYY",
    extended_permissions = TRUE
  )

# Autorize o app e clique em ok

# Salvar autenticacao

save(fb_oauth, file = "fb_oauth")

# Nas próximas vezes, ir direto para:

load("fb_oauth")

# Paginas - presidenciaveis
paginas <-
  c(
    "Lula",
    "jdoriajr",
    "jairmessias.bolsonaro",
    "cirogomesoficial",
    "marinasilva.oficial",
    "LucianoHuck",
    "geraldoalckmin"
  )

# Loop para extrair os dados das paginas
for (i in 1:7)  {
  page <- getPage(paginas[i], token, n = 10000)
  page[which.max(page$likes_count),]
  # create data frame with average metric counts per month
  page$datetime <- format.facebook.date(page$created_time)
  page$month <- format(page$datetime, "%Y-%m")
  df.list <- lapply(c("likes", "comments", "shares"), aggregate.metric)
  df <- do.call(rbind, df.list)
  
  df[[i]] <- df
  page[[i]] <- page
}


