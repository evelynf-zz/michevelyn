C = im2double(imread('house.jpg'));
S = im2double(imread('painting.jpg'));

% get key feature
imshow(C);
rect = imrect();

%% make the hallucinated image
whiteIm = ones(size(C));
unbiasedW = ones(400,400);

% our estimate of the style transfer result to get the hallucination
% initialized as content image in the color scheme of the style image
blurredC = imgaussfilt(C,100);
workingH = noisyColorTransfer(blurredC,S,1);

patch_widths = [33 21];
patch_strides = [21 18];
[~,numPatchTrials] = size(patch_widths); 

L_vals = [4 2 1];
for L=L_vals
    for i=1:numPatchTrials
        workingH = executeStyleTransfer(workingH, C, S, true, whiteIm, unbiasedW, L, patch_widths(i), patch_strides(i));
    end
end

H = workingH;

%% make the style transfer image

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
blurredEdgeC = imgaussfilt(edgeCoeff*edgesC, sigmaBlur);
blurredEdgeKey = imgaussfilt(edgeCoeff*edgesKey, sigmaBlur);
mask = blurredEdgeC > mean2(blurredEdgeC);
maskKey = blurredEdgeKey > mean2(blurredEdgeKey);
maskedGrayC = activecontour(grayC,mask);
maskedGrayK = activecontour(grayKey, maskKey);
maskedGrayKey = ones(iMax - iMin + 1, jMax - jMin + 1); %1 offset
% put in key feature
% blurredEdgeC(iMin: iMax, jMin:jMax) = blurredEdgeKey;
% maskedGrayC(iMin: iMax, jMin:jMax) = maskedGrayKey;

blurredEdgeCoeff = 10;
biasedW = imgaussfilt(double(maskedGrayC+blurredEdgeCoeff*blurredEdgeC),sigmaBlur);

workingX = noisyColorTransfer(C,S,5);

patch_widths = [33 21 13 9];
patch_strides = [21 18 8 5];
[~,numPatchTrials] = size(patch_widths); 

L_vals = [4 2 1];
for L=L_vals
    for i=1:numPatchTrials
        workingX = executeStyleTransfer(workingX, C, S, false, H, biasedW, L, patch_widths(i), patch_strides(i));
    end
end

X = workingX;

figure;
subplot(2,2,1); imshow(S); title('Style');
subplot(2,2,2); imshow(C); title('Content');
subplot(2,2,3); imshow(H); title('Hallucination');
subplot(2,2,4); imshow(X); title('Final Output');
