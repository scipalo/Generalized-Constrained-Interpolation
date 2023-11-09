# Inicialisation

im_a = [0.1 0.2 0.3 0.4 0.5
0.1 0.2 0.3 0.4 0.5
0.1 0.2 0.3 0.4 0.5
0.1 0.2 0.3 0.4 0.5
0.1 0.2 0.3 0.4 0.5];

im_b1 = [0.1 0.1 0.1 0.9 0.9 0.9
0.1 0.1 0.1 0.9 0.9 0.9
0.1 0.1 0.1 0.9 0.9 0.9
0.1 0.1 0.1 0.9 0.9 0.9
0.1 0.1 0.1 0.9 0.9 0.9
0.1 0.1 0.1 0.9 0.9 0.9];

im_b2 = [0 0 0 255 255 255
0 0 0 255 255 255
0 0 0 255 255 255
0 0 0 255 255 255
0 0 0 255 255 255
0 0 0 255 255 255];

im_b4 = ([50 50 50 150 150 150
50 50 50 150 150 150
50 50 50 150 150 150
50 50 50 150 150 150
50 50 50 150 150 150
50 50 50 150 150 150] );

im_b45 = ([50 50 60 140 150 150
50 50 60 140 150 150
50 50 60 140 150 150
50 50 60 140 150 150
50 50 60 140 150 150
50 50 60 140 150 150] );

im_c = [0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9
0.1 0.1 0.3 0.7 0.9 0.9];

im_d = [0.1 0.4 0.5 0.5 0.6 0.9
0.1 0.4 0.5 0.5 0.6 0.9
0.1 0.4 0.5 0.5 0.6 0.9
0.1 0.4 0.5 0.5 0.6 0.9
0.1 0.4 0.5 0.5 0.6 0.9
0.1 0.4 0.5 0.5 0.6 0.9]*100;

im_1 = imread('slike/Rachel.png');
#im_1 = im_1(1:300, 1:249);
im_1 = im_1(248:252, 250:254);

edge_case = ones(10,10)* 40;
edge_case(4:6, 4:6) = edge_case(4:6, 4:6)* 5;

im_x = [150 150 50 50 60 60 50
150 150 50 50 60 60 50
150 150 50 50 60 60 50
150 150 50 50 60 60 50
150 150 50 50 60 60 50
150 150 50 50 60 60 50];

diagonala = [250 200 0 0 0 25
0 0 0 0 25 255
0 0 0 25 255 255
0 0 25 255 255 255
0 25 255 255 255 255
25 255 255 255 255 255];

test = [0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
200 200 200 200 200 200 200 200
200 200 200 200 200 200 200 200
0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 
20 20 20 20 20 20 20 20
20 20 20 20 20 20 20 20];
test = test.';

im_b3 = [0 0 0 10 10 10
0 0 0 10 10 10
0 0 0 10 10 10
0 0 0 10 10 10
0 0 0 10 10 10
0 0 0 10 10 10];

im_org = im_b3;

# -------------------------------------
# -------- Sharpening model -----------
# -------------------------------------

# --------- Initialization ------------

alpha = 7;
magfactorx = 2;
magfactory = 2;
magfactor = max(magfactorx, magfactory);

im_org = double(im_org);
[im_hight, im_width, _] = size(im_org);

magimageheight = floor(im_hight*magfactory);
magimagewidth = floor(im_width*magfactorx);
im_mag = imresize(im_org, [magimageheight, magimagewidth], "bilinear");
im_bicubic = im_mag;

[immag_hight, immag_width, _] = size(im_mag);

# Colors to gray [todo: color chanels]

im_mag = double(im_mag);
if ndims(im_mag) == 3
  im_mag = rgb2gray(im_mag);
  disp('Job done: piksel to gray');
end

# Testing parameters

tic;
time = 1;
visual= 0;
comments = 0;

if max(max(im_org)) > 140
  mini = 0;
  maxi = 255;
else 
  mini = 0;
  maxi = 1;
endif

# -------------------------------------
# ----------- Nudge flow --------------
# -------------------------------------

nudge_flow = Sharpening_model_nudge_flow_fun(im_org, im_mag, magfactorx, magfactory);

