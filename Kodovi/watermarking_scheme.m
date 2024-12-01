% Učitavanje slika
orig_file = 'cvijet.jpg'; % Originalna slika
original = imread(orig_file);
original = rgb2gray(original);
watermark_file = 'inz.png'; % Vodeni žig
watermark = imread(watermark_file);
watermark = rgb2gray(watermark);
watermark = im2double(watermark);

% Pretvorba dimenzija
original = imresize(original, [2000, 2000]);
watermark = imresize(watermark, [100, 100]);

block_size = 10; % Dimenzija M x M blokova
alpha = 0.01;

% Osiguravamo da su u vodenom žigu vrijednosti 0 ili 1
threshold = 0.5;
watermark = watermark > threshold;

% Podjela originalne slike u 4 bloka
[rows, cols] = size(original);
tl = original(1:(rows / 2), 1:(cols / 2));
tr = original(1:(rows / 2), (cols / 2)+1:end);
bl = original((rows / 2)+1:end, 1:(cols / 2));
br = original((rows / 2)+1:end, (cols / 2)+1:end);

% Umetanje vodenog žiga u gornji lijevi blok
[tl_rows, tl_cols] = size(tl);
[watermark_rows, watermark_cols] = size(watermark);
block_size_tl = tl_rows / watermark_rows;
tl_w = zeros(tl_rows, tl_cols);
modified_d = zeros(watermark_rows, watermark_cols);

for i = 1:block_size_tl:tl_rows
    for j = 1:block_size_tl:tl_cols
        sub_block = tl(i:i+block_size_tl-1, j:j+block_size_tl-1);
        [U, S, V] = svd(sub_block);
        d = S(1, 1);
        row_index = ceil(i / block_size_tl);
        col_index = ceil(j / block_size_tl);
        w_bit = watermark(row_index, col_index);

        % Dither kvantizacija
        low = floor(d);
        high = ceil(d);
        mid = (low + high) / 2;
        if w_bit == 1
            d = (low + mid) / 2;
        else
            d = (mid + high) / 2;
        end

        S(1, 1) = d;
        modified_d(row_index, col_index) = d;
        tl_w(i:i+block_size_tl-1, j:j+block_size_tl-1) = U * S * V';
    end
end

% Umetanje vodenog žiga u donji desni blok
[br_rows, br_cols] = size(br);
block_size_br = br_rows / watermark_rows;
br_w = zeros(br_rows, br_cols);

for i = 1:block_size_br:br_rows
    for j = 1:block_size_br:br_cols
        sub_block = br(i:i+block_size_br-1, j:j+block_size_br-1);
        [U, S, V] = svd(sub_block);
        u11 = U(1, 1);
        u21 = U(2, 1);
        row_index = ceil(i / block_size_br);
        col_index = ceil(j / block_size_br);
        w_bit = watermark(row_index, col_index);

        % Modifikacija vrijednosti u11 i u21
        diff = abs(u11) - abs(u21);
        if (w_bit == 1 && diff > alpha) || (w_bit == 0 && diff < alpha)
            u21 = u21 - (alpha - diff) / 2;
            u11 = u11 + (alpha - diff) / 2;
        else
            u21 = u21 - (alpha + diff) / 2;
            u11 = u11 + (alpha + diff) / 2;
        end

        U(1, 1) = u11;
        U(2, 1) = u21;
        br_w(i:i+block_size_br-1, j:j+block_size_br-1) = U * S * V';
    end
end

% Rekonstrukcija slike s vodenim žigom
watermarked_image = [tl_w, tr; bl, br_w];
imshow(watermarked_image);
title(['Slika s umetnutim vodenim žigom (alpha = ', num2str(alpha), ')']);
imwrite(watermarked_image, ['watermarked_image_alpha_', num2str(alpha), '.jpg']);

% Ekstrakcija vodenog žiga
extracted_watermark_d = zeros(size(modified_d));

for i = 1:watermark_rows
    for j = 1:watermark_cols
        d = modified_d(i, j);
        low = floor(d);
        high = ceil(d);
        mid = (low + high) / 2;
        if d >= 0
            if abs(d - low) < abs(d - high)
                extracted_watermark_d(i, j) = 1;
            else
                extracted_watermark_d(i, j) = 0;
            end
        else
            if abs(d - high) < abs(d - low)
                extracted_watermark_d(i, j) = 1;
            else
                extracted_watermark_d(i, j) = 0;
            end
        end
    end
end

figure;
imshow(extracted_watermark_d, []);
title(['Rekonstruirani vodeni žig (alpha = ', num2str(alpha), ')']);
imwrite(extracted_watermark_d, ['reconstructed_watermark_alpha_', num2str(alpha), '.jpg']);

