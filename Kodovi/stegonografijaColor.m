% Definiramo imena fileova
orig_file = 'pas2.jpg'; % Originalna slika
zig_file = 'macka2.jpg'; % Maska slika

% Ucitamo i procesuiramo prvu sliku (originalnu)
coverImage = imread(orig_file);
% Pretvorimo u tip double za SVD
coverImage = im2double(coverImage);
figure(1), imshow(coverImage), title('Originalna slika');

% Na svakoj od RGB komponenti napravimo SVD
[U_cover_r, S_cover_r, V_cover_r] = svd(coverImage(:,:,1)); % Red channel
[U_cover_g, S_cover_g, V_cover_g] = svd(coverImage(:,:,2)); % Green channel
[U_cover_b, S_cover_b, V_cover_b] = svd(coverImage(:,:,3)); % Blue channel

% Ucitamo i procesuiramo drugu sliku (masku/sliku koja se skriva)
secretImage = imread(zig_file);
secretImage = im2double(secretImage);
[rows, cols, ~] = size(coverImage); % Velièina originalne slike
% U slucaju da treba masku smanjimo/povecamo na na velicinu originala
secretImage = imresize(secretImage, [rows, cols]);

% Na svakoj RGB komponenti maskirane slike napravimo SVD
[U_secret_r, S_secret_r, V_secret_r] = svd(secretImage(:,:,1)); % Red channel
[U_secret_g, S_secret_g, V_secret_g] = svd(secretImage(:,:,2)); % Green channel
[U_secret_b, S_secret_b, V_secret_b] = svd(secretImage(:,:,3)); % Blue channel

% Ovdje mozemo mijenjati alpha za steganometriju
alpha = 0.05;

% Embedding tajne slike u svaku komponentu
S_stega_r = S_cover_r + alpha * S_secret_r; % Red channel
S_stega_g = S_cover_g + alpha * S_secret_g; % Green channel
S_stega_b = S_cover_b + alpha * S_secret_b; % Blue channel

% Rekonstruiramo steganometrijsku sliku
stegaImage_r = U_cover_r * S_stega_r * V_cover_r';
stegaImage_g = U_cover_g * S_stega_g * V_cover_g';
stegaImage_b = U_cover_b * S_stega_b * V_cover_b';

% Spajamo komponente nazad u RGB sliku
stegaImage = cat(3, stegaImage_r, stegaImage_g, stegaImage_b);

% Prikazivanje steganometrijske slike
figure(2), imshow(stegaImage), title('Steganometrijska slika');
imwrite(stegaImage, 'stega_output.png'); 

% Ponovno uèitavamo stego sliku i provodimo SVD na svakom kanalu
stegaImageReloaded = im2double(imread('stega_output.png'));

[U_stega_r, S_stega_r_reloaded, V_stega_r] = svd(stegaImageReloaded(:,:,1)); % Red channel
[U_stega_g, S_stega_g_reloaded, V_stega_g] = svd(stegaImageReloaded(:,:,2)); % Green channel
[U_stega_b, S_stega_b_reloaded, V_stega_b] = svd(stegaImageReloaded(:,:,3)); % Blue channel

% Pomoæu poznate alpha izvucemo tajnu sliku iz svakog kanala
S_extracted_secret_r = (S_stega_r_reloaded - S_cover_r) / alpha; % Red channel
S_extracted_secret_g = (S_stega_g_reloaded - S_cover_g) / alpha; % Green channel
S_extracted_secret_b = (S_stega_b_reloaded - S_cover_b) / alpha; % Blue channel

% Rekonstruiramo tajnu sliku iz svakog kanala
extractedSecretImage_r = U_secret_r * S_extracted_secret_r * V_secret_r';
extractedSecretImage_g = U_secret_g * S_extracted_secret_g * V_secret_g';
extractedSecretImage_b = U_secret_b * S_extracted_secret_b * V_secret_b';

% Spajamo komponente u RGB sliku
extractedSecretImage = cat(3, extractedSecretImage_r, extractedSecretImage_g, extractedSecretImage_b);

% Prikazivanje rekonstruirane tajne slike
figure(3), imshow(extractedSecretImage), title('Tajna slika');

% Rekonstruiramo originalnu sliku iz stego slike
S_reconstructed_original_r = S_stega_r_reloaded - alpha * S_secret_r; % Red channel
S_reconstructed_original_g = S_stega_g_reloaded - alpha * S_secret_g; % Green channel
S_reconstructed_original_b = S_stega_b_reloaded - alpha * S_secret_b; % Blue channel

% Rekonstruiramo originalnu sliku iz svakog kanala
reconstructedOriginal_r = U_stega_r * S_reconstructed_original_r * V_stega_r';
reconstructedOriginal_g = U_stega_g * S_reconstructed_original_g * V_stega_g';
reconstructedOriginal_b = U_stega_b * S_reconstructed_original_b * V_stega_b';

% Spajamo komponente u RGB sliku
reconstructedOriginal = cat(3, reconstructedOriginal_r, reconstructedOriginal_g, reconstructedOriginal_b);

% Prikazivanje rekonstruirane originalne slike
figure(4), imshow(reconstructedOriginal), title('Rekonstruirana originalna slika');
