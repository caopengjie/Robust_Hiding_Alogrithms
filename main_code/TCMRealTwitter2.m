function [recompressed,index]  = TCMRealTwitter2(imgPath,middleName,quality)
index = 0;
    while true
        jpeg_img = jpeg_read(imgPath);
        coef_array = jpeg_img.coef_arrays{1};
        quant_table = jpeg_img.quant_tables{1};
        [recompressed_dct,img_output] = re_compress4(imgPath,quality,'tcmstego.jpg');
        diff_num_v = sum(sum((recompressed_dct~=coef_array)));
        if diff_num_v == 0
            recompressed = imgPath;
            return;
        else
            recompressed = img_output;%将重压缩后的图像当作新生成的图像
            index = index + 1;
            recompressed_img = jpeg_read(recompressed);
            recompressed_dct = recompressed_img.coef_arrays{1};
            [recompressed_twi_dct,recompressed_twi] = re_compress4(recompressed,quality,'tcmstego.jpg');
            dn2 = sum(sum((recompressed_twi_dct~=recompressed_dct)));
            if dn2==0
                return;
            else
                imgPath = recompressed_twi;
                index = index + 1;
            end
        end
        if(index==12)
            fprintf('this is image is bad !!\n');
            break;
        end
    end
end