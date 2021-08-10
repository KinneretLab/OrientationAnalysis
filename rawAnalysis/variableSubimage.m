function y = variableSubimage(x, d ,ntot , n);
% function x = variableSubimage(x, d ,ntot , n)
% make submatrix along dimension d divided into ntot part and give the nth
% one
  index = repmat({':'},1,ndims(x));  %# Create a 1-by-ndims(x) cell array
                                     %#   containing ':' in each cell
  index{d} = ((n-1)* size(x,d)/ntot) + [1:size(x,d)/ntot];          %# Create an index for dimension d
  y = x(index{:});                   %# Index with a comma separated list
end