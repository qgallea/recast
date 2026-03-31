library(devtools)
install_version("grf", version = "1.2.0", repos = "http://cran.us.r-project.org")
rm(list = ls())

library(foreign)
library(grf)
library(DiagrammeR) 
library(DiagrammeRsvg)
library(plyr)
library(knitr)
library(doBy)
library(xtable)

setwd("Replication_package_BaiardiNaghi/Replication_Code&Data/Code_FoxNews")
set.seed(1)
# load data and select variables used in analysis
df <- read.dta("../Data/data_fox_news.dta") 

# add dummy variable noch2000d1
x1 <- as.matrix(df[,c("noch2000d2", "noch2000d3", "noch2000d4", "noch2000d5","noch2000d6", "noch2000d7", "noch2000d8", 
                      "noch2000d9", "noch2000d10")])
df$noch2000d1 <- rep(0, dim(x1)[1])
df$noch2000d1[which(rowSums(x1)==0)] <- 1

# add dummy variable poptot2000d1
x2 <- as.matrix(df[,c("poptot2000d2", "poptot2000d3", "poptot2000d4", "poptot2000d5","poptot2000d6", "poptot2000d7", 
                      "poptot2000d8", "poptot2000d9", "poptot2000d10")])
df$poptot2000d1 <- rep(0, dim(x2)[1])
df$poptot2000d1[which(rowSums(x2)==0)] <- 1

# define variables used in regression
Y <- df$reppresfv2p00m96
W <- df$foxnews2000
census_controls_90 <- c("pop00m90", "hs00m90", "hsp00m90", "college00m90", "male00m90", 
                        "black00m90", "hisp00m90", "empl00m90", "unempl00m90", "married00m90", 
                        "income00m90", "urban00m90")
census_controls_20 <- c("pop2000", "hs2000", "hsp2000", "college2000", "male2000",
                        "black2000", "hisp2000", "empl2000", "unempl2000", "married2000", 
                        "income2000", "urban2000")
cable_controls <- c("poptot2000", "poptot2000d1", "poptot2000d2", "poptot2000d3", "poptot2000d4", 
                    "poptot2000d5", "poptot2000d6", "poptot2000d7", "poptot2000d8", "poptot2000d9", 
                    "poptot2000d10", "noch2000", "noch2000d1", "noch2000d2", "noch2000d3", "noch2000d4", 
                    "noch2000d5", "noch2000d6", "noch2000d7", "noch2000d8", "noch2000d9", "noch2000d10")
controls_VI <- c("reppresfv2pwdstd22000", "reppresfv2pwdstd32000")

# check whether number of controls coincides with thesis
nr_controls <- length(census_controls_20)+length(census_controls_90)+length(cable_controls)+length(controls_VI)

# make dummies for the fixed effects house disctrict
house_district_fe <- model.matrix(~ factor(df$diststate) + 0)

# establish X matrix with controls and fixed effects
X <- as.matrix(cbind(df[,c(census_controls_90, census_controls_20, cable_controls, controls_VI)], house_district_fe)) 

# create list of variable names
X.names <- c(census_controls_90, census_controls_20, cable_controls, controls_VI, unique(lapply(df$diststate, toString)))

# create dataframe with variable description
df.labels <- data.frame(t(attributes(df)$var.labels))
names(df.labels) <- names(df)[1:219]

# grow a cf. Add extra trees for the causal forest
Y.forest = regression_forest(X, Y, num.trees=2000, sample.weights = df$totpresvotes1996 )
Y.hat = predict(Y.forest)$predictions
W.forest = regression_forest(X, W, num.trees = 2000, sample.weights = df$totpresvotes1996 )
W.hat = predict(W.forest)$predictions

hist(W.hat, main = "Propensity scores Causal forest", xlab = "W.hat")


########################## Single Forest #############################
# train causal forest
cf = causal_forest(X, Y, W, Y.hat = Y.hat, W.hat = W.hat,
                   sample.weights = df$totpresvotes1996,
                   tune.parameters = "all", num.trees = 2000)
tau.hat = predict(cf)$predictions

# check whether overlap assumption is violated
propensity.forest = regression_forest(X, W)
W.hat.check = predict(propensity.forest)$predictions
hist(W.hat.check, main = "Histogram of W.hat", xlab = "propensity score")

####################
# TABLE 3 Column 1 #
####################

# calculate average treatment effect
ATE = average_treatment_effect(cf)

# compare regions with high and low estimated CATEs
high_effect = tau.hat > median(tau.hat)
ate.high = average_treatment_effect(cf, subset = high_effect)
ate.low = average_treatment_effect(cf, subset = !high_effect)

# intialize matrix to save values
ate_matrix <- data.frame(matrix(ncol = 2, nrow = 9))
names(ate_matrix) <- c("", "y")
ate_matrix[,1] <- c("Average treatment effect", "","ATE (high)", "","ATE (low)", "",
                    "95% CI", "95% CI for the difference", 
                    "Observations")

