<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_chartName="", rs_Title="", rs_statPlanId="", rs_Note="", rs_chartType="", rs_nSerial="", rs_typeName="", rs_status="";
String strTable = "asStatChart";
String sql = "";
	int FormType = 2;
	String DataID = WebChar.requestStr(request, "DataID");
	int ModuleNo = WebChar.ToInt(request.getParameter("ModuleNo"));
	int Count = 1;
// +++++++++服务器全局页面启动代码开始++++++++
// ServerPageStartCode
if(request.getProtocol().compareTo("HTTP/1.0")==0)
	response.setHeader("Pragma","max-age=5");
if(request.getProtocol().compareTo("HTTP/1.1")==0)
	response.setHeader("Cache-Control","max-age=5");
response.setDateHeader("Expires",0);
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	WebUser user = new SysUser();

	if (user.initWebUser(jdb, cookie) != 1)
	{
		ServletContext sc = getServletContext();
		request.setAttribute("pagename", SysApp.scriptName(request));
		RequestDispatcher rd = sc.getRequestDispatcher("/com/error.jsp");
		rd.forward(request, response);
		out.clear();
		out = pageContext.pushBody();
		return;
	}

	WebEnum webenum = new WebEnum(jdb);
	SysApp sysApp = new SysApp(jdb);
	project.SystemLog sysLog = new project.SystemLog(jdb, user, request);
