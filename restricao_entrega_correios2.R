library(httr)
library(readr)
library(tibble)
library(readxl)
library(rvest)
library(dplyr)

# favelas <- read.csv("tbl_cep_201710_n_csv/tbl_cep_201710_log_n_csv.csv",sep=',',encoding = 'UTF-8',colClasses = 'character')
# 
# favelas$restricao <- NA
# nrow(favelas)

setwd('D:/projetos/cep/restricao correios')


#favelas <- readRDS('favelas.RDS')

inicio<- Sys.time()
for(i in 1032625:nrow(favelas)){
  
  
  #Busca CEP da favela
  destino <- as.character(favelas[['cep']][[i]])

  #Tempo de espera para n�o ser bloqueado pelo site
  if(i%%3==0) Sys.sleep(1)
  #Sys.sleep(4)
  #Consulta site dos Correios
  
  res <- POST(url = "http://www2.correios.com.br/sistemas/precosPrazos/restricaoentrega/resultado.cfm",
              body = list(servico = '04510',
                        cepOrigem = '70765-060',
                        cepDestino = destino),
              add_headers(Origin="http://www2.correios.com.br",
                        Referer="http://www2.correios.com.br/sistemas/precosPrazos/restricaoentrega"),
             timeout(99),
             encode = "form")


  #Leitura do resultado de restricao
  x<- read_html(res) %>% 
      html_node(xpath='//*[@class="msg"]') %>%
      html_text() %>%
      gsub('[\r\n\t]', '', .)
  
  #Gravacao do resultado
  favelas[['restricao']][[i]] <- x
  
  print(paste(destino," : ",x))
  
  if(i%%500==0){
    fim <- Sys.time()
    print(fim-inicio)
    inicio<- Sys.time()
    Sys.sleep(20)
    percent <- round(100*i/nrow(favelas),2)
    print(paste0(i,' ',percent,'%'))
    print(favelas %>%
            filter(!is.na(restricao),restricao!='N�o h� restri��es de entrega para o trecho informado.') %>%
            group_by(estado) %>%
            summarise(quantidade=n()) %>%
            as.data.frame())
    
  } 
  
  if(i%%5000==0) save.image("favelas_total.RData")
  
}

1032625/1090252


save.image("favelas_total.RData")
write.csv(favelas,'favelas_total.csv',row.names = FALSE)
