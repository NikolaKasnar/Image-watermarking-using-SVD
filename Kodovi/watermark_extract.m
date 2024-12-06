% Učitavanje slike s vodenim žigom
image = imread('watermarked_image_grid_4x4_alpha_0.01_rotation_45.jpg');
image = im2double(image);

% Pretvorba dimenzija
image = imresize(image, [4000, 4000]);

% Parametri za blokove
[rows, cols] = size(image);
num_blocks = 4; % Mreža 4x4 blokova
block_rows = rows / num_blocks;
block_cols = cols / num_blocks;

% Dimenzije vodenog žiga u skladu s blokovima
watermark_rows = 100;
watermark_cols = 100;
block_size = block_rows / watermark_rows;

% Odabir samo jednog unutarnjeg bloka (2,3) - 2. red i 3. stupac
row_block = 2; % Drugi redak blokova
col_block = 3; % Treći stupac blokova

% Izolacija tog unutarnjeg bloka (2x3)
r_start = (row_block - 1) * block_rows + 1;
r_end = row_block * block_rows;
c_start = (col_block - 1) * block_cols + 1;
c_end = col_block * block_cols;
block = image(r_start:r_end, c_start:c_end);

% Ekstrakcija vodenog žiga iz tog 2x3 bloka
extracted_watermark = zeros(watermark_rows, watermark_cols); % Predloženi rezultat za žig

for i = 1:block_size:block_rows
    for j = 1:block_size:block_cols
        sub_block = block(i:i+block_size-1, j:j+block_size-1);
        [U, S, V] = svd(sub_block);
        d = abs(S(1, 1)); % Ekstrakcija najveće singularne vrijednosti

        % Izračun pozicije u vodenom žigu
        row_index = ceil(i / block_size);
        col_index = ceil(j / block_size);

        % Kvantizacija za rekonstrukciju
        low = floor(d);
        high = ceil(d);
        mid = (low + high) / 2;

        if abs(d - mid) < abs(d - low)
            extracted_watermark(row_index, col_index) = 0; % Nema žiga
        else
            extracted_watermark(row_index, col_index) = 1; % Žig prisutan
        end
    end
end

% Prikaz i spremanje rekonstruiranog vodenog žiga
figure;
imshow(extracted_watermark, []);
title('Rekonstruirani vodeni žig iz 2x3 bloka');
imwrite(extracted_watermark, 'reconstructed_watermarked_image_grid_4x4_alpha_0.01_rotation_45_4.jpg');

