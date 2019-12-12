

parseEmails <- function(folder) {
  # Get all the files on the folder
  fileList <- list.files(path = folder, recursive = FALSE)

  # For each file
  for(pdf in fileList) {
    # Get the whole name
    file <- paste0(folder, "/", pdf)
    
    # Now read it
    REmail
    
    
  }
  
  
  
}