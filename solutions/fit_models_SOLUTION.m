function model = fit_models_SOLUTION(model, data, iter)
options = optimoptions('fmincon','Display','none');

fprintf('=== MODEL %s ===\n', model.name);

travel_time = [3, 5]; % CHANGE THIS IF FITTING TO EXPERIMENT 1 


num_subjects = length(unique(data.sub));
% pre-size per model (num_params (k) varies!)
% this code sets up the correct parameters depending on the model we're using e.g. which combinations of self vs other
spec = build_param_spec(model); 
num_params = spec.k; % number of parameters
lb = spec.lb;
ub = spec.ub ;

% Generate starting parameters for fmincon within [lb, ub]
rng(123);                                  % reproducible
init_params = rand(iter, num_params) .* (ub - lb) + lb;      % each row is one start
% bias certain parameters to be lower - more realistic than assuming
% uniform distribution between lower bound and upper bound
alpha_cols = find(contains(spec.names, 'alpha'));   % learning rates
init_params(:, alpha_cols) = init_params(:, alpha_cols).^2;           % bias toward 0

beta_cols = find(contains(spec.names, 'beta'));     % betas
init_params(:, beta_cols) = init_params(:, beta_cols).^(1/3);         % bias toward lower values
init_params(:, beta_cols) = lb(beta_cols) + (ub(beta_cols)-lb(beta_cols)) .* init_params(:, beta_cols);

% Empty containers for results 
min_NLL        = zeros(num_subjects,1);
min_NLL_params = nan(num_subjects, num_params);
BIC            = zeros(num_subjects,1);
AIC            = zeros(num_subjects,1);

for iS = 1:num_subjects
    fprintf('Subject %d\n', iS);

    % subject data into scalar struct
    subject_data = table2struct(data(data.sub==iS,:), 'ToScalar', true);

    agent = preprocess_agent(subject_data, travel_time); % converts leaving times into sequence of stay/leave actions 

    % objective
    model_func = @(x) fit_wrapper(x, agent, model);

    NLL_eval = zeros([iter, 1]); % container for negative log likelihood for each iteration
    fit_params = zeros([iter, num_params]); % container for best fit params for each iteration

    parfor ii = 1:iter % NOTE: can switch off parallel processing by just putting 'for' if you're having problems
        [fit_params(ii,:), NLL_eval(ii)] = fmincon(model_func, init_params(ii,:), [], [], [], [], lb, ub, [], options);
    end

    % best start
    [min_NLL(iS), idx] = min(NLL_eval);
    min_NLL_params(iS,:) = fit_params(idx,:);

    % ** CALCULATE THE BIC AND AIC.   % SOLUTION 
    % HINT: you will need to calculate the number of choices/observations,
    % and this is NOT the total number of  timesteps in the task. Think
    % carefully about this. 
    n_choices = sum(round(agent.lt)); % how many choices/observations do we have? The number of stay choices
    BIC(iS) = num_params*log(n_choices) + 2*min_NLL(iS); 
    AIC(iS) = 2*num_params + 2*min_NLL(iS); 
end

% stash into the model struct
model.best_params     = min_NLL_params;
model.param_names     = spec.names;
model.BIC             = BIC;
model.AIC             = AIC;
model.median_params   = median(min_NLL_params, 1, 'omitnan');

fprintf('MODEL %s DONE\n', model.name);
end
