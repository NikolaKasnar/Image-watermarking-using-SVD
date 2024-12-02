% Uƒçitavanje slike s umetnutim ûigom
watermarked_image = imread('../Slike/watermarked_image_alpha_0.01_zgrade.jpg'); % Vodena slika
watermark_file = '../Slike/inz.png'; % Originalni vodeni ûig
watermark = imread(watermark_file);
watermark = rgb2gray(watermark);
watermark = im2double(watermark);

% Pretvorba dimenzija
watermarked_image = imresize(watermarked_image, [2000, 2000]);
watermark = imresize(watermark, [100, 100]);

% Dimenzije blokova
block_size_tl = size(watermarked_image, 1) / size(watermark, 1); 
[tl_rows, tl_cols] = size(watermarked_image); % Dimenzije gornjeg lijevog bloka

% Ekstrakcija vodenog ûiga
extracted_watermark_d = zeros(size(watermark));

for i = 1:block_size_tl:tl_rows
    for j = 1:block_size_tl:tl_cols
        sub_block = watermarked_image(i:i+block_size_tl-1, j:j+block_size_tl-1);
        [U, S, V] = svd(double(sub_block));
        d = abs(S(1, 1));
        row_index = ceil(i / block_size_tl);
        col_index = ceil(j / block_size_tl);

        low = floor(d);
        high = ceil(d);
        mid = (low + high) / 2;

        if abs(d - mid) < abs(d - low)
            extracted_watermark_d(row_index, col_index) = 0; % Blizu "mid"
        else
            extracted_watermark_d(row_index, col_index) = 1; % Dalje od "mid"
        end
    end
end

% Prikaz i spremanje rekonstruiranog vodenog ûiga
figure;
imshow(extracted_watermark_d, []);
title(['Rekonstruirani vodeni ûig (alpha = ', num2str(alpha), ')']);
imwrite(mat2gray(extracted_watermark_d), ['reconstructed_watermark_alpha_', num2str(alpha), '.jpg']);
