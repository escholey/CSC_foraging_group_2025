function [neg_log_lik,trial_vars,time_vars] = fit_model_MVT_self_other(agent,params,model,fit_flag)
% Birmingham-Leiden Computational Social Cognition (CSC) Summer School 2025
% MVT foraging model
% Emma Scholey, 19 August 2025

% fit_model_MVT_self_other.m is main simulation and fitting script for all models

% INPUTS:
%
%   agent: data container for each subject. Includes real subject data if fitting, or
%   empty if simulating
%
%   model: specifies which model we're simulating or fitting 
%
%   params: parameters we're simulating or fitting
%
%   fit_flag: are we simulating or fitting?
%
% OUTPUTS:
%   neg_log_lik: negative log likelihood for model comparison (e.g. calculating BIC)
%   trial_vars: trial by trial results: leaving time for each patch x environment
%   x beneficiary
%   time_vars: fine-grained results: probabilities and actions taken at each timestep

%% Set up
% possible actions
leave = 2;
stay = 1;

% set up parameters
% reward sensitivity
if model.n_rew == 1
    rew_sens = [params.rew_sens, params.rew_sens];
elseif model.n_rew == 2
    rew_sens = [params.rew_sens_self, params.rew_sens_other];
end

% inverse temperature
if model.n_beta == 1
    beta = [params.beta, params.beta];
elseif model.n_beta == 2
    beta = [params.beta_self, params.beta_other];
end

% learning rate
if model.n_alpha == 1
    alpha = [params.alpha, params.alpha];
elseif model.n_alpha == 2
    alpha = [params.alpha_self, params.alpha_other];
end


% set up task
task.num_blocks = 12; % 3 repeats of the 4 farms
task.block_time = 300;
task.travel_time = [3, 5];  % CHANGE THIS IF FITTING TO EXPERIMENT 1
task.opt_BRR = [23.09, 19.10]; % MVT optimal background reward rates in rich versus poor environment
task.decay_rate = 0.11; % how the patch decays with successive harvests
task.r0 = [34.5, 57.5]; % initial patch yield

% set up empty datafames
if fit_flag == 0
    action = zeros(task.block_time * task.num_blocks + 1,1); % what action taken on each timestep
    BRR = zeros(task.block_time * task.num_blocks + 1,1); % estimated background reward rate

    env_order = [1,2,1,2,1,2,1,2,1,2,1,2]; % 1 = rich, 2 = poor
    ben_order = [1,1,2,2,1,1,2,2,1,1,2,2]; % 1 = self, 2 = other

elseif fit_flag ==  1

    action = agent.action; 
    BRR = zeros(numel(action)+1,1); % estimated background reward rate

    env_order = agent.env_order;
    ben_order = agent.ben_order;

    % Timesteps when subject switched blocks
    block_switch_points = agent.block_switch_points;
end

% set up first block - which environment and beneficiary?
block_number = 1;
env = env_order(1);
ben = ben_order(1);

% set up first patch encounter
action(1) = stay; % start by staying in a patch
patch_n = 0; % 0 patches visited right now
arrive = 1; % start by arriving at new patch
BRR(1) = task.opt_BRR(env); % initialise background reward rate
t = 1; % timestep index
time_in_block = 1;

log_lik = 0; % for fitting

while block_number <= task.num_blocks

    if action(t) == stay % take action to stay

        if arrive % if arriving in the patch
            time_in_patch = 1; % first second in patch
            patch_n = patch_n + 1; % patch number increases

            if fit_flag == 1
                if patch_n > length(agent.lt) % ignore the last patch - doesn't count
                    break
                end
            end

            if fit_flag == 0
                patch = randi([1,2]); % randomly encounter patch with 50% likelihood % CHANGE THIS IF FITTING TO EXPERIMENT 1
            elseif fit_flag == 1
                patch = agent.patch(patch_n); % select patch type from their real order
            end
            arrive = 0; % no longer arriving
        end

        patch_reward = task.r0(patch)*exp(-task.decay_rate*time_in_patch); % reward depends on time in patch and patch type

        % is background reward rate fixed or estimated?
        if model.learn
            RPE = patch_reward - BRR(t); % estimate average reward rate with delta learning rule
            BRR(t+1) = BRR(t) + alpha(ben) * RPE;
        else
            BRR(t+1) = task.opt_BRR(env); % just assume full knowledge of the average reward rate
        end

        % calculate action probabilities using softmax rule
        p_leave = (1 + exp(beta(ben) .* (rew_sens(ben) * patch_reward-BRR(t)))).^-1; % softmax rule

        p_action = [1 - p_leave, p_leave]; % [p(stay), p(leave)]

        if fit_flag == 1 % if fitting data
            p_selected = p_action(action(t+1)); % what is probability of action they actually took
            p_selected(p_selected == 0) = eps(0); % prevent log(pselected = 0) going to infinity
            log_lik = log_lik + log(p_selected); % update log likelihood
        else % if simulating, then simulate their actions based on probabilities
            action(t+1) = (rand < p_leave) + 1 ;
        end

        % if the next action is to leave
        if action(t+1) == leave
            time_in_travel = 1; % if next action is leave, then reset travel time counter
            leaveT(patch_n,1) = time_in_patch; % log the patch leaving time
            sim_patch(patch_n,1) = patch;
            sim_env(patch_n,1) = env;
            sim_ben(patch_n,1) = ben;

        end

        time_in_patch = time_in_patch + 1; % time in patch increases
        time_in_block = time_in_block + 1; % time in block increases
        t = t + 1;

    elseif action(t) == leave % take action to leave

        time_in_patch = 0; % not in a patch anymore

        if time_in_travel == task.travel_time(env) % if on the last second of travelling

            % --- block transition ---
            if fit_flag == 0
                % SIMULATION: switch after fixed time per block
                if time_in_block >= task.block_time
                    block_number = block_number + 1;
                    if block_number > task.num_blocks
                        break
                    end
                    env = env_order(block_number);
                    ben = ben_order(block_number);
                    time_in_block = 1; % reset counter
                end

            elseif fit_flag == 1
                % FITTING: switch exactly when subject switched
                if patch_n >= block_switch_points(block_number)
                    block_number = block_number + 1;
                    if block_number > task.num_blocks
                        break
                    end
                    env = env_order(block_number);
                    ben = ben_order(block_number);
                    % no need to reset time_in_block (optional)
                end
            end

            action(t+1) = stay;
            arrive = 1; % about to arrive in new patch
        elseif time_in_travel < task.travel_time(env) % if still travelling
            action(t+1) = leave;
        end

        patch_reward = 0; % no reward during travelling

        if model.learn
            RPE = patch_reward - BRR(t); % estimate average reward rate with delta learning rule
            BRR(t+1) = BRR(t) + alpha(ben) * RPE;
        else
            BRR(t+1) = task.opt_BRR(env); % just assume full knowledge of the average reward rate
        end

        time_in_travel = time_in_travel + 1; % increase time spent travelling
        time_in_block = time_in_block + 1;
        t = t + 1;

    end
end

neg_log_lik = -log_lik; % we want to find the parameter combinations that produce the MAXIMUM log likelihood.
% BUT when fitting, it's easier to find the MINIMUM. So we take the
% negative log likelihood

time_vars.BRR = BRR;
time_vars.action = action;

trial_vars.patch = sim_patch;
trial_vars.env = sim_env;
trial_vars.ben = sim_ben;
trial_vars.leaveT = leaveT;
trial_vars = struct2table(trial_vars);
