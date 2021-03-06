rm(list = ls())

require(deSolve)   
require(rootSolve)
require(FME)
require(ggplot2)
#setwd("C:/Users/fortinlab/Dropbox/Courses/2016-2017/EEB1451 - Disease in Communities/Term_paper")
###################TABLE OF CONTENTS

###[1] Setting up the model
###[2] Running model

################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
### [1] Setting up the model

##### Model description  #####
SISmodel=function(t,y,parameters) 
{ 
  ## Variables
  S=y[1]; I=y[2]; E=y[3];
  
  ## Parameters
  p = parameters[1];
  K = parameters[2];
  beta = parameters[3];
  mu = parameters[4];
  alpha = parameters[5];
  lambda = parameters[6];
  tau = parameters[7]  
  
  ## Ordinary differential equations
  logistic_growth <- (1 - (S + I)/K)
  dSdt <- p*(S+I)*logistic_growth - beta*S*E - S * mu
  dIdt <- beta*S*E - I * alpha - I * mu
  dEdt <- lambda * I - tau * E
  
  return(list(c(dSdt,
                dIdt,
                dEdt))); 
}  

###Paramater values (expect p and beta because that's what we're testing)
K <- 5000
mu <- 0.02
alpha <- 0.2
lambda <- 0.01
tau <- 0.2

## Initial state
variables0=c(S0=100,I0=1,E0=10)

################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
### [2] Relationship between p and beta

#Looping to get range of beta values
Beta_values <- seq(0.001, 0.1, by = 0.001)
Suscep_num <- NULL
Infect_num <- NULL
Environ_num <- NULL

#constant describing relationship to beta
p_constant <- 1/2

beta_exp <- 1


for (i in Beta_values){
       beta <- i
       p = p_constant*(beta^beta_exp)
       
       parameters=c(p,
               K,
               beta,
               mu,
               alpha,
               lambda,
               tau)
       
       steadyState=runsteady(y = variables0, 
                      fun = SISmodel, 
                      parms = parameters)
       
       Suscep <- steadyState$y[1]
       Suscep_num <- append(Suscep_num, Suscep)
       
       Infect <- steadyState$y[2]
       Infect_num <- append(Infect_num, Infect)
       
       Environ <- steadyState$y[3]
       Environ_num <- append(Environ_num, Environ)
       
       }
  
#Getting data into dataframe for plotting - figure out how to do in one line
tempdf <- cbind(Beta_values, Suscep_num, Infect_num, Environ_num)
Linear_data <- as.data.frame(tempdf, row.names = T)

#Finding optimal beta value for susceptibles
Opt.row <- which(Linear_data$Suscep_num == max(Linear_data$Suscep_num), arr.ind=TRUE)
Opt.beta.value <- Linear_data$Beta_values[Opt.row]

Opt.Infect.beta <- which(Linear_data$Infect_num == max(Linear_data$Infect_num), arr.ind=TRUE)
Opt.Infect.beta <- Linear_data$Beta_values[Opt.Infect.beta]
#View(Linear_data)

#Building plot with data
plot_title <- paste0("Population at equilibrium, Opt. beta = ", Opt.beta.value, ", alpha =", alpha, ", mu =", mu, ", p constant = ", p_constant, ", beta^", beta_exp)
plot_title

Linear_plot <- ggplot(Linear_data, aes(Beta_values)) +
  geom_line(aes(y = Suscep_num, colour = "Susceptibles")) + 
  geom_line(aes(y = Infect_num, colour = "Infecteds")) +
  geom_line(aes(y = Environ_num, colour = "Environmental parasites")) +
  labs(title = plot_title, x = "Beta values", y = "Population size")

#Setting theme for plot
Linear_plot + theme(
  plot.title = element_text(size = 16), 
  axis.text = element_text(size = 16),
  axis.title = element_text(size = 16),
  axis.line = element_line("black"),
  legend.title = element_blank(),
  panel.background = element_blank()
  )

ggsave(paste0("./plots/SI_env_transmission/", plot_title, ".png"), width = 10, height = 6)


######################################################################################################
######################################################################################################
######################################################################################################
######################################################################################################
