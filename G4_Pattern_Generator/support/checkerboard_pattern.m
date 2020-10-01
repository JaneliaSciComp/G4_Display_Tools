function Pats = checkerboard_pattern(Pats1, Pats2)
%FUNCTION frame = checkerboard_pattern(frame1, frame2)
%converts two pattern matrices into a single matrix, rearranged so that the
%first pattern will be displayed on one half of a checkerboard-layout LED
%panel, and the second pattern will fill the other half of the
%checkerboard.
%
%frame1: pattern that will fill checkerboard starting at (1,1)
%frame2: pattern that will fill checkerboard starting at (1,2)

load('C:\matlabroot\G4\Arena\arena_parameters.mat');

if nargin==1 %for only 1 pattern input, duplicate it for both checkboards
    Pats2 = Pats1;
end

[h1, w1, f1] = size(Pats1); %height, width, and number of indices in frame(s)
[h2, w2, f2] = size(Pats2); 

%if either input is 0, create a full pattern matrix of zeros
if h1==1 && w1==1 && f1==1 && Pats1==0
    Pats1 = zeros(size(Pats2));
    [h1, w1, f1] = size(Pats1);
end
if h2==1 && w2==1 && f2==1 && Pats2==0
    Pats2 = zeros(size(Pats1));
    [h2, w2, f2] = size(Pats2);
end
assert(h1==h2&w1==w2,'size of patterns to be merged must be the same')

if f1~=f2
    if f1==1 && f2>1
        Pats1 = repmat(Pats1,[1 1 f2]);
        f1 = f2;
    elseif f2==1 && f1>1
        Pats2 = repmat(Pats2,[1 1 f1]);
        f2 = f1;
    else
        error('the two input patterns must have either the same number of frames, or only 1 frame')
    end
end

Pats = nan(h1,w1,f1);

unit = aparam.Psize/2;
q = w1/unit; %width of arena in number of 8-column repeating units

out_idx_1 = [];
out_idx_2 = [];
for quad = 1:q
    out_idx_2 = [out_idx_2  h1*unit*(quad-1)+(1:h1*unit/2)]; %checkerboard index 1
    out_idx_1 = [out_idx_1  h1*unit*(quad-0.5)+(1:h1*unit/2)]; %checkerboard index 1
end

in_idx_1 = [];
in_idx_2 = [];
for col = 1:2:w1
    in_idx_1 = [in_idx_1  (h1*(col-1))+reshape([1:2:h1;h1+(2:2:h1)],[1 h1])];
    in_idx_2 = [in_idx_2  (h1*(col-1))+reshape([h1+(1:2:h1);2:2:h1],[1 h1])];
end

for f = 1:f1
    frame = nan(h1,w1);
    frame1 = Pats1(:,:,f);
    frame2 = Pats2(:,:,f);
    frame(out_idx_1) = frame1(in_idx_1); %checkerboard1 from frame1 fills group1
    frame(out_idx_2) = frame2(in_idx_2); %checkerboard2 from frame2 fills group2
    Pats(:,:,f) = frame;
end

end