// --------服务器全局页面启动代码结束--------
	String FormTitle = "图表编辑";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "图表编辑";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:2, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"图表名称\", EName:\"chartName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"标题\", EName:\"Title\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属统计方案\", EName:\"statPlanId\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"说明\", EName:\"Note\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:3, Hint:\"\"}");
		out.print(",{CName:\"图形类型\", EName:\"chartType\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"顺序号\", EName:\"nSerial\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"分类名称\", EName:\"typeName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"状态\", EName:\"status\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='asStatChart_form'"));
	String FormBar = FormTitle;
	int FormSaveFlag = WebChar.ToInt(request.getParameter("FormSaveFlag"));
	if (FormSaveFlag == 1)
	{
		if (WebChar.RequestInt(request, "I_DeleteFlag") == 1)
		{
			int result = 0;
			sql = "delete from asStatChart where ID=" + jdb.GetFieldTypeValueEx(DataID, 5, 0);
			result = jdb.ExecuteSQL(0, sql);
		 	SystemLog.setLog(jdb, user, request, "6", "", "asStatChart", DataID);
			out.clear();
			if (result == 1)
			{
				out.print("OK");
			}
			else
				out.print("Error:" + result);
			if (WebChar.RequestInt(request, "bSilence") == 1)
				out.clear();
			jdb.closeDBCon();
			return;
		}
		String LineDataID, selsql = "", subsql = "";
		int result;
		ResultSet rs = null;
		String DeleteIDs = WebChar.requestStr(request, "DeleteIDs");
		ModuleNo = WebChar.ToInt(request.getParameter("I_ModuleNo"));
		DataID = request.getParameter("I_DataID");
		Count = WebChar.ToInt(request.getParameter("Count"));
		if (Count == 0)
			Count = 1;
		if (!DeleteIDs.equals(""))
		{
			result = jdb.ExecuteSQL(0, "delete from asStatChart where ID in (" + DeleteIDs + ")");
			SystemLog.setLog(jdb, user, request, "6", "", "asStatChart", DeleteIDs);
			if (Count == -1)
			{
				out.clear();
				if (result == 1)
					out.print("OK");
				else
					out.print("Error:" + result);
				if (WebChar.RequestInt(request, "bSilence") == 1)
					out.clear();
				jdb.closeDBCon();
				return;
			}
		}
		for (int y = 0; y < Count; y++)
		{
			boolean ret;
			if (Count == 1)
				LineDataID = DataID;
			else
				LineDataID = WebChar.RequestForms(request, "LineDataID", y);
			rs_chartName = WebChar.getFormValue(request, "chartName", y);
			rs_Title = WebChar.getFormValue(request, "Title", y);
			rs_statPlanId = WebChar.getFormValue(request, "statPlanId", y);
			rs_Note = WebChar.getFormValue(request, "Note", y);
			rs_chartType = WebChar.getFormValue(request, "chartType", y);
			rs_nSerial = WebChar.getFormValue(request, "nSerial", y);
			rs_typeName = WebChar.getFormValue(request, "typeName", y);
			rs_status = WebChar.getFormValue(request, "status", y);
			if ((LineDataID == null) || LineDataID.equals(""))
			{
				selsql = "select ID from asStatChart where " + jdb.GetFieldWhereClouse("chartName", rs_chartName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("Title", rs_Title, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("statPlanId", rs_statPlanId, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("Note", rs_Note, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("chartType", rs_chartType, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("nSerial", rs_nSerial, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("typeName", rs_typeName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("status", rs_status, 3, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into asStatChart(" + jdb.SQLField(0, "chartName") + 
					"," + jdb.SQLField(0, "Title") + 
					"," + jdb.SQLField(0, "statPlanId") + 
					"," + jdb.SQLField(0, "Note") + 
					"," + jdb.SQLField(0, "chartType") + 
					"," + jdb.SQLField(0, "nSerial") + 
					"," + jdb.SQLField(0, "typeName") + 
					"," + jdb.SQLField(0, "status") + 
					") values (" + jdb.GetFieldTypeValueEx(rs_chartName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Title, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_statPlanId, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Note, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_chartType, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_nSerial, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_typeName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_status, 3, 0) + 
					")";
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
				while (rs.next())
				{
					if (!subsql.equals(""))
						subsql += ",";
					subsql += rs.getString(1);
				}
				jdb.rsClose(0, rs);
				if (!subsql.equals(""))
					subsql = " and ID not in (" + subsql + ")";
				rs = jdb.rsSQL(0, selsql + subsql);
				if (rs == null || !rs.next())
				{
					out.println("未找到刚提交的记录，请检查数据库\\n" + sql);
					jdb.closeDBCon();
					return;
				}
				else
					LineDataID = rs.getString("ID");
				jdb.rsClose(0, rs);
			 	SystemLog.setLog(jdb, user, request, "4", "", "asStatChart", DataID);
			}
			else
			{
				sql = "update asStatChart set " + 
					jdb.SQLField(0, "chartName") + "=" + jdb.GetFieldTypeValueEx(rs_chartName, 1, 0) + ", " + 
					jdb.SQLField(0, "Title") + "=" + jdb.GetFieldTypeValueEx(rs_Title, 1, 0) + ", " + 
					jdb.SQLField(0, "statPlanId") + "=" + jdb.GetFieldTypeValueEx(rs_statPlanId, 3, 0) + ", " + 
					jdb.SQLField(0, "Note") + "=" + jdb.GetFieldTypeValueEx(rs_Note, 1, 0) + ", " + 
					jdb.SQLField(0, "chartType") + "=" + jdb.GetFieldTypeValueEx(rs_chartType, 3, 0) + ", " + 
					jdb.SQLField(0, "nSerial") + "=" + jdb.GetFieldTypeValueEx(rs_nSerial, 3, 0) + ", " + 
					jdb.SQLField(0, "typeName") + "=" + jdb.GetFieldTypeValueEx(rs_typeName, 1, 0) + ", " + 
					jdb.SQLField(0, "status") + "=" + jdb.GetFieldTypeValueEx(rs_status, 3, 0) + " where ID=" + LineDataID;
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
	 			SystemLog.setLog(jdb, user, request, "5", "", "asStatChart", LineDataID);
			}
			if (y == 0)
				DataID = LineDataID;
			else
				DataID += "," + LineDataID;
		}
			out.println("OK:" + DataID);
		jdb.closeDBCon();
		return;
	}
	int bAppend = 1;
	if (!(DataID.equals("") || DataID.equals("0")))
	{
		sql = "select * from asStatChart where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_chartName = WebChar.getRSDefault(jdb.getRSString(0, rs, "chartName"), "");
			rs_Title = WebChar.getRSDefault(jdb.getRSString(0, rs, "Title"), "");
			rs_statPlanId = WebChar.getRSDefault(jdb.getRSString(0, rs, "statPlanId"), "");
			rs_Note = WebChar.getRSDefault(jdb.getRSString(0, rs, "Note"), "");
			rs_chartType = WebChar.getRSDefault(jdb.getRSString(0, rs, "chartType"), "");
			rs_nSerial = WebChar.getRSDefault(jdb.getRSString(0, rs, "nSerial"), "");
			rs_typeName = WebChar.getRSDefault(jdb.getRSString(0, rs, "typeName"), "");
			rs_status = WebChar.getRSDefault(jdb.getRSString(0, rs, "status"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	if (WebChar.RequestInt(request, "getrecord") == 1)
	{
		out.clear();
		String str = "";
		out.print("{chartName:\"" + rs_chartName + 
			"\",Title:\"" + rs_Title + 
			"\",statPlanId:\"" + rs_statPlanId + 
			"\",Note:\"" + WebChar.toJson(rs_Note) + 
			"\",chartType:\"" + rs_chartType + 
			"\",nSerial:\"" + rs_nSerial + 
			"\",typeName:\"" + rs_typeName + 
			"\",status:\"" + rs_status + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "图表编辑";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:2, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"图表名称\", EName:\"chartName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"标题\", EName:\"Title\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属统计方案\", EName:\"statPlanId\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"说明\", EName:\"Note\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:3, Hint:\"\"}");
		out.print(",{CName:\"图形类型\", EName:\"chartType\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"顺序号\", EName:\"nSerial\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"分类名称\", EName:\"typeName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"状态\", EName:\"status\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		out.print("{chartName:\"" + rs_chartName + 
			"\",Title:\"" + rs_Title + 
			"\",statPlanId:\"" + rs_statPlanId + 
			"\",Note:\"" + WebChar.toJson(rs_Note) + 
			"\",chartType:\"" + rs_chartType + 
			"\",nSerial:\"" + rs_nSerial + 
			"\",typeName:\"" + rs_typeName + 
			"\",status:\"" + rs_status + 
			"\"" + str + "}");
		out.print(", {" + 
			"DataID:\"" + DataID + 
			"\", FormAction:\"asStatChart_form.jsp\", ExcelFormID:" + ExcelFormID + "}]");
		jdb.closeDBCon();
		return;
	}
	out.println(WebFace.GetHTMLHead(FormTitle, "<link rel='stylesheet' type='text/css' href='../forum.css'>"));
%>
<script language=javascript src=../comjquery.js></script>
<script language=javascript src=../comjcom.js></script>
<script language=javascript src=../comview.js></script>

<script language=javascript>
nDefaultWinMode = 5;
//FormFeatures = 'titlebar=0,toolbar=0,scrollbars=0,resizable=0,width=640,height=200,left=50,top=50';
</script><body scroll=no style='background:' alink=#333333 vlink=#333333 link=#333333 topmargin=0 leftmargin=0>
<div id=FormDiv style=overflow:auto;width:100%;height:100%;></div></body>
<script language=javascript>
window.onload = function ()
{
 var ex = "";
	var fields = [{CName:"图表名称", EName:"chartName", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"标题", EName:"Title", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"所属统计方案", EName:"statPlanId", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:""},
		{CName:"说明", EName:"Note", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:4, nWidth:1, nHeight:3, Hint:""},
		{CName:"图形类型", EName:"chartType", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:""},
		{CName:"顺序号", EName:"nSerial", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:""},
		{CName:"分类名称", EName:"typeName", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:""},
		{CName:"状态", EName:"status", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:""}];
	var record = {chartName:"<%=WebChar.toJson(rs_chartName)%>",
		Title:"<%=WebChar.toJson(rs_Title)%>",
		statPlanId:"<%=rs_statPlanId%>",
		Note:"<%=WebChar.toJson(rs_Note)%>",
		chartType:"<%=rs_chartType%>",
		nSerial:"<%=rs_nSerial%>",
		typeName:"<%=WebChar.toJson(rs_typeName)%>",
		status:"<%=rs_status%>"};
	var ExcelFormID = <%=ExcelFormID%>;
	if (ExcelFormID > 0)
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"图表编辑", spaninput:1, gridformid:ExcelFormID});
	else
	{
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"图表编辑", formtype:2, nCols:1, ex:ex});
		form.appendHidden("I_DataID", "<%=DataID%>");
	}
//@@##:客户端载入时(归档用注释,切勿删改)

//(归档用注释,切勿删改) 客户端载入时 End##@@
}
</script></html>
