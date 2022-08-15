#CASE 
#WHEN VCHPENALIDAD = 0 AND VCHMESADENDA = 0 THEN 0
#ELSE 
#CASE 
#WHEN (18-VCHMESADENDA) > 0 THEN (18-VCHMESADENDA)
#ELSE 0
#END 
#END MESES_XFINANC , 



dfTrain = 
  sqldf("SELECT    
nro_telefono_hash ,  TIPO_ADQ     ,  SCORECAT     , 
-- MARCA , 
CASE WHEN MARCA = 'dc937b59892604f5a86ac96936cd7ff09e25f18ae6b758e8014a24c7fa039e91' THEN '2a1022b922f5038bc5bff79ff2960cd12cf266647b4f59121997a75c710b5b5d'
     ELSE MARCA
END  MARCA ,      
-- MODELO ,  
NUEVA_GAMMA ,  
CASE WHEN OS = 'dc937b59892604f5a86ac96936cd7ff09e25f18ae6b758e8014a24c7fa039e91' THEN 'fb8e9c929bbc4ccaebcf8d68296c419464bdfaf01a69708a4d01a0d3159f3116'   
     ELSE OS
END  OS   , 
-- DEVICE_TYPE ,
CASE WHEN ( LTRIM(RTRIM(DEVICE_TYPE)) IS NULL OR RTRIM(LTRIM(DEVICE_TYPE)) = '' ) THEN 'SMARTPHONE'
     ELSE DEVICE_TYPE
END  DEVICE_TYPE ,      
CAT_VARIACION_MINFLU1 , CAT_VARIACION_MINFLU2 , 
CAT_VARIACION_APP1    , CAT_VARIACION_APP2    , CAT_VARIACION_APP3 , 
CAT_VARIACION_APP4    , CAT_VARIACION_APP5    , CAT_VARIACION_APP6 ,
CAT_VARIACION_APP7    , CAT_VARIACION_APP8    , CAT_VARIACION_APP9 ,
CAT_VARIACION_RESTO   ,
GIRO ,  SUBGIRO   ,  TIENE_PROD_1 ,  TIENE_PROD_2 , TIENE_PROD_3   ,
FLG_GRUPO1   , FLG_GRUPO2 , 
-- FLG_GRUPO3 , 
FLG_GRUPO4   , 
-- FLG_GRUPO5   , 
FLG_GRUPO6 ,
FLG_GRUPO7      , 
-- FLG_GRUPO8   , 
FLG_GRUPO9 ,
FLG_GRUPO10  , FLG_GRUPO11,
CASE WHEN  FLG_GRUPO3 = 1 THEN 1
     WHEN  FLG_GRUPO5 = 1 THEN 1
     WHEN  FLG_GRUPO8 = 1 THEN 1
     ELSE  0 
END  FLG_GRUPO16 ,       
FLG_TARGETPREV,
CASE 
    WHEN VCHPENALIDAD = 0 AND VCHMESADENDA = 0 THEN 'PROPIO'
    ELSE 'FINANCIADO'
END TIPOEQUIPO ,
VCHMESADENDA   ,
VCHPENALIDAD   ,
DAYS_FECINGRESO , DAYS_FECACTCONT  , DAYS_LANZAMIENT  ,
mins_flujo_1    , mins_flujo_2  , flg_flujo  ,
trafico_app_1   , trafico_app_2 , trafico_app_3 ,
trafico_app_4   , trafico_app_5 , trafico_app_6 , 
trafico_app_7   , trafico_app_8 , trafico_app_9 ,
trafico_resto   , apptoppreferida , flgusopreferente ,
TARGET
FROM      dfTablon12
WHERE     1 = 1
AND       TARGET IS NOT NULL 
")



dfSubmit = 
  sqldf("SELECT    
nro_telefono_hash ,  TIPO_ADQ     ,  SCORECAT     , 
-- MARCA , 
CASE WHEN MARCA = 'dc937b59892604f5a86ac96936cd7ff09e25f18ae6b758e8014a24c7fa039e91' THEN '2a1022b922f5038bc5bff79ff2960cd12cf266647b4f59121997a75c710b5b5d'
     ELSE MARCA
END  MARCA ,      
-- MODELO ,  
NUEVA_GAMMA ,  
CASE WHEN OS = 'dc937b59892604f5a86ac96936cd7ff09e25f18ae6b758e8014a24c7fa039e91' THEN 'fb8e9c929bbc4ccaebcf8d68296c419464bdfaf01a69708a4d01a0d3159f3116'   
     ELSE OS
END  OS   , 
--DEVICE_TYPE ,
CASE WHEN ( LTRIM(RTRIM(DEVICE_TYPE)) IS NULL OR RTRIM(LTRIM(DEVICE_TYPE)) = '' ) THEN 'SMARTPHONE'
     ELSE DEVICE_TYPE
END  DEVICE_TYPE ,   
CAT_VARIACION_MINFLU1 , CAT_VARIACION_MINFLU2 , 
CAT_VARIACION_APP1    , CAT_VARIACION_APP2    , CAT_VARIACION_APP3 , 
CAT_VARIACION_APP4    , CAT_VARIACION_APP5    , CAT_VARIACION_APP6 ,
CAT_VARIACION_APP7    , CAT_VARIACION_APP8    , CAT_VARIACION_APP9 ,
CAT_VARIACION_RESTO   ,
GIRO ,  SUBGIRO   ,  TIENE_PROD_1 ,  TIENE_PROD_2 , TIENE_PROD_3   ,
FLG_GRUPO1   , FLG_GRUPO2 , 
-- FLG_GRUPO3 , 
FLG_GRUPO4   , 
-- FLG_GRUPO5   , 
FLG_GRUPO6 ,
FLG_GRUPO7      , 
-- FLG_GRUPO8   , 
FLG_GRUPO9 ,
FLG_GRUPO10  , FLG_GRUPO11,
CASE WHEN  FLG_GRUPO3 = 1 THEN 1
     WHEN  FLG_GRUPO5 = 1 THEN 1
     WHEN  FLG_GRUPO8 = 1 THEN 1
     ELSE  0 
END  FLG_GRUPO16 ,       
FLG_TARGETPREV,
CASE 
    WHEN VCHPENALIDAD = 0 AND VCHMESADENDA = 0 THEN 'PROPIO'
    ELSE 'FINANCIADO'
END TIPOEQUIPO ,
VCHMESADENDA   ,
VCHPENALIDAD   ,
DAYS_FECINGRESO , DAYS_FECACTCONT  , DAYS_LANZAMIENT  ,
mins_flujo_1    , mins_flujo_2  , flg_flujo  ,
trafico_app_1   , trafico_app_2 , trafico_app_3 ,
trafico_app_4   , trafico_app_5 , trafico_app_6 , 
trafico_app_7   , trafico_app_8 , trafico_app_9 ,
trafico_resto   , apptoppreferida , flgusopreferente ,
TARGET
FROM      dfTablon12
WHERE     1 = 1
AND       TARGET IS NULL 
")


head(dfTrain)
head(dfSubmit)

# write.csv(dfTrain  , "dfTrainV_20220814_V2.csv", row.names = FALSE)
# write.csv(dfSubmit , "dfSubmitV_20220814_V2.csv", row.names = FALSE)

write.csv(dfTrain  , "dfTrainV_20220814_V4.csv", row.names = FALSE)
write.csv(dfSubmit , "dfSubmitV_20220814_V4.csv", row.names = FALSE)










dfTrain2 = 
  sqldf("SELECT    
nro_telefono_hash ,  TIPO_ADQ     ,  SCORECAT     , 
-- MARCA , 
CASE WHEN MARCA = 'dc937b59892604f5a86ac96936cd7ff09e25f18ae6b758e8014a24c7fa039e91' THEN '2a1022b922f5038bc5bff79ff2960cd12cf266647b4f59121997a75c710b5b5d'
     ELSE MARCA
END  MARCA ,      
-- MODELO ,  
NUEVA_GAMMA ,  
CASE WHEN OS = 'dc937b59892604f5a86ac96936cd7ff09e25f18ae6b758e8014a24c7fa039e91' THEN 'fb8e9c929bbc4ccaebcf8d68296c419464bdfaf01a69708a4d01a0d3159f3116'   
     ELSE OS
END  OS   , 
-- DEVICE_TYPE ,
CASE WHEN ( LTRIM(RTRIM(DEVICE_TYPE)) IS NULL OR RTRIM(LTRIM(DEVICE_TYPE)) = '' ) THEN 'SMARTPHONE'
     ELSE DEVICE_TYPE
END  DEVICE_TYPE ,      
GIRO ,  SUBGIRO   ,  TIENE_PROD_1 ,  TIENE_PROD_2 , TIENE_PROD_3   ,
FLG_GRUPO1   , FLG_GRUPO2 , 
-- FLG_GRUPO3 , 
FLG_GRUPO4   , 
-- FLG_GRUPO5   , 
FLG_GRUPO6 ,
FLG_GRUPO7      , 
-- FLG_GRUPO8   , 
FLG_GRUPO9 ,
FLG_GRUPO10  , FLG_GRUPO11,
CASE WHEN  FLG_GRUPO3 = 1 THEN 1
     WHEN  FLG_GRUPO5 = 1 THEN 1
     WHEN  FLG_GRUPO8 = 1 THEN 1
     ELSE  0 
END  FLG_GRUPO16 ,       
FLG_TARGETPREV,
CASE 
    WHEN VCHPENALIDAD = 0 AND VCHMESADENDA = 0 THEN 'PROPIO'
    ELSE 'FINANCIADO'
END TIPOEQUIPO ,
VCHMESADENDA   ,
VCHPENALIDAD   ,
DAYS_FECINGRESO , DAYS_FECACTCONT  , DAYS_LANZAMIENT  ,
mins_flujo_1    , mins_flujo_2  , flg_flujo  ,
trafico_app_1   , trafico_app_2 , trafico_app_3 ,
trafico_app_4   , trafico_app_5 , trafico_app_6 , 
trafico_app_7   , trafico_app_8 , trafico_app_9 ,
trafico_resto   , apptoppreferida , flgusopreferente ,
TARGET
FROM      dfTablon12
WHERE     1 = 1
AND       TARGET IS NOT NULL 
and       numperiodo > 202201
")

write.csv( dfTrain2  , "dfTrainV_20220814_V3.csv", row.names = FALSE)



 
xx = sqldf("
SELECT    FLG_TARGETPREV , count(1) total 
from      dfTrain2 
group by  FLG_TARGETPREV
")  

xx %>% 
  mutate(Percent = 100*total/sum(total))



  