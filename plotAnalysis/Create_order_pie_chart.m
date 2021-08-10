function  Create_order_pie_chart(mainDir, fracOrdered)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

mean_frac = mean(fracOrdered);
f = figure();
labels = {'Ordered'};
p1 = pie([mean_frac,(1-mean_frac)]);
set(gcf,'units','centimeter','position', [5 14 12 12])
colormap ([0.4 0.4 0.4 ;0.9 0.9 0.9]);

set(p1(2),'fontsize', 20)
set(p1(4),'fontsize', 20)

legend(labels,'Location','northoutside','FontSize',16 )

mkdir(mainDir,'\Orientation_Display');
saveas(f,[mainDir,'\Orientation_Display','\Frac_ordered2'],'eps');
saveas(f,[mainDir,'\Orientation_Display','\Frac_ordered2'],'png');

close;
end

