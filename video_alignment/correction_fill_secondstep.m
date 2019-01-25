function fix1 = correction_fill_secondstep(m1, fix_info_row, fix_info_col)
%% ��ĭ ä���
% m1 = double(msFrame(:,:,385));
% i = 1;
% cmrowa_f =  cmrowa(:,:,i);
% cmrowb_f = cmrowb(:,:,21);
% cmcola_f = cmcola(:,:,i);
% cmcolb_f = cmcolb(:,:,21);

%%

rs = size(m1,1);
cs = size(m1,2);

fix1 = NaN(rs,cs);
posthoc = zeros(rs,cs);

for row = 1:rs
    for col = 1:cs
        value = m1(row,col);
        fixr = fix_info_row(row,col);
        fixc = fix_info_col(row,col);
        
        c1 = round(row+fixr) > 0 && round(row+fixr) <= rs;
        c2 = round(col+fixc) > 0 && round(col+fixc) <= cs;
        
        if c1 && c2
            if isnan(fix1(round(row+fixr),round(col+fixc)))
                fix1(round(row+fixr),round(col+fixc)) = value;
            elseif ~isnan(fix1(round(row+fixr),round(col+fixc)))
                posthoc(round(row+fixr),round(col+fixc)) = 1;
            else
                disp('e')
            end
        end
    end
end

for row = 1:rs
    for col = 1:cs
        if posthoc(row,col) == 1
            fix1(row,col) = nan;
        end
    end
end

fix2 = fix1; % fix2�� �����۾��� ������� �ʴ� ref
for row = 1:rs
    for col = 1:cs
        sw = 1;
        if isnan(fix1(row,col))
            try
                if ~isnan(fix2(row-1,col)) && sw
                    fix1(row,col) = (fix2(row-1,col));
                    sw = 0;
                end
            catch
            end
            
            try
                if ~isnan(fix2(row,col-1)) && sw
                    fix1(row,col) = (fix2(row,col-1));
                    sw = 0;
                end
            catch
            end
            
            try
                if ~isnan(fix2(row-1,col-1)) && sw
                    fix1(row,col) = (fix2(row-1,col-1));
                    sw = 0;
                end
            catch
            end
            
            if sw
            end

        end
    end
end


























