# Test nudge flow function

im_4 = imread('slike/Rachel.png');
im_4 = im_4(200:300, 200:300);
im_org = im_4;
im_org = double(im_org);

[im_hight, im_width, _] = size(im_org);
magimageheight = floor(im_hight*magfactory);
magimagewidth = floor(im_width*magfactorx);

im_mag = imresize(im_org, [magimageheight, magimagewidth], "bilinear");
im_mag = double(im_mag);
if ndims(im_mag) == 3
  im_mag = rgb2gray(im_mag);
  disp('Job done: piksel to gray');
end

magfactorx = 2;
magfactory = 2;

# Ostrenje

nudge_flow = Sharpening_model_nudge_flow_fun(im_org, im_mag, magfactorx, magfactory);
im_sharp = im_mag + nudge_flow;

figure;
subplot(1,2,1);
imshow(im_mag, []);
subplot(1,2,2);
imshow(im_sharp, []);


