function csection= Cross(energy,  delta_m)
    r = 2.82e-15;
    gamma = energy/0.511e6; %in eV
    beta = 1%sqrt(1-1/gamma^2);
    chi_m = delta_m/gamma;
    chi = 0.001:0.0001:0.015;
    gamma_t = gamma./(sqrt(1+beta^2.*chi.^2.*gamma^2)); %energy in eV  
    beta_bar = gamma_t.^2 .* beta^2.* chi.^2;  
    csection = (pi*r^2*gamma_t.^2./2./gamma.^2).*((3-2./beta_bar.^2 - 1./beta_bar.^4).*...
               log(gamma_t.*chi./delta_m)+(1+1./beta_bar.^2).^2.*(gamma_t.^2.*chi.^2./delta_m^2 - 1)...
               +1-delta_m./gamma_t./chi);
    cs2 = 2*pi*r ^2/gamma^2/delta_m^2./chi.^2;
    figure(2)
    [0 ;0.05 ;0 ;0.5e-11];
    plot(chi, csection/1e-28,'g','LineWidth',2);
    title('Total cross section in lab frame vs \chi angle E = 2.9 GeV, \Deltap/p = 0.01')
    xlabel('Angle \chi [rad]')
    ylabel('cross section [b]')
    hold on 
    plot(chi, cs2/1e-28, 'ob','LineWidth',1);
    legend('analytical', 'ultra-relativistic')
    hold off
