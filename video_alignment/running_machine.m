function [Aixo, Bixo, Cixo, Dixo] = running_machine(Aix, Bix, Cix, Dix, img, ref, cm)

cmrowa = cm.cmrowa; cmrowb = cm.cmrowb; cmcola = cm.cmcola; cmcolb = cm.cmcolb;
A = nanmean(nanmean(abs(img-ref)));

rn = 3;
parfor sequence = 1:4
    pre = [Aix, Bix, Cix, Dix];
    start1 = 21-rn; end1 = 21+rn;
    min1 = inf(); cnt = 0;
     
    while 1
        if start1 < 1 || start1 > 41; start1 = 1; end
        if end1 < 1 || end1 > 41; end1 = 41; end
        
        for i = start1:end1
            pre(sequence) = i;
            fix1 = correction_fill(img, cmrowa(:,:,pre(1)), cmrowb(:,:,pre(2)), cmcola(:,:,pre(3)), cmcolb(:,:,pre(4)));
            B = nanmean(nanmean(abs(fix1-ref)));
            if B/A < min1; min1 = B/A; minIx = i; end
        end
        
        mid1 = (start1+end1)/2;
        if minIx < mid1; start1 = start1-1; end1 = end1-1;
        elseif minIx > mid1; start1 = start1+1; end1 = end1+1;
        elseif minIx == mid1; break;
        else disp('e'); cnt = cnt+1; end
        if cnt > 5; break; end
    end

    fsave(sequence) = minIx;
end

Aixo = fsave(1); Bixo = fsave(2); Cixo = fsave(3); Dixo = fsave(4);