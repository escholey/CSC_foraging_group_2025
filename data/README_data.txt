%%%%% Description of Data tables %%%%%%%

The following description of data sets are applied for both studies 1 and 2. Each study is identified by 'exp1' and 'exp2' in each file. Data was divided in different files to separate and identify different analyses and aims. 

All these files are read by the analysis R scripts 'Analyses_Exp1' and 'Analyses_Exp2' for studies 1 and 2 respectively

%%%% 'trialbytrial_exp.csv' 

This is the data to perform the mixed models where leaving times and reward rates at time of leaving are predicted by the different variables of the SOFT
Each row is one trial in the SOFT
Each column corresponds to a variable value:

sub		: Subject ID
patch		: Yield of the patch of that trial - High (2) or Low (1) yield
env		: Environment in that trial - Rich (1) or Poor (2) background reward rate
ben		: Beneficiary of the reward in that trial - Self (1) or Other (2)
lt		: Leaving time in which the participant left the patch (in seconds). 
rr		: Reward rate of the patch at the time in which the participant left the patch


%%%% 'for_plots_Means_exp.csv' and 'forplots_RR_exp.csv'

These correspond to the mean leaving times and mean reward rate at time of leaving, with their corresponding within-subject SEM, for each condition to create plots
Each column corresponds to a variable value:

Lts: 		: Mean leaving time
RR		: Mean reward rate at time of leaving the patch
wse		: Within-subject SEM.  
Environment	: Type of farm, considering its background reward rate (Rich and Poor) and the beneficiary (Self and Other)  
Patch		: Type of patch, either Low or High Yield. 

%%%% 'LT_opt_exp.csv'

Mean leaving times for each participant in each condition to contrast with optimal solution given by MVT. 
Each row corresponds to a subject
Each column corresponds to a variable value:

sub		: Subject ID
Bad_RichSelf	: Leaving times for Low Yield Patch / Rich Environment / Self trials
Good_RichSelf	: Leaving times for High Yield Patch / Rich Environment / Self trials
Bad_PoorSelf	: Leaving times for Low Yield Patch / Poor Environment / Self trials
Good_PoorSelf	: Leaving times for High Yield Patch / Poor Environment / Self trials
Bad_RichOther	: Leaving times for Low Yield Patch / Rich Environment / Other trials
Good_RichOther	: Leaving times for High Yield Patch / Rich Environment / Other trials
Bad_PoorOther	: Leaving times for Low Yield Patch / Poor Environment / Other trials
Good_PoorOther	: Leaving times for High Yield Patch / Poor Environment / Other trials
Opt_BadRich	: Optimal leaving time for Low Yield Patch / Rich Environment trials
Opt_GoodRich	: Optimal leaving time for High Yield Patch / Rich Environment trials
Opt_BadPoor	: Optimal leaving time for Low Yield Patch / Poor Environment trials
Opt_GoodPoor	: Optimal leaving time for High Yield Patch / Poor Environment trials


%%%% 'Lts_effect_exp.csv'
Data to contrast FRR (high yield - low yield patch) and BRR (poor - rich environment) effects on leaving times against the optimal solution given by MVT. 
Each row corresponds to a subject
Each column corresponds to a variable value:

sub		: Subject ID
ltPatch_Self	: Mean leaving times for FRR effect in self trials
ltPatch_Other	: Mean leaving times for FRR effect in other trials
ltPatch_Optimal	: Optimal leaving time for FRR effect 
ltEnv_Self		: Mean leaving times for BRR effect in self trials
ltEnv_Other	: Mean leaving times for BRR effect in other trials
ltEnv_Optimal	: Optimal Leaving time for BRR effect 


%%%% 'RR_Env_exp.csv'
Mean of obtained background reward rate in each environment, considering its BRR and beneficiary
Each row corresponds to a subject
Each column corresponds to a variable value:

sub		: Subject ID
Rich_Self		: Mean of obtained background reward rate in rich environments for self trials
Rich_Other	: Mean of obtained background reward rate in rich environments for other trials
Poor_Self		: Mean of obtained background reward rate in poor environments for self trials
Poor_Other	: Mean of obtained background reward rate in poor environments for other trials


%%%% 'LT_adjustedoptimal_exp.csv'

Mean leaving times of each condition when substracted by the optimal MVT solution adjusted according to each participant's obtained BRR. 
Each row corresponds to a subject
Each column corresponds to a variable value:

sub		: Subject ID
Bad_RichSelf	: Leaving times minus adjusted MVT optimal for Low Yield Patch / Rich Environment / Self trials
Good_RichSelf	: Leaving times minus adjusted MVT optimal for High Yield Patch / Rich Environment / Self trials
Bad_PoorSelf	: Leaving times minus adjusted MVT optimal for Low Yield Patch / Poor Environment / Self trials
Good_PoorSelf	: Leaving times minus adjusted MVT optimal for High Yield Patch / Poor Environment / Self trials
Bad_RichOther	: Leaving times minus adjusted MVT optimal for Low Yield Patch / Rich Environment / Other trials
Good_RichOther	: Leaving times minus adjusted MVT optimal for High Yield Patch / Rich Environment / Other trials
Bad_PoorOther	: Leaving times minus adjusted MVT optimal for Low Yield Patch / Poor Environment / Other trials
Good_PoorOther	: Leaving times minus adjusted MVT optimal for High Yield Patch / Poor Environment / Other trials


