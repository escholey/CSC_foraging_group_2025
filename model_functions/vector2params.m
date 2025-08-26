function params = vector2params(x, model)
    % Convert flat parameter vector x into a params struct
    i = 1;

    % inverse temperature
    if model.n_beta == 1
        params.beta = x(i); i=i+1;
    elseif model.n_beta == 2
        params.beta_self = x(i); i=i+1;
        params.beta_other = x(i); i=i+1;
    end

    % reward sensitivity
    if model.n_rew == 1
        params.rew_sens = x(i); i=i+1;
    elseif model.n_rew == 2
        params.rew_sens_self = x(i); i=i+1;
        params.rew_sens_other = x(i); i=i+1;
    end

    % learning rate
    if model.n_alpha == 1
        params.alpha = x(i); i=i+1;
    elseif model.n_alpha == 2
        params.alpha_self = x(i); i=i+1;
        params.alpha_other = x(i); i=i+1;
    end
end
