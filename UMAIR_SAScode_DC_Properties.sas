*CSC423 Summer FINAL PROJECT;
*Muhammad Umair - SAS Code;

*--------IMPORTING DATASET---------;
TITLE "Get raw data into SAS Dataset using IMPORT";
proc import datafile="UMAIR_DC_Properties_Revised.csv" out=house replace;
getnames=yes;
run;
proc print data=house (obs=10);
run;

*--------DROPPING VARIABLES---------;
TITLE "Drop variables not chosen for analysis";
Data house_cleaned;
Set house; 
Drop ID AYB HEAT YR_RMDL EYB SALE_NUM BLDG_NUM GRADE ROOF INTWALL USECODE
GIS_LAST_MOD_DTTM SOURCE CMPLX_NUM LIVING_GBA FULLADDRESS CITY
STATE ZIPCODE NATIONALGRID LATITUDE LONGITUDE ASSESSMENT_NBHD
ASSESSMENT_SUBNBHD CENSUS_TRACT CENSUS_BLOCK WARD SQUARE X Y;
Run;

proc print data=house_cleaned (obs=5);
run;

*--------CREATING BIN VARIABLES---------;
TITLE "Creating BIN Variables";
Data house_cleaned;
set house_cleaned;
year=year(datepart(SALEDATE));

if 1992<=year<=2005 then bin_SALEDATE=1;
else if 2006<=year<=2012 then bin_SALEDATE=2;
else if 2013<=year<=2018 then bin_SALEDATE=3;

if STYLE in('1 Story', '1.5 Story Fin', '1.5 Story Unf') then bin_STYLE=1;
else if STYLE in('2 Story', '2.5 Story Fin', '2.5 Story Unf') then bin_STYLE=2;
else if STYLE in('3 Story', '3.5 Story Fin') then bin_STYLE=3;
else if STYLE in('4 Story', 'Bi-Level', 'Default', 'Split Foyer', 'Split Level') then bin_STYLE=4;

if STRUCT in ('Single') then bin_STRUCT=1;
else if STRUCT in ('Multi') then bin_STRUCT=2;
else if STRUCT in ('Row End', 'Row Inside', 'Semi-Detached', 'Town End') then bin_STRUCT=3;

if CNDTN in ('Average', 'Fair') then bin_CNDTN=1;
else if CNDTN in ('Excellent', 'Very Good', 'Good') then bin_CNDTN=2;

if EXTWALL in ('Brick Veneer', 'Brick/Siding', 'Brick/Stone', 'Brick/Stucco', 'Common Brick', 'Face Brick') then bin_EXTWALL=1;
else if EXTWALL in ('Stone', 'Stone Veneer', 'Stone/Siding', 'Stone/Stucco', 'Stucco', 'Stucco Block') then bin_EXTWALL=2;
else if EXTWALL in ('Hardboard', 'Shingle', 'Vinyl Siding', 'Wood Siding') then bin_EXTWALL=3;
else if EXTWALL in ('Aluminum', 'Concrete', 'Concrete Blo', 'Metal Siding') then bin_EXTWALL=4;

run;
proc print data=house_cleaned (obs=10);
VAR year bin_SALEDATE bin_STYLE bin_STRUCT bin_CNDTN bin_EXTWALL;
run;



