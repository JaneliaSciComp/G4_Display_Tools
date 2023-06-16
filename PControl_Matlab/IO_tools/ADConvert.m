function adcValue = ADConvert(analogValue)
% this function does the ADC convert: -10V..10V are converted to int16
% when analogValue = -10, adcValue = -32,768
% when analogValue = 10, adcValue = 32,767
% FL 5/1/2023 add cast to int16

amplifiedValue = (analogValue + 10)/20* 65535 - 32768;
adcValue = cast(amplifiedValue, "int16");