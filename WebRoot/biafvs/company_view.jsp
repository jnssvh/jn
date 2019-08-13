<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
public String AjaxGetKeyword(SeekRun seekrun, int nSize, String SeekParam, String Filters)
{
	int cnt = 0;
	String result = "", Condition = "";
	SeekParam = SeekParam.replaceAll("'", "''");
	result = WebChar.joinStr(result, seekrun.GetEnumWordValue("(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)", SeekParam, 1), ",");
	if (!Filters.equals(""))
		Condition = " where (" + Filters + ") and ";
	else
		Condition = " where ";
	String [] sqls = new String [19];
	String [] fields = {"comName","comAddress","legalMan","phoneNo","street","tag1","tag2","official","regType","industryType","busnissTerm","ID","approvAuthor","creditCode","estabDate","stdIndustryType","postCode","licenceAffix","mapPos"};
	for (int x = 0; x < fields.length; x++)
		sqls[x + 0] = seekrun.jdb.SQLSelectEx(0, nSize, fields[x], "company", Condition + "(" + fields[x] + " like '%" + SeekParam + "%')", "distinct", "");
	for (int x = 0; x < sqls.length; x++)
	{
		ResultSet rs = seekrun.jdb.rsSQL(0, sqls[x]);
		try {
			while (rs.next())
			{
				if (!result.equals(""))
					result += ",";
				result += rs.getString(1);
				if (cnt ++ >= nSize - 1)
				{
					seekrun.jdb.rsClose(0, rs);
					return result;
				}
			}
			seekrun.jdb.rsClose(0, rs);
		} catch (SQLException e) {
				return "";
		}
	}
	return result;
}

