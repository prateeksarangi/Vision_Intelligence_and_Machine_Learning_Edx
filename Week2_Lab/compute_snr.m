function snr = compute_snr(I, Id)

    % Input:
    % I: the original image
    % Id: the approximated (noisy) image
    % Output:
    % snr: signal-to-noise ratio
    
    % Please follow the instructions in the comments to fill in the missing commands.    

    % 1) Compute the noise image (original image minus the approximation)
    noise_Img = I - Id;

    % 2) Compute the Frobenius norm of the noise image
    norm_In = norm(noise_Img, 'fro');
    
    % 3) Compute the Frobenius norm of the original image
    norm_I = norm(I, 'fro');
    
    % 4) Compute SNR
    snr = -20*log10(norm_In / norm_I);

end