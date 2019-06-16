function [I_x,I_y] = grad2d(img)
	% compute image gradients in the x direction
	% convolve the image with the derivative filter from the lecture
	% using the conv2 function and the 'same' option
	dx_filter = [1/2 0 -1/2];
	I_x = conv2(img,dx_filter,'same');

	% compute image gradients in the y direction
	% convolve the image with the derivative filter from the lecture
	% using the conv2 function and the 'same' option
	dy_filter = dx_filter';
	I_y = conv2(img,dy_filter,'same');
end