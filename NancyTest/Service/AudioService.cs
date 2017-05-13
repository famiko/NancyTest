using System;
using System.Linq;
using System.Runtime.InteropServices;
using audio;
using MathWorks.MATLAB.NET.Arrays;

namespace NancyTest.Service
{
    public class AudioService
    {
        private readonly AudioUtil _audioUtil;

        public AudioService(AudioUtil audioUtil)
        {
            _audioUtil = audioUtil;
        }

        string generate()
        {
            var fileName = Guid.NewGuid().ToString();
            return "";
        }

        public string generate(string key)
        {
            var fileName = Guid.NewGuid().ToString();
            _audioUtil.audio(key, fileName);
            return fileName;
        }

        public bool validate(string answer, string key) => answer.Equals(key);

    }
}