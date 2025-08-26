% Emma Scholey, Luis Sebastian Contreras-Huerta & Matthew Apps
% Birmingham-Leiden Computational Social Cognition (CSC) Summer School 2025
% Computational modelling of prosocial foraging decisions

%% Step 1. Load the data
close all
clear

% ** SET YOUR DIRECTORY PATH **
dir = '~/Dropbox/conferences/2025-CSC-group-work/CSC_foraging_group_2025';
cd(dir)
addpath("model_functions/") % where all the functions you need are

% ** Read through the README. We're using the trialbytrial_exp2.csv dataset
% ** Do you understand what each of the columns represents? 

data = readtable('./data/exp2/trialbytrial_exp2.csv');

num_subjects = length(unique(data.sub)); % how many subjects do we have? 

%% Step 2. Visualise individual subject leaving times

% Let's learn about the data by plotting it. 
% We don't need to plot everyone, just a few example subjects 

% Let's plot the leaving times by patch number for subject 10 

example_subject_id = 10;
subject_data = data(data.sub == example_subject_id, :);

% X = number of patches they completed 
trials = (1:height(subject_data))'; 
% Y = leaving time
lt = subject_data.lt;

% Plot all leaving times per patch across the task
figure;
scatter(trials, lt, 36, 'filled');
xlabel('Patch number'), ylabel('Patch leaving time (s)'), ylim([0, inf]), set(gca, 'FontSize', 14);
title('Leaving times for example subject');

%** Feel free to inspect a few participants' leaving times

%% Now let's plot by patch type.
% What trends do you notice? 

grp = categorical(subject_data.patch);

figure;
gscatter(trials, lt, grp);
xlabel('Patch number'), ylabel('Patch leaving time (s)'), ylim([0, inf]), set(gca, 'FontSize', 14);
title('Leaving times by patch type');

%** ADD LEGEND LABELLING EACH PATCH TYPE

%% ** Your turn - add plot of patch leaving times by ENVIRONMENT ** %
% What trends do you notice? 

%% ** Your turn - add plot of patch leaving times by BENEFICIARY ** %
% What trends do you notice? 

%% ************************* SIMULATE ********************************* 

%% Step 3. Simulate basic MVT model + softmax rule ('noisy' choices)
close all

% To start, we're going to ignore the beneficiary, and just model a simple
% MVT rule with a bit of noise (from softmax action selection)

% set plot colours
ben_colors = [1 0 0; 0 0 1];  % beneficiary: 2=Other=blue, 1=Self=red
env_weight = [1, 0.5]; % env: 2=Poor=lighter, 1=Rich=darker

% set up parameters 
params.beta = 5; % softmax inverse temperature
params.rew_sens = 1; % patch reward sensitivity

% Run the simulation
[~, trial_vars, time_vars] = simulate_MVT(params);

% average across patch x environment x ben 
idx = sub2ind([2 2 2], trial_vars.patch, trial_vars.env, trial_vars.ben);  % 1..8
mean_leaveT = accumarray(idx, trial_vars.leaveT, [8 1], @mean, NaN);
M = reshape(mean_leaveT, [2 2 2]);   % patch x env x ben

figure, hold on
for iE = 1:2
    for iB = 1:2
        y = squeeze(M(:, iE, iB)); 
        line_color = ben_colors(iB,:) * env_weight(iE);

        plot(y, '.--', 'Color', line_color, 'MarkerSize', 18, 'LineWidth', 1.5)
    end
end
xlabel('Patch type');
ylabel('Mean leaving time (s)');
set(gca, 'FontSize', 14, 'XTick', [1,2],'XTickLabel', {'Low yield', 'High yield'});
legend({'Self – Rich','Other – Rich','Self – Poor','Other – Poor'}, ...
    'Location','bestoutside');
ylim([0, 20])

%% ** Try lowering the beta parameter. How does this change the leaving times?
% ** No need to copy the code, just change the parameters in the section
% above 
%% ** Try changing the given task parameters in the simulate_MVT.m function.
% ** How does changing the decay rate, optimal background reward rate (BRR)
% ** and initial reward (r0) influence the leaving times?
% ** Remember to set it back to what it was before you move on! 

%% How do these simulations compare with the real data? 
% Let's overlay the subjects mean leaving times on the plot

subj_mean_leaveT = readtable("data/exp2/forplots_Means_exp2.csv");
M = reshape(subj_mean_leaveT.Lts, [2 2 2]);   % patch x env x ben

