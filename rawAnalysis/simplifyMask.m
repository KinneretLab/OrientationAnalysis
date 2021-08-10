function outputMask = simplifyMask (inputMask,windowSize);
% function outputMask = simplifyMask (inputMask,windowSize);
% This function takes the 'inputMask' and makes it smoother by convovlving
% with a kernel of size 'windowSize' (optional input, defualt value =41)and applying a
% threshold on the convovled image; generates a smoother 'outputMask'
%
% INPUT
%   inputMask - can be a 2D binary image or a array of n images (sizei, sizej, n images)
%   windowSize (optional) defualt value =41
% OUTPUT
%   outputMask

if ~exist('windowSize'), windowSize = 41; end % enter default value for windowSize if there is no input
windowSize = round (windowSize); % make sure window size in an integer

% this blurs the image
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = convn(inputMask, kernel, 'same'); % the convn works on the first two dimension, so can work on imputMask of multiple images
outputMask = blurryImage > 0.5; % Threshold the convovled image to obtain new mask 
end
