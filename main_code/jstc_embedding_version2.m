function result_msg = jstc_embedding_version2(fileName,dstName,re_dstName)

%load the JPEG_Toolbox
addpath(fullfile('..','JPEG_Toolbox'));
%load the STC_Toolbox
addpath(fullfile('..','STC'));

payload = 0.15;
randkey = 123456;
rng(randkey);
use_robust =1;
k = 64;
cwl = 127;
h_height = 5;
%[fileName,ind] = TCMRealTwitter2(fileName,[seed,'middle.jpg']);
[rhoP1, rhoM1] = J_UNIWARD(fileName);
jpeg_img = jpeg_read(fileName);
jpeg_y = jpeg_img.coef_arrays{1};
size_ = size(jpeg_y);
cover_len = size_(1) * size_(2);
rng(randkey);
rand_path = randperm(cover_len);
jpeg_y_perm = int32(jpeg_y(rand_path));
rhoP1_perm = rhoP1(rand_path);
rhoM1_perm = rhoM1(rand_path);
rho = zeros(3,cover_len,'single');
rho(1,:) = rhoP1_perm;
rho(3,:) = rhoM1_perm;
payload_bits = round(payload*((nnz(jpeg_y) - nnz(jpeg_y(1:8:end,1:8:end)))));
msg = uint8(round(rand([1,payload_bits])));
% padd= ceil(length(msg)/k)*k-length(msg);
% strimm=[msg zeros(1,padd)];
% enc=comm.BCHEncoder(cwl,k);  
% msg=step(enc,strimm.');
% length_msg = length(msg);
% rng(randkey);
% perm_msg_index = randperm(length_msg);
% perm_msg = msg(perm_msg_index);
% msg_new = perm_msg;
% msg_old = msg;
% msg = msg_new;
% quant_table = jpeg_img.quant_tables{1};
% [imgH,imgW] = size(jpeg_y);
%dctCopy = currentDct;
[d,stego,n_msg_bits,l] = stc_pm1_pls_embed(jpeg_y_perm, rho,msg, h_height);
stego_real = zeros([1,cover_len]);
for i=1:cover_len
    stego_real(rand_path(i)) = stego(i);
end
stego_real = reshape(stego_real,size_);
jpeg_img.coef_arrays{1} = stego_real;
diff = stego_real - jpeg_y;
imshow(abs(diff));
jpeg_write(jpeg_img,dstName);
img_result = re_compress_once(dstName, re_dstName);
diff = stego_real - img_result;
imshow(abs(diff));
num = sum(sum(diff~=0));
rng(randkey);
rand_path = randperm(cover_len);
Y = int32(img_result(rand_path));
MSG = stc_ml_extract(Y, n_msg_bits,h_height);
% diff_data = double(MSG) - double(msg);
% data = zeros([1,length_msg]);
% MSG = MSG';
% for i=1:length_msg
%     data(perm_msg_index(i)) = MSG(i);
% end
% dec=comm.BCHDecoder(cwl,k);
% DecMess_All=step(dec,data').';
%diff_msg = uint8(DecMess_All) - strimm;
diff_msg = MSG - msg;
result_msg = nnz(diff_msg)/length(msg);
end

