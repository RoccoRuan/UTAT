%code to analyze output of thermistors per spec outlined in document:
%Thermistor Quality Assesment Overview + Procedure
%Code written by Eric van Velzen, August / Sept 2019

%September 15, 2019 - Code edited by Rocco Ruan
%Changes:
% - got rid of some extra variables for each trial - the plan is to
% eventually have a for-loop run everything, or at least everything for one
% thermistor at a time
% - added code to read actual temperature data, fit it to a line, and use
% the line to produce data points for measured vs actual temperature
% - added code to fit data points produced above to a function
% - removed code for plotting certain graphs, to reduce clutter for later - graphs
% can be added back as necessary

%September 20, 2019 - Code edited by Rocco Ruan
%Changes:
% - implemented for-loop to automatically run code for all 10 thermistors
% and any trials specified
% - changed some variable names and comments to make things more
% intelligible

%%
%% run to initialize
clc;
clear all
close all

%initialize array to contain data points for measured vs actual values
measured_vs_actual_pts = nan(0,2);

%list the temperatures for the trials that have been conducted
trials = [10,20,30,40];
thermistors = [1,2,3,4,5,6,7,8,9,10];
%%

for therm = thermistors %For loop for each thermistor
for trial = trials %For loop for each trial
    
%import data from different trials
fileName = [sprintf('therm quality data - trial %dc attempt 1.csv',trial)];
folder = 'C:\UTAT\MF Thermistor Quality Testing';
fullFileName = fullfile(folder,fileName);
coolterm_data = readmatrix(fullFileName);
fclose('all');
%time stamp listed in col 1 in ms
%10 thermistors in cols 2-21, 
%temp data is 3, 5, 7.. col
%275ms time interval
%code accounts for header of 2 lines

%import actual temperature data
fileName = [sprintf('actual temp - trial %dc attempt 1.csv',trial)];
folder = 'C:\UTAT\MF Thermistor Quality Testing';
fullFileName = fullfile(folder,fileName);
actual_temp = readmatrix(fullFileName);
fclose('all');
%column 1 is time in minutes
%column 2 is temperature in degrees Celsius

%define array for time
time = coolterm_data(3:end,1).*10^-3; %converts from milliseconds to seconds

%read temperature data for thermistor in question
thermistor_temp = coolterm_data(3:end,2*therm+1); 

%estimate actual temperature for each measured temperature
actual_temp(:,1) = actual_temp(:,1)*60; %change time to seconds
[p1, S1] = polyfit(actual_temp(:,1),actual_temp(:,2),1); % fit to a line
[est_actual_temp,delta] = polyval(p1,time,S1); %estimate actual temperature for given time using fit

%add to array of measured vs actual temperature
points_to_add = nan(length(est_actual_temp),2) ;
points_to_add(:,1) = thermistor_temp;
points_to_add(:,2) = est_actual_temp;
measured_vs_actual_pts = cat(1,measured_vs_actual_pts,points_to_add);

end %For-loop for each trial ends


%%
%some redundant variables to make formatting work - may be possible to remove
measured_temps = measured_vs_actual_pts(:,1);
actual_temps = measured_vs_actual_pts(:,2);

%fit measured temp vs actual temp
idx = isfinite(measured_temps) & isfinite(actual_temps); %check for NaNs, infinities, etc.
[p2,S2] = polyfit(measured_temps(idx),actual_temps(idx),1); %fit measured temp vs actual temp to a line

temp_range = linspace(10,40,1000); %initialize array of measured temperatures to plot
[predicted_actual_temp, delta2] = polyval(p2,temp_range,S2); %calculate predicted actual temperatures from temp_range

%plot data for thermistor in question
hold on
plot(measured_temps,actual_temps,"b*")
plot(temp_range,predicted_actual_temp,"r-")
plot(temp_range,predicted_actual_temp+2*delta2,"m--",temp_range,predicted_actual_temp-2*delta2,"m--")

disp(sprintf('Results for Thermistor %d',therm))
disp(sprintf('Linear Fit: y = %dx + %d',p2))
disp(sprintf('Average Standard Error: %d',mean(delta2)))

title(sprintf('Measured vs Actual Temperature: Thermistor %d',therm))
xlabel("Measured Temperature [C]")
ylabel("Predicted Actual Temperature [C]")
legend("Data","Linear Fit","95% Prediction Interval")

end %For loop for each thermistor ends