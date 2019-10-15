function string = join(parts,spacer)

num_parts = length(parts);

string = parts{1};
if num_parts>1
    for i = 2:num_parts
        string = [string spacer parts{i}];
    end
end

end