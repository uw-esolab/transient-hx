clear all;

% re-make of hxer_study_501
% re-make of hxer_study_401

% from hxer_study_302
% axial conduction included

% inputs
    % fluid parameters
        UA_h = 40;                              %[W/K] thermal conductance on hot-flow side
        UA_c = 40;                              %[W/K] thermal conductance on cold-flow side
        UA = 1/((1/UA_h)+(1/UA_c));             %[W/K] overall thermal conductance
    % hxer parameters 
        N = 101;                                %[-] number of nodes, (N-1) should be divisible by 4
        DELTAN = (N-1)/4;                       %[-] set up for graphing
        x_star = zeros(N,1);                    %[-] create matrix for dimensionless position x-axis
        for i=1:N
            x_star(i) = i/N;                    %[-] step through each node to fill matrix
        end
        C_tot = 80;                             %[J/K] total heat capacity of metal (thermal mass)  
        R_cond_tot = 0.1;                       %[K/W] total axial conduction resistance of metal
        T_m_ini = zeros(1,N);                   %[K] initial temperature of metal nodes
        for i=1:N
            T_m_ini(1,i) = 300;                 %[K] user can specify whether this is constant or not
        end
        
% variables for integration
    M = 121;                                    %[-] number of time steps, (M-1) should be divisible by 5
    DELTAM = (M-1)/5;                           %[-] set up for graphing
    tau = C_tot/UA;                             %[s] time constant
    t_sim = 5*tau;                              %[s] simulation time, change constant as necessary 
    t_span = linspace(0,t_sim,M);               %[s] set up for ODE45

% integration
    OPTIONS=odeset('RelTol',1e-6);              %[-] set relative tolerance for integration
    [time,T_m]=ode45(@(time,T_m)CF_HXER_DTMDT_v0(T_m,time,UA_h,UA_c,C_tot,R_cond_tot,N),t_span,T_m_ini,OPTIONS);
    
% find temperature profiles from function dT_mdt
    % create matrix for metal temperature change wrt time
    dT_mdt = zeros(M,N);
    % create matrix for hot flow temperature profile
    myTh = zeros(M,N);
    % create matrix for cold flow temperature profile
    myTc = zeros(M,N);
    % solve for values from function dT_mdt
    for i=1:M
        [dT_mdt(i,:),myTh(i,:),myTc(i,:)] = CF_HXER_DTMDT_v0(T_m(i,:),time(i),UA_h,UA_c,C_tot,R_cond_tot,N);
    end
 
% find metal temperatures at inlet & outlet for final timestep
    T_m_1_fin = T_m(M,1);
    T_m_N_fin = T_m(M,N);
    
% find fluid inlet temperatures at final timestep
    T_h_in_check = myTh(M,1);
    T_c_in_check = myTc(M,N);

% find fluid inlet & outlet temperatures at final timestep
    T_h_in_fin = myTh(M,1);
    T_h_out_fin = myTh(M,N);
    T_c_in_fin = myTc(M,N);
    T_c_out_fin = myTc(M,1);

% check fluid inlet temperature calculation with function
    % create matrices for hot fluid inlet
        T_h_in = zeros(M,1);
        C_dot_h_in = zeros(M,1);
    % create matrices for cold flow inlet 
        T_c_in = zeros(M,1);
        C_dot_c_in = zeros(M,1);
    % solve for values from inlet functions
        for i=1:M
            [T_h_in(i),C_dot_h_in(i)] = CF_HXER_HOT_INLET_v0(time(i));
            [T_c_in(i),C_dot_c_in(i)] = CF_HXER_COLD_INLET_v0(time(i));
        end

% calculate temperature difference of inlets & outlets for all timesteps
    DELTAT_in = myTh(:,1) - myTc(:,N);
    DELTAT_out = myTh(:,N) - myTc(:,1);
    
% capacitance rates
    % create matrix for minimum capacitance rate at final timestep
        C_dot_min = zeros(M,1);
    % create matrix for maximum capacitance rate at final timestep
        C_dot_max = zeros(M,1);
    % create matrix for capacitance ratio at final timestep
        C_R = zeros(M,1);
    % solve for values at each timestep
        for i=1:M  
            C_dot_min(i) = min(C_dot_h_in(i),C_dot_c_in(i));        %[W/K] minimum capacitance rate
            C_dot_max(i) = max(C_dot_h_in(i),C_dot_c_in(i));        %[W/K] maximum capacitance rate
            C_R(i) = C_dot_min(i)/C_dot_max(i);                     %[-] capacitance ratio
        end
    
% find heat exchanger sizing at final timestep
    NTU = UA/C_dot_min(M);

% heat exchanger effectiveness calculations
    % create matrix for heat transfer rate from the hot flow
        q_dot_h = zeros(M,1);
    % create matrix for heat transfer rate from the cold flow
        q_dot_c = zeros(M,1);
    % create matrix for maximum heat transfer rate 
        q_dot_max = zeros(M,1);
    % create epsilon matrices to check both flows
        epsilon_f_h = zeros(M,1);
        epsilon_f_c = zeros(M,1);
    % solve for values at each timestep
        for i=1:M
            q_dot_h(i) = C_dot_h_in(i)*(myTh(i,1) - myTh(i,N));
            q_dot_c(i) = C_dot_c_in(i)*(myTc(i,1) - myTc(i,N));
            q_dot_max(i) = C_dot_min(i)*(myTh(i,1) - myTc(i,N));
            epsilon_f_h(i) = q_dot_h(i)/q_dot_max(i);
            epsilon_f_c(i) = q_dot_c(i)/q_dot_max(i);
        end
        
