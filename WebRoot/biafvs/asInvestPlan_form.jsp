<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_planName="", rs_beginTime="", rs_endTime="", rs_fillBTime="", rs_fillETime="", rs_asSysMainId="", rs_fillReq="", rs_fillScope="", rs_createMan="", rs_createTime="", rs_Detail="", rs_info="", rs_companys="";
String ds_Detail="", rs_Detail_detailName="", rs_Detail_beginTime="", rs_Detail_endTime="", rs_Detail_fillBeginTime="", rs_Detail_fillEndTime="";
String strTable_Detail = "asInvestPlanDetail", FKeyField_Detail = "mainId";
String strTable = "asInvestPlan";
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
	String FormTitle = "编辑调查计划";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "编辑调查计划";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:2, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"计划名称\", EName:\"planName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"数据开始时间\", EName:\"beginTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"数据结束时间\", EName:\"endTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"计划开始时间\", EName:\"fillBTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"计划结束时间\", EName:\"fillETime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"评估体系模板\", EName:\"asSysMainId\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysMain.ID,cName\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"填报要求\", EName:\"fillReq\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print(",{CName:\"填报范围\", EName:\"fillScope\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print(",{CName:\"创建人\", EName:\"createMan\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"创建时间\", EName:\"createTime\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"$none\", EName:\"Detail\", nShow:1, nReadOnly:0, nRequired:0, InputType:17, Relation:\"\",SubFields:[{EName:\"ID\",CName:\"自动编号\",bShow:0,nReadOnly:0,nRequired:0,InputType:1,Relation:\"\",nCol:1,nWidth:1, bPrimaryKey:1,FieldType:5,FieldLen:4,Quote:\"\"},{EName:\"mainId\",CName:\"主表编号\",bShow:0,nReadOnly:0,nRequired:0,InputType:1,Relation:\"\",nCol:2,nWidth:1,FieldType:3,FieldLen:4,Quote:\"asInvestPlan.ID,planName\"},{EName:\"detailName\",CName:\"名称\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:3,nWidth:100,FieldType:1,FieldLen:50,Quote:\"\"},{EName:\"beginTime\",CName:\"数据开始时间\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:4,nWidth:100,FieldType:4,FieldLen:8,Quote:\"&d:1\"},{EName:\"endTime\",CName:\"数据结束时间\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:5,nWidth:100,FieldType:4,FieldLen:8,Quote:\"&d:1\"},{EName:\"fillBeginTime\",CName:\"填报开始时间\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:6,nWidth:100,FieldType:4,FieldLen:8,Quote:\"&d:1\"},{EName:\"fillEndTime\",CName:\"填报结束时间\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:7,nWidth:100,FieldType:4,FieldLen:8,Quote:\"&d:1\"},{EName:\"askCount\",CName:\"问卷总数\",bShow:0,nReadOnly:0,nRequired:0,InputType:1,Relation:\"\",nCol:8,nWidth:1,FieldType:3,FieldLen:4,Quote:\"\"},{EName:\"answerCount\",CName:\"答卷总数\",bShow:0,nReadOnly:0,nRequired:0,InputType:1,Relation:\"\",nCol:9,nWidth:1,FieldType:3,FieldLen:4,Quote:\"\"}], FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:11, nWidth:1, nHeight:5, Hint:\"计划明细\"}");
		out.print(",{CName:\"备注\", EName:\"info\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:12, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print(",{CName:\"$none\", EName:\"companys\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"*Object\", FieldType:1,FieldLen:3000, Quote:\"+company.ID,comName\", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:\"被调查企业\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='asInvestPlan_form'"));
	String FormBar = FormTitle;
	int FormSaveFlag = WebChar.ToInt(request.getParameter("FormSaveFlag"));
	if (FormSaveFlag == 1)
	{
		if (WebChar.RequestInt(request, "I_DeleteFlag") == 1)
		{
			int result = 0;
			sql = "delete from asInvestPlan where ID=" + jdb.GetFieldTypeValueEx(DataID, 5, 0);
			result = jdb.ExecuteSQL(0, sql);
		 	SystemLog.setLog(jdb, user, request, "6", "", "asInvestPlan", DataID);
			out.clear();
			if (result == 1)
			{
				out.print("OK");
				sql = "delete from asInvestPlanDetail where mainId=" + jdb.GetFieldTypeValueEx(DataID, 3, 0);
				result = jdb.ExecuteSQL(0, sql);
		 		SystemLog.setLog(jdb, user, request, "6", "", "asInvestPlanDetail", DataID);
				out.print(",delete detail table result:" + result);
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
			result = jdb.ExecuteSQL(0, "delete from asInvestPlan where ID in (" + DeleteIDs + ")");
			SystemLog.setLog(jdb, user, request, "6", "", "asInvestPlan", DeleteIDs);
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
			rs_fillBTime = WebChar.getFormValue(request, "fillBTime", y);
			rs_fillETime = WebChar.getFormValue(request, "fillETime", y);
			rs_asSysMainId = WebChar.getFormValue(request, "asSysMainId", y);
			rs_fillReq = WebChar.getFormValue(request, "fillReq", y);
			rs_fillScope = WebChar.getFormValue(request, "fillScope", y);
			rs_createMan = WebChar.getFormValue(request, "createMan", y);
			rs_createTime = WebChar.getFormValue(request, "createTime", y);
			rs_Detail = WebChar.getFormValue(request, "Detail", y);
			rs_info = WebChar.getFormValue(request, "info", y);
			rs_companys = WebChar.getFormValue(request, "companys", y);
			if ((LineDataID == null) || LineDataID.equals("") || LineDataID.equals("0"))
			{
				selsql = "select ID from asInvestPlan where " + jdb.GetFieldWhereClouse("planName", rs_planName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("beginTime", rs_beginTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("endTime", rs_endTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("fillBTime", rs_fillBTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("fillETime", rs_fillETime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("asSysMainId", rs_asSysMainId, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("createMan", rs_createMan, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("createTime", rs_createTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("companys", rs_companys, 1, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into asInvestPlan(" + jdb.SQLField(0, "planName") + 
					"," + jdb.SQLField(0, "beginTime") + 
					"," + jdb.SQLField(0, "endTime") + 
					"," + jdb.SQLField(0, "fillBTime") + 
					"," + jdb.SQLField(0, "fillETime") + 
					"," + jdb.SQLField(0, "asSysMainId") + 
					"," + jdb.SQLField(0, "fillReq") + 
					"," + jdb.SQLField(0, "fillScope") + 
					"," + jdb.SQLField(0, "createMan") + 
					"," + jdb.SQLField(0, "createTime") + 
					"," + jdb.SQLField(0, "info") + 
					"," + jdb.SQLField(0, "companys") + 
					") values (" + jdb.GetFieldTypeValueEx(rs_planName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_beginTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_endTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_fillBTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_fillETime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_asSysMainId, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_fillReq, 2, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_fillScope, 2, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_createMan, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_createTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_info, 2, 0) + 
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
			 	SystemLog.setLog(jdb, user, request, "4", "", "asInvestPlan", DataID);
			}
			else
			{
				sql = "update asInvestPlan set " + 
					jdb.SQLField(0, "planName") + "=" + jdb.GetFieldTypeValueEx(rs_planName, 1, 0) + ", " + 
					jdb.SQLField(0, "beginTime") + "=" + jdb.GetFieldTypeValueEx(rs_beginTime, 4, 0) + ", " + 
					jdb.SQLField(0, "endTime") + "=" + jdb.GetFieldTypeValueEx(rs_endTime, 4, 0) + ", " + 
					jdb.SQLField(0, "fillBTime") + "=" + jdb.GetFieldTypeValueEx(rs_fillBTime, 4, 0) + ", " + 
					jdb.SQLField(0, "fillETime") + "=" + jdb.GetFieldTypeValueEx(rs_fillETime, 4, 0) + ", " + 
					jdb.SQLField(0, "asSysMainId") + "=" + jdb.GetFieldTypeValueEx(rs_asSysMainId, 3, 0) + ", " + 
					jdb.SQLField(0, "fillReq") + "=" + jdb.GetFieldTypeValueEx(rs_fillReq, 2, 0) + ", " + 
					jdb.SQLField(0, "fillScope") + "=" + jdb.GetFieldTypeValueEx(rs_fillScope, 2, 0) + ", " + 
					jdb.SQLField(0, "createMan") + "=" + jdb.GetFieldTypeValueEx(rs_createMan, 1, 0) + ", " + 
					jdb.SQLField(0, "createTime") + "=" + jdb.GetFieldTypeValueEx(rs_createTime, 4, 0) + ", " + 
					jdb.SQLField(0, "info") + "=" + jdb.GetFieldTypeValueEx(rs_info, 2, 0) + ", " + 
					jdb.SQLField(0, "companys") + "=" + jdb.GetFieldTypeValueEx(rs_companys, 1, 0) + " where ID=" + LineDataID;
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
	 			SystemLog.setLog(jdb, user, request, "5", "", "asInvestPlan", LineDataID);
			}
			if (y == 0)
				DataID = LineDataID;
			else
				DataID += "," + LineDataID;
		}
//明细表(asInvestPlanDetail)的保存开始
		Count = request.getParameterValues("I_Detail_DataID").length;
		String I_Detail_IDs = "";
		for (int y = 0; y < Count; y++)
		{
			String I_Detail_DataID = WebChar.getFormValue(request, "I_Detail_DataID", y);
			rs_Detail_detailName = WebChar.getFormValue(request, "Detail_detailName", y);
			rs_Detail_beginTime = WebChar.getFormValue(request, "Detail_beginTime", y);
			rs_Detail_endTime = WebChar.getFormValue(request, "Detail_endTime", y);
			rs_Detail_fillBeginTime = WebChar.getFormValue(request, "Detail_fillBeginTime", y);
			rs_Detail_fillEndTime = WebChar.getFormValue(request, "Detail_fillEndTime", y);
			if (I_Detail_DataID.equals("0") || I_Detail_DataID.equals(""))
			{
				selsql = "select ID from asInvestPlanDetail where " + jdb.GetFieldWhereClouse("detailName", rs_Detail_detailName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("beginTime", rs_Detail_beginTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("endTime", rs_Detail_endTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("fillBeginTime", rs_Detail_fillBeginTime, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("fillEndTime", rs_Detail_fillEndTime, 4, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into asInvestPlanDetail(" + jdb.SQLField(0, "mainId") + 
					"," + jdb.SQLField(0, "detailName") + 
					"," + jdb.SQLField(0, "beginTime") + 
					"," + jdb.SQLField(0, "endTime") + 
					"," + jdb.SQLField(0, "fillBeginTime") + 
					"," + jdb.SQLField(0, "fillEndTime") + 
					") values (" + jdb.GetFieldTypeValueEx(DataID, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Detail_detailName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Detail_beginTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Detail_endTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Detail_fillBeginTime, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_Detail_fillEndTime, 4, 0) + 
					")";
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
				subsql = "";
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
				I_Detail_DataID = rs.getString("ID");
				jdb.rsClose(0, rs);
			}
			else
			{
				sql = "update asInvestPlanDetail set " + 
					jdb.SQLField(0, "detailName") + "=" + jdb.GetFieldTypeValueEx(rs_Detail_detailName, 1, 0) + ", " + 
					jdb.SQLField(0, "beginTime") + "=" + jdb.GetFieldTypeValueEx(rs_Detail_beginTime, 4, 0) + ", " + 
					jdb.SQLField(0, "endTime") + "=" + jdb.GetFieldTypeValueEx(rs_Detail_endTime, 4, 0) + ", " + 
					jdb.SQLField(0, "fillBeginTime") + "=" + jdb.GetFieldTypeValueEx(rs_Detail_fillBeginTime, 4, 0) + ", " + 
					jdb.SQLField(0, "fillEndTime") + "=" + jdb.GetFieldTypeValueEx(rs_Detail_fillEndTime, 4, 0) + " where ID=" + I_Detail_DataID;
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
			}
			if (!I_Detail_IDs.equals(""))
				I_Detail_IDs += ",";
			I_Detail_IDs += I_Detail_DataID;
		}
		if (!I_Detail_IDs.equals(""))
		{
			sql = "delete from asInvestPlanDetail where mainId=" + DataID + " and ID not in(" + I_Detail_IDs + ")";
			result = jdb.ExecuteSQL(0, sql);
		}
//明细表(asInvestPlanDetail)的保存结束
		if (WebChar.RequestInt(request, "Ajax") == 1)
			out.println("OK:" + DataID);
		else
		{
			out.println(WebFace.GetHTMLHead(FormTitle, "<link rel='stylesheet' type='text/css' href='../forum.css'>"));
			out.println("<script language=javascript src=../comForm.jsp></script>");
			out.println("<script language=javascript src=../compsub.jsp></script>");
			out.println(WebFace.ResultPage("提交成功!" ,"<a href=javascript:CloseActionWindow()>" + "点击这里返回" + "</a>"));
			if (WebChar.ToInt(request.getParameter("PrintFlag")) == 1)
			{
				String PrintAction = jdb.GetTableValue(1, "TableAction", "PrintAction", "ID", "209");
				out.println("<script language=javascript>" +
					"NewHref('TableAction.asp?nActionType=3&ActionID=" + PrintAction + "&DataID=" + DataID +
					"','menubar=0,toolbar=0,resizable=1,status=0,width=640,height=480,left=50,top=50');" +
					"</script>");
			}
			out.println("</BODY></HTML>");
		}
		jdb.closeDBCon();
		return;
	}
	int bAppend = 1;
	if (!(DataID.equals("") || DataID.equals("0")))
	{
		sql = "select * from asInvestPlan where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_planName = WebChar.getRSDefault(jdb.getRSString(0, rs, "planName"), "");
			rs_beginTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "beginTime"), "");
			rs_beginTime = VB.dateCStr(VB.CDate(rs_beginTime), "yyyy-MM-dd");
			rs_endTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "endTime"), "");
			rs_endTime = VB.dateCStr(VB.CDate(rs_endTime), "yyyy-MM-dd");
			rs_fillBTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "fillBTime"), "");
			rs_fillBTime = VB.dateCStr(VB.CDate(rs_fillBTime), "yyyy-MM-dd");
			rs_fillETime = WebChar.getRSDefault(jdb.getRSString(0, rs, "fillETime"), "");
			rs_fillETime = VB.dateCStr(VB.CDate(rs_fillETime), "yyyy-MM-dd");
			rs_asSysMainId = WebChar.getRSDefault(jdb.getRSString(0, rs, "asSysMainId"), "");
			rs_fillReq = WebChar.getRSDefault(jdb.readClob(rs.getClob("fillReq")), "");
			rs_fillScope = WebChar.getRSDefault(jdb.readClob(rs.getClob("fillScope")), "");
			rs_createMan = WebChar.getRSDefault(jdb.getRSString(0, rs, "createMan"), "");
			rs_createTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "createTime"), "");
			rs_info = WebChar.getRSDefault(jdb.readClob(rs.getClob("info")), "");
			rs_companys = WebChar.getRSDefault(jdb.getRSString(0, rs, "companys"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	rs_createMan = WebChar.getRSDefault(rs_createMan, user.CMemberName);
	rs_createTime = WebChar.getRSDefault(rs_createTime, VB.Now());
	rs_Detail = "<table width=100% id=Detail_SubTable border=0><tr><td style=display:none></td><td>名称<font color=red>*</font></td><td>数据开始时间<font color=red>*</font></td><td>数据结束时间<font color=red>*</font></td><td>填报开始时间<font color=red>*</font></td><td>填报结束时间<font color=red>*</font></td><td>&nbsp;</td></tr>";
			rs_Detail_detailName = WebChar.getRSDefault(rs_Detail_detailName, "新步骤");
			rs_Detail_beginTime = WebChar.getRSDefault(rs_Detail_beginTime, VB.Date());
			rs_Detail_fillBeginTime = WebChar.getRSDefault(rs_Detail_fillBeginTime, VB.Date());

	ds_Detail = "{detailName:\"" +  rs_Detail_detailName + "\",beginTime:\"" +  rs_Detail_beginTime + "\",endTime:\"" +  rs_Detail_endTime + "\",fillBeginTime:\"" +  rs_Detail_fillBeginTime + "\",fillEndTime:\"" +  rs_Detail_fillEndTime + "\"}";
	String rs_DetailLine = "<td style=display:none><input type=hidden name=I_Detail_DataID value=0></td><td width='100%'><input name='Detail_detailName' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='" + rs_Detail_detailName + 
				"' bRequired=1 title=''></td><td width='100%'><input name='Detail_beginTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='" + rs_Detail_beginTime + 
				"' bRequired=1 title=''></td><td width='100%'><input name='Detail_endTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='" + rs_Detail_endTime + 
				"' bRequired=1 title=''></td><td width='100%'><input name='Detail_fillBeginTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='" + rs_Detail_fillBeginTime + 
				"' bRequired=1 title=''></td><td width='100%'><input name='Detail_fillEndTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='" + rs_Detail_fillEndTime + 
				"' bRequired=1 title=''></td><td>&nbsp;<img src=../pic/favorites_new.png style=cursor:hand onclick=InsertDetail(this)>&nbsp;<img src=../pic/favorites_del.png style=cursor:hand; onclick=DeleteDetail(this)></td>";
	rs_Detail += "<tr id=DetailTempleteTR style=display:none>" + rs_DetailLine + "</tr>";
	int rs_DetailLineCount=0;
	if (!(DataID.equals("") || DataID.equals("0")))
	{
		sql = " select * from asInvestPlanDetail where mainId=" + DataID + " order by beginTime";
		ResultSet rs = jdb.rsSQL(0, sql);
		while (rs.next())
		{
			rs_Detail_detailName = WebChar.getRSDefault(jdb.getRSString(0, rs, "detailName"), "");
			rs_Detail_beginTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "beginTime"), "");
			rs_Detail_beginTime = VB.dateCStr(VB.CDate(rs_Detail_beginTime), "yyyy-MM-dd");
			rs_Detail_endTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "endTime"), "");
			rs_Detail_endTime = VB.dateCStr(VB.CDate(rs_Detail_endTime), "yyyy-MM-dd");
			rs_Detail_fillBeginTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "fillBeginTime"), "");
			rs_Detail_fillBeginTime = VB.dateCStr(VB.CDate(rs_Detail_fillBeginTime), "yyyy-MM-dd");
			rs_Detail_fillEndTime = WebChar.getRSDefault(jdb.getRSString(0, rs, "fillEndTime"), "");
			rs_Detail_fillEndTime = VB.dateCStr(VB.CDate(rs_Detail_fillEndTime), "yyyy-MM-dd");

			rs_Detail_detailName = WebChar.getRSDefault(rs_Detail_detailName, "新步骤");
			rs_Detail_beginTime = WebChar.getRSDefault(rs_Detail_beginTime, VB.Date());
			rs_Detail_fillBeginTime = WebChar.getRSDefault(rs_Detail_fillBeginTime, VB.Date());

			ds_Detail += ",{I_DataID:\"" + rs.getString("ID") + "\",detailName:\"" +  rs_Detail_detailName + "\",beginTime:\"" +  rs_Detail_beginTime + "\",endTime:\"" +  rs_Detail_endTime + "\",fillBeginTime:\"" +  rs_Detail_fillBeginTime + "\",fillEndTime:\"" +  rs_Detail_fillEndTime + "\"}";
			rs_Detail += "<tr><td style=display:none><input type=hidden name=I_Detail_DataID value=" + rs.getString("ID") + "></td><td width='100%'><input name='Detail_detailName' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='" + rs_Detail_detailName + 
				"' bRequired=1 title=''></td><td width='100%'><input name='Detail_beginTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='" + rs_Detail_beginTime + 
				"' bRequired=1 title=''></td><td width='100%'><input name='Detail_endTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='" + rs_Detail_endTime + 
				"' bRequired=1 title=''></td><td width='100%'><input name='Detail_fillBeginTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='" + rs_Detail_fillBeginTime + 
				"' bRequired=1 title=''></td><td width='100%'><input name='Detail_fillEndTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='" + rs_Detail_fillEndTime + 
				"' bRequired=1 title=''></td><td>&nbsp;<img src=../pic/favorites_new.png style=cursor:hand onclick=InsertDetail(this)>&nbsp;<img src=../pic/favorites_del.png style=cursor:hand; onclick=DeleteDetail(this)></td></tr>";
			rs_DetailLineCount ++;
		}
	}
	ds_Detail= "[" + ds_Detail + "]";
	if (rs_DetailLineCount == 0)
	{
		for (int x = 0; x < 5; x++)
			rs_Detail += "<tr>" + rs_DetailLine + "</tr>";
	}
	rs_Detail += "</table>";
	if (WebChar.RequestInt(request, "getrecord") == 1)
	{
		out.clear();
		String str = "";
		str +=", asSysMainId_ex:\"" + jdb.GetQuoteValue("asSysMain",0, "ID", "cName", rs_asSysMainId) + "\"";
		str +=", companys_ex:\"" + jdb.GetQuoteValue("+company",0, "ID", "comName", rs_companys) + "\"";
		out.print("{planName:\"" + rs_planName + 
			"\",beginTime:\"" + rs_beginTime + 
			"\",endTime:\"" + rs_endTime + 
			"\",fillBTime:\"" + rs_fillBTime + 
			"\",fillETime:\"" + rs_fillETime + 
			"\",asSysMainId:\"" + rs_asSysMainId + 
			"\",fillReq:\"" + WebChar.toJson(rs_fillReq) + 
			"\",fillScope:\"" + WebChar.toJson(rs_fillScope) + 
			"\",createMan:\"" + rs_createMan + 
			"\",createTime:\"" + rs_createTime + 
			"\",Detail:" + ds_Detail + 
			",info:\"" + WebChar.toJson(rs_info) + 
			"\",companys:\"" + WebChar.toJson(rs_companys) + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "编辑调查计划";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:2, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"计划名称\", EName:\"planName\", nShow:1, nReadOnly:0, nRequired:1, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"数据开始时间\", EName:\"beginTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"数据结束时间\", EName:\"endTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"计划开始时间\", EName:\"fillBTime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"计划结束时间\", EName:\"fillETime\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"&d:1\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"评估体系模板\", EName:\"asSysMainId\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysMain.ID,cName\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"填报要求\", EName:\"fillReq\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print(",{CName:\"填报范围\", EName:\"fillScope\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print(",{CName:\"创建人\", EName:\"createMan\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"创建时间\", EName:\"createTime\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"$none\", EName:\"Detail\", nShow:1, nReadOnly:0, nRequired:0, InputType:17, Relation:\"\",SubFields:[{EName:\"ID\",CName:\"自动编号\",bShow:0,nReadOnly:0,nRequired:0,InputType:1,Relation:\"\",nCol:1,nWidth:1, bPrimaryKey:1,FieldType:5,FieldLen:4,Quote:\"\"},{EName:\"mainId\",CName:\"主表编号\",bShow:0,nReadOnly:0,nRequired:0,InputType:1,Relation:\"\",nCol:2,nWidth:1,FieldType:3,FieldLen:4,Quote:\"asInvestPlan.ID,planName\"},{EName:\"detailName\",CName:\"名称\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:3,nWidth:100,FieldType:1,FieldLen:50,Quote:\"\"},{EName:\"beginTime\",CName:\"数据开始时间\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:4,nWidth:100,FieldType:4,FieldLen:8,Quote:\"&d:1\"},{EName:\"endTime\",CName:\"数据结束时间\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:5,nWidth:100,FieldType:4,FieldLen:8,Quote:\"&d:1\"},{EName:\"fillBeginTime\",CName:\"填报开始时间\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:6,nWidth:100,FieldType:4,FieldLen:8,Quote:\"&d:1\"},{EName:\"fillEndTime\",CName:\"填报结束时间\",bShow:1,nReadOnly:0,nRequired:1,InputType:1,Relation:\"\",nCol:7,nWidth:100,FieldType:4,FieldLen:8,Quote:\"&d:1\"},{EName:\"askCount\",CName:\"问卷总数\",bShow:0,nReadOnly:0,nRequired:0,InputType:1,Relation:\"\",nCol:8,nWidth:1,FieldType:3,FieldLen:4,Quote:\"\"},{EName:\"answerCount\",CName:\"答卷总数\",bShow:0,nReadOnly:0,nRequired:0,InputType:1,Relation:\"\",nCol:9,nWidth:1,FieldType:3,FieldLen:4,Quote:\"\"}], FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:11, nWidth:1, nHeight:5, Hint:\"计划明细\"}");
		out.print(",{CName:\"备注\", EName:\"info\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:2,FieldLen:536870910, Quote:\"\", nCol:1, nRow:12, nWidth:1, nHeight:4, Hint:\"\"}");
		out.print(",{CName:\"$none\", EName:\"companys\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"*Object\", FieldType:1,FieldLen:3000, Quote:\"+company.ID,comName\", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:\"被调查企业\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		str +=", asSysMainId_ex:\"" + jdb.GetQuoteValue("asSysMain",0, "ID", "cName", rs_asSysMainId) + "\"";
		str +=", companys_ex:\"" + jdb.GetQuoteValue("+company",0, "ID", "comName", rs_companys) + "\"";
		out.print("{planName:\"" + rs_planName + 
			"\",beginTime:\"" + rs_beginTime + 
			"\",endTime:\"" + rs_endTime + 
			"\",fillBTime:\"" + rs_fillBTime + 
			"\",fillETime:\"" + rs_fillETime + 
			"\",asSysMainId:\"" + rs_asSysMainId + 
			"\",fillReq:\"" + WebChar.toJson(rs_fillReq) + 
			"\",fillScope:\"" + WebChar.toJson(rs_fillScope) + 
			"\",createMan:\"" + rs_createMan + 
			"\",createTime:\"" + rs_createTime + 
			"\",Detail:" + ds_Detail + 
			",info:\"" + WebChar.toJson(rs_info) + 
			"\",companys:\"" + WebChar.toJson(rs_companys) + 
			"\"" + str + "}");
		out.print(", {" + 
			"DataID:\"" + DataID + 
			"\", FormAction:\"asInvestPlan_form.jsp\", ExcelFormID:" + ExcelFormID + "}]");
		jdb.closeDBCon();
		return;
	}
	out.println(WebFace.GetHTMLHead(FormTitle, "<link rel='stylesheet' type='text/css' href='../forum.css'>"));
%>
<script language=javascript src=../compsub.jsp></script>
<script language=javascript src=../comcommon.js></script>
<script language=javascript src=../comForm.jsp></script>

<script language=javascript>
nDefaultWinMode = 5;
//FormFeatures = 'titlebar=0,toolbar=0,scrollbars=0,resizable=0,width=640,height=200,left=50,top=50';
</script><body style='background:' alink=#333333 vlink=#333333 link=#333333 topmargin=0 leftmargin=0>
<form action='asInvestPlan_form.jsp' method=POST name=ActionSave>
<input name=I_DataID type=hidden value=<%=DataID%>>
<input name=I_ModuleNo type=hidden value=<%=ModuleNo%>>
<input name=I_TableDefID type=hidden value=200>
<input name=PrintFlag type=hidden value=0>
<input name=FormSaveFlag type=hidden value=1>
<%=FormBar%>
<div id=FormBodyDiv class=jformdiv><table id=FormTableObj1 border=0 cellpadding=3 cellspacing=1 style=width:100% onkeydown=PressKey() class=jformtable1>
<tr><td id=T1_planName nowrap width=10%  class=jformcon1>计划名称<font color=red>*</font></TD>
<td id=T2_planName width=90% class=jformval1 nowrap>
<input name='planName' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='<%=rs_planName%>' bRequired=1 title=''></td>
</tr>
<tr><td id=T1_beginTime nowrap width=10%  class=jformcon1>数据开始时间</TD>
<td id=T2_beginTime width=90% class=jformval1 nowrap>
<input name='beginTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='<%=rs_beginTime%>' title=''></td>
</tr>
<tr><td id=T1_endTime nowrap width=10%  class=jformcon1>数据结束时间</TD>
<td id=T2_endTime width=90% class=jformval1 nowrap>
<input name='endTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='<%=rs_endTime%>' title=''></td>
</tr>
<tr><td id=T1_fillBTime nowrap width=10%  class=jformcon1>计划开始时间</TD>
<td id=T2_fillBTime width=90% class=jformval1 nowrap>
<input name='fillBTime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='<%=rs_fillBTime%>' title=''></td>
</tr>
<tr><td id=T1_fillETime nowrap width=10%  class=jformcon1>计划结束时间</TD>
<td id=T2_fillETime width=90% class=jformval1 nowrap>
<input name='fillETime' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='<%=rs_fillETime%>' title=''></td>
</tr>
<tr><td id=T1_asSysMainId nowrap width=10%  class=jformcon1>评估体系模板</TD>
<td id=T2_asSysMainId width=90% class=jformval1 nowrap>
<%=webenum.GetOptionFromDB("asSysMain", 0, "ID", "cName", "asSysMainId", rs_asSysMainId, "", "", "")%></td>
</tr>
<tr><td id=T1_fillReq nowrap width=10%  class=jformcon1>填报要求</TD>
<td id=T2_fillReq width=90% class=jformval1>
<textarea style=width:100%;margin-right:24px; name='fillReq' rows=4 wrap=VIRTUAL FieldType=2 FieldLen=536870910><%=rs_fillReq%></textarea></td>
</tr>
<tr><td id=T1_fillScope nowrap width=10%  class=jformcon1>填报范围</TD>
<td id=T2_fillScope width=90% class=jformval1>
<textarea style=width:100%;margin-right:24px; name='fillScope' rows=4 wrap=VIRTUAL FieldType=2 FieldLen=536870910><%=rs_fillScope%></textarea></td>
</tr>
<tr><td id=T1_createMan nowrap width=10%  class=jformconreadonly1>创建人</TD>
<td id=T2_createMan width=90% class=jformval1 nowrap>
<input name='createMan' readonly class=textreadonly style=width:100%;height:100% value='<%=rs_createMan%>' title=''></td>
</tr>
<tr><td id=T1_createTime nowrap width=10%  class=jformconreadonly1>创建时间</TD>
<td id=T2_createTime width=90% class=jformval1 nowrap>
<input name='createTime' readonly class=textreadonly style=width:100%;height:100% value='<%=rs_createTime%>' title=''></td>
</tr>
<tr><td id=T2_Detail width=90% class=jformval1 colSpan=2>
<%=rs_Detail%></td>
</tr>
<tr><td id=T1_info nowrap width=10%  class=jformcon1>备注</TD>
<td id=T2_info width=90% class=jformval1>
<textarea style=width:100%;margin-right:24px; name='info' rows=4 wrap=VIRTUAL FieldType=2 FieldLen=536870910><%=rs_info%></textarea></td>
</tr>
<tr><td id=T2_companys width=90% class=jformval1 colSpan=2 nowrap>
<input type=hidden name='companys' value='<%=rs_companys%>'><input class=text name=Alias_companys style=width:100%;height:100%;margin-right:24px value='<%=jdb.GetQuoteResult("company", 0, "ID", "comName", rs_companys)%>' onchange=SelectQuoteValue(this,200,'company','ID','comName','<%=rs_companys%>')><img src=../compic/search.png style=cursor:hand;margin-left:-20px condition='*Object' id=R_companys onclick="SelectQuoteResult(this,'company','ID','comName','<%=rs_companys%>')"></td>
</tr></table></div><input type=hidden name=Count value=<%=Count%>>
<div id=FormButtonDiv align=center class=jformtail1>
<input type=button value='提 交' name=SubmitButton onclick=SubmitForm(this)> &nbsp;
<input type=button name=exitform value='返 回' onclick=CloseActionWindow(2)>&nbsp;</div>
</form>
<iframe name=FormDataFrame src=../comblank.htm style=position:absolute;display:none;width:600px;height:300px; frameborder=0></iframe></BODY>
<SCRIPT LANGUAGE=JavaScript>
window.onload = function()
{
	InitForm();
	ResizeFlowForm();
}
function CheckForm()
{
	if (CheckFormValue(document.all.ActionSave) == false)
		return false;
	return true;
}

function PrintForm(obj)
{
	if (window.confirm("打印前是否提交?"))
		SubmitForm(obj,1);
	else
		NewHref("TableAction.asp?nActionType=3&ActionID=0&TableDefID=200&DataID=", "menubar=0,toolbar=0,resizable=1,status=0,width=640,height=480,left=50,top=50");
}
window.onresize=ResizeActionWin;
</SCRIPT>
<%
	jdb.closeDBCon();
	out.println("</HTML>");
%>