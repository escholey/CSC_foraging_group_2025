%%%%% Description of Data tables %%%%%%%

These files are used to test for correlations between FRR and BRR effects and psychological self-report scales. 
The R script colled 'Correlations' uses these files to create plots and correct for multiple comparison  

%%%% 'questionnaire_measures_CSC2025_Foraging.csv' 

This is the data to perform correlations. These correlations were performed in SPSS, with Spearman correlations for AQ10 scores, and Pearson correlations for the rest of the scales
Each row is a subject across studies 1 and 2. Subjects who did not pass a catch trial were excluded from this data table 
Each column corresponds to a variable value:

exp		: Which study participants took part of, either study 1 (1) or 2 (2)
QCAE_CE	: Z-score of participant score in the Cognitive subscale of the Questionnaire of Cognitive and Affective Empathy
QCAE_AE		: Z-score of participant score in the Affective subscale of the Questionnaire of Cognitive and Affective Empathy
AMI_BAScore	: Z-score of participant score in the Behavioural Activation subscale of the Apathy-Motivation Index
AMI_SMScore	: Z-score of participant score in the Social Motivation subscale of the Apathy-Motivation Index
AMI_ESScore	: Z-score of participant score in the Emotional Sensitivity subscale of the Apathy-Motivation Index
AQ10		: Z-score of participant score in the Autism Spectrum Quotient

