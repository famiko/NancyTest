
function y=mix_word(s1, y)
r=randsrc(1,1,[1,2,3,4,5,6]);
%s1=randsrc(1,1,[10,11,12,13,14,15,16]);
%sui ji zao sheng
filepath_r='C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\audio_noise\';
filepath_r=strcat(filepath_r,int2str(r));
filepath_r=strcat(filepath_r,'.wav');

%[x,fs]=audioread(filepath_r); %��ȡ�����źŵ����ݣ���������x1
%sui ji yu yin wen jian
filepath_s1='C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\audio_files\';
filepath_s1=strcat(filepath_s1,s1);
filepath_s1=strcat(filepath_s1,'.mp3');


[x,fs]=audioread(filepath_r);
x = x/3;


[after1,Fs1]=mixvoice(filepath_s1);
%after1=after1(1:80000);
after1=after1(:);
x=x(1:length(after1));
x=x(:);
after2=after1+x;

after2 = after2 * 2;
after2=awgn(after2,30); % �����˹������
a=randsrc(1,1,[1.25,1.5,1.75,2]);
after2=resample(after2,fs,a*fs/1.5); % �ز���
after2=after2/max(abs(after2(:)));
%sound(after2, Fs1)
audiowrite(['C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\audio_gen\',y,'.wav'],after2,Fs1);

y=1;



function [s_syn,Fs]=mixvoice(filepath)

    % ���峣��
    FL = 80;                % ֡��
    WL = 240;               % ����
    P = 10;                 % Ԥ��ϵ������
    [temp, Fs]=audioread(filepath);%temp��ʾ�������� Fs��ʾƵ��
    handles.y=temp;
    handles.Fs=Fs;
    s = handles.y;
    %s(:,1)=[];  %�õ�һ��Ϊ��
    s = s(logical(s));
    s = s/max(s);
    %s = readspeech('Tomvoice.pcm',100000) % ��������s
    %s = readspeech('57.wav',100000);
    %sound(s,Fs);
    %wavplay(s,Fs*0.6);
    %wavwrite(handles.y,Fs*1.3,'new.wav');
    %sound (s);
    L = length(s);          % ������������
    FN = floor(L/FL)-2;     % ����֡��
    % Ԥ����ؽ��˲���
    exc = zeros(L,1);       % �����źţ�Ԥ����
    zi_pre = zeros(P,1);    % Ԥ���˲�����״̬
    s_rec = zeros(L,1);     % �ؽ�����
    zi_rec = zeros(P,1);
    % �ϳ��˲���
    exc_syn = zeros(L,1);   % �ϳɵļ����źţ����崮��
    s_syn = zeros(L,1);     % �ϳ�����
    zi_syn = zeros(P,1);

    hw = hamming(WL);       % ������
    for n = 3:FN

        % ����Ԥ��ϵ��������Ҫ���գ�
        s_w = s(n*FL-WL+1:n*FL).*hw;    %��������Ȩ�������
        [A E] = lpc(s_w, P);            %������Ԥ�ⷨ����P��Ԥ��ϵ��
                                        % A��Ԥ��ϵ����E�ᱻ��������ϳɼ���������

        if n == 27
          %figure;zplane(1,A);
        end
        
        s_f = s((n-1)*FL+1:n*FL);       % ��֡�����������Ҫ����������
        

        %��filter����s_f���㼤���������˲���״̬
        [exc_1, zi_pre] = filter(A, 1, s_f, zi_pre);
        exc((n-1)*FL+1:n*FL) = exc_1;

        %��filter������exc�ؽ�������ע�Ᵽ���˲���״̬
        [rec_1, zi_rec] = filter(1, A, exc_1, zi_rec);
         s_rec((n-1)*FL+1:n*FL) = rec_1;

        

        %ֻ���ڵõ�exc��Ż������ȷ
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % �����������PT����Ҫ�����գ�
        G = sqrt(E*PT);           % ����ϳɼ���������G����Ҫ�����գ�
        
        %���ɺϳɼ��������ü�����filter���������ϳ�����
        if n==3
              sta=0;
         end
              while sta <= FL
                     exc_syn((n-1)*FL+sta) = G;
                     sta = sta + PT;
              end
               sta = sta - FL;             
      
          [s_syn((n-1)*FL+1:n*FL),zf] = filter(1,A,exc_syn((n-1)*FL+1:n*FL),zi_syn);
          zi_syn = zf;
    end      
    %sound(s_syn,Fs);
    %wavwrite(s_syn,Fs,'sounddone\1.wav')
return

% ����һ�������Ļ�������
function PT = findpitch(s)
[B, A] = butter(5, 700/4000);
s = filter(B,A,s);
R = zeros(143,1);
for k=1:143
    R(k) = s(144:223)'*s(144-k:223-k);
end
[R1,T1] = max(R(80:143));
T1 = T1 + 79;
R1 = R1/(norm(s(144-T1:223-T1))+1);
[R2,T2] = max(R(40:79));
T2 = T2 + 39;
R2 = R2/(norm(s(144-T2:223-T2))+1);
[R3,T3] = max(R(20:39));
T3 = T3 + 19;
R3 = R3/(norm(s(144-T3:223-T3))+1);
Top = T1;
Rop = R1;
if R2 >= 0.85*Rop
    Rop = R2;
    Top = T2;
end
if R3 > 0.85*Rop
    Rop = R3;
    Top = T3;
end
PT = Top;
return

