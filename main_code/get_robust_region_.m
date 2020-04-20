function [ dct8x8_r_chunk, r_index ] = get_robust_region_( p1_robust_region, m1_robust_region, dct_coefs )
    size_ = size(p1_robust_region);
    A = zeros(size_(1), size_(2));
    p1_r_chunk_nums = size_(1)*size_(2) - sum(sum(p1_robust_region~=0));
    m1_r_chunk_nums = size_(1)*size_(2) - sum(sum(m1_robust_region~=0));
    
    p1_index = zeros(1,p1_r_chunk_nums);
    m1_index = zeros(1,m1_r_chunk_nums);
    
    %% get the index from robust chunk
    p1_n = 1; m1_n = 1;
    for r = 1:size_(1)
        for c = 1:size_(2)
            % p1_robust_region 
            if p1_robust_region(r,c) == 0
                p1_index(1,p1_n) = (r-1)*size_(2) + c;
                p1_n = p1_n + 1;
            end
            % m1_robust_region
            if m1_robust_region(r,c) == 0
                m1_index(1,m1_n) = (r-1)*size_(2) + c;
                m1_n = m1_n + 1;
            end
        end
    end
    
    %% get the same index from p1_index and m1_index
    r_index = intersect(p1_index, m1_index);
    
    %% get the robust dct8x8 chunk
    chunk_nums = length(r_index);
    dct8x8_r_chunk = zeros(8, chunk_nums*8);
    for num = 1:chunk_nums
        % find the r and c
        b = r_index(num);
        ds = int32((b - 1)/size_(2)) + 1;
        r = int32(fix((b -1) / size_(2))) + 1; 
        c = int32(mod(b, size_(2)));
        if c == 0
            c = size_(2);
        end
        % get dct coefs
        for i = 1:8
            for j = 1:8
                dct8x8_r_chunk(i,(num-1)*8+j) = dct_coefs((r-1)*8+i,(c-1)*8 +j);
            end
        end
    end
    
end

 