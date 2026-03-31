# The program below uses code from
# References: "Double/Debiased Machine Learning of Treatment and Causal Parameters",  AER P&P 2017     
#             "Double Machine Learning for Treatment and Causal Parameters",  Arxiv 2016 

# This empirical example uses the data from Djankov, Simeon, et al. "The effect of corporate taxes on investment and entrepreneurship." American Economic Journal: Macroeconomics 2.3 (2010): 31-64..
#######################################################################################################################################################
#install.packages("ggplot2")
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
library(ggplot2)
rm(list = ls()) 

###################### Loading functions and Data ##############################

setwd("Replication_package_BaiardiNaghi/Replication_Code&Data/Code_Taxes")
source("functions/ML_Functions_01.R")
source("functions/Moment_Functions_02.R")
source("functions/output_lasso_final.R")


options(warn=-1)
set.seed(12);
cl <- makeCluster(15)
registerDoParallel(cl)

# Method names: Boosting, Nnet, RLasso, PostRLasso, Forest, Trees, Ridge, Lasso, Elnet, Ensemble

Boosting     <- list(n.minobsinnode = 1, bag.fraction = .8, train.fraction = 1.0, interaction.depth=2, n.trees=1000, shrinkage=.01, n.cores=1, cv.folds=2, verbose = FALSE, clas_dist= 'adaboost', reg_dist='gaussian')
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


# Line 1 Panel D ----------------------------------------------------------------
data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("nentryrateav", "statutory", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_4b <- lm(nentryrateav~., data)

################################ Inputs ##############################

# Outcome Variable5
y <- "nentryrateav"


# list of treatment of Treatment Indicator

d <-"statutory"

z <- NULL

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=" + ")

# use this for tree-based methods like forests and boosted trees

xl <- paste("(", x, ")^2", sep="") # use this for rlasso etc.

start_time <- Sys.time()

r_4b <- foreach(k = 1:split, .combine='rbind', .inorder=FALSE, .packages=c('MASS','randomForest','neuralnet','gbm', 'sandwich', 'hdm', 'nnet', 'rpart','glmnet')) %dopar% { 
  set.seed(k+123); 
  dml <- DoubleML(data=data, y=y, d=d, z=z, xx=x, xL=xl, methods=methods, DML="DML2", nfold, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE, trim=NULL) 
  
}

end_time <- Sys.time()
time <- end_time - start_time

