<%@ page language="java" import="java.util.*,com.jaguar.*,java.sql.*,project.*" pageEncoding="GBK"%>
 <%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
 <%@ include file="init.jsp" %>
<%
	WebEnum webenum = new WebEnum(jdb);
//	jdbapp = new JDBApp(jdb, user, webenum);
//	if (!user.GetDataRight(12,1,"",0,""))
//	{
//		out.println("您没有权限执行此操作，请与管理员联系");
//		out.close();
//	}
		String MoreButton = "";
		String TableName = WebChar.requestStr(request, "TableName");
		String FieldName = WebChar.requestStr(request, "FieldName");
		int nPage = WebChar.RequestInt(request, "nPage");
		if (nPage == 0)
			nPage = 1;
		out.println(WebFace.GetHTMLHead(TagMethod.getLang(request.getLocale(),"selefield.Select_tablblist")));
		out.println("<body leftmargin=0 topmargin=0 scroll=no>");
		out.println("<DIV id=ListDiv style=height:420;overflow=auto>" +
			"<table id=HistTable cellpadding=3 cellspacing=0 width=100% border=0>");

		String sql = "select DISTINCT " + FieldName + " from " + TableName;
		ResultSet rs = jdb.rsSQL(0, sql);
		int nPageSize = 40;
		try 
		{
			rs.last();
			int TotalRec = rs.getRow();
			rs.beforeFirst();
			if (TotalRec > 0) 
			{
				rs.absolute((nPage - 1) * nPageSize + 1);
				for (int x = 0; x < nPageSize; x++) 
				{
					out.println("<tr bgcolor=white onclick=SelObject(this) ondblclick=ConfirmFieldDlg()>"
						+ "<TD>" + rs.getString(FieldName) + "</TD></TR>");
					if (rs.next()) 
					{
					}
					else 
					{
						break;
					}
				}
			}
			else
				out.println("<tr bgcolor=white><TD>"+TagMethod.getLang(request.getLocale(),"selefield.Ziduan_noselect")+"</TD></TR>");

			if (nPage > 1)
			{
				out.println("</table></div><script language=javascript>parent.PageReady()</script></body></html>");
				return;
			}

			int Pages = (TotalRec + nPageSize - 1) / nPageSize;

			if (Pages > 1)
				MoreButton = "<input name=MoreButton type=button onclick=MoreData(this) value="+TagMethod.getLang(request.getLocale(),"selefield.Many")+" Pages="
				+ Pages + " nPage=" + nPage + "> &nbsp;";
			else
				MoreButton = "";

			out.println("</table></div>");

		}
		catch (Exception e)
		{
		}
		jdb.closeDBCon();
	%>
	<IFRAME id=DataFrame style=display:none;width:100%;height:20;></IFRAME>
	<BR>
	<CENTER>
		<%=MoreButton%>
		
		<input type=Button value="<j:Lang key="psub.Queding"/>" onclick=ConfirmFieldDlg()>
		&nbsp;
		<input type=button value="<j:Lang key="psub.cancel"/>" onclick="if(IsNetBoxRunning())external.close();else window.close();">
		&nbsp;
	</CENTER>
	<script language=javascript src=psub.jsp></script>
	<SCRIPT LANGUAGE="JavaScript">

function ConfirmFieldDlg()
{
	if (typeof(oFocus) == "object")
	{
		returnValue=oFocus.innerText;
		// w3c lxt 2017.12.26
		if(navigator.userAgent.indexOf("Chrome")>-1){
			window.localStorage["crmSelectDialogRValue"]=returnValue;
		}
		
		if(IsNetBoxRunning()){
			external.EndDialog(oFocus.innerText);
		}
		else window.close();
	}
	else
		alert("<j:Lang key="SeleQuoteTabEx.No_select"/>");
}

function MoreData(obj)
{
	obj.nPage = parseInt(obj.nPage) + 1;
	document.all.DataFrame.src = location.href + "&nPage=" + obj.nPage;
	obj.disabled = true;
	if (obj.nPage > obj.Pages)
		obj.style.display = "none";
}

function PageReady()
{
	document.all.MoreButton.disabled = false;
	document.all.ListDiv.lastChild.insertAdjacentHTML("afterEnd", 
		document.all.DataFrame.contentWindow.document.all.HistTable.outerHTML);
	document.all.ListDiv.style.position = "absolute";
	document.all.ListDiv.scrollIntoView(true);
	document.all.ListDiv.style.position = "";
}
</SCRIPT>
<%="</BODY></HTML>" %>