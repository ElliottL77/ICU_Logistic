/* Reformats the variable's values so as to make it easier to analyze. */
proc format;
	value  live_or_dead 0 = 'lived'
						1 = 'died';
	value agegroup 0 = '40 to 63 (inclusive)'
			  	   1 = '<40 or >63';
	value $gendergroup 0 = 'male'
					  1 = 'female';
	value $racegroup 1 = 'white'
					2 , 3 = 'other';
	value medsurg 0 = 'medical'
				  1 = 'surgical';
	value cancer 0 = 'no'
				 1 = 'yes';
	value renal 0 = 'no'
				1 = 'yes';
	value infection 0 = 'no'
					1 = 'yes';
	value cpradmin 0 = 'no'
				   1 = 'yes';
	value previous 0 = 'no'
				   1 = 'yes';
	value admintype 0 = 'elective'
					1 = 'emergency';
	value fracture 0 = 'no'
				   1 = 'yes';
	value oxygen 0 = '=> 60'
				 1 = '=< 60';
	value pH 0 ='=> 7.25'
			 1 = '=< 7.25';
	value carbond 0 = '=< 45'
				  1 = '=> 45';
	value bicarb 0 = '=> 18'
				 1 = '=< 18';
	value creatinine 0 = '=< 2.0'
					 1 = '=> 2.0';
	value consciousness 0 = 'conscious'
						1, 2 = 'stupor or unconscious';
run;

data icu; /* begins the data step */
infile "C:\Users\Elliott\Documents\STAT696\Final Project\icu.csv" dlm=',' firstobs=2;
input ID $ STA AGE GENDER $ RACE $ SER CAN CRN INF CPR SYS HRA PRE TYP FRA PO2 PH PCO BIC CRE LOC;
/* The following comments will explain some of the finer details of the variables. These are the original valued before
being formatted by the above values.
ID = Identification number,
STA = vital status,
	0 = lived
	1 = died
AGE = Age of the patient,
GENDER = Gender of the patient,
RACE = Race of patient,
	1 = White
	2 = Black
	3 = Other
SER = service, 
	0 = medical, 
	1 = surgical.
CAN = Was cancer a part of the problem,
	0 = No
	1 = Yes
CRN = History of Chronic Renal Falure,
	0 = No
	1 = Yes
INF = Infection probable at time of admittmitance to ICU, 
	0 = No
	1 = Yes
CPR = Was CPR issued prior to ICU admission,
	0 = No
	1 = Yes
SYS = Systolic Blood Pressure at ICU admission
HRA = Heart Rate at ICU Admission
PRE = Has the patient been into the ICU within 6 months
	0 = No
	1 = Yes
TYP = Type of Admission
	0 = Elective
	1 = Emergency
FRA = Was there a long bone (such as the thigh), multiple bones broken
	  a neck fracture, a single area (such as the ribs), or a hip fracture involved,
	0 = No
	1 = Yes
PO2 = PO2 from initial blood gases,
	0 => 60
	1 =< 60
PH = pH of initial blood gasses,
	0 => 7.25
	1 =< 7.25
PCO = PCO2 from initial blood gases,
	0 =< 45
	1 => 45
BIC = Bicarbonate from initial blood gases,
	0 => 18
	1 =< 18
CRE = Creatinine from initial blood gases,
	0 =< 2.0
	1 => 2.0
LOC = Level of Consciousness at ICU admission,
	0 = No coma or stupor
	1 = Deep Stupor
	2 = Coma
*/

if not missing(AGE) then do;
	if AGE GE 40 and AGE LE 63 then agegroup = 0;
	else agegroup = 1;
	if AGE GT 63 then old = 1;
	else old = 0;
	if AGE LT 40 then young = 1;
	else young = 0;	
end;

if RACE in ('1' '2' '3') then do; /* Creates dummy variables for race for use in proc logistic step.
	with 'Other', '3' as reference.*/
	WHITE = (RACE = '1');
	AF_AM = (RACE = '2');
end;

if GENDER in ('0' '1') then female = (GENDER = '1'); /* Creates dummy variables for gender with 'Female' reference. */

label ID = 'Identification number' /* Adds labels to the variables for easier references in the date */
	  STA = 'vital status'
	  AGE = 'Age of the patient'
	  GENDER = 'Gender of the patient'
	  RACE = 'Race of patient'
	  SER = 'Service'
	  CAN = 'Was cancer a part of the problem'
	  CRN = 'History of Chronic Renal Falure'
	  INF = 'Infection probable at time of admittmitance to ICU'
	  CPR = 'Was CPR issued prior to ICU admission?'
	  SYS = 'Systolic blood pressure at ICU admission'
	  HRA = 'Heart rate at ICU admission'
	  PRE = 'Has the patient been into the ICU within 6 months'
	  TYP = 'Type of Admission'
	  FRA = 'Was there a long bone (such as the thigh), multiple bones broken'
	  PO2 = 'PO2 from initial blood gases'
	  PH = 'pH of initial blood gasses'
	  PCO = 'PCO2 from initial blood gases'
	  BIC = 'Bicarbonate from initial blood gases'
	  CRE = 'Creatinine from initial blood gases'
	  LOC = 'Level of Consciousness at ICU admission';

format STA live_or_dead. /* Assigns what we put up in the 'proc format' statement to our variables in the datastep */
	   GENDER $gendergroup.
	   AGE agegroup.
	   RACE $racegroup.
	   SER medsurg.
	   CAN cancer.
	   CRN renal.
	   INF infection.
	   CPR cpradmin.
	   PRE previous.
	   TYP admintype.
	   FRA fracture.
	   PO2 oxygen.
	   PH pH.
	   PCO carbond.
	   BIC bicarb.
	   CRE creatinine.
	   LOC consciousness. ;
	   
proc print data = icu (obs = 5); /* Simple 'proc print' to check output. */
run;

proc univariate data = icu normal; /* Will give us a very thourough set of descriptive statistics of 
	the listed variables. The 'normal' in both the 'proc univariate' statement and with the individual 
	variables below will first print the histogram of each of the respected variables and will then superimpose a normal curve on it.*/
title " Descriptive statistics for the age of the patient.";
var AGE;
histogram AGE / normal midpoints= 15 to 95 by 15;
run;
quit;

proc freq data = icu; /* Will show us the frequency of the following variables by their values. */
title 'Frequency count for the following variables';
tables STA GENDER RACE / nocum nopercent;
run;

proc gchart data = icu;
title 'Bar chart for of the gender of the patients.';
vbar GENDER;
run;

proc gchart data = icu;
title 'Bar chart of the race of the patients.';
vbar RACE;
run;

proc corr data = icu nosimple;
title 'Correlation amongst the variables';
var STA AGE LOC;
run;

proc logistic data = icu descending;
title 'Predicting vitality if admitted to the ICU based on age';
model STA = old young /
risklimits /*Will see if age has any affect on living or dying */
selection = forward;

proc logistic data = icu descending; /* Begins the logistics test. */
title 'Predicting vitality if admitted to the ICU based on race and gender.';
model STA = female WHITE/ /* will look at if the person's race or gender is significant in their survival
with Ho= they live and Ha = they die. */
risklimits
selection = forward;

proc logistic data = icu descending;
title ' Predicting vitality if admitted to the ICU based on the consciousness of patient. ';
model STA = LOC  / /* Does their level of consciousness affect their chances of survival if
admitted to the ICU? */
risklimits
selection = forward;
run;
quit;
