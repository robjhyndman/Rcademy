#' Parsing Emails
#'
#' @description This function parses your emails stored as PDF files in a folder.
#' It returns a data frame with from, to, date, subject and content fields.
#' Note: some emails if "saved as PDFs" may not be parsed correctly.
#'
#' @param folder The path to the folder where all emails are stored.
#'
#' @return A tibble.
#' @export
#'
#' @importFrom pdftools pdf_text
#' @importFrom stringr str_split
#' @importFrom dplyr filter_all any_vars
#'
#' @examples
#' \dontrun{
#' emails <- parse_pdf_emails("Some/Folder/Path/Here")
#' }
#'
parse_pdf_emails <- function(folder) {
  # Get all the files on the folder
  fileList <- list.files(path = folder, pattern = "*.pdf", full.names = TRUE)

  df <- matrix(ncol = 5)
  df <- as.data.frame(df)
  colnames(df) <- c("From", "To", "Date", "Subject", "Content")


  # For each file
  for(pdf in fileList) {
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
    for(j in seq_along(split)) {
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

  return(df)
}
