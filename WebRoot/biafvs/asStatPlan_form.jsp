<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_planName="", rs_beginTime="", rs_endTime="", rs_Info="", rs_scopeInfo="", rs_asSysMainId="", rs_sumRptName="", rs_comCount="", rs_answerCount="", rs_createMan="", rs_createTime="", rs_companys="";
String strTable = "asStatPlan";
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
	String FormTitle = "统计方案";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "统计方案";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:2, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"方案名称\", EName:\"planName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"开始时间\", EName:\"beginTime\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"结束时间\", EName:\"endTime\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"说明\", EName:\"Info\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print(",{CName:\"范围说明\", EName:\"scopeInfo\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"评估体系\", EName:\"asSysMainId\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysMain.ID,cName\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"汇总表名称\", EName:\"sumRptName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"企业总数\", EName:\"comCount\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"答卷总数\", EName:\"answerCount\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"创建人\", EName:\"createMan\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"创建时间\", EName:\"createTime\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:2\", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"$none\", EName:\"companys\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"*Object\", FieldType:1,FieldLen:3000, Quote:\"+company.ID,comName\", nCol:1, nRow:12, nWidth:1, nHeight:10, Hint:\"被统计企业\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='asStatPlan_form'"));
	String FormBar = FormTitle;
	int FormSaveFlag = WebChar.ToInt(request.getParameter("FormSaveFlag"));
	if (FormSaveFlag == 1)
	{
		if (WebChar.RequestInt(request, "I_DeleteFlag") == 1)
		{
			int result = 0;
			sql = "delete from asStatPlan where ID=" + jdb.GetFieldTypeValueEx(DataID, 5, 0);
			result = jdb.ExecuteSQL(0, sql);
		 	SystemLog.setLog(jdb, user, request, "6", "", "asStatPlan", DataID);
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
			result = jdb.ExecuteSQL(0, "delete from asStatPlan where ID in (" + DeleteIDs + ")");
			SystemLog.setLog(jdb, user, request, "6", "", "asStatPlan", DeleteIDs);
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
			rs_planName = WebChar.getFormValue(request, "planName", y);
			rs_beginTime = WebChar.getFormValue(request, "beginTime", y);
			rs_endTime = WebChar.getFormValue(request, "endTime", y);
			rs_Info = WebChar.getFormValue(request, "Info", y);
			rs_scopeInfo = WebChar.getFormValue(request, "scopeInfo", y);
			rs_asSysMainId = WebChar.getFormValue(request, "asSysMainId", y);
			rs_sumRptName = WebChar.getFormValue(request, "sumRptName", y);
			rs_comCount = WebChar.getFormValue(request, "comCount", y);
			rs_answerCount = WebChar.getFormValue(request, "answerCount", y);
			rs_createMan = WebChar.getFormValue(request, "createMan", y);
			rs_createTime = WebChar.getFormValue(request, "createTime", y);
			rs_companys = WebChar.getFormValue(request, "companys", y);
			if ((LineDataID == null) || LineDataID.equals(""))
			{
				selsql = "select ID from asStatPlan where " + jdb.GetFieldWhereClouse("planName", rs_planName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("beginTime", rs_beginTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("endTime", rs_endTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("asSysMainId", rs_asSysMainId, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("sumRptName", rs_sumRptName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("comCount", rs_comCount, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("answerCount", rs_answerCount, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("createMan", rs_createMan, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("createTime", rs_createTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("companys", rs_companys, 1, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into asStatPlan(" + jdb.SQLField(0, "planName") + 
					"," + jdb.SQLField(0, "beginTime") + 
					"," + jdb.SQLField(0, "endTime") + 
					"," + jdb.SQLField(0, "Info") + 
					"," + jdb.SQLField(0, "scopeInfo") + 
					"," + jdb.SQLField(0, "asSysMainId") + 
					"," + jdb.SQLField(0, "sumRptName") + 
					"," + jdb.SQLField(0, "comCount") + 
					"," + jdb.SQLField(0, "answerCount") + 
					"," + jdb.SQLField(0, "createMan") + 
					"," + jdb.SQLField(0, "createTime") + 
					"," + jdb.SQLField(0, "companys") + 
					") values (" + jdb.GetFieldTypeValueEx(rs_planName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_beginTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_endTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Info, 2, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_scopeInfo, 2, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_asSysMainId, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_sumRptName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_comCount, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_answerCount, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_createMan, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_createTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_companys, 1, 0) + 
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
			 	SystemLog.setLog(jdb, user, request, "4", "", "asStatPlan", DataID);
			}
			else
			{
				sql = "update asStatPlan set " + 
					jdb.SQLField(0, "planName") + "=" + jdb.GetFieldTypeValueEx(rs_planName, 1, 0) + ", " + 
					jdb.SQLField(0, "beginTime") + "=" + jdb.GetFieldTypeValueEx(rs_beginTime, 4, 0) + ", " + 
					jdb.SQLField(0, "endTime") + "=" + jdb.GetFieldTypeValueEx(rs_endTime, 4, 0) + ", " + 
					jdb.SQLField(0, "Info") + "=" + jdb.GetFieldTypeValueEx(rs_Info, 2, 0) + ", " + 
					jdb.SQLField(0, "scopeInfo") + "=" + jdb.GetFieldTypeValueEx(rs_scopeInfo, 2, 0) + ", " + 
					jdb.SQLField(0, "asSysMainId") + "=" + jdb.GetFieldTypeValueEx(rs_asSysMainId, 3, 0) + ", " + 
					jdb.SQLField(0, "sumRptName") + "=" + jdb.GetFieldTypeValueEx(rs_sumRptName, 1, 0) + ", " + 
					jdb.SQLField(0, "comCount") + "=" + jdb.GetFieldTypeValueEx(rs_comCount, 3, 0) + ", " + 
					jdb.SQLField(0, "answerCount") + "=" + jdb.GetFieldTypeValueEx(rs_answerCount, 3, 0) + ", " + 
					jdb.SQLField(0, "createMan") + "=" + jdb.GetFieldTypeValueEx(rs_createMan, 1, 0) + ", " + 
					jdb.SQLField(0, "createTime") + "=" + jdb.GetFieldTypeValueEx(rs_createTime, 4, 0) + ", " + 
					jdb.SQLField(0, "companys") + "=" + jdb.GetFieldTypeValueEx(rs_companys, 1, 0) + " where ID=" + LineDataID;
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
	 			SystemLog.setLog(jdb, user, request, "5", "", "asStatPlan", LineDataID);
			}
			if (y == 0)
				DataID = LineDataID;
			else
				DataID += "," + LineDataID;
		}
//@@##175:后台提交时(内容改变后)用户自定义代码开始(归档用注释,切勿删改)
//
String [] p = request.getParameterValues("sysDetailId");
    for (int x = 0; x < p.length; x++)
    {
      String SysDetailId = p[x];
      String weight = WebChar.RequestForms(request, "weight", x);
      int method = WebChar.ToInt(WebChar.RequestForms(request, "method", x));
      int statSysDetailID = jdb.getIntBySql(0, "select ID from asStatSysDetail where statPlanId=" + DataID + " and sysDetailId=" + SysDetailId);
      if (statSysDetailID > 0)
        sql = "update asStatSysDetail set weight=" + weight + ", method=" + method + " where ID=" + statSysDetailID;
      else
        sql = "insert into asStatSysDetail(statPlanId, sysDetailId, weight, method) values(" + DataID + "," + SysDetailId + "," + weight + "," + method + ")";
      result = jdb.ExecuteSQL(0, sql);
    }


//(归档用注释,切勿删改)后台提交时(内容改变后)用户自定义代码 End##@@
			out.println("OK:" + DataID);
		jdb.closeDBCon();
		return;
	}
	int bAppend = 1;
	if (!(DataID.equals("") || DataID.equals("0")))
	{
		sql = "select * from asStatPlan where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_planName = WebChar.getRSDefault(jdb.getRSString(0, rs, "planName"), "");
			rs_beginTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "beginTime"), "");
			rs_beginTime = VB.dateCStr(VB.CDate(rs_beginTime), "yyyy-MM-dd");
			rs_endTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "endTime"), "");
			rs_endTime = VB.dateCStr(VB.CDate(rs_endTime), "yyyy-MM-dd");
			rs_Info = WebChar.getRSDefault(jdb.readClob(rs.getClob("Info")), "");
			rs_scopeInfo = WebChar.getRSDefault(jdb.readClob(rs.getClob("scopeInfo")), "");
			rs_asSysMainId = WebChar.getRSDefault(jdb.getRSString(0, rs, "asSysMainId"), "");
			rs_sumRptName = WebChar.getRSDefault(jdb.getRSString(0, rs, "sumRptName"), "");
			rs_comCount = WebChar.getRSDefault(jdb.getRSString(0, rs, "comCount"), "");
			rs_answerCount = WebChar.getRSDefault(jdb.getRSString(0, rs, "answerCount"), "");
			rs_createMan = WebChar.getRSDefault(jdb.getRSString(0, rs, "createMan"), "");
			rs_createTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "createTime"), "");
			rs_createTime = VB.dateCStr(VB.CDate(rs_createTime), "yyyy-MM-dd HH:mm:ss");
			rs_companys = WebChar.getRSDefault(jdb.getRSString(0, rs, "companys"), "");
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
		str +=", asSysMainId_ex:\"" + jdb.GetQuoteValue("asSysMain",0, "ID", "cName", rs_asSysMainId) + "\"";
		str +=", companys_ex:\"" + jdb.GetQuoteValue("+company",0, "ID", "comName", rs_companys) + "\"";
		out.print("{planName:\"" + rs_planName + 
			"\",beginTime:\"" + rs_beginTime + 
			"\",endTime:\"" + rs_endTime + 
			"\",Info:\"" + WebChar.toJson(rs_Info) + 
			"\",scopeInfo:\"" + rs_scopeInfo + 
			"\",asSysMainId:\"" + rs_asSysMainId + 
			"\",sumRptName:\"" + rs_sumRptName + 
			"\",comCount:\"" + rs_comCount + 
			"\",answerCount:\"" + rs_answerCount + 
			"\",createMan:\"" + rs_createMan + 
			"\",createTime:\"" + rs_createTime + 
			"\",companys:\"" + WebChar.toJson(rs_companys) + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "统计方案";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:2, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"方案名称\", EName:\"planName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"开始时间\", EName:\"beginTime\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"结束时间\", EName:\"endTime\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"说明\", EName:\"Info\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print(",{CName:\"范围说明\", EName:\"scopeInfo\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"评估体系\", EName:\"asSysMainId\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysMain.ID,cName\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"汇总表名称\", EName:\"sumRptName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"企业总数\", EName:\"comCount\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"答卷总数\", EName:\"answerCount\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"创建人\", EName:\"createMan\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"创建时间\", EName:\"createTime\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:2\", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"$none\", EName:\"companys\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"*Object\", FieldType:1,FieldLen:3000, Quote:\"+company.ID,comName\", nCol:1, nRow:12, nWidth:1, nHeight:10, Hint:\"被统计企业\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		str +=", asSysMainId_ex:\"" + jdb.GetQuoteValue("asSysMain",0, "ID", "cName", rs_asSysMainId) + "\"";
		str +=", companys_ex:\"" + jdb.GetQuoteValue("+company",0, "ID", "comName", rs_companys) + "\"";
		out.print("{planName:\"" + rs_planName + 
			"\",beginTime:\"" + rs_beginTime + 
			"\",endTime:\"" + rs_endTime + 
			"\",Info:\"" + WebChar.toJson(rs_Info) + 
			"\",scopeInfo:\"" + rs_scopeInfo + 
			"\",asSysMainId:\"" + rs_asSysMainId + 
			"\",sumRptName:\"" + rs_sumRptName + 
			"\",comCount:\"" + rs_comCount + 
			"\",answerCount:\"" + rs_answerCount + 
			"\",createMan:\"" + rs_createMan + 
			"\",createTime:\"" + rs_createTime + 
			"\",companys:\"" + WebChar.toJson(rs_companys) + 
			"\"" + str + "}");
		out.print(", {" + 
			"DataID:\"" + DataID + 
			"\", FormAction:\"asStatPlan_form.jsp\", ExcelFormID:" + ExcelFormID + "}]");
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
	var fields = [{CName:"方案名称", EName:"planName", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"开始时间", EName:"beginTime", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:"", FieldType:4, FieldLen:8, Quote:"&d:1", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"结束时间", EName:"endTime", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:"", FieldType:4, FieldLen:8, Quote:"&d:1", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:""},
		{CName:"说明", EName:"Info", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:2, FieldLen:536870910, Quote:"", nCol:1, nRow:4, nWidth:1, nHeight:4, Hint:""},
		{CName:"范围说明", EName:"scopeInfo", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:2, FieldLen:536870910, Quote:"", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:""},
		{CName:"评估体系", EName:"asSysMainId", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:"", FieldType:3, FieldLen:4, Quote:"asSysMain.ID,cName", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:""},
		{CName:"汇总表名称", EName:"sumRptName", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:""},
		{CName:"企业总数", EName:"comCount", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:""},
		{CName:"答卷总数", EName:"answerCount", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:""},
		{CName:"创建人", EName:"createMan", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:20, Quote:"", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:""},
		{CName:"创建时间", EName:"createTime", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:"", FieldType:4, FieldLen:8, Quote:"&d:2", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:""},
		{CName:"$none", EName:"companys", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:"*Object", FieldType:1, FieldLen:3000, Quote:"+company.ID,comName", nCol:1, nRow:12, nWidth:1, nHeight:10, Hint:"被统计企业"}];
	var record = {planName:"<%=WebChar.toJson(rs_planName)%>",
		beginTime:"<%=rs_beginTime%>",
		endTime:"<%=rs_endTime%>",
		Info:"<%=WebChar.toJson(rs_Info)%>",
		scopeInfo:"<%=WebChar.toJson(rs_scopeInfo)%>",
		asSysMainId:"<%=rs_asSysMainId%>",
		sumRptName:"<%=WebChar.toJson(rs_sumRptName)%>",
		comCount:"<%=rs_comCount%>",
		answerCount:"<%=rs_answerCount%>",
		createMan:"<%=WebChar.toJson(rs_createMan)%>",
		createTime:"<%=rs_createTime%>",
		companys:"<%=WebChar.toJson(rs_companys)%>"};
	var ExcelFormID = <%=ExcelFormID%>;
	if (ExcelFormID > 0)
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"统计方案", spaninput:1, gridformid:ExcelFormID});
	else
	{
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"统计方案", formtype:2, nCols:1, ex:ex});
		form.appendHidden("I_DataID", "<%=DataID%>");
	}
//@@##:客户端载入时(归档用注释,切勿删改)

//(归档用注释,切勿删改) 客户端载入时 End##@@
}
</script></html>
