% Učitavanje slika
orig_file = '../Slike/cvijet.jpg'; % Originalna slika
original = imread(orig_file);
original = rgb2gray(original);
original = im2double(original);
watermark_file = '../Slike/inz.png'; % Vodeni žig
watermark = imread(watermark_file);
watermark = rgb2gray(watermark);
watermark = im2double(watermark);

% Pretvorba dimenzija
original = imresize(original, [4000, 4000]);
watermark = imresize(watermark, [100, 100]);
alpha = 0.1;  % Povećaj alpha za jači vodeni žig

% Osiguravamo da su u vodenom žigu vrijednosti 0 ili 1
threshold = 0.5;
watermark = watermark > threshold;

% Parametri za blokove
[rows, cols] = size(original);
num_blocks = 4; % Mreža 4x4 blokova
block_rows = rows / num_blocks;
block_cols = cols / num_blocks;

% Dimenzije vodenog žiga u skladu s blokovima
[watermark_rows, watermark_cols] = size(watermark);
block_size = block_rows / watermark_rows;

% Umetanje vodenog žiga u svaki blok
watermarked_image = zeros(rows, cols); % Slika s vodenim žigom
for row_block = 1:num_blocks
    for col_block = 1:num_blocks
        r_start = (row_block - 1) * block_rows + 1;
        r_end = row_block * block_rows;
        c_start = (col_block - 1) * block_cols + 1;
        c_end = col_block * block_cols;
        block = original(r_start:r_end, c_start:c_end);

        block_contrast = std2(block); % Prilagodba prema kontrastu
        alpha_local = alpha * block_contrast;

        block_w = zeros(size(block));
        for i = 1:block_size:block_rows
            for j = 1:block_size:block_cols
                sub_block = block(i:i+block_size-1, j:j+block_size-1);
                [U, S, V] = svd(sub_block);
                d = S(1, 1);
                row_index = ceil(i / block_size);
                col_index = ceil(j / block_size);
                w_bit = watermark(row_index, col_index);

                % Povećanje promjena za vodeni žig
                if w_bit == 1
                    d = d + alpha_local;  % Povećanje promjene za jači žig
                else
                    d = d - alpha_local;  % Povećanje promjene za jači žig
                end
                S(1, 1) = d;

                block_w(i:i+block_size-1, j:j+block_size-1) = U * S * V';
            end
        end

        watermarked_image(r_start:r_end, c_start:c_end) = block_w;
    end
end

% Prikaz i spremanje slike s vodenim žigom
figure;
imshow(watermarked_image);
title(['Slika s umetnutim vodenim žigom (mreža 4x4, alpha = ', num2str(alpha), ')']);
imwrite(watermarked_image, ['watermarked_image_grid_4x4_alpha_loose_', num2str(alpha), '.jpg']);

