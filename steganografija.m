% Definiramo imena fileova
orig_file = 'macka.jpg'; % Originalna slika
zig_file = 'pas.jpg'; % Maska slika

% Ucitamo i procesuiramo prvu sliku
coverImage = imread(orig_file);
% Pretvorimo ju u crno-bijelu sliku radi izgleda(makar ova vec je
coverImage = rgb2gray(coverImage);
% Pretvorimo u tip double radi SVDa
coverImage = im2double(coverImage);
figure(1), imshow(coverImage), title('Originalna slika');

% Na njoj napravimo SVD
[U_cover, S_cover, V_cover] = svd(coverImage);

% Napravimo isto procesiranje za drugu sliku
secretImage = imread(zig_file);
secretImage = rgb2gray(secretImage);
secretImage = im2double(secretImage);
[rows, cols] = size(coverImage);

% U slucaju da treba masku smanjimo/povecamo na na velicinu originala
secretImage = imresize(secretImage, [rows, cols]);

% Napravimo SVD na tajnoj slici
[U_secret, S_secret, V_secret] = svd(secretImage);

% Ovdje mozemo mijenjati alpha za steganometriju
alpha = 0.5;
S_stega = S_cover + alpha * S_secret;

% Napravimo steganometrijsku sliku
stegaImage = U_cover * S_stega * V_cover';

% Spremanje slike
figure(2), imshow(stegaImage), title('Steganoetrijska slika');
imwrite(stegaImage, 'stega_output.png'); 

% Ponovno ušitamo stega sliku i napravimo svd na njoj
stegaImageReloaded = im2double(imread('stega_output.png'));
[U_stega, S_stega_reloaded, V_stega] = svd(stegaImageReloaded);

% Pomoću poznate alphe izvucemo tajnu sliku
S_extracted_secret = (S_stega_reloaded - S_cover) / alpha;

% Rekonstruiramo staru sliku
extractedSecretImage = U_secret * S_extracted_secret * V_secret';

figure(3), imshow(extractedSecretImage), title('Tajna slika');

% Rekonstruiramo originalnu sliku iz stega slike
S_reconstructed_original = S_stega_reloaded - alpha * S_secret; 
reconstructedOriginal = U_stega * S_reconstructed_original * V_stega';

figure(4), imshow(reconstructedOriginal), title('Rekonstruirana originalna slika');