*---------CREATING DUMMY VARIABLES------------;
TITLE "Creating dummy variables";
data house_cleaned;
set house_cleaned;
*dummy variable for AC;
dumAC=(AC="Y");
*dummy variable for QUALIFIED;
dumQUALIFIED=(QUALIFIED="Q");
*dummy variables for QUADRANT;
dumNW=(QUADRANT="NW");
dumSE=(QUADRANT="SE");
dumSW=(QUADRANT="SW");
*dummy variables for bin_SALEDATE;
dumAfterBurst=(bin_SALEDATE="2");
dumRecentSales=(bin_SALEDATE="3");
*dummy variables for bin_STYLE;
dumDoubleStory=(bin_STYLE="2");
dumTripleStory=(bin_STYLE="3");
dumOtherStyle=(bin_STYLE="4");
*dummy variables for bin_STRUCT;
dumMultiFam=(bin_STRUCT="2");
dumTownhome=(bin_STRUCT="3");
*dummy variable for bin_CNDTN;
dumGoodCndtn=(bin_CNDTN="2");
*dummy variables for bin_EXTWALL;
dumStone=(bin_EXTWALL="2");
dumFrame=(bin_EXTWALL="3");
dumOtherExtwall=(bin_EXTWALL="4");
run;
*printing data for verification after creating dummy variables;
proc print data=house_cleaned (obs=10);
var AC dumAC QUALIFIED dumQUALIFIED QUADRANT dumNW dumSE dumSW year
	dumAfterBurst dumRecentSales bin_STYLE dumDoubleStory dumTripleStory
	dumOtherStyle STRUCT dumMultiFam dumTownhome CNDTN dumGoodCndtn 
	EXTWALL dumStone dumFrame dumOtherExtwall;
run;

*Variable names imported by SAS: 
* PRICE BATHRM HF_BATHRM AC NUM_UNITS ROOMS BEDRM STORIES bin_SALEDATE QUALIFIED
* SALE_NUM GBA bin_STYLE bin_STRUCT bin_CNDTN bin_EXTWALL KITCHENS FIREPLACES LANDAREA QUADRANT;
* All dummy variables: dumAC dumQUALIFIED dumNW dumSE dumSW dumAfterBurst dumRecentSales
						dumDoubleStory dumTripleStory dumOtherStyle dumMultiFam dumTownhome
						dumGoodCndtn dumStone dumFrame dumOtherExtwall;


*---------PROC MEANS CHECK MISSING DATA---------;
TITLE "Means of the data - house";
proc means data=house_cleaned n nmiss qrange min p25 p50 mean median p75 max std stderr maxdec=3;
* n: number of observations;
* nmiss: number missing obs.;
* mean: average of obs.;
* std: standard deviation;
* stderr: standard error = std/(n)1/2 ;
* maxdec=3: round to 3 digits;
var PRICE BATHRM HF_BATHRM NUM_UNITS ROOMS BEDRM STORIES bin_SALEDATE 
	GBA bin_STYLE bin_STRUCT bin_CNDTN bin_EXTWALL KITCHENS FIREPLACES LANDAREA 
	dumAC dumQUALIFIED dumNW dumSE dumSW dumAfterBurst dumRecentSales
	dumDoubleStory dumTripleStory dumOtherStyle dumMultiFam dumTownhome
	dumGoodCndtn dumStone dumFrame dumOtherExtwall;
run;

*-------------DESCRIPTIVES------------;
TITLE "Descriptives - house_cleaned";
proc univariate data=house_cleaned;
var PRICE BATHRM HF_BATHRM NUM_UNITS ROOMS BEDRM STORIES
	GBA KITCHENS FIREPLACES LANDAREA;
run;

*Extreme Observations;
 *PRICE:		Lowest= 1668, 562, 1767, 414, 1659		Highest= 127, 620, 1972, 408, 1481
 *BATHRM:		Lowest= 1997, 1995, 1982, 1971, 1966	Highest= 1972, 1254, 1738, 620, 1481
 *HF_BATHRM:	Lowest= 1997, 1996, 1994, 1991, 1987	Highest= 1972, 1992, 620, 408, 1959
 *NUM_UNITS:	Lowest= 1182, 41, 2000, 1997, 1996		Highest= 1986, 1992, 1994, 85, 1772
 *ROOMS:		Lowest= 1607, 1258, 528, 1966, 1891		Highest= 1503, 1634, 1638, 1686, 385
 *BEDRM:		Lowest= 1885, 1409, 1006, 838, 698		Highest= 1994, 620, 1481, 68, 326
 *STORIES:		Lowest= 812, 1915, 1909, 1891, 1828		Highest= 1481, 1486, 1960, 1195, 1862
 *SALE_NUM:		Lowest= 1997, 1995, 1994, 1993, 1992	Highest= 123, 562, 1039, 1133, 164
 *GBA:			Lowest= 528, 1891, 1397, 1609, 702		Highest= 756, 955, 408, 406, 1481
 *KITCHENS:		Lowest= 2000, 1997, 1996, 1995, 1991	Highest= 1959, 1986, 1992, 1994, 85
 *FIREPLACES:	Lowest= 1996, 1995, 1994, 1993, 1992	Highest= 988, 1481, 1694, 194, 689
 *LANDAREA:		Lowest= 1647, 1331, 234, 449, 199		Highest= 406, 120, 1481, 408, 235


