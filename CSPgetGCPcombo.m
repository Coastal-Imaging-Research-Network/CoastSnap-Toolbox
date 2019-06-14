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
I1 = min(find(epoch>TimeIns));
I2 = min(find(epoch<TimeOuts)); %I1 and I2 should in theory be the same
I = I1;
out = siteDB.gcp_combo(I).combo;