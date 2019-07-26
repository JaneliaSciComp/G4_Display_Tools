function adcValue = ADConvert(analogValue)
%this function do the ADC convert 
%when analogValue = -10, adcValue = -32,768
%when analogValue = 10, adcValue = 32,767

adcValue = (analogValue + 10)/20* 65535 - 32768;