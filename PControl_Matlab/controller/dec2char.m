function charArray = dec2char(num, num_chars)
% this functions makes an array of char values (0-255) from a decimal number
% this is listed in MSB first order.
% Not working for negative numbers
% to decode, for e.g. a 3 char array:
% ans = charArray(1)*2^16 + charArray(2)*2^8 + charArray(3)*2^0
% JL 2/2/2016 dec2char cannot handle negative numbers
% FL 3/1/2022 fix constraint check to avoid overflow error
% FL 3/16/2022 fix constraint with large num_chars
% FL 3/17/2022 limit return type to uint8 with values 0..255
% FL 8/4/2022 fix https://github.com/JaneliaSciComp/G4_Display_Tools/issues/64

arguments % simple argument verification
    num (1,1) {mustBeInteger, mustBeGreaterThanOrEqual(num, 0)}
    num_chars (1,1) {mustBeGreaterThanOrEqual(num_chars, 0)}
end
% % % % more difficult argument verification
rnum = cast(num, 'uint64');
assert(rnum == num, ...
    "Rounding error. The number you are giving is too big. Try to use explicit typing instead, eg `dec2char(uint64(%u), %d)`", rnum, num_chars)

% [f,e] = log2(num);
% assert(e <= num_chars, ...
%     "G4DT:dec2char:numchar",... 
%     "Not enough characters for a number of size %d (%u should be between 0...%u)", ...
%     num_chars, rnum, (uint64(2^(8*num_chars))-1))
assert(rnum <  uint64(2^(8*num_chars)), ...
   "G4DT:dec2char:numchar",... 
   "Not enough characters for a number of size %d (%u should be between 0...%u)", ...
   num_chars, rnum, (uint64(2^(8*num_chars))-1))

bitArray = bitget(rnum, 64:-1:1, 'uint64');
charArray = uint8(zeros(1,num_chars));
maxChars = min(num_chars, 8);
for j = 0:1:maxChars-1
    temp = bitArray(64-j*8-7:64-j*8);
    charArray(j+1) = uint8(bin2dec(num2str(temp)));
end