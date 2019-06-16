img = imread('peppers.png');
img_gray = double(rgb2gray(img));

img_gray_smooth = gauss_blur(img_gray);
[I_x,I_y] = grad2d(img_gray_smooth);

I_xx = gauss_blur(I_x.^2);
I_yy = gauss_blur(I_y.^2);
I_xy = gauss_blur(I_x.*I_y);

k = 0.06;
R = ((I_xx.*I_yy)-(I_xy.^2))-k.*(I_xx+I_yy).^2;

r = 5;
thresh = 10000;
hc = nmsup(R,r,thresh);

figure()
imshow(img)
hold on;
plot(hc(:,1), hc(:,2), 'rx')
hold off;

function loc = nmsup(R,r,thresh)

  % Step 1-2 must be performed in a way that allows you to
  % preserve location information for each corner.
  [sy,sx] = size(R);
  [x,y] = meshgrid(1:sx,1:sy);
  nrow = sy;
  ncol = sx;

  % Step 1: eliminate values below the specified threshold.
  Rt = zeros(nrow,ncol);
  for row=1:nrow
    for col=1:ncol
      if (R(row,col) >= thresh)
        Rt(row,col) = R(row,col);    % new matrix with only elements above threshold
      end
    end
  end

  % Step 2: Sort the remaining values in decreasing order.
  l = nrow*ncol;    % number of all potential elements
  Rta = Rt;
  Rts = zeros(1,l,3);    % 3D column vector
  for i = 1:l
    [M,I] = max(Rta(:));
    if (M == 0)
      break
    end
    [X,Y] = ind2sub(size(Rta),I);
    Rta(X,Y) = 0;
    Rts(1,i,1) = M;    % sorted values
    Rts(1,i,2) = X;    % sorted x-coordinate
    Rts(1,i,3) = Y;    % sorted y-coordinate
  end

  % Step 3: Starting with the highest scoring corner value, if
  % there are corners within its r neighborhood remove
  % them since their cores are lower than that of the corner currently
  % considered. This is true since the corners are sorted
  % according to their score and in decreasing order.
  for n = 1:l
    for temp = -(r-1)/2:(r-1)/2
        X = Rts(1,n,2);
        Y = Rts(1,n,3);
      tempX = X+temp;
      tempY = Y+temp;
      if (tempX>0 & tempY>0 & tempX<=nrow & tempY<=ncol & X>0 & Y>0)
          if (Rt(tempX,tempY)<Rt(X,Y))
            Rt(tempX,tempY) = 0;
          end
      end
    end
  end


  Rta = Rt;
  Rtf = zeros(1,l,3);    % 3D column vector
  for i = 1:l
    [M,I] = max(Rta(:));
    if (M == 0)
        break
    end
    [X,Y] = ind2sub(size(Rta),I);
    Rta(X,Y) = 0;
    Rtf(1,i,1) = M;    % sorted values
    Rtf(1,i,2) = X;    % sorted x-coordinate
    Rtf(1,i,3) = Y;    % sorted y-coordinate
  end

  % The variable loc should contain the sorted corner locations which
  % survive thresholding and non-maximum suppression with
  % size(loc): nx2
  % loc(:,1): x location
  % loc(:,2): y location
  loc(:,1) = Rtf(1,1:l,2)';
  loc(:,2) = Rtf(1,1:l,3)';
  
end