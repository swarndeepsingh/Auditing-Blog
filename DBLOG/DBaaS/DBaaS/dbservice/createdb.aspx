<%@ Page Language="C#" MasterPageFile="~/DBLOG.Master" AutoEventWireup="true" CodeBehind="createdb.aspx.cs" Inherits="DBaaS.dbservice.creatredb" %>


<asp:Content ID="dbassopentionhc" runat="server" ContentPlaceHolderID="ParentContent">
            <link href="/dblog3/css/dbaas.css" rel="stylesheet" type="text/css" />
            
</asp:Content>

<asp:Content ID="dbaasoptioncont" runat="server" ContentPlaceHolderID="ChildContent">
    <table style="width: 100%;" class="tablestyle">
        <tr style="align-items:center">
            <td class="tabletd" colspan="2">
                <asp:label ID="label1" runat="server" CssClass="pagetitle" Text="Create New Database"></asp:label><br /><br /><br /><br />
            </td>
        </tr >
        <tr >
            <td class="formtabletdlabel">
                <asp:label ID="lblDataCenter" runat="server" CssClass="formlabel" Text="Data Center" ></asp:label>
            </td>
            <td class="formtabletdfield">
                <asp:DropDownList ID="ddDataCenter" runat="server" CssClass="dropdown" OnSelectedIndexChanged="ddDataCenter_OnSelectionChange" AutoPostBack="true" ViewStateMode="Enabled" EnableViewState="true"></asp:DropDownList>
            </td>
            <tr >
            <td class="formtabletdlabel">
                <asp:label ID="Label2" runat="server" CssClass="formlabel" Text="RDBMS" ></asp:label>
            </td>
            <td class="formtabletdfield">
                <asp:DropDownList ID="ddRDBMS" runat="server" CssClass="dropdown" >
                </asp:DropDownList>
            </td>
            
        </tr>

        <tr >
            <td class="formtabletdlabel">
                <asp:label ID="Label3" runat="server" CssClass="formlabel" Text="Database Name" ></asp:label>
            </td>
            <td class="formtabletdfield">
                <asp:TextBox ID="txtDBname" runat="server" CssClass="dropdown" ></asp:TextBox>
            </td>
        <tr >
            <td class="formtabletdlabel">
                <asp:label ID="lblDBSize" runat="server" CssClass="formlabel" Text="Database Size (MB)" ></asp:label>
            </td>
            <td class="formtabletdfield">
                <asp:TextBox ID="txtDBSize" runat="server" CssClass="dropdown" >
                </asp:TextBox>
            </td>
            
        </tr>
        <tr>
            <td style="text-align:left" colspan="2">
                <asp:RequiredFieldValidator ID="txtDBNameReq" runat="server" ErrorMessage="Please Enter Database Name" ControlToValidate="txtDBName"></asp:RequiredFieldValidator><br />
                <asp:RegularExpressionValidator ID="txtDBNameReqReg" ControlToValidate="txtDBName" ValidationExpression="^[A-Za-z0-9]*$" runat="server" ErrorMessage="Please Enter Database Name in correct format"></asp:RegularExpressionValidator><BR />
                <asp:RequiredFieldValidator ID="txtDBSizeReg" runat="server" ErrorMessage="Please Enter Database Size" ControlToValidate="txtDBSize"></asp:RequiredFieldValidator><br />
                <asp:RegularExpressionValidator ID="RegularExpressionValidator1" ControlToValidate="txtDBSize" ValidationExpression="^[1-9]\d*$" runat="server" ErrorMessage="Please Enter Database Size in correct format"></asp:RegularExpressionValidator><BR />

            </td>
        </tr>
        <tr>
            <td colspan="2" >
                <asp:Button class="button" Text="Submit Request" runat="server" OnClick="submit_onlcick" />
            </td>
        </tr>
    </table>
</asp:content>

