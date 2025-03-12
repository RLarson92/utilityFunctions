###############################################################################
#                                                                             #
#                         Code to Combine Survey123's                         #
#                     Metadata and Individual Object Data                     #
#                         AND Save as a New CSV File                          #
#                                                                             #
###############################################################################

# Written by R.N. Larson
# Last Updated: 8 Nov 2024

# This code will combine the information found in the two .csv file outputs 
# from the small mammal form in Survey123. This code adds new columns to the
# mammal capture data with information found on the metadata form (e.g., 
# weather conditions)

# although I've written it with the small mammal capture data in mind, the code 
# will work with any survey that has metadata stored in one .csv and 
# object-specific data (e.g., individual animal data) stored in another

# Start by loading in your Survey123 results. You will need to change the file 
# paths (the stuff in quotes) to match where your files are stored on your 
# computer

# this survey_0.csv is the metadata file, containing, in this example, data 
# about the weather, temperature, etc. for each night of small mammal trapping
myMetadata <- read.csv("C:/Users/rlarson/Documents/survey123/survey_0.csv") 

# then this Captures_1.csv is the object-specific data file, containing
# information on each animal captured (e.g., species, weights, sex, etc.)
myAnimalData <- read.csv("C:/Users/rlarson/Documents/survey123/Captures_1.csv")

# these two datasets are linked via a key, which is a string of random 
# characters unique to each entry in the metadata file. In the metadata file, 
# this column is labeled 'GlobalID' and in the object-specific file this is 
# called the 'ParentGlobalID'. 

# For example, let's say you did two surveys, one at site A and one at site B. 
# At site A you caught 5 lizards and at site B you caught 2 lizards. The 
# 'GlobalID' for site A is 123abc and the ID for site B is 678def, then the 5 
# lizards from site A will have 123abc in their 'ParentGlobalID' column (and 
# the site B lizards will have 678edf)

# Now let's actually join these datasets together.
# I like to use the functions in 'dplyr', an R package for keeping your data 
# tidy. You'll need to install this package if you haven't already, which you 
# can do by deleting the '#' in front of this next line of code and running it:

# install.packages("dplyr")

# then boot up the package to use the functions:
library(dplyr)

# next we'll tell R which columns to use as the key for each dataset. this
# line of code tells R to copy data from the metadataset (y) when the GlobalID
# matches the ParentGlobalID in the animal dataset (x)
joinColumn <- join_by(x$ParentGlobalID == y$GlobalID) 

# then, this line of code actually does the joining
myCombinedData <- left_join(myAnimalData, myMetadata, by=joinColumn)
# you should see the metadata associated with each animal capture has been 
# added to the right-hand side of the data frame

# now save it as a .csv file for later or to use with another program. Again,
# should change the filepath to where you want the file to be saved. You can
# also edit the name of your file to whatever you want
write.csv(myCombinedData, 
          "C:/Users/rlarson/Documents/survey123/myCombinedData.csv", 
          row.names = F)

# That's it! You're done! Enjoy having all your data combined in one place

