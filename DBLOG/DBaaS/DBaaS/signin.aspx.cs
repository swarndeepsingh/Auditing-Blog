using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DBaaS.classes;
using Npgsql;



namespace DBaaS
{
    public partial class signin : System.Web.UI.Page
    {
        string ldapServer;
        string ldapAdminUser;
        string ldapAdminPwd;
        ExceptionSave es;
        string user;
        string pwd;

        protected void Page_Load(object sender, EventArgs e)
        {
            //foreach (TimeZoneInfo info in TimeZoneInfo.GetSystemTimeZones())
            //    Console.Write(info);

            //var dtos = new DateTimeOffset(DateTime.Now);
            //var dt = DateTime.Now;




            ldapServer = "192.168.173.190";
            ldapAdminUser = "CN=Admin,DC=ebix, DC=com";
            ldapAdminPwd = "P@ssw0rd";
            //Decide where to login if there is an error

            Session.Add("Redirect", "LoginPage");
            Session.Add("LdapAuthed", false);
            Session.Add("LdapUser", "None");
            //txtTimeZone.Text = dtos.ToString();
            //txtcurrenttime.Text = dt.ToString();

        }

        public bool inputValidation()
        {
            es = new ExceptionSave();
            user = txtUser.Text.Trim();
            pwd = txtPwd.Text.Trim();

            if ((user.Length< 3)||(pwd.Length< 1))
            {
                Session["Redirect"] = "LoginPage";
                es.SaveExceptionToDB("User Name or Password Input not valid for " + user, "inputValidation Method", this.GetType().Name, Session["LdapUser"].ToString());
                es.Dispose();
                return false;
            }

            else
            {
                es.Dispose();
                return true;
            }

            
        }
        public bool LdapLoginValidate()
        {
            ldapauth ldauth;
            ldauth = new ldapauth();
            
            es = new ExceptionSave();

           
            bool resultldapauth=false;
            try
            {
                resultldapauth = ldauth.IsAuthenticated(ldapServer, ldapAdminUser, ldapAdminPwd, user, pwd);
                if (resultldapauth == false)
                {
                    throw new Exception("Ldap Authentication failed");
                }
                else
                {
                    Session["LdapAuthed"] = true;
                    Session["LdapUser"] = user;
                    
                    es.Dispose();
                    ldauth.Dispose();
                    return resultldapauth;
                }
                
            }
            catch(Exception ex)
            {
                Session["Redirect"] = "LoginPage";
                es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());
                es.Dispose();
                Response.Redirect("~/Error.aspx?Error=" + ex.Message);
                return false;

            }
        }

        public void navigateToPage(string page)
        {
            Response.Redirect(page);
        }

        public void btnSubmitOnClick(object sender, EventArgs e)
        {
            bool userexists = false;
            bool managerexists = false;
            
            if (inputValidation())
            {


                es = new ExceptionSave();

                if (LdapLoginValidate())
                {
                    // create object
                    pgsql pg;
                    pg = new pgsql();

                    // get connection string
                    var connstr="";
                    connstr = pg.ConnectToPostsql();

                    //initiate connection
                    using (var conn = new NpgsqlConnection(connstr))
                    {
                        try
                        {
                            conn.Open();

                            using (var cmd = new NpgsqlCommand("select u.userid, e.manageremail from RTM.Users as u left outer join RTM.usermanageremail as e 	on u.userid=e.userid where u.username='" + user + "'", conn))
                            {

                                using (var reader = cmd.ExecuteReader())
                                {

                                    if (!reader.HasRows)
                                    {
                                        try
                                        {
                                            throw new Exception("User " + user + " Not Found!! in database" + this.GetType().Name);
                                        }
                                        catch (Exception ex)
                                        {
                                            Session["Redirect"] = "LoginPage";
                                            es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());

                                            userexists = false;
                                        }
                                        finally
                                        {
                                            //conn.Close();
                                        }
                                    }
                                    else if (reader.HasRows)
                                    {
                                        String mangemail;
                                        mangemail = "";


                                        while (reader.Read())
                                        {
                                            Console.WriteLine(reader.GetValue(1));
                                            mangemail = reader.GetValue(1).ToString();
                                        }

                                        if (mangemail == null||mangemail=="")
                                        {
                                            try
                                            {
                                                throw new Exception("User " + user + " managers email address missing." + this.GetType().Name);
                                            }
                                            catch (Exception ex)
                                            {
                                                Session["Redirect"] = "LoginPage";
                                                es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());
                                                userexists = true;
                                                managerexists = false;
                                            }
                                        }
                                        else
                                        {
                                            userexists = true;
                                            managerexists = true;

                                        }
                                    }
                                    


                                    //    while (reader.Read())
                                    //    {
                                    //        Response.Write(reader.GetString(1));
                                    //    }
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            Session["Redirect"] = "LoginPage";
                            es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());
                            Response.Redirect("~/Error.aspx?Error=" + ex.Message);
                        }
                        finally
                        {
                            //conn.Close();
                        }
                    }
                    pg.Dispose();
                    
                }
                if  (userexists == true && managerexists == false)
                {
                    Session["Redirect"] = "LoginPage";
                    Response.Redirect("~/Error.aspx?Error=We are working on the user setup, please try again after 5 minutes. If not fixed in 15 minutes then contact globalsql");
                }
                if (userexists == true && managerexists==true) 
                {
                    navigateToPage("~/selection.aspx");
                }
                else if(userexists==false)
                {
                    navigateToPage("~/registeruser.aspx");
                }
                es.Dispose();
            }
            else
            {
                es.Dispose();
                
                Response.Write("<script>alert('Login Input Not Valid');</script>");
                return;
            }
        }

    }
}