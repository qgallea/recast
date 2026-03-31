###########################################################################################################################
#  The program below uses code from the paper
#  "Double/Debiased Machine Learning of Treatment and Causal Parameters",  AER P&P 2017     
#  "Double Machine Learning for Treatment and Causal Parameters",  Arxiv 2016               

# 
# 

# 
# 

###########################################################################################################################

###################### Loading packages  ###########################

library(foreign);
library(quantreg);
library(mnormt);
library(gbm);
library(glmnet);
library(MASS);
library(rpart);
library(doParallel)
library(sandwich);
library(hdm);
library(randomForest);
library(nnet)
library(matrixStats)
library(quadprog)
library(ivmodel)
library(xtable)
library(tictoc)

###################### Loading functions and Data ##############################

rm(list = ls())  # Clear everything out so we're starting clean
setwd("Replication_package_BaiardiNaghi/Replication_Code&Data/Code_Tariffs")
source("ML_Functions.R")
source("Moment_Functions.R")
options(warn=-1)
set.seed(1234);
cl   <- makeCluster(12, outfile="")

# load data
library(readstata13)
data.raw        <- read.dta13("../Data/data_tariffs.dta")

#  
#Change part of the code below using data_tarrifs_table_column.R for the different tables and panels 

data <- data.raw[which(data.raw$industry=="211212"),]
controls <- c("avg_tar", "init", "inv", "human_cap", "w_africa", "e_africa", "s_c_africa",
              "n_afr_me", "e_europe", "lat_america", "e_asia", "s_e_asia", "s_w_asia",
              "dum80_83", "dum85_87", "ln_init_q_skilla", "ln_init_q_unskilla") 
y <- "growth"
d <- "diffg"






data <- data[complete.cases(data[,c(y,d,controls)]),c(y,d,controls)]

# generate formula for x, xl is for linear models
x <- ""
for(i in 1:length(controls)){
  x <- paste(x, controls[i], "+", sep = "")
}
x  <- substr(x, 1, nchar(x)-1)


# # 
xl <- paste("(", x , ")^2", sep="")

# create interaction terms
k <- length(controls)
nr_interactions <- sum(1:(k-1))
x_inter <- matrix(NA, nrow(data), nr_interactions)
i <- 1
for (col1 in 1:k) {
  for (col2 in 1:k) {
    if (col2 > col1) {
      x_inter[,i] <- data[,controls[col1]] * data[,controls[col2]]
      i <- i + 1
    }
  }
}
colnames(x_inter) <- paste("x", 1:nr_interactions, sep="") 
data[,colnames(x_inter)] <- x_inter


# xl <- "datause[,c(controls, colnames(x_inter))]"

controls_xl <- c(controls, colnames(x_inter))
xl <- ""
for(i in 1:length(controls_xl)){
  xl <- paste(xl, controls_xl[i], "+", sep = "")
}
xl  <- substr(xl, 1, nchar(xl)-1)

# form_y <- "skill1_corr"
# form_x <- xl
# alp <- 1
# arg <- list(penalty = list(homoscedastic = FALSE, X.dependent.lambda =FALSE, lambda.start = NULL, c = 1.1), intercept = TRUE)
# form            <- as.formula(paste(form_y, "~", form_x));
# fit           <- lm(form,  x = TRUE, y = TRUE, data=data);
# lasso         <- cv.glmnet(x=fit$x[ ,-1], y=fit$y)

################################ Inputs ########################################

# Controls
# x      <- "age + inc + educ + fsize + marr + twoearn + db + pira + hown" # use this for tree-based methods like forests and boosted trees
# xl     <- "(poly(age, 6, raw=TRUE) + poly(inc, 8, raw=TRUE) + poly(educ, 4, raw=TRUE) + poly(fsize, 2, raw=TRUE) + marr + twoearn + db + pira + hown)^2";  # use this for rlasso etc.

# Method names: Boosting, Nnet, RLasso, PostRLasso, Forest, Trees, Ridge, Lasso, Elnet, Ensemble

##Use these boosting settings for Table 2, Country-level estimates
Boosting     <- list(n.minobsinnode = 1, bag.fraction = .8, train.fraction = 1.0, interaction.depth=2, n.trees=1000, shrinkage=.01, n.cores=1, cv.folds=2, verbose = FALSE, clas_dist= 'adaboost', reg_dist='gaussian')
##Use these boosting settings for Table S3.3 and S3.4 in the online appendix, Industry-level estimates 
#Boosting     <- list(n.minobsinnode = 1, bag.fraction = .5, train.fraction = 1.0, interaction.depth=2, n.trees=2000, shrinkage=.01, n.cores=1, cv.folds=2, verbose = FALSE, clas_dist= 'adaboost', reg_dist='gaussian')

Forest       <- list(clas_nodesize=1, reg_nodesize=5, ntree=1000, na.action=na.omit, replace=TRUE)
RLasso       <- list(penalty = list(homoscedastic = FALSE, X.dependent.lambda =FALSE, lambda.start = NULL, c = 1.1), intercept = TRUE)
#Nnet         <- list(size=2,  maxit=1000, decay=0.01, MaxNWts=10000,  trace=FALSE)  #Industry-level estimates
Trees        <- list(reg_method="anova", clas_method="class")
Elnet        <- list(penalty = list(homoscedastic = FALSE, X.dependent.lambda =FALSE, lambda.start = NULL, c = 1.1), intercept = TRUE)
Lasso        <- list(nfolds = 10)

