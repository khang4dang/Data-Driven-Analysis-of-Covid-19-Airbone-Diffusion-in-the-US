################################################################################
# This code is the continuation from Model Selection. The Whole code can be found as "Complete Code" 
rm(list=ls()) # Clear existing data and variables from the Global Environment

# Include the libraries (some of these will be needed at a later 
#                       stage of the project)

library(leaps) #all subsets
library(faraway) #this will be used to check adjusted r square
library(MASS) #this has the step AIC function
library(boot) #contains tools to do cross validation
library(caret) 
library(glmnet) 
library(data.table)
library(ggplot2)
library(ggcorrplot)
library(reshape2)#for correlation heat matrix

set.seed(42)
## We found from EDA that mod3 was the multiple linear regression model
## We had moderate linear relation with the most significant predictors 

## Now we split the data intro training and testing set
sample <- sample.int(n = nrow(covid2), size = floor(.8*nrow(covid2)),
                     replace = F)
train.dat <- covid2[sample, ]
test.dat  <- covid2[-sample, ]
###################################################################################################################
# Generalized Additive Models
# Load libraries
library(nlme)
library(mgcv)
# We first started with the standard linear regression model (SLiM) approach
mod_gam_lm <- gam(log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + 
                    log.PopDensity, data=train.dat)
summary(mod_gam_lm)
#Family: gaussian 
#Link function: identity 
#Formula:
#  log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + log.PopDensity
#Parametric coefficients:
#  Estimate Std. Error t value Pr(>|t|)    
#(Intercept)    -2.3791976  0.3708128  -6.416 4.53e-10 ***
#  AQI             0.0258730  0.0028627   9.038  < 2e-16 ***
#  Ozone           0.0012662  0.0005039   2.513  0.01243 *  
#  PM2.5           0.0017415  0.0006360   2.738  0.00649 ** 
#  MeanTemp        0.0696461  0.0053937  12.913  < 2e-16 ***
#  log.PopDensity  0.7469352  0.0272076  27.453  < 2e-16 ***
#  ---
#R-sq.(adj) =  0.793   Deviance explained = 79.6%
#GCV = 0.66806  Scale est. = 0.65683   n = 357
mod_gam <- gam(log.TotalCases ~ s(AQI) + s(Ozone) + s(PM2.5) + s(MeanTemp)
               + s(log.PopDensity), data=train.dat)
summary(mod_gam)
#Family: gaussian 
#Link function: identity 
#Formula:
#  log.TotalCases ~ s(AQI) + s(Ozone) + s(PM2.5) + s(MeanTemp) + 
#  s(log.PopDensity)
#Parametric coefficients:
#  Estimate Std. Error t value Pr(>|t|)    
#(Intercept)  7.86768    0.03915     201   <2e-16 ***
#  ---
#Approximate significance of smooth terms:
#  edf Ref.df       F  p-value    
#s(AQI)            3.860  4.802  23.100  < 2e-16 ***
#  s(Ozone)          1.000  1.000  13.136 0.000333 ***
#  s(PM2.5)          4.676  5.660   4.728 0.000253 ***
#  s(MeanTemp)       7.821  8.619  23.394  < 2e-16 ***
#  s(log.PopDensity) 3.864  4.844 144.689  < 2e-16 ***
#  ---
#R-sq.(adj) =  0.827   Deviance explained = 83.8%
#GCV = 0.58355  Scale est. = 0.54723   n = 357

# Model comparison
anova(mod_gam_lm, mod_gam, test="Chisq")
#Analysis of Deviance Table
#Model 1: log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + log.PopDensity
#Model 2: log.TotalCases ~ s(AQI) + s(Ozone) + s(PM2.5) + s(MeanTemp) + 
#  s(log.PopDensity)
#Resid. Df Resid. Dev     Df Deviance  Pr(>Chi)    
#1    351.00     230.55                              
#2    331.08     183.20 19.925   47.348 2.817e-10 ***
#  ---
# We have three competing models
mod_gam1 <- gam(log.TotalCases ~ s(log.PopDensity), data=train.dat)
mod_gam2 <- gam(log.TotalCases ~ s(log.PopDensity) + s(MeanTemp),
                data=train.dat)
mod_gam3 <- gam(log.TotalCases ~ s(AQI) + s(Ozone) + s(PM2.5) + s(MeanTemp)
               + s(log.PopDensity), data=train.dat)

# LOOCV for training data
loo.cv1 <- cv.glm(train.dat, mod_gam1)
loo.cv1$delta # 1.245176 1.245052
loo.cv2 <- cv.glm(train.dat, mod_gam2)
loo.cv2$delta # 0.8855844 0.8863736
loo.cv3 <- cv.glm(train.dat, mod_gam3)
loo.cv3$delta # 0.6258556 0.6200710

# 5-fold cross validation
cv.error5_1 <- cv.glm(train.dat, mod_gam1, K= 5)
cv.error5_1$delta
# 1.250825 1.240288

# 5-fold cross validation
cv.error5_2 <- cv.glm(train.dat, mod_gam2, K= 5)
cv.error5_2$delta
# 0.8800074 0.8768801

cv.error5_3 <- cv.glm(train.dat, mod_gam3, K=5)
cv.error5_3$delta
# 0.6213970 0.5887481

# The results indicate that model 3, that includes all the predictors, results 
# in less predictive error and hence, we should go forward with this model. 

# Estimate a multiple linear regression model with 'log.TotalCases' as the response
# and all other variables as predictors.
mod_gam3 <- gam(log.TotalCases ~ s(AQI) + s(Ozone) + s(PM2.5) + s(MeanTemp)
                + s(log.PopDensity), data=train.dat)
summary(mod_gam3)
# The adjusted R-squared = 0.781 with all the predictors included 
# in the prediction model shows that 78.1%  of the variance 
# in the measure of "log.TotalCases" can be predicted by all the predictors


# We now calculate Mean Squared Predictive error on the test data, based on
# model mod 7

pred.mod2 <- predict(mod_gam3, newdata = test.dat[, c(1,2,3,4,6)])

y.new <- test.dat$log.TotalCases

MSPE1 <- mean((y.new - pred.mod2)^2) # 0.7439

## Prediction of three cases based on the trained model
# For the prediction of three cases, we used three SC counties
# Anderson, Greenville, and Pickens

#              AQI     Ozone     PM2.5     MeanTemp      PopDensity
# Anderson     67      225         0        61.42          261.6
# Greenville   67      234        127       61.33          574.7
# Pickens     59.8     251        21        59.83          240.2

# Feeding the data into a data frame
predict.data <- data.frame(AQI=c(67,67,71), Ozone=c(225,234,251), 
                           PM2.5=c(0,127,21), MeanTemp=c(61.4,61.3,59.8),
                           PopDensity=c(261.6,547.7,240.2))
predict.data$log.PopDensity <- log(predict.data$PopDensity)
predict.data <- predict.data[-c(5)] 

predict(mod_gam3, predict.data, type="response")
#         1         2         3 
#     7.800852  8.762426  7.944883