# -------------------------------------
# ---------- Maksimum slope -----------
# -------------------------------------

[Dx, Dy] =  gradient(im_org);
[Dxy, Dyy] =  gradient(Dy);
Dxx =  gradient(Dx);

# Izračun ukrivljenosti (moči roba) na LR sliki

curvature = zeros(im_hight, im_width);
for i = 1 : im_width
  for j = 1 : im_hight
    
      curvature(j, i) = Dx(j,i) * Dx(j,i) * Dxx(j,i) + ...
                        Dx(j,i) * Dy(j,i) * Dxy(j,i) + ...
                        Dy(j,i) * Dy(j,i) * Dyy(j,i);
      
  endfor
endfor

# Normalizacija ukrivljenosti ?

# curv_max = max(max(abs(curvature)));
# if curv_max > 1
#   curvature = curvature/curv_max;
# endif

# Izračun gradienta (using the sobel kernel) za vsak HR piksel
# Ali lahko zamenjam u običnimi odvodi? Čas vs. kvaliteta

gradient_direction = zeros(immag_hight, immag_width);
sobel_x = [-1 0 1; -2 0 2; -1 0 1]; # originalno, bi morala množiti z (-1)
sobel_y = [-1 -2 -1; 0 0 0; 1 2 1];

for i = 2 : immag_width - 1
  for j = 2 : immag_hight - 1
    
    dx_conv = im_mag(j - 1 : j + 1, i - 1 : i + 1).*sobel_x;
    dy_conv = im_mag(j - 1 : j + 1, i - 1 : i + 1).*sobel_y;
    dx = sum(sum(dx_conv));
    dy = sum(sum(dy_conv));
    
    # gradient orientation (radians to degrees)
    
    if dx == 0
      grad_angle = 90;
    else
      grad_angle = atan(dy/dx) * 57.29578;
      if grad_angle < 0
        grad_angle += 360;
        if grad_angle > 180
          grad_angle -= 180;
        endif
      endif
    endif
    
    gradient_direction(j, i) = grad_angle;
   
   endfor
endfor

# --- comment ---

if comments == 1
  disp("maximum slope");
endif  

# -----------------------------------------
# --- MAKSIMUM SLOPE (za vsak hr pixel) ---
# -----------------------------------------

I_diff = zeros(immag_hight, immag_width);
C_diff = zeros(immag_hight, immag_width);
I_x1 = zeros(immag_hight, immag_width);
I_x2 = zeros(immag_hight, immag_width);
max_slope = zeros(immag_hight, immag_width);

