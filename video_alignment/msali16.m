function ms = msali16(img, ref, cm)

% img = msFrame385;
% ref = msFrame386;

Aix = 21; Bix = 21; Cix = 21; Dix = 21; 
[Aixo, Bixo, Cixo, Dixo] = running_machine(Aix, Bix, Cix, Dix, img, ref, cm);
sw = 1; lr = 0.9; cnt3 = 0; cnt_nan = 0; cnt_ad1 = 0;
preDirection = ([Aixo, Bixo, Cixo, Dixo] - [round(Aix), round(Bix), round(Cix), round(Dix)]) ...
        ./ abs([Aixo, Bixo, Cixo, Dixo] - [round(Aix), round(Bix), round(Cix), round(Dix)]);
while sw
    dA = (Aixo - round(Aix))*lr; dB = (Bixo - round(Bix))*lr;  dC = (Cixo - round(Cix))*lr; dD = (Dixo - round(Dix))*lr;
    Aix = Aix + dA; Bix = Bix + dB; Cix = Cix + dC; Dix = Dix + dD;

    [Aixo, Bixo, Cixo, Dixo] = ...
        running_machine(round(Aix), round(Bix), round(Cix), round(Dix), img, ref, cm);
    
    Direction = ([Aixo, Bixo, Cixo, Dixo] - [round(Aix), round(Bix), round(Cix), round(Dix)]) ...
        ./ abs([Aixo, Bixo, Cixo, Dixo] - [round(Aix), round(Bix), round(Cix), round(Dix)]);
    
    tmp3 = nanmean(Direction ./ preDirection);
    preDirection = Direction;
    
    if tmp3 < 0 || isnan(tmp3); cnt3 = cnt3 + 1; end
    if isnan(tmp3); cnt_nan = cnt_nan + 1; end
    if cnt_nan == 20; break; end
    %
    add1 = nanmean(abs([Aixo, Bixo, Cixo, Dixo] - [round(Aix), round(Bix), round(Cix), round(Dix)]) < 2.1) > 0.9;
    if add1;  cnt_ad1 =  cnt_ad1 + 1; end
    
    if cnt_ad1 > 20
        tmp9 = round(([Aixo, Bixo, Cixo, Dixo] + [round(Aix), round(Bix), round(Cix), round(Dix)])/2);
        Aixo = tmp9(1); Bixo = tmp9(2); Cixo = tmp9(3); Dixo = tmp9(4);
        break; 
    end
    
    if lr < 0.4; break; end
    if cnt3 == 10; cnt3 = 0; lr = lr - 0.1; end
    
    [Aixo, Bixo, Cixo, Dixo, lr, cnt_ad1]
end

ms.Aixo = Aixo; ms.Bixo = Bixo; ms.Cixo = Cixo; ms.Dixo = Dixo;