# TODO 
# Set working directory to file location
setwd("Replication_package_BaiardiNaghi/Replication_Code&Data/MonteCarlo")


# Main file for generating one MC simulation 
# The output is a set of estimates for all the methods specified below and 
# it is written into a CSV file which is later aggregated with other MC simulations

rm(list = ls())
options(warn=-1)

library(MASS) # for drawing from multivariate normal distribution
library(scales)
library(tictoc)
library(BBmisc)
#install.packages("snow")
source("tools.r") # Contains the DGP function 
source("MomentEstimation.r")  
source("MLestimators.r")
source("MonteCarloDML.r")


############################# Parameters #######################################
theta <- 2 # Parameter in DGP; Change k, n, M and iter as desired

# load in files obtained from Lisa
k = 20
n = 100  #sample size

# Number of Simulations
M <- 100     #set to 5 for a quick run, change the value to increase the number of simulation repetitions

# Number of splits
iter <- 10

y <- c("y.PLR")
d <- c("gamma.PLR")

methods <- c("Lasso", "Tree", "Boosting", "Forest", "Nnet", "Elnet")

 dgp='linear'
# dgp='nonlinear' # Use this for the nonlinear DGPs

error.cov.dist = 'normal'
# error.cov.dist = 'uniform'

results.PLR <- matrix(NA, M , length(methods)+1)

for(i in 1:M){
  cat(paste0('Starting iteration ', i, '\n'))
  # Data Generating Process 
  set.seed(i) 
  data <- generate.data(k, n, theta, dgp, error.cov.dist)
  input.y <- as.matrix(data[, y])
  input.d <- as.matrix(data[, d])
  input.x <- data[, !colnames(data) %in% c(y, d)]
  
  colnames(input.y) <- y
  colnames(input.d) <- d
  
  # Estimation
  results.dml <- mcdml(y = input.y, d = input.d, x = input.x, niterations=iter, methods=methods)
  results.ols <- summary(lm(input.y ~ input.d + input.x))$coefficients[2,1]
  results.PLR[i, 1] <- as.numeric(results.ols)
  results.PLR[i, 2:(length(methods) + 1)] <- as.numeric(results.dml[1, 1:length(methods)])
}

colnames(results.PLR) <- c('OLS', methods)

makeTable <- function(results) {
  
  result_table <- matrix(NA, 5, length(methods)+1)
  colnames(result_table) <- c('OLS', methods)
  rownames(result_table) <- c("Mean", "MAE", "Var", "MSE","OLS hitrate")
  
  # calculate mean, median, variance and MSE
  result_table[1,] <- colMeans(results)
  result_table[2,] <- colMedians(abs(theta - results))
  result_table[3,] <- colVars(results)
  result_table[4,] <- colMeans((theta - results)^2)
  
  # calculate hitrate
  rOLS <- abs(theta - results[, "OLS"])
  for (method in methods) {
    rMeth <- abs(theta - results[,method])
    result_table[5,method] <- sum(rOLS < rMeth) / length(rOLS)
  }
  
  tbl = t(result_table)
  
  orders <- c('OLS', 'Lasso', 'Tree', 'Boosting', 'Forest', 'Nnet', 'Elnet')
  return(tbl[orders, ])
}

makeTable(results.PLR)

# save results
library(xtable)
print(xtable(makeTable(results.PLR), type="latex", digits=6),
      file=paste("2PLR_n", n, "_sim", M, "_k", k, "_", dgp, "_", error.cov.dist, ".txt",sep=""))
