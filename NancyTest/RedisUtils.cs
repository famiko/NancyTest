using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using ServiceStack.Redis;

namespace NancyTest
{
    public class RedisUtils
    {
        private readonly IRedisClient _client;

        public RedisUtils(IRedisClient client)
        {
            _client = client;
            // 初始化Redis
//            var lines =
//                File.ReadLines(
//                    "C:\\Users\\dbfan\\Documents\\Visual Studio 2017\\Projects\\NancyTest\\NancyTest\\chengyu.txt");
//            foreach (var line in lines)
//                AddItem(Encrypt(line), line);
        }

        private void AddItem(string key, string value)
        {
            if (!_client.Add(key, value))
                Console.WriteLine(value);
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