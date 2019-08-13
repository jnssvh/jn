<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_BaseId="", rs_cName="", rs_eName="", rs_info="", rs_createMan="", rs_createTime="", rs_modifyMan="", rs_modifyTime="";
String strTable = "asSysMain";
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
	String FormTitle = "评估体系模板";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "评估体系模板";
		String ex = "";
		out.print("{title: \"" +  Title + "\", nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"基础模板\", EName:\"BaseId\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysMain.ID,cName\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"模板名称\", EName:\"cName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"英文名称\", EName:\"eName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"说明\", EName:\"info\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:3, Hint:\"\"}");
		out.print(",{CName:\"创建人\", EName:\"createMan\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:2, nRow:5, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"创建时间\", EName:\"createTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:3, nRow:5, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"最后修改人\", EName:\"modifyMan\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:4, nRow:5, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"最后修改时间\", EName:\"modifyTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:5, nRow:5, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='asSysMain_form'"));
	String FormBar = FormTitle;
	int FormSaveFlag = WebChar.ToInt(request.getParameter("FormSaveFlag"));
	if (FormSaveFlag == 1)
	{
		if (WebChar.RequestInt(request, "I_DeleteFlag") == 1)
		{
			int result = 0;
			sql = "delete from asSysMain where ID=" + jdb.GetFieldTypeValueEx(DataID, 5, 0);
			result = jdb.ExecuteSQL(0, sql);
		 	SystemLog.setLog(jdb, user, request, "6", "", "asSysMain", DataID);
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
			result = jdb.ExecuteSQL(0, "delete from asSysMain where ID in (" + DeleteIDs + ")");
			SystemLog.setLog(jdb, user, request, "6", "", "asSysMain", DeleteIDs);
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
			rs_BaseId = WebChar.getFormValue(request, "BaseId", y);
			rs_cName = WebChar.getFormValue(request, "cName", y);
			rs_eName = WebChar.getFormValue(request, "eName", y);
			rs_info = WebChar.getFormValue(request, "info", y);
			rs_createMan = WebChar.getFormValue(request, "createMan", y);
			rs_createTime = WebChar.getFormValue(request, "createTime", y);
			rs_modifyMan = WebChar.getFormValue(request, "modifyMan", y);
			rs_modifyTime = WebChar.getFormValue(request, "modifyTime", y);
			if ((LineDataID == null) || LineDataID.equals(""))
			{
				selsql = "select ID from asSysMain where " + jdb.GetFieldWhereClouse("BaseId", rs_BaseId, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("cName", rs_cName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("eName", rs_eName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("info", rs_info, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("createMan", rs_createMan, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("createTime", rs_createTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("modifyMan", rs_modifyMan, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("modifyTime", rs_modifyTime, 4, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into asSysMain(" + jdb.SQLField(0, "BaseId") + 
					"," + jdb.SQLField(0, "cName") + 
					"," + jdb.SQLField(0, "eName") + 
					"," + jdb.SQLField(0, "info") + 
					"," + jdb.SQLField(0, "createMan") + 
					"," + jdb.SQLField(0, "createTime") + 
					"," + jdb.SQLField(0, "modifyMan") + 
					"," + jdb.SQLField(0, "modifyTime") + 
					") values (" + jdb.GetFieldTypeValueEx(rs_BaseId, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_cName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_eName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_info, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_createMan, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_createTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_modifyMan, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_modifyTime, 4, 0) + 
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
			 	SystemLog.setLog(jdb, user, request, "4", "", "asSysMain", DataID);
			}
			else
			{
				sql = "update asSysMain set " + 
					jdb.SQLField(0, "BaseId") + "=" + jdb.GetFieldTypeValueEx(rs_BaseId, 3, 0) + ", " + 
					jdb.SQLField(0, "cName") + "=" + jdb.GetFieldTypeValueEx(rs_cName, 1, 0) + ", " + 
					jdb.SQLField(0, "eName") + "=" + jdb.GetFieldTypeValueEx(rs_eName, 1, 0) + ", " + 
					jdb.SQLField(0, "info") + "=" + jdb.GetFieldTypeValueEx(rs_info, 1, 0) + ", " + 
					jdb.SQLField(0, "createMan") + "=" + jdb.GetFieldTypeValueEx(rs_createMan, 1, 0) + ", " + 
					jdb.SQLField(0, "createTime") + "=" + jdb.GetFieldTypeValueEx(rs_createTime, 4, 0) + ", " + 
					jdb.SQLField(0, "modifyMan") + "=" + jdb.GetFieldTypeValueEx(rs_modifyMan, 1, 0) + ", " + 
					jdb.SQLField(0, "modifyTime") + "=" + jdb.GetFieldTypeValueEx(rs_modifyTime, 4, 0) + " where ID=" + LineDataID;
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
	 			SystemLog.setLog(jdb, user, request, "5", "", "asSysMain", LineDataID);
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
		sql = "select * from asSysMain where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_BaseId = WebChar.getRSDefault(jdb.getRSString(0, rs, "BaseId"), "");
			rs_cName = WebChar.getRSDefault(jdb.getRSString(0, rs, "cName"), "");
			rs_eName = WebChar.getRSDefault(jdb.getRSString(0, rs, "eName"), "");
			rs_info = WebChar.getRSDefault(jdb.getRSString(0, rs, "info"), "");
			rs_createMan = WebChar.getRSDefault(jdb.getRSString(0, rs, "createMan"), "");
			rs_createTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "createTime"), "");
			rs_modifyMan = WebChar.getRSDefault(jdb.getRSString(0, rs, "modifyMan"), "");
			rs_modifyTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "modifyTime"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	rs_createMan = WebChar.getRSDefault(rs_createMan, user.CMemberName);
	rs_createTime = WebChar.getRSDefault(rs_createTime, VB.Now());
	if (WebChar.RequestInt(request, "getrecord") == 1)
	{
		out.clear();
		String str = "";
		str +=", BaseId_ex:\"" + jdb.GetQuoteValue("asSysMain",0, "ID", "cName", rs_BaseId) + "\"";
		out.print("{BaseId:\"" + rs_BaseId + 
			"\",cName:\"" + rs_cName + 
			"\",eName:\"" + rs_eName + 
			"\",info:\"" + WebChar.toJson(rs_info) + 
			"\",createMan:\"" + rs_createMan + 
			"\",createTime:\"" + rs_createTime + 
			"\",modifyMan:\"" + rs_modifyMan + 
			"\",modifyTime:\"" + rs_modifyTime + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "评估体系模板";
		String ex = "";
		out.print("{title: \"" +  Title + "\", nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"基础模板\", EName:\"BaseId\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysMain.ID,cName\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"模板名称\", EName:\"cName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"英文名称\", EName:\"eName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"说明\", EName:\"info\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:3, Hint:\"\"}");
		out.print(",{CName:\"创建人\", EName:\"createMan\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:2, nRow:5, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"创建时间\", EName:\"createTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:3, nRow:5, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"最后修改人\", EName:\"modifyMan\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:4, nRow:5, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"最后修改时间\", EName:\"modifyTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:5, nRow:5, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		str +=", BaseId_ex:\"" + jdb.GetQuoteValue("asSysMain",0, "ID", "cName", rs_BaseId) + "\"";
		out.print("{BaseId:\"" + rs_BaseId + 
			"\",cName:\"" + rs_cName + 
			"\",eName:\"" + rs_eName + 
			"\",info:\"" + WebChar.toJson(rs_info) + 
			"\",createMan:\"" + rs_createMan + 
			"\",createTime:\"" + rs_createTime + 
			"\",modifyMan:\"" + rs_modifyMan + 
			"\",modifyTime:\"" + rs_modifyTime + 
			"\"" + str + "}");
		out.print(", {" + 
			"DataID:\"" + DataID + 
			"\", FormAction:\"asSysMain_form.jsp\", ExcelFormID:" + ExcelFormID + "}]");
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
	var fields = [{CName:"基础模板", EName:"BaseId", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"asSysMain.ID,cName", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"模板名称", EName:"cName", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"英文名称", EName:"eName", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:""},
		{CName:"说明", EName:"info", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:4, nWidth:1, nHeight:3, Hint:""},
		{CName:"创建人", EName:"createMan", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:20, Quote:"", nCol:2, nRow:5, nWidth:0, nHeight:1, Hint:""},
		{CName:"创建时间", EName:"createTime", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:4, FieldLen:8, Quote:"", nCol:3, nRow:5, nWidth:0, nHeight:1, Hint:""},
		{CName:"最后修改人", EName:"modifyMan", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:20, Quote:"", nCol:4, nRow:5, nWidth:0, nHeight:1, Hint:""},
		{CName:"最后修改时间", EName:"modifyTime", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:4, FieldLen:8, Quote:"", nCol:5, nRow:5, nWidth:0, nHeight:1, Hint:""}];
	var record = {BaseId:"<%=rs_BaseId%>",
		cName:"<%=WebChar.toJson(rs_cName)%>",
		eName:"<%=WebChar.toJson(rs_eName)%>",
		info:"<%=WebChar.toJson(rs_info)%>",
		createMan:"<%=WebChar.toJson(rs_createMan)%>",
		createTime:"<%=rs_createTime%>",
		modifyMan:"<%=WebChar.toJson(rs_modifyMan)%>",
		modifyTime:"<%=rs_modifyTime%>"};
	var ExcelFormID = <%=ExcelFormID%>;
	if (ExcelFormID > 0)
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"评估体系模板", spaninput:1, gridformid:ExcelFormID});
	else
	{
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"评估体系模板", formtype:2, nCols:1, ex:ex});
		form.appendHidden("I_DataID", "<%=DataID%>");
	}
//@@##:客户端载入时(归档用注释,切勿删改)

//(归档用注释,切勿删改) 客户端载入时 End##@@
}
</script></html>
