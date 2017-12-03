function [colNoisyIm] = noisyColorTransfer(contentIm, styleIm, sigmaScaling)
dContentIm = im2double(contentIm);
dStyleIm = im2double(styleIm);

% choose to use the color of the style image (will probably look better)
coloredContent = imhistmatch(dContentIm, dStyleIm);


sigma = max(max(max(coloredContent)));
colWithNoise = coloredContent + (sigma/sigmaScaling)*randn(size(coloredContent));


% figure;
% subplot(2,2,1); imshow(dContentIm);
% subplot(2,2,2); imshow(dStyleIm);
% subplot(2,2,3); imshow(coloredContent);
% subplot(2,2,4); imshow(colWithNoise);

colNoisyIm = colWithNoise;
end
