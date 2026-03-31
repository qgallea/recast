# The program below uses code from
# "Double/Debiased Machine Learning of Treatment and Causal Parameters",  AER P&P 2017     
#  "Double Machine Learning for Treatment and Causal Parameters",  Arxiv 2016 

# This empirical example uses the data from Djankov, Simeon, et al. "The effect of corporate taxes on investment and entrepreneurship." American Economic Journal: Macroeconomics 2.3 (2010): 31-64..
#######################################################################################################################################################

###################### Loading packages ###########################
library(foreign);
library(quantreg);
library(mnormt);
library(gbm);
library(glmnet, warn.conflicts = FALSE);
library(MASS);
library(rpart);
library(foreach)
library(iterators)
library(parallel)
library(doParallel)
library(sandwich);
library(hdm);
library(randomForest);
library(nnet)
library(neuralnet)
library(matrixStats)
library(quadprog)
library(xtable)
library(ivmodel)
library(Hmisc)
library(dummy)
rm(list = ls()) 

###################### Loading functions and Data ##############################

setwd("Replication_package_BaiardiNaghi/Replication_Code&Data/Code_Taxes")
source("functions/ML_Functions_01.R")
source("functions/Moment_Functions_02.R")
source("functions/output_lasso_final.R")


options(warn=-1)
set.seed(1211);
cl <- makeCluster(15)
registerDoParallel(cl)

# Method names: Boosting, Nnet, RLasso, PostRLasso, Forest, Trees, Ridge, Lasso, Elnet, Ensemble

Boosting     <- list(n.minobsinnode = 1, bag.fraction = .5, train.fraction = 1.0, interaction.depth=2, n.trees=1000, shrinkage=.01, n.cores=1, cv.folds=2, verbose = FALSE, clas_dist= 'adaboost', reg_dist='gaussian')
Forest       <- list(clas_nodesize=1, reg_nodesize=5, ntree=1000, na.action=na.omit, replace=TRUE)
Lasso       <- list(s = "lambda.min",intercept = TRUE)
RLasso       <- list(intercept = TRUE)
Nnet         <- list(size=2,  maxit=1000, decay=0.01, MaxNWts=10000,  trace=FALSE)
Trees        <- list(reg_method="anova", clas_method="class")

arguments    <- list(Boosting=Boosting, Forest=Forest, RLasso=RLasso, Lasso=Lasso, Nnet=Nnet, Trees=Trees)

ensemble     <- list(methods=c("Lasso", "Boosting", "Forest", "Nnet"))                       # methods for the ensemble estimation
methods      <- c("Lasso", "Trees", "Boosting", "Forest", "Nnet","Ensemble")  
split        <- 100
nfold 	     <- 2

start_time <- Sys.time()


# Line 1 Panel C ----------------------------------------------------------------
data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("nbusinessdensitycf", "statutory", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_1b <- lm(nbusinessdensitycf~., data)

################################ Inputs ##############################

# Outcome Variable5
y <- "nbusinessdensitycf"


# list of treatment of Treatment Indicator

d <-"statutory"

z <- NULL

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=" + ")

# use this for tree-based methods like forests and boosted trees

xl <- paste("(", x, ")^2", sep="") # use this for rlasso etc.

start_time <- Sys.time()

r_1b <- foreach(k = 1:split, .combine='rbind', .inorder=FALSE, .packages=c('MASS','randomForest','neuralnet','gbm', 'sandwich', 'hdm', 'nnet', 'rpart','glmnet')) %dopar% { 
  set.seed(k+1); 
  dml <- DoubleML(data=data, y=y, d=d, z=z, xx=x, xL=xl, methods=methods, DML="DML2", nfold, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE, trim=NULL) 
  
}

end_time <- Sys.time()
time <- end_time - start_time

