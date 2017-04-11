using Nancy.Hosting.Self;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NancyTest
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var host = new NancyHost(new ConfigApp(),new Uri("http://localhost:80")))
            {
                string rootPath = @"C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\";
                string[] strings = { "audio_gen", "video_gen" };
                foreach (var path in strings)
                {
                    var folder = rootPath + path;
                    if (System.IO.Directory.Exists(folder))
                    {
                        System.IO.Directory.Delete(folder, true);
                    }
                    System.IO.Directory.CreateDirectory(folder);
                }
                host.Start();
                Console.WriteLine("Running on http://localhost:80");
                Console.ReadLine();
            }
        }
    }
}
