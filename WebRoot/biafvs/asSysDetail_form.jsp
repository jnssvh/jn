<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_asSysId="", rs_baseId="", rs_parentId="", rs_nSerial="", rs_itemCName="", rs_itemEName="", rs_info="", rs_weight="", rs_method="", rs_dataType="", rs_unit="", rs_dotNum="", rs_fillName="", rs_fillInfo="", rs_sumMethod="", rs_sumMethodExp="";
String strTable = "asSysDetail";
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
	String FormTitle = "指标项";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "指标项";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:2, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"模板\", EName:\"asSysId\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysMain.ID,cName\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"基础指标编号\", EName:\"baseId\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysDetail.ID,itemCName\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"上级指标\", EName:\"parentId\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"$asSysDetail_view:DBTree\", FieldType:3,FieldLen:4, Quote:\"asSysDetail.ID,itemCName\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"顺序号\", EName:\"nSerial\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"指标名称\", EName:\"itemCName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"字段名称\", EName:\"itemEName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"说明\", EName:\"info\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:200, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:3, Hint:\"\"}");
		out.print(",{CName:\"权重\", EName:\"weight\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:6,FieldLen:4, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"指数计算方法\", EName:\"method\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"数据类型\", EName:\"dataType\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"单位\", EName:\"unit\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:10, Quote:\"\", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"小数点后位数\", EName:\"dotNum\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:12, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"填报名称\", EName:\"fillName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"填报说明\", EName:\"fillInfo\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:200, Quote:\"\", nCol:1, nRow:14, nWidth:1, nHeight:3, Hint:\"\"}");
		out.print(",{CName:\"汇总表计算方法\", EName:\"sumMethod\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:累加法,2:平均法,3:去零平均法,4:最新数据法,5:公式计算法.6:程序计算法)\", nCol:1, nRow:15, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"汇总表计算公式\", EName:\"sumMethodExp\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:16, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='asSysDetail_form'"));
	String FormBar = FormTitle;
	int FormSaveFlag = WebChar.ToInt(request.getParameter("FormSaveFlag"));
	if (FormSaveFlag == 1)
	{
		if (WebChar.RequestInt(request, "I_DeleteFlag") == 1)
		{
			int result = 0;
			sql = "delete from asSysDetail where ID=" + jdb.GetFieldTypeValueEx(DataID, 5, 0);
			result = jdb.ExecuteSQL(0, sql);
		 	SystemLog.setLog(jdb, user, request, "6", "", "asSysDetail", DataID);
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
			result = jdb.ExecuteSQL(0, "delete from asSysDetail where ID in (" + DeleteIDs + ")");
			SystemLog.setLog(jdb, user, request, "6", "", "asSysDetail", DeleteIDs);
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
			rs_asSysId = WebChar.getFormValue(request, "asSysId", y);
			rs_baseId = WebChar.getFormValue(request, "baseId", y);
			rs_parentId = WebChar.getFormValue(request, "parentId", y);
			rs_nSerial = WebChar.getFormValue(request, "nSerial", y);
			rs_itemCName = WebChar.getFormValue(request, "itemCName", y);
			rs_itemEName = WebChar.getFormValue(request, "itemEName", y);
			rs_info = WebChar.getFormValue(request, "info", y);
			rs_weight = WebChar.getFormValue(request, "weight", y);
			rs_method = WebChar.getFormValue(request, "method", y);
			rs_dataType = WebChar.getFormValue(request, "dataType", y);
			rs_unit = WebChar.getFormValue(request, "unit", y);
			rs_dotNum = WebChar.getFormValue(request, "dotNum", y);
			rs_fillName = WebChar.getFormValue(request, "fillName", y);
			rs_fillInfo = WebChar.getFormValue(request, "fillInfo", y);
			rs_sumMethod = WebChar.getFormValue(request, "sumMethod", y);
			rs_sumMethodExp = WebChar.getFormValue(request, "sumMethodExp", y);
			if ((LineDataID == null) || LineDataID.equals(""))
			{
				selsql = "select ID from asSysDetail where " + jdb.GetFieldWhereClouse("asSysId", rs_asSysId, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("baseId", rs_baseId, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("parentId", rs_parentId, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("nSerial", rs_nSerial, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("itemCName", rs_itemCName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("itemEName", rs_itemEName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("info", rs_info, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("weight", rs_weight, 6, 0) + 
					" and " + jdb.GetFieldWhereClouse("method", rs_method, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("dataType", rs_dataType, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("unit", rs_unit, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("dotNum", rs_dotNum, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("fillName", rs_fillName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("fillInfo", rs_fillInfo, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("sumMethod", rs_sumMethod, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("sumMethodExp", rs_sumMethodExp, 1, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into asSysDetail(" + jdb.SQLField(0, "asSysId") + 
					"," + jdb.SQLField(0, "baseId") + 
					"," + jdb.SQLField(0, "parentId") + 
					"," + jdb.SQLField(0, "nSerial") + 
					"," + jdb.SQLField(0, "itemCName") + 
					"," + jdb.SQLField(0, "itemEName") + 
					"," + jdb.SQLField(0, "info") + 
					"," + jdb.SQLField(0, "weight") + 
					"," + jdb.SQLField(0, "method") + 
					"," + jdb.SQLField(0, "dataType") + 
					"," + jdb.SQLField(0, "unit") + 
					"," + jdb.SQLField(0, "dotNum") + 
					"," + jdb.SQLField(0, "fillName") + 
					"," + jdb.SQLField(0, "fillInfo") + 
					"," + jdb.SQLField(0, "sumMethod") + 
					"," + jdb.SQLField(0, "sumMethodExp") + 
					") values (" + jdb.GetFieldTypeValueEx(rs_asSysId, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_baseId, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_parentId, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_nSerial, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_itemCName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_itemEName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_info, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_weight, 6, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_method, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_dataType, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_unit, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_dotNum, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_fillName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_fillInfo, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_sumMethod, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_sumMethodExp, 1, 0) + 
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
			 	SystemLog.setLog(jdb, user, request, "4", "", "asSysDetail", DataID);
			}
			else
			{
				sql = "update asSysDetail set " + 
					jdb.SQLField(0, "asSysId") + "=" + jdb.GetFieldTypeValueEx(rs_asSysId, 3, 0) + ", " + 
					jdb.SQLField(0, "baseId") + "=" + jdb.GetFieldTypeValueEx(rs_baseId, 3, 0) + ", " + 
					jdb.SQLField(0, "parentId") + "=" + jdb.GetFieldTypeValueEx(rs_parentId, 3, 0) + ", " + 
					jdb.SQLField(0, "nSerial") + "=" + jdb.GetFieldTypeValueEx(rs_nSerial, 3, 0) + ", " + 
					jdb.SQLField(0, "itemCName") + "=" + jdb.GetFieldTypeValueEx(rs_itemCName, 1, 0) + ", " + 
					jdb.SQLField(0, "itemEName") + "=" + jdb.GetFieldTypeValueEx(rs_itemEName, 1, 0) + ", " + 
					jdb.SQLField(0, "info") + "=" + jdb.GetFieldTypeValueEx(rs_info, 1, 0) + ", " + 
					jdb.SQLField(0, "weight") + "=" + jdb.GetFieldTypeValueEx(rs_weight, 6, 0) + ", " + 
					jdb.SQLField(0, "method") + "=" + jdb.GetFieldTypeValueEx(rs_method, 3, 0) + ", " + 
					jdb.SQLField(0, "dataType") + "=" + jdb.GetFieldTypeValueEx(rs_dataType, 3, 0) + ", " + 
					jdb.SQLField(0, "unit") + "=" + jdb.GetFieldTypeValueEx(rs_unit, 1, 0) + ", " + 
					jdb.SQLField(0, "dotNum") + "=" + jdb.GetFieldTypeValueEx(rs_dotNum, 3, 0) + ", " + 
					jdb.SQLField(0, "fillName") + "=" + jdb.GetFieldTypeValueEx(rs_fillName, 1, 0) + ", " + 
					jdb.SQLField(0, "fillInfo") + "=" + jdb.GetFieldTypeValueEx(rs_fillInfo, 1, 0) + ", " + 
					jdb.SQLField(0, "sumMethod") + "=" + jdb.GetFieldTypeValueEx(rs_sumMethod, 3, 0) + ", " + 
					jdb.SQLField(0, "sumMethodExp") + "=" + jdb.GetFieldTypeValueEx(rs_sumMethodExp, 1, 0) + " where ID=" + LineDataID;
				result = jdb.ExecuteSQL(0, sql);
				if (result == -1)
				{
					out.println("提交失败，请检查SQL\\n" + sql);
					jdb.closeDBCon();
					return;
				}
	 			SystemLog.setLog(jdb, user, request, "5", "", "asSysDetail", LineDataID);
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
		sql = "select * from asSysDetail where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_asSysId = WebChar.getRSDefault(jdb.getRSString(0, rs, "asSysId"), "");
			rs_baseId = WebChar.getRSDefault(jdb.getRSString(0, rs, "baseId"), "");
			rs_parentId = WebChar.getRSDefault(jdb.getRSString(0, rs, "parentId"), "");
			rs_nSerial = WebChar.getRSDefault(jdb.getRSString(0, rs, "nSerial"), "");
			rs_itemCName = WebChar.getRSDefault(jdb.getRSString(0, rs, "itemCName"), "");
			rs_itemEName = WebChar.getRSDefault(jdb.getRSString(0, rs, "itemEName"), "");
			rs_info = WebChar.getRSDefault(jdb.getRSString(0, rs, "info"), "");
			rs_weight = WebChar.getRSDefault(jdb.getRSString(0, rs, "weight"), "");
			rs_method = WebChar.getRSDefault(jdb.getRSString(0, rs, "method"), "");
			rs_dataType = WebChar.getRSDefault(jdb.getRSString(0, rs, "dataType"), "");
			rs_unit = WebChar.getRSDefault(jdb.getRSString(0, rs, "unit"), "");
			rs_dotNum = WebChar.getRSDefault(jdb.getRSString(0, rs, "dotNum"), "");
			rs_fillName = WebChar.getRSDefault(jdb.getRSString(0, rs, "fillName"), "");
			rs_fillInfo = WebChar.getRSDefault(jdb.getRSString(0, rs, "fillInfo"), "");
			rs_sumMethod = WebChar.getRSDefault(jdb.getRSString(0, rs, "sumMethod"), "");
			rs_sumMethodExp = WebChar.getRSDefault(jdb.getRSString(0, rs, "sumMethodExp"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	rs_asSysId = WebChar.getRSDefault(rs_asSysId, WebChar.requestStr(request, "asSysId"));
	rs_dataType = WebChar.getRSDefault(rs_dataType, "7");
	rs_dotNum = WebChar.getRSDefault(rs_dotNum, "0");
	if (WebChar.RequestInt(request, "getrecord") == 1)
	{
		out.clear();
		String str = "";
		str +=", asSysId_ex:\"" + jdb.GetQuoteValue("asSysMain",0, "ID", "cName", rs_asSysId) + "\"";
		str +=", baseId_ex:\"" + jdb.GetQuoteValue("asSysDetail",0, "ID", "itemCName", rs_baseId) + "\"";
		str +=", parentId_ex:\"" + jdb.GetQuoteValue("asSysDetail",0, "ID", "itemCName", rs_parentId) + "\"";
		str += ", method_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)", rs_method), !rs_method.equals("")) + "\"";
		str += ", dataType_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", rs_dataType), !rs_dataType.equals("")) + "\"";
		str += ", sumMethod_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:累加法,2:平均法,3:去零平均法,4:最新数据法,5:公式计算法.6:程序计算法)", rs_sumMethod), !rs_sumMethod.equals("")) + "\"";
		out.print("{asSysId:\"" + rs_asSysId + 
			"\",baseId:\"" + rs_baseId + 
			"\",parentId:\"" + rs_parentId + 
			"\",nSerial:\"" + rs_nSerial + 
			"\",itemCName:\"" + rs_itemCName + 
			"\",itemEName:\"" + rs_itemEName + 
			"\",info:\"" + WebChar.toJson(rs_info) + 
			"\",weight:\"" + rs_weight + 
			"\",method:\"" + rs_method + 
			"\",dataType:\"" + rs_dataType + 
			"\",unit:\"" + rs_unit + 
			"\",dotNum:\"" + rs_dotNum + 
			"\",fillName:\"" + rs_fillName + 
			"\",fillInfo:\"" + WebChar.toJson(rs_fillInfo) + 
			"\",sumMethod:\"" + rs_sumMethod + 
			"\",sumMethodExp:\"" + rs_sumMethodExp + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "指标项";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:2, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"模板\", EName:\"asSysId\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysMain.ID,cName\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"基础指标编号\", EName:\"baseId\", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"asSysDetail.ID,itemCName\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"上级指标\", EName:\"parentId\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"$asSysDetail_view:DBTree\", FieldType:3,FieldLen:4, Quote:\"asSysDetail.ID,itemCName\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"顺序号\", EName:\"nSerial\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"指标名称\", EName:\"itemCName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"字段名称\", EName:\"itemEName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"说明\", EName:\"info\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:200, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:3, Hint:\"\"}");
		out.print(",{CName:\"权重\", EName:\"weight\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:6,FieldLen:4, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"指数计算方法\", EName:\"method\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"数据类型\", EName:\"dataType\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"单位\", EName:\"unit\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:10, Quote:\"\", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"小数点后位数\", EName:\"dotNum\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:12, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"填报名称\", EName:\"fillName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"填报说明\", EName:\"fillInfo\", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:\"\", FieldType:1,FieldLen:200, Quote:\"\", nCol:1, nRow:14, nWidth:1, nHeight:3, Hint:\"\"}");
		out.print(",{CName:\"汇总表计算方法\", EName:\"sumMethod\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:累加法,2:平均法,3:去零平均法,4:最新数据法,5:公式计算法.6:程序计算法)\", nCol:1, nRow:15, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"汇总表计算公式\", EName:\"sumMethodExp\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:16, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		str +=", asSysId_ex:\"" + jdb.GetQuoteValue("asSysMain",0, "ID", "cName", rs_asSysId) + "\"";
		str +=", baseId_ex:\"" + jdb.GetQuoteValue("asSysDetail",0, "ID", "itemCName", rs_baseId) + "\"";
		str +=", parentId_ex:\"" + jdb.GetQuoteValue("asSysDetail",0, "ID", "itemCName", rs_parentId) + "\"";
		str += ", method_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)", rs_method), !rs_method.equals("")) + "\"";
		str += ", dataType_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", rs_dataType), !rs_dataType.equals("")) + "\"";
		str += ", sumMethod_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:累加法,2:平均法,3:去零平均法,4:最新数据法,5:公式计算法.6:程序计算法)", rs_sumMethod), !rs_sumMethod.equals("")) + "\"";
		out.print("{asSysId:\"" + rs_asSysId + 
			"\",baseId:\"" + rs_baseId + 
			"\",parentId:\"" + rs_parentId + 
			"\",nSerial:\"" + rs_nSerial + 
			"\",itemCName:\"" + rs_itemCName + 
			"\",itemEName:\"" + rs_itemEName + 
			"\",info:\"" + WebChar.toJson(rs_info) + 
			"\",weight:\"" + rs_weight + 
			"\",method:\"" + rs_method + 
			"\",dataType:\"" + rs_dataType + 
			"\",unit:\"" + rs_unit + 
			"\",dotNum:\"" + rs_dotNum + 
			"\",fillName:\"" + rs_fillName + 
			"\",fillInfo:\"" + WebChar.toJson(rs_fillInfo) + 
			"\",sumMethod:\"" + rs_sumMethod + 
			"\",sumMethodExp:\"" + rs_sumMethodExp + 
			"\"" + str + "}");
		out.print(", {" + 
			"DataID:\"" + DataID + 
			"\", FormAction:\"asSysDetail_form.jsp\", ExcelFormID:" + ExcelFormID + "}]");
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
	var fields = [{CName:"模板", EName:"asSysId", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"asSysMain.ID,cName", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"基础指标编号", EName:"baseId", nShow:1, nReadOnly:1, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"asSysDetail.ID,itemCName", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"上级指标", EName:"parentId", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"$asSysDetail_view:DBTree", FieldType:3, FieldLen:4, Quote:"asSysDetail.ID,itemCName", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:""},
		{CName:"顺序号", EName:"nSerial", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:""},
		{CName:"指标名称", EName:"itemCName", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:""},
		{CName:"字段名称", EName:"itemEName", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:""},
		{CName:"说明", EName:"info", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:200, Quote:"", nCol:1, nRow:7, nWidth:1, nHeight:3, Hint:""},
		{CName:"权重", EName:"weight", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:6, FieldLen:4, Quote:"", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:""},
		{CName:"指数计算方法", EName:"method", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:"", FieldType:3, FieldLen:4, Quote:"(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:""},
		{CName:"数据类型", EName:"dataType", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:"", FieldType:3, FieldLen:4, Quote:"(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:""},
		{CName:"单位", EName:"unit", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:10, Quote:"", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:""},
		{CName:"小数点后位数", EName:"dotNum", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:12, nWidth:1, nHeight:1, Hint:""},
		{CName:"填报名称", EName:"fillName", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:""},
		{CName:"填报说明", EName:"fillInfo", nShow:1, nReadOnly:0, nRequired:0, InputType:5, Relation:"", FieldType:1, FieldLen:200, Quote:"", nCol:1, nRow:14, nWidth:1, nHeight:3, Hint:""},
		{CName:"汇总表计算方法", EName:"sumMethod", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:"", FieldType:3, FieldLen:4, Quote:"(1:累加法,2:平均法,3:去零平均法,4:最新数据法,5:公式计算法.6:程序计算法)", nCol:1, nRow:15, nWidth:1, nHeight:1, Hint:""},
		{CName:"汇总表计算公式", EName:"sumMethodExp", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:"", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:16, nWidth:1, nHeight:1, Hint:""}];
	var record = {asSysId:"<%=rs_asSysId%>",
		baseId:"<%=rs_baseId%>",
		parentId:"<%=rs_parentId%>",
		nSerial:"<%=rs_nSerial%>",
		itemCName:"<%=WebChar.toJson(rs_itemCName)%>",
		itemEName:"<%=WebChar.toJson(rs_itemEName)%>",
		info:"<%=WebChar.toJson(rs_info)%>",
		weight:"<%=rs_weight%>",
		method:"<%=rs_method%>",
		dataType:"<%=rs_dataType%>",
		unit:"<%=WebChar.toJson(rs_unit)%>",
		dotNum:"<%=rs_dotNum%>",
		fillName:"<%=WebChar.toJson(rs_fillName)%>",
		fillInfo:"<%=WebChar.toJson(rs_fillInfo)%>",
		sumMethod:"<%=rs_sumMethod%>",
		sumMethodExp:"<%=WebChar.toJson(rs_sumMethodExp)%>"};
	var ExcelFormID = <%=ExcelFormID%>;
	if (ExcelFormID > 0)
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"指标项", spaninput:1, gridformid:ExcelFormID});
	else
	{
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"指标项", formtype:2, nCols:1, ex:ex});
		form.appendHidden("I_DataID", "<%=DataID%>");
	}
//@@##:客户端载入时(归档用注释,切勿删改)

//(归档用注释,切勿删改) 客户端载入时 End##@@
}
</script></html>