*--------------REMOVE EXTREME OBSERVATIONS------------;
*writing the new dataset into houseNew_1 after the deletion of extreme obs;
TITLE "Remove Extreme Observations from house";
data houseNew_1;
set house_cleaned;
if _n_ in (41,68,85,120,123,127,164,194,199,234,235,326,385,406,408,414,449,528,562,
620,689,698,702,756,812,838,955,988,1006,1039,1133,1182,1195,1254,1258,
1331,1397,1409,1481,1486,1503,1607,1609,1634,1638,1647,1659,1668,1686,
1694,1738,1767,1772,1828,1862,1885,1891,1909,1915,1959,1960,1966,1971,
1972,1982,1986,1987,1991,1992,1993,1994,1995,1996,1997,2000) then delete; 
*drop variables as we created dummies for them;
drop AC SALEDATE year STYLE STRUCT CNDTN EXTWALL bin_SALEDATE QUALIFIED bin_STYLE bin_STRUCT bin_CNDTN bin_EXTWALL QUADRANT;
run;
proc print data=houseNew_1 (obs=10);
run;

*---------------FREQUENCY TABLE---------------;
TITLE "Frequency Table - houseNew_1";
PROC freq data=houseNew_1;
tables BATHRM HF_BATHRM dumAC NUM_UNITS ROOMS BEDRM STORIES 
		dumAfterBurst dumRecentSales dumQUALIFIED
		dumDoubleStory dumTripleStory dumOtherStyle 
		dumMultiFam dumTownhome dumGoodCndtn 
		dumStone dumFrame dumOtherExtwall KITCHENS 
		FIREPLACES dumNW dumSE dumSW;
run;

*--------------HISTOGRAMS--------------------;
*Creates Histogram with Normal Density plotted on top of histogram;
*exclduing dummy variables;
TITLE "Histogram + Normal Curve with 5-number summary - houseNew_1";
PROC UNIVARIATE normal data=houseNew_1; 
var PRICE BATHRM HF_BATHRM NUM_UNITS ROOMS BEDRM STORIES
	GBA KITCHENS FIREPLACES LANDAREA;
histogram / normal (mu = est sigma=est);
inset min mean Q1 Q2 Q3 max Range stddev/
		header = 'Overall Statistics'
		pos		= tm;
run;

*---------------TRANSFORMATION----------------;
*Transform PRICE;
TITLE "Transformation on PRICE";
data houseNew_2;
set houseNew_1;
*new transforemd variable;
In_PRICE=log(PRICE);
*drop variable PRICE as we created LOG;
drop PRICE;
run;
proc print data=houseNew_2 (obs=5);
VAR In_PRICE;
run;

*-----------HISTOGRAMS FOR TRANSFORMED VAR-----------;
*Creating HISTOGRAM for Transformed variable;
TITLE "Histogram for In_PRICE - houseNew_2";
PROC UNIVARIATE normal data=houseNew_2; 
var In_PRICE;
histogram / normal (mu = est sigma=est);
inset min mean Q1 Q2 Q3 max Range stddev/
		header = 'Overall Statistics'
		pos		= tm;
run;


*--------------SCATTERPLOTS--------------;
* excluding dummy variables;
title "GPLOTS for Y and X-variables - houseNew_2";
proc gplot data=houseNew_2;
plot In_PRICE*(GBA LANDAREA BATHRM HF_BATHRM NUM_UNITS ROOMS BEDRM STORIES
	 KITCHENS FIREPLACES);
run;

