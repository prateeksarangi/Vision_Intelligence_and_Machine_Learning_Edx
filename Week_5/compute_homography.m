function H = compute_homography(p1,p2)		
    % use SVD to solve for H as was done in the lecture
  p1 = p1';
  p2 = p2';
  n = 4;

  x = p1(1, :); y = p1(2,:); X = p2(1,:); Y = p2(2,:);
  rows0 = zeros(3, n);
  rowsXY = [X; Y; ones(1,n)];
  hx = [rowsXY; rows0; -x.*X; -x.*Y; -x];
  hy = [rows0; rowsXY; -y.*X; -y.*Y; -y];
  h = [hx hy];
  [U, D, V] = svd(h');
  temp = V(:,end)/V(end,end);

  H = reshape(temp,3,3)';
end
