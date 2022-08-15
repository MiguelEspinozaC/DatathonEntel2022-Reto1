library(dplyr)
library(MLmetrics)
library(party)
library(lattice)
library(mlr)
library(sqldf)
library(ggplot2)
library(C50)
library(rpart)

options(repr.matrix.max.cols=150, repr.matrix.max.rows=200)



list.files( pattern=NULL, all.files=FALSE, full.names=FALSE)

##################################################################################################################################################
## CARGAMOS LAS BASES 
##################################################################################################################################################

## 
DfSuscriptor_01 <- read.csv(file = '01_suscriptora_202201_202204.csv')
head(DfSuscriptor_01)


## 
DfAdenda_01 <- read.csv(file =  '02_adenda_202201_202204.csv')
head(DfAdenda_01)


##
DfPerfilDigital_01 <- read.csv(file =  '03_perfil_digital_202201_202204.csv')
head(DfPerfilDigital_01)


## 
DfRoaming_01 <- read.csv(file =  '04_roaming_202201_202204.csv')
head(DfRoaming_01)


## 
DfTerminales_01 <- read.csv(file = '05_terminales_202201_202204.csv')
head(DfTerminales_01)


## 
DfTrafico_01 <- read.csv(file =  '06_trafico_202201_202204.csv')
head(DfTrafico_01)


## 
DfConvergente_01 <- read.csv(file =  '07_convergente_202201_202204.csv')
head(DfConvergente_01)


## 
DfTarget_01 <- read.csv(file =  '08_target_202201_202203.csv')
head(DfTarget_01)






##################################################################################################################################################
## Juntamos Bases 
##################################################################################################################################################

