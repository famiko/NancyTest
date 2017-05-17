using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using ServiceStack;
using ServiceStack.Redis;

namespace NancyTest
{
    public class RedisUtils
    {
        private readonly IRedisClient _client;

        public RedisUtils(IRedisClient client)
        {
            _client = client;
//             初始化Redis
//            var lines =
//                File.ReadLines(
//                    "C:\\Users\\dbfan\\Documents\\Visual Studio 2017\\Projects\\NancyTest\\NancyTest\\chengyu.txt");
//            var filePath =
//                "C:\\Users\\dbfan\\Documents\\Visual Studio 2017\\Projects\\NancyTest\\NancyTest\\audio_files";
//            var files = System.IO.Directory.GetFiles(filePath);
//            var fileNames = new ArrayOfString();
//            foreach (var file in files)
//            {
//                fileNames.Add(Path.GetFileName(file));
//            }
//            var i = 0;
//            foreach (var line in lines)
//            {
//                Console.WriteLine("第" + ++i + "行");
//                var str = Encrypt(line).ToLower();
//                if (fileNames.Contains(str + ".mp3"))
//                {
//                    AddItem(str, line);
//                }
//                Thread.Sleep(200);
//            }
        }

        private void AddItem(string key, string value)
        {
            if (!_client.Add(key, value))
                Console.WriteLine(value);
            else
            {
                Console.WriteLine("写入" + value);
            }
        }

        // 暴露两个必要的方法。
        public string GetValue(string key) => _client.GetValue(key);

        public string GetKey() => _client.GetRandomKey();

        // 将成语进行md5编码
        private static string Encrypt(string txt)
        {
            var md5 =
                new MD5CryptoServiceProvider();
            var bytes = md5.ComputeHash(Encoding.UTF8.GetBytes(txt));

            return BitConverter.ToString(bytes).Replace("-", "");
        }
    }
}