# I cannot take credit for this function; it belongs to Mason Fidino (@mfidino)
#
# a function to split the output of an mcmc model into its constituent parts.
# For example, if you run a model with an intercept and two coefficients, and 
# have 3 mcmc chains going, the results will be stored per chain. this code
# combines the chains and creates one array per model component. This makes the
# model output much easier to work with to predict across covariates ranges.
split_mcmc <- function(x){
  # get parameter names
  pars <- colnames(x)
  # unique parameters
  unq_pars <- unique(
    gsub(
      "\\[.*\\]",
      "",
      pars
    )
  )
  # make list object to store arrays in
  result_list <- vector(
    "list",
    length = length(unq_pars)
  )
  # name the list
  names(result_list) <- unq_pars
  # fill in the arrays
  for(i in 1:length(result_list)){
    # get just the parameters
    tmp <- pars[grep(
      paste0(
        "^",unq_pars[i], "\\["
      ),
      pars
    )]
    if(length(tmp) == 0){
      tmp <- pars[grep(
        paste0("^",unq_pars[i],"$"),
        pars
      )]
    }
    # and then the array dimensions
    arr_dim <- gsub(
      paste0(
        unq_pars[i],"\\[|\\]"
      ),
      "",
      tmp
    )
    arr_dim <- strsplit(
      arr_dim,
      ","
    )
    ndim <- length(arr_dim[[1]])
    npar <- length(arr_dim)
    # make a matrix
    arr_ind <- suppressWarnings(
      matrix(
        as.numeric(
          unlist(arr_dim)
        ),
        ncol = ndim,
        nrow = npar,
        byrow = TRUE
      )
    )
    if(nrow(arr_ind) == 1 & ncol(arr_ind) == 1){
      arr_ind[1,1] <- 1
    }
    # get max index for each
    max_ind <- apply(arr_ind, 2, max)
    # and then fill in the array
    result_list[[i]] <- array(
      x[,tmp],
      dim = c(nrow(x), max_ind)
    )
    
  }
  return(result_list)
}