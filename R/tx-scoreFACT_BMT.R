#' @title Score the FACT-BMT 
#' 
#' @description
#' Generates all of the scores of the Functional Assessment of Cancer Therapy - 
#' Bone Marrow Transplant (FACT-BMT, v4) from item responses.
#' 
#' @details
#' Given a data frame that includes all of the FACT-BMT (Version 4) items as 
#' variables, appropriately named, this function generates all of the FACT-BMT 
#' scale scores.  It is crucial that the item variables in the supplied data 
#' frame are named according to FACT conventions.  For example, the first 
#' physical well-being item should be named GP1, the second GP2, and so on.  
#' Please refer to the materials provided by \url{http://www.facit.org} for the
#' particular questionnaire you are using.  In particular, refer to the left
#' margin of the official questionnaire (i.e., from facit.org) for the
#' appropriate item variable names.
#' 
#' @section Note:
#' Keep in mind that this function (and R in general) is case-sensitive.
#'
#' All variables should be in numeric or integer format.
#'
#' This scoring function expects missing item responses to be coded as NA,
#' 8, or 9, and valid item responses to be coded as 0, 1, 2, 3, or 4.  Any
#' other value for any of the items will result in an error message and no
#' scores.
#'
#' Some item variables are reverse coded for the purpose of generating the
#' scale scores.  The official (e.g., from \url{http://www.facit.org}) SAS
#' and SPSS scoring algorithms for this questionnaire automatically replace
#' the original items with their reverse-coded versions.  This can be
#' confusing if you accidentally run the algorithm more than once on your
#' data.  As its default, \code{scoreFACT_BMT} DOES NOT replace any of your
#' original item variables with the reverse coded versions.  However, for
#' consistentcy with the behavior of the other versions on
#' \url{http://www.facit.org}, the \code{updateItems} argument is
#' provided.  If set to \code{TRUE}, any item that is supposed to be
#' reverse coded will be replaced with its reversed version in the data
#' frame returned by \code{scoreFACT_BMT}.
#' 
#' 
#' @param df A data frame with the FACT-BMT items, appropriately-named.
#' @param updateItems Logical, if \code{TRUE} any original item that is
#' reverse coded for scoring will be replaced by its reverse coded version
#' in the returned data frame, and any values of 8 or 9 will be replaced
#' with NA.  The default, \code{FALSE}, returns the original items
#' unmodified.  
#' @param keepNvalid Logical, if \code{TRUE} the function
#' returns an additional variable for each of the returned scale scores
#' containing the number of valid, non-missing responses from each
#' respondent to the items on the given scale.  If \code{FALSE} (the
#' default), these variables are omitted from the returned data frame.
#' 
#' 
#' @return The original data frame is returned (optionally with modified
#' items if \code{updateItems = TRUE}) with new variables corresponding to
#' the scored scales. If \code{keepNvalid = TRUE}, for each scored scale an
#' additional variable is returned that contains the number of valid
#' responses each respondent made to the items making up the given scale.
#' These optional variables have names of the format \code{SCALENAME_N}.
#' The following scale scores are returned:
#' 
#' \describe{
#'   \item{PWB}{Physical Well-Being subscale}
#'   \item{SWB}{Social/Family Well-Being subscale}
#'   \item{EWB}{Emotional Well-Being subscale}
#'   \item{FWB}{Physical Well-Being subscale}
#'   \item{FACTG}{FACT-G Total Score (i.e., PWB+SWB+EWB+FWB)}
#'   \item{BMTS}{Bone Marrow Transplant subscale}
#'   \item{FACT_BMT_TOTAL}{FACT-BMT Total Score (i.e., PWB+SWB+EWB+FWB+BMTS)}
#'   \item{FACT_BMT_TOI}{FACT-BMT Trial Outcome Index (e.g., PWB+FWB+BMTS)}
#' }
#' 
#' @references FACT-BMT Scoring Guidelines, available at \url{http://www.facit.org}
#' 
#' @export
#' 
#' @examples
#' ## Setting up item names for fake data
#' G_names <- c(paste0('GP', 1:7), 
#'              paste0('GS', 1:7), 
#'              paste0('GE', 1:6), 
#'              paste0('GF', 1:7))
#' AC_names <- c('BMT1', 'BMT2', 'BMT3', 'BMT4', 'C6', 'C7', 'BMT5', 'BMT6', 'BL4', 'BMT8')
#' itemNames <- c(G_names, AC_names)
#' ## Generating random item responses for 8 fake respondents
#' set.seed(6375309)
#' exampleDat <- t(replicate(8, sample(0:4, size = length(itemNames), replace = TRUE)))
#' ## Making half of respondents missing about 10% of items, 
#' ## half missing about 50%.
#' miss10 <- t(replicate(4, sample(c(0, 9), prob = c(0.9, 0.1), 
#'     size = length(itemNames), replace = TRUE)))
#' miss50 <- t(replicate(4, sample(c(0, 9), prob = c(0.5, 0.5), 
#'     size = length(itemNames), replace = TRUE)))
#' missMtx <- rbind(miss10, miss50)
#' ## Using 9 as the code for missing responses
#' exampleDat[missMtx == 9] <- 9
#' exampleDat <- as.data.frame(cbind(ID = paste0('ID', 1:8), 
#'     as.data.frame(exampleDat)))
#' names(exampleDat) <- c('ID', itemNames)
#' 
#' ## Returns data frame with scale scores and with original items untouched
#' scoredDat <- scoreFACT_BMT(exampleDat)
#' names(scoredDat)
#' scoredDat
#' ## Returns data frame with scale scores, with the appropriate items
#' ## reverse scored, and with item values of 8 and 9 replaced with NA.
#' ## Also illustrates the effect of setting keepNvalid = TRUE.
#' scoredDat <- scoreFACT_BMT(exampleDat, updateItems = TRUE, keepNvalid = TRUE)
#' names(scoredDat)
#' ## Descriptives of scored scales
#' summary(scoredDat[, c('PWB', 'SWB', 'EWB', 'FWB', 'FACTG', 
#'                       'BMTS', 'FACT_BMT_TOTAL', 'FACT_BMT_TOI')])
scoreFACT_BMT <- function(df, updateItems = FALSE, keepNvalid = FALSE) {
    dfG <- scoreFACTG(df, updateItems = updateItems, keepNvalid = TRUE)
    dfGup <- dfG
    names(dfGup) <- toupper(names(dfGup))
    G_names <- c(paste0("GP", 1:7), paste0("GS", 1:7), paste0("GE", 1:6), 
        paste0("GF", 1:7))
    AC_names <- toupper(c("BMT1", "BMT2", "BMT3", "BMT4", "C6", "C7", "BMT5", 
        "BMT6", "BL4", "BMT8"))
    revNames <- toupper(c("BMT1", "BMT2", "BMT3", "BMT4", "BMT6"))
    AC_items <- dfGup[, AC_names]
    if (any(!(as.matrix(AC_items) %in% c(0:4, 8, 9, NA)))) {
        stop("At least 1 response is out of range (i.e., not 0-4, 8, 9, or NA)")
        break
    }
    makeMiss <- function(x) {
        x[x %in% c(8, 9)] <- NA
        return(x)
    }
    AC_items <- as.data.frame(lapply(AC_items, makeMiss))
    revHelper <- function(x) {
        return(4 - x)
    }
    AC_items[, revNames] <- lapply(AC_items[, revNames], revHelper)
    valid_N <- as.data.frame(lapply(AC_items, function(x) as.numeric(!is.na(x))))
    AC_N <- rowSums(valid_N[, AC_names])
    TOTAL_N <- dfG$PWB_N + dfG$SWB_N + dfG$EWB_N + dfG$FWB_N + AC_N
    AC <- round(rowMeans(AC_items[, AC_names], na.rm = TRUE) * length(AC_names), 
        3)
    AC[AC_N/length(AC_names) <= 0.5] <- NA
    TOTAL <- dfG$PWB + dfG$SWB + dfG$EWB + dfG$FWB + AC
    TOTAL[TOTAL_N/length(c(G_names, AC_names)) <= 0.8] <- NA
    TOI <- dfG$PWB + dfG$FWB + AC
    FACT_BMT_TOTAL_N <- TOTAL_N
    BMTS_N <- AC_N
    BMTS <- AC
    FACT_BMT_TOTAL <- TOTAL
    FACT_BMT_TOI <- TOI
    if (updateItems) {
        dfItemPos <- unlist(sapply(AC_names, function(x) grep(x, names(dfG), 
            ignore.case = TRUE, value = FALSE)))
        names(dfG)[dfItemPos] <- toupper(names(dfG)[dfItemPos])
        dfG[, AC_names] <- AC_items
    }
    if (keepNvalid) {
        dfOut <- as.data.frame(cbind(dfG, BMTS_N, FACT_BMT_TOTAL_N, BMTS, 
            FACT_BMT_TOTAL, FACT_BMT_TOI))
    } else {
        dfG[, "PWB_N"] <- NULL
        dfG[, "SWB_N"] <- NULL
        dfG[, "EWB_N"] <- NULL
        dfG[, "FWB_N"] <- NULL
        dfG[, "FACTG_N"] <- NULL
        dfOut <- as.data.frame(cbind(dfG, BMTS, FACT_BMT_TOTAL, FACT_BMT_TOI))
    }
    return(dfOut)
} 
