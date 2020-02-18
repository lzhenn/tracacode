function RX1matrix=GRID_ComputeMatrixRx1_V2(Z_w, MSK_rho)

[eta_rho, xi_rho]=size(MSK_rho);
N=size(Z_w,1)-1;
Umat=[0 1;
      1 0;
      0 -1;
      -1 0];
RX1matrix=zeros(eta_rho, xi_rho);
for iEta=1:eta_rho
  for iXi=1:xi_rho
    if (MSK_rho(iEta, iXi) == 1)
      rx1=0;
      for i=1:4
        iEtaB=iEta+Umat(i,1);
        iXiB=iXi+Umat(i,2);
        if (iEtaB >= 1 && iEtaB <= eta_rho && ...
            iXiB >= 1 && iXiB <= xi_rho && MSK_rho(iEtaB, iXiB) == 1)
	  for i=1:N
	    a1=abs(Z_w(i+1,iEta,iXi) - Z_w(i+1,iEtaB, iXiB) + ...
		   Z_w(i,iEta,iXi) - Z_w(i,iEtaB,iXiB));
	    b1=abs(Z_w(i+1,iEta,iXi) + Z_w(i+1,iEtaB, iXiB) - ...
		   Z_w(i,iEta,iXi) - Z_w(i,iEtaB, iXiB));
	    quot=abs(a1/b1);
	    rx1=max(rx1, quot);
	  end;
	end;
      end;
      RX1matrix(iEta, iXi)=rx1;
    end;
  end;
end;
