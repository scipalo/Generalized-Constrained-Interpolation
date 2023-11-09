
# Inicialisation

im_1 = [0.1 0.1 0.1 0.1 0.1 0.1;
0.1 0.1 0.1 0.1 0.1 0.6;
0.1 0.1 0.1 0.1 0.6 0.6;
0.1 0.1 0.1 0.9 0.6 0.6;
0.1 0.1 0.9 0.9 0.6 0.6;
0.1 0.9 0.9 0.9 0.6 0.6];

im_2 = [0.1 0.2 0.3 0.4 0.5 0.6;
0.1 0.2 0.3 0.4 0.5 0.6;
0.1 0.2 0.3 0.4 0.5 0.6;
0.9 0.9 0.9 0.6 0.6 0.6;
0.9 0.9 0.9 0.6 0.6 0.6;
0.9 0.9 0.9 0.6 0.6 0.6];

im_3 = imread('slike/zebra.png');
im_3 = im_3(150:200, 50:100);

im_4 = imread('slike/Rachel.png');
#im_4 = im_4(200:300, 200:300);

im_5 = [0.6 0.5 0.4 0.3
0.5 0.4 0.3 0.2
0.4 0.3 0.2 0.1
0.3 0.2 0.1 0.0] + 0.2;

# Test sharp model meshing

im_b2 = [0 0 0 255 255 255
0 0 0 255 255 255
0 0 0 255 255 255
0 0 0 255 255 255
0 0 0 255 255 255
1 1 1 255 255 255];

im_b4 = [50 50 50 150 150 150
50 50 50 150 150 150
50 50 50 150 150 150
50 50 50 150 150 150
50 50 50 150 150 150
50 50 50 150 150 150];

im_c = [0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9];

im_org = im_b4;
if max(max(im_org)) > 140
  mini = 0;
  maxi = 255;
else 
  mini = 0;
  maxi = 1;
endif

# --- init ---

if ndims(im_org) == 3
  im_org = rgb2gray(im_org);
  disp('Job done: piksel to gray');
end

magfactorx = 2;
magfactory = 2;

[imhight, imwidth, _] = size(im_org);
magimageheight = floor(imhight*magfactory);
magimagewidth = floor(imwidth*magfactorx);
im_mag = imresize(im_org, [magimageheight, magimagewidth], "bilinear");
im_mag = double(im_mag);

# -------------------------------------
# -------- Sharpening model -----------
# ----- Calculating nudge flow --------
# -------------------------------------

tic;
im_bicubic = im_mag;
im_sharp_new = im_mag;
alpha = 7;

[im_hight, im_width, _] = size(im_org);
[immag_hight, immag_width, _] = size(im_mag);

for fake_loop = 1 : 1

  # Potrebujemo verzijo ki se spreminja in verzijo, ki se ohranja
  
  im_sharp = im_sharp_new;

  # Izračun odvodov

  [Dx, Dy] = gradient(im_sharp);
  [Dxy, Dyy] = gradient(Dy);
  Dxx = gradient(Dx);
  
  # calculate our DValues [sharpening values]
  nudge_flow = ones(immag_hight, immag_width);
  for i = 2 : immag_width - 1
    for j = 2 : immag_hight - 1

      # calculate Iww using local derivatives
      xval = Dx(j, i);
      yval = Dy(j, i);
      xyval = Dxy(j, i);
      xxval = Dxx(j, i);
      yyval = Dyy(j, i);
      # the second derivatives in the direction of the gradient
      iwwval = xval*xval*xxval + 2.0*xval*yval*xyval + yval*yval*yyval;

      # calculate possible upwind derivatives
      dxpos = im_sharp(j, i + 1) - im_sharp(j, i);
      dxneg = im_sharp(j, i) - im_sharp(j, i - 1);
      dypos = im_sharp(j + 1, i) - im_sharp(j, i);
      dyneg = im_sharp(j, i) - im_sharp(j - 1, i);

      if dxpos * dxneg <= 0
        #don’t move
        xval = 0;
      elseif iwwval * dxpos >= 0
        xval = dxpos;
      else
        xval = dxneg;
      end

      if dypos * dyneg <= 0
        #don’t move
        yval = 0;
      elseif iwwval * dypos >= 0
        yval = dypos;
      else
        yval = dyneg;
      end

      # calculate the gradient magnitude from the upwind derivatives
      gradmag = sqrt( (xval * xval) + (yval * yval) );

      # gradmag needs to have oposite sign of the iwwval sign
      if iwwval > 0
        gradmag *= -1;
      elseif iwwval == 0
        gradmag = 0.0;
      end

      # Vrednosti popravljana pikslov, da se probližuje vrednosti proč od roba.
      nudge_flow(j, i) = gradmag; # min(gradmag, max_slope);
      im_sharp_new(j, i) += nudge_flow(j, i);

      # normalizacija slike (Ali je potrebna, ko imamo max_slope? Ne)
      #im_sharp_new(j, i) = min(im_sharp_new(j, i), maxi);
      #im_sharp_new(j, i) = max(im_sharp_new(j, i), mini);

    endfor
  endfor

endfor # fake loop 

timeElapsed = toc;
disp("Time:");
disp(timeElapsed);

figure;
subplot(2, 2, 1);
title("Original")
imshow(im_org, [mini, maxi]);
subplot(2, 2, 2);
imshow(im_bicubic, [mini, maxi]);
subplot(2, 2, 3);
imshow(im_sharp_new, [mini, maxi]);
subplot(2, 2, 4);
imshow(nudge_flow, []);

