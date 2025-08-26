function spec = build_param_spec(model)
    names = {}; lb = []; ub = [];

    % helper
    function add(name, lo, hi)
        names = [names, {name}];
        lb    = [lb, lo];
        ub    = [ub, hi];
    end

    % betas
    if model.n_beta==1
        add('beta', 0, 50);
    else
        add('beta_self', 0, 50); add('beta_other', 0, 50);
    end

    % reward sensitivity
    if model.n_rew==1
        add('rew_sens', 0, 5);
    else
        add('rew_sens_self', 0, 5); add('rew_sens_other', 0, 5);
    end

    % learning rate
    if model.n_alpha==1
        add('alpha', 0, 1);
    else
        add('alpha_self', 0, 1); add('alpha_other', 0, 1);
    end

    spec.names = names;
    spec.lb    = lb;
    spec.ub    = ub;
    spec.k     = numel(lb);
end
