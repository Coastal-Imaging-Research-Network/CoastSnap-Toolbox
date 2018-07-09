function out = CSPparseFilename(fname)
%
%function out = CSPparseFilename(fname)
%
%Function that reads the CoastSnap filename and parses it into its various
%components (as strings). 
%
%Written by Mitch Harley
%12/6/2018

C = strsplit(fname,'.');
out.epochtime = C{1};
out.dayname = C{2};
out.year = C{6};
out.month = C{3};
out.day = C{4}(1:2);
out.hour = C{4}(4:5);
out.min = C{4}(7:8);
out.sec = C{4}(10:11);
out.timezone = C{5};
out.site = C{7};
out.type = C{8};
out.user = C{9};
out.format = C{10};

