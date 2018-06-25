function localMatlabTime = CSPepoch2LocalMatlab(epochtime,gmt_offset)


%Convert to local time in Matlab
localMatlabTime = epoch2Matlab(epochtime)+gmt_offset/24;