for i = 1 : immag_width
  for j = 1 : immag_hight

    grad = gradient_direction(j, i);

    # Closest four lr pixels (to the left, right, top or bottom)

    x_move = 1;
    y_move = 1;
    lrp_x_center = (i - 0.5)/magfactorx;
    lrp_y_center = (j - 0.5)/magfactory;
    x = ceil(lrp_x_center);
    y = ceil(lrp_y_center);
    
    # coordinates of 4 closest LR pixles
    # defining which four are closest
    
    if round(lrp_x_center) < lrp_x_center
      x_move = -1;
    endif
    if round(lrp_y_center) < lrp_y_center
      y_move = -1;
    endif

    # Bounds check and adaption
    
    if (x + x_move < 1 || x + x_move > im_width)
      x_move = -1 * x_move;
    endif
    if (y + y_move < 1 || y + y_move > im_hight)
      y_move = -1 * y_move;
    endif
        
    # Primerjaj kote in najdi najbližja LR piksla
    
    angles = [0, 45, 90, 135, 180];
    
    ca_diff = abs(angles - grad);
    [_, ca_index] = min(ca_diff);
    closest_angle = angles(ca_index);

    move_sign = x_move * y_move;
    if (closest_angle == 0 || closest_angle == 180)
      cp1 = [x,y];
      cp2 = [x + x_move, y];
    elseif closest_angle == 90
      cp1 = [x,y];
      cp2 = [x, y + y_move];
    elseif closest_angle == 45
      if move_sign > 0
        cp1 = [x + x_move,y];
        cp2 = [x, y + y_move];
      else
        cp1 = [x,y];
        cp2 = [x + x_move, y + y_move];
      end
    elseif closest_angle == 135
      if move_sign < 0
        cp1 = [x + x_move,y];
        cp2 = [x, y + y_move];
      else
        cp1 = [x,y];
        cp2 = [x + x_move, y + y_move];
      end
    else
    disp("Warning: Napaka v računanju kotov.");
    end

    # Koordinate najbližjih dveh pikslov

    lr_pix1_x = cp1(1);
    lr_pix1_y = cp1(2);
    lr_pix2_x = cp2(1);
    lr_pix2_y = cp2(2);

    # Low rewolution pixel values

    lr_pix1 = im_org(lr_pix1_y, lr_pix1_x);
    lr_pix2 = im_org(lr_pix2_y, lr_pix2_x);

    # curvatures at LR pixles

    curv_pix2 = curvature(lr_pix1_y, lr_pix1_x);
    curv_pix1 = curvature(lr_pix2_y, lr_pix2_x);
    
    # Maximal slope calculation
    
    # (a) Primera sta pravilno rešena s pomočjo ukrivljenosti.
    # (b) Problem za ulomkom
    # (c) Problem z ulomkom
    # (d) Ni še testiran
    
    # TODO: m2_fraction se mora gibati med 0 in 1. 
    # Op: Nič pomeni kolinearnost točk, 1 pa step edge.
    
    # Originalna verzija
    
    if abs(lr_pix2 - lr_pix1) > 0   
      m1 = abs(lr_pix2 - lr_pix1)/magfactor
      c_diff = abs(curv_pix2 - curv_pix1)
      i_diff = abs(lr_pix2 - lr_pix1)
      m2_fraction = (c_diff/(2*i_diff)) # ^ alpha
      m2 = 1 + (magfactor - 1) * m2_fraction
      max_slope(j, i) = m1*m2;     
    else
      max_slope(j, i) = 0;
    endif
    
    I_diff(j, i) = abs(lr_pix2 - lr_pix1);
    C_diff(j, i) = abs(curv_pix2 - curv_pix1);
    I_x1(j, i) = lr_pix1_x;
    I_x2(j, i) = lr_pix2_x;
    
    %{ 
    
    # Alternativna verzija
    
    m1 = abs(lr_pix2 - lr_pix1)/magfactor; 
    
    m2_criterium = min(abs(curv_pix1), abs(curv_pix2));
    m2 = 1 + (magfactor - 1) * m2_criterium;
    max_slope(j, i) = m1*m2;     
    
    curv_diff = abs(curv_pix2 - curv_pix1)/10000000; # normalizacija
    value_diff = abs(lr_pix2 - lr_pix1)/255;
    ratio_cv = curv_diff/value_diff;
    if value_diff != 0
      fprintf('%2.2f %2.2f, ratio: %2.2f \n~', curv_diff, value_diff, ratio_cv);      
    endif

    %}
 
  endfor
endfor

im_sharp = im_mag + nudge_flow;

# TODO: Pravilno združenje z nudge flow

# Parametri in vizualizacija za testiranje: 

if visual == 1
  
  im_sharp = im_mag + nudge_flow;

  figure;
  subplot(1, 3, 1);
  imshow(im_org, [mini, maxi]);
  subplot(1, 3, 2);
  imshow(im_bicubic, [mini, maxi]);
  subplot(1, 3, 3);
  imshow(im_sharp, [mini, maxi]);

  s_min = min(min(max_slope));
  s_max = max(max(max_slope));
  c_min = min(min(curvature));
  c_max = max(max(curvature));

  figure;
  subplot(2, 2, 1);
  imshow(curvature, [-1, 1]);
  subplot(2, 2, 2);
  imshow(curvature, [c_min, c_max]);
  subplot(2, 2, 3);
  imshow(max_slope, [0, 255]);
  subplot(2, 2, 4);
  imshow(max_slope, [s_min, s_max]);
end

if time == 1
  timeElapsed = toc;
  disp("Time:");
  disp(timeElapsed);
end
  
# ----------------------------------
# --- IMAGE BASED ON MAX SLOPE -----
# ----------------------------------





