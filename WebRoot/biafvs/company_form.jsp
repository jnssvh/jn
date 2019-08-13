<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_comName="", rs_comAddress="", rs_regType="", rs_approvAuthor="", rs_creditCode="", rs_estabDate="", rs_industryType="", rs_stdIndustryType="", rs_approvDate="", rs_busnissTerm="", rs_postCode="", rs_phoneNo="", rs_legalMan="", rs_locationArea="", rs_licenceAffix="", rs_mapPos="", rs_regCost="", rs_shortName="", rs_areaSize="", rs_bFlag1="", rs_bFalg2="", rs_bFlag3="", rs_bFlag4="";
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
	String FormTitle = "企业情况";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "企业情况";
		String ex = "";
		out.print("{title: \"" +  Title + "\", nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"企业名称\", EName:\"comName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:150, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"企业地址\", EName:\"comAddress\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"注册类型\", EName:\"regType\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"批准设立机关\", EName:\"approvAuthor\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"统一社会信用代码\", EName:\"creditCode\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"成立日期\", EName:\"estabDate\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属行业\", EName:\"industryType\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"国标行业代码\", EName:\"stdIndustryType\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:10, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"核准日期\", EName:\"approvDate\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"营业期限\", EName:\"busnissTerm\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"邮政编码\", EName:\"postCode\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"电话\", EName:\"phoneNo\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:12, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"法人\", EName:\"legalMan\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属地区\", EName:\"locationArea\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:14, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"营业执照\", EName:\"licenceAffix\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:15, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"地图位置\", EName:\"mapPos\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:16, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"注册资本\", EName:\"regCost\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:17, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"企业简称\", EName:\"shortName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:18, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"办公面积\", EName:\"areaSize\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:19, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"是否高新技术企业\", EName:\"bFlag1\", nShow:1, nReadOnly:0, nRequired:0, InputType:2, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:20, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"是否省市备案入库\", EName:\"bFalg2\", nShow:1, nReadOnly:0, nRequired:0, InputType:2, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:21, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"是否为科技型中小企业\", EName:\"bFlag3\", nShow:1, nReadOnly:0, nRequired:0, InputType:2, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:22, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"是否为省双软企业\", EName:\"bFlag4\", nShow:1, nReadOnly:0, nRequired:0, InputType:2, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:23, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='company_form'"));
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
			rs_regType = WebChar.getFormValue(request, "regType", y);
			rs_approvAuthor = WebChar.getFormValue(request, "approvAuthor", y);
			rs_creditCode = WebChar.getFormValue(request, "creditCode", y);
			rs_estabDate = WebChar.getFormValue(request, "estabDate", y);
			rs_industryType = WebChar.getFormValue(request, "industryType", y);
			rs_stdIndustryType = WebChar.getFormValue(request, "stdIndustryType", y);
			rs_approvDate = WebChar.getFormValue(request, "approvDate", y);
			rs_busnissTerm = WebChar.getFormValue(request, "busnissTerm", y);
			rs_postCode = WebChar.getFormValue(request, "postCode", y);
			rs_phoneNo = WebChar.getFormValue(request, "phoneNo", y);
			rs_legalMan = WebChar.getFormValue(request, "legalMan", y);
			rs_locationArea = WebChar.getFormValue(request, "locationArea", y);
			rs_licenceAffix = WebChar.getFormValue(request, "licenceAffix", y);
			rs_mapPos = WebChar.getFormValue(request, "mapPos", y);
			rs_regCost = WebChar.getFormValue(request, "regCost", y);
			rs_shortName = WebChar.getFormValue(request, "shortName", y);
			rs_areaSize = WebChar.getFormValue(request, "areaSize", y);
			rs_bFlag1 = WebChar.getFormValue(request, "bFlag1", y);
			rs_bFalg2 = WebChar.getFormValue(request, "bFalg2", y);
			rs_bFlag3 = WebChar.getFormValue(request, "bFlag3", y);
			rs_bFlag4 = WebChar.getFormValue(request, "bFlag4", y);
			if ((LineDataID == null) || LineDataID.equals(""))
			{
				selsql = "select ID from company where " + jdb.GetFieldWhereClouse("comName", rs_comName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("comAddress", rs_comAddress, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("regType", rs_regType, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("approvAuthor", rs_approvAuthor, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("creditCode", rs_creditCode, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("estabDate", rs_estabDate, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("industryType", rs_industryType, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("stdIndustryType", rs_stdIndustryType, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("approvDate", rs_approvDate, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("busnissTerm", rs_busnissTerm, 4, 0) + 
					" and " + jdb.GetFieldWhereClouse("postCode", rs_postCode, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("phoneNo", rs_phoneNo, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("legalMan", rs_legalMan, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("locationArea", rs_locationArea, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("licenceAffix", rs_licenceAffix, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("mapPos", rs_mapPos, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("regCost", rs_regCost, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("shortName", rs_shortName, 1, 0) + 
					" and " + jdb.GetFieldWhereClouse("areaSize", rs_areaSize, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("bFlag1", rs_bFlag1, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("bFalg2", rs_bFalg2, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("bFlag3", rs_bFlag3, 3, 0) + 
					" and " + jdb.GetFieldWhereClouse("bFlag4", rs_bFlag4, 3, 0) + 
					"";
				rs = jdb.rsSQL(0, selsql);
				sql = "insert into company(" + jdb.SQLField(0, "comName") + 
					"," + jdb.SQLField(0, "comAddress") + 
					"," + jdb.SQLField(0, "regType") + 
					"," + jdb.SQLField(0, "approvAuthor") + 
					"," + jdb.SQLField(0, "creditCode") + 
					"," + jdb.SQLField(0, "estabDate") + 
					"," + jdb.SQLField(0, "industryType") + 
					"," + jdb.SQLField(0, "stdIndustryType") + 
					"," + jdb.SQLField(0, "approvDate") + 
					"," + jdb.SQLField(0, "busnissTerm") + 
					"," + jdb.SQLField(0, "postCode") + 
					"," + jdb.SQLField(0, "phoneNo") + 
					"," + jdb.SQLField(0, "legalMan") + 
					"," + jdb.SQLField(0, "locationArea") + 
					"," + jdb.SQLField(0, "licenceAffix") + 
					"," + jdb.SQLField(0, "mapPos") + 
					"," + jdb.SQLField(0, "regCost") + 
					"," + jdb.SQLField(0, "shortName") + 
					"," + jdb.SQLField(0, "areaSize") + 
					"," + jdb.SQLField(0, "bFlag1") + 
					"," + jdb.SQLField(0, "bFalg2") + 
					"," + jdb.SQLField(0, "bFlag3") + 
					"," + jdb.SQLField(0, "bFlag4") + 
					") values (" + jdb.GetFieldTypeValueEx(rs_comName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_comAddress, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_regType, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_approvAuthor, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_creditCode, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_estabDate, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_industryType, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_stdIndustryType, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_approvDate, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_busnissTerm, 4, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_postCode, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_phoneNo, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_legalMan, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_locationArea, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_licenceAffix, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_mapPos, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_regCost, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_shortName, 1, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_areaSize, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_bFlag1, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_bFalg2, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_bFlag3, 3, 0) + 
					", " + jdb.GetFieldTypeValueEx(rs_bFlag4, 3, 0) + 
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
					jdb.SQLField(0, "regType") + "=" + jdb.GetFieldTypeValueEx(rs_regType, 3, 0) + ", " + 
					jdb.SQLField(0, "approvAuthor") + "=" + jdb.GetFieldTypeValueEx(rs_approvAuthor, 1, 0) + ", " + 
					jdb.SQLField(0, "creditCode") + "=" + jdb.GetFieldTypeValueEx(rs_creditCode, 1, 0) + ", " + 
					jdb.SQLField(0, "estabDate") + "=" + jdb.GetFieldTypeValueEx(rs_estabDate, 4, 0) + ", " + 
					jdb.SQLField(0, "industryType") + "=" + jdb.GetFieldTypeValueEx(rs_industryType, 3, 0) + ", " + 
					jdb.SQLField(0, "stdIndustryType") + "=" + jdb.GetFieldTypeValueEx(rs_stdIndustryType, 1, 0) + ", " + 
					jdb.SQLField(0, "approvDate") + "=" + jdb.GetFieldTypeValueEx(rs_approvDate, 4, 0) + ", " + 
					jdb.SQLField(0, "busnissTerm") + "=" + jdb.GetFieldTypeValueEx(rs_busnissTerm, 4, 0) + ", " + 
					jdb.SQLField(0, "postCode") + "=" + jdb.GetFieldTypeValueEx(rs_postCode, 1, 0) + ", " + 
					jdb.SQLField(0, "phoneNo") + "=" + jdb.GetFieldTypeValueEx(rs_phoneNo, 1, 0) + ", " + 
					jdb.SQLField(0, "legalMan") + "=" + jdb.GetFieldTypeValueEx(rs_legalMan, 1, 0) + ", " + 
					jdb.SQLField(0, "locationArea") + "=" + jdb.GetFieldTypeValueEx(rs_locationArea, 1, 0) + ", " + 
					jdb.SQLField(0, "licenceAffix") + "=" + jdb.GetFieldTypeValueEx(rs_licenceAffix, 3, 0) + ", " + 
					jdb.SQLField(0, "mapPos") + "=" + jdb.GetFieldTypeValueEx(rs_mapPos, 1, 0) + ", " + 
					jdb.SQLField(0, "regCost") + "=" + jdb.GetFieldTypeValueEx(rs_regCost, 3, 0) + ", " + 
					jdb.SQLField(0, "shortName") + "=" + jdb.GetFieldTypeValueEx(rs_shortName, 1, 0) + ", " + 
					jdb.SQLField(0, "areaSize") + "=" + jdb.GetFieldTypeValueEx(rs_areaSize, 3, 0) + ", " + 
					jdb.SQLField(0, "bFlag1") + "=" + jdb.GetFieldTypeValueEx(rs_bFlag1, 3, 0) + ", " + 
					jdb.SQLField(0, "bFalg2") + "=" + jdb.GetFieldTypeValueEx(rs_bFalg2, 3, 0) + ", " + 
					jdb.SQLField(0, "bFlag3") + "=" + jdb.GetFieldTypeValueEx(rs_bFlag3, 3, 0) + ", " + 
					jdb.SQLField(0, "bFlag4") + "=" + jdb.GetFieldTypeValueEx(rs_bFlag4, 3, 0) + " where ID=" + LineDataID;
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
				String PrintAction = jdb.GetTableValue(1, "TableAction", "PrintAction", "ID", "208");
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
		sql = "select * from company where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_comName = WebChar.getRSDefault(jdb.getRSString(0, rs, "comName"), "");
			rs_comAddress = WebChar.getRSDefault(jdb.getRSString(0, rs, "comAddress"), "");
			rs_regType = WebChar.getRSDefault(jdb.getRSString(0, rs, "regType"), "");
			rs_approvAuthor = WebChar.getRSDefault(jdb.getRSString(0, rs, "approvAuthor"), "");
			rs_creditCode = WebChar.getRSDefault(jdb.getRSString(0, rs, "creditCode"), "");
			rs_estabDate = WebChar.getRSDefault(jdb.getRSString(0, rs, "estabDate"), "");
			rs_industryType = WebChar.getRSDefault(jdb.getRSString(0, rs, "industryType"), "");
			rs_stdIndustryType = WebChar.getRSDefault(jdb.getRSString(0, rs, "stdIndustryType"), "");
			rs_approvDate = WebChar.getRSDefault(jdb.getRSString(0, rs, "approvDate"), "");
			rs_busnissTerm = WebChar.getRSDefault(jdb.getRSString(0, rs, "busnissTerm"), "");
			rs_postCode = WebChar.getRSDefault(jdb.getRSString(0, rs, "postCode"), "");
			rs_phoneNo = WebChar.getRSDefault(jdb.getRSString(0, rs, "phoneNo"), "");
			rs_legalMan = WebChar.getRSDefault(jdb.getRSString(0, rs, "legalMan"), "");
			rs_locationArea = WebChar.getRSDefault(jdb.getRSString(0, rs, "locationArea"), "");
			rs_licenceAffix = WebChar.getRSDefault(jdb.getRSString(0, rs, "licenceAffix"), "");
			rs_mapPos = WebChar.getRSDefault(jdb.getRSString(0, rs, "mapPos"), "");
			rs_regCost = WebChar.getRSDefault(jdb.getRSString(0, rs, "regCost"), "");
			rs_shortName = WebChar.getRSDefault(jdb.getRSString(0, rs, "shortName"), "");
			rs_areaSize = WebChar.getRSDefault(jdb.getRSString(0, rs, "areaSize"), "");
			rs_bFlag1 = WebChar.getRSDefault(jdb.getRSString(0, rs, "bFlag1"), "");
			rs_bFalg2 = WebChar.getRSDefault(jdb.getRSString(0, rs, "bFalg2"), "");
			rs_bFlag3 = WebChar.getRSDefault(jdb.getRSString(0, rs, "bFlag3"), "");
			rs_bFlag4 = WebChar.getRSDefault(jdb.getRSString(0, rs, "bFlag4"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	if (WebChar.RequestInt(request, "getrecord") == 1)
	{
		out.clear();
		String str = "";
		str += ", regType_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)", rs_regType), !rs_regType.equals("")) + "\"";
		out.print("{comName:\"" + rs_comName + 
			"\",comAddress:\"" + rs_comAddress + 
			"\",regType:\"" + rs_regType + 
			"\",approvAuthor:\"" + rs_approvAuthor + 
			"\",creditCode:\"" + rs_creditCode + 
			"\",estabDate:\"" + rs_estabDate + 
			"\",industryType:\"" + rs_industryType + 
			"\",stdIndustryType:\"" + rs_stdIndustryType + 
			"\",approvDate:\"" + rs_approvDate + 
			"\",busnissTerm:\"" + rs_busnissTerm + 
			"\",postCode:\"" + rs_postCode + 
			"\",phoneNo:\"" + rs_phoneNo + 
			"\",legalMan:\"" + rs_legalMan + 
			"\",locationArea:\"" + rs_locationArea + 
			"\",licenceAffix:\"" + rs_licenceAffix + 
			"\",mapPos:\"" + rs_mapPos + 
			"\",regCost:\"" + rs_regCost + 
			"\",shortName:\"" + rs_shortName + 
			"\",areaSize:\"" + rs_areaSize + 
			"\",bFlag1:\"" + rs_bFlag1 + 
			"\",bFalg2:\"" + rs_bFalg2 + 
			"\",bFlag3:\"" + rs_bFlag3 + 
			"\",bFlag4:\"" + rs_bFlag4 + 
			"\"" + str + "}");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "企业情况";
		String ex = "";
		out.print("{title: \"" +  Title + "\", nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"企业名称\", EName:\"comName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:150, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"企业地址\", EName:\"comAddress\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"注册类型\", EName:\"regType\", nShow:1, nReadOnly:0, nRequired:0, InputType:4, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"批准设立机关\", EName:\"approvAuthor\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"统一社会信用代码\", EName:\"creditCode\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"成立日期\", EName:\"estabDate\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属行业\", EName:\"industryType\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"国标行业代码\", EName:\"stdIndustryType\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:10, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"核准日期\", EName:\"approvDate\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:9, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"营业期限\", EName:\"busnissTerm\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:10, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"邮政编码\", EName:\"postCode\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:11, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"电话\", EName:\"phoneNo\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:12, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"法人\", EName:\"legalMan\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:13, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"所属地区\", EName:\"locationArea\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:14, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"营业执照\", EName:\"licenceAffix\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:15, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"地图位置\", EName:\"mapPos\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:16, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"注册资本\", EName:\"regCost\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:17, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"企业简称\", EName:\"shortName\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:1,FieldLen:20, Quote:\"\", nCol:1, nRow:18, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"办公面积\", EName:\"areaSize\", nShow:1, nReadOnly:0, nRequired:0, InputType:1, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:19, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"是否高新技术企业\", EName:\"bFlag1\", nShow:1, nReadOnly:0, nRequired:0, InputType:2, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:20, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"是否省市备案入库\", EName:\"bFalg2\", nShow:1, nReadOnly:0, nRequired:0, InputType:2, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:21, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"是否为科技型中小企业\", EName:\"bFlag3\", nShow:1, nReadOnly:0, nRequired:0, InputType:2, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:22, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"是否为省双软企业\", EName:\"bFlag4\", nShow:1, nReadOnly:0, nRequired:0, InputType:2, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:23, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		str += ", regType_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)", rs_regType), !rs_regType.equals("")) + "\"";
		out.print("{comName:\"" + rs_comName + 
			"\",comAddress:\"" + rs_comAddress + 
			"\",regType:\"" + rs_regType + 
			"\",approvAuthor:\"" + rs_approvAuthor + 
			"\",creditCode:\"" + rs_creditCode + 
			"\",estabDate:\"" + rs_estabDate + 
			"\",industryType:\"" + rs_industryType + 
			"\",stdIndustryType:\"" + rs_stdIndustryType + 
			"\",approvDate:\"" + rs_approvDate + 
			"\",busnissTerm:\"" + rs_busnissTerm + 
			"\",postCode:\"" + rs_postCode + 
			"\",phoneNo:\"" + rs_phoneNo + 
			"\",legalMan:\"" + rs_legalMan + 
			"\",locationArea:\"" + rs_locationArea + 
			"\",licenceAffix:\"" + rs_licenceAffix + 
			"\",mapPos:\"" + rs_mapPos + 
			"\",regCost:\"" + rs_regCost + 
			"\",shortName:\"" + rs_shortName + 
			"\",areaSize:\"" + rs_areaSize + 
			"\",bFlag1:\"" + rs_bFlag1 + 
			"\",bFalg2:\"" + rs_bFalg2 + 
			"\",bFlag3:\"" + rs_bFlag3 + 
			"\",bFlag4:\"" + rs_bFlag4 + 
			"\"" + str + "}");
		out.print(", {" + 
			"DataID:\"" + DataID + 
			"\", FormAction:\"company_form.jsp\", ExcelFormID:" + ExcelFormID + "}]");
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
<form action='company_form.jsp' method=POST name=ActionSave>
<input name=I_DataID type=hidden value=<%=DataID%>>
<input name=I_ModuleNo type=hidden value=<%=ModuleNo%>>
<input name=I_TableDefID type=hidden value=197>
<input name=PrintFlag type=hidden value=0>
<input name=FormSaveFlag type=hidden value=1>
<%=FormBar%>
<div id=FormBodyDiv class=jformdiv><table id=FormTableObj1 border=0 cellpadding=3 cellspacing=1 style=width:100% onkeydown=PressKey() class=jformtable1>
<tr><td id=T1_comName nowrap width=10%  class=jformcon1>企业名称</TD>
<td id=T2_comName width=90% class=jformval1 nowrap>
<input name='comName' FieldType=1 FieldLen=150 class=text style=width:100%;height:100% value='<%=rs_comName%>' title=''></td>
</tr>
<tr><td id=T1_comAddress nowrap width=10%  class=jformcon1>企业地址</TD>
<td id=T2_comAddress width=90% class=jformval1 nowrap>
<input name='comAddress' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='<%=rs_comAddress%>' title=''></td>
</tr>
<tr><td id=T1_regType nowrap width=10%  class=jformcon1>注册类型</TD>
<td id=T2_regType width=90% class=jformval1 nowrap>
<%=webenum.GetOptionfromStringSet("(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)", "regType", rs_regType, "", " size=1", "")%></td>
</tr>
<tr><td id=T1_approvAuthor nowrap width=10%  class=jformcon1>批准设立机关</TD>
<td id=T2_approvAuthor width=90% class=jformval1 nowrap>
<input name='approvAuthor' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='<%=rs_approvAuthor%>' title=''></td>
</tr>
<tr><td id=T1_creditCode nowrap width=10%  class=jformcon1>统一社会信用代码</TD>
<td id=T2_creditCode width=90% class=jformval1 nowrap>
<input name='creditCode' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='<%=rs_creditCode%>' title=''></td>
</tr>
<tr><td id=T1_estabDate nowrap width=10%  class=jformcon1>成立日期</TD>
<td id=T2_estabDate width=90% class=jformval1 nowrap>
<input name='estabDate' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='<%=rs_estabDate%>' title=''></td>
</tr>
<tr><td id=T1_industryType nowrap width=10%  class=jformcon1>所属行业</TD>
<td id=T2_industryType width=90% class=jformval1 nowrap>
<input name='industryType' FieldType=3 FieldLen=4 class=text style=width:100%;height:100% value='<%=rs_industryType%>' title=''></td>
</tr>
<tr><td id=T1_stdIndustryType nowrap width=10%  class=jformcon1>国标行业代码</TD>
<td id=T2_stdIndustryType width=90% class=jformval1 nowrap>
<input name='stdIndustryType' FieldType=1 FieldLen=10 class=text style=width:100%;height:100% value='<%=rs_stdIndustryType%>' title=''></td>
</tr>
<tr><td id=T1_approvDate nowrap width=10%  class=jformcon1>核准日期</TD>
<td id=T2_approvDate width=90% class=jformval1 nowrap>
<input name='approvDate' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='<%=rs_approvDate%>' title=''></td>
</tr>
<tr><td id=T1_busnissTerm nowrap width=10%  class=jformcon1>营业期限</TD>
<td id=T2_busnissTerm width=90% class=jformval1 nowrap>
<input name='busnissTerm' FieldType=4 FieldLen=8 class=text style=width:100%;height:100% value='<%=rs_busnissTerm%>' title=''></td>
</tr>
<tr><td id=T1_postCode nowrap width=10%  class=jformcon1>邮政编码</TD>
<td id=T2_postCode width=90% class=jformval1 nowrap>
<input name='postCode' FieldType=1 FieldLen=20 class=text style=width:100%;height:100% value='<%=rs_postCode%>' title=''></td>
</tr>
<tr><td id=T1_phoneNo nowrap width=10%  class=jformcon1>电话</TD>
<td id=T2_phoneNo width=90% class=jformval1 nowrap>
<input name='phoneNo' FieldType=1 FieldLen=20 class=text style=width:100%;height:100% value='<%=rs_phoneNo%>' title=''></td>
</tr>
<tr><td id=T1_legalMan nowrap width=10%  class=jformcon1>法人</TD>
<td id=T2_legalMan width=90% class=jformval1 nowrap>
<input name='legalMan' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='<%=rs_legalMan%>' title=''></td>
</tr>
<tr><td id=T1_locationArea nowrap width=10%  class=jformcon1>所属地区</TD>
<td id=T2_locationArea width=90% class=jformval1 nowrap>
<input name='locationArea' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='<%=rs_locationArea%>' title=''></td>
</tr>
<tr><td id=T1_licenceAffix nowrap width=10%  class=jformcon1>营业执照</TD>
<td id=T2_licenceAffix width=90% class=jformval1 nowrap>
<input name='licenceAffix' FieldType=3 FieldLen=4 class=text style=width:100%;height:100% value='<%=rs_licenceAffix%>' title=''></td>
</tr>
<tr><td id=T1_mapPos nowrap width=10%  class=jformcon1>地图位置</TD>
<td id=T2_mapPos width=90% class=jformval1 nowrap>
<input name='mapPos' FieldType=1 FieldLen=50 class=text style=width:100%;height:100% value='<%=rs_mapPos%>' title=''></td>
</tr>
<tr><td id=T1_regCost nowrap width=10%  class=jformcon1>注册资本</TD>
<td id=T2_regCost width=90% class=jformval1 nowrap>
<input name='regCost' FieldType=3 FieldLen=4 class=text style=width:100%;height:100% value='<%=rs_regCost%>' title=''></td>
</tr>
<tr><td id=T1_shortName nowrap width=10%  class=jformcon1>企业简称</TD>
<td id=T2_shortName width=90% class=jformval1 nowrap>
<input name='shortName' FieldType=1 FieldLen=20 class=text style=width:100%;height:100% value='<%=rs_shortName%>' title=''></td>
</tr>
<tr><td id=T1_areaSize nowrap width=10%  class=jformcon1>办公面积</TD>
<td id=T2_areaSize width=90% class=jformval1 nowrap>
<input name='areaSize' FieldType=3 FieldLen=4 class=text style=width:100%;height:100% value='<%=rs_areaSize%>' title=''></td>
</tr>
<tr><td id=T1_bFlag1 nowrap width=10%  class=jformcon1>是否高新技术企业</TD>
<td id=T2_bFlag1 width=90% class=jformval1 nowrap>
<input type=checkbox name='bFlag1' value=1 <%=WebChar.isString("checked ", WebChar.ToInt(rs_bFlag1)==1)%>></td>
</tr>
<tr><td id=T1_bFalg2 nowrap width=10%  class=jformcon1>是否省市备案入库</TD>
<td id=T2_bFalg2 width=90% class=jformval1 nowrap>
<input type=checkbox name='bFalg2' value=1 <%=WebChar.isString("checked ", WebChar.ToInt(rs_bFalg2)==1)%>></td>
</tr>
<tr><td id=T1_bFlag3 nowrap width=10%  class=jformcon1>是否为科技型中小企业</TD>
<td id=T2_bFlag3 width=90% class=jformval1 nowrap>
<input type=checkbox name='bFlag3' value=1 <%=WebChar.isString("checked ", WebChar.ToInt(rs_bFlag3)==1)%>></td>
</tr>
<tr><td id=T1_bFlag4 nowrap width=10%  class=jformcon1>是否为省双软企业</TD>
<td id=T2_bFlag4 width=90% class=jformval1 nowrap>
<input type=checkbox name='bFlag4' value=1 <%=WebChar.isString("checked ", WebChar.ToInt(rs_bFlag4)==1)%>></td>
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
		NewHref("TableAction.asp?nActionType=3&ActionID=0&TableDefID=197&DataID=", "menubar=0,toolbar=0,resizable=1,status=0,width=640,height=480,left=50,top=50");
}
window.onresize=ResizeActionWin;
</SCRIPT>
<%
	jdb.closeDBCon();
	out.println("</HTML>");
%>