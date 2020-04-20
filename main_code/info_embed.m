%%info embed
clc;

%% parameters initial
%load the JPEG_Toolbox
addpath(fullfile('..','JPEG_Toolbox'));
%load the STC_Toolbox
addpath(fullfile('..','STC'));

%cover image
cover_img = 'times_8_53.jpg';
%stego image
stego_img = 'stego_times_8_53.jpg';
%recompress image
re_stego_img = 're_stego_times_8_53.jpg';
%payload, rand_key, h_height, wet_cost
payload = 0.20;
rand_key = 12345;
h_height = 5;
wet_cost = 1e10;

%% get the whole dct_coefs cost {uerd}
jpeg_img = jpeg_read(cover_img);
jpeg_coefs = jpeg_img.coef_arrays{1};
jpeg_quant = jpeg_img.quant_tables{1};
[rho_p1, rho_m1] = uerd(jpeg_coefs, jpeg_quant, wet_cost);

%% get the robust dct coefs
m1_region_c = get_robust_region_m1(cover_img);
p1_region_c = get_robust_region_p1(cover_img);
[r_coefs, r_index] = get_robust_region_(p1_region_c, m1_region_c, jpeg_coefs);

%% get the robust dct cost
[rho_r_p1, rho_r_m1] = get_robust_cost(rho_p1, rho_m1, r_index);

%% embeding
% msg generate
size_ = size(jpeg_coefs);
cover_len = size_(1)*size_(2);
payload_bits = round(payload*((nnz(jpeg_coefs) - nnz(jpeg_coefs(1:8:end,1:8:end)))));
msg = uint8(round(rand([1,payload_bits])));
%BCH encoder
% dct coefs randperm
r_size_ = size(r_coefs);
r_coefs_len = r_size_(1)*r_size_(2);
rng(rand_key);
rand_path = randperm(r_coefs_len);
r_coefs_perm = int32(r_coefs(rand_path));
% rho randperm
rho_r_pl_perm = rho_r_p1(rand_path);
rho_r_m1_perm = rho_r_m1(rand_path);
rho_r = zeros(3, r_coefs_len, 'single');
rho_r(1,:) = rho_r_pl_perm;
rho_r(3,:) = rho_r_m1_perm;
% stc embed
[d, stego, n_msg_bits, L] = stc_pm1_pls_embed(r_coefs_perm, rho_r, msg, h_height);
 
% write to img
r_stego_real = zeros([1, r_coefs_len]);
for i = 1:r_coefs_len
    r_stego_real(rand_path(i)) = stego(i);
end
r_stego_real = reshape(r_stego_real, r_size_);
dct8x8 = size_(2)/8;
for num = 1:length(r_index)
    % find the r and c
    r = int32(fix((r_index(num)-1)/dct8x8) + 1);
    c = int32(mod(r_index(num), dct8x8));
    if c == 0
        c = dct8x8;
    end
    for i = 1:8
        for j = 1:8
            jpeg_coefs((r-1)*8+i,(c-1)*8+j) = r_stego_real(i,(num-1)*8+j);
        end
    end
end
jpeg_img.coef_arrays{1} = jpeg_coefs;
jpeg_write(jpeg_img,stego_img);

%% Test extract info
% recompress the img
re_jpeg_coefs = re_compress_once(stego_img, re_stego_img);
% diff coefs
diff_coefs = jpeg_coefs - re_jpeg_coefs;
imshow(abs(diff_coefs));
diff_num = sum(sum(diff_coefs~=0));
% get the robust embedding region
re_size_ = size(re_jpeg_coefs);
re_dct8x8 = re_size_(2)/8;
re_r_coefs = zeros(8, length(r_index)*8);
for num = 1:length(r_index)
    % find the r and c
    r = int32(fix((r_index(num)-1)/re_dct8x8) + 1);
    c = int32(mod(r_index(num), re_dct8x8));
    if c == 0
        c = re_dct8x8;
    end
    for i = 1:8
        for j = 1:8
             re_r_coefs(i,(num-1)*8+j) = re_jpeg_coefs((r-1)*8+i,(c-1)*8 +j);
        end
    end
end

rng(rand_key);
rand_path = randperm(r_coefs_len);
r_coefs_perm_ = int32(re_r_coefs(rand_path));
e_msg = stc_ml_extract(r_coefs_perm_, n_msg_bits,h_height);
diff_data = double(e_msg) - double(msg);
num = sum(diff_data~=0);
v = 1;


