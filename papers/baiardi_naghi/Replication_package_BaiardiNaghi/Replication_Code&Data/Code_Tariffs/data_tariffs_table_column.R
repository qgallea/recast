## Replace the following lines of code, depending on what Table and Column of 
## the Tariffs application you want to obtain the results for

####################
# Table 2 Panel A #
####################
data <- data.raw[which(data.raw$industry=="211212"),]
controls <- c("avg_tar", "init", "inv", "human_cap", "w_africa", "e_africa", "s_c_africa",
              "n_afr_me", "e_europe", "lat_america", "e_asia", "s_e_asia", "s_w_asia",
              "dum80_83", "dum85_87", "ln_init_q_skilla", "ln_init_q_unskilla") 
y <- "growth"
d <- "skill1_corr"


####################
# Table 2 Panel B #
####################
data <- data.raw[which(data.raw$industry=="211212"),]
controls <- c("avg_tar", "init", "inv", "human_cap", "w_africa", "e_africa", "s_c_africa",
              "n_afr_me", "e_europe", "lat_america", "e_asia", "s_e_asia", "s_w_asia",
              "dum80_83", "dum85_87", "ln_init_q_skilla", "ln_init_q_unskilla") 
y <- "growth"
d <- "diffa"


####################
# Table 2 Panel C #
####################
data <- data.raw[which(data.raw$industry=="211212"),]
controls <- c("avg_tar", "init", "inv", "human_cap", "w_africa", "e_africa", "s_c_africa",
              "n_afr_me", "e_europe", "lat_america", "e_asia", "s_e_asia", "s_w_asia",
              "dum80_83", "dum85_87", "ln_init_q_skilla", "ln_init_q_unskilla") 
y <- "growth"
d <- "diffg"


####################
# Table S3.3 Panel A#
####################

data <- data.raw
controls <- c("avg_tar", "init", "ln_init_q", "inv", "human_cap",
              "w_africa", "e_africa", "s_c_africa", "n_afr_me", "lat_america",
              "e_asia", "s_e_asia", "s_w_asia", "e_europe", "dum80_83", "dum85_87",
              "ln_init_q_skilla", "ln_init_q_unskilla")
y <- "prod_growth"
d <- "skill1_corr"


####################
# Table S3.3 Panel B #
####################

data <- data.raw
controls <- c("avg_tar", "init", "ln_init_q", "inv", "human_cap",
              "w_africa", "e_africa", "s_c_africa", "n_afr_me", "lat_america",
              "e_asia", "s_e_asia", "s_w_asia", "e_europe", "dum80_83", "dum85_87",
              "ln_init_q_skilla", "ln_init_q_unskilla")
y <- "prod_growth"
d <- "diffa"

####################
# Table S3.3 Panel C #
####################

data <- data.raw
controls <- c("avg_tar", "init", "ln_init_q", "inv", "human_cap",
              "w_africa", "e_africa", "s_c_africa", "n_afr_me", "lat_america",
              "e_asia", "s_e_asia", "s_w_asia", "e_europe", "dum80_83", "dum85_87",
              "ln_init_q_skilla", "ln_init_q_unskilla")
y <- "prod_growth"
d <- "diffg"


####################
# Table S3.4 Panel A #
####################

data <- data.raw
controls <- c("avg_tar", "init_tar", "ln_init_q", "init", "inv", "human_cap",
              "w_africa", "e_africa", "s_c_africa", "n_afr_me", "lat_america",
              "e_asia", "s_e_asia", "s_w_asia", "e_europe", "dum80_83", "dum85_87",
              "ln_init_q_skilla", "ln_init_q_unskilla")
y <- "prod_growth"
d <- "skill1_corr"


####################
# Table S3.4 Panel B #
####################

data <- data.raw
controls <- c("avg_tar", "init_tar", "ln_init_q", "init", "inv", "human_cap",
              "w_africa", "e_africa", "s_c_africa", "n_afr_me", "lat_america",
              "e_asia", "s_e_asia", "s_w_asia", "e_europe", "dum80_83", "dum85_87",
              "ln_init_q_skilla", "ln_init_q_unskilla")
y <- "prod_growth"
d <- "diffa"


####################
# Table S3.4 Panel C#
####################

data <- data.raw
controls <- c("avg_tar", "init_tar", "ln_init_q", "init", "inv", "human_cap",
              "w_africa", "e_africa", "s_c_africa", "n_afr_me", "lat_america",
              "e_asia", "s_e_asia", "s_w_asia", "e_europe", "dum80_83", "dum85_87",
              "ln_init_q_skilla", "ln_init_q_unskilla")
y <- "prod_growth"
d <- "diffg"