*--------------SCATTERPLOTS MATRIX-------------;
* excluding dummy variables;
proc sgscatter DATA=houseNew_2;
TITLE "Scatterplot Matrix - houseNew_2";
matrix In_PRICE GBA LANDAREA BATHRM HF_BATHRM NUM_UNITS ROOMS BEDRM STORIES
	   KITCHENS FIREPLACES;
run;

*-------------CORRELATIONS-------------------;
* excluding dummy variables;
TITLE "Correlation - houseNew_2";
proc corr DATA=houseNew_2;
var In_PRICE GBA LANDAREA BATHRM HF_BATHRM NUM_UNITS ROOMS BEDRM STORIES
	KITCHENS FIREPLACES;
run;

*-------------DROP NUM_UNITS----------------;
*Drop NUM_UNITS for multicollearity and very-low correlation with PRICE;
TITLE "Drop var NUM_UNITS due to multicollearity";
data houseNew_3;
set houseNew_2;
drop NUM_UNITS;
run;
proc print data = houseNew_3 (obs=5);
run;

*--------------CORRELATIONS---------------;
*produces correlation values for all variables except NUM_UNITS;
TITLE "Correlation for all variables except NUM_UNITS - houseNew_3";
proc corr DATA=houseNew_3;
var In_PRICE GBA LANDAREA BATHRM HF_BATHRM ROOMS BEDRM STORIES
	KITCHENS FIREPLACES;
run;

*-------------PROC REG FULL MODEL-------------;
*regression and Residual analysis;
TITLE "Model-M1 Regression and Residual Analysis- FULL linear model- houseNew_3";
proc reg DATA=houseNew_3;
model In_PRICE= GBA LANDAREA BATHRM HF_BATHRM ROOMS BEDRM STORIES KITCHENS FIREPLACES  
				dumAC dumQUALIFIED dumNW dumSE dumSW dumAfterBurst dumRecentSales
				dumDoubleStory dumTripleStory dumOtherStyle dumMultiFam dumTownhome
				dumGoodCndtn dumStone dumFrame dumOtherExtwall/vif tol stb influence r;
plot student.*predicted.; * Residual plot: residuals vs predicted values;
plot student.*(GBA LANDAREA BATHRM HF_BATHRM ROOMS
				BEDRM STORIES KITCHENS FIREPLACES); * Residual plot: residuals vs x-variables;
plot npp.*student.; * Normal probability plot or QQ plot;
run;


*--------------REMOVE OUTLIERS/INFLU POINTS--------------;
* writing into new dataset after deletion;
TITLE "Remove Influencial Points and Outliers from houseNew_3 dataset";
data houseNew_4;
set houseNew_3;
if _n_ in (90,185,202,240,251,258,303,308,363,376,665,675,717,769,787,837,913,927,959,1025,
			1052,1078,1142,1176,1380,1467,1530,1617,1625,1633,1659,1711,1714,1779,1796,1852,1892) then delete; 
run;
PROC freq data=houseNew_4;
tables dumAC;
run;


*-------------PROC REG AFTER REMOVE OUT/INFLU------------;
TITLE "Model-M2 Regression and Residual Analysis- FULL linear model- houseNew_4";
proc reg DATA=houseNew_4;
model In_PRICE= GBA LANDAREA BATHRM HF_BATHRM ROOMS BEDRM STORIES KITCHENS FIREPLACES  
				dumAC dumQUALIFIED dumNW dumSE dumSW dumAfterBurst dumRecentSales
				dumDoubleStory dumTripleStory dumOtherStyle dumMultiFam dumTownhome
				dumGoodCndtn dumStone dumFrame dumOtherExtwall/vif tol stb influence r;
plot student.*predicted.; * Residual plot: residuals vs predicted values;
plot student.*(GBA LANDAREA BATHRM HF_BATHRM ROOMS
				BEDRM STORIES KITCHENS FIREPLACES); * Residual plot: residuals vs x-variables;
plot npp.*student.; * Normal probability plot or QQ plot;
run;


