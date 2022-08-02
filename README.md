# Data-Driven Analysis of Covid-19 Airbone Diffusion in the US

## I. Introduction
The uncontrollable outbreak of SARS-COV-2 (Severe Acute Respiratory Corona Virus 2) resulting in a global pandemic of COVID-19 (Coronavirus Disease 2019) is threatening public health globally. The providers of healthcare services are at a disproportionately high risk (29% higher than general population) of contracting the infection (Bai, Yan; Yao, Lingsheng; Wei, tao; Tian, Fei; Jin, Dong-Yan; Chen, Lijuan; Wang, 2020)[^1]. Dealing with a virus with unprecedented transmission efficiency, the lack of definite knowledge about the characteristics and diffusion mechanism has exacerbated the problem, leaving the effectiveness of mitigation measures uncertain. The mechanisms behind the spread of this virulent strain are not fully understood yet. The initial notion about human-to-human close contact spread through respiratory droplets was thought to be the main route of spread. Recently, with subsequent studies worldwide, it has been confirmed that airborne diffusion is significant. Morawska and Cao (2020)[^6] has shown the airborne transmission to be a main reason behind the spread by summarizing a wide array of studies (Morawska & Cao, 2020)[^6]. Confirming evidence of the virus being airborne and has already been established. The on-field studies inside Wuhan Hospitals in China has demonstrated the virus's capability to diffuse indoors and travel up to 10 m airborne (Setti et al., 2020)[^7].

With the airborne diffusion of COVID-19 ascertained, it is of paramount importance to look at the factors that aid in airborne diffusion of the virus. Zhang et al. (2020)[^8] studied the trends of spread and mitigation measures in Wuhan (China), Italy, and New York city (USA) to show that mitigation measures against the airborne spread, like mask wearing mandates have reduced the spread – a confirmation about the airborne diffusion (Zhang, Li, Zhang, Wang, & Molina, 2020)[^8]. Li et al.[^5] studied the transmission routes of COVID-19 in 15 states of the United States to demonstrate that the growth rate of transmission was curbed after mandates about face covering and stay at home order, again confirming the airborne spread of the virus (Li, Zhang, Zhao, & Molina, 2020)[^5]. 

Most of the published articles that have investigated the transmission through aerosol, have focused on mitigation measures like face coverings, rather than examining the factors responsible for the airborne spread. Coccia et al. (2020)[^3] studied the environmental and demographic factors related to 55 Italian cities that linked air pollution and population density in those cities with the transmission of COVID-19 (Coccia, 2020)[^3]. Given the lack of such studies for United States, this study aims to collect similar data in the USA to find significant relationships with the airborne method of coronavirus spread. Different supervised statistical learning methods were applied to find machine learning models that can establish and explain the relationship. 

## II. Method
Through this project, the spread of COVID-19 in the US, specifically the 15 states severely plagued by the disease, is investigated. These states are CA, OH, GA, FL, TX, VA, CT, MA, MI, NJ, NY, PA, IL, LA, and MD. 

### 1. The Data
Since the states as a unit of analysis does not provide a clear understanding of the problem and there is a lot of variance in the main outcome variable – no. of confirmed COVID-19 cases, the data was collected at county level for each of these 15 states. Thus, for this project the dataset has following variables:

Predictor Variables:
1. The particulate matter (PM 2.5) concentration in each county in terms of days exceeding the set limit of PM 2.5 (12 $μg/m^3$ as mandated by EPA in 2012) for 2019 - $x_1$
2. Ozone concentration in terms of number of days per year exceeding the limits set for ozone (0.07 ppm as mandated by EPA in 2015) for 2019 - $x_2$
3. 90<sup>th</sup> percentile Air Quality Index (AQI) which shows the average of 90 percent of daily AQI values during 2019 that were less than or equal to the 90<sup>th</sup> percentile value - $x_3$
4. Average year to date temperature (in degree F) in each county during 2020 - $x_4$
5. Average year to date wind speed (in MPH) in each county during 2020 - $x_5$
6. Average year to date Relative Humidity (RH in percentage) in each county during 2020 - $x_6$
7. The average county-level population density (in inhabitants/sq. mile) as per the census 2010 - $x_7$

