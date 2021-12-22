function[dT_mdt,T_h,T_c]=CF_HXER_DTMDT_v0(T_m,time,UA_h,UA_c,C_tot,R_cond_tot,N)

    % inputs
        % T_m_ini - initial temperature of metal nodes [K]
        % time - during simulation [s]
        % UA_h - hot flow thermal conductance [W/K]
        % UA_c - cold flow thermal conductance [W/K]
        % C_tot - total heat capacity in metal [J/K]
        % R_cond_tot - total axial conduction resistance [K/W]
        % N - number of nodes [-]
    
    % calculate axial conduction resistance between each node, [K/W]
        R_cond = R_cond_tot/(N-1);
      
    % hot flow nodes, T_h
        % create matrix for hot flow temperature profile
        T_h=zeros(N,1);
        % call function to find hot flow inlet conditions @ node 1
        [T_h(1),C_dot_h_in] = CF_HXER_HOT_INLET_v0(time);
        % assume constant capacitance rate between hot inlet & outlet
        C_dot_h = C_dot_h_in;
        % calculate hot flow temperature @ node 2
        T_h(2)=(1/((UA_h/(2*(N-1)))+C_dot_h))*((C_dot_h*T_h(1))+((UA_h/(2*(N-1)))*(T_m(1)+T_m(2)-T_h(1))));
        % calculate hot flow temperatures @ nodes 3 to N
        for i=2:(N-1)
            T_h(i+1)=(1/((UA_h/(2*(N-1)))+C_dot_h))*((C_dot_h*T_h(i))+((UA_h/(2*(N-1)))*(T_m(i)+T_m(i+1)-T_h(i))));
        end

    % cold flow nodes, T_c
        % create matrix for cold flow temperature profile
        T_c=zeros(N,1);
        % call function to find cold flow inlet conditions @ node N
        [T_c(N),C_dot_c_in] = CF_HXER_COLD_INLET_v0(time);
        % assume constant capacitance rate between hot inlet & outlet
        C_dot_c = C_dot_c_in;
        % calculate cold flow temperature @ node N-1
        T_c(N-1)=(1/((UA_c/(2*(N-1)))+C_dot_c))*((C_dot_c*T_c(N))+((UA_c/(2*(N-1)))*(T_m(N)+T_m(N-1)-T_c(N))));
        % calculate cold flow temperature @ nodes N-2 to 1
        for i=(N-1):-1:2
            T_c(i-1)=(1/((UA_c/(2*(N-1)))+C_dot_c))*((C_dot_c*T_c(i))+((UA_c/(2*(N-1)))*(T_m(i)+T_m(i-1)-T_c(i))));
        end

    % metal nodes, dT_mdt
        % create matrix for metal temperature change wrt time
        dT_mdt=zeros(N,1);
        % calculate metal temperature change wrt time @ node 1
        dT_mdt(1)=((2*(N-1)/(R_cond*C_tot))*(T_m(2)-T_m(1)))+((UA_h/C_tot)*(T_h(1)-T_m(1)))+((UA_c/C_tot)*(T_c(1)-T_m(1)));
        % calculate metal temperature change wrt time @ nodes 2 to N-1
        for i=2:(N-1)
            dT_mdt(i)=(((N-1)/(R_cond*C_tot))*(T_m(i-1)+T_m(i+1)-2*T_m(i)))+((UA_h/C_tot)*(T_h(i)-T_m(i)))+((UA_c/C_tot)*(T_c(i)-T_m(i)));
        end
        % calculate metal temperature change wrt time @ node N
        dT_mdt(N)=((2*(N-1)/(R_cond*C_tot))*(T_m(N-1)-T_m(N)))+((UA_h/C_tot)*(T_h(N)-T_m(N)))+((UA_c/C_tot)*(T_c(N)-T_m(N)));
        
end