# save values in format to write to word
ate_matrix[1,2] <- paste0(round(ATE[1],5), " (", round(ATE[2],5), ")")
ate_matrix[2,2] <- paste0("t-value: ", round(ATE[1]/ATE[2],5))
ate_matrix[3,2] <- paste0(round(ate.high[1],5), " (", round(ate.high[2],5), ")")
ate_matrix[4,2] <- paste0("t-value: ", round(ate.high[1]/ate.high[2],5))
ate_matrix[5,2] <- paste0(round(ate.low[1],5), " (", round(ate.low[2],5), ")")
ate_matrix[6,2] <- paste0("t-value: ", round(ate.low[1]/ate.low[2],5))
ate_matrix[7,2] <- paste0("(", round(ATE[1], 5) - round(qnorm(0.975) * ATE[2], 5), ", ",
                          round(ATE[1], 5) + round(qnorm(0.975) * ATE[2], 5), ")")
ate_matrix[8,2] <- paste0("(", round(ate.high[1] - ate.low[1], 5) - round(qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2), 5),
                          ", ", round(ate.high[1] - ate.low[1], 5) + round(qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2), 5), ")")
ate_matrix[9,2] <- dim(df)[1]
kable(ate_matrix)

print(xtable(ate_matrix, type="latex"), include.rownames=FALSE, file=paste("FN_T3_C1.txt"))

t.test(tau.hat[high_effect], tau.hat[!high_effect])

##############
# TABLE S3.9 #
##############

varimp = variable_importance(cf)
selected = which.maxn(varimp,37)

# set table into format to write to word document
kable(as.matrix(cbind(X.names[selected], varimp[selected])))
print(xtable(as.matrix(cbind(X.names[selected], paste0(round(varimp[selected]*100,2), "%"))), type="latex"), include.rownames=FALSE, file=paste("FN_S9.txt"))

###################
# TABLE 4 Panel A and S3.7 #
###################

# perform cluster-weighted t-test for all variables
#indices_var <- c(which(X.names=="urban2000"), which(X.names=="reppresfv2pwdstd22000"), which(X.names=="reppresfv2pwdstd32000"))
#indices <- c(selected.idx, indices_var)
most_imp_var <- X[,1:48]
names_most_imp_var <- as.matrix(c(X.names[1:48]))
data_matrix <- data.frame(matrix(ncol = 6, nrow = dim(most_imp_var)[2]))
names(data_matrix) <- c("Variable", "ATE low",  "ATE high", "95% CI difference", "t-value difference", "p-value difference")
for (i in 1:dim(most_imp_var)[2]) {
  
  high_effect <- most_imp_var[, i] > median(most_imp_var[, i])
  ate.high = average_treatment_effect(cf, subset = high_effect)
  ate.low = average_treatment_effect(cf, subset = !high_effect)
  
  # save in format to write to word
  data_matrix[i,1] <- names_most_imp_var[i]
  data_matrix[i,2] <- paste0(round(ate.low[1],5), " (", round(ate.low[2],5), ")")
  data_matrix[i,3] <- paste0(round(ate.high[1],5), " (", round(ate.high[2],5), ")")
  data_matrix[i,4] <- paste0("(", round(ate.high[1] - ate.low[1], 5) - round(qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2), 5),
                             ", ", round(ate.high[1] - ate.low[1], 5) + round(qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2), 5), ")")
  
  CIhigh <- ate.high[1] - ate.low[1] + qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2)
  CIlow <- ate.high[1] - ate.low[1] - qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2)
  se <- (CIhigh - CIlow) / (2* qnorm(0.975))
  z <- (ate.high[1] - ate.low[1]) / se
  data_matrix[i,5] <- paste0(round(z,5))
  data_matrix[i,6] <- paste0(round(2 * pnorm(-abs(z)),5))
}
kable(data_matrix)
print(xtable(data_matrix, type="latex"), include.rownames=FALSE, file=paste("FN_T4_PA_&_S7.txt"))

##############
# TABLE S3.6 Column 1 #
##############
print("CALIBRATION TEST")
capture.output(test_calibration(cf), file=paste("FN_S6_C1.txt"))

########################## Double Forest #############################
# variable selection
#cf.raw = causal_forest(X, Y, W,
 #                      Y.hat = Y.hat, W.hat = W.hat, tune.parameters="all", sample.weights = df$totpresvotes1996, num.trees = 2000)
varimp = variable_importance(cf)
selected.idx = sort(which.maxn(varimp,9))
print("SELECTED VARIABLES")
kable(unlist(X.names[selected.idx]))

xtable(as.matrix(cbind(unlist(X.names[selected.idx]), paste0(round(100*varimp[selected.idx],2), "%"))), type="latex")
print(xtable(as.matrix(cbind(unlist(X.names), paste0(round(100*varimp,2), "%"))), type="latex"), include.rownames=FALSE)

