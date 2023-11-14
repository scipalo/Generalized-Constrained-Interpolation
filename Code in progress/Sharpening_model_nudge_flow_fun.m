# -------------------------------------
# -------- Sharpening model -----------
# ----------- Nudge flow --------------
# -------------------------------------

# Opombe
# Sliki morata biti tipa double
# Sliki morata biti dimenzije n x n x 1 (Črno bela oz. en barvni kanal)

# Todo: addtime, comments, visual as function parameters and add default value
# Todo: add restrictions to arguments

function nudge_flow = Sharpening_model_nudge_flow_fun (im_org, im_mag, magfactorx, magfactory)  
  
  # --- init za testiranje --- 

  tic;
  
  time = 1;
  visual = 0;
  comments = 0;
  
  im_sharp = im_mag;
  im_bicubic = im_mag;
  
  if max(max(im_org)) > 140
    mini = 0;
    maxi = 255;
  else 
    mini = 0;
    maxi = 1;
  endif

  # ----- Nudge flow -----
  
  [immag_hight, immag_width, _] = size(im_mag);
  
  # Izračun odvodov [Se jih splača  dat v funkcijo?]

  [Dx, Dy] = gradient(im_mag);
  [Dxy, Dyy] = gradient(Dy);
  Dxx = gradient(Dx);
  
  # calculate our DValues [sharpening values] za vsak piksel posebej

  nudge_flow = zeros(immag_hight, immag_width);
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
      dxpos = im_mag(j, i + 1) - im_mag(j, i);
      dxneg = im_mag(j, i) - im_mag(j, i - 1);
      dypos = im_mag(j + 1, i) - im_mag(j, i);
      dyneg = im_mag(j, i) - im_mag(j - 1, i);

      # Vedno gledamo razliko do zunanjega piksla glede na roba
      # Razen v primeru, ko smo na prelomu in si ne želimo spremembe
      
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
      gradmag = sqrt( (xval * xval) + (yval * yval));

      # gradmag needs to have oposite sign of the iwwval sign
      if iwwval > 0
        gradmag *= -1;
      elseif iwwval == 0
        gradmag = 0.0;
      end

      # korekcijske vrednosti 
      
      # Op: piksle prekimajo proti vrednostim proč od roba
      nudge_flow(j, i) = gradmag; # min(gradmag, max_slope);
      
      # testna slika
      # im_sharp(j, i) += nudge_flow(j, i);
      
      # Normalizacija slike (Ali je potrebna, ko imamo max_slope? Ne)
      
      #im_sharp(j, i) = min(im_sharp(j, i), maxi);
      #im_sharp(j, i) = max(im_sharp(j, i), mini);

    endfor
  endfor

  if time == 1
    timeElapsed = toc;
    disp("Time nudge flow:");
    disp(timeElapsed);
  end
    
  if visual == 1
    figure;
    subplot(2, 2, 1);
    title("Original")
    imshow(im_org, [mini, maxi]);
    subplot(2, 2, 2);
    imshow(im_bicubic, [mini, maxi]);
    subplot(2, 2, 3);
    imshow(im_sharp, [mini, maxi]);
    subplot(2, 2, 4);
    imshow(nudge_flow, []);
  end 
  
end
