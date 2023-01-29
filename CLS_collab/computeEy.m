function Ey= computeEy(by,ay,dy,dyp,dipole_Length,dipole_radAngle)
%caclulate emittance
%by= 27.0684
%ay= -7.2606
%dy=0
%dyp=-0.0
%dipole_Length=1.87
%dipole_radAngle=15*3.14/180
gx= (1+ay.^2)./by;
H = by.*dyp+2*ay.*dy.*dyp +gx.*dy.^2;
rho = dipole_Length./dipole_radAngle;
I5 = sum((H'./(abs(rho).^3)).*dipole_Length);
I2 = sum(1./(rho.^2).*dipole_Length);
Cq = 3.8319E-13;
E_0 = 2.9e9; %eV
gamma = (E_0*1e-6)/PhysConstant.electron_mass_energy_equivalent_in_MeV.value;
%Emittance in Vertical direction
Ey= Cq*gamma^2*15/I2;

end