* Reading the datafile;
proc import datafile="/home/bandlmd20/A_448_project/SAheart.csv"
     out=heart;
run; 
*proc print data=heart;
*run;
* descriptive statistics;
proc univariate data=heart;
	var sbp tobacco ldl adiposity typea obesity alcohol age;
	ods select Moments BasicMeasures;
run;
proc freq data=heart;
	tables chd famhist;
run;		
* defining new class variable;
data heart_dis;
	set heart;
	class="classA";
	if chd=1 AND famhist="Present" then class="classB";
	if chd=0 AND famhist="Absent" then class="classC";
	if chd=1 AND famhist="Absent" then class="classD";
run;
* frequency plot for class;
proc gchart data=heart_dis;
   *format sales dollar8.;
   hbar class / width=6 sum raxis=axis1;
run;   

* LDA-QDA program;
proc stepdisc data=heart_dis sle=.05 sls=.05;
   	class class;
   	var sbp tobacco ldl adiposity typea obesity alcohol age ;
   	*ods select selectionSummary; 
run;
proc discrim data=heart_dis manova pcov;
   class class;
   var tobacco ldl typea age ;
run;
proc discrim data=heart_dis pool=test crossvalidate;
   class class;
   var tobacco ldl typea age ;
   priors proportional;
run;

* making four classes into three classes;
data heart_dis_3_cls;
set heart_dis;
newclass="classA_D";
if class="classB" then newclass="classB";
if class="classC" then newclass="classC";
run;

* frequency plot for class;
proc gchart data=heart_dis_3_cls;
   hbar newclass / width=6 sum raxis=axis1;
run; 

* LDA-QDA program;
proc stepdisc data=heart_dis_3_cls sle=.05 sls=.05;
   	class newclass;
   	var sbp tobacco ldl adiposity typea obesity alcohol	age;
   	ods select Summary; 
run;
proc discrim data=heart_dis_3_cls manova pool=test;
   class newclass;
   var ldl age typea;
run;
proc discrim data=heart_dis_3_cls pool=test crossvalidate out=discrim_out canonical;
   class newclass;
   var ldl typea age ;
   priors proportional;
run;

	  
* 3-D scatter plot;
data heart_3d;
   set heart_dis_3_cls;
   length hclass $12. Colorval $8. Shapeval $8.;
   if newclass="classA_D" then
      do;
         hclass='classA_D';
         shapeval='club';
         colorval='vibg';
      end;
   if newclass="classB" then
      do;
         hclass='classB';
         shapeval='diamond';
         colorval='depk';
      end;
   if hclass='classC' then
      do;
         hclass='classC';;
         shapeval='spade';
         colorval='dagb';
      end;
run;

 /* Define titles and footnotes for graph */
title1 '3-D visualization of significant variables';
*title2 'Physical Measurement';
*title3 'Source: Fisher (1936) Iris Data';
*footnote1 j=l '  Petallen: Petal Length in mm.'
          j=r 'Petalwid: Petal Width in mm. ';
*footnote2 j=l '  Sepallen: Sepal Length in mm.'
          j=r 'Sepal Width not shown      ';
*footnote3  ' ';

 /* Create the graph using a NOTE statement  */
 /* to create the legend                     */
proc g3d data=heart_3d;
   scatter ldl*age=typea
           / color=colorval
             shape=shapeval;

  /* Create a legend using NOTE statements */
   note;
   note j=r c=dagb 'Class C      '
        j=r c=depk ' Class B      '
        j=r c=vibg 'Class A_D         ';
run;
quit; 

 