The outcome variable (Y) is the cumulative no. of confirmed COVID-19 positive cases in each county till 10/12/2020.

Now, the reason behind selecting air pollution data for the year 2019 is twofold. First, these were the measures of the air quality in each county before the COVID-19 pandemic, which is considered to have temporal effect on both human and environmental health (Brunekreef & Holgate, 2002)[^2]. Second, the air pollution data for the current year is still being populated and the EPA website (epa.gov) warns that the data for the current year can take until May 2021 to be available at county level. The rationale behind including AQI as a predictor is that this index is calculated based on the concentration levels of PM 2.5, PM 10.5, ozone, Nitrogen Dioxide, and Sulfur Dioxide. Even though the indirect measures of PM 2.5 and ozone concentration were available, no such indicator other than AQI was available for the other three pollutants. So, to understand their effects on the diffusion of COVID-19, AQI index was included in the dataset and it was understood that correlation may exist between the measures of PM 2.5, ozone and AQI. The meteorological indicators, namely average year to date temperature, average year to date wind speed, average year to date RH were selected for 2020 since the effects of these factors are not temporal, rather they have been indicated to have current effects (Brunekreef & Holgate, 2002)[^2]. 

### 2. Summary of the Dataset
The unit of analysis for this study is the Counties in the aforementioned 15 states of the US. Each observation includes information about the variables for a particular county in one of those states. Thus, every observation in the dataset are unique, and there are 447 such unique observations. All of these data are continuous variables. 

### 3. Data Cleaning
The meteorological and air quality data are collected from land-based weather monitoring stations that does not necessarily generate data at county level. So, some counties in those states did not have any data for pollutant concentration and those counties were removed from the data set. Similarly, the year to date mean wind speed data was available for only 118 counties out of 447 and the year to date mean RH data was available for only 61 counties. Including these two predictors would have resulted in a loss of a large no. of observation. To avoid that, it was decided not to consider year to date average wind speed and year to date average RH as predictors (predictor variables $x_5$ and $x_6$) and $x_7$ (average population density) was now $x_5$. Thus, the final dataset for analysis was of 447 rows and 6 columns. 

### 4. Regression Models
Supervised statistical learning method, where a set of methods are used to formulate the rules that connect the predictor variables to the response variable, was used to analyze the data set. In Supervised learning methods, predictors have response variables associated with them for each observation. This is a learning process since the mechanism of how the dependent variable is changing as a function of the independent variables is being studied from within the data. A part of the data set (training set) was used to understand the relation between the dependent and independent variables by training regression models. These trained models were then used in the remainder of the data (test set) to predict the value of the response; and to compare them with the observed response, through quantification of the deviance between the two values. There are several statistical models that can be used to train the regression models, depending on the problem and the data type. The techniques used for this study are discussed in the subsequent sections.  

#### a. Multiple Linear Regression Model
Linear Regression is a statistical method to explore the relationship between the response and the predictor variables. When only one predictor is used to construct the relationship, it is summarized using an intercept and a slope coefficient representing a line in the two-dimensional space, known as population regression line which is the best linear approximation of the relationship, summarized in Equation 1.

**Equation 1** $$\{Y}=\beta_0+\beta_1\{x}+\epsilon$$

The intercept coefficient $(β_0)$ is the approximated response $(Y)$ when the predictor variable $(x)$ is zero, and the slope coefficient $(β_1)$ is the average effect of one-unit change in $x$ on $Y$. $ϵ$ is the error term that determines the distance of individual observations from the approximated regression line. But when the number of predictor variables are more than one, a linear relationship can still be established using a multi-dimensional space, where the meaning of coefficients associated with the independent variables are interpreted as the average effect on the dependent variable while keeping the other independent variables constant, as expressed in Equation 2, where there are $p(x_1…x_p)$ predictors. 

**Equation 2** $$\{Y}=\beta_0+\beta_1\{x}_1+\beta_2\{x}_2+⋯+\beta_p\{x}_p+\epsilon$$

