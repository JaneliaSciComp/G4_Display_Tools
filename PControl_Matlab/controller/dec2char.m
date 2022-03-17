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

arguments % simple argument verification
    num (1,1) {mustBeInteger, mustBeGreaterThanOrEqual(num, 0)}
    num_chars (1,1) {mustBeGreaterThanOrEqual(num_chars, 0)}
end
% more difficult argument verification
assert(num <  2^(8*num_chars), ...
    "G4DT:dec2char:numchar",... 
    "Not enough characters for a number of size %d (should be between 0...%d)", ...
    num_chars, (2^(8*num_chars)-1))
assert(2^(8*(num_chars-1)) ~= Inf,...
    "G4DT:dec2char:overflow", ...
    "the number of characters (%d) is too much for MATLAB to handle", num_chars);
% end argument verification

charArray = uint8(zeros(1,num_chars));
num_rem = num;

for j = num_chars:-1:1
    temp = floor((num_rem)/(2^(8*(j-1))));
    num_rem = num_rem - temp*(2^(8*(j-1)));
    charArray(j) = temp;
end





    