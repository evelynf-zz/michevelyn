function [match] = getPatchMatch(target, styleIm, patch_w, patch_stride, iPixLow, iPixHigh, jPixLow, jPixHigh)
% for patch from (iLow:iHigh, jLow:jHigh) in the target image, we will find the 
% optimal patch "match" in the style image which best mimics the original patch
grayTargetIm = double(rgb2gray(target));
grayStyleIm = double(rgb2gray(styleIm));

c_patch = grayTargetIm(iPixLow:iPixHigh, jPixLow:jPixHigh);

[s_h,s_w,~] = size(styleIm);
nearestDist = Inf;
k_opt_pix = 0;
l_opt_pix = 0;
for k_pix=1:patch_stride:(s_h-patch_w) %ignoring the edges of the photo here
    for l_pix=1:patch_stride:(s_w-patch_w)
        styleRegion = grayStyleIm(k_pix:k_pix+patch_w-1, l_pix:l_pix+patch_w-1);
%         dist = norm(c_patch - styleRegion); %pca here if need to save time
        [index, dist] = knnsearch(styleRegion, c_patch);
        %add noise to the norm, to allow patch matching alg to make more
        %venturous guesses
        dist = dist+0.1*min(dist)*randn(size(dist)); % add some noise to NN 
        
         if (norm(dist) < nearestDist)
             nearestDist = norm(dist);
             k_opt_pix = k_pix;
             l_opt_pix = l_pix;
        end
    end
end

% match = styleIm(k_opt_pix:k_opt_pix+patch_w-1,l_opt_pix:l_opt_pix+patch_w-1,:); 
match = [k_opt_pix, k_opt_pix+patch_w-1, l_opt_pix, l_opt_pix+patch_w-1];

% figure;
% subplot(1,2,1); imshow(target(i_pix:i_pix+patch_w-1, j_pix:j_pix+patch_w-1,:));
% subplot(1,2,2); imshow(match);

% k_opt = k_opt_pix/patch_stride;
% l_opt = l_opt_pix/patch_stride;
end