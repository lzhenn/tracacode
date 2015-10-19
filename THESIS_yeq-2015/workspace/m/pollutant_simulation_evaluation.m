bfunction sta=draw(start_time,end_time)

    clear all;
    close all;
    echo off;
    
    obs_donggaun = load('E:\dissertation2\data\obs_dongguan_pol.txt');
    obs_foshan = load('E:\dissertation2\data\obs_foshan_pol.txt');
    obs_panyu = load('E:\dissertation2\data\obs_panyu_pol.txt');
    sim_dongguan = load('E:\dissertation2\data\cctm\cctm_dongguan.txt');
    sim_foshan = load('E:\dissertation2\data\cctm\cctm_foshan.txt');
    sim_panyu = load('E:\dissertation2\data\cctm\cctm_panyu.txt');
  
    for i = 1:6
        dongguan_MB(i) = nanmean(sim_dongguan(49:480,i)-obs_donggaun(:,i));               %--------------------------------%
        foshan_MB(i) = nanmean(sim_foshan(49:480,i)-obs_foshan(:,i));                  %-----------均值偏差-------------%
        panyu_MB(i) = nanmean(sim_panyu(49:480,i)-obs_panyu(:,i));                  %--------------------------------%
        
        dongguan_MAGE(i) = nanmean(abs(sim_dongguan(49:480,i)-obs_donggaun(:,i)));        %--------------------------------%
        foshan_MAGE(i) = nanmean(abs(sim_foshan(49:480,i)-obs_foshan(:,i)));           %----------平均绝对误差-----------%
        panyu_MAGE(i) = nanmean(abs(sim_panyu(49:480,i)-obs_panyu(:,i)));           %--------------------------------%
        
        dongguan_RMSE(i) = (nanmean((sim_dongguan(49:480,i)-obs_donggaun(:,i)).^2))^(1/2);    %--------------------------------%
        foshan_RMSE(i) = (nanmean((sim_foshan(49:480,i)-obs_foshan(:,i)).^2))^(1/2);       %----------均方根误差-------------%
        panyu_RMSE(i) = (nanmean((sim_panyu(49:480,i)-obs_panyu(:,i)).^2))^(1/2);       %--------------------------------%
        
        dongguan_NMB(i) = nanmean(sim_dongguan(49:480,i)./obs_donggaun(:,i)-1);             %--------------------------------%
        foshan_NMB(i) = nanmean(sim_foshan(49:480,i)./obs_foshan(:,i)-1);                %----------平均标准偏差-----------%
        panyu_NMB(i) = nanmean(sim_panyu(49:480,i)./obs_panyu(:,i)-1);                %--------------------------------%

        dongguan_NME(i) = nanmean(abs(sim_dongguan(49:480,i)-obs_donggaun(:,i))./obs_donggaun(:,i));            %--------------------------------%
        foshan_NME(i) = nanmean(abs(sim_foshan(49:480,i)-obs_foshan(:,i))./obs_foshan(:,i));                %----------平均标准误差-----------%
        panyu_NME(i) = nanmean(abs(sim_panyu(49:480,i)-obs_panyu(:,i))./obs_panyu(:,i));                %--------------------------------%
        
        dongguan_FB(i) = nanmean((sim_dongguan(49:480,i)-obs_donggaun(:,i))./(0.5*(sim_dongguan(49:480,i)+obs_donggaun(:,i))));           %--------------------------------%
        foshan_FB(i) = nanmean((sim_foshan(49:480,i)-obs_foshan(:,i))./(0.5*(sim_foshan(49:480,i)+obs_foshan(:,i))));                %-----------平均残差率------------%
        panyu_FB(i) = nanmean((sim_panyu(49:480,i)-obs_panyu(:,i))./(0.5*(sim_panyu(49:480,i)+obs_panyu(:,i))));                %--------------------------------%
        
        obs_dongguan_mean(i) = nanmean(obs_donggaun(:,i));
        obs_foshan_mean(i) = nanmean(obs_foshan(:,i));
        obs_panyu_mean(i) = nanmean(obs_panyu(:,i));
        sim_dongguan_mean(i) = nanmean(sim_dongguan(49:480,i));
        sim_foshan_mean(i) = nanmean(sim_foshan(49:480,i));
        sim_panyu_mean(i) = nanmean(sim_panyu(49:480,i));
        
        dongguan_R(i) = nansum((obs_donggaun(:,i)-obs_dongguan_mean(i)).*(sim_dongguan(49:480,i)-sim_dongguan_mean(i)))./((nansum((obs_donggaun(:,i)-obs_dongguan_mean(i)).^2).*nansum((sim_dongguan(49:480,i)-sim_dongguan_mean(i)).^2)).^(1/2));
        foshan_R(i) = nansum((obs_foshan(:,i)-obs_foshan_mean(i)).*(sim_foshan(49:480,i)-sim_foshan_mean(i)))./((nansum((obs_foshan(:,i)-obs_foshan_mean(i)).^2).*nansum((sim_foshan(49:480,i)-sim_foshan_mean(i)).^2)).^(1/2));
        panyu_R(i) = nansum((obs_panyu(:,i)-obs_panyu_mean(i)).*(sim_panyu(49:480,i)-sim_panyu_mean(i)))./((nansum((obs_panyu(:,i)-obs_panyu_mean(i)).^2).*nansum((sim_panyu(49:480,i)-sim_panyu_mean(i)).^2)).^(1/2));
        
        dongguan_IOA(i) = 1-(432*dongguan_RMSE(i)^2)./nansum((abs(sim_dongguan(49:480,i))+abs(obs_donggaun(:,i))).^2);     %--------------------------------%
        foshan_IOA(i) = 1-(432*foshan_RMSE(i)^2)./nansum((abs(sim_foshan(49:480,i))+abs(obs_foshan(:,i))).^2);         %-----------吻合指数------------%
        panyu_IOA(i) = 1-(432*panyu_RMSE(i)^2)./nansum((abs(sim_panyu(49:480,i))+abs(obs_panyu(:,i))).^2);        %--------------------------------%
        
    end
    
    fid_dongguan = fopen('E:\dissertation2\data\dongguan_index.txt','wt');
    fid_foshan = fopen('E:\dissertation2\data\foshan_index.txt','wt');
    fid_panyu = fopen('E:\dissertation2\data\panyu_index.txt','wt');
    
    for i = 1:6
        fprintf(fid_dongguan,'%5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f\n',obs_dongguan_mean(i),sim_dongguan_mean(i),dongguan_MB(i),dongguan_MAGE(i),dongguan_RMSE(i),dongguan_NMB(i),dongguan_NME(i),dongguan_FB(i),dongguan_R(i),dongguan_IOA(i));
        fprintf(fid_foshan,'%5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f\n',obs_foshan_mean(i),sim_foshan_mean(i),foshan_MB(i),foshan_MAGE(i),foshan_RMSE(i),foshan_NMB(i),foshan_NME(i),foshan_FB(i),foshan_R(i),foshan_IOA(i));
        fprintf(fid_panyu,'%5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f\n',obs_panyu_mean(i),sim_panyu_mean(i),panyu_MB(i),panyu_MAGE(i),panyu_RMSE(i),panyu_NMB(i),panyu_NME(i),panyu_FB(i),panyu_R(i),panyu_IOA(i));
    end
end