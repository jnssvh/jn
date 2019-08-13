<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_GroupName="", rs_GroupNo="", rs_Leader="", rs_ParentId="", rs_Status="", rs_Members="", rs_OrderNo="";
String strTable = "WorkGroup";
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
	String FormTitle = "工作组管理";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "工作组管理";
		String ex = "";
		out.print("{title: \"" +  Title + "\", nCols:2, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"工作组名称\", EName:\"GroupName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"工作组编号\", EName:\"GroupNo\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:2, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"负责人\", EName:\"Leader\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"Member.CName\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属项目\", EName:\"ParentId\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"WorkGroup.ID,GroupName\", nCol:2, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"状态\", EName:\"Status\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"@GroupState\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"成员\", EName:\"Members\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"!select_user(this)\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:4, nWidth:2, nHeight:6, Hint:\"\"}");
		out.print(",{CName:\"顺序号\", EName:\"OrderNo\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:2, nRow:4, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='WorkGroup_form'"));
	String FormBar = FormTitle;
	String FlowInput = WebChar.getReqAttrib(request, "I_FlowInput");
	String FlowButton = WebChar.getReqAttrib(request, "I_FlowButton");
	String FlowAttach = WebChar.getReqAttrib(request, "I_FlowAttach");
	int RunMode = WebChar.ToInt(WebChar.getReqAttrib(request, "I_RunMode"));
	String FlowTitle = WebChar.getReqAttrib(request, "I_FlowTitle");
	String FlowBar = WebChar.getReqAttrib(request, "I_FlowBar");
	if (!FlowAttach.equals(""))
		FlowAttach = "<div id=FlowAttach>" + FlowAttach + "</div>";
	if (!FlowTitle.equals(""))
		FormTitle = FlowTitle + "(" + FormTitle + ")";
	if (FlowBar.equals(""))
		FormBar = "<div id=UserFormHeadDiv class=jformtitle1>&nbsp;&nbsp;" + FormTitle + "</div>";
	else
		FormBar = FlowBar;

