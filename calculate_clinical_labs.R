calculate_clinical_labs <- function() {
  
  #install.packages("rJava")
  library(rJava)
  #install.packages("xlsx")
  library(xlsx)
  #install.packages("openxlsx")
  library(openxlsx)
  #install.packages("lubridate")
  library(lubridate)
  #install.packages("reshape")
  library(reshape)
  #install.packages("tidyr")
  library(tidyr)
  #install.packages("dplyr")
  library(dplyr)
  #install.packages("RMySQL")
  library(RMySQL)
  
  run <- "yes"
  while(run=="yes") {
    
    ## Read in all relevant data from xlsx files
    print("Input the four letters that signify the patient we are doing calculations for")
    print("Example: FILA")
    patient <- readline(prompt="Enter here: ")
    
    setwd("G:/MySQL Database/Demographics/")
    demo <- "DEMOGRAPHICS_SOURCE.xlsx"
    demo <- openxlsx::read.xlsx(demo,sheet=1,detectDates=TRUE)
    
    setwd("G:/MySQL Database/Labs/")
    ref <- "CLINICAL_LABS_REFERENCES_SOURCE.xlsx"
    ref <- openxlsx::read.xlsx(ref,sheet=1,detectDates=TRUE)
    
    print("Input the directory that you wish to draw this patient's CLINICAL_LABS_SOURCE file from")
    print("Example: C:/Folder_Name/")
    directory <- readline(prompt="Enter here: ")
    setwd(directory)
    
    labs <- "CLINICAL_LABS_SOURCE.xlsx"
    labs <- gsub(" ","",paste(patient,"_",labs))
    labs <- openxlsx::read.xlsx(labs,sheet=1,detectDates=TRUE)
    
    ## Remove all empty rows from each data frame
    labs <- labs[!is.na(labs$MRNUMBER),]
    demo <- demo[!is.na(demo$MRNUMBER),]
    ref <- ref[!is.na(ref$CLINICAL_LABS),]
    
    ## Store patient's medical record number as R object
    mrnumber <- unique(labs$MRNUMBER)
    
    ## Store patient's date of birth as R object
    dob <- demo[which(demo$MRNUMBER==mrnumber),colnames(demo)=="DOB"]
    
    ## Store patient's gender as R object (Male = 1, Female = 2)
    gender <- demo[which(demo$MRNUMBER==mrnumber),colnames(demo)=="GENDER"]
    gender <- ifelse(gender=="M",1,2)
    
    ## Create the data frame that will store the FILA_CLINICAL_LABS_REFERENCE temp file
    temp <- data.frame(MRNUMBER=character(),DATE=as.Date(as.character()),DAY_TYPE=integer(),
                       SOURCE=integer(),FASTING=integer(),AGE=integer(),
                       TG_BLOOD_BH=integer(),TG_BLOOD_H=integer(),
                       TG_BLOOD_VH=integer(),TG_BLOOD_UL=integer(),
                       HDL_BLOOD_BL=integer(),HDL_BLOOD_L=integer(),
                       HDL_BLOOD_H=integer(),HDL_BLOOD_LL=integer(),
                       LDL_BLOOD_BH=integer(),LDL_BLOOD_H=integer(),LDL_BLOOD_VH=integer(),
                       LDL_BLOOD_NO=integer(),LDL_BLOOD_UL=integer(),
                       TC_BLOOD_BH=integer(),TC_BLOOD_H=integer(),TC_BLOOD_UL=integer(),
                       NONHDL_BLOOD_BH=integer(),NONHDL_BLOOD_H=integer(),NONHDL_BLOOD_VH=integer(),
                       NONHDL_BLOOD_NO=integer(),NONHDL_BLOOD_UL=integer(),
                       NA_BLOOD_LL=integer(),NA_BLOOD_UL=integer(),
                       K_BLOOD_LL=integer(),K_BLOOD_UL=integer(),
                       CHL_BLOOD_LL=integer(),CHL_BLOOD_UL=integer(),
                       CO2_BLOOD_LL=integer(),CO2_BLOOD_UL=integer(), 
                       BUN_BLOOD_LL=integer(),BUN_BLOOD_UL=integer(),
                       CR_BLOOD_LL=integer(),CR_BLOOD_UL=integer(),
                       GLUS_BLOOD_LL=integer(),GLUS_BLOOD_UL=integer(),
                       GLUS_BLOOD_BH=integer(),GLUS_BLOOD_H=integer(),
                       CA_BLOOD_LL=integer(),CA_BLOOD_UL=integer(),
                       MAG_BLOOD_LL=integer(),MAG_BLOOD_UL=integer(),
                       PHOS_BLOOD_LL=integer(),PHOS_BLOOD_UL=integer(),
                       URIC_ACID_BLOOD_LL=integer(),URIC_ACID_BLOOD_UL=integer(),
                       PRO_BLOOD_LL=integer(),PRO_BLOOD_UL=integer(),
                       ALB_BLOOD_LL=integer(),ALB_BLOOD_UL=integer(),
                       TBIL_BLOOD_LL=integer(),TBIL_BLOOD_UL=integer(),
                       ALP_BLOOD_LL=integer(),ALP_BLOOD_UL=integer(),
                       AST_BLOOD_LL=integer(),AST_BLOOD_UL=integer(),
                       ALT_BLOOD_LL=integer(),ALT_BLOOD_UL=integer(),
                       RBC_BLOOD_LL=integer(),RBC_BLOOD_UL=integer(),
                       HGB_BLOOD_LL=integer(),HGB_BLOOD_UL=integer(),
                       HCT_BLOOD_LL=integer(),HCT_BLOOD_UL=integer(),
                       PLATELET_BLOOD_LL=integer(),PLATELET_BLOOD_UL=integer(),
                       MCV_BLOOD_LL=integer(),MCV_BLOOD_UL=integer(),
                       MCH_BLOOD_LL=integer(),MCH_BLOOD_UL=integer(),
                       MCHC_BLOOD_LL=integer(),MCHC_BLOOD_UL=integer(),
                       MPV_BLOOD_LL=integer(),MPV_BLOOD_UL=integer(),
                       RDW_BLOOD_LL=integer(),RDW_BLOOD_UL=integer(),
                       WBC_BLOOD_LL=integer(),WBC_BLOOD_UL=integer(),
                       BHB_BLOOD_LL=integer(),BHB_BLOOD_UL=integer(),
                       NEUTROPHILS_BLOOD_LL=integer(),NEUTROPHILS_BLOOD_UL=integer(),
                       LYMPHOCYTES_BLOOD_LL=integer(),LYMPHOCYTES_BLOOD_UL=integer(),
                       MONOCYTES_BLOOD_LL=integer(),MONOCYTES_BLOOD_UL=integer(),
                       EOSINOPHILS_BLOOD_LL=integer(),EOSINOPHILS_BLOOD_UL=integer(),
                       BASOPHILS_BLOOD_LL=integer(),BASOPHILS_BLOOD_UL=integer(),
                       LARGE_UNSTAINED_CELLS_BLOOD_LL=integer(),LARGE_UNSTAINED_CELLS_BLOOD_UL=integer(),
                       NEUTROPHILS_ABSOLUTE_BLOOD_LL=integer(),NEUTROPHILS_ABSOLUTE_BLOOD_UL=integer(),
                       LYMPHOCYTES_ABSOLUTE_BLOOD_LL=integer(),LYMPHOCYTES_ABSOLUTE_BLOOD_UL=integer(),
                       MONOCYTES_ABSOLUTE_BLOOD_LL=integer(),MONOCYTES_ABSOLUTE_BLOOD_UL=integer(),
                       EOSINOPHILS_ABSOLUTE_BLOOD_LL=integer(),EOSINOPHILS_ABSOLUTE_BLOOD_UL=integer(),
                       BASOPHILS_ABSOLUTE_BLOOD_LL=integer(),BASOPHILS_ABSOLUTE_BLOOD_UL=integer(),
                       GLUS_BLOOD_CRC_LL=integer(),GLUS_BLOOD_CRC_UL=integer(),
                       GLUS_BLOOD_CRC_BH=integer(),GLUS_BLOOD_CRC_H=integer(),
                       LACT_BLOOD_CRC_MMOL_LL=integer(),LACT_BLOOD_CRC_MMOL_UL=integer(),
                       LAB_BLOOD_1_LL=integer(),LAB_BLOOD_1_UL=integer())
    temp[1:(dim(labs)[1]),] <- NA
    temp$MRNUMBER <- labs$MRNUMBER
    temp$DATE <- as.Date(labs$DATE,format="%m/%d/%Y")
    temp$TIME <- labs$TIME
    temp$DAY_TYPE <- labs$DAY_TYPE
    temp$SOURCE <- labs$SOURCE
    temp$FASTING <- labs$FASTING
    temp$AGE <- as.integer(difftime(temp$DATE,dob,units="days"))
    temp <- melt(temp,id=c("MRNUMBER","DATE","TIME","DAY_TYPE","SOURCE","FASTING","AGE"))
    #temp <- temp[order(temp$DATE),]
    ## Loop through all lab normal lower limit and lab normal upper limit columns in the temp file
    for (i in unique(temp$variable)) {
      
      if (!(grepl("TG_BLOOD",i) | 
            grepl("NONHDL_BLOOD",i) | 
            grepl("LDL_BLOOD",i) |
            grepl("TC_BLOOD",i) |
            grepl("HDL_BLOOD",i) |
            grepl("GLUS_BLOOD",i) |
            grepl("GLUS_BLOOD_CRC",i))) {
        base <- ifelse(grepl("_LL",i),gsub("_LL","",i),gsub("_UL","",i))
        sub <- ref[ref$GENDER==gender & ref$CLINICAL_LABS==base, 
                   colnames(ref) %in% c("CLINICAL_LABS","AGE_LOWER_LIMIT","AGE_UPPER_LIMIT","GENDER","NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT")]
        rname <- ifelse(grepl("_LL",i),"NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT")
        for (j in 1:(dim(temp[temp$variable==i,])[1])) {
          if (!is.na(sub[sub$AGE_LOWER_LIMIT<=temp[temp$variable==i,colnames(temp)=="AGE"][j] & sub$AGE_UPPER_LIMIT>temp[temp$variable==i,colnames(temp)=="AGE"][j],colnames(sub)==rname])) {
            temp[temp$variable==i,colnames(temp)=="value"][j] <- sub[sub$AGE_LOWER_LIMIT<=temp[temp$variable==i,colnames(temp)=="AGE"][j] & sub$AGE_UPPER_LIMIT>temp[temp$variable==i,colnames(temp)=="AGE"][j],colnames(sub)==rname]
          }
        }
      } else {
        rname <- ""
        if (grepl("_LL",i)) {
          rname <- "NORMAL_LOWER_LIMIT"
        } else if (grepl("_UL",gsub("_BLOOD","",i))) {
          rname <- "NORMAL_UPPER_LIMIT"
        } else if (grepl("_BH",gsub("_BLOOD","",i))) {
          rname <- "BORDERLINE_UPPER_LIMIT"
        } else if (grepl("_BL",gsub("_BLOOD","",i))) {
          rname <- "BORDERLINE_LOWER_LIMIT"
        } else if (grepl("_L",gsub("_BLOOD","",i))) {
          rname <- "HIGH_LOWER_LIMIT"
        } else if (grepl("_H",gsub("_BLOOD","",i))) {
          rname <- "HIGH_UPPER_LIMIT"
        } else if (grepl("_VH",gsub("_BLOOD","",i))) {
          rname <- "VERY_HIGH_LOWER_LIMIT"
        } else if (grepl("_NO",gsub("_BLOOD","",i))) {
          rname <- "NEAR_OPTIMAL_UPPER_LIMIT"
        }
        
        sub <- ref
        if (grepl("TG_BLOOD",i)) {
          sub <- ref[ref$GENDER==gender & ref$CLINICAL_LABS=="TG_BLOOD",
                     colnames(ref) %in% c("CLINICAL_LABS","AGE_LOWER_LIMIT","AGE_UPPER_LIMIT","GENDER",
                                          "NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT","BORDERLINE_LOWER_LIMIT",
                                          "BORDERLINE_UPPER_LIMIT","HIGH_LOWER_LIMIT","HIGH_UPPER_LIMIT",
                                          "VERY_HIGH_LOWER_LIMIT","VERY_HIGH_UPPER_LIMIT",
                                          "NEAR_OPTIMAL_LOWER_LIMIT","NEAR_OPTIMAL_UPPER_LIMIT")]
        } else if (grepl("NONHDL_BLOOD",i)) {
          sub <- ref[ref$GENDER==gender & ref$CLINICAL_LABS=="NONHDL_BLOOD",
                     colnames(ref) %in% c("CLINICAL_LABS","AGE_LOWER_LIMIT","AGE_UPPER_LIMIT","GENDER",
                                          "NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT","BORDERLINE_LOWER_LIMIT",
                                          "BORDERLINE_UPPER_LIMIT","HIGH_LOWER_LIMIT","HIGH_UPPER_LIMIT",
                                          "VERY_HIGH_LOWER_LIMIT","VERY_HIGH_UPPER_LIMIT",
                                          "NEAR_OPTIMAL_LOWER_LIMIT","NEAR_OPTIMAL_UPPER_LIMIT")]
        } else if (grepl("HDL_BLOOD",i)) {
          sub <- ref[ref$GENDER==gender & ref$CLINICAL_LABS=="HDL_BLOOD",
                     colnames(ref) %in% c("CLINICAL_LABS","AGE_LOWER_LIMIT","AGE_UPPER_LIMIT","GENDER",
                                          "NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT","BORDERLINE_LOWER_LIMIT",
                                          "BORDERLINE_UPPER_LIMIT","HIGH_LOWER_LIMIT","HIGH_UPPER_LIMIT",
                                          "VERY_HIGH_LOWER_LIMIT","VERY_HIGH_UPPER_LIMIT",
                                          "NEAR_OPTIMAL_LOWER_LIMIT","NEAR_OPTIMAL_UPPER_LIMIT")]
        } else if (grepl("LDL_BLOOD",i)) {
          sub <- ref[ref$GENDER==gender & ref$CLINICAL_LABS=="LDL_BLOOD",
                     colnames(ref) %in% c("CLINICAL_LABS","AGE_LOWER_LIMIT","AGE_UPPER_LIMIT","GENDER",
                                          "NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT","BORDERLINE_LOWER_LIMIT",
                                          "BORDERLINE_UPPER_LIMIT","HIGH_LOWER_LIMIT","HIGH_UPPER_LIMIT",
                                          "VERY_HIGH_LOWER_LIMIT","VERY_HIGH_UPPER_LIMIT",
                                          "NEAR_OPTIMAL_LOWER_LIMIT","NEAR_OPTIMAL_UPPER_LIMIT")]
        } else if (grepl("TC_BLOOD",i)) {
          sub <- ref[ref$GENDER==gender & ref$CLINICAL_LABS=="TC_BLOOD",
                     colnames(ref) %in% c("CLINICAL_LABS","AGE_LOWER_LIMIT","AGE_UPPER_LIMIT","GENDER",
                                          "NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT","BORDERLINE_LOWER_LIMIT",
                                          "BORDERLINE_UPPER_LIMIT","HIGH_LOWER_LIMIT","HIGH_UPPER_LIMIT",
                                          "VERY_HIGH_LOWER_LIMIT","VERY_HIGH_UPPER_LIMIT",
                                          "NEAR_OPTIMAL_LOWER_LIMIT","NEAR_OPTIMAL_UPPER_LIMIT")]
        } else if (grepl("GLUS_BLOOD_CRC",i)) {
          sub <- ref[ref$GENDER==gender & ref$CLINICAL_LABS=="GLUS_BLOOD_CRC",
                     colnames(ref) %in% c("CLINICAL_LABS","AGE_LOWER_LIMIT","AGE_UPPER_LIMIT","GENDER",
                                          "NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT","BORDERLINE_LOWER_LIMIT",
                                          "BORDERLINE_UPPER_LIMIT","HIGH_LOWER_LIMIT","HIGH_UPPER_LIMIT",
                                          "VERY_HIGH_LOWER_LIMIT","VERY_HIGH_UPPER_LIMIT",
                                          "NEAR_OPTIMAL_LOWER_LIMIT","NEAR_OPTIMAL_UPPER_LIMIT")]
        } else if (grepl("GLUS_BLOOD",i)) {
          sub <- ref[ref$GENDER==gender & ref$CLINICAL_LABS=="GLUS_BLOOD",
                     colnames(ref) %in% c("CLINICAL_LABS","AGE_LOWER_LIMIT","AGE_UPPER_LIMIT","GENDER",
                                          "NORMAL_LOWER_LIMIT","NORMAL_UPPER_LIMIT","BORDERLINE_LOWER_LIMIT",
                                          "BORDERLINE_UPPER_LIMIT","HIGH_LOWER_LIMIT","HIGH_UPPER_LIMIT",
                                          "VERY_HIGH_LOWER_LIMIT","VERY_HIGH_UPPER_LIMIT",
                                          "NEAR_OPTIMAL_LOWER_LIMIT","NEAR_OPTIMAL_UPPER_LIMIT")]
        }
        
        for (j in 1:(dim(temp[temp$variable==i,])[1])) {
          if (!is.na(sub[sub$AGE_LOWER_LIMIT<=temp[temp$variable==i,colnames(temp)=="AGE"][j] & sub$AGE_UPPER_LIMIT>temp[temp$variable==i,colnames(temp)=="AGE"][j],colnames(sub)==rname])) {
            temp[temp$variable==i,colnames(temp)=="value"][j] <- sub[sub$AGE_LOWER_LIMIT<=temp[temp$variable==i,colnames(temp)=="AGE"][j] & sub$AGE_UPPER_LIMIT>temp[temp$variable==i,colnames(temp)=="AGE"][j],colnames(sub)==rname]
          }
        }
      }
    }
    
    temp <- spread(temp,variable,value)
    xlsx <- "CLINICAL_LABS_REFERENCE.xlsx"
    xlsx <- gsub(" ","",paste(patient,"_",xlsx))
    xlsx::write.xlsx2(temp,file=xlsx,showNA=FALSE,row.names=FALSE)
    print(paste(xlsx,"created and saved in the patient's folder"))
    
    clinical <- data.frame(MRNUMBER=character(),DATE=as.Date(as.character()),DAY_TYPE=integer(), 
                           SOURCE=integer(),FASTING=integer(),AGE=integer(),
                           TG_BLOOD=integer(),TG_FLAG=character(),
                           HDL_BLOOD=integer(),HDL_FLAG=character(),
                           LDL_BLOOD=integer(),LDL_FLAG=character(),
                           TC_BLOOD=integer(),TC_FLAG=character(),
                           NONHDL_BLOOD=integer(),NONHDL_FLAG=character(),
                           NA_BLOOD=integer(),NA_FLAG=character(),
                           K_BLOOD=integer(),K_FLAG=character(),
                           CHL_BLOOD=integer(),CHL_FLAG=character(),
                           CO2_BLOOD=integer(),CO2_FLAG=character(),
                           BUN_BLOOD=integer(),BUN_FLAG=character(),
                           CR_BLOOD=integer(),CR_FLAG=character(),
                           GLUS_BLOOD=integer(),GLUS_FLAG=character(),
                           CA_BLOOD=integer(),CA_FLAG=character(),
                           MAG_BLOOD=integer(),MAG_FLAG=character(),
                           PHOS_BLOOD=integer(),PHOS_FLAG=character(),
                           URIC_ACID_BLOOD=integer(),URIC_ACID_FLAG=character(),
                           PRO_BLOOD=integer(),PRO_FLAG=character(),
                           ALB_BLOOD=integer(),ALB_FLAG=character(),
                           TBIL_BLOOD=integer(),TBIL_FLAG=character(),
                           ALP_BLOOD=integer(),ALP_FLAG=character(),
                           AST_BLOOD=integer(),AST_FLAG=character(),
                           ALT_BLOOD=integer(),ALT_FLAG=character(),
                           RBC_BLOOD=integer(),RBC_FLAG=character(),
                           HGB_BLOOD=integer(),HGB_FLAG=character(),
                           HCT_BLOOD=integer(),HCT_FLAG=character(),
                           PLATELET_BLOOD=integer(),PLATELET_FLAG=character(),
                           MCV_BLOOD=integer(),MCV_FLAG=character(),
                           MCH_BLOOD=integer(),MCH_FLAG=character(),
                           MCHC_BLOOD=integer(),MCHC_FLAG=character(),
                           MPV_BLOOD=integer(),MPV_FLAG=character(),
                           RDW_BLOOD=integer(),RDW_FLAG=character(),
                           WBC_BLOOD=integer(),WBC_FLAG=character(),
                           AMMONIA_BLOOD=integer(),
                           BHB_BLOOD=integer(),BHB_FLAG=character(),
                           ACAC_BLOOD=integer(),
                           NEUTROPHILS_BLOOD=integer(),NEUTROPHILS_FLAG=character(),
                           LYMPHOCYTES_BLOOD=integer(),LYMPHOCYTES_FLAG=character(),
                           MONOCYTES_BLOOD=integer(),MONOCYTES_FLAG=character(),
                           EOSINOPHILS_BLOOD=integer(),EOSINOPHILS_FLAG=character(),
                           BASOPHILS_BLOOD=integer(),BASOPHILS_FLAG=character(),
                           LARGE_UNSTAINED_CELLS_BLOOD=integer(),LARGE_UNSTAINED_CELLS_FLAG=character(),
                           NEUTROPHILS_ABSOLUTE_BLOOD=integer(),NEUTROPHILS_ABSOLUTE_FLAG=character(),
                           LYMPHOCYTES_ABSOLUTE_BLOOD=integer(),LYMPHOCYTES_ABSOLUTE_FLAG=character(),
                           MONOCYTES_ABSOLUTE_BLOOD=integer(),MONOCYTES_ABSOLUTE_FLAG=character(),
                           EOSINOPHILS_ABSOLUTE_BLOOD=integer(),EOSINOPHILS_ABSOLUTE_FLAG=character(),
                           BASOPHILS_ABSOLUTE_BLOOD=integer(),BASOPHILS_ABSOLUTE_FLAG=character(),
                           GLUS_BLOOD_CRC=integer(),GLUS_FLAG_CRC=character(),
                           LACT_BLOOD_CRC_MMOL=integer(),LACT_FLAG_CRC_MMOL=integer(),
                           LAB_BLOOD_1=integer(),LAB_FLAG_1=character(),
                           LAB_BLOOD_2=integer(),LAB_FLAG_2=character(),
                           LAB_BLOOD_3=integer(),LAB_FLAG_3=character(),
                           LAB_BLOOD_4=integer(),LAB_FLAG_4=character(),
                           LAB_BLOOD_5=integer(),LAB_FLAG_5=character(),
                           LAB_BLOOD_6=integer(),LAB_FLAG_6=character(),
                           LAB_BLOOD_7=integer(),LAB_FLAG_7=character(),
                           LAB_BLOOD_8=integer(),LAB_FLAG_8=character(),
                           LAB_BLOOD_9=integer(),LAB_FLAG_9=character(),
                           LAB_BLOOD_10=integer(),LAB_FLAG_10=character(),
                           LAB_BLOOD_11=integer(),LAB_FLAG_11=character(),
                           LAB_BLOOD_12=integer(),LAB_FLAG_12=character(),
                           LAB_BLOOD_13=integer(),LAB_FLAG_13=character(),
                           LAB_BLOOD_14=integer(),LAB_FLAG_14=character(),
                           LAB_BLOOD_15=integer(),LAB_FLAG_15=character(),
                           LAB_BLOOD_16=integer(),LAB_FLAG_16=character(),
                           LAB_BLOOD_17=integer(),LAB_FLAG_17=character(),
                           LAB_BLOOD_18=integer(),LAB_FLAG_18=character(),
                           LAB_BLOOD_19=integer(),LAB_FLAG_19=character(),
                           LAB_BLOOD_20=integer(),LAB_FLAG_20=character(),
                           LAB_BLOOD_21=integer(),LAB_FLAG_21=character(),
                           LAB_BLOOD_22=integer(),LAB_FLAG_22=character(),
                           LAB_BLOOD_23=integer(),LAB_FLAG_23=character(),
                           LAB_BLOOD_24=integer(),LAB_FLAG_24=character(),
                           LAB_BLOOD_25=integer(),LAB_FLAG_25=character(),
                           LAB_BLOOD_26=integer(),LAB_FLAG_26=character(),
                           LAB_BLOOD_27=integer(),LAB_FLAG_27=character(),
                           LAB_BLOOD_28=integer(),LAB_FLAG_28=character(),
                           LAB_BLOOD_29=integer(),LAB_FLAG_29=character(),
                           LAB_BLOOD_30=integer(),LAB_FLAG_30=character(),
                           LAB_BLOOD_31=integer(),LAB_FLAG_31=character(),
                           LAB_BLOOD_32=integer(),LAB_FLAG_32=character(),
                           LAB_BLOOD_33=integer(),LAB_FLAG_33=character(),
                           LAB_BLOOD_34=integer(),LAB_FLAG_34=character(),
                           LAB_BLOOD_35=integer(),LAB_FLAG_35=character(),
                           LAB_BLOOD_36=integer(),LAB_FLAG_36=character(),
                           LAB_BLOOD_37=integer(),LAB_FLAG_37=character(),
                           LAB_BLOOD_38=integer(),LAB_FLAG_38=character(),
                           LAB_BLOOD_39=integer(),LAB_FLAG_39=character(),
                           LAB_BLOOD_40=integer(),LAB_FLAG_40=character(),
                           LAB_BLOOD_41=integer(),LAB_FLAG_41=character(),
                           LAB_BLOOD_42=integer(),LAB_FLAG_42=character(),
                           LAB_BLOOD_43=integer(),LAB_FLAG_43=character(),
                           LAB_BLOOD_44=integer(),LAB_FLAG_44=character(),
                           LAB_BLOOD_45=integer(),LAB_FLAG_45=character(),
                           LAB_BLOOD_46=integer(),LAB_FLAG_46=character(),
                           LAB_BLOOD_47=integer(),LAB_FLAG_47=character(),
                           LAB_BLOOD_48=integer(),LAB_FLAG_48=character(),
                           LAB_BLOOD_49=integer(),LAB_FLAG_49=character(),
                           LAB_BLOOD_50=integer(),LAB_FLAG_50=character())
    clinical[1:(dim(labs)[1]),] <- NA
    clinical$MRNUMBER <- labs$MRNUMBER
    clinical$DATE <- labs$DATE
    clinical$TIME <- labs$TIME
    clinical$DAY_TYPE <- labs$DAY_TYPE
    clinical$SOURCE <- labs$SOURCE
    clinical$FASTING <- labs$FASTING
    clinical$AGE <- as.integer(difftime(temp$DATE,dob,units="days"))
    
    clinical <- melt(clinical,id=c("MRNUMBER","DATE","TIME","DAY_TYPE","SOURCE","FASTING","AGE"))
    clinical <- clinical[order(clinical$DATE),]
    
    for (i in unique(clinical$variable)[!grepl("_FLAG",unique(clinical$variable))]) {
      print(i)
      if (i=="AMMONIA_BLOOD" || i=="ACAC_BLOOD") {
        clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)==i]
      }
      
      else if (i=="TG_BLOOD") {
        clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)==i]
        compare <- clinical[clinical$variable==i,colnames(clinical) %in% c("DATE","TIME","AGE","value")]
        compare[,4] <- as.numeric(compare[,4])
        test.lower <- cbind.data.frame(temp[,colnames(temp) %in% c("DATE","TIME","AGE")],rep(0,dim(compare)[1]))
        test.upper <- temp[,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
        test.lower[,4] <- as.numeric(test.lower[,4])
        test.upper[,4] <- as.numeric(test.upper[,4])
        clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE, 
                 colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] >= test.lower[,4] & 
                                                          compare[,4] <= test.upper[,4],"WNL","no")
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] &
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          test.b.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] &
                                     temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                               colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                              clinical$TIME %in% test.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          test.b.upper[,4] <- as.numeric(test.b.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.upper[,4] & 
                                                            compare[,4] <= test.b.upper[,4],"BH","no")
        }
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.b.upper.1 <- temp[which(temp$DATE %in% clinical[clinical$value=="no" & clinical$AGE<9125,c("DATE")] & 
                                       temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE<9125,c("TIME")]),
                                 colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          test.b.upper.2 <- temp[which(temp$DATE %in% clinical[clinical$value=="no" & clinical$AGE>=9125,c("DATE")] & 
                                       temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE>=9125,c("TIME")]),
                                 colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          test.high <- temp[which(temp$DATE %in% clinical[clinical$value=="no" & clinical$AGE>=9125,c("DATE")] & 
                                  temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE>=9125,c("TIME")]),
                            colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_H")))]
          compare.1 <- clinical[clinical$variable==i & clinical$DATE %in% test.b.upper.1$DATE &
                                clinical$TIME %in% test.b.upper.1$TIME,
                                colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare.2 <- clinical[clinical$variable==i & clinical$DATE %in% test.b.upper.2$DATE &
                                clinical$TIME %in% test.b.upper.2$TIME,
                                colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare.1[,4] <- as.numeric(compare.1[,4])
          compare.2[,4] <- as.numeric(compare.2[,4])
          test.b.upper.1[,4] <- as.numeric(test.b.upper.1[,4])
          test.b.upper.2[,4] <- as.numeric(test.b.upper.2[,4])
          test.high[,4] <- as.numeric(test.high[,4])
          if (dim(test.b.upper.1)[1]>0) {
            clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare.1$DATE & clinical$value=="no", 
                     colnames(clinical)=="value"] <- ifelse(!is.na(compare.1[,4]) & compare.1[,4] > test.b.upper.1[,4],"H",NA)
          }
          if (dim(test.b.upper.2)[1]>0) {
            clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare.2$DATE & clinical$value=="no", 
                     colnames(clinical)=="value"] <- ifelse(!is.na(compare.2[,4]) & compare.2[,4] > test.b.upper.2[,4] & 
                                                              compare.2[,4] <= test.high[,4],"H","no")
          }
        }
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no" & clinical$AGE>=9125,c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE>=9125,c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_VH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                              clinical$TIME %in% test.lower$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] >= test.lower[,4],"VH",NA)
        }
      }
      
      else if (i=="HDL_BLOOD") {
        clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)==i]
        compare <- clinical[clinical$variable==i & clinical$AGE<9125, 
                            colnames(clinical) %in% c("DATE","TIME","AGE","value")]
        compare[,4] <- as.numeric(compare[,4])
        test.b.lower <- temp[temp$AGE<9125,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BL")))]
        test.b.lower[,4] <- as.numeric(test.b.lower[,4])
        if (dim(test.b.lower)[1]>0) {
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$AGE<9125,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] < test.b.lower[,4],"L","no")
        }
        if (length(clinical[clinical$AGE<9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.b.lower <- temp[which(temp$DATE %in% clinical[clinical$AGE<9125 & clinical$value=="no",c("DATE")] & 
                                     temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE<9125,c("TIME")]),
                               colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BL")))]
          test.b.upper <- temp[which(temp$DATE %in% clinical[clinical$AGE<9125 & clinical$value=="no",c("DATE")] & 
                                     temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE<9125,c("TIME")]),
                               colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_LL")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.b.upper$DATE &
                              clinical$TIME %in% test.b.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.b.lower[,4] <- as.numeric(test.b.lower[,4])
          test.b.upper[,4] <- as.numeric(test.b.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] >= test.b.lower[,4] & 
                                                            compare[,4] < test.b.upper[,4],"BL","no")
        }
        if (length(clinical[clinical$AGE<9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$AGE<9125 & clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE<9125,c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_LL")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                              clinical$TIME %in% test.lower$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] >= test.lower[,4],"WNL",NA)
        }
        if (length(clinical[clinical$AGE>=9125,colnames(clinical)=="value"])>0) {
          compare <- clinical[clinical$variable==i & clinical$AGE>=9125, 
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower <- temp[temp$AGE>=9125,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_LL")))]
          test.upper <- temp[temp$AGE>=9125,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_L")))]
          test.lower[,4] <- as.numeric(test.lower[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE, 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] >= test.lower[,4] & 
                                                            compare[,4] < test.upper[,4],"WNL","no")
        }
        if (length(clinical[clinical$AGE>=9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$AGE>=9125 & clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE>=9125,c("TIME")]), 
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_L")))]
          test.lower[,4] <- as.numeric(test.lower[,4])
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                              clinical$TIME %in% test.lower$TIME, 
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$AGE>=9125, 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] >= test.lower[,4],"H","no")
        }
        if (length(clinical[clinical$AGE>=9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$AGE>=9125 & clinical$value=="no",c("DATE")] & 
                                  temp$TIME %in% clinical[clinical$value=="no" & clinical$AGE>=9125,c("TIME")]), 
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_LL")))]
          test.upper[,4] <- as.numeric(test.upper[,4])
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                              clinical$TIME %in% test.upper$TIME, 
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$AGE>=9125, 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] < test.upper[,4],"L",NA)
        }
      }
      
      else if (i=="LDL_BLOOD" || i=="NONHDL_BLOOD") {
        if (i=="NONHDL_BLOOD") {
          clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)=="TC_BLOOD"]-labs[,colnames(labs)=="HDL_BLOOD"]
        } else if (i=="LDL_BLOOD") {
          clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)==i]
        }
        compare <- clinical[clinical$variable==i & clinical$AGE<9125, 
                            colnames(clinical) %in% c("DATE","TIME","AGE","value")]
        compare[,4] <- as.numeric(compare[,4])
        test.upper <- temp[temp$AGE<9125,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
        test.upper[,4] <- as.numeric(test.upper[,4])
        if (dim(test.upper)[1]>0) {
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$AGE<9125,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] <= test.upper[,4],"WNL","no")
        }
        if (length(clinical[clinical$AGE<9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                              clinical$TIME %in% test.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4] & 
                                                            compare[,4] <= test.upper[,4],"BH","no")
        }
        if (length(clinical[clinical$AGE<9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                              clinical$TIME %in% test.lower$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4],"H",NA)
        }
        if (length(clinical[clinical$AGE>=9125,colnames(clinical)=="value"])>0) {
          compare <- clinical[clinical$variable==i & clinical$AGE>=9125, 
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.upper <- temp[temp$AGE>=9125,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$AGE>=9125,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] <= test.upper[,4],"WNL","no")
        }
        if (length(clinical[clinical$AGE>=9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                    temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_NO")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                              clinical$TIME %in% test.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4] & 
                                                            compare[,4] <= test.upper[,4],"NO","no")
        }
        if (length(clinical[clinical$AGE>=9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                              clinical$TIME %in% test.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4] & 
                                                            compare[,4] <= test.upper[,4],"BH","no")
        }
        if (length(clinical[clinical$AGE>=9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_H")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                              clinical$TIME %in% test.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4] & 
                                                            compare[,4] <= test.upper[,4],"H","no")
        }
        if (length(clinical[clinical$AGE>=9125 & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_H")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                              clinical$TIME %in% test.lower$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4],"VH",NA)
        }
      }
      
      else if (i=="TC_BLOOD") {
        clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)==i]
        compare <- clinical[clinical$variable==i,colnames(clinical) %in% c("DATE","TIME","AGE","value")]
        compare[,4] <- as.numeric(compare[,4])
        test.upper <- temp[,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
        test.upper[,4] <- as.numeric(test.upper[,4])
        if (dim(test.upper)[1]>0) {
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] <= test.upper[,4],"WNL","no")
        }
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                              clinical$TIME %in% test.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4] & 
                                                            compare[,4] <= test.upper[,4],"BH","no")
        }
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                   temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                              clinical$TIME %in% test.lower$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4],"H",NA)
        }
      }
      
      ##
      else if (i=="GLUS_BLOOD" || i=="GLUS_BLOOD_CRC") {
        clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)==i]
        compare <- clinical[clinical$variable==i & clinical$AGE<210,
                            colnames(clinical) %in% c("DATE","TIME","AGE","value")]
        compare[,4] <- as.numeric(compare[,4])
        test.lower <- temp[temp$AGE<210,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_LL")))]
        test.upper <- temp[temp$AGE<210,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
        test.lower[,4] <- as.numeric(test.lower[,4])
        test.upper[,4] <- as.numeric(test.upper[,4])
        if (dim(test.upper)[1]>0) {
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$AGE<210,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] >= test.lower[,4] &
                                                            compare[,4] <= test.upper[,4],"WNL","no")
        }
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                     temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                                clinical$TIME %in% test.lower$TIME,
                              colnames(clinical)%in%c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$AGE<210 & clinical$value=="no",
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4],"H","no")
        }
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                     temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_LL")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                                clinical$TIME %in% test.upper$TIME,
                              colnames(clinical)%in%c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$AGE<210 & clinical$value=="no",
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] < test.upper[,4],"L",NA)
        }
        if (length(clinical[clinical$AGE>=210,colnames(clinical)=="value"])>0) {
          compare <- clinical[clinical$variable==i & clinical$AGE>=210,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower <- temp[temp$AGE>=210,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_LL")))]
          test.upper <- temp[temp$AGE>=210,colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          test.lower[,4] <- as.numeric(test.lower[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] >= test.lower[,4] &
                                                            compare[,4] <= test.upper[,4],"WNL","no")
        }
        print(i)
        if (length(clinical[clinical$AGE>=210,colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                     temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_UL")))]
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                     temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                                clinical$TIME %in% test.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4] &
                                                            compare[,4] <= test.upper[,4],"BH","no")
        }
        print(i)
        if (length(clinical[clinical$AGE>=210,colnames(clinical)=="value"])>0) {
          test.lower <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                     temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_BH")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                                clinical$TIME %in% test.lower$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.lower[,4] <- as.numeric(test.lower[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] > test.lower[,4],"H","no")
        }
        print(i)
        if (length(clinical[clinical$AGE>=210,colnames(clinical)=="value"])>0) {
          test.upper <- temp[which(temp$DATE %in% clinical[clinical$value=="no",c("DATE")] & 
                                     temp$TIME %in% clinical[clinical$value=="no",c("TIME")]),
                             colnames(temp) %in% c("DATE","TIME","AGE",gsub(" ","",paste(i,"_LL")))]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.upper$DATE &
                                clinical$TIME %in% test.upper$TIME,
                              colnames(clinical) %in% c("DATE","TIME","AGE","value")]
          compare[,4] <- as.numeric(compare[,4])
          test.upper[,4] <- as.numeric(test.upper[,4])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$DATE %in% compare$DATE,
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,4]) & compare[,4] < test.upper[,4],"L",NA)
        }
      }
      
      else if (grepl("LAB_BLOOD",i) & i!="LAB_BLOOD_1") {
        clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)==i]
      }
      
      else {
        if (i=="BHB_BLOOD") {
          clinical[clinical$variable==i,colnames(clinical)=="value"] <- ((labs[,colnames(labs)==gsub(" ","",paste(i,"_MMOL"))]*104.1*100)/1000)
        } else {
          clinical[clinical$variable==i,colnames(clinical)=="value"] <- labs[,colnames(labs)==i]
        }
        compare <- clinical[clinical$variable==i,colnames(clinical) %in% c("DATE","TIME","value")]
        compare[,3] <- as.numeric(compare[,3])
        test.lower <- temp[,colnames(temp) %in% c("DATE","TIME",gsub(" ","",paste(i,"_LL")))]
        test.upper <- temp[,colnames(temp) %in% c("DATE","TIME",gsub(" ","",paste(i,"_UL")))]
        clinical[clinical$variable==gsub("_BLOOD","_FLAG",i), 
                 colnames(clinical)=="value"] <- ifelse(!is.na(compare[,3]) & compare[,3] >= test.lower[,3] & 
                                                          compare[,3] <= test.upper[,3],"WNL","no")
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- test.lower[test.lower$DATE %in% clinical[clinical$variable==gsub(" ","",paste(gsub("_BLOOD","_FLAG",i))) 
                                                                 & clinical$value=="no",colnames(clinical)=="DATE"] &
                                   test.lower$TIME %in% clinical[clinical$variable==gsub(" ","",paste(gsub("_BLOOD","_FLAG",i))) 
                                                                   & clinical$value=="no",colnames(clinical)=="TIME"],]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE & 
                              clinical$TIME %in% test.lower$TIME,colnames(clinical)%in%c("DATE","TIME","value")]
          compare[,3] <- as.numeric(compare[,3])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,3]) & compare[,3] < test.lower[,3],"L","no")
        }
        if (length(clinical[!is.na(clinical$value) & clinical$value=="no",colnames(clinical)=="value"])>0) {
          test.lower <- test.lower[test.lower$DATE %in% clinical[clinical$variable==gsub(" ","",paste(gsub("_BLOOD","_FLAG",i))) 
                                                                 & clinical$value=="no",colnames(clinical)=="DATE"] & 
                                   test.lower$TIME %in% clinical[clinical$variable==gsub(" ","",paste(gsub("_BLOOD","_FLAG",i))) 
                                                                   & clinical$value=="no",colnames(clinical)=="TIME"],]
          compare <- clinical[clinical$variable==i & clinical$DATE %in% test.lower$DATE &
                              clinical$TIME %in% test.lower$TIME,colnames(clinical)%in%c("DATE","TIME","value")]
          compare[,3] <- as.numeric(compare[,3])
          clinical[clinical$variable==gsub("_BLOOD","_FLAG",i) & clinical$value=="no", 
                   colnames(clinical)=="value"] <- ifelse(!is.na(compare[,3]),"H",NA)
        }
      }
    }
    
    clinical <- spread(clinical,variable,value)
    for (i in colnames(clinical)[grepl("_BLOOD",colnames(clinical))]) {
      clinical[,colnames(clinical)==i] <- as.numeric(clinical[,colnames(clinical)==i])
    }
    clinical <- clinical[,!(colnames(clinical)%in%c("AGE","TIME"))]
    xlsx <- "CLINICAL_LABS_CLINICAL.xlsx"
    xlsx <- gsub(" ","",paste(patient,"_",xlsx))
    xlsx::write.xlsx2(clinical,file=xlsx,showNA=FALSE,row.names=FALSE)
    print(paste(xlsx,"created and saved in the patient's folder"))
    
    return(1)
    colnames(clinical)[colnames(clinical)=="GLUS_BLOOD_CRC"] <- "GLUS_BLOOD_CRC_MMOL"
    colnames(clinical)[colnames(clinical)=="GLUS_FLAG_CRC"] <- "GLUS_FLAG_CRC_MMOL"
    
    # Delete any previously existing connections creating using the RMySQL package
    # (If too many are running at once, the script will not be able to establish a new connection)
    all_cons <- dbListConnections(MySQL())
    for (con in all_cons) {
      dbDisconnect(con)
    }
    
    # Input MySQL user name, password, database name, and host
    # Then establish a connection to the database
    print("When prompted, please input the MySQL username, password, database name, and host that you wish to use")
    print("To leave any of these fields blank, press the enter key without typing anything else")
    u <- readline(prompt="User: ")
    p <- readline(prompt="Password: ")
    d <- readline(prompt="Database Name: ")
    h <- readline(prompt="Host: ")
    connect <- dbConnect(MySQL(),user=u,password=p,dbname=d,host=h)
    
    dbSendQuery(connect,paste("USE",d))
    
    clinical$BHB_BLOOD <- labs$BHB_BLOOD_MMOL
    clinical$GLUS_BLOOD_CRC_MMOL <- (clinical$GLUS_BLOOD_CRC_MMOL/180.1559)*10
    clinical <- cbind.data.frame(clinical,labs$COMMENTS)
    colnames(clinical)[dim(clinical)[2]] <- "COMMENTS"
    
    mrnumber <- unique(clinical$MRNUMBER)
    table <- "clinical_labs_id_research"
    
    exists <- dbGetQuery(connect,paste("SHOW TABLES FROM",d,"LIKE",gsub(" ","",paste("'",table,"'")),";"))
    if (length(exists[,1])==1) {
      exists.this <- dbGetQuery(connect,paste("SELECT * FROM",table,"WHERE MRNUMBER=",mrnumber,";"))
      if (dim(exists.this)[1]>0) {
        print(paste("Data for patient with mrnumber",mrnumber,"already exists in table",
                    gsub(" ","",paste(table,".")),"Would you like to update it?"))
        r <- " "
        while (tolower(r)!="yes" & tolower(r)!="no") {
          r <- readline(prompt="Type 'yes' or 'no': ")
        }
        if (tolower(r)=="yes") {
          dbSendQuery(connect,paste("DELETE FROM",table,"WHERE MRNUMBER=",mrnumber,";"))
          dbWriteTable(connect,name=table,value=clinical,append=TRUE)
        }
      } else {
        dbWriteTable(connect,name=table,value=clinical,append=TRUE)
      }
      print(paste("Table",table,"has been updated with data for this patient"))
    } else if (length(exists[,1])==0) {
      dbWriteTable(connect,name=table,value=clinical,append=TRUE)
      print(paste("Table",table,"has been created and can be found in the database"))
    }
    
    print("Would you like to run this script on another patient?")
    print("Type 'yes' to do so, or type 'no' to quit")
    temp <- ""
    while (tolower(temp)!="yes" & tolower(temp)!="no") {
      temp <- readline(prompt="Enter here: ")
    }
    run <- temp
  }
}