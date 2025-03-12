# this code can take data that are wide on columns and convert it to data that
# are long on rows (e.g., stacking repeat seasons of data collection on top of
# on another).
wide_to_stacked <- function(input_df, surveys_per_bout){
  obs <- input_df[,-1]
  nbouts <- ncol(obs) / surveys_per_bout
  inds <- split(1:(nbouts*surveys_per_bout), rep(1:nbouts, 
                                                 each=surveys_per_bout))
  split_df <- lapply(1:nbouts, function(i){
    out <- obs[,inds[[i]]]
    out$Site <- input_df$Site
    out$Season <- i
    names(out)[1:28] <- paste0("obs",1:28)
    out
  })
  stack_df <- do.call("rbind", split_df)
  stack_df
}

# I take only partial credit for this code; it is heavily referenced from the
# 'umbs' package by Ken Kellner