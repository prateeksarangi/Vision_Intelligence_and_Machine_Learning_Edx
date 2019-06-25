buildingDir = fullfile(toolboxdir('vision'), 'visiondata', 'building');
buildingScene = imageDatastore(buildingDir);

I1 = readimage(buildingScene, 1);
I2 = readimage(buildingScene, 2);

I1_gray = rgb2gray(I1);
I2_gray = rgb2gray(I2);

% get points
points1 = detectHarrisFeatures(I1_gray);
points2 = detectHarrisFeatures(I2_gray);

% get features
[features1, points1] = extractFeatures(I1_gray, points1);
[features2, points2] = extractFeatures(I2_gray, points2);

loc1 = points1.Location;
loc2 = points2.Location;

[match,match_fwd,match_bkwd] = match_features(double(features1.Features),double(features2.Features));

H = ransac_homography(loc1(match(:,1),:),loc2(match(:,2),:));

I = stitch(I1,I2,H);

figure()
imshow(I)

function best_H = ransac_homography(p1,p2)
    thresh = sqrt(2); % threshold for inlier points
    p = 1-1e-4; % probability of RANSAC success
    w = 0.5; % fraction inliers
  % n: number of correspondences required to build the model (homography)
  n = 4;
  % number of iterations required
  % from the lecture given the probability of RANSAC success, and fraction of inliers
  k = 40;

  num_pts = size(p1,1);
  best_inliers = 4;
  best_H = eye(3);

  [np1,~] = size(p1);
  [np2,~] = size(p2);
  for iter = 1:k
    % randomly select n correspondences from p1 and p2
    % use these points to compute the homography
    temp = randperm(np1);
    p1_sample = p1(temp(1:n),:);
    p2_sample = p2(temp(1:n),:);
    H = compute_homography(p1_sample,p2_sample);

    % transform p2 to homogeneous coordinates
    p2_h = cart2hom(p2);
    % estimate the location of correspondences given the homography
    p1_hat = H*p2_h;
    % convert to image coordinates by dividing x and y by the third coordinate
    temp = p1_hat(3,:);
    p1_hat = p1_hat./temp;
    % compute the distance between the estimated correspondence location and the
    % putative correspondence location
    dist = pdist2(p1_hat(1:2,:)', p1, 'euclidean');
    % inlying points have a distance less than the threshold thresh defined
    % previously
    num_inliers =  sum(sum(dist < thresh));
    
    if num_inliers > best_inliers
      best_inliers = num_inliers;
      best_H = H;
    end
  end
end

function hom = cart2hom (cart)
  % argument cart = 2D or 3D points in cartesian coordinates
  assert(size(cart', 1) == 2 || size(cart', 1) == 3);
  hom = [cart'; ones(1, size(cart', 2))];
end

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


function [match,match_fwd,match_bkwd] = match_features(f1,f2)
 t = 0.7;

  % fwd matching
  D = pdist2(f1, f2, 'euclidean');
  [B,I] = sort(D,2);
  nearest_neighbor = B(:,1);
  second_nearest_neighbor = B(:,2);
  confidences = nearest_neighbor ./ second_nearest_neighbor;
  i = find(confidences < t);
  s = size(i);
  match_fwd = zeros(s(1),2);
  match_fwd(:,1) = i;
  match_fwd(:,2) = I(i);
  
  % bkwd matching
  D = pdist2(f2, f1, 'euclidean');
  [B,I] = sort(D,2);
  nearest_neighbor = B(:,1);
  second_nearest_neighbor = B(:,2);
  confidences = nearest_neighbor ./ second_nearest_neighbor;
  i = find(confidences < t);
  s = size(i);
  match_bkwd = zeros(s(1),2);
  match_bkwd(:,2) = i;
  match_bkwd(:,1) = I(i);

  % fwd bkwd consistency check
  [C,D] = sortrows([match_fwd;match_bkwd]);
  E = all(C(1:end-1,:)==C(2:end,:),2);
  F = D(E);
  match = match_fwd(F,:);
end
