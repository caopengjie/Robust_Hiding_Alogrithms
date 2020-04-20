%%info embed
clc;

%% parameters initial
%load the JPEG_Toolbox
addpath(fullfile('..','JPEG_Toolbox'));
%load the STC_Toolbox
addpath(fullfile('..','STC'));
 
%cover image dir
cover_img_dir = 'D:\test_data\test\cover\S\';
%stego image dir
stego_img_dir = 'D:\test_data\test\stego\S\';
%recompress cover img dir
re_cover_img_dir = 'D:\test_data\test\cover_recompress\S\';
%recompress stego img dir
re_stego_img_dir = 'D:\test_data\test\stego_recompress\S\';
%payload, rand_key, h_hei ght, wet_cost
payload_ = [0.10, 0.20, 0.30];
payload = 0.30;
rand_key = 12345;
h_height = 5;
wet_cost = 1e10;
k = 64;
cwl = 127;
payload_bits_arr = zeros(1,100);
error_total_nums = 0;
error_bits = zeros(1,100);
error_channel_nums = 0;
error_channel_bits = zeros(1,100);
error_nums = zeros(1,100);

% test for error
for num = 279:600
    % recompress the cover img
    cover_img_path = strcat(cover_img_dir, num2str(num), '.jpg');
    
    %store the initial dct_value
    cover_img_jpeg = jpeg_read(cover_img_path);
    dct_value_pre = cover_img_jpeg.coef_arrays{1};
    
    %re_compress the jpeg 
    diff_error = 1;
    times = 1;
    while diff_error == 1
        re_cover_img_path = strcat(re_cover_img_dir, 'times_',num2str(times), '_', num2str(num), '.jpg');
        [ dct_value_post ] = re_compress_once( cover_img_path, re_cover_img_path);
        dct_diff = dct_value_post - dct_value_pre;
        dct_diff_nums = sum(sum(dct_diff~=0));
        if dct_diff_nums == 0
            diff_error = 0;
            final_img_path = cover_img_path;
            break;
        end
        times = times + 1;
        dct_value_pre = dct_value_post;
        delete(cover_img_path);
        cover_img_path = re_cover_img_path;
    end
    
    delete(re_cover_img_path);
    %% get the whole dct_coefs cost {uerd}
    jpeg_img = jpeg_read(final_img_path);
    jpeg_coefs = jpeg_img.coef_arrays{1};
    jpeg_quant = jpeg_img.quant_tables{1};
    [rho_p1, rho_m1] = uerd(jpeg_coefs, jpeg_quant, wet_cost);
    
    %% get the robust dct coefs
    m1_region_c = get_robust_region_m1(final_img_path);
    p1_region_c = get_robust_region_p1(final_img_path);
    [r_coefs, r_index] = get_robust_region_(p1_region_c, m1_region_c, jpeg_coefs);
    
    %% get the robust dct cost
    [rho_r_p1, rho_r_m1] = get_robust_cost(rho_p1, rho_m1, r_index);
    
    %% embeding
    stego_img_path = strcat(stego_img_dir, num2str(num), '_stego.jpg');
    % msg generate
    size_ = size(jpeg_coefs);
    cover_len = size_(1)*size_(2);
    payload_bits = round(payload*((nnz(jpeg_coefs) - nnz(jpeg_coefs(1:8:end,1:8:end)))));
    msg = uint8(round(rand([1,payload_bits])));
    payload_bits_arr(1,num) = payload_bits;
    
    %BCH encoder
%     padd = ceil(length(msg)/k)*k-length(msg);
%     strimm = [msg zeros(1,padd)];
%     enc = comm.BCHEncoder(cwl,k);
%     msg=step(enc,strimm.');
%     length_msg = length(msg);
%     rng(rand_key);
%     perm_msg_index = randperm(length_msg);
%     perm_msg = msg(perm_msg_index);
%     msg_new = perm_msg;
%     msg_old = msg;
%     msg = msg_new;
    
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
    for num_ = 1:length(r_index)
        % find the r and c
        r = int32(fix((r_index(num_)-1)/dct8x8) + 1);
        c = int32(mod(r_index(num_), dct8x8));
        if c == 0
            c = dct8x8;
        end
        for i = 1:8
            for j = 1:8
                jpeg_coefs((r-1)*8+i,(c-1)*8+j) = r_stego_real(i,(num_-1)*8+j);
            end
        end
    end
    jpeg_img.coef_arrays{1} = jpeg_coefs;
    jpeg_write(jpeg_img,stego_img_path);
    
%     %% extract msg from stego
%     stego_img_path = strcat(stego_img_dir, num2str(num), '_stego.jpg');
%     r_stego_img_path = strcat(re_stego_img_dir, num2str(num), '_r_stego.jpg');
%     re_stego_coefs = re_compress_once(stego_img_path, r_stego_img_path);
%     
%     % get the channel error bits
%     stego_img = jpeg_read(stego_img_path);
%     stego_coefs = stego_img.coef_arrays{1};
%     diff_coefs = stego_coefs - re_stego_coefs;
%     d_num = sum(sum(diff_coefs~=0));
%     error_channel_nums = error_channel_nums + d_num;
%     error_channel_bits(1, num) = d_num;
%     
%     % get the robust embedding region
%     re_size_ = size(re_stego_coefs);
%     re_dct8x8 = re_size_(2)/8;
%     re_r_coefs = zeros(8, length(r_index)*8);
%     for num_ = 1:length(r_index)
%         % find the r and c
%         r = int32(fix((r_index(num_)-1)/re_dct8x8) + 1);
%         c = int32(mod(r_index(num_), re_dct8x8));
%         if c == 0
%             c = re_dct8x8;
%         end
%         for i = 1:8
%             for j = 1:8
%                 re_r_coefs(i,(num_-1)*8+j) = re_stego_coefs((r-1)*8+i,(c-1)*8 +j);
%             end
%         end
%     end
%     %% extract the msg
%      rng(rand_key);
%      rand_path = randperm(r_coefs_len);
%      r_coefs_perm_ = int32(re_r_coefs(rand_path));
%      e_msg = stc_ml_extract(r_coefs_perm_, n_msg_bits,h_height);
% %      dec=comm.BCHDecoder(cwl,k);
% %      DecMess_All=step(dec,e_msg').';
% %      diff_msg = uint8(DecMess_All) - strimm;
%      diff_msg = e_msg - msg;
%      error_total_nums = error_total_nums + nnz(diff_msg);
%      error_bits(1,num) = nnz(diff_msg);
end
% error_channel = sum(sum(error_channel_bits~=0));
% error_embed = sum(sum(error_bits~=0));


% %% caculate error bits
% error_total_nums = 0;
% error_bits = zeros(1,100);
%  for num = 1:100
%      stego_img_path = strcat(stego_img_dir, num2str(num), '_stego.jpg');
%      r_stego_img_path = strcat(re_stego_img_dir, num2str(num), '_r_stego.jpg');
%      re_stego_coefs = re_compress_once(stego_img_path, r_stego_img_path);
%      
%      stego_img = jpeg_read(stego_img_path);
%      stego_coefs = stego_img.coef_arrays{1};
%      diff_coefs = stego_coefs - re_stego_coefs;
%      d_num = sum(sum(diff_coefs~=0));
%      error_total_nums = error_total_nums + d_num;
%      error_bits(1, num) = d_num;
%  end
%  
%  error_embed = sum(sum(error_bits~=0));


