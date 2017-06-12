########################
#INTERAÇÕES NO FACEBOOK#
########################

#Autor: Gabriel Zanlorenssi

#Bibliotecas 
library(stringr)
library(wordcloud)
library(tm)

# Primeiro é necessario instalar o pacote "Rfacebook", de Pablo Barbera
library(devtools)
install_github("Rfacebook", "pablobarbera", subdir="Rfacebook")
library(Rfacebook)

## Função 1: convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}
## Função 2: aggregate metric counts over month
aggregate.metric <- function(metric) {
  m <- aggregate(page[[paste0(metric, "_count")]], list(month = page$month), 
                 mean)
  m$month <- as.Date(paste0(m$month, "-15"))
  m$metric <- metric
  return(m)
} 

# Autenticação de app no facebook. É necessário criar um app, na seção de desenvolvedores, e inserir
# aqui as informações de id e app secret
fb_oauth <- fbOAuth(app_id="XXXXXXX", app_secret="YYYYYYYYY",extended_permissions = TRUE)

# Autorize o app e clique em ok

#Salvar autenticação
save(fb_oauth, file="fb_oauth")
load("fb_oauth")

#Token
##Obtenha um token temporáro aqui: https://developers.facebook.com/tools/explorer
token <- 'ZZZZZZZZZZZZZZZZ'

#Páginas - presidenciaveis
paginas<-c("Lula", "jdoriajr", "jairmessias.bolsonaro", "cirogomesoficial", "marinasilva.oficial",
           "LucianoHuck", "geraldoalckmin")
           
#Loop para extrair os dados das páginas 
for (i in 1:7)  {
page <- getPage(paginas[i], token, n=10000)
page[which.max(page$likes_count), ]
# create data frame with average metric counts per month
page$datetime <- format.facebook.date(page$created_time)
page$month <- format(page$datetime, "%Y-%m")
df.list <- lapply(c("likes", "comments", "shares"), aggregate.metric)
df <- do.call(rbind, df.list)
assign(paste("df_", paginas[i], sep=""), df)
assign(paste("page_", paginas[i], sep=""), page)
}


df_final<-rbind(page_geraldoalckmin, page_cirogomesoficial, page_LucianoHuck, page_Lula,
                page_marinasilva.oficial, page_jairmessias.bolsonaro, page_jdoriajr)


df_final$text<-df_final$message
## Passar tudo para minusculo
df_final$text<-tolower(df_final$text)
## Remover pontuação
df_final$text<-removePunctuation(df_final$text)
## Remover números
df_final$text<-removeNumbers(df_final$text)
## Remover palavras frequentes da lingua portuguesa
df_final$text2<-removeWords(df_final$text, stopwords("pt"))
## Remover espaços vazios em excesso
df_final$text2<-stripWhitespace(df_final$text2)

## Retirar acentos e caracteres especiais
df_final$text2<-str_replace_all(df_final$text2, "ú", "u")
df_final$text2<-str_replace_all(df_final$text2, "â", "a")
df_final$text2<-str_replace_all(df_final$text2, "á", "a")
df_final$text2<-str_replace_all(df_final$text2, "ã", "a")
df_final$text2<-str_replace_all(df_final$text2, "é", "e")
df_final$text2<-str_replace_all(df_final$text2, "ê", "e")
df_final$text2<-str_replace_all(df_final$text2, "ç", "c")
df_final$text2<-str_replace_all(df_final$text2, "í", "i")
df_final$text2<-str_replace_all(df_final$text2, "\n", "")
df_final$text2<-str_replace_all(df_final$text2, "û", "u")
df_final$text2<-str_replace_all(df_final$text2, "ú", "u")
df_final$text2<-str_replace_all(df_final$text2, "õ", "o")
df_final$text2<-str_replace_all(df_final$text2, "ó", "o")
df_final$text2<-str_replace_all(df_final$text2, "ô", "o")
##Eliminar palavras muito grandes
df_final$text2<-gsub("\\b[[:alpha:]]{20,}\\b", "", df_final$text2, perl=T)

## Csv
facebook<-df_final[c(2,9,10,11,12,13,15)]
write.csv2(facebook, file="facebook.csv", row.names=FALSE, na="") 

