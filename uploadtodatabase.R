uploadtodatabase <- function() {
  
  if (!require("rJava")) {
    install.packages("rJava")
  }
  library(rJava)
  if (!require("XLConnect")) {
    install.packages("XLConnect")
  }
  library(XLConnect)
  if (!require("RMySQL")) {
    install.packages("RMySQL")
  }
  library(RMySQL)
  if (!require("dplyr")) {
    install.packages("dplyr")
  }
  library(dplyr)
  
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
  
  upload <- "yes"
  while(upload=="yes") {
    
    print("Input the directory in which the table you would like to add to the database can be found")
    print("Example: C:/Folder_Name/")
    directory <- readline(prompt="Enter here: ")
    setwd(directory)
    
    print("Input the name of the file you would like to use (leave off the .xlsx extension)")
    print("Example: FILA_TABLE")
    data <- readline(prompt="Enter here: ")
    
    check <- ""
    if (grepl("CLINIC_VISIT_SOURCE",data)) {
      check <- "CLINIC_VISIT_SOURCE"
    } else if (grepl("MEAL_CHALLENGE",data)) {
      check <- "MEAL_CHALLENGE"
    } else if (grepl("ALERTNESS",data)) {
      check <- "ALERTNESS"
    } else if (grepl("DEMOGRAPHICS_SOURCE",data)) {
      check <- "DEMOGRAPHICS_SOURCE"
    }
    individual <- FALSE
    if (grepl("ALERTNESS",data) || 
        grepl("BMR",data) || 
        grepl("CLINIC_GI_ISSUES",data) || 
        grepl("RX",data) || 
        grepl("MEAL_CHALLENGE",data) || 
        grepl("URINE_KT",data) || 
        grepl("VITALS",data) || 
        grepl("VNS",data)) {
      individual <- TRUE
    }
    
    data <- gsub(" ","",paste(data,".xlsx"))
    data <- data.frame(readWorksheetFromFile(data,sheet=1))
    data <- data[,!(tolower(colnames(data))%in%c("entered","audited","comments"))]
    data <- data[!is.na(data[,1]),]
    mrnumber <- unique(data$MRNUMBER)
    
    if (check=="CLINIC_VISIT_SOURCE") {
      data$DATE <- as.Date(data$DATE)
      demo <- data.frame(readWorksheetFromFile("DEMOGRAPHICS_SOURCE.xlsx",sheet=1))
      demo$PKT_INITIATED_DATE <- as.Date(demo$PKT_INITIATED_DATE)
      DOPKT <- data.frame(DOPKT=as.Date(as.character()))
      DOPKT <- rep(NA,dim(data)[1])
      DOPKT <- as.Date(DOPKT,format="%m/%d/%Y")
      data <- cbind.data.frame(data,DOPKT)
      for (i in unique(data$MRNUMBER)) {
        data[data$MRNUMBER==i,c("DOPKT")] <- demo$PKT_INITIATED_DATE[which(demo$MRNUMBER==i)]
      }
      data$DOPKT <- data$DATE-data$DOPKT
    } else if (check=="MEAL_CHALLENGE") {
      colnames(data)[colnames(data)=="GLUS_BLOOD_CRC"] <- "GLUS_BLOOD_CRC_MMOL"
      data$GLUS_BLOOD_CRC_MMOL <- (data$GLUS_BLOOD_CRC_MMOL/180.1559)*10
    } else if (check=="ALERTNESS") {
      data$ALERTNESS <- iconv(data$ALERTNESS,to="UTF-8")
      data$ACTIVITY <- iconv(data$ACTIVITY,to="UTF-8")
      data$DEVELOPMENT <- iconv(data$DEVELOPMENT,to="UTF-8")
    } else if (check=="DEMOGRAPHICS_SOURCE") {
      for (i in colnames(data)) {
        data[,colnames(data)==i] <- iconv(data[,colnames(data)==i],to="UTF-8")
      }
    }
    
    data <- tbl_df(data)
    
    print("Insert the name of the table in the database that you would like to upload this table into")
    table <- readline(prompt="Enter here: ")
    
    exists <- dbGetQuery(connect,paste("SHOW TABLES FROM",d,"LIKE",gsub(" ","",paste("'",table,"'")),";"))
    if (length(exists[,1])==1) {
      if (individual) {
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
            dbWriteTable(connect,name=table,value=data,append=TRUE)
          }
        } else {
          dbWriteTable(connect,name=table,value=data,append=TRUE)
        }
        print(paste("Table",table,"has been updated with data for this patient"))
      } else {
        print(paste("Table",table,"already exists. Would you like to update it?"))
        r <- " "
        while (tolower(r)!="yes" & tolower(r)!="no") {
          r <- readline(prompt="Type 'yes' or 'no': ")
        }
        if (tolower(r)=="yes") {
          dbWriteTable(connect,name=table,value=data,overwrite=TRUE)
        }
        print(ifelse(tolower(r)=="yes",paste("Table",table,"has been updated with new data"),
               paste("Table",table,"not changed")))
      }
    } else if (length(exists[,1])==0) {
      dbWriteTable(connect,name=table,value=data,append=TRUE)
      print(paste("Table",table,"has been created and can be found in the database"))
    }
    
    print("Would you like to upload another table to the database?")
    print("Type 'yes' to do so, or type 'no' to quit")
    temp <- ""
    while (tolower(temp)!="yes" & tolower(temp)!="no") {
      temp <- readline(prompt="Enter here: ")
    }
    upload <- temp
  }
}
