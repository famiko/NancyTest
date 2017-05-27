using System;
using System.Diagnostics;
using MathWorks.MATLAB.NET.Arrays;
using Nancy.Session;
using video;

namespace NancyTest.Service
{
    public class VideoService
    {
        private readonly AudioService _audioService;

        private readonly VideoUtil _videoUtil;

        private readonly ContentValidator _content;

        private readonly SubtitleValidator _subtitle;

        private readonly BackgroundValidator _background;

        public VideoService(
            AudioService audioService,
            VideoUtil videoUtil,
            ContentValidator content,
            SubtitleValidator subtitle,
            BackgroundValidator background)
        {
            _audioService = audioService;
            _videoUtil = videoUtil;
            _content = content;
            _subtitle = subtitle;
            _background = background;
        }

        public enum VideoType
        {
            subtitle,
            background,
            content
        }

        private readonly Random _random = new Random();

        public VideoType GetVideoType() => (VideoType) _random.Next(2);

        public void generate(ISession session)
        {
            var type = GetVideoType();
            var str = Guid.NewGuid().ToString();
            session["video_type"] = type;
            session["video_addr"] = str;
            switch (type)
            {
                case VideoType.background:
                    session["video_answer"] = "ac6i3";
                    _videoUtil.test_video(1, 1, 2, str, 1);
                    session["video_question"] = _audioService.generate("background");
                    break;
                case VideoType.content:
                    session["video_answer"] = new[] {"猫", "鼠", "汤姆", "杰瑞", "tom", "jerry"};
                    _videoUtil.test_video(1, 1, 2, str, 0);
                    session["video_question"] = _audioService.generate("content");
                    break;
                case VideoType.subtitle:
                    session["video_answer"] = ((MWArray[])_videoUtil.test_video(1, 1, 2, str, -1))[0];
                    session["front"] = _random.Next(0, 2).ToString();
                    session["video_length"] = _random.Next(4, 7).ToString();
                    session["video_question"] = _audioService.generate($"{session["front"]}-{session["video_length"]}");
                    break;
            }
        }

        private IVideoAnswerValidator GetValidator(VideoType type)
        {
            switch (type)
            {
                case VideoType.subtitle:
                    return _subtitle;
                case VideoType.content:
                    return _content;
                case VideoType.background:
                    return _background;
                default:
                    return null;
            }
        }

        public bool Validate(string answer, ISession session)
            => GetValidator((VideoType) session["video_type"]).Validate(answer, session);
    }
}