public ResultSet GetSeekResult(SeekRun seekrun, String SeekKey, String SeekParam, String OrderField, int bDesc, int nPage, int nPageSize, String Filters)
{
String Condition, order, sql, id, ss;
JspWriter jout = seekrun.jout;
JDatabase jdb = seekrun.jdb;
WebUser user = seekrun.user;
WebEnum webenum = seekrun.we;
HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
	if (SeekKey.equals("$WholeDoc$") || SeekKey.equals("$ClipSearch$"))
	{
		String other = "";
		String [] sss = SeekParam.split("\\|\\|");
		if (sss.length > 1)
		{
			SeekParam = sss[0];
			other = sss[1];
		}
		Condition = "company.comName like '%" + SeekParam + 
			"%' or company.comAddress like '%" + SeekParam + 
			"%' or company.legalMan like '%" + SeekParam + 
			"%' or company.phoneNo like '%" + SeekParam + 
			"%' or company.street like '%" + SeekParam + 
			"%' or company.tag1 like '%" + SeekParam + 
			"%' or company.tag2 like '%" + SeekParam + 
			"%' or company.official like '%" + SeekParam + 
			"%' or company.regType like '%" + SeekParam + 
			"%' or company.industryType like '%" + SeekParam + 
			"%' or company.busnissTerm like '%" + SeekParam + 
			"%' or company.ID like '%" + SeekParam + 
			"%' or company.approvAuthor like '%" + SeekParam + 
			"%' or company.creditCode like '%" + SeekParam + 
			"%' or company.estabDate like '%" + SeekParam + 
			"%' or company.stdIndustryType like '%" + SeekParam + 
			"%' or company.postCode like '%" + SeekParam + 
			"%' or company.licenceAffix like '%" + SeekParam + 
			"%' or company.mapPos like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.GetEnumWordValue("(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or company.regType in (" + ss + ")";
	}
	else
	{
		if (SeekKey.equals("$LoadSeek$"))
			Condition = seekrun.LoadSeekCondition(SeekParam, seekrun.strTable, 0);
		else
		{
			String [] param = SeekParam.split("\\|\\|");
			Condition = seekrun.GetSeekCondition(SeekKey, param[0], seekrun.strTable, 0);
		}
	}
	if (!Filters.equals(""))
	{
		if (!Condition.equals(""))
			Condition = " where (" + Filters + ") and " + "(" + Condition + ")";
		else
			Condition = " where (" + Filters + ")";
	}
	else
	{
		if (!Condition.equals(""))
			Condition = " where " + "(" + Condition + ")";
	}
	String group = "";
	if (!OrderField.equals(""))
	{
		String [] sss= OrderField.split(",");
		order = null;
		for (int x = 0; x < sss.length; x++)
		{
			if (sss[x].indexOf(".") <= 0)
			sss[x] = "company." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by company.comName desc";
	String fields = "company.comName,company.comAddress,company.legalMan,company.phoneNo,company.street,company.tag1,company.tag2,company.official,company.regType,company.industryType,company.busnissTerm,company.ID,company.approvAuthor,company.creditCode,company.estabDate,company.stdIndustryType,company.postCode,company.licenceAffix,company.mapPos";
	id = "company.ID";
	if ((!order.equals("")) && (order.toLowerCase().indexOf(id.toLowerCase()) < 0))
		order = order + "," + id;
	seekrun.TotalRec = seekrun.jdb.count(0, seekrun.strTable, Condition);
	if (nPage < 1)
		nPage = 1;
	if ((nPage - 1) * nPageSize > seekrun.TotalRec)
		nPage = (seekrun.TotalRec + nPageSize - 1) / nPageSize;
	sql = seekrun.jdb.SQLSelectPage(0, nPage, nPageSize, fields, seekrun.strTable, Condition, group, order, id);
	ResultSet rs = seekrun.jdb.rsSQL(0, sql);
	seekrun.nPage = nPage;
	return rs;
}

public String GetGridData(SeekRun seekrun, String SeekKey, String SeekParam, String OrderField, int bDesc, int nPage, int nPageSize, String Filters) throws Exception
{
String value;
JspWriter jout = seekrun.jout;
JDatabase jdb = seekrun.jdb;
WebEnum webenum = seekrun.we;
HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
	ResultSet rs = GetSeekResult(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
	nPage = seekrun.nPage;
	if (seekrun.TotalRec == 0)
	{
		seekrun.jout.print("{info:{Records:0}, Data:[]");
		return "";
	}
	int x = 0;
	seekrun.jout.print("{info:{Records:" + seekrun.TotalRec + ",nPage:" + nPage + ", PageSize:" + nPageSize + ", Order:\"" + OrderField + "\", bDesc:" + bDesc + "}, Data:[");
	String dot = "";
	while (rs.next())
	{
		seekrun.jout.print(dot + "{");
		dot = ",";
		String rs_comName = WebChar.isString(jdb.getRSString(0, rs, 1));
		String rs_comAddress = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_legalMan = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_phoneNo = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_street = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_tag1 = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_tag2 = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_official = WebChar.isString(jdb.getRSString(0, rs, 8));
		String rs_regType = WebChar.isString(jdb.getRSString(0, rs, 9));
		String rs_industryType = WebChar.isString(jdb.getRSString(0, rs, 10));
		String rs_busnissTerm = WebChar.isString(jdb.getRSString(0, rs, 11));
		String rs_ID = WebChar.isString(jdb.getRSString(0, rs, 12));
		String rs_approvAuthor = WebChar.isString(jdb.getRSString(0, rs, 13));
		String rs_creditCode = WebChar.isString(jdb.getRSString(0, rs, 14));
		String rs_estabDate = WebChar.isString(jdb.getRSString(0, rs, 15));
		String rs_stdIndustryType = WebChar.isString(jdb.getRSString(0, rs, 16));
		String rs_postCode = WebChar.isString(jdb.getRSString(0, rs, 17));
		String rs_licenceAffix = WebChar.isString(jdb.getRSString(0, rs, 18));
		String rs_mapPos = WebChar.isString(jdb.getRSString(0, rs, 19));
		jout.print("comName:\"" + WebChar.toJson(rs_comName) + "\"");
		jout.print(", comAddress:\"" + WebChar.toJson(rs_comAddress) + "\"");
		value = rs_comAddress;
		String rs_comAddress_ex = value;
		jout.print(", comAddress_ex:\"" + rs_comAddress_ex + "\"");
		jout.print(", legalMan:\"" + WebChar.toJson(rs_legalMan) + "\"");
		jout.print(", phoneNo:\"" + WebChar.toJson(rs_phoneNo) + "\"");
		jout.print(", street:\"" + WebChar.toJson(rs_street) + "\"");
		jout.print(", tag1:\"" + WebChar.toJson(rs_tag1) + "\"");
		jout.print(", tag2:\"" + WebChar.toJson(rs_tag2) + "\"");
		jout.print(", official:\"" + WebChar.toJson(rs_official) + "\"");
		jout.print(", regType:\"" + rs_regType + "\"");
		String rs_regType_ex = WebChar.toJson(seekrun.ConvertFieldValue("(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)", rs_regType, 0));
		jout.print(", regType_ex:\"" + rs_regType_ex + "\"");
		jout.print(", industryType:\"" + rs_industryType + "\"");
		jout.print(", busnissTerm:\"" + rs_busnissTerm + "\"");
		jout.print(", ID:\"" + rs_ID + "\"");
		jout.print(", approvAuthor:\"" + WebChar.toJson(rs_approvAuthor) + "\"");
		jout.print(", creditCode:\"" + WebChar.toJson(rs_creditCode) + "\"");
		jout.print(", estabDate:\"" + rs_estabDate + "\"");
		jout.print(", stdIndustryType:\"" + WebChar.toJson(rs_stdIndustryType) + "\"");
		jout.print(", postCode:\"" + WebChar.toJson(rs_postCode) + "\"");
		jout.print(", licenceAffix:\"" + rs_licenceAffix + "\"");
		jout.print(", mapPos:\"" + WebChar.toJson(rs_mapPos) + "\"");
		jout.print("}");
		if (x ++ >= nPageSize - 1)
			break;
	}
	jdb.rsClose(0, rs);
	jout.print("]");
	return "";
}

public String TableSeekReport(SeekRun seekrun, String SeekKey, String SeekParam, String OrderField, int bDesc, int nPage, int nPageSize, String Filters, String href, int ViewMode) throws Exception
{
String tr1, tr2, hint, value, value0, node, id = "", bkcolor, color, item, ss, UserDefineValue, attach = "";
int TotalRec = 0, Depth=-1;
JspWriter jout = seekrun.jout;
JDatabase jdb = seekrun.jdb;
WebUser user = seekrun.user;
WebEnum webenum = seekrun.we;
HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
	ResultSet rs = GetSeekResult(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
	TotalRec = seekrun.TotalRec;
	nPage = seekrun.nPage;
	seekrun.jout.print("<DIV id=TableDoc>");
	seekrun.jout.print("<table id=SeekTable width=100% cellpadding=3 cellspacing=0 border=0 oncontextmenu='return ExSeekFunction(this);' ondblclick=DblClickSeekTable(this)>");
	if ((ViewMode % 100) == 1)
	{
		seekrun.jout.print("<TR id=SeekTitleTR oncontextmenu='TitleMenu(this);return false;'>");
		seekrun.jout.print("<TD node=comName nowrap  onclick=SetOrder(this) bTotal=0>" + "企业名称" + "</TD>");
		seekrun.jout.print("<TD node=comAddress nowrap  onclick=SetOrder(this) bTotal=0>" + "企业地址" + "</TD>");
		seekrun.jout.print("<TD node=legalMan nowrap  onclick=SetOrder(this) bTotal=0>" + "法人" + "</TD>");
		seekrun.jout.print("<TD node=phoneNo nowrap  onclick=SetOrder(this) bTotal=0>" + "电话" + "</TD>");
		seekrun.jout.print("<TD node=street nowrap  onclick=SetOrder(this) bTotal=0>" + "街道" + "</TD>");
		seekrun.jout.print("<TD node=tag1 nowrap  onclick=SetOrder(this) bTotal=0>" + "人才类型" + "</TD>");
		seekrun.jout.print("<TD node=tag2 nowrap  onclick=SetOrder(this) bTotal=0>" + "入选批次" + "</TD>");
		seekrun.jout.print("<TD node=official nowrap  onclick=SetOrder(this) bTotal=0>" + "专管员" + "</TD>");
		seekrun.jout.print("</TR>");
	}
	if (TotalRec == 0)
	{
		seekrun.jout.print("<tr><td style=color:#cccccc;border:none;padding-top:5px;padding-left:20px; clospan=7>当前视图没有数据</td><tr id=SeekTailTR><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr></table></DIV>");
	}
	else
	{
		int x = 0;
		while (rs.next())
		{
				String rs_comName = seekrun.jdb.getRSString(0, rs, 1);
				String rs_comAddress = seekrun.jdb.getRSString(0, rs, 2);
				String rs_legalMan = seekrun.jdb.getRSString(0, rs, 3);
				String rs_phoneNo = seekrun.jdb.getRSString(0, rs, 4);
				String rs_street = seekrun.jdb.getRSString(0, rs, 5);
				String rs_tag1 = seekrun.jdb.getRSString(0, rs, 6);
				String rs_tag2 = seekrun.jdb.getRSString(0, rs, 7);
				String rs_official = seekrun.jdb.getRSString(0, rs, 8);
				String rs_regType = seekrun.jdb.getRSString(0, rs, 9);
				String rs_industryType = seekrun.jdb.getRSString(0, rs, 10);
				String rs_busnissTerm = seekrun.jdb.getRSString(0, rs, 11);
				String rs_ID = seekrun.jdb.getRSString(0, rs, 12);
				String rs_approvAuthor = seekrun.jdb.getRSString(0, rs, 13);
				String rs_creditCode = seekrun.jdb.getRSString(0, rs, 14);
				String rs_estabDate = seekrun.jdb.getRSString(0, rs, 15);
				String rs_stdIndustryType = seekrun.jdb.getRSString(0, rs, 16);
				String rs_postCode = seekrun.jdb.getRSString(0, rs, 17);
				String rs_licenceAffix = seekrun.jdb.getRSString(0, rs, 18);
				String rs_mapPos = seekrun.jdb.getRSString(0, rs, 19);
			if ((ViewMode % 100) == 1)
			{
				x ++;
				bkcolor = "";
				color = "";
				tr1 = "";
				tr2 = "";
				hint = "";
				attach = "";
				value0 = WebChar.isString(rs_comName);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_comAddress);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_legalMan);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_phoneNo);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_street);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_tag1);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_tag2);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_official);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_regType);
				value = seekrun.ConvertFieldValue("(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)", value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "注册类型" + ":" + value + "\n";

				value0 = WebChar.isString(rs_industryType);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "所属行业" + ":" + value + "\n";

				value0 = WebChar.isString(rs_busnissTerm);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "营业期限" + ":" + value + "\n";

				value0 = WebChar.isString(rs_ID);
				value = value0;
				id = " node='" + WebChar.isString(rs_ID) + "'";
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "自动编号" + ":" + value + "\n";

				value0 = WebChar.isString(rs_approvAuthor);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "批准设立机关" + ":" + value + "\n";

				value0 = WebChar.isString(rs_creditCode);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "统一社会信用代码" + ":" + value + "\n";

				value0 = WebChar.isString(rs_estabDate);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "成立日期" + ":" + value + "\n";

				value0 = WebChar.isString(rs_stdIndustryType);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "国标行业代码" + ":" + value + "\n";

				value0 = WebChar.isString(rs_postCode);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "邮政编码" + ":" + value + "\n";

				value0 = WebChar.isString(rs_licenceAffix);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "营业执照" + ":" + value + "\n";

				value0 = WebChar.isString(rs_mapPos);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "地图位置" + ":" + value + "\n";

				tr1 = "<TR onclick=\"SelObject(this)\" oncontextmenu='ExSeekFunction(this);return false;'" + id + " title='" + hint + "' style='background-color:" + bkcolor + ";color:" + color + "'" + attach + ">" + tr1 + "</tr>";
				if (!tr2.equals(""))
					tr2 = "<TR id=Detail bgcolor=white style=display:none><TD colSpan=8>" + tr2 + "</td></tr>";
				seekrun.jout.print(tr1 + tr2);
			}
		}
		seekrun.jdb.rsClose(0, rs);
		seekrun.jout.print("<tr id=SeekTailTR><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>");
		seekrun.jout.print("</table>");
		seekrun.jout.print("</DIV>");
		seekrun.jout.print(seekrun.PagesFoot(TotalRec, WebChar.AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam.replace('%','*') + "&ViewMode=" + ViewMode + "&OrderField=" + OrderField + "&bDesc=" + bDesc), nPageSize, nPage, 0));
	}
	return "";
}

