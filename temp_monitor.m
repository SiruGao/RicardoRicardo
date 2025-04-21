function temp_monitor(arduinoObj, analogPin, greenPin, yellowPin, redPin)
%TEMP_MONITOR Real-time temperature monitoring with LED feedback g)
%   Inputs:
%   arduinoObj - Arduino connection object
%   analogPin  - Analog input pin for temperature sensor
%   greenPin   - Digital output pin for green LED
%   yellowPin  - Digital output pin for yellow LED
%   redPin     - Digital output pin for red LED
%   V0         - Sensor voltage at 0°C
%   Tc         - Temperature coefficient (V/°C)
%   Features:
%   - It can read the voltage to get the temperature immediately and show
%   it in figure and control the light to show the range of temperature to
%   alert

V0 = 0.5;
Tc = 0.01;
% Initialize plot
figure(2);
h = animatedline;
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Real-time Temperature Monitoring');
grid on;
startTime = datetime('now');

while true
    % Read and convert temperature
    voltage = readVoltage(arduinoObj, analogPin);
    temp = (voltage - 0.5)/0.01;
    pause(1);
    % Update plot
    t = seconds(datetime('now') - startTime);
    addpoints(h, t, temp);
    xlim([max(0, t-60), t+10]);
    ylim([10 30]);
    drawnow;
    
    % LED control logic
    if temp >= 18 && temp <= 24
        writeDigitalPin(arduinoObj, greenPin, 1);
        writeDigitalPin(arduinoObj, yellowPin, 0);
        writeDigitalPin(arduinoObj, redPin, 0);
        pause(1)
    elseif temp < 18
        % Yellow LED blinking at 0.5Hz
        writeDigitalPin(arduinoObj, greenPin, 0);
        writeDigitalPin(arduinoObj, yellowPin, 1);
        writeDigitalPin(arduinoObj, redPin, 0);
        pause(0.5)
        writeDigitalPin(arduinoObj,yellowPin,0);
        pause(0.5)
    else
        % Red LED blinking at 2Hz
        for n = 1 : 2
        writeDigitalPin(arduinoObj, greenPin, 0);
        writeDigitalPin(arduinoObj, yellowPin, 0);
        writeDigitalPin(arduinoObj, redPin, 1);
        pause(0.25);
        writeDigitalPin(arduinoObj,redPin,0);
        pause(0.25);
        end
    end
end
end