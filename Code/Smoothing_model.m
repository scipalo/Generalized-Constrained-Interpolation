       
# --- slike ---

im_1 = [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1;
0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1;
0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1;
0.1 0.1 0.1 0.1 0.6 0.6 0.6 0.6 0.6 0.6;
0.1 0.1 0.1 0.1 0.6 0.6 0.6 0.6 0.6 0.6;
0.1 0.1 0.1 0.1 0.6 0.6 0.6 0.6 0.6 0.6;
0.1 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.1 0.1;
0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.6 0.1 0.1;
0.6 0.6 0.6 0.6 0.6 0.6 0.1 0.1 0.1 0.1;
0.6 0.6 0.6 0.6 0.6 0.1 0.1 0.1 0.1 0.1] + 0.1;
#im_1 = im_1(6:10, 4:7);

im_3 = imread('slike/full_circle.png');
im_3 = double(im_3);
im_3 = im2bw(im_3, 0.99);
im_3 = im_3(1:120, 1.:120);
# im_3 = im_3(5:10, 70:80); 
# im_3 = im_3(215:225, 145:150);

im_4 = imread('slike/zebra.png');
#im_4 = im_4(1:464, 1:329); # 10 sec
#im_4 = im_4(200:300, 200:300); # 5 sec - Zebra iz predstavitve
im_4 = im_4(260:270, 200:220); # 10 sec

im_5 = imread('slike/Rachel.png');
im_5 = im_5(1:512, 1:512);

im_org = im_4; 

# --- Testing ---

if max(max(im_org)) > 150
  mini = 0;
  maxi = 255;
else 
  mini = 0;
  maxi = 1;
endif
  
visual = 1;
time = 1;

# --- init 1 ---

magfactorx = 2;
magfactory = 2;

im_org = double(im_org);
[im_hight, im_width, _] = size(im_org);

magimageheight = floor(im_hight*magfactory);
magimagewidth = floor(im_width*magfactorx);
im_mag = imresize(im_org, [magimageheight, magimagewidth], "bilinear");
im_bicubic = double(im_mag);

# Colors to gray

if ndims(im_mag) == 3
  im_mag = rgb2gray(im_mag);
  disp('Job done: piksel to gray');
end

# -------- metoda ----------
# ---- SMOOTHTING MODEL ----
# --------------------------

tic;

[height, width, _] = size(im_mag);
correction = zeros(height, width);
curvature = zeros(height, width);
mask = ones(height, width);
mask(1 : height - 1, 1 : width - 1) = 0;

convergence = 0;

while range(range(mask)) > 0 # convergence < 2
  
  convergence += 1;
  fprintf('Round: %i \n', convergence);  
  
  # Izračun odvodov
 
  [Fx,Fy] = gradient(im_mag);
  [Fxy, Fyy] = gradient(Fy);
  Fxx = gradient(Fx);
  
  # ------------------------------
  # ------- SMOOTHING ------------
  # --- correction calculation ---
  # ------------------------------
  
  for i = 1 : width
    for j = 1 : height

      if mask(j, i) < 1
  
          #odvodi
          dx = Fx(j, i);
          dy = Fy(j, i);
          dxx = Fxx(j, i);
          dxy = Fxy(j, i);
          dyy = Fyy(j, i);

          # Izračun popravka
          
          imenovalec = dx*dx*dyy - 2*dx*dy*dxy + dy*dy*dxx;
          stevec = dx*dx + dy*dy;

          correction(j, i) = 0;
          if stevec != 0; 
            correction(j, i) = imenovalec/stevec;
            curvature = imenovalec/sqrt(stevec^3);
  
          endif
          
          # --- Infection mask ---
          
          # treshold za ukrivljenost
          # Op: Bi bilo bolje, da ga merim brez grad. mag. (linearnost)
          # Op: Okno mora biti večje od jaggies > Kaj je s tem? 
          # > Kaj zajame curvature - je dovolj veliko okno? 
          
          if curvature(j,i) < 20
            mask(j,i) = 1;
          endif
          
          im_mag(j, i) = im_mag(j, i) + correction(j ,i);

      endif
      
    endfor
  endfor
   
  timeElapsed = toc;
  disp(timeElapsed);
  
end

im_smooth = im_mag;

if visual == 1
  figure;
  subplot(1, 2, 1);
  imshow(im_bicubic, [mini, maxi]);
  subplot(1, 2, 2);
  imshow(im_smooth, [mini, maxi]);

  figure;
  title('Curvature and correction');
  subplot(1, 3, 1);
  imshow(curvature, []);
  subplot(1, 3, 2);
  imshow(correction, []);
  subplot(1, 3, 3);
  imshow(mask, []);

endif

if time == 1
  timeElapsed = toc;
  disp("Time total:");
  disp(timeElapsed);
endif
