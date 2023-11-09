# Inicialisation

im_org = [1 1 1 1 0;
1 1 1 1 0;
1 1 1 1 0;
1 1 0 0 0;
0 1 0 0 0];

im_org = [0 0 0 0 1 1;
0 0 0 0 1 1;
0 0 0 0 1 1;
0 0 0 1 1 1;
0 0 1 1 1 1;
0 1 1 1 1 1];

figure;
subplot(1, 3, 1);
imshow(im_org);

magfactorx = 3;
magfactory = 2;

# -------------------------------------
# ------ Initial intepolation ---------
# -------------------------------------

[imheight, imwidth, _] = size(im_org);
magimageheight = floor(imheight*magfactory);
magimagewidth = floor(imwidth*magfactorx);

im_high = imresize(im_org, [magimageheight, magimagewidth], "bicubic");
# Dodana napaka v ostrenju/glajenju
im_high(3:4, 3:4) = 1;

subplot(1, 3, 2);
imshow(im_high);

# -----------------------------
# ------ SENZOR MODEL ---------
# -----------------------------

tic;

# Data inicialisation
[imheight, imwidth, _] = size(im_org);
[magimageheight, magimagewidth, _] = size(im_high);

# KERNEL
kernel_size = 3;
kernel = fspecial('gaussian', kernel_size,0.85);
box_size_x = ceil(magfactorx) + 1;
box_size_y = ceil(magfactory) + 1;

# iterate over low resolution pixels
for z = 1:150

for i = 1 : imwidth
  for j = 1 : imheight

    if (i == 3) && (j == 4)
      levi_kot = 1;
    endif

    # Pixel to gray value
    #lr_pix = im_org(i, j);
    #value = lr_pix(1) + lr_pix(2) + lr_pix(3);
    value = im_org (j,i);

    #disp("Bounding box");
    # Highresolution bounding box for (i, j) pixel
    # calculate central pixel on magnified picture
    box_center_x = ceil(magfactorx * (i-0.5));
    box_center_y = ceil(magfactory * (j-0.5));

    # Bounding box (odvisen od povečave v obe strani)
    box_x_left = box_center_x - floor(box_size_x/2);
    box_x_right = box_center_x + floor(box_size_x/2);
    box_y_top = box_center_y - floor(box_size_y/2);
    box_y_bottom = box_center_y + floor(box_size_y/2);

    #disp("Iteration over bounding box");
    # Iterate over the high resolution bounding box and perform the convolution
    sum_w = 0;
    sumweights = 0;
    for x = box_x_left : box_x_right
      for y = box_y_top : box_y_bottom

        # check for bounds - po potrebi oz. naštimaj, da tega ne rabiš
        if (x > 0) && (y > 0) && (x <= magimagewidth) && (y <= magimageheight)

          # find out where this high res pixel maps into low res
          low_x = ceil((x - 0.5)/magfactorx);
          low_y = ceil((y - 0.5)/magfactory);

          # calculate the nearest kernel subdivision
          kernelx = low_x - i + (kernel_size - 1)/2  + 1;
          kernely = low_y - j + (kernel_size - 1)/2 + 1;

          sum_w += im_high(y, x) * kernel(kernely, kernelx);
          sumweights += kernel(kernely, kernelx);

        endif
      end
    end
    # calculate the difference between high res average and low res pixel
    diff = value - sum_w/sumweights;

    # BACKPROPAGATION
    # to do this, we take our diff variable, multiply by the nearest
    # kernel subdivision weight, and then divide by the sum of the weights
    for x = box_x_left : box_x_right
      for y = box_y_top : box_y_bottom

        # check for bounds
        if (x > 0) && (y > 0) && (x <= magimagewidth) && (y <= magimageheight)

          # find out where this high res pixel maps into low res
          low_x = ceil((x - 0.5)/magfactorx);
          low_y = ceil((y - 0.5)/magfactory);

          # calculate the nearest kernel subdivision
          kernelx = low_x - i + (kernel_size - 1)/2 + 1;
          kernely = low_y - j + (kernel_size - 1)/2 + 1;

          correction = diff * kernel(kernely, kernelx) / sumweights;
          im_high(y, x) = im_high(y, x) + correction;

          if im_high(y, x) > 1
            im_high(y, x) = 1;
          elseif im_high(y, x) < 0
            im_high(y, x) = 0;
          endif

        endif
      end
    end
  end
end
end

timeElapsed = toc;
disp("Time:");
disp(timeElapsed);
subplot(1, 3, 3);
imshow(im_high);