# train causal forest with selected variables
cf = causal_forest(X[,selected.idx], Y, W, Y.hat = Y.hat, W.hat = W.hat, 
                   sample.weights = df$totpresvotes1996,
                   tune.parameters = "all", num.trees = 2000)
tau.hat = predict(cf)$predictions

# scree plot of the variable importance
#plot(sort(varimp, decreasing=TRUE), type="lines", main ="Scree plot", ylab = "Variable importance", xlab = "Variables")
#plot(sort(variable_importance(cf.raw)[1:40], decreasing=TRUE), ylab="Importance", type = "l")

# check whether overlap assumption is violated
propensity.forest = regression_forest(X, W)
W.hat.check = predict(propensity.forest)$predictions
hist(W.hat.check, main = "Histogram of W.hat", xlab = "propensity score")

####################
# TABLE S3.11 Column 1 #
####################

# calculate average treatment effect
ATE = average_treatment_effect(cf)

# compare regions with high and low estimated CATEs
high_effect = tau.hat > median(tau.hat)
ate.high = average_treatment_effect(cf, subset = high_effect)
ate.low = average_treatment_effect(cf, subset = !high_effect)

# intialize matrix to save values
ate_matrix <- data.frame(matrix(ncol = 2, nrow = 9))
names(ate_matrix) <- c("", "y")
ate_matrix[,1] <- c("Average treatment effect", "","ATE (high)", "","ATE (low)", "",
                    "95% CI", "95% CI for the difference", 
                    "Observations")

# save values in format to write to word
ate_matrix[1,2] <- paste0(round(ATE[1],5), " (", round(ATE[2],5), ")")
ate_matrix[2,2] <- paste0("t-value: ", round(ATE[1]/ATE[2],5))
ate_matrix[3,2] <- paste0(round(ate.high[1],5), " (", round(ate.high[2],5), ")")
ate_matrix[4,2] <- paste0("t-value: ", round(ate.high[1]/ate.high[2],5))
ate_matrix[5,2] <- paste0(round(ate.low[1],5), " (", round(ate.low[2],5), ")")
ate_matrix[6,2] <- paste0("t-value: ", round(ate.low[1]/ate.low[2],5))
ate_matrix[7,2] <- paste0("(", round(ATE[1], 5) - round(qnorm(0.975) * ATE[2], 5), ", ",
                          round(ATE[1], 5) + round(qnorm(0.975) * ATE[2], 5), ")")
ate_matrix[8,2] <- paste0("(", round(ate.high[1] - ate.low[1], 5) - round(qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2), 5),
                          ", ", round(ate.high[1] - ate.low[1], 5) + round(qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2), 5), ")")
ate_matrix[9,2] <- dim(df)[1]
kable(ate_matrix)

print(xtable(ate_matrix, type="latex"), include.rownames=FALSE, file=paste("FN_S11_C1.txt"))

t.test(tau.hat[high_effect], tau.hat[!high_effect])


###################
# TABLE S3.12 Panel A #
###################

# perform cluster-weighted t-test for all variables
#indices_var <- c(which(X.names=="urban2000"), which(X.names=="reppresfv2pwdstd22000"), which(X.names=="reppresfv2pwdstd32000"))
#indices <- c(selected.idx, indices_var)
most_imp_var <- X[,selected.idx]
names_most_imp_var <- as.matrix(c(X.names[selected.idx]))
data_matrix <- data.frame(matrix(ncol = 6, nrow = dim(most_imp_var)[2]))
names(data_matrix) <- c("Variable", "ATE low",  "ATE high", "95% CI difference", "t-value difference", "p-value difference")
for (i in 1:dim(most_imp_var)[2]) {
  
  high_effect <- most_imp_var[, i] > median(most_imp_var[, i])
  ate.high = average_treatment_effect(cf, subset = high_effect)
  ate.low = average_treatment_effect(cf, subset = !high_effect)
  
  # save in format to write to word
  data_matrix[i,1] <- names_most_imp_var[i]
  data_matrix[i,2] <- paste0(round(ate.low[1],5), " (", round(ate.low[2],5), ")")
  data_matrix[i,3] <- paste0(round(ate.high[1],5), " (", round(ate.high[2],5), ")")
  data_matrix[i,4] <- paste0("(", round(ate.high[1] - ate.low[1], 5) - round(qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2), 5),
                             ", ", round(ate.high[1] - ate.low[1], 5) + round(qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2), 5), ")")
  
  CIhigh <- ate.high[1] - ate.low[1] + qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2)
  CIlow <- ate.high[1] - ate.low[1] - qnorm(0.975) * sqrt(ate.high[2]^2 + ate.low[2]^2)
  se <- (CIhigh - CIlow) / (2* qnorm(0.975))
  z <- (ate.high[1] - ate.low[1]) / se
  data_matrix[i,5] <- paste0(round(z,5))
  data_matrix[i,6] <- paste0(round(2 * pnorm(-abs(z)),5))
}
kable(data_matrix)
print(xtable(data_matrix, type="latex"), include.rownames=FALSE, file=print("FN_S12_PA.txt"))
