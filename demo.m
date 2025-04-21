clear all
a = arduino('COM4', 'Uno');
V0 = 0.5;   % Voltage at 0°C
Tc = 0.01;  % 10mV/°C
analogPin = 'A0';
greenPin = 'D4';
yellowPin = 'D3';
redPin = 'D2';
configurePin(a, greenPin, 'DigitalOutput');
configurePin(a, yellowPin, 'DigitalOutput');
configurePin(a, redPin, 'DigitalOutput');


while true
    VoltageData = readVoltage(a, analogPin); % read the voltage data
    temps = (VoltageData - 0.5)/0.01; % turn voltage into temperature
    pause(1); % Account for processing time as the question said about 1 second
    if temps >= 18 && temps <= 24
        writeDigitalPin(a, greenPin, 1);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 0);
        pause(1)
    elseif temps < 18
        % Yellow LED blinking at 0.5Hz
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 1);
        writeDigitalPin(a, redPin, 0);
        pause(0.5)
        writeDigitalPin(a,yellowPin,0);
        pause(0.5)
    else
        % Red LED blinking at 2Hz
        for n = 1 : 2
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 1);
        pause(0.25);
        writeDigitalPin(a,redPin,0);
        pause(0.25);
        end
    end

end