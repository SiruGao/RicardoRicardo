function temp_prediction(arduinoObj, analogPin, greenPin, yellowPin, redPin)
%TEMP_PREDICTION Monitors temperature trends and predicts future values
%   Inputs:
%   arduinoObj - Arduino connection object
%   analogPin  - Analog input pin for temperature sensor
%   greenPin   - Digital output pin for green LED
%   yellowPin  - Digital output pin for yellow LED
%   redPin     - Digital output pin for red LED
%   V0         - Sensor voltage at 0°C
%   Tc         - Temperature coefficient (V/°C)
%   Features:
%   - 60-second moving window for rate calculation
%   - Exponential smoothing for noise reduction
%   - Real-time prediction display
%   - Threshold-based LED alerts

% 初始化参数
window_size = 60;       % 60秒数据窗口（1分钟）
alpha = 0.2;            % 指数平滑系数
prediction_horizon = 300; % 预测时间（5分钟）
V0 = 0.5;
Tc = 0.01;
% 数据缓冲区初始化
time_buffer = zeros(1, window_size);
temp_buffer = zeros(1, window_size);
smoothed_temp = [];

% 硬件配置
configurePin(arduinoObj, greenPin, 'DigitalOutput');
configurePin(arduinoObj, yellowPin, 'DigitalOutput');
configurePin(arduinoObj, redPin, 'DigitalOutput');

% 主循环
while true
    % --- 数据采集与处理 ---
    % 读取原始温度
    raw_voltage = readVoltage(arduinoObj, analogPin);
    current_temp = (raw_voltage - V0)/Tc;
    
    % 指数平滑滤波
    if isempty(smoothed_temp)
        smoothed_temp = current_temp;
    else
        smoothed_temp = alpha*current_temp + (1-alpha)*smoothed_temp;
    end
    
    % 更新缓冲区（先进先出）
    time_buffer = [time_buffer(2:end), now];
    temp_buffer = [temp_buffer(2:end), smoothed_temp];
    
    % --- 变化率计算 ---
    valid_data = temp_buffer(temp_buffer ~= 0);
    if length(valid_data) >= 2
        time_diff = (time_buffer(end) - time_buffer(1)) * 86400; % 转秒
        temp_diff = valid_data(end) - valid_data(1);
        rate = temp_diff / time_diff; % °C/s
    else
        rate = 0;
    end
    
    % --- 预测计算 ---
    predicted_temp = smoothed_temp + rate * prediction_horizon;
    
    % --- 输出控制 ---
    % 控制台输出
    fprintf('[%s] Current: %.2f°C | Rate: %.2f°C/min | Predicted: %.2f°C\n',...
        datestr(now,'HH:MM:SS'),...
        smoothed_temp,...
        rate*60,... 
        predicted_temp);
    
    % LED状态机
    if rate*60 > 4        % 过热趋势
        writeDigitalPin(arduinoObj, redPin, 1);
        writeDigitalPin(arduinoObj, yellowPin, 0);
        writeDigitalPin(arduinoObj, greenPin, 0);
    elseif rate*60 < -4   % 过冷趋势
        writeDigitalPin(arduinoObj, yellowPin, 1);
        writeDigitalPin(arduinoObj, redPin, 0);
        writeDigitalPin(arduinoObj, greenPin, 0);
    else                  % 稳定状态
        writeDigitalPin(arduinoObj, greenPin, 1);
        writeDigitalPin(arduinoObj, yellowPin, 0);
        writeDigitalPin(arduinoObj, redPin, 0);
    end
    
    % --- 时序控制 ---
    pause(1 - rem(now*86400,1)); % 精确1秒周期
end
end
