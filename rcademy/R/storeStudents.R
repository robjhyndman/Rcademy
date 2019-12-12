storeStudents <- function(firstName, familyName, degreeType, 
                          degreeName, institution, startDate, 
                          endDate, completed = FALSE, thesisTitle, 
                          mainSupervisor, adjuctSupervisors, 
                          csvFilePath, csvFileName) {
  
  # Full file
  file <- paste0(csvFilePath, "/", csvFileName)
  
  # If the path doesn't exist, stop
  if(!dir.exists(csvFilePath)) {
    stop("CSV Path does not exists")
  }
  else {
    # If the file doesn't exists create it
    if( !file.exists(paste0(csvFilePath, "/", csvFileName)) ) {
      df <- matrix(ncol = 10)
      df <- as.data.frame(df)
      colnames(df) <- c("Name", "Lastname", "Type", "Degree",
                        "Institution", "Start", "End", "Thesis",
                        "Supervisor", "CoAdvisors")
      write.csv(df, file, row.names = FALSE)
    }
  }
  
  # Now, read the CSV file
  csv <- read_csv(file = file, col_names = TRUE)
  
  # Check if we have a student with this names
  filtered <- subset(csv, firstName == Name && familyName == Lastname)
  # If the student isn't there, add it
  if( nrow(filtered) == 0 ) {
    # Create the student
    done <- if(completed) "" else "Expected "
    done <- paste0(done, endDate)
    student <- c(firstName, familyName, degreeType, degreeName, institution,
                 startDate, done, thesisTitle,
                 mainSupervisor, adjuctSupervisors)
    
    # Add it to the csv
    csv[nrow(csv) + 1, ] <- student
  }
  # Otherwise 
  else {
    # Get the row name
    rowNum <- which(csv$Name == firstName & csv$Lastname == familyName)
    print(rowNum)
    
    # Now, edit what it is not empty
    if(!missing(degreeType)) {
      csv[rowNum,]$Type <- degreeType
    }
    
    if(!missing(degreeName)) {
      csv[rowNum,]$Degree <- degreeName
    } 
      
    if(!missing(institution)) {
      csv[rowNum,]$Institution <- institution
    }
    
    if(!missing(endDate)) {
      done1 <- if(!completed) "Expected " else ""
      print(paste0("Done? ", done1))
      
      csv[rowNum,]$End <- paste0(done1, endDate)
    }
    
    if(!missing(startDate)) {
      csv[rowNum,]$Start <- startDate
    }
    
    if(!missing(thesisTitle)) {
      csv[rowNum,]$hesisthesisTitle
    }
    
    if(!missing(mainSupervisor)) {
      csv[rowNum,]$Supervisor <- mainSupervisor
    }
    
    if(!missing(adjuctSupervisors)) {
      csv[rowNum,]$CoAdvisors <- adjuctSupervisors
    }
  }
  
  
  
  # Remove the empty rows
  csv <- csv %>% filter_all(any_vars(complete.cases(.))) 
  # Write the file
  write.csv(csv, file, row.names = FALSE)
  
  return(csv)
}