#### b. Generalized Additive Model
Linear relationships are widely used simplified approximations that often result in poor inference and prediction as relationships are not always deducible simply to a multidimensional plane. The non-linearity associated with the relationships demands special attention when training regression models. Those non-linear relationships can be approximated using curves, splines, or step-functions, using polynomials of the predictor variables. Generalized Additive Model (GAM) is a special framework where the standard multiple linear models are extended to accommodate higher powers by allowing non-linear functions of each predictors, while maintaining additivity. Equation 3 represents a generic GAM where the linear component $β_jx_j$ is replaced by a non-linear function $f_j(x_j)$.

**Equation 3** $$\{Y}=\beta_0+\{f}_1({x}_1)+{f}_2({x}_2)+⋯+{f}_p({x}_p)+\epsilon$$

The functions that are applied to the predictors do not need to be same, i.e., $f_1$ can represent a polynomial of degree 4, while $f_2$ can represent smoothing splines. GAMs are significantly better at approximating the true relationships that the response has with individual predictors and providing a regression result that accounts for all of them. These added complications also make it difficult to interpret the results from GAMs, even though the functions include smoothing parameters that prevent the results from being too biased to the training set. GAMs do not estimate regression coefficients like MLR; instead the interpretation of the regression results is made from partial influence plot of smoothing functions and the predictive scores of the model. For more details on these methods, please chapters 3 and 7 of (James, G., Witten, D., Hastie, T., Tibshirani, 2013)[^4].
These models were evaluated using Leave One Out Cross-Validation (LOOCV) scores and their predictive ability were tested by calculating the mean square predictive error (MSPE), defined in Equation 4, when the models were used to predict the velocity values using the predictors from the test set.

**Equation 4** $${MSPE}=\frac{1}{N}\sum_{i=1}^N(\widehat{{Y}_i}-{Y}_i)^2$$

Where $n$ is the total no. of observations, $\widehat{{Y}_i}$ is the predicted velocity value for the $i^{th}$ observation and $Y_i$ is the observed velocity value of the $i^{th}$ observation.

## III. Results and Discussion

### 1. Exploratory Data Analysis
The summary of the data is tabulate in Table 1.
Table 1: Summary of variables
TotalCases	AQI	Ozone	PM2.5	MeanTemp	PopDensity
Min.: 14	Min.:  0.00	Min.:  0.0	Min.:  0.00	Min.:44.90	Min.:    0.6
1st Qu.: 852	1st Qu.: 48.00	1st Qu.:164.0	1st Qu.:  0.00	1st Qu.:55.00	1st Qu.:   94.8
Median: 3021	Median: 54.00	Median: 233.0	Median: 91.00	Median: 59.10	Median:  254.4
Mean:  9435	Mean: 54.81	Mean: 205.4	Mean: 96.09	Mean: 61.24	Mean: 1113.9
3rd Qu.:  9998	3rd Qu.: 61.00	3rd Qu.: 271.0	3rd Qu.: 146.00	3rd Qu.: 68.25	3rd Qu.:  741.5
Max.: 280961	Max.: 169.00	Max.: 365.0	Max.: 365.00	Max.: 78.90	Max.: 69467.5
The correlation between the variables are shown in the heatmap in Figure 1 which shows a moderate negative correlation between the measures of PM 2.5 and ozone. After a simple, first order linear model was fitted (Eq. 5) to the data and residuals were plotted against fitted value, it indicated there are violations about the normality and random distribution of residual assumptions, that called for a transformation of the response variable. 

**Equation 5** $$Y=β_0+ β_1 x_1+β_2 x_2+ β_3 x_3+ β_4 x_4+ β_5 x_5$$

Using Boxcox method, we found the Boxcox transformation index (λ) value to be near zero, that indicated a log transformation of the Y variable. After transformation, the first order simple linear model was applied again and the trends in the residual’s vs fitted plot still showed a fanning out pattern, indicating the requirement to transform one of the predictor variables. From the scatterplot matrix after Y transformation, we found that Population Density measure needed a log transformation. When that transformation was performed and fitted to the linear model (Eq. 6) as before, the residuals had no pattern anymore. 
 
               Figure 1:  Correlation Heatmap		     Figure 2:  Histogram of Transformed Response
   	      
**Equation 6** $$Y'=β_0+ β_1 x_1+β_2 x_2+ β_3 x_3+ β_4 x_4+ β_5 〖x'〗_5  , where Y^'=□log log (Y)  and x_5^'=□log log (x_5) $$

