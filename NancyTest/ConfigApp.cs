using Nancy;
using Nancy.Bootstrapper;
using Nancy.Conventions;
using Nancy.Session;
using Nancy.TinyIoc;
using ServiceStack.Redis;

namespace NancyTest
{
    internal class ConfigApp : DefaultNancyBootstrapper
    {
        protected override IRootPathProvider RootPathProvider
        {
            get { return new CustomRootPathProvider(); }
        }

        protected override void ApplicationStartup(TinyIoCContainer container, IPipelines pipelines)
        {
            base.ApplicationStartup(container, pipelines);
//            CookieBasedSessions.Enable(pipelines);
            //redis setting
            container.Register<IRedisClientsManager>(
                new PooledRedisClientManager("127.0.0.1:6379"));
            container.Register(container.Resolve<IRedisClientsManager>().GetClient());
//            container.Register<IRedisClient>(new RedisClient());
            RedisBasedSessions.Enable(pipelines);
        }

        protected override void ConfigureConventions(NancyConventions nancyConventions)
        {
            nancyConventions.StaticContentsConventions.Add(StaticContentConventionBuilder.AddDirectory("Views", @"Views"));
            base.ConfigureConventions(nancyConventions);
        }
    }

    public class CustomRootPathProvider : IRootPathProvider
    {
        public string GetRootPath()
        {
            return "C:\\Users\\dbfan\\Documents\\Visual Studio 2017\\Projects\\NancyTest\\NancyTest";
        }
    }
}