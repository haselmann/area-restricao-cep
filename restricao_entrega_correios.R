library(httr)
library(readr)
library(tibble)
library(readxl)
library(rvest)

favelas <- read_xlsx("FAVELAS_BRASIL.xlsx")

favelas$restricao <- NA
nrow(favelas)

for(i in 17:nrow(favelas)){
  

  #Busca CEP da favela
  destino <- favelas[['CEP']][[i]]

  #Tempo de espera para não ser bloqueado pelo site
  Sys.sleep(9)
  
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
  
  percent <- round(100*i/nrow(favelas),2)
  print(paste0(percent,'%    ', destino,'       Resultado: ',x))
  

  
}

save.image("~/buscaCEP/favelas.RData")
write.csv(favelas,'favelas.csv',row.names = FALSE)
