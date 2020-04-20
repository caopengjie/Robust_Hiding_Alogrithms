function [ rho_r_p1, rho_r_m1 ] = get_robust_cost( rho_p1, rho_m1, r_index )
    %% get the robust r and c
    size_ = size(rho_p1);
    dct8x8_c = size_(2)/8;
    
    %% rho_r_p1, rho_r_m1 get
    rho_r_p1 = zeros(8, length(r_index)*8);
    rho_r_m1 = zeros(8, length(r_index)*8);
    
    for num = 1: length(r_index)
        % find the r and c
        r = int32(fix((r_index(num)-1)/dct8x8_c) + 1);
        c = int32(mod(r_index(num), dct8x8_c));
        if c == 0
            c = dct8x8_c;
        end
        % get dct coefs
        for i = 1:8
            for j = 1:8
                rho_r_p1(i, (num-1)*8+j) = rho_p1((r-1)*8+i,(c-1)*8 +j);
                rho_r_m1(i, (num-1)*8+j) = rho_m1((r-1)*8+i,(c-1)*8 +j);
            end
        end
    end
end