lasso_y = lasso_coeff(matrix_list_coeff = r_4b[, "lasso_y_coeff"], dep="y", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
lasso_d = lasso_coeff(matrix_list_coeff = r_4b[, "lasso_d_coeff"], dep="d", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
if(is.null(z)){lasso_z <- NA}else{lasso_z <- lasso_coeff(matrix_list_coeff = r_4b[, "lasso_z_coeff"], dep="z", split=split, nfold=nfold, output_coeff="pos", number_coeff=20)}
data_info <- list("n"=nrow(data),"p_col" = ncol(data), "y"= y, "d"=d, "x"=x, "xl"=xl, "methods"=methods, "time"= time, "split"=split, "nfold"=nfold, "original_4b"=original_4b)
lasso_coeff_4b <- list("lasso_y" = lasso_y, "lasso_d" = lasso_d, "lasso_z" = lasso_z)
r_4b <- r_4b[,"table"]
output_4b = output_p(r_4b, adj = T)
save(r_4b, output_4b, lasso_coeff_4b,  data_info, file = "taxes_t5D_c4b_output.RData")
print(output_4b[["output"]], include.rownames=FALSE, file=paste("TX_T1_PD_L1.txt"))

Names <- c("lnpayments2004", "sb_proc2004", "seign2004", "other_taxes", "emplo_i2004", "inf10yearavg", "pit2004", "propertyrights", "vatsales", "index_gcr", "lngdppc2003", "freedomtotradeinternationally")
Column1 <- lasso_coeff_4b$lasso_y$coeff[Names, ]$'Y|X'
Column2 <- lasso_coeff_4b$lasso_d$coeff[Names, ]$'D|X'
capture.output(cbind(Names, Column1, Column2), file=paste("TX_S1.txt"))

names_Figure1 <- c("lnpayments2004:lngdppc2003", "lnpayments2004:sb_proc2004", "pit2004:lnpayments2004", "lnpayments2004:propertyrights", "vatsales:freedomtotradeinternationally")
names_Figure2 <- c("freedomtotradeinternationally:index_gcr", "lnpayments2004:index_gcr", "lnpayments2004:sb_proc2004", "sb_proc2004:index_gcr", "lnpayments2004:lngdppc2003")
figure1 <- lasso_coeff_4b$lasso_d$coeff[names_Figure1, ]$'D|X'
figure2 <- lasso_coeff_4b$lasso_y$coeff[names_Figure2, ]$'Y|X'

apa_theme <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(text = element_text(family = "Times New Roman"),
          plot.title = element_text(face = "bold"),
          axis.title = element_text(face = "bold"),
          panel.grid.major = element_line(colour = "gray70"),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          legend.title = element_blank(),
          legend.position = "bottom",
          legend.key.size = unit(0.5, "cm"),
          legend.text = element_text(size = rel(0.8)),
          plot.margin = unit(c(1, 1, 1, 2), "lines"))
}


names_Figure1_factor <- factor(names_Figure1, levels = rev(names_Figure1))
plot_data1 <- data.frame(y = names_Figure1_factor, x = figure1)
ggplot(plot_data1, aes(x = 0, y = y)) +
  geom_segment(aes(xend = x, yend = y), size = 1.5) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(title = "", x = "", y = "") +
  theme_minimal() +
  scale_color_manual(values = c("lines" = "black")) +
  apa_theme()
ggsave("TX_S1.1.png", width = 8, height = 6, units = "in", dpi = 300)


names_Figure2_factor <- factor(names_Figure2, levels = rev(names_Figure2))
plot_data2 <- data.frame(y = names_Figure2_factor, x = figure2)
ggplot(plot_data2, aes(x = 0, y = y)) +
  geom_segment(aes(xend = x, yend = y), size = 1.5) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(title = "", x = "", y = "") +
  theme_minimal() +
  scale_color_manual(values = c("lines" = "black")) +
  apa_theme()
ggsave("TX_S1.2.png", width = 8, height = 6, units = "in", dpi = 300)


#stopCluster(cl)

# Line 2 Panel D ----------------------------------------------------------------
data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("nentryrateav", "effective", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_5b <- lm(nentryrateav~., data)

################################ Inputs ##############################

# Outcome Variable
y <- "nentryrateav"


# list of treatment of Treatment Indicator

d <-"effective"

z <- NULL

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=" + ")

# use this for tree-based methods like forests and boosted trees

xl <- paste("(", x, ")^2", sep="") # use this for rlasso etc.

start_time <- Sys.time()

r_5b <- foreach(k = 1:split, .combine='rbind', .inorder=FALSE, .packages=c('MASS','randomForest','neuralnet','gbm', 'sandwich', 'hdm', 'nnet', 'rpart','glmnet')) %dopar% { 
  set.seed(k+123); 
  dml <- DoubleML(data=data, y=y, d=d, z=z, xx=x, xL=xl, methods=methods, DML="DML2", nfold, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE, trim=NULL) 
  
}

end_time <- Sys.time()
time <- end_time - start_time

lasso_y = lasso_coeff(matrix_list_coeff = r_5b[, "lasso_y_coeff"], dep="y", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
lasso_d = lasso_coeff(matrix_list_coeff = r_5b[, "lasso_d_coeff"], dep="d", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
if(is.null(z)){lasso_z <- NA}else{lasso_z <- lasso_coeff(matrix_list_coeff = r_5b[, "lasso_z_coeff"], dep="z", split=split, nfold=nfold, output_coeff="pos", number_coeff=20)}
data_info <- list("n"=nrow(data),"p_col" = ncol(data), "y"= y, "d"=d, "x"=x, "xl"=xl, "methods"=methods, "time"= time, "split"=split, "nfold"=nfold, "original_5b"=original_5b)
lasso_coeff_5b <- list("lasso_y" = lasso_y, "lasso_d" = lasso_d, "lasso_z" = lasso_z)
r_5b <- r_5b[,"table"]
output_5b = output_p(r_5b, adj = T)
save(r_5b, output_5b, lasso_coeff_5b,  data_info, file = "taxes_t5D_c5b_output.RData")
print(output_5b[["output"]], include.rownames=FALSE, file=paste("TX_T1_PD_L2.txt"))
#stopCluster(cl)

#Line 3 Panel D ----------------------------------------------------------------
data <- read.dta("../Data/data_taxes.dta")
data <- data[,c("nentryrateav", "effective_5yr", "other_taxes","vatsales", "pit2004", "lnpayments2004", "lngdppc2003","propertyrights", "sb_proc2004", "emplo_i2004", "freedomtotradeinternationally", "seign2004", "inf10yearavg","index_gcr")] 
data <- na.omit(data)
original_6b <- lm(nentryrateav~., data)

################################ Inputs ##############################

# Outcome Variable5
y <- "nentryrateav"


# list of treatment of Treatment Indicator

d <-"effective_5yr"

z <- NULL

# Controls
x <- paste(colnames(data[,!colnames(data)%in% c(y,d)]), collapse=" + ")

# use this for tree-based methods like forests and boosted trees

xl <- paste("(", x, ")^2", sep="") # use this for rlasso etc.

start_time <- Sys.time()

r_6b <- foreach(k = 1:split, .combine='rbind', .inorder=FALSE, .packages=c('MASS','randomForest','neuralnet','gbm', 'sandwich', 'hdm', 'nnet', 'rpart','glmnet')) %dopar% { 
  set.seed(k+123);  
  dml <- DoubleML(data=data, y=y, d=d, z=z, xx=x, xL=xl, methods=methods, DML="DML2", nfold, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE, trim=NULL) 
  
}

end_time <- Sys.time()
time <- end_time - start_time

lasso_y = lasso_coeff(matrix_list_coeff = r_6b[, "lasso_y_coeff"], dep="y", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
lasso_d = lasso_coeff(matrix_list_coeff = r_6b[, "lasso_d_coeff"], dep="d", split=split, nfold=nfold, output_coeff="abs", number_coeff=NA)
if(is.null(z)){lasso_z <- NA}else{lasso_z <- lasso_coeff(matrix_list_coeff = r_6b[, "lasso_z_coeff"], dep="z", split=split, nfold=nfold, output_coeff="pos", number_coeff=20)}
data_info <- list("n"=nrow(data),"p_col" = ncol(data), "y"= y, "d"=d, "x"=x, "xl"=xl, "methods"=methods, "time"= time, "split"=split, "nfold"=nfold, "original_6b"=original_6b)
lasso_coeff_6b <- list("lasso_y" = lasso_y, "lasso_d" = lasso_d, "lasso_z" = lasso_z)
r_6b <- r_6b[,"table"]
output_6b = output_p(r_6b, adj = T)
save(r_6b, output_6b, lasso_coeff_6b,  data_info, file = "taxes_t5D_c6b_output.RData")
print(output_6b[["output"]], include.rownames=FALSE, file=paste("TX_T1_PD_L3.txt"))
stopCluster(cl)