for iE = 1:2
    for iB = 1:2
        y = squeeze(M(:, iE, iB)); 
        line_color = ben_colors(iB,:) * env_weight(iE);

        plot(y, 'Color', line_color, 'MarkerSize', 18, 'LineWidth', 1.5)
    end
end
legend({'Self – Rich','Other – Rich','Self – Poor','Other – Poor', ...
    'Self-rich-data', 'Other-rich-data','Self-poor-data','Other-poor-data'},'Location','bestoutside');

% What do you notice? 
% 1) The model is ignoring the beneficiary right now, so there's no
% difference between self vs other 
% 2) Subjects leave much later than the MVT model. 
% This is overharvesting, and is found across species!
% There are lots of reasons for why foragers overharvest. 
% One way we can model it is with a patch reward senstivity parameter
% This parameter weights patch reward more strongly than background reward 
% in the softmax rule. 

%% ** Try changing the reward sensitivity parameter to 1.5. 
% What happens now?

% Now trying lowering the reward sensitivity parameter. 

%% Step 4. Simulate learning MVT model
% This model is very simple, as it assumes people have a fixed estimate of 
% the background reward rate (BRR). Instead, people may experience changes in 
% the BRR rate over time.  
% Let's introduce a Rescorla-Wagner model that learns BRR in the function:
% simulate_MVT_learning.m

close all

sim_model.learn = 1; % We're now using the Rescorla-Wagner model 

% ** Look at the simulate_MVT script and understand how 
% the learning model works! Ask if anything is unclear. 

params.beta = 2;
params.rew_sens = 1.5;
params.alpha = 0.02;

iter = 50; % run 50 simulations since learning adds noise and we want to average over simulations

for i = 1:iter
    [~, trial_vars, time_vars] = simulate_MVT_learning(params, sim_model);

    % average across patches in a single iteration
    idx = sub2ind([2 2 2], trial_vars.patch, trial_vars.env, trial_vars.ben);  % 1..8
    tmp = accumarray(idx, trial_vars.leaveT, [8 1], @mean, NaN);  
    iter_leaveT(:, i) = tmp;
end

% average across iterations
mean_leaveT = mean(iter_leaveT, 2, 'omitnan');

M = reshape(mean_leaveT, [2 2 2]);   % patch x env x ben

figure, hold on
for iE = 1:2
    for iB = 1:2
        y = squeeze(M(:, iE, iB));   % [patch1; patch2]
        line_color = ben_colors(iB,:) * env_weight(iE);

        plot(y, '.--', 'Color', line_color, 'MarkerSize', 18, 'LineWidth', 1.5)

        % you can add error bars if you want to! 
    end
end

xlabel('Patch type');
ylabel('Mean leaving time (s)');
set(gca, 'FontSize', 14, 'XTick', [1,2],'XTickLabel', {'Low yield', 'High yield'});
legend({'Self – Rich','Other – Rich','Self – Poor','Other – Poor'}, ...
    'Location','bestoutside');
ylim([0, 20])


%% ** Try plotting the background reward rate over time 
% % BRR is found in the time_vars variable 


%% ** Try changing the learning rate parameter (alpha). 
% How does this change the leaving times, and BRR? 
% Tip: the learning rate parameter is typically between 0 and 1,
% but because the agent is learning over timesteps, lower works much better here!


%% ** Try changing the travel time for one of the environments. 
% This is in the task.travel_time in the simulate_MVT_learning.m script
% How does this influence the estimated background reward rate, and patch leaving
% times?

%% Step 5. We've been ignoring the beneficiary! Let's add self vs other parameters
% We'll start with reward sensitivity
% We're now using a new script, simulate_MVT_self_other.
% Check what differences you can notice in the script. 
% Based on these differences, set up the parameters below with a SINGLE
% beta, a SINGLE learning rate, and SELF VS OTHER reward sensitivity 

close all

% ** SET MODEL OPTIONS    


% ** SET PARAMETERS  % SOLUTION 


iter = 50; % run 50 simulations since learning adds noise

for i = 1:iter
    [~, trial_vars, time_vars] = simulate_MVT_self_other(params, sim_model);

    % average across patches in a single iteration
    idx = sub2ind([2 2 2], trial_vars.patch, trial_vars.env, trial_vars.ben);  % 1..8
    tmp = accumarray(idx, trial_vars.leaveT, [8 1], @mean, NaN);  
    iter_leaveT(:, i) = tmp;
