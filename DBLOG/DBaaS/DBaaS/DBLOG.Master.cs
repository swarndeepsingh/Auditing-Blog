using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace DBaaS
{
    public partial class DBLOG : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            classes.ExceptionSave es;
            try
            {
                if (((bool)Session["LdapAuthed"] == true))
                {
                    lblLDAPUser.Text = Session["LdapUser"].ToString();
                }

                else
                {
                    Response.Redirect("~/error.aspx?error=Login not valid");
                }
            }
            catch (Exception ex)
            {
                Session.Clear();
                Session.Abandon();
                es = new classes.ExceptionSave();
                es.SaveExceptionToDB(ex.Message.ToString(), ex.StackTrace.ToString(), this.GetType().Name, Session["LdapUser"].ToString());
                Response.Redirect("~/error.aspx?error=Login Session not Found");
                
            }
            
        }

        public void btnLogout_OnClick(object sender, EventArgs e)
        {
            //Session["LdapAuthed"] = false;
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/signin.aspx");
        }
    }
}