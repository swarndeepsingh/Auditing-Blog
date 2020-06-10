<%@ Page Language="C#" MasterPageFile="~/DBLOG.Master" AutoEventWireup="true" CodeBehind="dbaasoptions.aspx.cs" Inherits="DBaaS.dbaasoptions" %>



<asp:Content ID="dbassopentionhc" runat="server" ContentPlaceHolderID="ParentContent">
            <link href="/dblog3/css/dbaas.css" rel="stylesheet" type="text/css" />
            
</asp:Content>



<asp:Content ID="dbaasoptioncont" runat="server" ContentPlaceHolderID="ChildContent">

            <link href="/dblog3/css/dbaas.css" rel="stylesheet" type="text/css" />
            

    
            <div runat="server" class="center-div">
                <table style="width: 100%;" class="tablestyle"   >
                    <tr>
                        <td colspan="2" class="tabledb" >
                            <asp:Label ID="Label1" runat="server" Text="Database Self Service" CssClass="label"></asp:Label>

                        </td>
                    </tr>
                    <tr>
                        <td class="tabletd" colspan="2">
                            <asp:Button ID="Button1" runat="server" Text="My Databases" CssClass="button"  />
                        </td>
                        </tr>
                    <tr>
                        <td class="tabletd" colspan="2">
                            <asp:Button ID="btnNewDB" runat="server" Text="Create New Database" CssClass="button" OnClick="btnNewDB_OnClick" />
                        </td>                        
                    </tr>

                    <tr>
                        <td class="tabletd" colspan="2">
                            <asp:Button ID="Button3" runat="server" Text="Submit script to execute" CssClass="button" />
                        </td>                        
                    </tr>
                    <tr>
                        <td class="tabletd" colspan="2">
                            <asp:Button ID="btnBackup" runat="server" Text="Submit Backup Request" CssClass="button" OnClick="btnSubmitBackup"/>
                        </td>                        
                    </tr>
                    <tr>
                        <td class="tabletd" colspan="2">
                            <asp:Button ID="Button4" runat="server" Text="Requests" CssClass="button" OnClick="btnMyRequests_OnClick" />
                        </td>                        
                    </tr>

                </table>
            </div>
    </asp:Content>

