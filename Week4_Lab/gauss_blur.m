function smooth = gauss_blur(img)
  x =  -2:2;
  sigma = 1;
  gauss_filter = 1/(sqrt(2*pi)*sigma)*exp(-x.^2/(2*sigma));

  smooth_x = conv2(img,gauss_filter,'same');
  smooth = conv2(smooth_x,gauss_filter','same');
end