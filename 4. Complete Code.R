################################################################################
# This part of the code is for the Exploratory Data Analysis (EDA)
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

# Reading the data
covid2 <- read.csv("Data.csv", header = T)

# Removing the first two columns
covid2 <- covid2[-c(1,2)] 

#Renaming the columns (Variables)
names(covid2) <- c("TotalCases", "AQI", "Ozone", "PM2.5", "MeanTemp", 
                   "PopDensity")

head(covid2)
dim(covid2)
summary(covid2)


x11()

# Plotting a boxplot
boxplot(covid2, main = "Boxplot of variables") # It does not reveal much

# Plotting a scatterplot matrix
pairs(covid2, main = "Scatterplot Matrix")

#Check for correlation
corr.table <- cor(covid2)
cormat <- round(cor(covid2),4)
head(cormat)
ggcorrplot(cormat, hc.order = TRUE, type = "lower", lab = TRUE)

# Check for transformation requirement
# First, fit a first order linear model

mod1 <- lm(TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + PopDensity, 
           data = covid2)

# Check if residual vs fitted values have any sort of pattern
plot(x= mod1$fitted.values, y = mod1$residuals, pch = 20, 
     xlab = "Fitted Values", ylab= "Residual", 
     main = "Residual vs Fitted values - Preliminary model")
abline(h=0)

# It does have a fanning out pattern

# Check for appropriate transformation
boxcox(mod1)
# The lambda value obtained from boxcox is close to zero, so a log 
# transformation of the outcome variable is required

# Transforming the outcome variable
covid2$log.TotalCases <- log(covid2$TotalCases)
covid2 <- covid2[-c(1)]

# Fitting the simple first order linear model again
mod2 <- lm(log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + PopDensity, 
           data = covid2)
x11()
plot(x= mod2$fitted.values, y = mod1$residuals, pch = 20, 
     xlab = "Fitted Values", ylab= "Residual", 
     main = "Residual vs Fitted values - after Y transformation")
abline(h=0)
# It still shows some fanning out pattern

pairs(covid2, main = "Scatterplot Matrix after Y transformation")

#It reveals a non - linear association between PopDensity and log.TotalCases
# A log transformation of the PopDensity is required

covid2$log.PopDensity <- log(covid2$PopDensity)
covid2 <- covid2[-c(5)]

# Fitting the simple linear model again
mod3 <- lm(log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + log.PopDensity, 
           data = covid2)
x11()
plot(x= mod3$fitted.values, y = mod3$residuals, pch = 20, 
     xlab = "Fitted Values", ylab= "Residual", 
     main = "Residual vs Fitted values - after predictor transformation")
abline(h=0)
# The plot looks much better, the residual against fitted values are just noise

pairs(covid2, main = "Scatterplot Matrix after predictor transformation")


# Summary of outcome variable
# Histogram of outcome variable
p <- ggplot(covid2, aes(x=log.TotalCases)) +
  geom_histogram(binwidth = 0.12) +
  ggtitle ("Histogram of transformed Y variable")
print(p)

summary(covid2$log.TotalCases)
# Predictors and outcome

# log.PopDensity
p <- ggplot(data = covid2, mapping = aes(x=log.PopDensity, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(method = "lm", se= FALSE) +
  ggtitle ("Transformed Total Cases vs Transformed population Density")
print(p)

# Meantemp
p <- ggplot(data = covid2, mapping = aes(x=MeanTemp, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(method = "lm", se= FALSE) +
  ggtitle ("Transformed Total Cases vs Mean temperature")
print(p)

# PM2.5
p <- ggplot(data = covid2, mapping = aes(x=PM2.5, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(method = "lm", se= FALSE)+
  ggtitle ("Transformed Total Cases vs PM2.5")
print(p)  


# non-lm line
p <- ggplot(data = covid2, mapping = aes(x=PM2.5, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(se= FALSE)+
  ggtitle ("Transformed Total Cases vs PM2.5_nonLM")
print(p)



#Ozone
p <- ggplot(data = covid2, mapping = aes(x=Ozone, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(method = "lm", se= FALSE)+
  ggtitle ("Transformed Total Cases vs Ozone")
print(p)


#non-lm line
p <- ggplot(data = covid2, mapping = aes(x=Ozone, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(se= FALSE)+
  ggtitle ("Transformed Total Cases vs Ozone_nonLM")
print(p)



# AQI
p <- ggplot(data = covid2, mapping = aes(x=AQI, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(method = "lm", se= FALSE)+
  ggtitle ("Transformed Total Cases vs AQI")
print(p)


# non-lm line

p <- ggplot(data = covid2, mapping = aes(x=AQI, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(se= FALSE)+
  ggtitle ("Transformed Total Cases vs AQI_nonLM")
print(p)

############################################################################
############################################################################
#################### "Model Selection" Start here ###############################

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
#Call:
#  lm(formula = log.TotalCases ~ AQI + Ozone + PM2.5 + MeanTemp + 
#       log.PopDensity, data = train.dat)
#
#Residuals:
#  Min      1Q  Median      3Q     Max 
#-4.2620 -0.4718  0.0555  0.5156  2.5479 
#
#Coefficients:
#  Estimate Std. Error t value Pr(>|t|)    
#(Intercept)    -2.3656201  0.3873811  -6.107 2.70e-09 ***
#  AQI             0.0245129  0.0029549   8.296 2.34e-15 ***
#  Ozone           0.0010464  0.0005414   1.933   0.0541 .  
#PM2.5           0.0017128  0.0006662   2.571   0.0106 *  
#  MeanTemp        0.0704728  0.0056982  12.368  < 2e-16 ***
#  log.PopDensity  0.7584567  0.0285780  26.540  < 2e-16 ***
#  ---
#  Signif. codes:  0 â***â 0.001 â**â 0.01 â*â 0.05 â.â 0.1 â â 1
#
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
#1,2,3,4,5   1,3,4,5     1,4,5   1,2,4,5   2,3,4,5     3,4,5     2,4,5 
#0.781     0.779     0.778     0.777     0.739     0.713     0.709 
#4,5   1,2,3,5     1,3,5 
#0.703     0.686     0.686 

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
#########################################################################################
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
