function pat_vector = make_pattern_vector_g4(pattern)
% relevant fields of pattern are - Pats, BitMapIndex, gs_val
% converts a Pats file of size (L,M,N,O), where L is the number of rows, 8
% per panel, M is the number of columns, 8 per panel, N is the number of
% frames in the 'x' dimmension, and O is the number of frames in the 'y' dimmension
% to an array of size L/8, M/8, N*O stored as: Pannel, Frame, PatternData 
% here we flatten the 2D pattern array to a 1 D array using the formula 
% Pattern_number = (index_y - 1)*N + index_x;
Pats = pattern.Pats; 
[PatR, PatC, NumPatsX, NumPatsY] = size(Pats);
RowN = PatR/16;
ColN = PatC/16;
stretch = pattern.stretch;

if ~size(stretch, 1) == NumPatsX && ~size(stretch, 2) == NumPatsY
    f = errordlg('strech size should match the pattern size [NumPatsX, numPatsY].', 'Error stretch size', 'modal');
    pat_vector = 0;
    return;
end

if pattern.gs_val == 4
    gs_val = 16;
elseif pattern.gs_val == 1
    gs_val = 2;
else
    warndlg('The gray scale value should be either 4 or 1.', 'Wrong GS value Dialog');
    pat_vector = [];
    return;
end

%patternheader 
%Num of X frame(Low byte), Num of X frames(high byte), Num of Y frames(low byte); 
% num of Y frames(high byte), grayscale value(2 or 16),Row number, column number
patternHeader = [signed_16Bit_to_char(NumPatsX), signed_16Bit_to_char(NumPatsY), gs_val, RowN, ColN];
pat_vector = [patternHeader];

for j = 1:NumPatsY
    for i = 1:NumPatsX
        frame = Pats(:,:,i,j);
        stretch_val = stretch(i,j);
        if gs_val == 16
            stretch_val = min(stretch_val, 20);
            frameOut = make_framevector_gs16(frame, stretch_val);
        elseif gs_val == 2
            stretch_val = min(stretch_val, 107);
            frameOut = make_framevector_gs2(frame, stretch_val);
        end
        pat_vector = [pat_vector, frameOut];
    end
end

