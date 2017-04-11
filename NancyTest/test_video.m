function answer = test_video(char_distance,text_speed, video_gen_name)
%-----------�����б�----------------------------
raw_video_root_path = 'C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\video_files\';                                                           %����ԭʼ��Ƶ��·��
raw_video_account = 2;                                                             %������Ƶ��Ŀ
video_gen_path = ['C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\video_gen\', video_gen_name, '.mp4'];                                      %������Ƶ·��
raw_chars = char([50:57,65:78,80:90,97:107,109:110,112:122]);                       %ASCII��,2-9,A-N,P-Z,a-k,m-n,p-z,ȥ����0,O,o,1,l
str_gen_max = 10;                                                                   %�����ַ�����󳤶�
str_gen_min = 6;                                                                    %�����ַ�����̳���
answer_min = 4;                                                                     %����̳���
raw_video_path = getRawVideoPath(-1, raw_video_root_path, raw_video_account);
str_gen = getString(-1, str_gen_max, str_gen_min, raw_chars);
videoProcess(raw_video_path, video_gen_path, str_gen, text_speed);
answer = str_gen;
%[answer, index_array] = getAnswer(str_gen, answer_min);
end

%-----------�õ����ַ�������������----------------------------
function [answer, index_array] = getAnswer(str, min)
index_array = randperm(length(str), min + ceil(rand()*(length(str)-min)));
index_array = sort(index_array);
answer = '';
for i = 1:length(index_array)
    answer = [answer str(index_array(i))];
end
end
%-----------�õ��������ַ���----------------------------
function str = getString(n, max, min, chars)
if n <= 0
    count = ceil(rand()*(max - min)) + min;
else
    count = n;
end
str = randsample(chars, count, 1); %��������������Ϊ���ظ�
end

%-----------�õ�ԭʼ��Ƶ·��----------------------------
function path = getRawVideoPath(n, root_path, video_account)
if n > 0
    path = [root_path, int2str(n), '.mp4'];
else
    path = [root_path, int2str(ceil(rand()*video_account)), '.mp4'];
end
end

%--------------��Ƶ֡����-------------------------------------------
function videoProcess(raw_video_path, video_gen_path, str, text_speed)
%--------------��ȡ��Ƶ�Ļ�����Ϣ-----------------------------------
video_reader = VideoReader(raw_video_path);
video_fps = video_reader.FrameRate;      %֡��
video_frames = video_reader.NumberOfFrames;   %֡��   
video_width = video_reader.Width;            %֡��
video_height = video_reader.Height;           %֡��
[font_size, positon] = getInsertTextMeta(str, video_width, video_height, video_frames, video_fps);
color = randi(255, 1, 3);
font = randsample(listTrueTypeFonts(), 1);
proportion = video_width/video_frames;
vw = VideoWriter(video_gen_path,'MPEG-4');  %mp4��ʽ��avc(h264)���뷽ʽ
vw.FrameRate = video_fps;
open(vw);
for i = 1:video_frames
    image = read(video_reader,i);
    %image = imnoise(image,'speckle',rand(1)/10); %ÿһ֡ͼ��ӽ�������
     %imshow(image);
     %�������ӵ��ı��������ԣ�λ�ã���С����ɫ
     positon(1) = positon(1) - text_speed*proportion;
     image = insertText(image, positon, str, 'FontSize',font_size,'BoxOpacity',0, 'TextColor', color, 'Font', font{1});
     writeVideo(vw,uint8(image)); %�������ı����ͼ��д�뵽��Ƶ
end
close(vw);
end

function [font_size, positon] = getInsertTextMeta(str, video_width, video_height, video_frames, video_fps)
    font_size = 175 + randi(25);
    positon = [video_width  -video_height/4 + randi(video_height/2)];
end