int RunBatAction(SeekRun seekrun, int BatchAction, String BatchValue, String BatchKey, String BatchParam)
{
String sql, sql1, sql2, FieldName, value;
String[] keys, params;
int x, y, FieldType, result = 0;
	switch (BatchAction)
	{
	case 1:			//删除
		sql = "delete from " + seekrun.strTable + " where ID in (" + BatchValue + ")";
		result = seekrun.jdb.ExecuteSQL(0, sql);
	 	SystemLog.setLog(seekrun.jdb, seekrun.user, seekrun.jreq, "6", "", seekrun.strTable, "");
		break;
	case 2:			//修改
		sql1 = "";
		keys = BatchKey.split(",");
		params = BatchParam.split(",");
		for (x = 0; x < params.length; x++)
		{
			FieldType = seekrun.jdb.GetTableFieldType(seekrun.strTable, 0, keys[x]);
			value = seekrun.jdb.GetFieldTypeValueEx(params[x], FieldType, 0);
			if (sql1.equals(""))
				sql1 = keys[x] + "=" + value;
			else
				sql1 = sql1 + ", " + keys[x] + "=" + value;
		}
		sql = "update " + seekrun.strTable + " set " + sql1 + " where ID in (" + BatchValue + ")";
		result = seekrun.jdb.ExecuteSQL(0, sql);
		break;
	case 3:			//复制后修改
		keys = BatchKey.split(",");
		params = BatchParam.split(",");
		sql = "select * from " + seekrun.strTable + " where ID in (" + BatchValue + ")";
		ResultSet rs = seekrun.jdb.rsSQL(0, sql);
		try
		{
			while (rs.next())
			{
				sql1 = "";
				sql2 = "";
				ResultSetMetaData rsmt = rs.getMetaData();
				int columnCount = rsmt.getColumnCount();
				for (x = 0; x < columnCount; x++)
				{
					FieldName = rsmt.getColumnName(x).toUpperCase();
					if (FieldName.equals("ID"))
					{
						if (sql1.equals(""))
							sql1 = FieldName;
						else
							sql1 = sql1 + "," + FieldName;
						FieldType = JDatabase.ConvertFieldType(rsmt.getColumnType(x), "", 
							rsmt.getColumnDisplaySize(x));
						value = seekrun.jdb.getRSString(0, rs, x);
						for (y = 0; y < keys.length; y++)
						{
							if (FieldName.equals(keys[y].toUpperCase()))
							{
								value = params[y];
								break;
							}
						}
						value = seekrun.jdb.GetFieldTypeValueEx(value, FieldType, 0);
						if (sql2.equals(""))
							sql2 = value;
						else
							sql2 = sql2 + "," + value;
					}
				}
				sql = "insert into " + seekrun.strTable + " (" + sql1 + ") values (" + sql2 + ")";
				result = seekrun.jdb.ExecuteSQL(0, sql);
			}
			seekrun.jdb.rsClose(0, rs);
		}
		catch(SQLException e)
		{
			System.out.println(e.getMessage());
			System.out.println(sql);
			return 0;
		}
		break;
	case 5:			//自定义删除
		result = seekrun.jdb.deleteAllData(BatchParam);
		break;
	}
	return result;
}

