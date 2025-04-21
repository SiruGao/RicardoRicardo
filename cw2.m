% Siru GAO
% ssysg5@nottingham.edu.cn


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [10 MARKS]

a = arduino;

for i = 1 : 10
    writeDigitalPin(a,'D2',1) %turn on the light
    pause(0.5)                 %pause the for 0.5 second
    writeDigitalPin(a,'D2',0) %turn off the light
    pause(0.5)
end

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

clear; clc;
% a)
% photo
% b)
a = arduino;
analogPin = 'A0';

% Sensor parameters (MCP9700A)
V0 = 0.5;   % Voltage at 0°C
Tc = 0.01;  % 10mV/°C

% Data collection parameters
duration = 600; % 10 minutes in seconds
interval = 1;   % Sampling interval
samples = duration/interval; % get the length of the data
timestamps = 0:interval:duration-interval; % prepare for the xlable of the figure

% Initialize data arrays
VoltageData = zeros(1, samples); % store the voltage data
temps = zeros(1, samples); % store the temperature data

for i = 1:samples
    VoltageData(i) = readVoltage(a, analogPin); % read the voltage data
    temps(i) = (VoltageData(i) - V0)/Tc; % turn voltage into temperature
    pause(interval - 0.01); % Account for processing time as the question said about 1 second
end

min_temp = min(temps); % mark the minimum temperature
max_temp = max(temps); % mark the maximum temperature
avg_temp = mean(temps); % mark the average temperature

% c) Generate plot
figure;
plot(timestamps, temps);
xlabel('Time (seconds)');
ylabel('Temperature (°C)');
title('Cabin Temperature During Takeoff');
grid on;

% d) output the string
output = sprintf('Data logging initiated - %s\n''Location - Nottingham\n', datestr(now, 'dd/mm/yyyy')); % show the location and date
for i = 1:10
    output = [output sprintf('Minute %d\nTemperature %.2f C\n\n',i-1, temps(i*60))]; % Assumes 60 samples/minute
end
output = [output sprintf('Max temp %.2f C\n''Min temp %.2f C\n''Average temp %.2f C\n''Data logging terminated', max_temp, min_temp, avg_temp)]; % show the key data

% e)
data_table = fopen('cabin_temperature.txt', 'w'); % open a file
fprintf(data_table, output); % write the text into the file opened before
fclose(data_table); % close the file
disp(output) % show data on the screen

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

clear; clc;
% a)
%photo
% b) to g)
% red_light = D2
% yellow_light = D3
% green_light = D4
a = arduino;
greenPin = 'D4';
yellowPin = 'D3';
redPin = 'D2';
configurePin(a, greenPin, 'DigitalOutput');
configurePin(a, yellowPin, 'DigitalOutput');
configurePin(a, redPin, 'DigitalOutput');

temp_monitor(a,'A0','D4','D3','D2');

doc temp_monitor

%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [25 MARKS]
clear; clc;
a=arduino;
analogPin = 'A0';
temp_prediction(a,'A0','D4','D3','D2');

doc temp_prediction


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% **Reflective Statement**

%Challenges: Developing this real-time temperature monitoring system presented several significant challenges, particularly in balancing the demands of precise timing and accurate data processing. Synchronizing the continuous sensor data acquisition with responsive LED control proved complex initially, as simple polling loops led to inconsistent sampling intervals. This was resolved through implementing a circular buffer system with timestamp tracking, ensuring stable data flow. Another major hurdle involved managing sensor noise from the MCP9700A thermistor, which was effectively mitigated by introducing a three-point moving average filter, significantly enhancing measurement reliability.

%Strengths:The project’s core strengths lie in its modular architecture and robust algorithm design. By separating sensor interfacing, data analysis, and output control into distinct functional units, the system achieved flexibility and ease of debugging. The adoption of linear regression for trend analysis demonstrated superior performance compared to basic rate calculation methods, yielding more accurate temperature predictions. Professional implementation details such as ANSI-enhanced console output and comprehensive error handling further strengthened the system’s reliability. These features not only met but exceeded the coursework requirements, showcasing strong integration of software and hardware components.

%Limitations:However, certain limitations became apparent during development. The fixed 30-second analysis window, while effective for short-term trends, may not adapt well to varying environmental conditions. The linear prediction model’s assumption of constant change rates also restricts long-term forecasting accuracy. Hardware constraints, particularly the thermistor’s ±2°C measurement tolerance, occasionally impacted result precision. Additionally, the lack of hardware debouncing mechanisms left potential vulnerabilities in scenarios requiring manual input.

%Improvements for future:Future iterations could significantly enhance the system through several strategic improvements. Adaptive algorithms that dynamically adjust the analysis window based on environmental variability would improve responsiveness. Incorporating machine learning techniques or polynomial regression could address the limitations of linear prediction models. Upgrading to higher-precision sensors like the DS18B20 would boost measurement accuracy, while developing a graphical MATLAB App interface would enhance user interaction and data visualization. Extending the system to support wireless sensor networks could enable distributed monitoring applications, broadening its practical utility. These advancements would build upon the current foundation, transforming the project from a classroom exercise into a sophisticated industrial monitoring tool.