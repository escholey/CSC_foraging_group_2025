function agent = preprocess_agent(data, travel_time)
    % Build action sequence (stay=1 repeated leaveT seconds, then leave=2 repeated travel_time seconds)
    a = arrayfun(@(lt,ev) [ones(1,round(lt)) , 2*ones(1, travel_time(ev))], ...
                 data.lt(:), data.env(:), 'UniformOutput', false);
    agent = data;
    agent.action = [1, cat(2, a{:})]';       % start with 'stay'
    agent.block_switch_points = [find(diff(data.env)~=0 | diff(data.ben)~=0); numel(agent.action)-1];

    % Compute switch points (when subject switched blocks)
    block_idx = [true; diff(data.env)~=0 | diff(data.ben)~=0];
    agent.env_order = data.env(block_idx).';
    agent.ben_order = data.ben(block_idx).';
end