public String RunComplexSeek(SeekRun seekrun) throws Exception
{
	int DeleteID = WebChar.RequestInt(seekrun.jreq, "DeleteID");
	if (DeleteID > 0)
	{
		String sql = "delete from UDBCabinet where srcName='company_view' and ID=" + DeleteID;
		seekrun.jdb.ExecuteSQL(0, sql);
		seekrun.jout.print("OK");
		return "OK";
	}
	String Title = WebChar.requestStr(seekrun.jreq, "Title");
	if (!Title.equals(""))
	{
		String Content = WebChar.unApostrophe(WebChar.requestStr(seekrun.jreq, "Content"));
		String sql = "insert into UDBCabinet(nType, srcName, Title, SubmitMan, SubmitTime, Content) values(1,'company_view','" + Title + "','" + seekrun.user.CMemberName + "','" + VB.Now() + "','" + Content + "')";
		seekrun.jdb.ExecuteSQL(0, sql);
		seekrun.jout.print("OK");
		return "OK";
	}
	seekrun.jout.print(WebFace.GetHTMLHead("复合查询选择", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
		"<body alink=#333333 vlink=#333333 link=#333333 topmargin=0 leftmargin=0>");
	seekrun.jout.print("<div id=ContentDiv style=padding:8px>" + 
		"<table id=FilterTable cellpadding=0 cellspacing=0 border=0>" + 
		"<tr bgcolor=white><td width=150>字段</td><td width=40>条件</td><TD width=100>内容</td><td width=40>连接</td>" + 
		"<td bgcolor=white rowspan=2>&nbsp;<input type=button onclick=InsertCondition() value=添加></td>" + 
		"</tr><tr height=25px bgcolor=white><td><select id=FieldsSel style=width:150px; onchange=SelectFilterField(this)>");
	seekrun.jout.print("<option value=company.comName node=1 quote=''>" + "企业名称" + "</option>");
	seekrun.jout.print("<option value=company.comAddress node=1 quote=''>" + "企业地址" + "</option>");
	seekrun.jout.print("<option value=company.legalMan node=1 quote=''>" + "法人" + "</option>");
	seekrun.jout.print("<option value=company.phoneNo node=1 quote=''>" + "电话" + "</option>");
	seekrun.jout.print("<option value=company.street node=1 quote=''>" + "街道" + "</option>");
	seekrun.jout.print("<option value=company.tag1 node=1 quote=''>" + "人才类型" + "</option>");
	seekrun.jout.print("<option value=company.tag2 node=1 quote=''>" + "入选批次" + "</option>");
	seekrun.jout.print("<option value=company.official node=1 quote=''>" + "专管员" + "</option>");
	seekrun.jout.print("<option value=company.regType node=3 quote='(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)'>" + "注册类型" + "</option>");
	seekrun.jout.print("<option value=company.industryType node=3 quote=''>" + "所属行业" + "</option>");
	seekrun.jout.print("<option value=company.busnissTerm node=4 quote=''>" + "营业期限" + "</option>");
	seekrun.jout.print("<option value=company.ID node=5 quote=''>" + "自动编号" + "</option>");
	seekrun.jout.print("<option value=company.approvAuthor node=1 quote=''>" + "批准设立机关" + "</option>");
	seekrun.jout.print("<option value=company.creditCode node=1 quote=''>" + "统一社会信用代码" + "</option>");
	seekrun.jout.print("<option value=company.estabDate node=4 quote=''>" + "成立日期" + "</option>");
	seekrun.jout.print("<option value=company.stdIndustryType node=1 quote=''>" + "国标行业代码" + "</option>");
	seekrun.jout.print("<option value=company.postCode node=1 quote=''>" + "邮政编码" + "</option>");
	seekrun.jout.print("<option value=company.licenceAffix node=3 quote=''>" + "营业执照" + "</option>");
	seekrun.jout.print("<option value=company.mapPos node=1 quote=''>" + "地图位置" + "</option>");
	seekrun.jout.print("</select><td><select id=ChoiceSel><option value=1>等于</option><option value=2>不等于</option>" + 
		"<option value=3>大于</option><option value=4>小于</option><option value=5>大于等于</option>" + 
		"<option value=6>小于等于</option><option value=7>左包含</option><option value=8>右包含</option>" + 
		"<option value=9>全包含</option></select></td><TD bgcolor=white><span style='border:1px solid #7b9ebd;height:20px;overflow:hidden;width:130px;'>" + 
		"<input name=Content type=text FieldType=1 onkeydown=PressKey(this) style=border:none;height:20px;width=110px;>" + 
		"<img id=ComboImg onclick=SelectFilterCombo(this) src=../com/pic/combo.jpg onmouseover=this.src='../com/pic/combo1.jpg' onmouseout=this.src='../com/pic/combo.jpg'></span></td>" + 
		"<td><select id=ConnectSel><option value=and>并且</option><option value=or>或者</option></select></td>" + 
		"</tr></table><table><tr><td id=ContentTitleTD colspan=2>已添加的查询条件:</td><tr><td><tr><td>" + 
		"<div id=SelectedDiv style=\"width:400px;height:200px;overflow-y:auto;border:1px solid gray\">" + 
		"<table id=SelectedList width=400 border=0 style=table-layout:fixed></table></div>" +
		"<div id=LoadCatalogDiv style=\"width:400px;height:200px;overflow-y:auto;border:1px solid gray;display:none;padding:4px;\">");
	String sql = "select ID, Title, Content from UDBCabinet where nType=1 and srcName='company_view'";
	ResultSet rsCatalog = seekrun.jdb.rsSQL(0, sql);
	if (rsCatalog != null)
	{
		try
		{
			while (rsCatalog.next())
			{
				seekrun.jout.print("<div onclick=SelectCatalog(this) ondblclick=LoadSeek() node=" + rsCatalog.getString("ID") + 
					" style=cursor:default;>" + rsCatalog.getString("Title") + "</div>");
			}
		}
		catch(SQLException e)
		{
			System.out.println(e.getMessage());
			System.out.println(sql);
			return "error";
		}
	}
	seekrun.jout.print("</div></td><td valign=bottom>");
	if (rsCatalog != null)
	{
		seekrun.jout.print("<input name=LoadButton type=button onclick=LoadCondition() value=载入><br><br>" + 
			"<input name=SaveButton type=button disabled onclick=SaveCondition() value=保存><br><br>");
	}
	seekrun.jout.print("<input name=DeleteButton type=button disabled onclick=DeleteCondition() value=删除><br><br>" + 
		"<input name=SeekButton type=button onclick=ConfirmCondition() value=查询><br><br>" + 
		"<input name=CancelButton type=button onclick=CalcelSel() value=取消><br>" + 
		"</td></tr></table></div>" + 
		"<script language=javascript src=../com/psub.jsp></script>\n" +
		"<script language=javascript src=../com/Form.jsp></script>\n" +
		"<script language=javascript src=../com/seek.jsp></script>\n" +
		"<script language=javascript src=../com/common.js></script>\n" +
		"<script language=javascript>\n" +
		"window.onload = function()\n" +
		"{\n" +
		"	window.status = \"加载完成\";\n" + 
		"	SelectFilterField(document.getElementById(\"FieldsSel\"));\n" +
		"	if (parent.document.getElementById(\"InDlgTitle\") != null)\n" +
		"	{\n" + 
		"	if (parent.document.getElementById(\"InDlgTitle\").innerHTML == \"正在载入...\")\n" + 
		"		parent.document.getElementById(\"InDlgTitle\").innerHTML = document.title;\n" + 
		"	}\n" + 
		"}\n" +
		"</script></BODY></HTML>");
	return "";
}

%>
<%
	String SeekKey = WebChar.requestStr(request, "SeekKey");
	String SeekParam = WebChar.requestStr(request, "SeekParam").replace('*','%');
	int PrepID = WebChar.RequestInt(request, "PrepID");
	int ModuleID = WebChar.RequestInt(request, "ModuleNo");
	int ViewMode = WebChar.RequestInt(request, "ViewMode");
	int nPage=WebChar.RequestInt(request, "Page");
	int RootID = WebChar.RequestInt(request, "RootID");
	String OrderField = WebChar.requestStr(request, "OrderField");
	int bDesc = WebChar.RequestInt(request, "bDesc");
	int ComplexSeek = WebChar.RequestInt(request, "ComplexSeek");
	String ParentNode = WebChar.requestStr(request, "ParentNode");
	String DisableMenus = "|";
	String MenuFilter = null;
	int BatchAction = WebChar.RequestInt(request, "BatchAction");
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
// ServerSeekPageStartCode
	SeekRun seekrun = new SeekRun(jdb, webenum, user, out, request);

// --------服务器全局页面启动代码结束--------
	seekrun.strTable = "company";
	if (ModuleID > 0)
	{
		int ModuleNo = WebChar.ToInt(jdb.GetTableValue(0, "RightObject", "auth_no", "auth_id", "" + ModuleID));
		if (ModuleNo > 0)
		{
			if (user.isModuleEnable(ModuleNo) == false)
			{
				out.println("页面没有权限");
				return;
			}
		}
	}
	String Filters = "";
	if (ViewMode == 0)
		ViewMode = 1;
	seekrun.ViewMode = ViewMode;
	int nPageSize = 100;
	if (nPage == 0)
		nPage = 1;
	if (SeekKey.equals("$AjaxGetKeyword$"))
	{
		out.clear();
		out.print(AjaxGetKeyword(seekrun, 50, SeekParam, Filters));
		jdb.closeDBCon();
		return;
	}
	if (ComplexSeek > 0)
	{
		out.clear();
		RunComplexSeek(seekrun);
		jdb.closeDBCon();
		return;
	}
	if (BatchAction > 0)
	{
		String BatchValue =WebChar.requestStr(request, "BatchValue");
		String BatchKey = WebChar.requestStr(request, "BatchKey");
		String BatchParam = WebChar.requestStr(request, "BatchParam");
		int Ajax = WebChar.RequestInt(request, "Ajax");
		int result = RunBatAction(seekrun, BatchAction, BatchValue, BatchKey, BatchParam);
		jdb.closeDBCon();
		if (Ajax == 1)
		{
			if (result == 1)
				out.print("OK");
			else
				out.print("Error:" + result);
			return;
		}
		String href = request.getRequestURI();
		if 	(WebChar.request(request) != null)
		{
			String s = WebChar.request(request).replaceAll("(?i)&?(?:BatchAction|BatchValue|BatchKey|BatchParam)=[^&]*", "");
			if (!s.equals(""))
				href = request.getRequestURI() + "?" + s;
		}
		if (result == 1)
			response.sendRedirect(href);
		return;
	}
	int ajaxGetGridMode = WebChar.RequestInt(request, "GetGridData");
	if (ajaxGetGridMode > 0)
	{
		out.clear();
		switch (ajaxGetGridMode)
		{
		case 1:
			GetGridData(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
			out.print("}");
			break;
		case 2:
			GetGridData(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
			String viewhead = "[{FieldName:\"comName\", TitleName:\"企业名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"font:normal normal normal 20px 微软雅黑\",tagName:\"div\",LineNo:1}}," +
		"{FieldName:\"comAddress\", TitleName:\"企业地址\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"\",tagName:\"div\",LineNo:1}}," +
		"{FieldName:\"legalMan\", TitleName:\"法人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"phoneNo\", TitleName:\"电话\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"street\", TitleName:\"街道\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"tag1\", TitleName:\"人才类型\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"tag2\", TitleName:\"入选批次\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"official\", TitleName:\"专管员\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"regType\", TitleName:\"注册类型\", nWidth:0, nShowMode:3, Quote:\"(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)\", FieldType:3}," +
		"{FieldName:\"industryType\", TitleName:\"所属行业\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:3}," +
		"{FieldName:\"busnissTerm\", TitleName:\"营业期限\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:4}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"approvAuthor\", TitleName:\"批准设立机关\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"creditCode\", TitleName:\"统一社会信用代码\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"estabDate\", TitleName:\"成立日期\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:4}," +
		"{FieldName:\"stdIndustryType\", TitleName:\"国标行业代码\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"postCode\", TitleName:\"邮政编码\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"licenceAffix\", TitleName:\"营业执照\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:3}," +
		"{FieldName:\"mapPos\", TitleName:\"地图位置\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}]";
			out.print(", head:" + viewhead + ",TableName:\"company\", TableCName:\"企业表\", EditForm:\"company_form_brief\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetFieldInfo") == 1)
	{
		out.clear();
		out.print("[{TableName:\"company\", TableCName:\"企业表\", Fields:\"comName,comAddress,legalMan,phoneNo,street,tag1,tag2,official,regType,industryType,busnissTerm,ID,approvAuthor,creditCode,estabDate,stdIndustryType,postCode,licenceAffix,mapPos\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"comName\",ShowName:\"企业名称\",FieldType:1, FieldLen:150,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"comAddress\",ShowName:\"企业地址\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"regType\",ShowName:\"注册类型\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)\"},{FieldName:\"approvAuthor\",ShowName:\"批准设立机关\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"creditCode\",ShowName:\"统一社会信用代码\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"estabDate\",ShowName:\"成立日期\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"industryType\",ShowName:\"所属行业\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"stdIndustryType\",ShowName:\"国标行业代码\",FieldType:1, FieldLen:10,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"approvDate\",ShowName:\"核准日期\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"busnissTerm\",ShowName:\"营业期限\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"postCode\",ShowName:\"邮政编码\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"phoneNo\",ShowName:\"电话\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"legalMan\",ShowName:\"法人\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"locationArea\",ShowName:\"所属地区\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"licenceAffix\",ShowName:\"营业执照\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"mapPos\",ShowName:\"地图位置\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"official\",ShowName:\"专管员\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"province\",ShowName:\"省\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"city\",ShowName:\"市\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"conty\",ShowName:\"区县\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"street\",ShowName:\"街道\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"regCost\",ShowName:\"注册资本\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"shortName\",ShowName:\"企业简称\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"areaSize\",ShowName:\"办公面积\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"bFlag1\",ShowName:\"是否高新技术企业\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"bFalg2\",ShowName:\"是否省市备案入库\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"bFlag3\",ShowName:\"是否为科技型中小企业\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"bFlag4\",ShowName:\"是否为省双软企业\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"bFlag5\",ShowName:\"\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"bFlag6\",ShowName:\"\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"bFlag7\",ShowName:\"\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"note\",ShowName:\"备注\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"tag1\",ShowName:\"人才类型\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"tag2\",ShowName:\"入选批次\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"tag3\",ShowName:\"\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"tag4\",ShowName:\"\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"tag5\",ShowName:\"\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"comName\", TitleName:\"企业名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"font:normal normal normal 20px 微软雅黑\",tagName:\"div\",LineNo:1}}," +
		"{FieldName:\"comAddress\", TitleName:\"企业地址\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"\",tagName:\"div\",LineNo:1}}," +
		"{FieldName:\"legalMan\", TitleName:\"法人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"phoneNo\", TitleName:\"电话\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"street\", TitleName:\"街道\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"tag1\", TitleName:\"人才类型\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"tag2\", TitleName:\"入选批次\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"official\", TitleName:\"专管员\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1, FieldProp:{width:4,style:\"padding:8px\",tagName:\"span\",LineNo:1}}," +
		"{FieldName:\"regType\", TitleName:\"注册类型\", nWidth:0, nShowMode:3, Quote:\"(1:个体工商户,2:个人独资企业,3:合伙企业,4:有限合伙公司,5:有限责任公司,6:股份有限公司)\", FieldType:3}," +
		"{FieldName:\"industryType\", TitleName:\"所属行业\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:3}," +
		"{FieldName:\"busnissTerm\", TitleName:\"营业期限\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:4}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"approvAuthor\", TitleName:\"批准设立机关\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"creditCode\", TitleName:\"统一社会信用代码\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"estabDate\", TitleName:\"成立日期\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:4}," +
		"{FieldName:\"stdIndustryType\", TitleName:\"国标行业代码\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"postCode\", TitleName:\"邮政编码\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"licenceAffix\", TitleName:\"营业执照\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:3}," +
		"{FieldName:\"mapPos\", TitleName:\"地图位置\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("企业列表", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
		"<script language=javascript src=../com/psub.jsp></script>" + "\n" + 
		"<script language=javascript src=../com/common.js></script>" + "\n" + 
		"<script language=javascript src=../com/seek.jsp></script>" + "\n" +
		"<script language=javascript>\nnDefaultWinMode = 5;\n//FormFeatures = 'titlebar=0,toolbar=0,scrollbars=0,resizable=0,width=640,height=200,left=50,top=50';\n</script>" + "\n" + 
		"<body style='background:' alink=#333333 scroll=no vlink=#333333 link=#333333 topmargin=0 leftmargin=0>");
	String href = request.getRequestURI(), sMenu = "";
	if 	(WebChar.request(request) != null)
	{
		String s = WebChar.request(request).replaceAll("(?i)&?(?:SeekKey|SeekParam|OrderField|bDesc|ViewMode|PrepID|page)=[^&]*", "");
		if (!s.equals(""))
			href = request.getRequestURI() + "?" + s;
	}
	String title = "";
	if (SeekKey.equals("") && SeekParam.equals(""))
		title = "全部";
	else
	{
		if (SeekKey.equals(""))
			title = "<FONT title='" + SeekParam + "'>" + "复合查询" + "</FONT>";
		else
		{
			if (SeekKey.equals("$WholeDoc$") || SeekKey.equals("$ClipSearch$"))
				title = "<FONT title='" + "关键字" + "：" + SeekParam + "'>" + "全文检索" + "</FONT>";
			else
				title = SeekKey + "=" + SeekParam;
		}
			if (SeekKey.equals("$LoadSeek$"))
		{
				title = "检索方案：" + SeekParam;
		}
	}
	if (ViewMode < 100)
	{
	String submenu = "", exmenu1 = "", exmenu2 = "";
	sMenu = WebChar.joinStr(exmenu2, sMenu, ",");
	sMenu = WebChar.joinStr(sMenu, exmenu1, ",");
	title = "{nMode:1}";
	out.print("<div id=SeekMenubar style='with:100%;height:24px;padding:2px;background:'>载入中...</div>");
	}
	switch (ViewMode % 100)
	{
	case 1:
		TableSeekReport(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters, href, ViewMode);
		break;
	case 6:
		TableSeekReport(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters, href, ViewMode);
		break;
	case 7:
//		call MapView(TableDefID, TableStatus, FieldDB, SeekKey, SeekParam, ActionID, href, aAttrib);
		break;
	}
	out.print("<iframe name=FieldDataFrame style=display:none;></iframe>");

%>
<script language=javascript>
window.onload = function()
{
	window.menubar = new CommonMenubar([<%=sMenu%>], document.getElementById("SeekMenubar"), <%=title%>);
	InitSeekItemEvent();
	window.onresize=ResizeFrame;
	ResizeFrame();

<%
	switch (ViewMode)
	{
	case 3:
		out.print("InitTreeLine();" + "\n");
		break;
	case 4:
		out.print("InitHTreeLine();" + "\n");
		break;
	case 5:
		out.print("InitSubView()" + "\n");
		break;
	}

%>
	InitTitleOrder();
	var oSel = document.getElementsByName("PageFootSel");
	for (var x = 0; x < oSel.length; x++)
		MakeFootPage(oSel[x]);
}

function DblClickSeekTable(oTable)
{
	var obj = GetTableEventTR(oTable);
	if (obj == oTable)
		return;
	if ((typeof(obj) == "object") && (obj != null))
		DefaultDbClick(obj);
}

var href ="<%=href%>";
var SeekKey = "<%=SeekKey%>";
var SeekParam = "<%=SeekParam.replace('%', '*')%>";
var OrderField = "<%=OrderField%>";
var bDesc = <%=bDesc%>;
var ClassName = "";
var ActionID = 268;
var ViewMode = <%=ViewMode%>;
var TableDefID = 197;
var PrepID = 0;
var FormAction="company_form_brief.jsp";
var FormViewAction = "company_form.jsp";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>