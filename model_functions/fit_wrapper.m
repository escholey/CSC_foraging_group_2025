function [negLL, trial_vars, time_vars] = fit_wrapper(x, agent, model)
    params = vector2params(x, model); 
    [negLL, trial_vars, time_vars] = fit_model_MVT_self_other(agent, params, model, 1);
end
