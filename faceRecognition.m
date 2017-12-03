C = im2double(imread('selfie.jpg'));

% get key feature
imshow(C);
rect = imrect();

mask = rect.createMask;
[I, J] = find(mask);
sizeI = size(I);
sizeJ = size(J);
iMin = I(1);
iMax = I(sizeI(1));
jMin = J(1);
jMax = J(sizeJ(1));

% get the content edges
grayC = rgb2gray(C);
grayKey = grayC(iMin: iMax, jMin:jMax);
logThreshold = .03;
sigmaEdge = 1; 
edgesC = edge(grayC, 'log', logThreshold, sigmaEdge);
edgesKey = edge(grayKey, 'log', logThreshold, sigmaEdge);

% get the contour
edgeCoeff = .5;
sigmaBlur = 7;
blurredEdgeC = imgaussfilt(edgeCoeff*edgesC, 11);
blurredEdgeKey = imgaussfilt(edgeCoeff*edgesKey, sigmaBlur);
mask = blurredEdgeC > mean2(blurredEdgeC);
maskKey = blurredEdgeKey > mean2(blurredEdgeKey);
maskedGrayC = activecontour(grayC,mask);
maskedGrayKey = activecontour(grayKey, maskKey);
maskedGrayKey = ones(iMax - iMin + 1, jMax - jMin + 1); %1 offset
% put in key feature
blurredEdgeC(iMin: iMax, jMin:jMax) = blurredEdgeKey;
maskedGrayC(iMin: iMax, jMin:jMax) = maskedGrayKey;

blurredEdgeCoeff = 10;
biasedW = imgaussfilt(double(maskedGrayC+blurredEdgeCoeff*blurredEdgeC),sigmaBlur);