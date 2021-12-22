function[T_h_in,C_dot_h_in]=CF_HXER_HOT_INLET_v0(time)
    
    % time [s] - from dT_mdt function for current time
    % T_h_in_ini [K] - hot fluid inlet initial temperature
    % T_h_in_f [K] - hot fluid inlet final temperature 
    % beta_T_h_in [K/s] - hot fluid inlet temperature ramp rate
    % C_dot_h_in_ini [W/K] - hot fluid inlet initial capacitance rate
    % C_dot_h_in_f [W/K] - hot fluid inlet final capacitance rate
    % beta_C_dot_h_in [W/K-s] - hot fluid capacitance rate ramp rate
    
    % specify conditions for hot inlet specification
    condition = 1;
    
     % for constant inputs
    if condition == 1
        T_h_in = 875;
        C_dot_h_in = 20;
    end
    
    % for linear ramp inputs
    if condition == 2
        
        beta_T_h_in = 25;
        T_h_in_ini = 300;
        T_h_in_fin = 875;
        beta_C_dot_h_in = 1;
        C_dot_h_in_ini = 10;
        C_dot_h_in_fin = 20;
        
        % find duration of ramp period for hot fluid inlet temperature
            if beta_T_h_in == 0
                t_ramp_T_h_in = 0;
            else
                t_ramp_T_h_in = (T_h_in_fin-T_h_in_ini)/beta_T_h_in;
            end
        % calculate hot fluid inlet temperature
            if time<t_ramp_T_h_in
                T_h_in = T_h_in_ini + beta_T_h_in*time;
            else
                T_h_in = T_h_in_fin;
            end
        % find duration of ramp period for hot fluid inlet capacitance rate
            if beta_C_dot_h_in == 0 
                t_ramp_C_dot_h_in = 0;
            else
                t_ramp_C_dot_h_in = (C_dot_h_in_fin-C_dot_h_in_ini)/beta_C_dot_h_in;
            end
        % calculate hot fluid inlet capacitance rate during ramp up period
            if time<t_ramp_C_dot_h_in
                C_dot_h_in = C_dot_h_in_ini + beta_C_dot_h_in*time; 
            else
                C_dot_h_in = C_dot_h_in_fin;
            end    
            
    end   
    
    % for alternatively specified inputs
    if condition == 3
        T_h_in = 1;
        C_dot_h_in = 1;
        t_ramp_T_h_in = 0;
        t_ramp_C_dot_h_in = 0;
    end

end