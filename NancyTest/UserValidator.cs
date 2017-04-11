using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NancyTest
{
    using Nancy.Authentication.Basic;
    using Nancy.Security;

    public class UserValidator : IUserValidator
    {
        public IUserIdentity Validate(string username, string password)
        {
            if (username == "demo" && password == "demo")
            {
                return new DemoUserIdentity { UserName = username };
            }

            // Not recognised => anonymous.
            return null;
        }
    }

    internal class DemoUserIdentity : IUserIdentity
    {
        public string UserName { get; set; }

        public IEnumerable<string> Claims { get; }
    }
}
