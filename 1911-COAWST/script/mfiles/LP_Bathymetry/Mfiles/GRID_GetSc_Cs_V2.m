function [Sc_w, Cs_w, Sc_r, Cs_r]=GRID_GetSc_Cs_V2(ARVD)

N=ARVD.N;
ThetaS=ARVD.ThetaS;
ThetaB=ARVD.ThetaB;
Vstretching=ARVD.Vstretching;

theta_b=ThetaB;
theta_s=ThetaS;

Sc_r=zeros(N, 1);
for i=1:N
  Sc_r(i,1)=-(2*(N+1-i)-1)/(2*N);
end;
Sc_w=zeros(N+1, 1);
for i=1:N+1
  Sc_w(i,1)=-(N+1-i)/N;
end;
if (Vstretching == 1)
  for i=1:N
    sV=Sc_r(i,1);
    cV=(1-theta_b)*(sinh(sV*theta_s)/sinh(theta_s))+...
       theta_b*(-0.5+0.5*tanh(theta_s*(sV+0.5))/...
		tanh(0.5*theta_s));
    Cs_r(i,1)=cV;
  end;
  for i=1:N+1
    sV=Sc_w(i,1);
    cV=(1-theta_b)*(sinh(sV*theta_s)/sinh(theta_s))+...
       theta_b*(-0.5+0.5*tanh(theta_s*(sV+0.5))/...
		tanh(0.5*theta_s));
    Cs_w(i,1)=cV;
  end;
elseif (Vstretching == 2)
  alpha=1;
  beta=1;
  for i=1:N
    sV=Sc_r(i,1);
    Csur=(1-cosh(theta_s*sV))/(cosh(theta_s)-1);
    Cbot=-1+sinh(theta_b*(sV+1))/sinh(theta_b);
    Cweight=(sV+1)^(alpha)*(1+(alpha/beta)*(1-(sV+1)^(beta)));
    cV=Cweight*Csur+(1-Cweight)*Cbot;
    Cs_r(i,1)=cV;
  end;
  for i=1:N+1
    sV=Sc_w(i,1);
    Csur=(1-cosh(theta_s*sV))/(cosh(theta_s)-1);
    Cbot=-1+sinh(theta_b*(sV+1))/sinh(theta_b);
    Cweight=(sV+1)^(alpha)*(1+(alpha/beta)*(1-(sV+1)^(beta)));
    cV=Cweight*Csur+(1-Cweight)*Cbot;
    Cs_w(i,1)=cV;
  end;
elseif (Vstretching == 3)
  Hscale=3;
  alpha=theta_s;
  beta=theta_b;
  for i=1:N
    sV=Sc_r(i,1);
    Csur=-log(cosh(Hscale*abs(sV)^(alpha)))/...
	 log(cosh(Hscale));
    Cbot=log(cosh(Hscale*(sV+1)^(beta)))/...
	 log(cosh(Hscale))-1
    Cweight=0.5*(1-tanh(Hscale*(sV+0.5)));
    cV=Cweight*Cbot+(1-Cweight)*Csur;
    Cs_r(i,1)=cV;
  end;
  for i=1:N+1
    sV=Sc_w(i,1);
    Csur=-log(cosh(Hscale*abs(sV)^(alpha)))/...
	 log(cosh(Hscale));
    Cbot=log(cosh(Hscale*(sV+1)^(beta)))/...
	 log(cosh(Hscale))-1;
    Cweight=0.5*(1-tanh(Hscale*(sV+0.5)));
    cV=Cweight*Cbot+(1-Cweight)*Csur;
    Cs_w(i,1)=cV;
  end;
else
  disp('You did not choose correctly');
  error('Please correct');
end;