##Use these Nnet settings for Table 2, Country-level estimates
Nnet         <- list(size=3,  maxit=1000, decay=0.001, MaxNWts=10000,  trace=FALSE)

arguments    <- list(Forest=Forest, Trees=Trees, Lasso=Lasso, Boosting=Boosting, Nnet=Nnet)
ensemble     <- list(methods=c("Forest", "Trees", "Lasso", "Nnet"))            # specify methods for the ensemble estimation
methods      <- c("Forest", "Trees", "Lasso", "Nnet", "Ensemble")                # method names to be estimated


################################ Estimation ##################################################

############## Arguments for DoubleML function:

# data:     : data matrix
# y         : outcome variable
# d         : treatment variable
# z         : instrument
# xx        : controls for tree-based methods
# xL        : controls for penalized linear methods
# methods   : machine learning methods
# DML       : DML1 or DML2 estimation (DML1, DML2)
# nfold     : number of folds in cross fitting
# est       : estimation methods (IV, LATE, plinear, interactive)
# arguments : argument list for machine learning methods
# ensemble  : ML methods used in ensemble method
# silent    : whether to print messages
# trim      : bounds for propensity score trimming

ite <- 100

tic()
r <- foreach(k = 1:ite, .combine='rbind', .inorder=FALSE, .packages=c('MASS','randomForest','neuralnet','gbm', 'sandwich', 'hdm', 'nnet', 'rpart','glmnet')) %dopar% {

  dml <- DoubleML(data=data, y=y, d=d, z=NULL, xx=x, xL=xl, methods=methods, DML="DML2", nfold=2, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE, trim=c(0.01,0.99)) 
  
  data.frame(t(dml[1,]), t(dml[2,]))
  
}
toc() # 837 sec for 2 iterations
# 

# 

r <- as.matrix(r)

################################ Compute Output Table ########################################

result           <- matrix(0,3, length(methods)+1)
colnames(result) <- cbind(t(methods), "best")
rownames(result) <- cbind("Median ATE", "se(median)",  "se")

result[1,]        <- colQuantiles(r[,1:(length(methods)+1)], probs=0.5) # 
result[2,]        <- colQuantiles(sqrt(r[,(length(methods)+2):ncol(r)]^2+(r[,1:(length(methods)+1)] - colQuantiles(r[,1:(length(methods)+1)], probs=0.5))^2), probs=0.5)
result[3,]        <- colQuantiles(r[,(length(methods)+2):ncol(r)], probs=0.5)

result_table <- round(result, digits = 5)

for(i in 1:ncol(result_table)){
  for(j in seq(2,nrow(result_table),3)){
    
    result_table[j,i] <- paste("(", result_table[j,i], ")", sep="")
    
  }
  for(j in seq(3,nrow(result_table),3)){
    
    result_table[j,i] <- paste("(", result_table[j,i], ")", sep="")
    
  }
}
if (y=="growth") {
  if (d=="skill1_corr") {
    printName <- "TA_T2_PA.txt"
  }
  if (d=="diffa") {
    printName <- "TA_T2_PB.txt"
  }
  if (d=="diffg") {
    printName <- "TA_T2_PC.txt"
  }
}
if ((y=="prod_growth")) {
  if ("init_tar" %in% controls) {
    if (d=="skill1_corr") {
      printName <- "TA_S4_PA.txt"
    }
    if (d=="diffa") {
      printName <- "TA_S4_PB.txt"
    }
    if (d=="diffg") {
      printName <- "TA_S4_PC.txt"
    }
  } else {
    if (d=="skill1_corr") {
      printName <- "TA_S3_PA.txt"
    }
    if (d=="diffa") {
      printName <- "TA_S3_PB.txt"
    }
    if (d=="diffg") {
      printName <- "TA_S3_PC.txt"
    }
  }
}
print(xtable(result_table, type="latex", digits=3), include.rownames=TRUE, file=paste(printName))



###############################################################
######### BOOSTING ############################################

################################ Inputs ########################################

# Controls
# x      <- "age + inc + educ + fsize + marr + twoearn + db + pira + hown" # use this for tree-based methods like forests and boosted trees
# xl     <- "(poly(age, 6, raw=TRUE) + poly(inc, 8, raw=TRUE) + poly(educ, 4, raw=TRUE) + poly(fsize, 2, raw=TRUE) + marr + twoearn + db + pira + hown)^2";  # use this for rlasso etc.

# Method names: Boosting, Nnet, RLasso, PostRLasso, Forest, Trees, Ridge, Lasso, Elnet, Ensemble

