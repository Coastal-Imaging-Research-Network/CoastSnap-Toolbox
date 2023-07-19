function new_sl = CSPGshiftSLxshore(sl,SLtransects,xshore_shift,sl_elevation)

new_sl =NaN(length(SLtransects.x),3); %new shoreline based on forecast


for j = 1:length(SLtransects.x)
    [x_int,~] = polyxpoly(sl.xyz(:,1),sl.xyz(:,2),SLtransects.x(:,j),SLtransects.y(:,j));
    alpha = polyfit(SLtransects.x(:,j),SLtransects.y(:,j),1);
    xnew = x_int+xshore_shift/sqrt(1+alpha(1)^2);
    ynew = polyval(alpha,xnew);
    if ~isempty(xnew) %Catch in case shoreline does not intersect with that transect
        new_sl(j,:) = [xnew ynew sl_elevation]; %Elevation defined in function 
    end
end

%Remove any NaNs
I = find(isnan(new_sl(:,1)));
new_sl(I,:) = [];
