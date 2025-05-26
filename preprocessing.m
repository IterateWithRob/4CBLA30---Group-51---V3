% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model starts running (initFcn callback function).

%% Load the supply and demand data

timeUnit   = 's';

supplyFile = "Team51_supply.csv";
supplyUnit = "kW";

% load the supply data
Supply = loadSupplyData(supplyFile, timeUnit, supplyUnit);

demandFile = "Team51_demand.csv";
demandUnit = "kW";

% load the demand data
Demand = loadDemandData(demandFile, timeUnit, demandUnit);
DemandHeating = Demand*0.79;
DemandElectricity = Demand*0.21;

%% Simulation settings

deltat = 5*unit("min");
stopt  = min([Supply.Timeinfo.End, Demand.Timeinfo.End]);

%% copying the changing variables 
file_name='ChanginVars.txt';
file_id=fopen(file_name,'r');
fileContents = fileread("ChanginVars.txt");

BatterySizeLine = regexpi(fileContents, 'StorrageSize \d+.\d+', 'match');
StorrageSize = str2double(regexp(BatterySizeLine{1},'\d+\.?\d*','match'));
efficiencyLine = regexpi(fileContents, 'efficiency \d+.\d+', 'match');
efficiency = str2double(regexp(efficiencyLine{1},'\d+\.?\d*','match'));
fclose(file_id);

%% System parameters

% transport from supply
ElectricalConductivity = 1.7 *10^-8;
WireLenght = 12; %meters
WireDiameter = 7*10^-3; %%meters
SupplyVoltage = 230;%volts

SupplyWireArea = 0.25 * pi * WireDiameter^2;
SupplyWireRestance = (WireLenght * ElectricalConductivity) / SupplyWireArea;

aSupplyTransport = 0.01;

% injection system
aInjection = 0.01; % Dissipation coefficient
%approximations for COP
COP65 = 3; %COP at 65 c
COP80 = 2.48; %COP at 80 c

% storage system
EStorageInitial = 10^5;
bStorage        = 1e-6/unit("s");  % Storage dissipation coefficient

%%physical storage parameters
Tambient = 20;%degree C
Tmax = 80;%degree C
Tmin = 60;%degree C
height = 1.24; %meters
diameter = 1.2;%meters
density = 1000; %kg/m^3
SpecificHeat = 4184; %J/kgK
HeatTransferCoefficient = 0.48; %W/m^2K
InsulationThickness = 0.05; %meters

WaterMass = 0.25 * pi * diameter^2 * height * density;

HeatCapacity = WaterMass * SpecificHeat;

EStorageMin     = Tmin*HeatCapacity;
EStorageMax     = Tmax*HeatCapacity; % Maximum energy

% extraction system
aExtraction = efficiency; % Dissipation coefficient

% transport to demand
aHeatingDemandTransport = 0.01; % Dissipation coefficient
aElectricityDemandTransport = 0.01; % Dissipation coefficient

used_energy = trapz(Demand.Data, Demand.Time);
suppied_energy = trapz(Supply.Data,Supply.Time);