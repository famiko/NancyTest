using System;
using audio;
using Nancy;
using NancyTest.RedisService;
using System.Security.Cryptography;
using System.Text;
using MathWorks.MATLAB.NET.Arrays;
using video;

namespace NancyTest
{
    public class CaptchaModule : NancyModule
    {
        dynamic IndexPage() { return View["Index"]; }

        public CaptchaModule(
            AudioService audioService,
            AudioUtil audioUtil,
            VideoUtil videoUtil)
        {
            Get["/"] = _ =>
            {
                return IndexPage();
            };

            Get["/audio"] = _ =>
            {
                var key = audioService.GetKey();
                var value = audioService.GetValue(key).Trim('"');
                // 保存答案
                Session["audio_answer"] = value;
                var str = Guid.NewGuid().ToString();
                // 调用MATLAB
                try
                {
                    audioUtil.audio(key, str);
                }
                catch (Exception e)
                {
                    return e.ToString();
                }
                // 返回生成的音频
                return Response.AsText($"/audio_gen/{str}.wav");
            };

            Get["/audio_gen/{name}"] = _ =>
            {
                string fileName = _.name;
                var relatePath = @"audio_gen\" + fileName;
                return Response.AsFile(relatePath);
            };

            Get["/audio_check/{name}"] = _ =>
            {
                if (Session["audio_answer"] == null)
                {
                    return new Response().WithStatusCode(HttpStatusCode.Conflict);
                }
                var text = Session["audio_answer"].ToString();
                if (text.Equals(_.name.ToString()))
                {
                    return new Response().WithStatusCode(HttpStatusCode.OK);
                }
                return new Response().WithStatusCode(HttpStatusCode.Conflict);
            };

            Get["/video"] = _ =>
            {
                var str = Guid.NewGuid().ToString();
                try
                {
                    var answer = videoUtil.test_video((MWArray)1, 1.7, str).ToString();
                    Session["video_answer"] = answer.ToLower();
                }
                catch (Exception e)
                {
                    return e.ToString();
                }
                return Response.AsText($"/video_gen/{str}.mp4");
            };

            Get["/video_gen/{name}"] = _ =>
            {
                string fileName = _.name;
                var relatePath = @"video_gen\" + fileName;
                return Response.AsFile(relatePath);
            };

            Get["/video_check/{name}"] = _ =>
            {
                if (Session["video_answer"] == null)
                {
                    return new Response().WithStatusCode(HttpStatusCode.Conflict);
                }
                var text = Session["video_answer"].ToString();
                if (text.Equals(_.name.ToString().ToLower()))
                {
                    return new Response().WithStatusCode(HttpStatusCode.OK);
                }
                return new Response().WithStatusCode(HttpStatusCode.Conflict);
            };
        }
        private static string Encrypt(string txt)
        {
            var md5 =
                new MD5CryptoServiceProvider();
            var bytes = md5.ComputeHash(Encoding.UTF8.GetBytes(txt));

            return BitConverter.ToString(bytes).Replace("-", "");
        }
    }
}