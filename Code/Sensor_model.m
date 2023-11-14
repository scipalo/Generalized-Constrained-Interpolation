# --- Test images ---

im_1 = [1 1 1 1 0;
1 1 1 1 0;
1 1 1 1 0;
1 1 0 0 0;
0 1 0 0 0];

im_2 = [0 0 0 0 1 1;
0 0 0 0 1 1;
0 0 0 0 1 1;
0 0 0 1 1 1;
0 0 1 1 1 1;
0 1 1 1 1 1];

im_r = imread('slike/Rachel.png');
#im_r = im_r(247:252, 250:254);
#im_r = im_r(1:412, 50:462);
im_r = im_r(200:300, 200:300);

# Odsek slike rachel z dodanim šumom
im_org = im_r;

# -----------------------
# ------ Testing --------
# -----------------------

tic;
time = 1;
visual= 1;
comments = 0;

if max(max(im_org)) > 140
  mini = 0;
  maxi = 255;
else 
  mini = 0;
  maxi = 1;
endif

# --------------------
# ------ Init --------
# --------------------

magfactorx = 2;
magfactory = 2;

im_org = double(im_org);
[im_hight, im_width, _] = size(im_org);

immag_hight = floor(im_hight*magfactory);
immag_width = floor(im_width*magfactorx);
im_mag = imresize(im_org, [immag_hight, immag_width], "bilinear");
im_mag = double(im_mag);

# Dodana napaka v ostrenju/glajenju

#im_mag(3:5, 3:5) = 250;
im_mag(10:100,10:100) = 200;
im_mag_init = im_mag;

# -----------------------------
# ------ SENZOR MODEL ---------
# -----------------------------

tic;

# Data inicialisation
[im_hight, im_width, _] = size(im_org);
[immag_hight, immag_width, _] = size(im_mag);

# KERNEL
kernel_size = 3; # Ali to drži tudi za povečavo 3+ ?
kernel = fspecial('gaussian', kernel_size,0.85);
box_size_x = ceil(magfactorx) + 1;
box_size_y = ceil(magfactory) + 1;

# iterate over low resolution pixels 
# Why: to map all LR pixels with HR areas and corrrect values

for z = 1:10

for i = 1 : im_width
  for j = 1 : im_hight

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
        if (x > 0) && (y > 0) && (x <= immag_width) && (y <= immag_hight)

          # find out where this high res pixel maps into low res
          low_x = ceil((x - 0.5)/magfactorx);
          low_y = ceil((y - 0.5)/magfactory);

          # calculate the nearest kernel subdivision
          kernelx = low_x - i + (kernel_size - 1)/2  + 1;
          kernely = low_y - j + (kernel_size - 1)/2 + 1;

          sum_w += im_mag(y, x) * kernel(kernely, kernelx);
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
        if (x > 0) && (y > 0) && (x <= immag_width) && (y <= immag_hight)

          # find out where this high res pixel maps into low res
          low_x = ceil((x - 0.5)/magfactorx);
          low_y = ceil((y - 0.5)/magfactory);

          # calculate the nearest kernel subdivision
          kernelx = low_x - i + (kernel_size - 1)/2 + 1;
          kernely = low_y - j + (kernel_size - 1)/2 + 1;

          correction = diff * kernel(kernely, kernelx) / sumweights;
          im_mag(y, x) = im_mag(y, x) + correction;

          %{
          # umirjanje presežkov
          if im_mag(y, x) > 1
            im_mag(y, x) = 1;
          elseif im_mag(y, x) < 0
            im_mag(y, x) = 0;
          endif
          %}

        endif
      end
    end
  end
end
end

if time == 1
  timeElapsed = toc;
  disp("Time:");
  disp(timeElapsed);
endif

if visual == 1
  figure;
  subplot(1, 3, 1);
  imshow(im_org, [mini, maxi]);
  subplot(1, 3, 2);
  imshow(im_mag_init,[mini, maxi]);
  subplot(1, 3, 3);
  imshow(im_mag, [mini, maxi]);
endif