% calculate final effectiveness
    epsilon_fin = epsilon_f_h(M);
    
% calculate steady-state effectiveness with eff-NTU solution 
    if C_R(M) == 1
        epsilon_fin_ss = NTU/(1+NTU);
    elseif C_R(M) < 1
        epsilon_fin_ss = (1-exp(-NTU*(1-C_R(M))))/(1-C_R(M)*exp(-NTU*(1-C_R(M))));
    end
    
% set parameter for graph export
    s = get(0, 'ScreenSize');
    
% plot metal node temperatures vs time for 5 nodal positions
    figure('Position', [0 0 s(3) s(4)],'Units','normalized','Position',[0 0 1 1]);
    hold on
    set(gca,'FontSize',16)
    plot(time,T_m(:,0*DELTAN+1),'-o')
    plot(time,T_m(:,1*DELTAN+1),'-o')
    plot(time,T_m(:,2*DELTAN+1),'-o')
    plot(time,T_m(:,3*DELTAN+1),'-o')
    plot(time,T_m(:,4*DELTAN+1),'-o')
    plot(time,myTh(:,1),'-o')
    plot(time,myTc(:,N),'-o')
    hold off
    grid
    axis([0 t_sim round(min(myTc(:,N)-50)/50)*50 round(max(myTh(:,1)+50)/50)*50])
    yticks(round(min(myTc(:,N)-50)/50)*50:50:round(max(myTh(:,1)+50)/50)*50)
    xlabel('Time, t_s [s]','FontSize',16)
    ylabel('Temperature, T [K]','FontSize',16)
    legend('Metal Temperature @ x* = 0.00',...
        'Metal Temperature @ x* = 0.25',...
        'Metal Temperature @ x* = 0.50',...
        'Metal Temperature @ x* = 0.75',...
        'Metal Temperature @ x* = 1.00',...
        'Hot Flow Inlet Temperature',...
        'Cold Flow Inlet Temperature',...
        'Location','Northwest','FontSize',16)
    set(gcf, 'Color', 'w')
%     saveas(gcf, 'z_MetalTemperatureTime601_CR_05_Rcond_1.png');
%     export_fig z_MetalTemperatureTime601_CR_05_Rcond_1.png -m2 -native

% plot metal temperatures vs position 6 at specified timesteps
    figure('Position', [0 0 s(3) s(4)],'Units','normalized','Position',[0 0 1 1]);
    hold on
    set(gca,'FontSize',16)
    plot(x_star,T_m(0*DELTAM+1,:),'-o')
    plot(x_star,T_m(1*DELTAM+1,:),'-o')
    plot(x_star,T_m(2*DELTAM+1,:),'-o')
    plot(x_star,T_m(3*DELTAM+1,:),'-o')
    plot(x_star,T_m(4*DELTAM+1,:),'-o')
    plot(x_star,T_m(5*DELTAM+1,:),'-o')
    hold off
    grid
    axis([0 1 round(min(T_m(1,:)-50)/50)*50 round(max(T_m(M,:)+150)/50)*50])
    xticks(0:0.1:1)
    yticks(round(min(T_m(1,:)-50)/50)*50:50:round(max(T_m(M,:)+150)/50)*50)
    xlabel('Position, x* [-]','FontSize',16)
    ylabel('Temperature, T [K]','FontSize',16)
    labels = num2str([time(0*DELTAM+1) time(1*DELTAM+1) time(2*DELTAM+1)...
        time(3*DELTAM+1) time(4*DELTAM+1) time(5*DELTAM+1)].',...
        'Metal Temperature @ time = %d [s]');
    legend(labels,'Location','Northeast','FontSize',16)
    set(gcf, 'Color', 'w')
%     saveas(gcf, 'z_MetalTemperatureNode601_CR_05_Rcond_1.png');
%     export_fig z_MetalTemperatureNode601_CR_05_Rcond_1.png -m2 -native

% plot temperature profiles at final timestep
    figure('Position', [0 0 s(3) s(4)],'Units','normalized','Position',[0 0 1 1]);
    hold on
    set(gca,'FontSize',16)
    plot(x_star,myTh(M,:),'-o')
    plot(x_star,myTc(M,:),'-o')
    plot(x_star,T_m(M,:),'-o')
    hold off
    grid
    axis([0 1 round(min(myTc(M,:)-50)/50)*50 round(max(myTh(M,:)+50)/50)*50])
    xticks(0:0.1:1)
    yticks(round(min(myTc(M,:)-50)/50)*50:50:round(max(myTh(M,:)+50)/50)*50)
    xlabel('Position, x* [-]','FontSize',16)
    ylabel('Temperature, T [K]','FontSize',16)
    legend('Hot Flow Temperature @ final timestep',...
        'Cold Flow Temperature @ final timestep',...
        'Metal Temperature @ final timestep',...
        'Location','Northeast','FontSize',16)
    set(gcf, 'Color', 'w')
%     saveas(gcf, 'z_TemperatureProfiles601_CR_05_Rcond_1.png');
%     export_fig z_TemperatureProfiles601_CR_05_Rcond_1.png -m2 -native 

