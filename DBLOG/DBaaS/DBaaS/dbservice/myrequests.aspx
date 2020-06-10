<%@ Page Language="C#" MasterPageFile="~/DBLOG.Master"  AutoEventWireup="true" CodeBehind="myrequests.aspx.cs" Inherits="DBaaS.dbservice.myrequests" %>


<asp:Content ID="dbassopentionhc" runat="server" ContentPlaceHolderID="ParentContent">
            <link href="/dblog3/css/dbaas.css" rel="stylesheet" type="text/css" />
            
</asp:Content>



<asp:Content ID="dbaasoptioncont" runat="server" ContentPlaceHolderID="ChildContent">


    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
<script type="text/javascript">
    $("[src*=plus]").live("click", function () {
        $(this).closest("tr").after("<tr><td></td><td colspan = '999'>" + $(this).next().html() + "</td></tr>")
        $(this).attr("src", "/dblog3/images/minus.png");
        
    });
    $("[src*=minus]").live("click", function () {
        $(this).attr("src", "/dblog3/images/plus.png");
        $(this).closest("tr").next().remove();
    });
</script>



    
    <div runat="server" class="center-div">
        <asp:GridView ID="grdBackupRequests" runat="server" Caption="Backup Requests" CssClass="gridview" AllowSorting="True" 
              AlternatingRowStyle-CssClass="alternating" 
              SortedAscendingHeaderStyle-CssClass="sortedasc" 
              SortedDescendingHeaderStyle-CssClass="sorteddesc" 
              FooterStyle-CssClass="footer" DataKeyNames = "RequestID" OnRowDataBound="populateLogs">
              <AlternatingRowStyle CssClass="alternating"></AlternatingRowStyle>

            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <img alt = "" style="cursor: pointer" src="/dblog3/images/plus.png" />
                        <asp:Panel ID="pnlLogs"  runat="server" Style="display: none">
                            <asp:GridView ID="grdRequestLogs" runat="server" CssClass="subgridview">
                                <Columns></Columns>
                            </asp:GridView>
                        </asp:Panel>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
