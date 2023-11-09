       
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

im_4 = imread('slike/zebra.png');
#im_4 = im_4(1:464, 1:329); # 10 sec
im_4 = im_4(200:300, 200:300); # 5 sec

im_5 = imread('slike/Rachel.png');
im_5 = im_5(1:512, 1:512);

im_org = im_3;

if max(max(im_org)) > 200
  mini = 0;
  maxi = 255;
else 
  mini = 0;
  maxi = 1;
endif
  

# --- init 1 ---

magfactorx = 2;
magfactory = 2;

im_org = double(im_org);
[im_hight, im_width, _] = size(im_org);

magimageheight = floor(im_hight*magfactory);
magimagewidth = floor(im_width*magfactorx);
im_mag = imresize(im_org, [magimageheight, magimagewidth], "bilinear");
im_bicubic = double(im_mag);

# -------- metoda ----------
# ---- SMOOTHTING MODEL ----
# --------------------------

tic;
[height, width, _] = size(im_mag);


# Colors to gray

if ndims(im_mag) == 3
  im_mag = rgb2gray(im_mag);
  disp('Job done: piksel to gray');
end

# Robove nastavimo na 1, ker jih algoritem ne pokrije
windowx = floor((magfactorx + 1)/2);
windowy = floor((magfactory + 1)/2);
mask = ones(height, width);
mask(windowy + 1 : height - windowy, windowx + 1 : width - windowx) = 0;

correction = zeros(height, width);
ranges = zeros(height, width);

mask_sum = 0;
convergence = 0;
round = 1;

while range(range(mask)) > 0 # convergence < 6
  
  convergence += 1;
  fprintf('Round: %i \n', convergence);  
  
  # Stopping condition (treshold)
  
  #if mask_sum == sum(sum(mask))
  #  mask_convergence += 1;
  #endif
  #mask_sum = sum(sum(mask));   
 
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

      #if mask(j, i) < 1
  
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
          endif
          
          im_mag(j, i) = im_mag(j, i) + correction(j ,i);

      # endif
    endfor
  endfor
  
  timeElapsed = toc;
  disp(timeElapsed);
  
  # --- stopping criterium ----
  # ---- INFLECTION MASK ------
  # ---------------------------

  # Okno mora biti večje od jaggies, da ujamemo inflection point

  curvature_k = sign(correction);
  
  for i = windowx + 1 : width - windowx
    for j = windowy + 1 : height - windowx
      
      if mask(j, i) < 1
    
        c = curvature_k(j - windowy: j + windowy, i - windowx: i + windowx);
        [min_c, max_c] = bounds(c);
        min_c = min(min_c);
        max_c = max(max_c);
        ranges(j, i) = abs(min_c - max_c); # Testing variable

        # Test konkavnosti/ konveksnosti na podlagi predznakov        
        
        if abs(min_c - max_c) > 1
          
          # Popravimo vrednost piksla in prekinemo stop pogoj za while zanko
          # im_mag(j, i) = im_mag(j, i) + correction(j ,i);
          mask(j, i) = 0;
          
        else
         
          # Sosešččina je konveksna, zato onemogočimo nadaljno glajenje tega piksla
          mask(j, i) = 1;
        
        endif
      
      endif
    endfor
  endfor
  
  timeElapsed = toc;
  disp(timeElapsed);
  
end

# cor = round(correction*10);
im_smooth = im_mag;

figure;
subplot(1, 2, 1);
imshow(im_bicubic, [mini, maxi]);
subplot(1, 2, 2);
imshow(im_smooth, [mini, maxi]);

figure;
subplot(1, 2, 1);
imshow(curvature_k, []);
subplot(1, 2, 2);
imshow(correction, []);

figure;
subplot(1, 2, 1);
imshow(mask, []);
subplot(1, 2, 2);
imshow(ranges, []);

timeElapsed = toc;
disp("Time total:");
disp(timeElapsed);

