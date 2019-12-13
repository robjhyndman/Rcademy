

#' Parsing PDF Emails
#'
#' @description This function parses your emails stored as PDFs files in a folder
#' and produces an RDS file in the same directory. It contains a dataframe with
#' from, to, daet, subject and content fields.
#' Note: some emails if "saved as PDFs" may not be parsed correctly.
#'
#' @param folder The path to the folder where all emails are.
#'
#' @return The parsed dataframe in-memory
#' @export
#'
#' @importFrom pdftools pdf_text
#' @importFrom stringr str_split
#' @importFrom dplyr filter_all any_vars
#'
#' @examples
#' \dontrun{
#' emails <- parsePDFEmails("Some/Folder/Path/Here")
#' }
#'
parsePDFEmails <- function(folder) {
  # Get all the files on the folder
  fileList <- list.files(path = folder, recursive = FALSE)

  df <- matrix(ncol = 5)
  df <- as.data.frame(df)
  colnames(df) <- c("From", "To", "Date", "Subject", "Content")


  # For each file
  for(pdf in fileList) {
    # Get the whole name
    file <- paste0(folder, "/", pdf)

    # Now read it
    text <- pdftools::pdf_text(file)
    split <- stringr::str_split(text, "\r\n")
    split <- split[[1]]


    from <- ""
    to <- ""
    date <- ""
    subject <- ""
    content <- ""

    exceptIndex <- c()

    # Merge
    for(j in 1:length(split)) {
      if(grepl("From:", split[j], fixed = TRUE)) {
        from <- split[j]
        exceptIndex <- c(exceptIndex, j)
      }
      else if(grepl("To:", split[j], fixed = TRUE)) {
        to <- split[j]
        exceptIndex <- c(exceptIndex, j)
      }
      else if(grepl("Date:", split[j], fixed = TRUE)) {
        date <- split[j]
        exceptIndex <- c(exceptIndex, j)
      }
      else if(grepl("Subject:", split[j], fixed = TRUE)) {
        subject <- split[j]
        exceptIndex <- c(exceptIndex, j)
      }
    }

    # Get all rows not in the exception
    textRows <- split[-exceptIndex]
    content <- paste(textRows, sep = "\r\n", collapse = " ")
    df[nrow(df) + 1, ] <- c(from, to, date, subject, content)

  }


  # Remove the empty rows
  df <- df %>% dplyr::filter_all(dplyr::any_vars(complete.cases(.)))

  # Write the file
  saveRDS(df, paste0(folder, "/emailsDump.rds"))
  return(df)
}