//@@##437:后台载入时用户自定义代码(归档用注释,切勿删改)
out.println("<script type=text/javascript src=../js/jaguar.js></script>");
//(归档用注释,切勿删改)后台载入时用户自定义代码 End##@@
	int FormSaveFlag = WebChar.ToInt(request.getParameter("FormSaveFlag"));
	if (FormSaveFlag == 1)
	{
		if (WebChar.RequestInt(request, "I_DeleteFlag") == 1)
		{
			int result = 0;
			sql = "delete from WorkGroup where ID=" + jdb.GetFieldTypeValueEx(DataID, 5, 0);
			result = jdb.ExecuteSQL(0, sql);
		 	SystemLog.setLog(jdb, user, request, "6", "", "WorkGroup", DataID);
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
		if (WebChar.RequestInt(request, "FlowNodeRun") == 1)
		{
			out.clear();
			jdb.closeDBCon();
			return;
		}
		int StepID = WebChar.ToInt(WebChar.getFormValue(request, "I_StepID"));
		if (StepID > 0)
		{
			int Status = WebChar.ToInt(jdb.GetTableValue(0, "FlowData", "Status", "ID", "" + StepID));
			if ((Status != 1) && (Status != 11))
			{
				out.println("不能多次流转，因为流转活动已完成。");
				jdb.closeDBCon();
				return;
			}
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
			result = jdb.ExecuteSQL(0, "delete from WorkGroup where ID in (" + DeleteIDs + ")");
			SystemLog.setLog(jdb, user, request, "6", "", "WorkGroup", DeleteIDs);
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
			rs_GroupName = WebChar.getFormValue(request, "GroupName", y);
			rs_GroupNo = WebChar.getFormValue(request, "GroupNo", y);
			rs_Leader = WebChar.getFormValue(request, "Leader", y);
			rs_ParentId = WebChar.getFormValue(request, "ParentId", y);
			rs_Status = WebChar.getFormValue(request, "Status", y);
			rs_Members = WebChar.getFormValue(request, "Members", y);
			rs_OrderNo = WebChar.getFormValue(request, "OrderNo", y);
			if ((LineDataID == null) || LineDataID.equals(""))
			{
				ret = jdb.CheckUniqueValue(0, "WorkGroup", "GroupName", 1, rs_GroupName, DataID);
				if (ret == false)
				{
					out.println("提交失败。请检查提交数据是否正确。\\n错误为：工作组名称(GroupName)字段填写的内容:" + rs_GroupName + ",\\n违反唯一性规定。");
					jdb.closeDBCon();
					return;
				}
				ret = jdb.CheckUniqueValue(0, "WorkGroup", "GroupNo", 3, rs_GroupNo, DataID);
				if (ret == false)
				{
					out.println("提交失败。请检查提交数据是否正确。\\n错误为：工作组编号(GroupNo)字段填写的内容:" + rs_GroupNo + ",\\n违反唯一性规定。");
					jdb.closeDBCon();
					return;
				}
				selsql = "select ID from WorkGroup where " + jdb.GetFieldWhereClouse("GroupName", rs_GroupName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("GroupNo", rs_GroupNo, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("Leader", rs_Leader, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("ParentId", rs_ParentId, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("Status", rs_Status, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("OrderNo", rs_OrderNo, 3, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into WorkGroup(" + jdb.SQLField(0, "GroupName") + 
					"," + jdb.SQLField(0, "GroupNo") + 
					"," + jdb.SQLField(0, "Leader") + 
					"," + jdb.SQLField(0, "ParentId") + 
					"," + jdb.SQLField(0, "Status") + 
					"," + jdb.SQLField(0, "Members") + 
					"," + jdb.SQLField(0, "OrderNo") + 
					") values (" + jdb.GetFieldTypeValueEx(rs_GroupName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_GroupNo, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Leader, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_ParentId, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Status, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Members, 2, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_OrderNo, 3, 0) + 
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
			 	SystemLog.setLog(jdb, user, request, "4", "", "WorkGroup", DataID);
			}
			else
			{
				ret = jdb.CheckUniqueValue(0, "WorkGroup", "GroupName", 1, rs_GroupName, LineDataID);
				if (ret == false)
				{
					out.println("提交失败。请检查提交数据是否正确。\\n错误为：工作组名称(GroupName)字段填写的内容:" + rs_GroupName + ",\\n违反唯一性规定。')");
					jdb.closeDBCon();
					return;
				}
				ret = jdb.CheckUniqueValue(0, "WorkGroup", "GroupNo", 3, rs_GroupNo, LineDataID);
				if (ret == false)
				{
					out.println("提交失败。请检查提交数据是否正确。\\n错误为：工作组编号(GroupNo)字段填写的内容:" + rs_GroupNo + ",\\n违反唯一性规定。')");
					jdb.closeDBCon();
					return;
				}
				sql = "update WorkGroup set " + 
					jdb.SQLField(0, "GroupName") + "=" + jdb.GetFieldTypeValueEx(rs_GroupName, 1, 0) + ", " + 
					jdb.SQLField(0, "GroupNo") + "=" + jdb.GetFieldTypeValueEx(rs_GroupNo, 3, 0) + ", " + 
					jdb.SQLField(0, "Leader") + "=" + jdb.GetFieldTypeValueEx(rs_Leader, 1, 0) + ", " + 
					jdb.SQLField(0, "ParentId") + "=" + jdb.GetFieldTypeValueEx(rs_ParentId, 3, 0) + ", " + 
					jdb.SQLField(0, "Status") + "=" + jdb.GetFieldTypeValueEx(rs_Status, 3, 0) + ", " + 
					jdb.SQLField(0, "Members") + "=" + jdb.GetFieldTypeValueEx(rs_Members, 2, 0) + ", " + 
					jdb.SQLField(0, "OrderNo") + "=" + jdb.GetFieldTypeValueEx(rs_OrderNo, 3, 0) + " where ID=" + LineDataID;
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
	 			SystemLog.setLog(jdb, user, request, "5", "", "WorkGroup", LineDataID);
			}
			if (y == 0)
				DataID = LineDataID;
			else
				DataID += "," + LineDataID;
		}
//@@##448:后台提交时(内容改变后)用户自定义代码开始(归档用注释,切勿删改)
com.jaguar.event.EventSourceElement.notifyEvent("EditWorkGroup", jdb, DataID);
//(归档用注释,切勿删改)后台提交时(内容改变后)用户自定义代码 End##@@
		String FlowName = WebChar.requestStr(request, "I_FlowName");
		if (!FlowName.equals(""))
		{
			request.setAttribute("I_DataID", DataID);
			request.setAttribute("I_TagField", rs_GroupName);
			request.getRequestDispatcher(FlowName + ".jsp").forward(request, response);
			jdb.closeDBCon();
			return;
		}
			out.println("OK:" + DataID);
		jdb.closeDBCon();
		return;
	}
	int bAppend = 1;
	if (!(DataID.equals("") || DataID.equals("0")))
	{
		sql = "select * from WorkGroup where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_GroupName = WebChar.getRSDefault(jdb.getRSString(0, rs, "GroupName"), "");
			rs_GroupNo = WebChar.getRSDefault(jdb.getRSString(0, rs, "GroupNo"), "");
			rs_Leader = WebChar.getRSDefault(jdb.getRSString(0, rs, "Leader"), "");
			rs_ParentId = WebChar.getRSDefault(jdb.getRSString(0, rs, "ParentId"), "");
			rs_Status = WebChar.getRSDefault(jdb.getRSString(0, rs, "Status"), "");
			rs_Members = WebChar.getRSDefault(jdb.readClob(rs.getClob("Members")), "");
			rs_OrderNo = WebChar.getRSDefault(jdb.getRSString(0, rs, "OrderNo"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	rs_GroupNo = WebChar.getRSDefault(rs_GroupNo, jdb.getMaxFieldValue("WorkGroup", "GroupNo") + "");
	rs_ParentId = WebChar.getRSDefault(rs_ParentId, WebChar.RequestInt(request, "parent_id")+"");
	rs_Status = WebChar.getRSDefault(rs_Status, "1");
	rs_OrderNo = WebChar.getRSDefault(rs_OrderNo, "0");
	if (WebChar.RequestInt(request, "getrecord") == 1)
	{
		out.clear();
		String str = "";
		str +=", Leader_ex:\"" + jdb.GetQuoteValue("Member",0, "CName", "CName", rs_Leader) + "\"";
		str +=", ParentId_ex:\"" + jdb.GetQuoteValue("WorkGroup",0, "ID", "GroupName", rs_ParentId) + "\"";
		str += ", Status_ex:\"" + WebChar.isString(webenum.GetEnumDataString("GroupState", rs_Status), !rs_Status.equals("")) + "\"";
		out.print("{GroupName:\"" + rs_GroupName + 
			"\",GroupNo:\"" + rs_GroupNo + 
			"\",Leader:\"" + rs_Leader + 
			"\",ParentId:\"" + rs_ParentId + 
			"\",Status:\"" + rs_Status + 
			"\",Members:\"" + WebChar.toJson(rs_Members) + 
			"\",OrderNo:\"" + rs_OrderNo + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "工作组管理";
		String ex = "";
		out.print("{title: \"" +  Title + "\", nCols:2, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"工作组名称\", EName:\"GroupName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"工作组编号\", EName:\"GroupNo\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:2, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"负责人\", EName:\"Leader\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"Member.CName\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属项目\", EName:\"ParentId\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"WorkGroup.ID,GroupName\", nCol:2, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"状态\", EName:\"Status\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"@GroupState\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"成员\", EName:\"Members\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"!select_user(this)\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:4, nWidth:2, nHeight:6, Hint:\"\"}");
		out.print(",{CName:\"顺序号\", EName:\"OrderNo\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:2, nRow:4, nWidth:0, nHeight:1, Hint:\"\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		str +=", Leader_ex:\"" + jdb.GetQuoteValue("Member",0, "CName", "CName", rs_Leader) + "\"";
		str +=", ParentId_ex:\"" + jdb.GetQuoteValue("WorkGroup",0, "ID", "GroupName", rs_ParentId) + "\"";
		str += ", Status_ex:\"" + WebChar.isString(webenum.GetEnumDataString("GroupState", rs_Status), !rs_Status.equals("")) + "\"";
		out.print("{GroupName:\"" + rs_GroupName + 
			"\",GroupNo:\"" + rs_GroupNo + 
			"\",Leader:\"" + rs_Leader + 
			"\",ParentId:\"" + rs_ParentId + 
			"\",Status:\"" + rs_Status + 
			"\",Members:\"" + WebChar.toJson(rs_Members) + 
			"\",OrderNo:\"" + rs_OrderNo + 
			"\"" + str + "}");
		out.print(", {FlowInput:\"" + WebChar.toJson(FlowInput) +
			"\", FlowButton:\"" + WebChar.toJson(FlowButton) + 
			"\", FlowTitle:\"" + FlowTitle + 
			"\", FlowAttach:\"" + WebChar.toJson(FlowAttach) + "\", " +
			"DataID:\"" + DataID + 
			"\", FormAction:\"WorkGroup_form.jsp\", ExcelFormID:" + ExcelFormID + "}]");
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
<%
	String Title;
	Title = "null";
%>
 var ex = "";
	var fields = [{CName:"工作组名称", EName:"GroupName", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"工作组编号", EName:"GroupNo", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:2, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"负责人", EName:"Leader", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:20, Quote:"Member.CName", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"所属项目", EName:"ParentId", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"WorkGroup.ID,GroupName", nCol:2, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"状态", EName:"Status", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:"", FieldType:3, FieldLen:4, Quote:"@GroupState", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:""},
		{CName:"成员", EName:"Members", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"!select_user(this)", FieldType:2, FieldLen:536870910, Quote:"", nCol:1, nRow:4, nWidth:2, nHeight:6, Hint:", change: ChangeObj6923"},
		{CName:"顺序号", EName:"OrderNo", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:2, nRow:4, nWidth:0, nHeight:1, Hint:""}];
	var record = {GroupName:"<%=WebChar.toJson(rs_GroupName)%>",
		GroupNo:"<%=rs_GroupNo%>",
		Leader:"<%=WebChar.toJson(rs_Leader)%>",
		ParentId:"<%=rs_ParentId%>",
		Status:"<%=rs_Status%>",
		Members:"<%=WebChar.toJson(rs_Members)%>",
		OrderNo:"<%=rs_OrderNo%>"};
	var ExcelFormID = <%=ExcelFormID%>;
	if (ExcelFormID > 0)
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"<%=Title%>", spaninput:1, gridformid:ExcelFormID});
	else
	{
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"<%=Title%>", formtype:2, nCols:2, ex:ex});
		form.appendHidden("I_DataID", "<%=DataID%>");
	}
//@@##388:客户端载入时(归档用注释,切勿删改)
//var txt=document.getElementsByName("Members")[0];
//txt.onclick=function(){document.body.focus();};

var obj = {instanceName:"Alias_Leader1", url:"../AjaxFunction?type=getDynamicTip&sub_type=DynamicTip_WorkGroup_Leader"};
AjaxGetData.init(obj);
obj = {instanceName:"Alias_ParentId1", url:"../AjaxFunction?type=getDynamicTip&sub_type=DynamicTip_WorkGroup_ParentId&groupid=project.system.WorkGroupParentIdTip"};
AjaxGetData.init(obj);
//(归档用注释,切勿删改) 客户端载入时 End##@@
}
function ChangeObj6923(obj)
{
//@@##441:客户端交互时(onchange)(归档用注释,切勿删改)
if ( /\s/.test(obj.value) ) {
    obj.value = obj.value.replace(/\s+/g, "");
}
//(归档用注释,切勿删改) 客户端交互时(onchange) End##@@
}

//@@##387:客户端自定义脚本(归档用注释,切勿删改)
function select_user(obj)
{

  var user = SelectDialog(0, "../selmember.jsp","dialogWidth:640px;dialogHeight:500px;scroll:yes", document.getElementsByName("Members")[0].value);
  if(user == undefined || user == "")
    return;
  user = user.replace("@,@", ",");
  user = user.replace(/^ +| +$|/g, "");
  user = user.replace(/ *, +| +, */g, ",");
  var arr = user.split(/,/);
  arr.sort(function(a,b){return a.localeCompare(b)});
  user = arr.join(",");
  document.getElementsByName("Members")[0].value = user;
}
//(归档用注释,切勿删改) 客户端载入时 End##@@
</script></html>
