# a quick function for handling the output of, e.g., occupancy models and
# putting the values back on the probability scale
logit2prob <- function(logit){
  odds <- exp(logit)
  prob <- odds / (1 + odds)
  return(prob)
}