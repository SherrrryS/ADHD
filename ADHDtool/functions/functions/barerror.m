function barerror (Y,E,width,color,colors)

%%% BarrError combines the functions 'bar' and 'errorbar' in a single function. 
%%% As far as I know, 'errorbar' cannot accomodate several bars per X point (as 'bar' does), 
%%% so is not easy to plot one of the most common graph types (at least in natural sciences). 
%%% 'BarError' tries to fill this gap. If there is a function for this already, well, here is another.

%% Sintax: barerror(x,y,e,width,color)
%% x: vector of X values
%% y: vector or matrix of Y values
%% e: vector or matrix of error values (plotted simmetrically)
%% width: bar width
%% color: one-letter color code for the error bar
%% 'x', 'y' and 'e' must be the same length, and 'y' and 'e' must have the same number of columns

X=[1:size(Y,1)]';

if mean([size(X,1),size(Y,1),size(E,1)]) ~= length(X)	error ('Imput vectors are of different lengths'); return; end
if size(Y,2) ~= size(E,2) error ('Data and Error vectors have different number of columns'); return; end

% colormap(gray)
% colors= ['r';'y';'b';'g';'c';'m';'k';'w'];
% colors= ['g';'c';'b';'y';'c';'m';'k';'w'];
% colors=['k','w'];
% colors=['k';'[0.5 0.5 0.5]'];

hold on
ncol= size(Y,2);
off= [fix(-ncol/2):fix(ncol/2)];
realwidth= min(diff(X))/(ncol);
if ~mod(ncol,2) off= [off(1:ceil(length(off)/2)-1), off(1+ ceil(length(off)/2):length(off))]; end
for h= 1:ncol
	Xtmp= X(:,1)+ off(h)*(realwidth/2)- sign(off(h))*(~mod(ncol,2)*realwidth/4);
	bar(Xtmp,Y(:,h),width/(2*ncol),'linewidth',2,'facecolor',colors{mod(h,1+length(colors))});
end

for h = 1:ncol 
	Xtmp= X(:,1)+ off(h)*(realwidth/2)- sign(off(h))*(~mod(ncol,2)*realwidth/4);
	errorbar(Xtmp,Y(:,h),E(:,h),'LineStyle','none','Linewidth',3,'Color',color);
end
hold off
return