### Cruce 01
dfTablon01 = sqldf(" SELECT A.* , B.TARGET
                     FROM   DfSuscriptor_01 A
                     LEFT JOIN DfTarget_01  B
                     ON ( A.nro_telefono_hash  = B.nro_telefono_hash  
                     AND  A.NUMPERIODO         = B.PERIODO )
                   ")

### Cruce 02
dfTablon02 = sqldf(" SELECT A.* , 
                            CASE WHEN B.nro_telefono_hash IS NULL THEN 0 ELSE 1 END AS FLG_PERFIL , 
                            B.GRUPO      , 
                            B.SCORECAT   
                     FROM   dfTablon01             A
                     LEFT JOIN DfPerfilDigital_01  B
                     ON ( A.nro_telefono_hash  = B.nro_telefono_hash  
                     AND  A.NUMPERIODO         = B.PERIODO )
                   ")

### Cruce 03
dfTablon03 = sqldf(" SELECT A.* , B.MARCA , B.MODELO , B.NUEVA_GAMMA , B.LANZAMIENTO , B.OS , B.DEVICE_TYPE 
                     FROM   dfTablon02             A
                     LEFT JOIN DfTerminales_01     B
                     ON ( A.nro_telefono_hash  = B.nro_telefono_hash  
                     AND  A.NUMPERIODO         = B.PERIODO )
                   ")


### Cruce 04
dfTablon04 = sqldf(" SELECT A.* , B.GIRO , B.SUBGIRO , B.TIENE_PROD_1 , B.TIENE_PROD_2 , B.TIENE_PROD_3
                     FROM   dfTablon03             A
                     LEFT JOIN DfConvergente_01    B
                     ON ( A.nro_documento_hash  = B.nro_documento_hash
                     AND  A.NUMPERIODO          = B.PERIODO )
                   ")


DfRoaming_01[is.na(DfRoaming_01)] <- 0
head(DfRoaming_01)

DfRoaming_01_TOTAL  = 
  sqldf(" SELECT   PERIODO ,
                 nro_telefono_hash  ,
                    SUM( MINUTOS )     AS ROA_TOT_MINUTOS  , 
                    SUM( GIGAS  )      AS ROA_TOT_GIGAS    ,
                    SUM( MENSAJES   )  AS ROA_TOT_MENSAJES
        FROM     DfRoaming_01
        WHERE    1 = 1         
        GROUP BY PERIODO , nro_telefono_hash  
        ORDER BY PERIODO 
      ")


### Cruce 05
dfTablon05 = sqldf(" SELECT A.* , 
                            CASE WHEN B.nro_telefono_hash  IS NULL THEN 0 ELSE 1                  END AS FLG_ROAMING         ,
                            CASE WHEN B.ROA_TOT_MINUTOS    IS NULL THEN 0 ELSE B.ROA_TOT_MINUTOS  END AS ROA_TOT_MINUTOS     ,
                            CASE WHEN B.ROA_TOT_GIGAS      IS NULL THEN 0 ELSE B.ROA_TOT_GIGAS    END AS ROA_TOT_GIGAS       ,
                            CASE WHEN B.ROA_TOT_MENSAJES   IS NULL THEN 0 ELSE B.ROA_TOT_MENSAJES END AS ROA_TOT_MENSAJES    
                     FROM   dfTablon04                A
                     LEFT JOIN DfRoaming_01_TOTAL     B
                     ON ( A.nro_telefono_hash  = B.nro_telefono_hash
                     AND  A.NUMPERIODO         = B.PERIODO )
                   ")


### Cruce 06
dfTablon06 = sqldf(" SELECT    A.* , 
                               B.mins_flujo_1   ,
                               B.mins_flujo_2   ,
                               B.trafico_app_1  ,
                               B.trafico_app_2  ,
                               B.trafico_app_3  ,
                               B.trafico_app_4  ,
                               B.trafico_app_5  ,
                               B.trafico_app_6  ,
                               B.trafico_app_7  ,
                               B.trafico_app_8  ,
                               B.trafico_app_9  ,
                               B.trafico_total
                     FROM      dfTablon05       A
                     LEFT JOIN DfTrafico_01     B
                     ON ( A.nro_telefono_hash  = B.nro_telefono_hash
                     AND  A.NUMPERIODO         = B.NUMPERIODO )
                   ")


### Cruce 07
dfTablon07 = sqldf(" SELECT    A.* , 
                               CASE WHEN B.nro_telefono_hash IS NULL THEN 0 ELSE 1 END AS FLG_ADENDA , 
                               CASE WHEN B.nro_telefono_hash IS NULL THEN 0 ELSE B.VCHMESADENDA  END AS VCHMESADENDA , 
                               CASE WHEN B.nro_telefono_hash IS NULL THEN 0 ELSE B.VCHPENALIDAD  END AS VCHPENALIDAD 
                     FROM      dfTablon06       A
                     LEFT JOIN DfAdenda_01      B
                     ON ( A.nro_telefono_hash  = B.nro_telefono_hash
                     AND  A.NUMPERIODO         = B.NUMPERIODO )
                   ")


rm(dfTablon06)
rm(dfTablon05)
rm(dfTablon04)
rm(dfTablon03)
rm(dfTablon02)
rm(dfTablon01)




data.frame(colSums(is.na(dfTablon07)))
dfTablon07$FECINGRESOCLIENTE_DATE     =  as.Date(dfTablon07$FECINGRESOCLIENTE, format="%Y-%m-%d")
dfTablon07$FECACTIVACIONCONTRATO_DATE =  as.Date(dfTablon07$FECACTIVACIONCONTRATO, format="%Y-%m-%d")


summary(dfTablon07)




v_total = dfTablon07 %>% 
  count()

v_01 = dfTablon07 %>% 
  dplyr::filter( FECACTIVACIONCONTRATO_DATE == '0001-01-01' ) %>%
  count()

v_02 = dfTablon07 %>% 
  dplyr::filter( FECINGRESOCLIENTE_DATE     == '0001-01-01' ) %>%
  count()


v_02*100/ v_total
v_01*100/ v_total


summary(
  dfTablon07 %>% 
    dplyr::filter( FECACTIVACIONCONTRATO_DATE != '0001-01-01' ) %>% 
    dplyr::select( FECACTIVACIONCONTRATO_DATE )
)



dfTablon07 = dfTablon07 %>%
  dplyr::mutate( FECACTIVACIONCONTRATO_DATE = 
                   case_when (  FECACTIVACIONCONTRATO_DATE == '0001-01-01' ~  as.Date("2020-09-22", format="%Y-%m-%d") ,
                                TRUE                                       ~  FECACTIVACIONCONTRATO_DATE 
                   ))

summary(
  dfTablon07 %>% 
    dplyr::select( FECACTIVACIONCONTRATO_DATE )
)


###############################################################################
summary(
  dfTablon07 %>% 
    dplyr::filter( FECINGRESOCLIENTE_DATE != '0001-01-01' ) %>% 
    dplyr::select( FECINGRESOCLIENTE_DATE )
)



summary(
  dfTablon07 %>% 
    dplyr::filter( FECINGRESOCLIENTE_DATE >= '2022-05-01' ) %>% 
    dplyr::select( FECINGRESOCLIENTE_DATE ) %>% distinct()
)


##############################################

dfTablon07 = dfTablon07 %>%
  dplyr::mutate( FECINGRESOCLIENTE_DATE = 
                   case_when (  FECINGRESOCLIENTE_DATE >= '2022-05-01' ~ FECINGRESOCLIENTE_DATE - 100*365 - 25 ,
                                TRUE                    ~  FECINGRESOCLIENTE_DATE 
                   ))

dfTablon07 = dfTablon07 %>%
  dplyr::mutate( FECINGRESOCLIENTE_DATE = 
                   case_when (  FECINGRESOCLIENTE_DATE == '0001-01-01' ~  as.Date("2017-04-05", format="%Y-%m-%d") ,
                                TRUE                                   ~  FECINGRESOCLIENTE_DATE 
                   ))


summary(
  dfTablon07 %>% 
    dplyr::select( FECINGRESOCLIENTE_DATE )
)





##############################################
dfTablon07$LANZAMIENTO_DATE     =  as.Date(dfTablon07$LANZAMIENTO, format="%Y-%m-%d")
## Porcentaje de Nulos ###
## Cerca del 20% ########
149276*100/ v_total


summary(
  dfTablon07 %>% 
    dplyr::select( LANZAMIENTO_DATE )
)

#####
dfTablon07 %>% 
  dplyr::filter( LANZAMIENTO == "" ) %>%head()


dfTablon07 %>% 
  dplyr::filter( is.na(LANZAMIENTO)  ) %>%head()
#########



dfTablon07 = dfTablon07 %>%
  dplyr::mutate( LANZAMIENTO_DATE = 
                   case_when (  LANZAMIENTO_DATE >= '2022-05-01' ~  LANZAMIENTO_DATE - 100*365 - 25 ,
                                TRUE                             ~  LANZAMIENTO_DATE 
                   ))



summary(
  dfTablon07 %>% 
    dplyr::select( LANZAMIENTO_DATE )
)

dfTablon07 = dfTablon07 %>%
  dplyr::mutate( LANZAMIENTO_DATE = 
                   case_when (  is.na(LANZAMIENTO_DATE) ~  as.Date("2019-07-30", format="%Y-%m-%d") ,
                                TRUE                    ~  LANZAMIENTO_DATE 
                   ))








##############################################
## Obtenemos el último día hábil del mes 
##############################################
dfTablon07 = dfTablon07 %>%
  dplyr::mutate( LASTDAY_OF_MONTH  =  case_when (  NUMPERIODO == 202201      ~ "2022-01-31" ,
                                                   NUMPERIODO == 202202      ~ "2022-02-28" ,
                                                   NUMPERIODO == 202203      ~ "2022-03-31" ,
                                                   NUMPERIODO == 202204      ~ "2022-04-30" ,
                                                   TRUE                      ~ "2022-04-30" 
  ))

dfTablon07$LASTDAY_OF_MONTH = as.Date(dfTablon07$LASTDAY_OF_MONTH, format="%Y-%m-%d")




############################################################################################
## Calculamos días para poder trabajar de mejor forma
############################################################################################
dfTablon07$DAYS_FECINGRESO  = dfTablon07$LASTDAY_OF_MONTH - dfTablon07$FECINGRESOCLIENTE_DATE
dfTablon07$DAYS_FECACTCONT  = dfTablon07$LASTDAY_OF_MONTH - dfTablon07$FECACTIVACIONCONTRATO_DATE
dfTablon07$DAYS_LANZAMIENT  = dfTablon07$LASTDAY_OF_MONTH - dfTablon07$LANZAMIENTO_DATE

dfTablon07$DAYS_FECINGRESO = as.numeric(dfTablon07$DAYS_FECINGRESO)
dfTablon07$DAYS_FECACTCONT = as.numeric(dfTablon07$DAYS_FECACTCONT)
dfTablon07$DAYS_LANZAMIENT = as.numeric(dfTablon07$DAYS_LANZAMIENT)

lista_mes = c("DAYS_FECINGRESO" , "DAYS_FECACTCONT" , "DAYS_LANZAMIENT" )
head( dfTablon07[lista_mes] )

summary(
  dfTablon07[lista_mes] 
)







### Imputación Simple
dfTablon07$MARCA[is.na(dfTablon07$MARCA)]              = "NOINFORMACION"
dfTablon07$MODELO[is.na(dfTablon07$MODELO)]            = "NOINFORMACION"
dfTablon07$NUEVA_GAMMA[is.na(dfTablon07$NUEVA_GAMMA)]  = "NOINFORMACION"
dfTablon07$OS[is.na(dfTablon07$OS )]                   = "NOINFORMACION"
dfTablon07$DEVICE_TYPE[is.na(dfTablon07$DEVICE_TYPE )] = "NOINFORMACION"
dfTablon07$SCORECAT[is.na(dfTablon07$SCORECAT)]        = "NOINFORMACION"  





############################################################################################
## Ajuste al tráfico 
############################################################################################

dfTablon07$mins_flujo_1[is.na(dfTablon07$mins_flujo_1)]   <- 0
dfTablon07$mins_flujo_2[is.na(dfTablon07$mins_flujo_2)]   <- 0
dfTablon07$trafico_app_1[is.na(dfTablon07$trafico_app_1)] <- 0
dfTablon07$trafico_app_2[is.na(dfTablon07$trafico_app_2)] <- 0
dfTablon07$trafico_app_3[is.na(dfTablon07$trafico_app_3)] <- 0
dfTablon07$trafico_app_4[is.na(dfTablon07$trafico_app_4)] <- 0
dfTablon07$trafico_app_5[is.na(dfTablon07$trafico_app_5)] <- 0
dfTablon07$trafico_app_6[is.na(dfTablon07$trafico_app_6)] <- 0
dfTablon07$trafico_app_7[is.na(dfTablon07$trafico_app_7)] <- 0
dfTablon07$trafico_app_8[is.na(dfTablon07$trafico_app_8)] <- 0
dfTablon07$trafico_app_9[is.na(dfTablon07$trafico_app_9)] <- 0
dfTablon07$trafico_total[is.na(dfTablon07$trafico_total)] <- 0

dfTablon07$trafico_resto =  dfTablon07$trafico_total -  dfTablon07$trafico_app_9 - dfTablon07$trafico_app_8 - dfTablon07$trafico_app_7 - dfTablon07$trafico_app_6  -  dfTablon07$trafico_app_5 - dfTablon07$trafico_app_4 - dfTablon07$trafico_app_3 - dfTablon07$trafico_app_2 -  dfTablon07$trafico_app_1 

lista_trafico = c("trafico_app_1" , "trafico_app_2" , "trafico_app_3"  , "trafico_app_4" , "trafico_app_5" ,
                  "trafico_app_6" , "trafico_app_7" , "trafico_app_8"  , "trafico_app_9" , "trafico_resto" ,
                  "trafico_total" 
)

head( dfTablon07[lista_trafico] )


summary(
  dfTablon07 %>% 
    dplyr::select( lista_trafico )
)




############################################################################################
## Ajuste de la penalidad
############################################################################################

x = dfTablon07 %>%
  dplyr::filter( VCHMESADENDA > 0 ) %>% 
  dplyr::select( VCHPENALIDAD )  
x = as.numeric(unlist(x))
inp_01 = median( x , na.rm=T)


dfTablon07 = dfTablon07 %>%
  dplyr::mutate( VCHPENALIDAD  =  case_when (
    is.na(VCHPENALIDAD)    ~ inp_01  ,
    TRUE                   ~ VCHPENALIDAD 
  ))






#install.packages("splitstackshape")
library(splitstackshape)

dfTablon07 = cSplit(dfTablon07, "GRUPO","|")
head(dfTablon07)


dfTablon08 = 
  sqldf("SELECT      A.* , 
                   CASE WHEN ( GRUPO_01 = 'grupo_1' OR GRUPO_02 = 'grupo_1' OR GRUPO_03 = 'grupo_1'
                           OR  GRUPO_04 = 'grupo_1' OR GRUPO_05 = 'grupo_1' OR GRUPO_06 = 'grupo_1'  
                           OR  GRUPO_07 = 'grupo_1' OR GRUPO_08 = 'grupo_1' OR GRUPO_09 = 'grupo_1' 
                           OR  GRUPO_10 = 'grupo_1' OR GRUPO_11 = 'grupo_1' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO1 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_2'  OR GRUPO_02 = 'grupo_2' OR GRUPO_03 = 'grupo_2'
                           OR  GRUPO_04 = 'grupo_2'  OR GRUPO_05 = 'grupo_2' OR GRUPO_06 = 'grupo_2'  
                           OR  GRUPO_07 = 'grupo_2'  OR GRUPO_08 = 'grupo_2' OR GRUPO_09 = 'grupo_2' 
                           OR  GRUPO_10 = 'grupo_2'  OR GRUPO_11 = 'grupo_2' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO2 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_3' OR GRUPO_02 = 'grupo_3' OR GRUPO_03 = 'grupo_3'
                           OR  GRUPO_04 = 'grupo_3' OR GRUPO_05 = 'grupo_3' OR GRUPO_06 = 'grupo_3'  
                           OR  GRUPO_07 = 'grupo_3' OR GRUPO_08 = 'grupo_3' OR GRUPO_09 = 'grupo_3' 
                           OR  GRUPO_10 = 'grupo_3' OR GRUPO_11 = 'grupo_3' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO3 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_4' OR GRUPO_02 = 'grupo_4' OR GRUPO_03 = 'grupo_4'
                           OR  GRUPO_04 = 'grupo_4' OR GRUPO_05 = 'grupo_4' OR GRUPO_06 = 'grupo_4'  
                           OR  GRUPO_07 = 'grupo_4' OR GRUPO_08 = 'grupo_4' OR GRUPO_09 = 'grupo_4' 
                           OR  GRUPO_10 = 'grupo_4' OR GRUPO_11 = 'grupo_4' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO4 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_5' OR GRUPO_02 = 'grupo_5' OR GRUPO_03 = 'grupo_5'
                           OR  GRUPO_04 = 'grupo_5' OR GRUPO_05 = 'grupo_5' OR GRUPO_06 = 'grupo_5'  
                           OR  GRUPO_07 = 'grupo_5' OR GRUPO_08 = 'grupo_5' OR GRUPO_09 = 'grupo_5' 
                           OR  GRUPO_10 = 'grupo_5' OR GRUPO_11 = 'grupo_5' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO5 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_6' OR GRUPO_02 = 'grupo_6' OR GRUPO_03 = 'grupo_6'
                           OR  GRUPO_04 = 'grupo_6' OR GRUPO_05 = 'grupo_6' OR GRUPO_06 = 'grupo_6'  
                           OR  GRUPO_07 = 'grupo_6' OR GRUPO_08 = 'grupo_6' OR GRUPO_09 = 'grupo_6' 
                           OR  GRUPO_10 = 'grupo_6' OR GRUPO_11 = 'grupo_6' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO6 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_7' OR GRUPO_02 = 'grupo_7' OR GRUPO_03 = 'grupo_7'
                           OR  GRUPO_04 = 'grupo_7' OR GRUPO_05 = 'grupo_7' OR GRUPO_06 = 'grupo_7'  
                           OR  GRUPO_07 = 'grupo_7' OR GRUPO_08 = 'grupo_7' OR GRUPO_09 = 'grupo_7' 
                           OR  GRUPO_10 = 'grupo_7' OR GRUPO_11 = 'grupo_7' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO7 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_8' OR GRUPO_02 = 'grupo_8' OR GRUPO_03 = 'grupo_8'
                           OR  GRUPO_04 = 'grupo_8' OR GRUPO_05 = 'grupo_8' OR GRUPO_06 = 'grupo_8'  
                           OR  GRUPO_07 = 'grupo_8' OR GRUPO_08 = 'grupo_8' OR GRUPO_09 = 'grupo_8' 
                           OR  GRUPO_10 = 'grupo_8' OR GRUPO_11 = 'grupo_8' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO8 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_9' OR GRUPO_02 = 'grupo_9' OR GRUPO_03 = 'grupo_9'
                           OR  GRUPO_04 = 'grupo_9' OR GRUPO_05 = 'grupo_9' OR GRUPO_06 = 'grupo_9'  
                           OR  GRUPO_07 = 'grupo_9' OR GRUPO_08 = 'grupo_9' OR GRUPO_09 = 'grupo_9' 
                           OR  GRUPO_10 = 'grupo_9' OR GRUPO_11 = 'grupo_9' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO9 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_10' OR GRUPO_02 = 'grupo_10' OR GRUPO_03 = 'grupo_10'
                           OR  GRUPO_04 = 'grupo_10' OR GRUPO_05 = 'grupo_10' OR GRUPO_06 = 'grupo_10'  
                           OR  GRUPO_07 = 'grupo_10' OR GRUPO_08 = 'grupo_10' OR GRUPO_09 = 'grupo_10' 
                           OR  GRUPO_10 = 'grupo_10' OR GRUPO_11 = 'grupo_10' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO10 , 
                   CASE WHEN ( GRUPO_01 = 'grupo_11' OR GRUPO_02 = 'grupo_11' OR GRUPO_03 = 'grupo_11'
                           OR  GRUPO_04 = 'grupo_11' OR GRUPO_05 = 'grupo_11' OR GRUPO_06 = 'grupo_11'  
                           OR  GRUPO_07 = 'grupo_11' OR GRUPO_08 = 'grupo_11' OR GRUPO_09 = 'grupo_11' 
                           OR  GRUPO_10 = 'grupo_11' OR GRUPO_11 = 'grupo_11' ) THEN 1
                        ELSE 0
                   END FLG_GRUPO11                 
       FROM        dfTablon07 A
       WHERE       1 = 1
")



dropList <- c("GRUPO_01", "GRUPO_02", "GRUPO_03", "GRUPO_04", "GRUPO_05", 
              "GRUPO_06", "GRUPO_07", "GRUPO_08", "GRUPO_09", "GRUPO_10",
              "GRUPO_11"
)
dfTablon08 <- dfTablon08[, !colnames(dfTablon08) %in% dropList]

head(dfTablon08)



## ASÍ COMENTAMOS UN BLOQUE DE CÓDIGO CTRL+SHIFT+C 

# dfTablon09 =
#   sqldf("SELECT    A.*  ,
#                  CASE WHEN B.TARGET IS NULL THEN 'NO_INFORMACION'
#                       WHEN B.TARGET = 1     THEN 'SI_TARGET'
#                       WHEN B.TARGET = 0     THEN 'NO_TARGET'
#                  END  FLG_TARGETPREV
#        FROM      dfTablon08 A
#        LEFT JOIN dfTablon08 B
#        ON ( A.nro_telefono_hash = B.nro_telefono_hash
#        AND  A.NUMPERIODO -1     = B.NUMPERIODO
#          ) "  )



dfTablon09 = 
  sqldf(
"SELECT    A.*  , 
CASE 
     WHEN B.TARGET IS NULL THEN 'NO_INFORMACION'
     WHEN B.TARGET = 1     THEN 'SI_TARGET'
     WHEN B.TARGET = 0     THEN 'NO_TARGET'
END  FLG_TARGETPREV  ,


CASE 
     WHEN B.mins_flujo_1  is null                THEN 'noinfo'
     WHEN B.mins_flujo_1 / A.mins_flujo_1  < 0.8 THEN 'RANGO_01'
     WHEN B.mins_flujo_1 / A.mins_flujo_1  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_MINFLU1 , 

CASE 
     WHEN B.mins_flujo_2  is null                THEN 'noinfo'
     WHEN B.mins_flujo_2 / A.mins_flujo_2  < 0.8 THEN 'RANGO_01'
     WHEN B.mins_flujo_2 / A.mins_flujo_2  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_MINFLU2 , 

CASE 
     WHEN B.trafico_app_1  is null                 THEN 'noinfo'
     WHEN B.trafico_app_1 / A.trafico_app_1  < 0.8 THEN 'RANGO_01'
     WHEN B.trafico_app_1 / A.trafico_app_1  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_APP1 , 

CASE 
     WHEN B.trafico_app_2  is null                 THEN 'noinfo'
     WHEN B.trafico_app_2 / A.trafico_app_2  < 0.8 THEN 'RANGO_01'
     WHEN B.trafico_app_2 / A.trafico_app_2  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_APP2 , 

CASE 
     WHEN B.trafico_app_3  is null                 THEN 'noinfo'
     WHEN B.trafico_app_3 / A.trafico_app_3  < 0.8 THEN 'RANGO_01'
     WHEN B.trafico_app_3 / A.trafico_app_3  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_APP3 , 


CASE 
     WHEN B.trafico_app_4  is null                 THEN 'noinfo'
     WHEN B.trafico_app_4 / A.trafico_app_4  < 0.8 THEN 'RANGO_01'
     WHEN B.trafico_app_4 / A.trafico_app_4  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_APP4 ,


CASE 
     WHEN B.trafico_app_5  is null                 THEN 'noinfo'
     WHEN B.trafico_app_5 / A.trafico_app_5  < 0.8 THEN 'RANGO_01'
     WHEN B.trafico_app_5 / A.trafico_app_5  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_APP5 ,


CASE 
     WHEN B.trafico_app_6  is null                 THEN 'noinfo'
     WHEN B.trafico_app_6 / A.trafico_app_6  < 0.8 THEN 'RANGO_01'
     WHEN B.trafico_app_6 / A.trafico_app_6  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_APP6 ,

CASE 
     WHEN B.trafico_app_7  is null                 THEN 'noinfo'
     WHEN B.trafico_app_7 / A.trafico_app_7  < 0.8 THEN 'RANGO_01'
     WHEN B.trafico_app_7 / A.trafico_app_7  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_APP7 ,


CASE 
     WHEN B.trafico_app_8   is null                   THEN 'noinfo'
     WHEN B.trafico_app_8  / A.trafico_app_8   < 10   THEN 'RANGO_01'
     ELSE 'RANGO_02'
END  CAT_VARIACION_APP8 ,

CASE 
     WHEN B.trafico_app_9  is null                 THEN 'noinfo'
     WHEN B.trafico_app_9 / A.trafico_app_9  < 0.8 THEN 'RANGO_01'
     WHEN B.trafico_app_9 / A.trafico_app_9  < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_APP9 ,

CASE 
     WHEN B.trafico_resto   is null                  THEN 'noinfo'
     WHEN B.trafico_resto  / A.trafico_resto  < 0.8  THEN 'RANGO_01'
     WHEN B.trafico_resto  / A.trafico_resto   < 1.2 THEN 'RANGO_02'
     ELSE 'RANGO_03'
END  CAT_VARIACION_RESTO 

FROM      dfTablon08 A
LEFT JOIN dfTablon08 B
ON ( A.nro_telefono_hash = B.nro_telefono_hash
AND  A.NUMPERIODO -1     = B.NUMPERIODO ) 
"  )



## head(dfTablon09)





list_categoricas <- c("MARCA", "MODELO", "NUEVA_GAMMA", "OS", "DEVICE_TYPE", 
                      "GIRO", "SUBGIRO","TARGET"
)

dfTablon09_REVISION <- dfTablon09[list_categoricas]
head(dfTablon09_REVISION)

cantidad = length(colnames(dfTablon09_REVISION))
cantidad = cantidad - 1

for(i in 1:cantidad ) {
  print(i)  
  valores_train = dfTablon09_REVISION%>%filter( !is.na(TARGET) )
  valores_train = valores_train[i]%>%distinct()  
  
  valores_test  = dfTablon09_REVISION%>%filter(  is.na(TARGET) )
  valores_test  = valores_test[i]%>%distinct()  
  
  
  if ( i == 1) {
    l_MARCA_a = setdiff( valores_train, valores_test) 
    l_MARCA_b = setdiff( valores_test , valores_train) 
  } else if ( i == 2) {
    l_MODELO_a = setdiff( valores_train, valores_test) 
    l_MODELO_b = setdiff( valores_test , valores_train) 
  } else if ( i == 3) {
    l_NUEVA_GAMMA_a = setdiff( valores_train, valores_test) 
    l_NUEVA_GAMMA_b = setdiff( valores_test , valores_train) 
  } else if ( i == 4) {
    l_OS_a = setdiff( valores_train, valores_test) 
    l_OS_b = setdiff( valores_test , valores_train) 
  } else if ( i == 5) {
    l_DEVICE_TYPE_a = setdiff( valores_train, valores_test) 
    l_DEVICE_TYPE_b = setdiff( valores_test , valores_train)   
  } else if ( i == 6) {
    l_GIRO_a = setdiff( valores_train, valores_test) 
    l_GIRO_b = setdiff( valores_test , valores_train) 
  } else if ( i == 7) {
    l_SUBGIRO_a = setdiff( valores_train, valores_test) 
    l_SUBGIRO_b = setdiff( valores_test , valores_train) 
  } 
  
  # print("----------------------------")
}

nrow (l_MARCA_a)
nrow (l_MARCA_b)
filter(dfTablon09, MARCA %in% l_MARCA_a$MARCA) %>% count()
filter(dfTablon09, MARCA %in% l_MARCA_b$MARCA) %>% count()

###
nrow (l_MODELO_a)
nrow (l_MODELO_b)
filter(dfTablon09, MODELO %in% l_MODELO_a$MODELO) %>% count()
filter(dfTablon09, MODELO %in% l_MODELO_b$MODELO) %>% count()



### TODOS CRUZAN
nrow (l_NUEVA_GAMMA_a)
nrow (l_NUEVA_GAMMA_b)



###
nrow (l_OS_a)
nrow (l_OS_b)
filter(dfTablon09, OS %in% l_OS_a$OS) %>% count()
filter(dfTablon09, OS %in% l_OS_b$OS) %>% count()

###
nrow (l_DEVICE_TYPE_a)
nrow (l_DEVICE_TYPE_b)
filter(dfTablon09, DEVICE_TYPE %in% l_DEVICE_TYPE_a$DEVICE_TYPE) %>% count()


###########
nrow (l_GIRO_a)
nrow (l_GIRO_b)
filter(dfTablon09, GIRO %in% l_GIRO_a$GIRO) %>% count()
filter(dfTablon09, GIRO %in% l_GIRO_b$GIRO) %>% count()


###
nrow (l_SUBGIRO_a)
nrow (l_SUBGIRO_b)
filter(dfTablon09, SUBGIRO %in% l_SUBGIRO_a$SUBGIRO) %>% count()
filter(dfTablon09, SUBGIRO %in% l_SUBGIRO_b$SUBGIRO) %>% count()






##d888b670ea547ae9f0466758f1e54f688a5de40fdcc46b9a9611331100df841e

sqldf("
SELECT    DISTINCT MARCA
FROM      dfTablon09
WHERE     1 = 1
AND       MODELO   = 'a0c25dcc89207e21f98b235fc0025439d9b38a530b6e7ac8d4336ecef750991f'
LIMIT     10
")



dfTablon09_REVISION%>%filter(  is.na(TARGET) )%>% count()
dfTablon09_REVISION%>%filter(  !is.na(TARGET) )%>% count()




nrow(dfTablon09)
#734544
dfTablon09 <- dfTablon09[ !dfTablon09$MARCA        %in% l_MARCA_a$MARCA                 , ]
dfTablon09 <- dfTablon09[ !dfTablon09$MODELO       %in% l_MODELO_a$MODELO               , ]
dfTablon09 <- dfTablon09[ !dfTablon09$OS           %in% l_OS_a$OS                       , ]
dfTablon09 <- dfTablon09[ !dfTablon09$DEVICE_TYPE  %in% l_DEVICE_TYPE_a$DEVICE_TYPE     , ]
dfTablon09 <- dfTablon09[ !dfTablon09$GIRO         %in% l_GIRO_a$GIRO                   , ]
dfTablon09 <- dfTablon09[ !dfTablon09$SUBGIRO      %in% l_SUBGIRO_a$SUBGIRO             , ]




## MARCA 
dfTablon09[dfTablon09$MARCA %in% l_MARCA_b$MARCA  , ]$MODELO           = "NOINFORMACION"
dfTablon09[dfTablon09$MARCA %in% l_MARCA_b$MARCA  , ]$NUEVA_GAMMA      = "NOINFORMACION"
dfTablon09[dfTablon09$MARCA %in% l_MARCA_b$MARCA  , ]$OS               = "NOINFORMACION"
dfTablon09[dfTablon09$MARCA %in% l_MARCA_b$MARCA  , ]$DEVICE_TYPE      = "NOINFORMACION"
dfTablon09[dfTablon09$MARCA %in% l_MARCA_b$MARCA  , ]$MARCA            = "NOINFORMACION"


## MODELO 
dfTablon09[dfTablon09$MODELO %in% l_MODELO_b$MODELO  , ]$NUEVA_GAMMA      = "NOINFORMACION"
dfTablon09[dfTablon09$MODELO %in% l_MODELO_b$MODELO  , ]$OS               = "NOINFORMACION"
dfTablon09[dfTablon09$MODELO %in% l_MODELO_b$MODELO  , ]$DEVICE_TYPE      = "NOINFORMACION"
dfTablon09[dfTablon09$MODELO %in% l_MODELO_b$MODELO  , ]$MARCA            = "NOINFORMACION"
dfTablon09[dfTablon09$MODELO %in% l_MODELO_b$MODELO  , ]$MODELO           = "NOINFORMACION"