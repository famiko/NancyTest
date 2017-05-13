using System;
using System.Security.Cryptography;
using System.Text;
using audio;
using MathWorks.MATLAB.NET.Arrays;
using Nancy;
using NancyTest.Service;
using video;

namespace NancyTest
{
    public class CaptchaModule : NancyModule
    {
        public CaptchaModule(
            RedisUtils redisUtils,
            AudioService audioService,
            VideoService videoService)
        {
            Get["/"] = _ => View["Index"];

            Get["/audio"] = _ =>
            {
                var key = redisUtils.GetKey();
                var value = redisUtils.GetValue(key).Trim('"');
                // 保存答案
                Session["audio_answer"] = value;
                var str = audioService.generate(key);
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
                    return new Response().WithStatusCode(HttpStatusCode.Conflict);
                var text = Session["audio_answer"].ToString();
                return audioService.validate(_.name, text)
                    ? new Response().WithStatusCode(HttpStatusCode.OK)
                    : new Response().WithStatusCode(HttpStatusCode.Conflict);
            };

            Get["/video"] = _ =>
            {
                videoService.generate(this.Session);
                return
                    Response.AsJson(
                        new
                        {
                            type = Session["video_type"],
                            video = $"/video_gen/{Session["video_addr"]}.mp4",
                            audio = $"/audio_gen/{Session["video_question"]}.wav"
                        });
            };

            Get["/video_gen/{name}"] = _ =>
            {
                string fileName = _.name;
                var relatePath = @"video_gen/" + fileName;
                return Response.AsFile(relatePath);
            };

            Get["/video_check/{name}"] = _ =>
            {
                if (Session["video_answer"] == null)
                    return new Response().WithStatusCode(HttpStatusCode.Conflict);
                return videoService.Validate(_.name, this.Session)
                    ? new Response().WithStatusCode(HttpStatusCode.OK)
                    : new Response().WithStatusCode(HttpStatusCode.Conflict);
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