The distribution of the transformed Y variable (Figure 2) was slightly left-skewed with a minimum value of 2.639, a maximum value of 12.546, a mean of 7.889, and a median of 8.013. The value associated with the most count (23) was close to 7.75. 
 
                	 Figure 3:  Y^' VS.〖X'〗_5  		     			Figure 4:  Y^' VS.X_4
The trend when comparing Y’ with two of the key predictors x_5^' and x_4 are shown in Figure 3 and 4, respectively. Figure 3 demonstrates that Y’ and x_5^' have a strong positive linear relationship, with indications of a few outliers. On the other hand, Figure 4 also shows a positive linear relationship with a smaller slope compared to Figure 3. It is also notable that when comparing Y’ to only x_5^', the errors are lower than when Y’ is compared to only x_4.  

### 2. Results from MLR
As the data was explored in our EDA report, a log transformation of the Y variable and population density measure had been conducted. Then, we divided the data into two parts: 80% for training set (357 observations) and 20% for testing set (90 observations). The training data was used to run the multiple linear regression model while the testing data was used to make predictions and to see how accurate the predictions are. 
Table 2: Summary of MLR model
Parameters	Estimate	p-value
Intercept 	β_0 = -2.36562	2.07e-09
AQI (X_1)	β_1 = 0.02451	2.34e-15
Ozone (X_2)	β_2= 0.00105   	0.0541
PM 2.5 (X_3)	β_3 = 0.00171	0.0106
Mean Temperature (X_4)	β_4 = 0.07047	< 2e-16
Log(Population Density) (〖X'〗_5)	β_5 = 0.75847	< 2e-16
Residual Standard Error: 0.8347 (351 df); Adjusted R^2: 0.781; Overall F-Statistic: 254.9 (3 and 351 df), p-value < 2.2e-16
The results from the multiple linear regression, as shown on Table 2, suggest that all the variables that we selected and modified are significant except the value of ozone concentration and the particulate matter. Also, the R-squared value is quite high (0.7841). This means the model shows the variation that our model explains. We also do model selection using Adjusted R-squared, Akaike Information Criterion (AIC,) and Bayes Information Criterion (BIC). 
The appropriate subset of the predictors was selected by Adjusted R-squared, Akaike Information Criterion (AIC,) and Bayes Information Criterion (BIC) methods. The adjusted R-squared method showed the linear model is best fitted with Mean temp and log.PopDensity as predictors, and including AQI is also reasonable. The AIC method indicated that indicate all of the predictors should be included in the model. The BIC method preferred a simpler model that included only the only log.PopDensity as a predictor.
Thus, three competing MLR models were derived using combinations of predictors for training the model: combination 1 (log.PopDensity), combination 2 (log.PopDensity and MeanTemp), and combination 3 (all predictors), which are expressed as Eq. 7, 8, and 6, respectively.
			
**Equation 7** $$Y'=β_0+ β_5 〖x'〗_5$$			    

**Equation 8** $$Y'=β_0+ β_4 x_4+ β_5 〖x'〗_5$$

#### a. Model Training
The MLR models were compared using two validation-set approaches to estimate the test error rates, the Leave-One-Out Cross-Validation (LOOCV) and 5-Fold Cross-Validation. The test error rates using 2 validation-set approaches of each model are shown in the Table 3.
Table 3: Cross-Validation score comparison of MLR models
Combination	Test error rates using LOOCV approach	Test error rates using 5-Fold Cross-Validation approach
		
1	0.9517107 | 0.9516880	0.9421105 | 0.9413930
2	0.7138609 | 0.7138198	0.7159521 | 0.7124585
3	1.359231 | 1.359206	1.353713 | 1.352404
From the results, the model in Eq. 6 (combination of all predictors) were estimated to provide the least cross-validation scores. Hence, that model was selected as the final model to test the predictive ability. The adjusted R-squared = 0.781 with all the predictors included in the prediction multiple linear regression model shows that 78.1% of the variance in the measure of "log.TotalCases" can be predicted by all the predictors.

#### b. Prediction
Finally, the selected model was employed to make predictions for the cumulative number of confirmed COVID-19 positive cases in 90 counties till 12th October 2020 in the test set. The mean square predictive error was calculated to quantify the predictive ability. For the selected model, it was found to be 0.6178. 

### 3. Results from GAM
The training data was used to run the Generalized Additive Model, to check for non-linear relationships between the predictors and the response.  We first started with the standard linear regression model (SLiM) approach. The results from the SLiM approach, as shown in Figure 5, suggested that we have significantly statistical effects for all the selected and modified variables, but not for ozone concentration, and the high R-squared value (0.793) suggests a notable amount of the variance is accounted for, quite similar to the MLR model in Eq. 6. 

 
               			     Figure 5:  Summary of SLiM 

On the contrary, when the Generalized Additive Model, involving all the predictors (Eq. 9), was applied to the training set to see the nonlinear effects for every covariate, the results (Table 4) depicted that all the selected and modified variables were statistically significant. As only ozone had an estimated degree of freedom 1, it suggested that no variable other than ozone described a linear relationship. This model was able to explain the variance associated with the data better, as it had higher R-squared value of 0.827, compared to the MLR model. Therefore, it was decided that the non-linear model was a better fit for the data. 

**Equation 9** $$Y'= Β_0+F_1 (X_1 )+ F_2 (X_2 )+F_3 (X_3 )+F_4 (X_4 )+F_5 (〖X'〗_5 )$$ 

