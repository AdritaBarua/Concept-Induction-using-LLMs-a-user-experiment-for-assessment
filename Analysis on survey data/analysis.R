# Load the necessary libraries
library(dplyr)
library(brms)
library(BradleyTerry2)
# Read the data, setting fill = TRUE to handle incomplete lines
data <- read.csv("final.csv", header = TRUE, fill = TRUE) #read the csv file containing survey data

# Rename columns to ensure consistency
colnames(data) <- gsub("^set", "Set", colnames(data), ignore.case = TRUE)

# Initialize counters
HvE_wins_total <- 0
HvL_wins_total <- 0
EvL_wins_total <- 0
EvH_wins_total <- 0
LvH_wins_total <- 0
LvE_wins_total <- 0

# Create an empty data frame to store ability scores
ability_scores <- data.frame()

# Print the header
cat("ImageSet  HvE Wins HvL Wins EvL Wins\n")

# Loop over all sets
for (i in 1:45) {
  # Initialize set-specific counters
  HvE_wins <- 0
  HvL_wins <- 0
  EvL_wins <- 0
  EvH_wins <- 0
  LvH_wins <- 0
  LvE_wins <- 0
  
  # Calculate wins and losses for HvE
  tryCatch({
    HvE_wins <- sum(data[, paste0("Set", i, "_HvE")] == 56 & !is.na(data[, paste0("Set", i, "_HvE")]))
    EvH_wins <- sum(data[, paste0("Set", i, "_HvE")] == 57 & !is.na(data[, paste0("Set", i, "_HvE")]))
  }, error = function(e) {
    cat("Error in processing Set", i, "for HvE:", e$message, "\n")
  })
  
  # Calculate wins and losses for HvL
  tryCatch({
    HvL_wins <- sum(data[, paste0("Set", i, "_HvL")] == 56 & !is.na(data[, paste0("Set", i, "_HvL")]))
    LvH_wins <- sum(data[, paste0("Set", i, "_HvL")] == 57 & !is.na(data[, paste0("Set", i, "_HvL")]))
  }, error = function(e) {
    cat("Error in processing Set", i, "for HvL:", e$message, "\n")
  })
  
  # Calculate wins and losses for EvL
  tryCatch({
    EvL_wins <- sum(data[, paste0("Set", i, "_EvL")] == 56 & !is.na(data[, paste0("Set", i, "_EvL")]))
    LvE_wins <- sum(data[, paste0("Set", i, "_EvL")] == 57 & !is.na(data[, paste0("Set", i, "_EvL")]))
  }, error = function(e) {
    cat("Error in processing Set", i, "for EvL:", e$message, "\n")
  })
  
  # Print wins for the current set
  print("Set HvE.wins HvL.wins LvE.wins")
  cat(sprintf("Set_%d, %s, %s, %s\n", 
              i, 
              paste(HvE_wins, "-", EvH_wins, sep = ""),
              paste(HvL_wins, "-", LvH_wins, sep = ""),
              paste(LvE_wins, "-", EvL_wins, sep = ""))) 
  
  # Accumulate total wins
  HvE_wins_total <- HvE_wins_total + HvE_wins
  HvL_wins_total <- HvL_wins_total + HvL_wins
  EvL_wins_total <- EvL_wins_total + EvL_wins
  EvH_wins_total <- EvH_wins_total + EvH_wins
  LvH_wins_total <- LvH_wins_total + LvH_wins
  LvE_wins_total <- LvE_wins_total + LvE_wins
  
  # Create a new data frame with column names Human, ECII, Human.wins, and ECII.wins
  new_data <- data.frame(
    Model1 = c("Human_explanation", "ECII_explanation", "LLM_explanation"),
    Model2 = c("ECII_explanation", "LLM_explanation", "Human_explanation"),
    Model1.wins = c(HvE_wins, EvL_wins, LvH_wins),  # contains the wins for Model1
    Model2.wins = c(EvH_wins, LvE_wins, HvL_wins)   # contains the wins for Model2
  )
  
  #new_data <- read.csv("test2.csv",header = TRUE, fill = TRUE)
  # Convert the ID columns to factors
  new_data$Model1 <- as.factor(new_data$Model1)
  new_data$Model2 <- as.factor(new_data$Model2)
  
  
  # Perform Bradley-Terry analysis
  bt_model <- BTm(cbind(Model1.wins, Model2.wins), Model1, Model2,
                  data = new_data)
     
  # Print the estimated abilities
  #cat(sprintf("Set %d Abilities:\n", i))
  #print(BTabilities(bt_model))
  
  
  # Store the ability scores for the current set in a data frame
  set_ability_scores <- data.frame(BTabilities(bt_model))
  
  # Add the Set number to the ability scores
  #set_ability_scores$Set <- i
  
  # Extract row names and convert to data frame
  set_ability_scores <- data.frame(type = rownames(set_ability_scores), set_ability_scores, row.names = NULL)
  
  # Append the ability scores for the current set to the main data frame
  ability_scores <- bind_rows(ability_scores, set_ability_scores)
}

# Print the total wins
cat("\nTotal Wins\n")
cat(sprintf("HvE: %d, HvL: %d, EvL: %d, EvH: %d, LvH: %d, LvE: %d\n", 
            HvE_wins_total, HvL_wins_total, EvL_wins_total, EvH_wins_total, LvH_wins_total, LvE_wins_total))


#Statistical evaluation on the ability scores
library(tidyverse)
library(dplyr)

ability_scores$type <- factor(ability_scores$type)
summary(ability_scores)
group_by(ability_scores, type) %>%
  summarise(
    mean = mean(ability, na.rm = TRUE),
    sd = sd(ability, na.rm = TRUE)
  )

# 2nd method:
res_aov <- aov(ability ~ type,
               data = ability_scores
)

summary(res_aov)

#install.packages("remotes")
#remotes::install_github("easystats/report") # You only need to do that once
library("report") # Load the package every time you start R

report(res_aov)

#install.packages("multcomp")
library(multcomp)

# Tukey HSD test:
post_test <- glht(res_aov,
                  linfct = mcp(type = "Tukey")
)

summary(post_test)
TukeyHSD(res_aov)



