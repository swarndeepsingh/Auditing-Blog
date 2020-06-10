using System;
using System.Web;
using System.DirectoryServices;

namespace DBaaS.classes
{
    public class ldapauth : IHttpModule
    {
        /// <summary>
        /// You will need to configure this module in the Web.config file of your
        /// web and register it with IIS before being able to use it. For more information
        /// see the following link: https://go.microsoft.com/?linkid=8101007
        /// </summary>
        #region IHttpModule Members

        public void Dispose()
        {
            //clean-up code here.
            // Dispose(true);
        }

        public void Init(HttpApplication context)
        {
            // Below is an example of how you can handle LogRequest event and provide 
            // custom logging implementation for it
            // context.LogRequest += new EventHandler(OnLogRequest);
        }

        #endregion

        
        public bool IsAuthenticated(string ldapserver, string ldapAdmUsr, string ldapAdmPwd, string username, string pwd)
        {
            string userdn;

            userdn = "";

            DirectoryEntry root = new DirectoryEntry("LDAP://" + ldapserver, ldapAdmUsr, ldapAdmPwd, AuthenticationTypes.ServerBind);


            DirectorySearcher searcher = new DirectorySearcher(root);

            searcher.PropertiesToLoad.Add("entrydn");
            searcher.Filter = "(&(objectClass=person)(uid=" + username + "))";

            try
            {
                // Bind directory connection with user
                SearchResult result = searcher.FindOne();

                ResultPropertyCollection propertyCollection = result.Properties;

                foreach (string mykey in propertyCollection.PropertyNames)
                {
                    if (mykey == "entrydn")
                    {
                        foreach (object myCollection in propertyCollection[mykey])
                        {
                            userdn = myCollection.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {

                Console.WriteLine(ex.Message.ToString());
                return false;
            }



            root = new DirectoryEntry("LDAP://" + ldapserver, userdn, pwd, AuthenticationTypes.ServerBind);
            searcher = new DirectorySearcher(root);

            try
            {
                SearchResult resultdn = searcher.FindOne();
            }

            catch (Exception ex)
            {
                Console.WriteLine(ex.Message.ToString());
                return false;
            }



            return true;
        }
    }
}
