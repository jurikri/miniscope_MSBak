function cm = pre_linear_model(rs, cs)

% 흔들림을 보정하고자 하는 이미지가, 적어도 평면상의 패턴을 유지하고 있을 경우 (대부분의 일반적인 경우에 해당)
% 이미지의 각도, 위치가 이동하더라도 평면패턴이 유지되므로 이를 보정하기 위한 값 역시 평면상의 패턴이 남아있어야 함
% 따라서, 이미지 보정값은 선형 모델로 설명이 될것임.

% row에 따른 선형모델 y = ax + b에서 a,b 값
% col에 따른 선형모델 w = cz + d에서 c,d 값
% 즉, a,b 그리고 c,d 4가지 값을 구하여 최적의 이미지 보정 선형모델을 찾으면
% 각도, 위치에 따른 보정 값을 구할 수 있음
% 이 계산 과정은 반복되므로,
% 미리 선형모델을 만들어 놓고 계산에 사용함.
% 이 함수는 선형모델을 만들어 놓는 역할임.

ix = 0; a = 0; % ix는 단순 for문 indexing용
for b = -20:1:20 % 첫번째 for문은 row 보정값의 b model을 만드는겂임. a 는 0으로 고정함. 
    ix = ix+1;
    for row = 1:rs
        cmrowb(row,1:cs,ix) = a*row + b;
    end
end

ix = 0; b = 0;
for a = -20/rs:(20/rs+20/rs)/40:20/rs % 이하 반복하여  cm에 저장한 뒤 출력.
    ix = ix+1;
    for row = 1:rs
        cmrowa(row,1:cs,ix) = a*row + b;
    end
end

ix = 0; a = 0;
for b = -20:1:20
    ix = ix+1;
    for col = 1:cs
        cmcolb(1:rs,col,ix) = a*col + b;
    end
end

ix = 0; b = 0;
for a = -20/rs:(20/rs+20/rs)/40:20/rs
    ix = ix+1;
    for col = 1:cs
        cmcola(1:rs,col,ix) = a*col + b;
    end
end

cm.cmrowa = cmrowa; cm.cmrowb = cmrowb; cm.cmcola = cmcola; cm.cmcolb = cmcolb;