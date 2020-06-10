<%@ Page Language="C#" MasterPageFile="~/DBLOG.Master" AutoEventWireup="true" CodeBehind="backupRequest.aspx.cs" Inherits="DBaaS.dbservice.backupRequest" %>


<asp:Content ID="dbassopentionhc" runat="server" ContentPlaceHolderID="ParentContent">
            <link href="/dblog3/css/dbaas.css" rel="stylesheet" type="text/css" />
            
</asp:Content>

<asp:Content ID="dbaasoptioncont" runat="server" ContentPlaceHolderID="ChildContent">

    <Style>
    input[type=date]::-webkit-inner-spin-button {
        -webkit-appearance: none;
         display: none;
         }

    input[type=time]::-webkit-inner-spin-button {
        -webkit-appearance: none;
         display: none;
         }
    </style>

    <table style="width: 100%;" class="tablestyle">
        <tr style="align-items:center">
            <td class="tabletd" colspan="2">
                <asp:label ID="label1" runat="server" CssClass="pagetitle" Text="Backup Request"></asp:label><br /><br /><br /><br />
            </td>
        </tr >
        <tr >
            <td class="formtabletdlabel">
                <asp:label ID="lblServers" runat="server" CssClass="formlabel" Text="SQL Server" ></asp:label>
            </td>
            <td class="formtabletdfield">
                <asp:DropDownList ID="ddServers" runat="server" CssClass="dropdown" OnSelectedIndexChanged="ddServer_OnSelectionChange" AutoPostBack="true" ViewStateMode="Enabled" EnableViewState="true"></asp:DropDownList>
            </td>
        </tr>
        <tr >
            <td class="formtabletdlabel">
                <asp:label ID="lblDatabases" runat="server" CssClass="formlabel" Text="Database" ></asp:label>
            </td>
            <td class="formtabletdfield">
                <asp:DropDownList ID="ddDatabases" runat="server" CssClass="dropdown" >
                </asp:DropDownList>
            </td>
            
        </tr>
        

        <tr >
            <td class="formtabletdlabel">
                
            </td>
            <td class="formtabletdfield">
                <asp:CheckBox ID="chkByPassSecurity" Text="By Pass Dual Authentication" runat="server" CssClass="dropdown" OnCheckedChanged="OnCheckByPassSecurity" AutoPostBack="true"  >
                </asp:CheckBox>
            </td>            
        </tr>

        <tr >
            <td class="formtabletdlabel">
                <asp:label ID="Label3" runat="server" CssClass="formlabel" Text="SQL User Name" ></asp:label>
            </td>
            <td class="formtabletdfield">
                <asp:TextBox ID="txtusername" runat="server" CssClass="dropdown" ></asp:TextBox>
            </td>
        <tr >
            <td class="formtabletdlabel">
                <asp:label ID="lblDBSize" runat="server" CssClass="formlabel" Text="SQL Password" ></asp:label>
            </td>
            <td class="formtabletdfield">
                <asp:TextBox ID="txtpassword" runat="server" CssClass="dropdown" TextMode="Password" >
                </asp:TextBox>
            </td>
            
        </tr>

        <tr >
            <td class="formtabletdlabel">
                <asp:label ID="lblBackupScheduleDateTime" runat="server" CssClass="formlabel" Text="Schedule" ></asp:label>
            </td>
            <td class="formtabletdfield">
                
                <asp:TextBox ID="txtDate" runat="server" TextMode="Date" CssClass="dropdown"   AutoPostBack="true"    />

                <asp:TextBox ID="txtTime" runat="server" TextMode="Time" CssClass="dropdown"  AutoPostBack="true" /><br />
                <asp:Label ID="LblTimeZone" runat="server" CssClass="label" />
            </td>
        </tr>
        <tr>
        
            
        </tr>
        
        <tr>
            <td colspan="2" >
                <asp:Button class="button" Text="Submit Backup Request" runat="server" OnClick="onClickSubmit" />
            </td>
        </tr>
        <tr >
            <asp:RequiredFieldValidator ID="txtDateReq" ControlToValidate="txtDate" runat="server" ErrorMessage="Please Enter Valid Date"></asp:RequiredFieldValidator>    <br />
            <asp:RequiredFieldValidator ID="txtTimeReq" ControlToValidate="txtTime" runat="server" ErrorMessage="Please Enter Valid Time"></asp:RequiredFieldValidator> <br />   
            <asp:RequiredFieldValidator ID="ddlServersReq" ControlToValidate="ddServers" runat="server" ErrorMessage="Please Select Server" />

            <asp:RequiredFieldValidator ID="ddDatabasesReq" ControlToValidate="ddDatabases" runat="server" ErrorMessage="Please Select Database" />
        </tr>
    </table>
</asp:content>

