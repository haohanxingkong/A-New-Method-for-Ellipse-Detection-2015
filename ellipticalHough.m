function data = ellipticalHough(im,maxLength,th)
% ellipticalHough, Hough transform-based ellipse detection method
%
% data = ellipticalHough(im,maxLength,th)
%
% Details   Fits an ellipse by examining all possible major axes
%           (all pairs of points) and getting the minor axis using Hough 
%           transform. The algorithm complexity depends on the number of
%           valid non-zero points.
%
%           The code is reasonably fast due to full code vectorization. 
%           However, as the algorithm needs to compute pairwise point 
%           distances, it can be quite memory intensive. If you get out 
%           of memory errors, either downsample the input image or somehow
%           decrease the number of non-zero points in it. It can deal 
%           with big amount of noise but can have severe problem with
%           occlusions (major axis end points need to be visible)
%
% Inputs    im - Edge image
%           maxLength - Scale value denoting the maximum major/minor axis
%           length to consider (if a vector denotes [minimum,maximum]
%           major/minor axis length)
%           th - Threshold within range [0,1] for accumulator arrays
%
% Outputs   data - a matrix of ellipses. Each row contains five elements:
%           the center of the ellipse, its major and minor axes and
%           orientation of the major axis.
%
% Based on  "A New Efficient Ellipse Detection Method" (Yonghong Xie 
%           Qiang , Qiang Ji / 2002)
%
% Developed from    Simonovsky, Martin (2013) <a href="http://www.mathworks.com/matlabcentral/...
%                       fileexchange/3970-ellipse-detection-using-1d-hough-transform">
%					Ellipse Detection Using 1D Hough Transform</a>, MATLAB Central 
%					File Exchange. Retreived December, 2014.
%                   Release 1.1. Release date 25th July 2013.
% 
% Examples:
% data = ellipticalHough(im,[1,20],0.8), detects ellipses with axes of
% lengths between 1 and 20 pixels using 0.8 as the accumulator array
% threshold for accepted ellipses.
%    
% License   Redistribution and use in source and binary forms, with or
%           without modification, are permitted provided that the 
%           following conditions are met:
%           * Redistributions of source code must retain the above copyright
%               notice, this list of conditions and the following disclaimer.
%           * Redistributions in binary form must reproduce the above 
%               copyright notice, this list of conditions and the 
%               following disclaimer in the documentation and/or other 
%               materials provided with the distribution
%       
%            THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
%            IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
%            THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
%            PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
%            CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
%            EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
%            PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
%            PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%            LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%            NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%            SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% See also POD2, PODH, PODEXPERIMENTS

%% Inputs
if nargin<3; th = 0.8; end
if nargin<2; maxLength = min(size(im)); end
if length(maxLength)>1
    minLength = maxLength(1);
    maxLength = maxLength(2);
else
    minLength = 1;
end
%% Set-Up
eps = 0.0001;
data = [];
%% Step 1: Store all edge pixels in a 1D array
[Y,X]=find(im);
Y = single(Y); X = single(X);
%% Step 4: Compute Pairwise Distance, Filter for Desired Length Range
% N.B. uses distance squared throughout code (c.f. paper)
distsSq = bsxfun(@minus,X,X').^2 + bsxfun(@minus,Y,Y').^2;
[I,J] = find(distsSq>=minLength^2 & distsSq<=maxLength^2);
idx = I<J;
I = uint32(I(idx)); J = uint32(J(idx));
pairSubset = 1:length(I);
clear idx minLength
%% Steps 5-14
for p=pairSubset
    x1=X(I(p)); y1=Y(I(p));
    x2=X(J(p)); y2=Y(J(p));
    %% Step 5: Use Equations 1-4 to Calculate Center, Orientation] and Major Axis
    x0=(x1+x2)/2; % Eq. 1
    y0=(y1+y2)/2; % Eq. 2
    aSq = distsSq(I(p),J(p)); % Eq. 3
    %% Step 6: Compute Pairwise Distance for Each Third Pixel
    thirdPtDistsSq = (X-x0).^2 + (Y-y0).^2;
    K = thirdPtDistsSq <= (aSq/4);
    fSq = (X(K)-x2).^2 + (Y(K)-y2).^2;
    %% Step 7: Use Equations 5-6 to Calculate Minor Axis of All Possible Third Points
    cosTau = ((aSq/4) + thirdPtDistsSq(K) - fSq) ./ (2*sqrt((aSq/4)*thirdPtDistsSq(K))); % Eq. 6
    cosTau = min(1,max(-1,cosTau)); %inexact float arithmetic?!
    sinTauSq = 1 - cosTau.^2;
    b = sqrt( ((aSq/4) * thirdPtDistsSq(K) .* sinTauSq) ./ ((aSq/4) - thirdPtDistsSq(K) .* cosTau.^2 + eps) ); %Eq. 5
    clear thirdPtDistsSq K fSq cosTau sinTauSq
    %% Step 8: Incremement Accumulator as Appropriate
    idxs = ceil(b+eps);
    accumulator = accumarray(idxs, 1, [maxLength 1]);
    clear b idxs
    %% Step 10: Find Maximum in Accumulator
    [score, idx] = max(accumulator);
    clear accumulator
    %% Side Step: Angle
    angle = atand((y1-y2)/(x1-x2));
    if angle<0
        angle = -angle;
    elseif angle>0
        angle = 180-angle;
    end
    clear x1 x2 y1 y2
    %% Step 11: Output Ellipse Parameters
    data(end+1,:) = [x0+0.5 y0+0.5 sqrt(aSq) 2*idx angle score];
    clear x0 y0 aSq idx angle score
end
clear pairSubset p X Y I J distSq eps
%% Threshold for Ellipses
thresh = th * max(data(:,6));
idt = find(data(:,6)>=thresh);
data = data(idt,:);
clear thresh th idt
%% Sort
if size(data,1)>0
    [~,si]=sort(data(:,end),'descend');
    data = data(si,:);
end
data(:,6) = [];
clear si
end
