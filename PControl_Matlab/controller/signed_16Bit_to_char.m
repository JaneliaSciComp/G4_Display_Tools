function char_val = signed_16Bit_to_char(B)
% this functions makes two char value (0-255) from a signed
% 16bit valued number in the range of -32767 ~ 32767
% dec2char cannot handle negative numbers
% FL 5/1/2023 add argument check


arguments % simple argument verification
    B (1,:) {mustBeInteger, mustBeGreaterThanOrEqual(B, -32768), mustBeLessThanOrEqual(B, 32767)}
end

% this does both pos and neg in one line
temp_val = mod(65536 + int64(B), 65536);

for cnt =1 : length(temp_val)
    char_val(2*cnt-1:2*cnt) = dec2char(temp_val(cnt),2);
end
