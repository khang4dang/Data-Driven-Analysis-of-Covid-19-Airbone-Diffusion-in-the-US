################################################################################
# This code is the continuation from EDA. The Whole code can be found as "Complete Code" 
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

# Fitting the multiple linear model for the training set
mod4 <- lm(log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + log.PopDensity, 
           data = train.dat)
summary(mod4)

#############################################################################
# Call:
#  lm(formula = log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + 
#       log.PopDensity, data = train.dat)
#
# Residuals:
#  Min      1Q  Median      3Q     Max 
#-4.2620 -0.4718  0.0555  0.5156  2.5479 
#
# Coefficients:
#  Estimate Std. Error t value Pr(>|t|)    
#(Intercept)    -2.3656201  0.3873811  -6.107 2.70e-09 ***
# AQI             0.0245129  0.0029549   8.296 2.34e-15 ***
# Ozone           0.0010464  0.0005414   1.933   0.0541 .  
# PM2.5           0.0017128  0.0006662   2.571   0.0106 *  
# MeanTemp        0.0704728  0.0056982  12.368  < 2e-16 ***
# log.PopDensity  0.7584567  0.0285780  26.540  < 2e-16 ***
#  ---
#Residual standard error: 0.8347 on 351 degrees of freedom
#Multiple R-squared:  0.7841,	Adjusted R-squared:  0.781 
#F-statistic: 254.9 on 5 and 351 DF,  p-value: < 2.2e-16
###############################################################################
## From the summary we see that Ozone is not as significant as the other 
# predictors. Let us check for model selection using Adjusted R^2, AIC and BIC

# Next, it is to be determined, whether all the predictor variables are required
# or a subset of them are adequate.
#############################################################################

x.mat <- model.matrix(mod4) [,-1] # Ignoring the intercept column
checks <- leaps(x.mat, train.dat$log.TotalCases, method = "adjr2")
maxadjr(checks,best = 10) 
# 1,2,3,4,5   1,3,4,5     1,4,5   1,2,4,5   2,3,4,5     3,4,5     2,4,5 
#   0.781     0.779      0.778    0.777     0.739      0.713     0.709 
# 4,5    1,2,3,5     1,3,5 
# 0.703   0.686      0.686 

# it indicates the linear model is best fitted with Mean temp and log.PopDensity
# as predictors. Including AQI is also reasonable.

# Let's check for the best subset of predictors using AIC

# Null model
null <- lm(log.TotalCases ~ 1, data = train.dat)
summary(null)

# Full model
full <- mod4

## Forward selection
stepAIC(null, scope=list(lower=null,upper = full), direction = "forward",
        trace = FALSE)
# It indicates including all of the predictors in the model

# Backward selection
stepAIC(full, scope=list(lower=null,upper = full), direction = "backward",
        trace = FALSE)
# It also indicates including all of the predictors

# Stepwise selection
stepAIC(full, scope=list(lower=null,upper = full), direction = "both",
        trace = FALSE)
# Results are same as backward selection.

# BIC method 
all.subsets <- regsubsets(log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp 
                          + log.PopDensity, data = train.dat)
summary(all.subsets)
summary(all.subsets)$bic
#          AQI Ozone PM2.5 MeanTemp log.PopDensity
# 1  ( 1 ) " " " "   " "   " "      "*"           
# 2  ( 1 ) " " " "   " "   "*"      "*"           
# 3  ( 1 ) "*" " "   " "   "*"      "*"           
# 4  ( 1 ) "*" " "   "*"   "*"      "*"           
# 5  ( 1 ) "*" "*"   "*"   "*"      "*"           

# [1] -295.3605 -418.2600 -516.8719 -514.0246 -511.9265
# BIC prefers the simplest model with only log.PopDensity

# So we have three competing models
mod5 <- glm(log.TotalCases ~ log.PopDensity, data = train.dat)
mod6 <- glm(log.TotalCases ~ log.PopDensity + MeanTemp, data = train.dat)
mod7 <- glm(log.TotalCases ~ ., data = train.dat)

# LOOCV for training data
loo.cv1 <- cv.glm(train.dat, mod5)
loo.cv1$delta # 1.359231 1.359206
loo.cv2 <- cv.glm(train.dat, mod6)
loo.cv2$delta # 0.9517107 0.9516880
loo.cv3 <- cv.glm(train.dat, mod7)
loo.cv3$delta # 0.7138609 0.7138198

# from the results of LOOCV on the training set, we take model 6 and model 7 to 
# provide better results

# 5-fold cross validation
cv.error5_3 <- cv.glm(train.dat, mod5, K= 5)
cv.error5_3$delta
# 1.353713 1.352404

# 5-fold cross validation
cv.error5_1 <- cv.glm(train.dat, mod6, K= 5)
cv.error5_1$delta
# 0.9421105 0.9413930

cv.error5_2 <- cv.glm(train.dat,mod7, K=5)
cv.error5_2$delta
# 0.7159521 0.7124585

# The results indicate that model 7, that includes all the predictors, results 
# in less predictive error and hence, we should go forward with this model. 

# Estimate a multiple linear regression model with 'log.TotalCases' as the response
# and all other variables as predictors.
mod7_lm <- lm(log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + log.PopDensity, 
            data = train.dat)
summary(mod7_lm)
# The adjusted R-squared = 0.781 with all the predictors included 
# in the prediction model shows that 78.1%  of the variance 
# in the measure of "log.TotalCases" can be predicted by all the predictors


# We now calculate Mean Squared Predictive error on the test data, based on
# model mod 7

pred.mod1 <- predict(mod7_lm, newdata = test.dat[, c(1,2,3,4,6)])

y.new <- test.dat$log.TotalCases

MSPE1 <- mean((y.new - pred.mod1)^2) # 0.6178


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

predict(mod7_lm, predict.data, type="response")
#        1        2        3 
#     8.004403 8.850271 8.014841