end

% average across iterations
mean_leaveT = mean(iter_leaveT, 2, 'omitnan');

M = reshape(mean_leaveT, [2 2 2]);   % patch x env x ben

figure, hold on
for iE = 1:2
    for iB = 1:2
        y = squeeze(M(:, iE, iB));   % [patch1; patch2]
        line_color = ben_colors(iB,:) * env_weight(iE);

        plot(y, '.--', 'Color', line_color, 'MarkerSize', 18, 'LineWidth', 1.5)
    end
end

xlabel('Patch type');
ylabel('Mean leaving time (s)');
set(gca, 'FontSize', 14, 'XTick', [1,2],'XTickLabel', {'Low yield', 'High yield'});
legend({'Self – Rich','Other – Rich','Self – Poor','Other – Poor'}, ...
    'Location','bestoutside');
ylim([0, 20])

clear sim_model

%% ************************* FIT ********************************* 

%% Step 6. Fit the data!
% Now the exciting part, fitting the data! 
% There are some new functions we're using. It's not essential you
% understand them all, but I recommend looking at the
% fit_model_MVT_self_other.m script. This is the same as the simulation
% script, but we now include a fit_flag == 1. This tells the function to use the
% real data, and to compare the model's simulated p(actions) with the
% actual action of the subject, so we can calculate the log likelihoods.

% We're also doing all the nuts and bolts of the fitting (MLE) in the
% fit_models.m function. This takes a model as input, and prodivdes the
% model fitting results as output, including the best fit parameters, 
% AIC and BIC for each subject. However, there's some bits missing that you
% will need to fill in! 

%% ** Look through the fit_models.m script, understand it, and fill in the missing parts 
% Solution is in the solutions folder if you're struggling

%% Now we're ready, let's do some actual fitting 
% First, we'll fit the simplest learning model - a single parameter for
% self vs other

model.name='1_all'; % give it a random name
% set up the model 
model.learn=1; model.n_rew=1; model.n_beta=1; model.n_alpha=1;

first_model_results = fit_models(model, data); %% ** Why does this code not run? What information is the function missing? 

% Why is this missing information important for fitting with MLE? 

%% ** Fixed fitting code
% ** Copy the code above and add the missing information (set to 8 - usually
% we do more, but let's speed it up.)


% ** Have a look through the results and check it all makes sense. Any
% questions, ask! 

%% Step 7. Now try one of the other models
% e.g. with either self vs other learning rates, betas, or reward sensitivity. 
% ** Copy the code from the previous step and amend to repeat the process for your chosen model 


%% ** Check the median best fit parameters, and simulate them 
% ** Copy the simulation code in Step 5 and change the parameters. 
% Does this look like the real data? 

%% Step 8: now fit all of the learning models!
% Model list
models(1).name='1_all';        models(1).learn=1; models(1).n_rew=1; models(1).n_beta=1; models(1).n_alpha=1;
models(2).name='2_rew';        models(2).learn=1; models(2).n_rew=2; models(2).n_beta=1; models(2).n_alpha=1;
models(3).name='2_beta';       models(3).learn=1; models(3).n_rew=1; models(3).n_beta=2; models(3).n_alpha=1;
models(4).name='2_alpha';      models(4).learn=1; models(4).n_rew=1; models(4).n_beta=1; models(4).n_alpha=2;
% ** Fill in the last 3 models with different combinations of self vs other parameters 


% Run the models 
fit_iter = 8;

for m = 1:numel(models)
    model_results(m) = fit_models(models(m), data, fit_iter);
end

% ** Compare the AIC and BIC for the model with the most parameters. What is this telling you?

% If you want to save time, the results are pre-saved in the solutions
% folder
%save('csc_all_model_fits.mat',"solutions/model_results")

%% Step 8. Determine the winning model across participants and visualise results

% ** Calculate the summed BIC across participants for each model, and plot
% a bar graph of BIC by model  

%% Step 9. Determine the winning model for each participant.

% ** Plot the number of subjects that are best fit for each model 

% ** What does this tell you?

%% Step 10. Simulate the median parameters of the winning model 
close all

%% ************************* ANALYSE ********************************* 
%% Step 11. What does the spread of parameters look like for the best model
% ** Plot the parameters for self vs other, and identify any trends/outliers 

%--%
%% BONUS - well done for getting here! 
%-- See suggestions on the slides 