Figure 6:  Results of comparing SLiM and GAM (Eq. 9)

To compare the SLiM and the GAM models, an Analysis of Variance (Figure 6) was performed that proved that nonlinear effects had considerably improved the model. So, the nonlinear approach was used to train the model.

Table 4: Summary of GAM
Parameter	Estimate	P-value
7.86768	0.44095	<2e-16
Approximate Significance of Smoothing Terms
Function	Estimated df	Reference df	F	p-value
f_1 (x_1 )	3.860	4.802	23.100	<2e-16
f_2 (x_2 )	1.000	1.000	13.136	0.000333
f_3 (x_3 )	4.676	5.660	4.728	0.000253
f_4 (x_4 )	7.821	8.619	23.394	<2e-16
f_5 (x_5 )	3.864	4.844	144.689	<2e-16
Adjusted R^2 = 0.922	Deviance Explained = 92.3%

#### a. Model Training
As with the MLR models, three competing models were used in GAMs, given by Eq. 10, 11, and 9.
				
**Equation 10** $$Y^'= Β_0+ F_5 (X_5)$$			        

**Equation 11** $$Y'= Β_0+F_4 (X_4 )+F_5 (〖X'〗_5 )$$

These three models were compared in terms of cross-validation scores using both LOOCV and 5-fold cross-validation method. The results (Table 5) suggested that the model that included all the predictors had the lowest cross-validation score. Hence, that model was used to test prediction capabilities in the test set.
 
Table 4: Cross-Validation score comparison of GAMs
Combination	Test error rates using LOOCV approach	Test error rates using 5-Fold Cross-Validation approach
		
1	0.8855844 | 0.8863736	0.8800074 | 0.8768801
2	0.6258556 | 0.6200710	0.6213970 | 0.5887481
3	1.245176 | 1.245052	1.250825 | 1.240288


The partial influence plots were plotted (Figure 7), that depicts partial effects of the smoothing terms associated to each predictor on the response, where the solid line represents the mean of the estimated relationship and the shaded regions signify 95% confidence intervals.  It is evident that the smoothing terms for all the predictors captures the curved relations with velocity, apart from ozone which has a linear relationship. The GAM diagnostic (Figure 8) describes the model performance. From the Normal Q-Q plot, it is evident that the assumption of normally distributed residuals is deviated at the tails, which is corroborated by the Histogram of residuals, which is slightly left-skewed. The residual vs. linear prediction plot reveals that there are no significant patterns. The response vs. fitted values figure shows that the predicted values and the observed values are plotted in close clusters, without significant deviations. Hence, the generalized additive model is a better model in terms of fitting the data and predict velocity values.

 

Figure 7:  Partial Influence Plot of the Smoothing Functions

 

Figure 8:  Selected GAM Diagnostics

#### b. Prediction

The selected GAM was applied to the test set to make predictions and the MSPE index was 0.609 which is slightly better than the selected MLR model. 

