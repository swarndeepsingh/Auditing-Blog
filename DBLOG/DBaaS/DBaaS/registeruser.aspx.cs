using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DBaaS.classes;



namespace DBaaS
{
    
    public partial class registeruser : System.Web.UI.Page
    {
        classes.RegisterNewUser ru;
        classes.ExceptionSave es;
        protected void Page_Load(object sender, EventArgs e)
        {
            txtUser.Text = Session["LdapUser"].ToString();
            // txtEmail.Text = Session["LdapUser"].ToString()+"@ebix.com";
            foreach (TimeZoneInfo info in TimeZoneInfo.GetSystemTimeZones())
            {
                ListItem item = new ListItem(info.ToString(), info.BaseUtcOffset.ToString());
                ddlTimeZone.Items.Add(item);
            }


        }

        public void btnSubmitOnClick(object sender, EventArgs e)
        {

            es = new ExceptionSave();
            string result = "";
            try
            {
                ru = new RegisterNewUser();
                result=ru.RegisterUser(txtUser.Text.Trim(), txtEmail.Text.Trim(), txtFname.Text.Trim(), txtLname.Text.Trim(), ddlTimeZone.SelectedItem.Text, ddlTimeZone.SelectedValue);
                if (result!="saved")
                {
                    throw new Exception(result);
                }           
                
            }
            catch(Exception ex)
            {
                es.SaveExceptionToDB(ex.Message, ex.StackTrace, this.GetType().Name, Session["LdapUser"].ToString());
                Response.Redirect("~/Error.aspx?Error=" + ex.Message);
            }
            finally
            {
                es.Dispose();
                ru.Dispose();
            }
            Response.Redirect("~/selection.aspx");

        }
    }
}