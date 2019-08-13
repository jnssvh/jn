<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_comName="", rs_comAddress="", rs_industryType="", rs_phoneNo="", rs_legalMan="", rs_official="", rs_tag1="", rs_tag2="", rs_note="";
String strTable = "company";
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
	String FormTitle = "企业简况";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "企业简况";
		String ex = "";
		out.print("{title: \"" +  Title + "\", nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"企业名称\", EName:\"comName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:150, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"企业地址\", EName:\"comAddress\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属行业\", EName:\"industryType\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"电话\", EName:\"phoneNo\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"法人\", EName:\"legalMan\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"专管员\", EName:\"official\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"人才类型\", EName:\"tag1\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"入选批次\", EName:\"tag2\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"备注\", EName:\"note\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='company_form_brief'"));
	String FormBar = FormTitle;
	int FormSaveFlag = WebChar.ToInt(request.getParameter("FormSaveFlag"));
	if (FormSaveFlag == 1)
	{
		if (WebChar.RequestInt(request, "I_DeleteFlag") == 1)
		{
			int result = 0;
			sql = "delete from company where ID=" + jdb.GetFieldTypeValueEx(DataID, 5, 0);
			result = jdb.ExecuteSQL(0, sql);
		 	SystemLog.setLog(jdb, user, request, "6", "", "company", DataID);
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
			result = jdb.ExecuteSQL(0, "delete from company where ID in (" + DeleteIDs + ")");
			SystemLog.setLog(jdb, user, request, "6", "", "company", DeleteIDs);
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
			rs_comName = WebChar.getFormValue(request, "comName", y);
			rs_comAddress = WebChar.getFormValue(request, "comAddress", y);
			rs_industryType = WebChar.getFormValue(request, "industryType", y);
			rs_phoneNo = WebChar.getFormValue(request, "phoneNo", y);
			rs_legalMan = WebChar.getFormValue(request, "legalMan", y);
			rs_official = WebChar.getFormValue(request, "official", y);
			rs_tag1 = WebChar.getFormValue(request, "tag1", y);
			rs_tag2 = WebChar.getFormValue(request, "tag2", y);
			rs_note = WebChar.getFormValue(request, "note", y);
			if ((LineDataID == null) || LineDataID.equals(""))
			{
				selsql = "select ID from company where " + jdb.GetFieldWhereClouse("comName", rs_comName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("comAddress", rs_comAddress, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("industryType", rs_industryType, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("phoneNo", rs_phoneNo, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("legalMan", rs_legalMan, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("official", rs_official, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("tag1", rs_tag1, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("tag2", rs_tag2, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("note", rs_note, 1, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into company(" + jdb.SQLField(0, "comName") + 
					"," + jdb.SQLField(0, "comAddress") + 
					"," + jdb.SQLField(0, "industryType") + 
					"," + jdb.SQLField(0, "phoneNo") + 
					"," + jdb.SQLField(0, "legalMan") + 
					"," + jdb.SQLField(0, "official") + 
					"," + jdb.SQLField(0, "tag1") + 
					"," + jdb.SQLField(0, "tag2") + 
					"," + jdb.SQLField(0, "note") + 
					") values (" + jdb.GetFieldTypeValueEx(rs_comName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_comAddress, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_industryType, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_phoneNo, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_legalMan, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_official, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_tag1, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_tag2, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_note, 1, 0) + 
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
			 	SystemLog.setLog(jdb, user, request, "4", "", "company", DataID);
			}
			else
			{
				sql = "update company set " + 
					jdb.SQLField(0, "comName") + "=" + jdb.GetFieldTypeValueEx(rs_comName, 1, 0) + ", " + 
					jdb.SQLField(0, "comAddress") + "=" + jdb.GetFieldTypeValueEx(rs_comAddress, 1, 0) + ", " + 
					jdb.SQLField(0, "industryType") + "=" + jdb.GetFieldTypeValueEx(rs_industryType, 3, 0) + ", " + 
					jdb.SQLField(0, "phoneNo") + "=" + jdb.GetFieldTypeValueEx(rs_phoneNo, 1, 0) + ", " + 
					jdb.SQLField(0, "legalMan") + "=" + jdb.GetFieldTypeValueEx(rs_legalMan, 1, 0) + ", " + 
					jdb.SQLField(0, "official") + "=" + jdb.GetFieldTypeValueEx(rs_official, 1, 0) + ", " + 
					jdb.SQLField(0, "tag1") + "=" + jdb.GetFieldTypeValueEx(rs_tag1, 1, 0) + ", " + 
					jdb.SQLField(0, "tag2") + "=" + jdb.GetFieldTypeValueEx(rs_tag2, 1, 0) + ", " + 
					jdb.SQLField(0, "note") + "=" + jdb.GetFieldTypeValueEx(rs_note, 1, 0) + " where ID=" + LineDataID;
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
	 			SystemLog.setLog(jdb, user, request, "5", "", "company", LineDataID);
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
		sql = "select * from company where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_comName = WebChar.getRSDefault(jdb.getRSString(0, rs, "comName"), "");
			rs_comAddress = WebChar.getRSDefault(jdb.getRSString(0, rs, "comAddress"), "");
			rs_industryType = WebChar.getRSDefault(jdb.getRSString(0, rs, "industryType"), "");
			rs_phoneNo = WebChar.getRSDefault(jdb.getRSString(0, rs, "phoneNo"), "");
			rs_legalMan = WebChar.getRSDefault(jdb.getRSString(0, rs, "legalMan"), "");
			rs_official = WebChar.getRSDefault(jdb.getRSString(0, rs, "official"), "");
			rs_tag1 = WebChar.getRSDefault(jdb.getRSString(0, rs, "tag1"), "");
			rs_tag2 = WebChar.getRSDefault(jdb.getRSString(0, rs, "tag2"), "");
			rs_note = WebChar.getRSDefault(jdb.getRSString(0, rs, "note"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	if (WebChar.RequestInt(request, "getrecord") == 1)
	{
		out.clear();
		String str = "";
		out.print("{comName:\"" + rs_comName + 
			"\",comAddress:\"" + rs_comAddress + 
			"\",industryType:\"" + rs_industryType + 
			"\",phoneNo:\"" + rs_phoneNo + 
			"\",legalMan:\"" + rs_legalMan + 
			"\",official:\"" + rs_official + 
			"\",tag1:\"" + rs_tag1 + 
			"\",tag2:\"" + rs_tag2 + 
			"\",note:\"" + WebChar.toJson(rs_note) + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "企业简况";
		String ex = "";
		out.print("{title: \"" +  Title + "\", nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"企业名称\", EName:\"comName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:150, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"企业地址\", EName:\"comAddress\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属行业\", EName:\"industryType\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"电话\", EName:\"phoneNo\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"法人\", EName:\"legalMan\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"专管员\", EName:\"official\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"人才类型\", EName:\"tag1\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"入选批次\", EName:\"tag2\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"备注\", EName:\"note\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		out.print("{comName:\"" + rs_comName + 
			"\",comAddress:\"" + rs_comAddress + 
			"\",industryType:\"" + rs_industryType + 
			"\",phoneNo:\"" + rs_phoneNo + 
			"\",legalMan:\"" + rs_legalMan + 
			"\",official:\"" + rs_official + 
			"\",tag1:\"" + rs_tag1 + 
			"\",tag2:\"" + rs_tag2 + 
			"\",note:\"" + WebChar.toJson(rs_note) + 
			"\"" + str + "}");
		out.print(", {" + 
			"DataID:\"" + DataID + 
			"\", FormAction:\"company_form_brief.jsp\", ExcelFormID:" + ExcelFormID + "}]");
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
	var fields = [{CName:"企业名称", EName:"comName", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:"", FieldType:1, FieldLen:150, Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"企业地址", EName:"comAddress", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"所属行业", EName:"industryType", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:""},
		{CName:"电话", EName:"phoneNo", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:20, Quote:"", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:""},
		{CName:"法人", EName:"legalMan", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:""},
		{CName:"专管员", EName:"official", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:""},
		{CName:"人才类型", EName:"tag1", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:""},
		{CName:"入选批次", EName:"tag2", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:""},
		{CName:"备注", EName:"note", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:9, nWidth:1, nHeight:4, Hint:""}];
	var record = {comName:"<%=WebChar.toJson(rs_comName)%>",
		comAddress:"<%=WebChar.toJson(rs_comAddress)%>",
		industryType:"<%=rs_industryType%>",
		phoneNo:"<%=WebChar.toJson(rs_phoneNo)%>",
		legalMan:"<%=WebChar.toJson(rs_legalMan)%>",
		official:"<%=WebChar.toJson(rs_official)%>",
		tag1:"<%=WebChar.toJson(rs_tag1)%>",
		tag2:"<%=WebChar.toJson(rs_tag2)%>",
		note:"<%=WebChar.toJson(rs_note)%>"};
	var ExcelFormID = <%=ExcelFormID%>;
	if (ExcelFormID > 0)
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"企业简况", spaninput:1, gridformid:ExcelFormID});
	else
	{
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"企业简况", formtype:2, nCols:1, ex:ex});
		form.appendHidden("I_DataID", "<%=DataID%>");
	}
//@@##:客户端载入时(归档用注释,切勿删改)

//(归档用注释,切勿删改) 客户端载入时 End##@@
}
</script></html>
