########################
#INTERAÇÕES NO FACEBOOK#
########################

#Autor: Gabriel Zanlorenssi

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


##Reações -- Temer
page_temer<- getPage("MichelTemer", token=fb_oauth, n=10000)
posts_temer<-c()
for (i in 1:2023) {
posts<-getReactions(post=page_temer$id[i], token=fb_oauth)
posts_temer<-rbind(posts_temer, posts)
}

##Criar variável de mês
page_temer$datetime <- format.facebook.date(page_temer$created_time)
page_temer$month <- format(page_temer$datetime, "%Y-%m")


## Banco final para plotar no Stata
final_temer<-cbind(page_temer, posts_temer)
final_temer<-final_temer[c(2,9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20)]
write.csv2(final_temer, file="temer.csv", row.names=FALSE)

