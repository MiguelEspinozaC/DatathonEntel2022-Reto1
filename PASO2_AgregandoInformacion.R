##########################################
lista_selec <- c("trafico_app_1", "trafico_app_2", "trafico_app_3" , 
                 "trafico_app_4", "trafico_app_5", "trafico_app_6" ,
                 "trafico_app_7", "trafico_app_8", "trafico_app_9" 
)
dfTablon10 <- dfTablon09[, colnames(dfTablon09) %in% lista_selec]

head(dfTablon10)

j1            <- max.col(dfTablon10, "first")
valormaximo   <- dfTablon10[cbind(1:nrow(dfTablon10), j1)]
tipo_app      <- names(dfTablon10)[j1]

combinado_01  <- data.frame(valormaximo, tipo_app)
head(combinado_01)


## Juntamos esta informacion 
dfTablon11 = cbind(dfTablon09, combinado_01)
head(dfTablon11)

rm(dfTablon10)
rm(combinado_01)


dfTablon12 = 
sqldf("
SELECT    a.*  ,
          case when valormaximo  = 0 then 'ninguna' 
               else tipo_app
          end  apptoppreferida  ,
          case when ( trafico_app_1 +	trafico_app_2	+ trafico_app_3	+ 
                      trafico_app_4	+ trafico_app_5 + trafico_app_6	+ 
                      trafico_app_7	+ trafico_app_8	+ trafico_app_9	) >  trafico_resto  then 'usopreferido'
               else 'usoresto'
          end  flgusopreferente,                  
          case when mins_flujo_1 =  0 and mins_flujo_2 = 0                 then 'conflg_01'
               when mins_flujo_1 / ( mins_flujo_1 + mins_flujo_2 ) <= 0.35 then 'conflg_02'
               when mins_flujo_1 / ( mins_flujo_1 + mins_flujo_2 ) <= 0.50 then 'conflg_03'     
               when mins_flujo_1 / ( mins_flujo_1 + mins_flujo_2 ) <= 0.65 then 'conflg_04'
               when mins_flujo_1 / ( mins_flujo_1 + mins_flujo_2 ) <= 0.80 then 'conflg_05'
               else 'conflg_06'
          end  flg_flujo
FROM      dfTablon11 a
WHERE     1 = 1
")


rm(dfTablon11)
  
head(dfTablon12 , 15 )  
  