<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String rs_estabDate="", rs_industryType="", rs_regCost="", rs_street="", rs_bFlag1="", rs_tag1="", rs_itemValue="", rs_itemIndex="";
String strTable = "company";
String sql = "";
	int FormType = 7;
	String DataID = WebChar.requestStr(request, "DataID");
	int ModuleNo = WebChar.ToInt(request.getParameter("ModuleNo"));
	int Count = 1;
// +++++++++������ȫ��ҳ���������뿪ʼ++++++++
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
// --------������ȫ��ҳ�������������--------
	String FormTitle = "��ѯ���";
	if (WebChar.RequestInt(request, "getdesign") == 1)
	{
		String Title = "��ѯ���";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:7, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"��������\", EName:\"estabDate\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"(1:1������,2:1-2��,3:2-3��,4:3-5��,5:5������,6:�Զ���)\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"������ҵ\", EName:\"industryType\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:��Ϣ����,2:����ҽҩ,3:���ܻ���,4:�߶�����,5:����)\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"ע���ʱ�\", EName:\"regCost\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"(1:50������,2:50-100��,3:100-200��,4:200-500��,5:500������,6:�Զ���)\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"�ֵ�԰��\", EName:\"street\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"!SelectField(this,\\\"company\\\",\\\"street\\\")\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"��ҵ����\", EName:\"bFlag1\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"(1:�˹�������ҵ,2:���¼�����ҵ,3:ʡ�б������,4:�Ƽ�����С��ҵ,5:˫����ҵ)\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"�˲�����\", EName:\"tag1\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"$company,tag1\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"����ָ��\", EName:\"itemValue\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"*<div id=itemValueLine><select id=itemValueLink style=visibility:hidden><option value=and>��</option><option value=or>��</option></select><input id=itemValueName placeholder=ѡ��ָ������><select id=itemValueEq><option value=1>����</option><option value=2>���ڵ���</option><option value=3>����</option><option value=4>С�ڵ���</option><option value=5>С��</option><input id=itemValueVal placeholder=����ָ����ֵ style=width:80px>&nbsp;<input type=button id=Ins_itemValue style=width:20px value=+><input type=button id=Del_itemValue style=width:20px value=-></div>\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"����ָ��\", EName:\"itemIndex\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"*<div id=itemIndexLine><select id=itemIndexLink style=visibility:hidden><option value=and>��</option><option value=or>��</option></select><input id=itemIndexName placeholder=ѡ��ָ������><select id=itemIndexEq><option value=1>����</option><option value=2>���ڵ���</option><option value=3>����</option><option value=4>С�ڵ���</option><option value=5>С��</option><input id=itemIndexVal placeholder=����ָ����ֵ style=width:80px> <input type=button id=Ins_itemIndex style=width:20px value=+><input type=button id=Del_itemIndex style=width:20px value=-></div>\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		jdb.closeDBCon();
		return;
	}
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='company_form_filter'"));
	String FormBar = FormTitle;
	int bAppend = 0;
	if (!(DataID.equals("") || DataID.equals("0")))
	{
		sql = "select * from company where ID=" + DataID;
		ResultSet rs = jdb.rsSQL(0, sql);
		if(rs.next())
		{
			rs_estabDate = WebChar.getRSDefault(jdb.getRSString(0, rs, "estabDate"), "");
			rs_industryType = WebChar.getRSDefault(jdb.getRSString(0, rs, "industryType"), "");
			rs_regCost = WebChar.getRSDefault(jdb.getRSString(0, rs, "regCost"), "");
			rs_street = WebChar.getRSDefault(jdb.getRSString(0, rs, "street"), "");
			rs_bFlag1 = WebChar.getRSDefault(jdb.getRSString(0, rs, "bFlag1"), "");
			rs_tag1 = WebChar.getRSDefault(jdb.getRSString(0, rs, "tag1"), "");
			bAppend = 0;
			jdb.rsClose(0, rs);
		}
	}
	if (WebChar.RequestInt(request, "getflowform") == 1)
	{
		out.clear();
		out.print("[");
		String Title = "��ѯ���";
		String ex = "";
		out.print("{title: \"" +  Title + "\", formtype:7, nCols:1, ex:\"" + ex + "\", fields:[");
		out.print("{CName:\"��������\", EName:\"estabDate\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"(1:1������,2:1-2��,3:2-3��,4:3-5��,5:5������,6:�Զ���)\", FieldType:4,FieldLen:8, Quote:\"\", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"������ҵ\", EName:\"industryType\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"\", FieldType:3,FieldLen:4, Quote:\"(1:��Ϣ����,2:����ҽҩ,3:���ܻ���,4:�߶�����,5:����)\", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"ע���ʱ�\", EName:\"regCost\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"(1:50������,2:50-100��,3:100-200��,4:200-500��,5:500������,6:�Զ���)\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"�ֵ�԰��\", EName:\"street\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"!SelectField(this,\\\"company\\\",\\\"street\\\")\", FieldType:1,FieldLen:50, Quote:\"\", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"��ҵ����\", EName:\"bFlag1\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"(1:�˹�������ҵ,2:���¼�����ҵ,3:ʡ�б������,4:�Ƽ�����С��ҵ,5:˫����ҵ)\", FieldType:3,FieldLen:4, Quote:\"\", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"�˲�����\", EName:\"tag1\", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:\"\", FieldType:1,FieldLen:50, Quote:\"$company,tag1\", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"����ָ��\", EName:\"itemValue\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"*<div id=itemValueLine><select id=itemValueLink style=visibility:hidden><option value=and>��</option><option value=or>��</option></select><input id=itemValueName placeholder=ѡ��ָ������><select id=itemValueEq><option value=1>����</option><option value=2>���ڵ���</option><option value=3>����</option><option value=4>С�ڵ���</option><option value=5>С��</option><input id=itemValueVal placeholder=����ָ����ֵ style=width:80px>&nbsp;<input type=button id=Ins_itemValue style=width:20px value=+><input type=button id=Del_itemValue style=width:20px value=-></div>\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print(",{CName:\"����ָ��\", EName:\"itemIndex\", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:\"*<div id=itemIndexLine><select id=itemIndexLink style=visibility:hidden><option value=and>��</option><option value=or>��</option></select><input id=itemIndexName placeholder=ѡ��ָ������><select id=itemIndexEq><option value=1>����</option><option value=2>���ڵ���</option><option value=3>����</option><option value=4>С�ڵ���</option><option value=5>С��</option><input id=itemIndexVal placeholder=����ָ����ֵ style=width:80px> <input type=button id=Ins_itemIndex style=width:20px value=+><input type=button id=Del_itemIndex style=width:20px value=-></div>\", FieldType:100,FieldLen:0, Quote:\"\", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:\"\"}");
		out.print("]}");
		out.print(",");
		String str = "";
		str += ", industryType_ex:\"" + WebChar.isString(webenum.GetInlineEnumValue("(1:��Ϣ����,2:����ҽҩ,3:���ܻ���,4:�߶�����,5:����)", rs_industryType), !rs_industryType.equals("")) + "\"";
		out.print("{estabDate:\"" + rs_estabDate + 
			"\",industryType:\"" + rs_industryType + 
			"\",regCost:\"" + rs_regCost + 
			"\",street:\"" + rs_street + 
			"\",bFlag1:\"" + rs_bFlag1 + 
			"\",tag1:\"" + rs_tag1 + 
			"\",itemValue:\"" + WebChar.toJson(rs_itemValue) + 
			"\",itemIndex:\"" + WebChar.toJson(rs_itemIndex) + 
			"\"" + str + "}");
		out.print(", {" + 
			"DataID:\"" + DataID + 
			"\", FormAction:\"company_form_filter.jsp\", ExcelFormID:" + ExcelFormID + "}]");
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
	var fields = [{CName:"��������", EName:"estabDate", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:"(1:1������,2:1-2��,3:2-3��,4:3-5��,5:5������,6:�Զ���)", FieldType:4, FieldLen:8, Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:""},
		{CName:"������ҵ", EName:"industryType", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:"", FieldType:3, FieldLen:4, Quote:"(1:��Ϣ����,2:����ҽҩ,3:���ܻ���,4:�߶�����,5:����)", nCol:1, nRow:2, nWidth:1, nHeight:1, Hint:""},
		{CName:"ע���ʱ�", EName:"regCost", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:"(1:50������,2:50-100��,3:100-200��,4:200-500��,5:500������,6:�Զ���)", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:3, nWidth:1, nHeight:1, Hint:""},
		{CName:"�ֵ�԰��", EName:"street", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:"!SelectField(this,\"company\",\"street\")", FieldType:1, FieldLen:50, Quote:"", nCol:1, nRow:4, nWidth:1, nHeight:1, Hint:""},
		{CName:"��ҵ����", EName:"bFlag1", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:"(1:�˹�������ҵ,2:���¼�����ҵ,3:ʡ�б������,4:�Ƽ�����С��ҵ,5:˫����ҵ)", FieldType:3, FieldLen:4, Quote:"", nCol:1, nRow:5, nWidth:1, nHeight:1, Hint:""},
		{CName:"�˲�����", EName:"tag1", nShow:1, nReadOnly:0, nRequired:0, InputType:18, Relation:"", FieldType:1, FieldLen:50, Quote:"$company,tag1", nCol:1, nRow:6, nWidth:1, nHeight:1, Hint:""},
		{CName:"����ָ��", EName:"itemValue", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:"*<div id=itemValueLine><select id=itemValueLink style=visibility:hidden><option value=and>��</option><option value=or>��</option></select><input id=itemValueName placeholder=ѡ��ָ������><select id=itemValueEq><option value=1>����</option><option value=2>���ڵ���</option><option value=3>����</option><option value=4>С�ڵ���</option><option value=5>С��</option><input id=itemValueVal placeholder=����ָ����ֵ style=width:80px>&nbsp;<input type=button id=Ins_itemValue style=width:20px value=+><input type=button id=Del_itemValue style=width:20px value=-></div>", FieldType:100, FieldLen:0, Quote:"", nCol:1, nRow:7, nWidth:1, nHeight:1, Hint:""},
		{CName:"����ָ��", EName:"itemIndex", nShow:1, nReadOnly:0, nRequired:0, InputType:8, Relation:"*<div id=itemIndexLine><select id=itemIndexLink style=visibility:hidden><option value=and>��</option><option value=or>��</option></select><input id=itemIndexName placeholder=ѡ��ָ������><select id=itemIndexEq><option value=1>����</option><option value=2>���ڵ���</option><option value=3>����</option><option value=4>С�ڵ���</option><option value=5>С��</option><input id=itemIndexVal placeholder=����ָ����ֵ style=width:80px> <input type=button id=Ins_itemIndex style=width:20px value=+><input type=button id=Del_itemIndex style=width:20px value=-></div>", FieldType:100, FieldLen:0, Quote:"", nCol:1, nRow:8, nWidth:1, nHeight:1, Hint:""}];
	var record = {estabDate:"<%=rs_estabDate%>",
		industryType:"<%=rs_industryType%>",
		regCost:"<%=rs_regCost%>",
		street:"<%=WebChar.toJson(rs_street)%>",
		bFlag1:"<%=rs_bFlag1%>",
		tag1:"<%=WebChar.toJson(rs_tag1)%>",
		itemValue:"<%=WebChar.toJson(rs_itemValue)%>",
		itemIndex:"<%=WebChar.toJson(rs_itemIndex)%>"};
	var ExcelFormID = <%=ExcelFormID%>;
	if (ExcelFormID > 0)
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"��ѯ���", spaninput:1, gridformid:ExcelFormID});
	else
	{
		window.form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"��ѯ���", formtype:7, nCols:1, ex:ex});
		form.appendHidden("I_DataID", "<%=DataID%>");
	}
//@@##:�ͻ�������ʱ(�鵵��ע��,����ɾ��)

//(�鵵��ע��,����ɾ��) �ͻ�������ʱ End##@@
}
</script></html>
