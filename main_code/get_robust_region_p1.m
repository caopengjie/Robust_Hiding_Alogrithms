%% function fo get robust +1 region

function [ jpeg_dct8x8_c ] = get_robust_region_p1( jpeg_input )
    %load the JPEG_Toobox
    addpath(fullfile('..','JPEG_Toolbox'));
     
    %get the cover dct_coefs
    img_jpeg = jpeg_read(jpeg_input);
    dct_value_1 = img_jpeg.coef_arrays{1};
     
    [row,col] = size(dct_value_1);
    change_nums_arr = zeros(row,col);
    row8x8 = row/8;
    col8x8 = col/8;
    
    %+1 embedding and get dct_coefs
    for i = 1:8
        for j = 1:8
            dct_value_2 = dct_value_1;
            nums = num2str((i-1)*8 + j);
            file_output = strcat(nums, '_test_stego_p1.jpg');
            re_compress_file = strcat(nums, '_re_stego_test_p1.jpg');
            % embeding with add one
            for r = 1:row8x8
                for c = 1:col8x8
                    dct_value_2((r-1)*8+i, (c-1)*8+j) = dct_value_2((r-1)*8+i, (c-1)*8+j) + 1;
                end
            end
        
             %write to stego img
            img_jpeg.coef_arrays{1} = dct_value_2;
            jpeg_write(img_jpeg, file_output);
        
            %recompress stego img and get the changes
            [dct_value_3] = re_compress_once(file_output, re_compress_file);
            dct_diff_arrays = dct_value_2 - dct_value_3;
            %caculate the changes num
            for r = 1:row8x8
                for c = 1:col8x8
                    dct8x8 = dct_diff_arrays((r-1)*8+1:(r-1)*8+8,(c-1)*8+1:(c-1)*8+8);
                    change_nums_arr((r-1)*8+i, (c-1)*8+j) = sum(sum(dct8x8~=0));
                end
            end
           %% delete the temp img
             %delete(file_output);
             %delete(re_compress_file);
        end
    end

    %% find the robust dct chunk
    total_change_num = sum(sum(change_nums_arr~=0));

    dct8x8_changes = zeros(row8x8, col8x8);
    for  r = 1:row8x8
        for c = 1:col8x8
            dct8x8 = change_nums_arr((r-1)*8+1:(r-1)*8+8,(c-1)*8+1:(c-1)*8+8);
            dct8x8_changes(r,c) = sum(sum(dct8x8~=0)); 
        end
    end
    
    jpeg_dct8x8_c = dct8x8_changes;
end