### 4. Prediction of three cases of interest
As an MLR model and a GAM was selected and evaluated, these were used to predict the cumulative number of COVID-19 as on 12/10/2020 in three South Carolina County, namely Anderson County, Greenville County, and Pickens County. The related values for the predictors and the results of the predictions employing MLR and GAM are given in Table 6.
Table 6: Prediction of Three Cases of Interest
County	AQI	Ozone 	
PM 2.5	         Mean Temperature	      Population Density	Prediction from MLR	Prediction from GAM
Anderson	67	225	0	61.42	261.6	2994	2443
Greenville	67	234	127	61.33	547.7	6967	6390
Pickens	59.8	251	21	59.83	240.2	3025	2821

## IV. Conclusion

This study analyzed the environmental and demographic factors in 15 states of the United States to examine the relationship between those factors and the airborne diffusion of COVID-19. This study collected data from various sources pertinent to the variables that were suggested to be crucial in previous literature. Our studies provided important insight that the airborne diffusion of novel coronavirus is significantly related to the air pollution indices. The no. of confirmed infections had a positive relationship with air pollution indices, suggesting that the virus spreads more efficiently in places with bad air quality. Our investigation also considered the population density at the county level, and a positive relationship was found to be present with the confirmed no. of infected individuals that provides credibility to the theory that the virus is also capable to spread in close contact. 

It was demonstrated through this paper that with appropriate data, different machine learning models can be employed to examine the spread of airborne virulent strains that would lead to better understanding of the situation, ultimately aiding in improved mitigation strategy. It is crucial to fit different learning models to better estimate the relationships, as it was seen that non-linear models were better in explaining the variability associated to the data used our study. 

Having said that, it is quite cumbersome to collect meteorological and demographic data for a country like the United States as it is geographically dispersed, and the data is populated to the government servers after large intervals. In future studies, if a better dataset can be constructed including ore variables like relative humidity, wind speed, etc., a more accurate predictive model can be trained and utilized to control the spread. 

[^1]: Bai, Yan; Yao, Lingsheng; Wei, tao; Tian, Fei; Jin, Dong-Yan; Chen, Lijuan; Wang, M. (2020). Presumed Asymptomatic Carrier Transmission of COVID-19. Journal of American Medical Association, 323(14), 1406–1407. https://doi.org/10.1056/NEJMoa2001316

[^2]: Brunekreef, B., & Holgate, S. T. (2002). Air pollution and health. Lancet, 360(9341), 1233–1242. https://doi.org/10.1016/S0140-6736(02)11274-8

[^3]: Coccia, M. (2020). Factors determining the diffusion of COVID-19 and suggested strategy to prevent future accelerated viral infectivity similar to COVID. Science of the Total Environment, 729, 138474. https://doi.org/10.1016/j.scitotenv.2020.138474

[^4]: James, G., Witten, D., Hastie, T., Tibshirani, R. (2013). An Introduction to Statistical Learning - with Applications in R | Gareth James | Springer. Retrieved from https://www.springer.com/gp/book/9781461471370%0Ahttp://www.springer.com/us/book/9781461471370

[^5]: Li, Y., Zhang, R., Zhao, J., & Molina, M. J. (2020). Understanding transmission and intervention for the COVID-19 pandemic in the United States. Science of the Total Environment, 748, 141560. https://doi.org/10.1016/j.scitotenv.2020.141560

[^6]: Morawska, L., & Cao, J. (2020). Airborne transmission of SARS-CoV-2: The world should face the reality. Environment International, 139(April), 105730. https://doi.org/10.1016/j.envint.2020.105730

[^7]: Setti, L., Passarini, F., De Gennaro, G., Barbieri, P., Perrone, M. G., Borelli, M., … Miani, A. (2020). Airborne transmission route of covid-19: Why 2 meters/6 feet of inter-personal distance could not be enough. International Journal of Environmental Research and Public Health, 17(8). https://doi.org/10.3390/ijerph17082932

[^8]: Zhang, R., Li, Y., Zhang, A. L., Wang, Y., & Molina, M. J. (2020). Identifying airborne transmission as the dominant route for the spread of COVID-19. Proceedings of the National Academy of Sciences of the United States of America, 117(26), 14857–14863. https://doi.org/10.1073/pnas.2009637117