lasso_y = lasso_coeff(matrix_list_coeff = r_1b[, "lasso_y_coeff"], dep="y", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
lasso_d = lasso_coeff(matrix_list_coeff = r_1b[, "lasso_d_coeff"], dep="d", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
if(is.null(z)){lasso_z <- NA}else{lasso_z <- lasso_coeff(matrix_list_coeff = r_1b[, "lasso_z_coeff"], dep="z", split=split, nfold=nfold, output_coeff="pos", number_coeff=20)}
data_info <- list("n"=nrow(data),"p_col" = ncol(data), "y"= y, "d"=d, "x"=x, "xl"=xl, "methods"=methods, "time"= time, "split"=split, "nfold"=nfold, "original_1b"=original_1b)
lasso_coeff_1b <- list("lasso_y" = lasso_y, "lasso_d" = lasso_d, "lasso_z" = lasso_z)
r_1b <- r_1b[,"table"]
output_1b = output_p(r_1b, adj = T)
save(r_1b, output_1b, lasso_coeff_1b,  data_info, file = "taxes_t5D_c1b_output.RData")
print(output_1b[["output"]], include.rownames=FALSE, file=paste("TX_T1_PC_L1.txt"))
#stopCluster(cl)

# Line 2 Panel C ----------------------------------------------------------------
data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("nbusinessdensitycf", "effective", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_2b <- lm(nbusinessdensitycf~., data)

################################ Inputs ##############################

# Outcome Variable
y <- "nbusinessdensitycf"


# list of treatment of Treatment Indicator

d <-"effective"

z <- NULL

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=" + ")

# use this for tree-based methods like forests and boosted trees

xl <- paste("(", x, ")^2", sep="") # use this for rlasso etc.

start_time <- Sys.time()

r_2b <- foreach(k = 1:split, .combine='rbind', .inorder=FALSE, .packages=c('MASS','randomForest','neuralnet','gbm', 'sandwich', 'hdm', 'nnet', 'rpart','glmnet')) %dopar% { 
  set.seed(k+1);  
  dml <- DoubleML(data=data, y=y, d=d, z=z, xx=x, xL=xl, methods=methods, DML="DML2", nfold, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE, trim=NULL) 
  
}

end_time <- Sys.time()
time <- end_time - start_time

lasso_y = lasso_coeff(matrix_list_coeff = r_2b[, "lasso_y_coeff"], dep="y", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
lasso_d = lasso_coeff(matrix_list_coeff = r_2b[, "lasso_d_coeff"], dep="d", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
if(is.null(z)){lasso_z <- NA}else{lasso_z <- lasso_coeff(matrix_list_coeff = r_2b[, "lasso_z_coeff"], dep="z", split=split, nfold=nfold, output_coeff="pos", number_coeff=20)}
data_info <- list("n"=nrow(data),"p_col" = ncol(data), "y"= y, "d"=d, "x"=x, "xl"=xl, "methods"=methods, "time"= time, "split"=split, "nfold"=nfold, "original_2b"=original_2b)
lasso_coeff_2b <- list("lasso_y" = lasso_y, "lasso_d" = lasso_d, "lasso_z" = lasso_z)
r_2b <- r_2b[,"table"]
output_2b = output_p(r_2b, adj = T)
save(r_2b, output_2b, lasso_coeff_2b,  data_info, file = "taxes_t5D_c2b_output.RData")
print(output_2b[["output"]], include.rownames=FALSE, file=paste("TX_T1_PC_L2.txt"))
#stopCluster(cl)

# Line 3 Panel C ----------------------------------------------------------------
data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("nbusinessdensitycf", "effective_5yr", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_3b <- lm(nbusinessdensitycf~., data)

################################ Inputs ##############################

# Outcome Variable5
y <- "nbusinessdensitycf"


# list of treatment of Treatment Indicator

d <-"effective_5yr"

z <- NULL

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=" + ")

# use this for tree-based methods like forests and boosted trees

xl <- paste("(", x, ")^2", sep="") # use this for rlasso etc.

start_time <- Sys.time()

r_3b <- foreach(k = 1:split, .combine='rbind', .inorder=FALSE, .packages=c('MASS','randomForest','neuralnet','gbm', 'sandwich', 'hdm', 'nnet', 'rpart','glmnet')) %dopar% { 
  set.seed(k+1); 
  dml <- DoubleML(data=data, y=y, d=d, z=z, xx=x, xL=xl, methods=methods, DML="DML2", nfold, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE, trim=NULL) 
  
}

end_time <- Sys.time()
time <- end_time - start_time

lasso_y = lasso_coeff(matrix_list_coeff = r_3b[, "lasso_y_coeff"], dep="y", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
lasso_d = lasso_coeff(matrix_list_coeff = r_3b[, "lasso_d_coeff"], dep="d", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
if(is.null(z)){lasso_z <- NA}else{lasso_z <- lasso_coeff(matrix_list_coeff = r_3b[, "lasso_z_coeff"], dep="z", split=split, nfold=nfold, output_coeff="pos", number_coeff=20)}
data_info <- list("n"=nrow(data),"p_col" = ncol(data), "y"= y, "d"=d, "x"=x, "xl"=xl, "methods"=methods, "time"= time, "split"=split, "nfold"=nfold, "original_3b"=original_3b)
lasso_coeff_3b <- list("lasso_y" = lasso_y, "lasso_d" = lasso_d, "lasso_z" = lasso_z)
r_3b <- r_3b[,"table"]
output_3b = output_p(r_3b, adj = T)
save(r_3b, output_3b, lasso_coeff_3b,  data_info, file = "taxes_t5D_c3b_output.RData")
print(output_3b[["output"]], include.rownames=FALSE, file=paste("TX_T1_PC_L3.txt"))
stopCluster(cl)



