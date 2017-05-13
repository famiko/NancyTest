using System;
using System.Linq;
using MathWorks.MATLAB.NET.Arrays;
using Nancy.Session;

namespace NancyTest
{
    public interface IVideoAnswerValidator
    {
        bool Validate(string answer, ISession session);
    }

    public class SubtitleValidator : IVideoAnswerValidator
    {
        bool IVideoAnswerValidator.Validate(string answer, ISession session)
        {
            var str = ((MWCharArray)session["video_answer"]).ToString();
            var length = Int32.Parse(session["video_length"].ToString());
            var solution = (Int32.Parse(session["front"].ToString()) == 0)
                ? str.Substring(0,  length)
                : str.Substring(str.Length - length + 1, length);
            Console.WriteLine(str);
            if (answer.ToLower().Equals(solution.ToLower()))
            {
                return true;
            }
            return false;
        }
    }

    public class BackgroundValidator : IVideoAnswerValidator
    {
        bool IVideoAnswerValidator.Validate(string answer, ISession session)
        {
            if (answer.ToLower().Equals(session["video_answer"]))
            {
                return true;
            }
            return false;
        }
    }

    public class ContentValidator : IVideoAnswerValidator
    {
        bool IVideoAnswerValidator.Validate(string answer, ISession session)
        {
            var a = (string[]) session["video_answer"];
            foreach (var str in a)
            {
                if (answer.ToLower().Contains(str.ToString()))
                {
                    return true;
                }
            }
            return false;
        }
    }
}