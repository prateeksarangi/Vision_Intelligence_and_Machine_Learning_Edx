% get images
buildingDir = fullfile(toolboxdir('vision'), 'visiondata', 'building');
buildingScene = imageDatastore(buildingDir);
I1 = rgb2gray(readimage(buildingScene, 1));
I2 = rgb2gray(readimage(buildingScene, 2));

% get points
points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);

% get features
[features1, points1] = extractFeatures(I1, points1);
[features2, points2] = extractFeatures(I2, points2);

loc1 = points1.Location;
loc2 = points2.Location;

[match,match_fwd,match_bkwd] = match_features(double(features1.Features),double(features2.Features));

figure()
plot_corr(I1,I2,loc1(match_fwd(:,1),:),loc2(match_fwd(:,2),:));

figure()
plot_corr(I1,I2,loc1(match_bkwd(:,1),:),loc2(match_bkwd(:,2),:));

figure()
plot_corr(I1,I2,loc1(match(:,1),:),loc2(match(:,2),:));

function [match,match_fwd,match_bkwd] = match_features(f1,f2)
  % INPUT
  % f1,f2: [ number of points x number of features ]
  % OUTPUT
  % match, match_fwd, match_bkwd: [ indices in f1, corresponding indices in f2 ]

  % get matches using pdist2 and the ratio test with threshold of 0.7
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
