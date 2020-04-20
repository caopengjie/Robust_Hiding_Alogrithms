%% test function
clc;

%load the JPEG_Toobox
addpath(fullfile('..','JPEG_Toolbox'));

%payload, rand_key, h_height, wet_cost
cover_path = 'test_lena.jpg';
stego_path = 'stego_lena_test.jpg';
re_stego_path = 'r_stego_lena_test.jpg';
payload = 0.20;
rand_key = 12345;

result_msg = jstc_embedding_version2(cover_path,stego_path, re_stego_path);
%% diff coefs
% stego_img = jpeg_read(stego_path);
% stego_coefs = stego_img.coef_arrays{1};
% diff_coefs = stego_coefs - re_stego_coefs;
% % diff_a = zeros(row, col);
% % for r = 1:row
% %     for c = 1:col
% %         if diff_coefs(r,c) == 0
% %             diff_a(r,c) = 0;
% %         else
% %             diff_a(r,c) = 255;
% %         end
% %     end
% % end
% 
% diff_num = sum(sum(diff_coefs~=0));
% imshow(diff_coefs);
