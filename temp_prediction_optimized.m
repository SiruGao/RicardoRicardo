function temp_prediction_optimized(arduinoObj, analogPin, greenPin, yellowPin, redPin)
% TEMP_PREDICTION_OPTIMIZED - Rate-based temperature prediction system with 3-LED feedback
% Implements sliding window analysis for stable rate calculation
% 
% Features:
% - Real-time temperature monitoring via MCP9700A sensor
% - 5-minute linear prediction using sliding window regression
% - Threshold-triggered LED alerts
%
% Inputs:
%   arduinoObj : Initialized Arduino connection object
%   analogPin : Analog pin connected to temperature sensor (e.g., 'A0')
%   diffterent color pins    : Struct containing LED pins (green/yellow/red fields)
%
% Compliance:
% - Section a: 60-second data window for stable rate calculation
% - Section b: Console output of current/predicted temperatures
% - Section c: Rate-based LED control (±4°C/min thresholds)
% Sensor calibration parameters (MCP9700A specific)
V0 = 0.5;       % Voltage at 0°C
Tc = 0.01;      % Temperature coefficient
WINDOW_SIZE = 60;
THRESHOLD = 4;

% Initialize LED pins
configurePin(arduinoObj, greenPin, 'DigitalOutput');
configurePin(arduinoObj, yellowPin, 'DigitalOutput');
configurePin(arduinoObj, redPin, 'DigitalOutput');

% 
buffer = struct(...
    'temps', zeros(1, WINDOW_SIZE),...
    'times', NaT(1, WINDOW_SIZE),...  % 
    'idx', 1,...
    'count', 0);

% Main loop
while true
    [temp, currentTime] = readSensor(arduinoObj, analogPin, V0, Tc);
    buffer = updateBuffer(buffer, temp, currentTime);
    [rate, prediction] = calculateTrend(buffer);
    printStatus(currentTime, temp, rate, prediction);
    updateLEDs(arduinoObj, greenPin, yellowPin, redPin, rate);
    pause(1);
end

%% Nested function
function [temp, time] = readSensor(arduinoObj, analogPin, V0, Tc)
    voltage = readVoltage(arduinoObj, analogPin);
    temp = (voltage - V0)/Tc;
    time = datetime('now');
end

function buf = updateBuffer(buf, temp, time)
    buf.temps(buf.idx) = temp;
    buf.times(buf.idx) = time;
    buf.idx = mod(buf.idx, WINDOW_SIZE) + 1;
    buf.count = min(buf.count + 1, WINDOW_SIZE);
end

function [rate, prediction] = calculateTrend(buf)
    if buf.count < 2
        rate = 0;
        prediction = buf.temps(1);
        return
    end
    
    time_diff = buf.times(1:buf.count) - buf.times(1);  % get duration
    t = seconds(time_diff);  % change to seconds
    
    % linear regression 
    coeffs = polyfit(t, buf.temps(1:buf.count), 1);
    rate = coeffs(1) * 60;  % change c/s to °C/min
    
    % prediction for 5 mins
    prediction = polyval(coeffs, t(end) + 300);
end

function printStatus(time, temp, rate, prediction)
    persistent lastPrint;
    if isempty(lastPrint) || seconds(time - lastPrint) >= 5
        fprintf('[%s] Current: %.2f°C | Rate: %.2f°C/min | Predicted: %.2f°C\n',...
            datestr(time, 'HH:MM:SS'), temp, rate, prediction);
        lastPrint = time;
    end
end

function updateLEDs(a, greenPin, yellowPin, redPin, rate)
    writeDigitalPin(a, greenPin,  abs(rate) < THRESHOLD);
    writeDigitalPin(a, yellowPin, rate <= -THRESHOLD);
    writeDigitalPin(a, redPin,    rate >= THRESHOLD);
end

end