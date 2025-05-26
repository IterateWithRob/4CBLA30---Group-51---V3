% Post-processing script for the EST Simulink model. This script is invoked
% after the Simulink model is finished running (stopFcn callback function).

close all;
figure;



%% Supply and demand
PDemand = PDemandHeating + PDemandElectricity;
subplot(3,2,1);
plot(tout/unit("day"), PSupply/unit("W"));
hold on;
plot(tout/unit("day"), PDemand/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Supply and demand');
xlabel('Time [day]');
ylabel('Power [W]');
legend("Supply","Demand");



%% Stored energy
subplot(3,2,2);
plot(tout/unit("day"), EStorage/unit("J"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Storage');
xlabel('Time [day]');
ylabel('Energy [J]');

%% Energy losses
subplot(3,2,3);
plot(tout/unit("day"), D/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Losses');
xlabel('Time [day]');
ylabel('Dissipation rate [W]');

%% Load balancing
subplot(3,2,4);
plot(tout/unit("day"), PSell/unit("W"));
hold on;
plot(tout/unit("day"), PBuy/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Load balancing');
xlabel('Time [day]');
ylabel('Power [W]');
legend("Sell","Buy");
%{
%% Mismatch
Mismatch = PSupply - PDemand;
plot(tout/unit("day"), Mismatch/unit("W"));
hold on;
grid on;
title('Mismatch');
xlabel('Time [day]');
ylabel('Power [W]')

%}
%% Pie charts

% integrate the power signals in time
PtoDemandTransport = PtoHeatingDemandTransport + PtoElectricityDemandTransport;
EfromSupplyTransport = trapz(tout, PfromSupplyTransport);
EtoDemandTransport   = trapz(tout, PtoDemandTransport);
ESell                = trapz(tout, PSell);
EBuy                 = trapz(tout, PBuy);
EtoInjection         = trapz(tout, PtoInjection);
EfromExtraction      = trapz(tout, PfromExtraction);
EStorageDissipation  = trapz(tout, DStorage);
EBuyStorage          = trapz(tout, PbuyHeatingDemand);
EbuyElectridDemand   = trapz(tout, PbuyElectricDemand);
EDirect              = EfromSupplyTransport - ESell - EtoInjection + EBuyStorage;
ESurplus             = EtoInjection-EfromExtraction-EStorageDissipation;

file_name='results.txt';
file_id=fopen(file_name,'a+');
fprintf(file_id,'StorrageSize: %f, losses: %f, Ebuy: %f, Esell: %f\n',StorrageSize, efficiency, EBuy, ESell);
fclose(file_id);

figure;
tiles = tiledlayout(1,2);

ax = nexttile;

disp(ESell/EfromSupplyTransport)
disp(EDirect/EfromSupplyTransport)
disp(EtoInjection/EfromSupplyTransport)

pie(ax, [EDirect/EfromSupplyTransport, (EtoInjection-EBuyStorage)/EfromSupplyTransport, ESell/EfromSupplyTransport])
lgd = legend({"Direct to demand", "To storage", "Sold"});
lgd.Layout.Tile = "south";
title(sprintf("Received energy %3.2e [J]", EfromSupplyTransport/unit('J')));

ax = nexttile;
pie(ax, [EDirect, EfromExtraction, EBuy-EbuyElectridDemand, EbuyElectridDemand]/EtoDemandTransport);
lgd = legend({"Direct from supply", "From storage", "Bought for heating", "bought for electricity"});
lgd.Layout.Tile = "south";
title(sprintf("Delivered energy %3.2e [J]", EtoDemandTransport/unit('J')));
