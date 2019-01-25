function cm = pre_linear_model(rs, cs)

% ��鸲�� �����ϰ��� �ϴ� �̹�����, ��� ������ ������ �����ϰ� ���� ��� (��κ��� �Ϲ����� ��쿡 �ش�)
% �̹����� ����, ��ġ�� �̵��ϴ��� ��������� �����ǹǷ� �̸� �����ϱ� ���� �� ���� ������ ������ �����־�� ��
% ����, �̹��� �������� ���� �𵨷� ������ �ɰ���.

% row�� ���� ������ y = ax + b���� a,b ��
% col�� ���� ������ w = cz + d���� c,d ��
% ��, a,b �׸��� c,d 4���� ���� ���Ͽ� ������ �̹��� ���� �������� ã����
% ����, ��ġ�� ���� ���� ���� ���� �� ����
% �� ��� ������ �ݺ��ǹǷ�,
% �̸� �������� ����� ���� ��꿡 �����.
% �� �Լ��� �������� ����� ���� ������.

ix = 0; a = 0; % ix�� �ܼ� for�� indexing��
for b = -20:1:20 % ù��° for���� row �������� b model�� �������. a �� 0���� ������. 
    ix = ix+1;
    for row = 1:rs
        cmrowb(row,1:cs,ix) = a*row + b;
    end
end

ix = 0; b = 0;
for a = -20/rs:(20/rs+20/rs)/40:20/rs % ���� �ݺ��Ͽ�  cm�� ������ �� ���.
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