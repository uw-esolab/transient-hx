function[T_c_in,C_dot_c_in]=CF_HXER_COLD_INLET_v0(time)
    
    % time [s] - from dT_mdt function for current time
    % T_c_in_ini [K] - cold fluid inlet initial temperature
    % T_c_in_f [K] - cold fluid inlet final temperature 
    % beta_T_c_in [K/s] - cold fluid inlet temperature ramp rate
    % C_dot_c_in_ini [W/K] - cold fluid inlet initial capacitance rate
    % C_dot_c_in_f [W/K] - cold fluid inlet final capacitance rate
    % beta_C_dot_c_in [W/K-s] - cold fluid capacitance rate ramp rate
    
    % specify conditions for cold inlet specification
    condition = 1;
    
   % for constant inputs
    if condition == 1
        T_c_in = 375;
        C_dot_c_in = 40;
    end
    
    % for linear ramp inputs
    if condition == 2
        
        beta_T_c_in = 5;
        T_c_in_ini = 300;
        T_c_in_fin = 375;
        beta_C_dot_c_in = 1;
        C_dot_c_in_ini = 10;
        C_dot_c_in_fin = 20;

        % find duration of ramp period for cold fluid inlet temperature
            if beta_T_c_in == 0
                t_ramp_T_c_in = 0;
            else
                t_ramp_T_c_in = (T_c_in_fin-T_c_in_ini)/beta_T_c_in;
            end
        % calculate hot fluid inlet temperature
            if time<t_ramp_T_c_in
                T_c_in = T_c_in_ini + beta_T_c_in*time;
            else
                T_c_in = T_c_in_fin;
            end
        % find duration of ramp period for hot fluid inlet capacitance rate
            if beta_C_dot_c_in == 0
                t_ramp_C_dot_c_in = 0;
            else
                t_ramp_C_dot_c_in = (C_dot_c_in_fin-C_dot_c_in_ini)/beta_C_dot_c_in;
            end
        % calculate hot fluid inlet capacitance rate during ramp up period
            if time<t_ramp_C_dot_c_in
                C_dot_c_in = C_dot_c_in_ini + beta_C_dot_c_in*time; 
            else
                C_dot_c_in = C_dot_c_in_fin;
            end  
            
    end
    
    % for alternate inputs
    if condition == 3
        T_c_in = 1;
        C_dot_c_in = 1;
        t_ramp_T_c_in = 0;
        t_ramp_C_dot_c_in = 0;
    end
    
end