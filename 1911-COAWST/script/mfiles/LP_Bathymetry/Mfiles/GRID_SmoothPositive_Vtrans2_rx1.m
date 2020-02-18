function RetBathy=GRID_SmoothPositive_Vtrans2_rx1(...
    MSK, Hobs, rx1max, Sc_w, Cs_w, hc, RX1matrix)
% This program optimizes the bathymetry for the rx0 factor by increasing it.
% GRID_SmoothPositive_rx1(MSK, Hobs, rx1max, Scoord, Ccoord, hc)
%
% ---MSK(eta_rho,xi_rho) is the mask of the grid
%      1 for sea
%      0 for land
% ---Hobs(eta_rho,xi_rho) is the raw depth of the grid
% ---rx1max is the target rx1 roughness factor
% ---Sc_w, Cs_w, hc are roms fields.

Ksea=find(MSK == 0);
HobsSel=Hobs(Ksea);
mindep=min(HobsSel(:));
disp(['mindep=' num2str(mindep) '  hc=' num2str(hc)]);
tol=0.0001;
N=size(Sc_w,1)-1;
[eta_rho, xi_rho]=size(Hobs);
ListNeigh=[1 0;
	   0 1;
	   -1 0;
	   0 -1];
RetBathy=Hobs;

% the inequalities to have are
% z(e,k) - z(e',k) + z(e,k-1) - z(e',k-1)
% --------------------------------------- <= rx1
% z(e,k) + z(e',k) - z(e,k-1) + z(e',k-1)
%
% with 
%
% z(e,k) = h(e)   [hc s(k) + h(e) c(k)]/[hc + h(e)] 
%
% Those inequalities are rewritten as
%
%     a + b h(e)        a' + b' h(e')
% 0<= ---------- h(e) + ------------- h(e')
%      hc + h(e)          hc + h(e')
%
% with
%  a = hc s(k) (rx1 - 1) + hc s(k-1) (-rx1 - 1)
%  b = c(k) (rx1 - 1) + c(k-1) (-rx1 - 1)
%
% a' = hc s(k) (rx1 + 1) + hc s(k-1) (-rx1 + 1)
% b' = c(k) (rx1 + 1) + c(k-1) ( -rx1 + 1)
%
% and then to the inequality
% 
% 0 <= h(e')^2 {b'(hc + h(e))} 
%    + h(e')   {h(e) (a+b h(e)) + a'(hc + h(e))}
%    +         {hc(a + b h(e)) h(e)}
%         or
% 0 <= h(e)^2 {b(hc + h(e'))}
%      + h(e) {a(hc + h(e')) + h(e')(a' + b' h(e'))}
%      +      {hc(a' + b' h(e'))h(e')}

MSKpointModif=zeros(eta_rho,xi_rho);

MSKbad=zeros(eta_rho, xi_rho);
K=find(RX1matrix > rx1max);
MSKbad(K)=1;

TotalAbsDiff=0;
nbModif=0;
tol=0.000001;
while(true)
  IsFinished=1;
  for iEta=1:eta_rho
    for iXi=1:xi_rho
      if (MSK(iEta, iXi) == 1 && MSKbad(iEta, iXi) == 1)
        DepH=RetBathy(iEta,iXi);
	DoSomething=0;
	for ineigh=1:4
	  iEtaN=iEta+ListNeigh(ineigh,1);
	  iXiN=iXi+ListNeigh(ineigh,2);
	  if (iEtaN <= eta_rho && iEtaN >= 1 && ...
	      iXiN <= xi_rho && iXiN >= 1 && ...
	      MSK(iEtaN, iXiN) == 1)
	    DepHp=RetBathy(iEtaN,iXiN);
	    for k=2:N+1
	      a=hc*Sc_w(k,1)*(rx1max-1) - ...
		hc*Sc_w(k-1,1)*(rx1max + 1);
	      b=Cs_w(k,1)*(rx1max-1) - ...
		Cs_w(k-1,1)*(rx1max + 1);
	      aP=hc*Sc_w(k,1)*(rx1max+1) + ...
		 hc*Sc_w(k-1,1)*(-rx1max+1);
	      bP=Cs_w(k,1)*(rx1max+1) + ...
		 Cs_w(k-1,1)*(-rx1max+1);
	      %
	      aPol=b*(hc + DepHp);
	      bPol=a*(hc + DepHp) + DepHp*(aP + bP*DepHp);
	      cPol=hc*(aP + bP*DepHp)*DepHp;
	      TheDisc=bPol*bPol - 4*aPol*cPol;
	      TheSol1=(-bPol + sqrt(TheDisc))/(2*aPol);
	      TheSol2=(-bPol - sqrt(TheDisc))/(2*aPol);
	      TheSum=(DepH*DepH)*aPol + DepH*bPol + cPol;
	      if (TheDisc < 0)
		if (aPol < 0)
		  disp('We cannot smooth to get correct result');
		  disp('Please panic');
		  disp(['k=' num2str(k) '  iEta=' num2str(iEta) ...
			'  iXi=' num2str(iXi)]);
		  disp(['DepH=' num2str(DepH) ' DepHp=' num2str(DepHp)]);
		  disp(['bP=' num2str(bP) ...
			'  Cs_w(k,1)=' num2str(Cs_w(k,1)) ...
			'  Cs_w(k-1,1)=' num2str(Cs_w(k-1,1))]);
		  disp(['TheDisc=' num2str(TheDisc) ...
			'  aPol=' num2str(aPol)]);
		  disp(['TheSol1=' num2str(TheSol1)]);
		  disp(['TheSol2=' num2str(TheSol2)]);
		  disp(['TheSum=' num2str(TheSum)]);
		  error('Please correct');
		end;
	      end;
	      if (TheSum < -tol)
		IsFinished=0;
		nbModif=nbModif+1;
		TheDist1=abs(DepH - TheSol1);
		TheDist2=abs(DepH - TheSol2);
		if (TheDist1 < TheDist2 && TheSol1 > DepH)
		  NewDEP=TheSol1;
		elseif (TheDist2 < TheDist1 && TheSol2 > DepH)
		  NewDEP=TheSol2;
		else
		  % one of the solution is decreading depth
		  if (TheSol1 > DepH)
		    NewDEP=TheSol1;
		  elseif (TheSol2 > DepH)
		    NewDEP=TheSol1;
		  else
		    disp('We are seemingly in a dead end');
		    disp(['TheDisc=' num2str(TheDisc)]);
		    disp(['NewDEP=' num2str(NewDEP) ...
			  '   DepH=' num2str(DepH)]);
		    disp(['TheSol1=' num2str(TheSol1)]);
		    disp(['TheSol2=' num2str(TheSol2)]);
		    disp('There is an error here');
		    error('Please correct');
		  end;
		end;
		DiffDep=abs(NewDEP - DepH);
%		disp(['DiffDep=' num2str(DiffDep)]);
		MSKpointModif(iEta, iXi)=1;
		RetBathy(iEta, iXi)=NewDEP;
		TotalAbsDiff=TotalAbsDiff+abs(NewDEP - DepH);
		DoSomething=1;
	      end;
	    end;
	  end;
	end;
	if (DoSomething == 0)
	  MSKbad(iEta, iXi)=0;
	else
	  for ineigh2=1:4
	    iEtaN2=iEta+ListNeigh(ineigh2,1);
	    iXiN2=iXi+ListNeigh(ineigh2,2);
	    if (iEtaN2 <= eta_rho && iEtaN2 >= 1 && ...
		iXiN2 <= xi_rho && iXiN2 >= 1 && ...
		MSK(iEtaN2, iXiN2) == 1)
	      MSKbad(iEtaN2, iXiN2)=1;
	    end;
	  end;
	end;
      end;
    end;
  end;
  if (IsFinished == 1)
    break;
  end;
end;
K=find(MSKpointModif == 1);
nbK=size(K,1);

disp(['     nbModif=' num2str(nbModif)]);
disp(['         nbK=' num2str(nbK)]);
disp(['TotalAbsDiff=' num2str(TotalAbsDiff)]);
