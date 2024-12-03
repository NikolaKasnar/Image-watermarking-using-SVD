image = imread('zgrade.jpg');
image = im2double(image);

% Pretvorba dimenzija
image = imresize(image, [2000, 2000]);

block_size = 10; % Dimenzija M x M blokova

% Podjela slike u 4 bloka
[rows, cols] = size(image);
tl = image(1:(rows / 2), 1:(cols / 2));
tr = image(1:(rows / 2), (cols / 2)+1:end);
bl = image((rows / 2)+1:end, 1:(cols / 2));
br = image((rows / 2)+1:end, (cols / 2)+1:end);

% Ekstrakcija vodenog žiga v2
extracted_watermark_d2 = zeros([100, 100]);
[tl_rows, tl_cols] = size(tl);
watermark_rows = 100;
watermark_cols = 100;
block_size_tl = tl_rows / watermark_rows;

for i = 1:block_size_tl:tl_rows
    for j = 1:block_size_tl:tl_cols
        sub_block = tl(i:i+block_size_tl-1, j:j+block_size_tl-1);
        [U, S, V] = svd(sub_block);
        d = abs(S(1, 1));
        row_index = ceil(i / block_size_tl);
        col_index = ceil(j / block_size_tl);

        low = floor(d);
        high = ceil(d);
        mid = (low + high) / 2;

        if abs(d - mid) < abs(d - low)
            extracted_watermark_d2(row_index, col_index) = 0;
        else
            extracted_watermark_d2(row_index, col_index) = 1;
        end
    end
end

figure;
imshow(extracted_watermark_d2, []);
title(['Rekonstruirani vodeni žig v2 (alpha = ', num2str(alpha), ')']);
imwrite(extracted_watermark_d2, ['reconstructed_watermark_v2_alpha_', num2str(alpha), '.jpg']);