*--------------REMOVE FEW MORE OUTLIERS/INFLU POINTS--------------;
* writing into new dataset after deletion;
TITLE "Remove Influencial Points and Outliers from houseNew_4";
data houseNew_5;
set houseNew_4;
if _n_ in (2,252,547,1056,1160,1252,1755) then delete; 
run;
PROC freq data=houseNew_5;
tables dumAC;
run;


*-------------PROC REG AFTER REMOVE MORE OUT/INFLU------------;
TITLE "Model-M3 Regression and Residual Analysis- FULL linear model- houseNew_5";
proc reg DATA=houseNew_5;
model In_PRICE= GBA LANDAREA BATHRM HF_BATHRM ROOMS BEDRM STORIES KITCHENS FIREPLACES  
				dumAC dumQUALIFIED dumNW dumSE dumSW dumAfterBurst dumRecentSales
				dumDoubleStory dumTripleStory dumOtherStyle dumMultiFam dumTownhome
				dumGoodCndtn dumStone dumFrame dumOtherExtwall/vif tol stb;
plot student.*predicted.; * Residual plot: residuals vs predicted values;
plot student.*(GBA LANDAREA BATHRM HF_BATHRM ROOMS
				BEDRM STORIES KITCHENS FIREPLACES); * Residual plot: residuals vs x-variables;
plot npp.*student.; * Normal probability plot or QQ plot;
run;



/**************************************************
TRAINING AND TESTING
**************************************************/

/* Apply validation techniques to compare predictive power 
of the two models*/
/* Generate the test samples: training set used to fit the model
and the test set to compute predictive performance*/
/* samprate = % of observations to be randomly selected for training set
	out = xv_all defines new sas dataset (xv_all) definining training/test sets*/
title "Validation and Predition Power for houseNew_5";
proc surveyselect data=houseNew_5 out=xv_all seed=246523
samprate=0.75 outall; *outall: Selected=1 -->Train 	 Selected=0 -->Test;
run;
* print out training/test datasets identified by variable "selected";
title "Validation - Train Set";
proc print data=xv_all (obs=10);
run;
PROC freq data=xv_all;
tables Selected;
run;

*create new variable new_y=In_PRICE for training set, and new_y=NA for testing set;
data xv_all;
set xv_all;
if selected then new_y=IN_PRICE; *If selected=1, assign new_y=In_PRICE;
run;
proc print data=xv_all (obs=10);
VAR selected new_y;
run;

*running two model selections methods on train set;
title "Model-1 Selection";
proc reg data=xv_all;
* MODEL-1;
model new_y= GBA LANDAREA BATHRM HF_BATHRM ROOMS BEDRM STORIES KITCHENS FIREPLACES  
	dumAC dumQUALIFIED dumNW dumSE dumSW dumAfterBurst dumRecentSales
	dumDoubleStory dumTripleStory dumOtherStyle dumMultiFam dumTownhome
	dumGoodCndtn dumStone dumFrame dumOtherExtwall/selection=stepwise sle=0.01 sls=0.01;
run;
title "Model-2 Selection";
* MODEL-2;
model new_y= GBA LANDAREA BATHRM HF_BATHRM ROOMS BEDRM STORIES KITCHENS FIREPLACES  
	dumAC dumQUALIFIED dumNW dumSE dumSW dumAfterBurst dumRecentSales
	dumDoubleStory dumTripleStory dumOtherStyle dumMultiFam dumTownhome
	dumGoodCndtn dumStone dumFrame dumOtherExtwall/selection=adjrsq;
run;
/*-------------------Predictors selected by selection methods--------------------------------*
*MODEL-1: GBA LANDAREA BATHRM HF_BATHRM FIREPLACES dumAC dumQUALIFIED;
*			dumNW dumSE dumAfterBurst dumRecentSales dumMultiFam dumGoodCndtn;
*MODEL-2: GBA LANDAREA BATHRM HF_BATHRM BEDRM KITCHENS FIREPLACES dumAC dumQUALIFIED 
			dumNW dumSE dumSW dumAfterBurst dumRecentSales dumMultiFam dumGoodCndtn dumStone dumFrame
*********************************************************************************************/


