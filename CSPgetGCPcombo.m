function out = CSPgetGCPcombo(siteDB,epoch)
%
%function out = CSPgetGCPcombo(siteDB,epoch)
%
%Function that gets the relevant gcp combination to use for rectification
%for the image epoch. siteDB is given from CSPgetSiteDB
%
%Written by Mitch Harley
%15/06/2019

TimeIns = [siteDB.gcp_combo.TimeIn];
TimeOuts = [siteDB.gcp_combo.TimeOut];
I1 = find(TimeIns<epoch);
I2 = find(TimeOuts>epoch); %max(I1) and min(I2) should in theory be the same
I = max(I1);
out = siteDB.gcp_combo(I).combo;