##Use these boosting settings for Table 2, Country-level estimates
Boosting     <- list(n.minobsinnode = 1, bag.fraction = .8, train.fraction = 1.0, interaction.depth=2, n.trees=1000, shrinkage=.01, n.cores=1, cv.folds=2, verbose = FALSE, clas_dist= 'adaboost', reg_dist='gaussian')
##Use these boosting settings for Table S3.3 and S3.4 in the online appendix, Industry-level estimates 
#Boosting     <- list(n.minobsinnode = 1, bag.fraction = .5, train.fraction = 1.0, interaction.depth=2, n.trees=2000, shrinkage=.01, n.cores=1, cv.folds=2, verbose = FALSE, clas_dist= 'adaboost', reg_dist='gaussian')

Forest       <- list(clas_nodesize=1, reg_nodesize=5, ntree=1000, na.action=na.omit, replace=TRUE)
RLasso       <- list(penalty = list(homoscedastic = FALSE, X.dependent.lambda =FALSE, lambda.start = NULL, c = 1.1), intercept = TRUE)
#Nnet         <- list(size=2,  maxit=1000, decay=0.01, MaxNWts=10000,  trace=FALSE)  #Industry-level estimates
Trees        <- list(reg_method="anova", clas_method="class")
Elnet        <- list(penalty = list(homoscedastic = FALSE, X.dependent.lambda =FALSE, lambda.start = NULL, c = 1.1), intercept = TRUE)
Lasso        <- list(nfolds = 10)

##Use these Nnet settings for Table 2, Country-level estimates
Nnet         <- list(size=3,  maxit=1000, decay=0.001, MaxNWts=10000,  trace=FALSE)

arguments    <- list(Forest=Forest, Trees=Trees, Lasso=Lasso, Boosting=Boosting, Nnet=Nnet)
ensemble     <- list(methods=c("Forest", "Trees", "Lasso", "Boosting", "Nnet"))            # specify methods for the ensemble estimation
methods      <- c("Boosting")                # method names to be estimated


################################ Estimation ##################################################

############## Arguments for DoubleML function:

# data:     : data matrix
# y         : outcome variable
# d         : treatment variable
# z         : instrument
# xx        : controls for tree-based methods
# xL        : controls for penalized linear methods
# methods   : machine learning methods
# DML       : DML1 or DML2 estimation (DML1, DML2)
# nfold     : number of folds in cross fitting
# est       : estimation methods (IV, LATE, plinear, interactive)
# arguments : argument list for machine learning methods
# ensemble  : ML methods used in ensemble method
# silent    : whether to print messages
# trim      : bounds for propensity score trimming

ite <- 100

tic()
r <- foreach(k = 1:ite, .combine='rbind', .inorder=FALSE, .packages=c('MASS','randomForest','neuralnet','gbm', 'sandwich', 'hdm', 'nnet', 'rpart','glmnet')) %dopar% {
  
  dml <- DoubleML(data=data, y=y, d=d, z=NULL, xx=x, xL=xl, methods=methods, DML="DML2", nfold=2, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE, trim=c(0.01,0.99)) 
  
  data.frame(t(dml[1,]), t(dml[2,]))
  
}
toc() # 837 sec for 2 iterations
# 

# 

r <- as.matrix(r)

################################ Compute Output Table ########################################

result           <- matrix(0,3, length(methods)+1)
colnames(result) <- cbind(t(methods), "best")
rownames(result) <- cbind("Median ATE", "se(median)",  "se")

result[1,]        <- colQuantiles(r[,1:(length(methods)+1)], probs=0.5) # 
result[2,]        <- colQuantiles(sqrt(r[,(length(methods)+2):ncol(r)]^2+(r[,1:(length(methods)+1)] - colQuantiles(r[,1:(length(methods)+1)], probs=0.5))^2), probs=0.5)
result[3,]        <- colQuantiles(r[,(length(methods)+2):ncol(r)], probs=0.5)

result_table <- round(result, digits = 5)

for(i in 1:ncol(result_table)){
  for(j in seq(2,nrow(result_table),3)){
    
    result_table[j,i] <- paste("(", result_table[j,i], ")", sep="")
    
  }
  for(j in seq(3,nrow(result_table),3)){
    
    result_table[j,i] <- paste("(", result_table[j,i], ")", sep="")
    
  }
}
if (y=="growth") {
  if (d=="skill1_corr") {
    printName <- "TA_T2_PA_boosting.txt"
  }
  if (d=="diffa") {
    printName <- "TA_T2_PB_boosting.txt"
  }
  if (d=="diffg") {
    printName <- "TA_T2_PC_boosting.txt"
  }
}
if ((y=="prod_growth")) {
  if ("init_tar" %in% controls) {
    if (d=="skill1_corr") {
      printName <- "TA_S4_PA.txt"
    }
    if (d=="diffa") {
      printName <- "TA_S4_PB.txt"
    }
    if (d=="diffg") {
      printName <- "TA_S4_PC.txt"
    }
  } else {
    if (d=="skill1_corr") {
      printName <- "TA_S3_PA.txt"
    }
    if (d=="diffa") {
      printName <- "TA_S3_PB.txt"
    }
    if (d=="diffg") {
      printName <- "TA_S3_PC.txt"
    }
  }
}
print(xtable(result_table, type="latex", digits=3), include.rownames=TRUE, file=paste(printName))