/***********PROC REG - Model-1***********/
TITLE "Model-1 - Full prog reg output";
proc reg data=xv_all;
model new_y= GBA LANDAREA BATHRM HF_BATHRM FIREPLACES dumAC dumQUALIFIED  
			dumNW dumSE dumAfterBurst dumRecentSales dumMultiFam dumGoodCndtn/vif tol stb;
plot student.*predicted.; *Residual plot: residuals vs predicted values;
plot student.*(GBA LANDAREA BATHRM HF_BATHRM FIREPLACES); *Residual plot: residuals vs x-variables;
plot npp.*student.; *Normal probability plot or QQ plot;
run;

/***********PROC REG - Model-2***********/
TITLE "Model-2 - Full prog reg output";
proc reg data=xv_all;
model new_y= GBA LANDAREA BATHRM HF_BATHRM BEDRM KITCHENS FIREPLACES dumAC dumQUALIFIED
			dumNW dumSE dumSW dumAfterBurst dumRecentSales dumMultiFam dumGoodCndtn dumStone dumFrame/vif tol stb;
plot student.*predicted.; *Residual plot: residuals vs predicted values;
plot student.*(GBA LANDAREA BATHRM HF_BATHRM BEDRM KITCHENS FIREPLACES); *Residual plot: residuals vs x-variables;
plot npp.*student.; *Normal probability plot or QQ plot;
run;


/*********************VALIDATION******************/
title "Get predicted values for the missing new_y in test set for 2 models";
proc reg data=xv_all;
* MODEL1;
model new_y=GBA LANDAREA BATHRM HF_BATHRM FIREPLACES dumAC dumQUALIFIED
			dumNW dumSE dumAfterBurst dumRecentSales dumMultiFam dumGoodCndtn;
*out=outm1 defines dataset containing Model-1 predicted values for test set;
output out=outm1(where=(new_y=.)) p=yhat;
* MODEL2;
model new_y=GBA LANDAREA BATHRM HF_BATHRM BEDRM KITCHENS FIREPLACES dumAC dumQUALIFIED
			dumNW dumSE dumSW dumAfterBurst dumRecentSales dumMultiFam dumGoodCndtn dumStone dumFrame;
*out=outm2 defines dataset containing Model-2 predicted values for test set;
output out=outm2(where=(new_y=.)) p=yhat;
run;

proc print data=outm1 (obs=10);
var selected In_PRICE new_y yhat;
run;
proc print data=outm2 (obs=10);
var selected In_PRICE new_y yhat;
run;


/* summarize the results of the cross-validations for model-1*/
title "Difference between Observed and Predicted in Test Set";
data outm1_sum;
set outm1;
d=In_PRICE-yhat; *d column is the difference between observed and predicted values in test set;
absd=abs(d); 
run;
proc print data=outm1_sum (obs=10);
VAR selected In_PRICE new_y yhat d absd;
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm1_sum;
var d absd;
output out=outm1_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm1_stats (obs=10);
title 'Validation  statistics for Model-1';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm1;
var In_PRICE yhat;
run;



/* summarize the results of the cross-validations for model-2*/
title "Difference between Observed and Predicted in Test Set";
data outm2_sum;
set outm2;
d=In_PRICE-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
proc print data=outm2_sum (obs=10);
VAR selected In_PRICE new_y yhat d absd;
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm2_sum;
var d absd;
output out=outm2_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm2_stats (obs=10);
title 'Validation  statistics for Model-2';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm2;
var In_PRICE yhat;
run;



/***************************************************************
	FINAL MODEL Based on Highest Standardized Estimate Values
****************************************************************/
TITLE "Model-M5 Final Fitted Model- houseNew_5";
proc reg DATA=xv_all;
model In_PRICE= dumRecentSales dumAfterBurst GBA FIREPLACES dumNW dumQUALIFIED/vif tol stb;
run;
plot student.*predicted.; * Residual plot: residuals vs predicted values;
plot student.*(dumRecentSales dumAfterBurst GBA FIREPLACES dumNW dumQUALIFIED); * Residual plot: residuals vs x-variables;
plot npp.*student.; * Normal probability plot or QQ plot;
run;
