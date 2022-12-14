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
library(boot) 
library(data.table)
library(ggplot2)
library(ggcorrplot)
library(reshape2)#for correlation heat matrix

set.seed(42)

# Reading the data
covid2 <- read.csv("Data.csv", header = T)

# CLEAN DATA

# Since we don't have enough data for Wind Speed and Relative Humidity
# We will drop out the columns "Wind.Speed" and "Mean.Relative.Humidity"
# And we also remove the first two columns of "State" and "County"
# Then we only keep 6 columns, corresponding to 6 variables
covid2 <- covid2[-c(1,2,8,9)] 

# Renaming the columns (Variables)
names(covid2) <- c("TotalCases", "AQI", "Ozone", "PM2.5", "MeanTemp", 
                   "PopDensity")

# EXPLORE DATA

# Show the first 6 observations
head(covid2)
# Check the number of observations and variables
dim(covid2) # There are 447 observations and 6 variables
# Summary of the dataset
summary(covid2)

# Visualize data
x11()
# Plotting a boxplot of variables
boxplot(covid2, main = "Boxplot of variables") # It does not reveal much
# Plotting a scatterplot matrix
pairs(covid2, main = "Scatterplot Matrix")

# Check for correlation between variables
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

# It reveals a non - linear association between PopDensity and log.TotalCases
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
  geom_smooth(method = "lm", se= FALSE)  
print(p)

# non-lm line
p <- ggplot(data = covid2, mapping = aes(x=PM2.5, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(se= FALSE)
print(p)


#Ozone
p <- ggplot(data = covid2, mapping = aes(x=Ozone, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(method = "lm", se= FALSE)
print(p)

# non-lm line
p <- ggplot(data = covid2, mapping = aes(x=Ozone, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(se= FALSE)
print(p)


# AQI
p <- ggplot(data = covid2, mapping = aes(x=AQI, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(method = "lm", se= FALSE)
print(p)

# non-lm line

p <- ggplot(data = covid2, mapping = aes(x=AQI, y=log.TotalCases)) +
  geom_point() +
  geom_smooth(se= FALSE)
print(p)