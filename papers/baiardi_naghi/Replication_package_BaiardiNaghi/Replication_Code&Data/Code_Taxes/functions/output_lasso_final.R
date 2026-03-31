output_p <- function(r, x = data_info$x, n = data_info$n , adj = FALSE, one_p = TRUE){  
  library(stringr)
  library(xtable)
  library(matrixStats)
  library(gtools)
  r <- do.call("rbind", r)
  
  methods <- na.omit(str_extract(colnames(r), "^[^.]+$"))
  r <- r[,1:(2*length(methods))] #right dimensions to plot coefficients and standard errors
  methods <- methods[methods!="best"]
  result           <- matrix(0,5, length(methods)+1)
  colnames(result) <- cbind(t(methods), "best")
  rownames(result) <- cbind("Median ATE", "se(adj)",  "se(median)", "T-stat", "p-value")
  
  r <- data.matrix(r)
  
  result[1,]        <- colQuantiles(r[,1:(length(methods)+1)], probs=0.5)
  result[2,]        <- colQuantiles(sqrt(r[,(length(methods)+2):ncol(r)]^2+(r[,1:(length(methods)+1)] - colQuantiles(r[,1:(length(methods)+1)], probs=0.5))^2), probs=0.5)
  result[3,]        <- colQuantiles(r[,(length(methods)+2):ncol(r)], probs=0.5)
  
  
  if(adj == FALSE){
    result[4,] <- result[1,]/result[3,]
  }else{
    result[4,] <- result[1,]/result[2,]
  }
  
  no_controls = str_count(x, pattern = "\\+")+ 1
  
  p = no_controls + 1 
  
  if(one_p==FALSE){
    df <- n - p   
  }else{
    df <- n - 1 
  }
  
  result[5,] <- 2*pt(-abs(result[4,]),df=df) 
  
  result <- round(result, digits = 3)
  result_table <- result
  result_table[1,] <- paste(result_table[1,], stars.pval(result_table[5,]), sep="")
  result_table_n <- result_table
  
  for(i in 1:ncol(result_table)){
    for(j in seq(2,nrow(result_table),3)){
      
      result_table[j,i] <- paste("(", result_table[j,i], ")", sep="")
      
    }
    for(j in seq(3,nrow(result_table),3)){
      
      result_table[j,i] <- paste("(", result_table[j,i], ")", sep="")
      
    }
  }
  
  
  output <- list(result, xtable(result_table[1:3,]))
  return(list("table" = r, "output"=output))
}


lasso_coeff <-  function(matrix_list_coeff, dep="y", split=100, nfold=2, output_coeff="abs", number_coeff=20){
  library(Matrix) 
  library(xtable)
  if(dep=="y"){
    coeff_names <- "Y|X"
  }
  if(dep=="d"){
    coeff_names <- "D|X"
  }
  if(dep=="z"){
    coeff_names <- "Z|X"
  }
  
  coeff_sum_split <- list()
  coeff_sum <- 0
  for(i in 1:split){
    coeff_sum_split[[i]] <- 0
    for (j in 1:nfold){
      coeff_sum_split[[i]] <- coeff_sum_split[[i]] + matrix_list_coeff[[i]][[j]] 
    }
    coeff_sum <- coeff_sum + coeff_sum_split[[i]] 
  }
  coeff_sum <- coeff_sum/(split*nfold)
  names_var <- rownames(coeff_sum)
  if(is.null(names_var)){names_var <- names(coeff_sum)}
  coeff_sum <- matrix(coeff_sum, dimnames= list(names_var, coeff_names))
  coeff_sum <- round(coeff_sum, digit=3)
  coeff_sum <- data.frame(coeff_sum)
  coeff_sum_abs <- coeff_sum 
  coeff_sum_abs$abs <- abs(coeff_sum)
  coeff_sum_abs <-   coeff_sum_abs[order(coeff_sum_abs$abs, decreasing = T),]
  if(is.na(number_coeff)){
    coeff_sum_abs <- coeff_sum_abs
  }else{coeff_sum_abs <- coeff_sum_abs[1:number_coeff,]}   
  
  colnames(coeff_sum_abs) <- c(coeff_names, "abs")
  coeff_sum_p <- matrix(coeff_sum[coeff_sum!=0,], dimnames= list(names_var[coeff_sum!=0], coeff_names))
  all_p <- nrow(coeff_sum)
  nonzero_p <- length(coeff_sum_p)
  
  lasso_output <- list("coeff" = coeff_sum, "total_p"=all_p, "nonzero_p" = nonzero_p ) 
  lasso_output_p <- list("coeff" = coeff_sum_p, "total_p"=all_p, "nonzero_p" = nonzero_p ) 
  lasso_output_abs <- list("coeff" = coeff_sum_abs, "total_p"=all_p, "nonzero_p" = nonzero_p, "number_top" = number_coeff) 
  
  if(output_coeff=="abs"){return(lasso_output_abs)}else(if(output_coeff=="all"){return(lasso_output)}else(return(lasso_output_p)))
}
