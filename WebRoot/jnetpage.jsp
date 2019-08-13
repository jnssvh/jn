<%@ page language="java" import="java.sql.* ,com.jaguar.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%!
String GetPageItem(String name, String click, String auth_no)
{
String img = "", exstr = "", roll = "";
	if ( click.length() > 0 )
		roll = roll + " onclick=\"" + WebChar.apostrophe(click) + "\"";
	return "<span id=PageSpan class=page onclick=\"" + click + "\" ModuleNo=" 
		+ auth_no + ">" + name + "</span>";
}


%>
<%@ include file="com/init.jsp" %>
<%
String auth_no = WebChar.RequestInt(request, "ModuleNo") + "";
String auth_name = jdb.GetTableValue("rightobject", "auth_name", "auth_no", auth_no);
String ModuleID = jdb.GetTableValue("rightobject", "auth_id", "auth_no", auth_no);
out.print(WebFace.GetHTMLHead("¼´ÍøÍ¨", "<link rel='stylesheet' type='text/css' href='com/forum.css'>"));
%>
<body style='background:#C1C2BD' alink=#333333 vlink=#333333 link=#333333 topmargin=1 leftmargin=0>
<%
String sql = "";
ResultSet rs = null;
sql = "select * from rightobject where parent_node=" + ModuleID + " and auth_show=1 order by auth_order, auth_no";
rs = jdb.rsSQL(0, sql );
int Pages = 0;
String PageSpan = "";
while (rs.next())
{
	//if (GetGroupsRight(MemberGroupIDs, rs("auth_no")))
	{
		PageSpan = PageSpan + GetPageItem(rs.getString("auth_name"), rs.getString("auth_url"), rs.getString("auth_no"));
		Pages = Pages + 1;
	}
}
jdb.rsClose(0, rs);
out.print("<div nowrap id=JNetPropTag style='height:20px;width:" + Pages * 75 + "px;'>" + PageSpan + "</div>");
%>
<div id=pageline class=pagediv style=width:100%;padding-top:2px;background-color:white;>
<iframe id=WorkFrame SCROLLING=no FRAMEBORDER=0 style="width:100%;height:200;">
</iframe></div>
</BODY>
<script language=javascript src="com/psub.jsp"></script>
<script language=javascript>
function window.onload()
{
	var objs = document.getElementsByName("PageSpan");
	objs[0].click();
	window.onresize = ResizeWin;
	ResizeWin();
}

function ResizeWin()
{
	document.all.WorkFrame.style.height = document.body.clientHeight - 22;
}

var oSelectedPage;
function SelectPage(obj, url)
{
	if (typeof(oSelectedPage) == "object")
		oSelectedPage.className = "page";
	oSelectedPage = obj;

	oSelectedPage.className = "page selected";
	document.all.WorkFrame.src = AppendURLParam(url, "ModuleNo=" + obj.ModuleNo);
}
</script>
</HTML>
<%jdb.closeDBCon(); %>