<%@ Page Language="C#" MasterPageFile="~/DBLOG.Master"  AutoEventWireup="true" CodeBehind="selection.aspx.cs" Inherits="DBaaS.selection" %>


<asp:Content ID="hc" runat="server" ContentPlaceHolderID="ParentContent">
    <link href="/dblog3/css/dbaas.css" rel="stylesheet" type="text/css" />
    
</asp:Content>



<asp:Content ID="selectioncont" runat="server" ContentPlaceHolderID="ChildContent">
    
    <div id="divselection" runat="server" class="center-div" >
        <asp:Table ID="Table1" runat="server" CssClass="tablestyle" HorizontalAlign="Center" BorderColor="#666666">
            <asp:TableHeaderRow HorizontalAlign="Center" CssClass="textcolor">
                <asp:TableCell ColumnSpan="2">Please select the module to enter</asp:TableCell>
            </asp:TableHeaderRow>
            <asp:TableRow>
                <asp:TableCell>
                    <asp:Button ID="btndbaas" runat="server" Text="DBaaS (Database as a Service)" CssClass="button" OnClick="btnDBaasClick"/>
                </asp:TableCell>
             </asp:tablerow>
            <asp:TableRow>
                <asp:TableCell>
                    <asp:Button ID="btnDCU" runat="server" Text="DCU (Database Configuration Utlity)" CssClass="button" />
                </asp:TableCell>
            </asp:TableRow>
            
        </asp:Table>
    </div>
</asp:Content>