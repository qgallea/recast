# 
# Robustness Checks with the Causal Random Forest   
#             

# This empirical example uses the data from Djankov, Simeon, et al. "The effect of corporate taxes on investment and entrepreneurship." American Economic Journal: Macroeconomics 2.3 (2010): 31-64..
#######################################################################################################################################################
#### Column 1 of Table S3.2 ####
library(devtools)
###################### Loading packages ###########################
library(xtable)
library(dummy)
library(grf)
library(foreign)
install_version("grf", version = "1.2.0", repos = "http://cran.us.r-project.org")
rm(list = ls()) 
###################### Loading functions and Data ##############################

setwd("Replication_package_BaiardiNaghi/Replication_Code&Data/Code_Taxes")
set.seed(12345)
# Column 1A ----------------------------------------------------------------
data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("Investment2005", "statutory", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_1a <- lm(Investment2005~., data)

################################ Inputs ##############################

# Outcome Variable
y <- "Investment2005"

# list of treatment of Treatment Indicator
d <-"statutory"

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=", ")

#cf
X <- as.matrix(data[!colnames(data)%in%c(y,d)])
y <- data[,y]
d <- data[,d]
cf <- causal_forest(X, y, d, seed= 123)
Row1 <- average_partial_effect(cf)

data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("Investment2005", "effective", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_2a <- lm(Investment2005~., data)

################################ Inputs ##############################

# Outcome Variable
y <- "Investment2005"

# list of treatment of Treatment Indicator

d <-"effective"

z <- NULL

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=" + ")

#cf
X <- as.matrix(data[!colnames(data)%in%c(y,d)])
y <- data[,y]
d <- data[,d]
cf <- causal_forest(X, y, d, seed= 123)
Row2 <- average_partial_effect(cf)

data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("Investment2005", "effective_5yr", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_3a <- lm(Investment2005~., data)

################################ Inputs ##############################

# Outcome Variable
y <- "Investment2005"

# list of treatment of Treatment Indicator

d <-"effective_5yr"

z <- NULL

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=" + ")

#cf
X <- as.matrix(data[!colnames(data)%in%c(y,d)])
y <- data[,y]
d <- data[,d]
cf <- causal_forest(X, y, d, seed= 123)
Row3 <- average_partial_effect(cf)
capture.output(rbind(Row1, Row2, Row3), file=paste("TX_S2_C1.txt"))



