function temp_prediction(arduinoObj,analogPin,greenPin,yellowPin,redPin)
% TEMP_PREDICTION_OPTIMIZED - Rate-based temperature prediction system with 3-LED feedback
% Implements sliding window analysis for stable rate calculation
% 
% Features:
% - Real-time temperature monitoring via MCP9700A sensor
% - 5-minute linear prediction
% - Threshold-triggered LED alerts
%
% Inputs:
%   arduinoObj : Initialized Arduino connection object
%   analogPin : Analog pin connected to temperature sensor (e.g., 'A0')
%   diffterent color pins 
%
% Compliance:
% - Section b: Console output of current/predicted temperatures
% - Section c: Rate-based LED control (±4°C/min)
% Sensor calibration (MCP9700A specific)
TC = 0.01; 
V0C = 0.5;
t0 = 0;
temp = [];
times = [];
while true
voltage = readVoltage(arduinoObj,analogPin); % read voltage
temperature = (voltage - V0C) / TC; % convert to temperature
t0 = t0 + 1;
temp = [temp, temperature]; % store temperature
times = [times, t0]; % store time
if length(temp) > 1
temp_diffs = diff(temp); % derivate the temperature
time_diffs = diff(times); % derivate the time
rate_of_change = (temp_diffs / time_diffs) * 60; % the temperature change rate over time is the derivative of the data and convert seconds to minutes
last_rate = rate_of_change(end);
fprintf('current temperature: %.2f °C\n', temperature);
fprintf('current changing rate of temperature: %.2f °C/min\n', last_rate);
predicted_temp = temperature + last_rate * 5; % assuming the rate not change
fprintf('predicted temperature: %.2f °C\n', predicted_temp);
% control the led
if last_rate > 4 
writeDigitalPin(arduinoObj,greenPin,0);
writeDigitalPin(arduinoObj,yellowPin,0);
writeDigitalPin(arduinoObj,redPin,1);
elseif last_rate < -4
writeDigitalPin(arduinoObj,greenPin,0);
writeDigitalPin(arduinoObj,redPin,0);
writeDigitalPin(arduinoObj,yellowPin,1);
 else
writeDigitalPin(arduinoObj,greenPin,1);
writeDigitalPin(arduinoObj,yellowPin,0);
writeDigitalPin(arduinoObj,redPin,0);
end
end
pause(1);
end
end
