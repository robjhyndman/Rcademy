#' Students parser function
#'
#' @description This function will allow you to add your students (HDRs, Honours), as well as their basic information. The result will be stored in a CSV file. If it doesn't exist, this creates the file. When you create a new student you need all arguments, but you can edit it with only first name, family name, and the ones you need to change.
#'
#' @param firstName The first name of the student.
#' @param familyName The student's surname or family name.
#' @param degreeType The type of degree: PhD, Master, Honours, and so on.
#' @param degreeName The name of the degree.
#' @param institution The institution where the student is working.
#' @param startDate The start date of the degree.
#' @param endDate End date. If it is not completed, a "Expected" will be added before it.
#' @param completed False if the student hasn't completed the degree.
#' @param thesisTitle The name of the thesis.
#' @param mainSupervisor The main supervisor. If there are several, they should be split by comma.
#' @param adjuctSupervisors Other supervisors, split by comma.
#' @param csvFilePath The path to where the file is stored.
#' @param csvFileName The name of the file, with csv extension.
#'
#' @return The in-memory object of the CSV file, with all the students and the updates/adds performed.
#' @export
#'
#' @importFrom readr read_csv
#' @importFrom dplyr filter_all any_vars
#' @importFrom stats complete.cases
#' @importFrom utils write.csv
#'
#' @examples
#' # To add a new student
#' storeStudents("Jane", "Shepard", "Honours", "Computer Science", "Normandy SR1", "March/2020", "November/2020", FALSE, "Fight the Reapers", "Dr Somebody", "Dr Another Person", "Path/To/Folder", "fileName.csv")
#'
#' # Otherwise, update them
#' storeStudents("Jane", "Shepard", completed = TRUE, csvFilePath = "Path/To/Folder", csvFileName = "fileName.csv")
#'
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
