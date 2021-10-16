function [ mutated_pos ] = LOCAL_SEARCH_DISCRETE( pos, Xmin, Xmax,a )
tmpPos = rounding( pos );
minPos = rounding( Xmin );
maxPos = rounding( Xmax );
if rand() > 0.5
    if tmpPos < maxPos
        mutated_pos = tmpPos + 1*a;
    else
        mutated_pos = tmpPos - 1*a;
    end
else
    if tmpPos > minPos
        mutated_pos = tmpPos - 1*a;
    else
        mutated_pos = tmpPos + 1*a;
    end
end
end