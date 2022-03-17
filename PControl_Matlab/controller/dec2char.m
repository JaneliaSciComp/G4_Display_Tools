function charArray = dec2char(num, num_chars)
% this functions makes an array of char values (0-255) from a decimal number
% this is listed in MSB first order.
% untested for negative numbers, probably wrong!
% to decode, for e.g. a 3 char array:
% ans = charArray(1)*2^16 + charArray(2)*2^8 + charArray(3)*2^0
% JL 2/2/2016 dec2char cannot handle negative numbers
% FL 3/1/2022 fix constraint check to avoid overflow error
% FL 3/16/2022 fix constraint with large num_chars
% FL 3/17/2022 limit return type to uint8 with values 0..255

charArray = uint8(zeros(1,num_chars));
if (num > (2^(8*num_chars)-1))
    error("G4DT:dec2char:numchar", "not enough characters for a number of size %d (should be between 0...%d)", ...
        num_chars, (2^(8*num_chars)-1) );
end

if (num < 0 )
    error("G4DT:dec2char:neg", 'this function does not handle negative numbers correctly');
end

if (2^(8*(num_chars-1)) == Inf)
    error("G4DT:dec2char:overflow","the number of characters is too much for MATLAB to handle");
end

num_rem = num;

for j = num_chars:-1:1
    temp = floor((num_rem)/(2^(8*(j-1))));
    num_rem = num_rem - temp*(2^(8*(j-1)));
    charArray(j) = temp;
end





    