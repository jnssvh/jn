<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
// ServerChapterPageStartCode
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	user = new SysUser();
	int result = user.initWebUser(jdb, cookie);
	if (result != 1)
	{//���cookie��ʧ���ʹ�������ȡ���˻�������cookie
		String EName = WebChar.requestStr(request, "UserName");
		Cookie [] ck = new Cookie[2];
		ck[0] = new Cookie("loginname", EName);
		ck[1] = new Cookie("loginpassword", WebChar.requestStr(request, "Password"));
		result = user.initWebUser(jdb, ck);
		if (result != 1)
		{
			jdb.closeDBCon();
			response.sendRedirect("../bia/login.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
	boolean isAdmin = user.isAdmin();
	String CodeName="BIDynaForm";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='BIDynaForm' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##162:��������������(�鵵��ע��,����ɾ��)
//

	if (WebChar.RequestInt(request, "ImportOldData") == 1)
	{
		int planId = jdb.getIntBySql(0, "select ID from asInvestPlan where planName='2018��ȵ���ƻ�'");
		int asSysId = jdb.getIntBySql(0, "select asSysMainId from asInvestPlan where ID=" + planId);
		String submitTime = VB.Now();
		String sql;
		int cnt = 0;
		ResultSet rs = jdb.rsSQL(0, "select * from import1");
		while (rs.next())
		{
			int comId = jdb.getIntBySql(0, "select ID from company where comName='" + rs.getString("F2") + "'");
			if (comId == 0)
			{
				System.out.println("δ�ҵ���ҵ:" + rs.getString("F2"));
				continue;
			}
			String legalMan = rs.getString("F3");
			String street =  rs.getString("F4");
			String tag1 =  rs.getString("F5");
			String tag2 =  rs.getString("F6");
			String f7 =  rs.getString("F7");
			String [] ss = f7.split("/");
			int industryType = 0;
			if (ss[0].equals("��Ϣ����"))
				industryType = 1;
			else if (ss[0].equals("����ҽҩ"))
				industryType = 2;
			else if (ss[0].equals("���ܻ���"))
				industryType = 3;
			else if (ss[0].equals("�߶�����"))
				industryType = 4;
			else if (ss[0].equals("����"))
				industryType = 5;
			int bFlag5 = 0;
			if (ss.length == 2)
				bFlag5 = 1;
			sql = "update company set legalMan='" + legalMan + "', street='" + street + "',tag1='" + tag1 + "', tag2='" + tag2 + "', industryType=" + industryType +
				",bFlag5=" + bFlag5 + " where ID=" + comId;
			jdb.ExecuteSQL(0, sql);
			cnt ++;
			sql = "select ID from asInvestPlanDetail where '��' + detailName='" + rs.getString("F8") + "'";
			int planDetailId = jdb.getIntBySql(0, sql);
			int answerId = jdb.getIntBySql(0, "select ID from asAnswer where comId=" + comId + " and planId=" + planId + " and planDetailId=" + planDetailId);
			if (answerId == 0)
			{
				sql = "insert into asAnswer (planId, planDetailId, comId, submitType, submitMan, submitTime) values(" + planId + "," + planDetailId + "," + comId + 
					",3,'" + user.CMemberName + "','" + submitTime + "')";
				jdb.ExecuteSQL(0, sql);		
				answerId = jdb.getIntBySql(0, "select ID from asAnswer where comId=" + comId + " and planId=" + planId + " and planDetailId=" + planDetailId);
			}
			String [] cols = {"��Ʊ����", "��ͬȷ�϶�", "��ҵ����˰", "��������˰", "��ֵ˰", "����˰��", "��Ȩ������", "ծ��������", "��������", "���ʲ�", "ʵ�ʹ�ֵ��", "רְԱ����", "��ְԱ����", "֪ʶ��Ȩ������", "֪ʶ��Ȩ��Ȩ��", "�²�Ʒ/������"};
			for (int x = 9; x < 25; x++)
			{
				String value = rs.getString("F" + x);
				int asSysDetailId = jdb.getIntBySql(0, "select ID from asSysDetail where itemCName='" + cols[x - 9] + "' and asSysId=" + asSysId);
				int answerDetailId = jdb.getIntBySql(0, "select ID from asAnswerDetail where answerId=" + answerId +  " and asSysDetailId=" + asSysDetailId);
				if (answerDetailId > 0)
					sql = "update asAnswerDetail set sValue='" + value + "' where ID=" + answerDetailId;
				else
					sql = "insert into asAnswerDetail(answerId, asSysDetailId, sValue) values(" + answerId + "," + asSysDetailId + ",'" + value + "')";
				result = jdb.ExecuteSQL(0, sql);
			}
		}
		out.print("OK:" + cnt);
		jdb.closeDBCon();
		return;
	}




	if (WebChar.RequestInt(request, "ImportOldDataOld") == 1)
	{
		int planId = jdb.getIntBySql(0, "select ID from asInvestPlan where planName='2018��ȵ���ƻ�'");
		int asSysId = jdb.getIntBySql(0, "select asSysMainId from asInvestPlan where ID=" + planId);
		String submitTime = VB.Now();
		String sql;
		ResultSet rs = jdb.rsSQL(0, "select * from import");
		while (rs.next())
		{
			int comId = jdb.getIntBySql(0, "select ID from company where comName='" + rs.getString("C1") + "'");
			if (comId == 0)
				continue;
			sql = "select ID from asInvestPlanDetail where '��' + detailName='" + rs.getString("C2") + "'";
			int planDetailId = jdb.getIntBySql(0, sql);
			int answerId = jdb.getIntBySql(0, "select ID from asAnswer where comId=" + comId + " and planId=" + planId + " and planDetailId=" + planDetailId);
			if (answerId == 0)
			{
				sql = "insert into asAnswer (planId, planDetailId, comId, submitType, submitMan, submitTime) values(" + planId + "," + planDetailId + "," + comId + 
					",3,'" + user.CMemberName + "','" + submitTime + "')";
				jdb.ExecuteSQL(0, sql);		
				answerId = jdb.getIntBySql(0, "select ID from asAnswer where comId=" + comId + " and planId=" + planId + " and planDetailId=" + planDetailId);
			}
			String [] cols = {"��Ʊ����", "��ͬȷ�϶�", "��ҵ����˰", "��������˰", "��ֵ˰", "����˰��", "��Ȩ������", "ծ��������", "��������", "���ʲ�", "ʵ�ʹ�ֵ��", "רְԱ����", "��ְԱ����", "����Ȩ������", "����Ȩ��Ȩ��", "�²�Ʒ/������"};
			for (int x = 3; x < 19; x++)
			{
				String value = rs.getString("C" + x);
				int asSysDetailId = jdb.getIntBySql(0, "select ID from asSysDetail where itemCName='" + cols[x - 3] + "' and asSysId=" + asSysId);
				int answerDetailId = jdb.getIntBySql(0, "select ID from asAnswerDetail where answerId=" + answerId +  " and asSysDetailId=" + asSysDetailId);
				if (answerDetailId > 0)
					sql = "update asAnswerDetail set sValue='" + value + "' where ID=" + answerDetailId;
				else
					sql = "insert into asAnswerDetail(answerId, asSysDetailId, sValue) values(" + answerId + "," + asSysDetailId + ",'" + value + "')";
				result = jdb.ExecuteSQL(0, sql);
			}
		}
		out.print("OK");
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "getPlan") == 1)
	{
		int comID = WebChar.RequestInt(request, "comID");
		String Plans = jdb.getJsonBySql(0, "select ID, planName as item, asSysMainId, fillReq from asInvestPlan where ',' + companys + ',' like '%," + comID + ",%' and status<>2");
		String Details = jdb.getJsonBySql(0, "select ID, mainId, detailName as item, beginTime, endTime, fillBeginTime, fillEndTime from asInvestPlanDetail where mainId in(" +
			 "select ID from asInvestPlan where ',' + companys + ',' like '%," + comID + ",%' and status<>2)");
		out.print("{Plans:" + Plans + ", Details:" + Details + "}");
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "LoadComAnswer") == 1)
	{
		int comId = WebChar.RequestInt(request, "comId");
		int planId = WebChar.RequestInt(request, "planId");
		int planDetailId = WebChar.RequestInt(request, "planDetailId");
		String Main = jdb.getJsonBySql(0, "select * from asAnswer where comId=" + comId + " and planId=" + planId + " and planDetailId=" + planDetailId);
		String Details = jdb.getJsonBySql(0, "select * from asAnswerDetail where answerId in(select ID from asAnswer where  comId=" +
			comId + " and planId=" + planId + " and planDetailId=" + planDetailId + ")");
		out.print("{Main:" + Main + ", Details:" + Details + "}");
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "SaveFormFlag") == 1)
	{
		int comId = WebChar.RequestInt(request, "comId");
		int planId = WebChar.RequestInt(request, "planId");
		int planDetailId = WebChar.RequestInt(request, "planDetailId");
		int status = WebChar.RequestInt(request, "status");
		String info = WebChar.requestStr(request, "info");
		
		String s = "select ID from asAnswer where comId=" + comId + " and planId=" + planId + " and planDetailId=" + planDetailId;
		int mainId = jdb.getIntBySql(0, s);
		String submitTime = VB.Now();
		String sql;
		if (mainId > 0)
		{
			if (status < 3)
				sql = "update asAnswer set status=" + status + ", submitMan='" + user.CMemberName + "', submitTime='" + submitTime + "' where ID=" + mainId;
			else
				sql = "update asAnswer set status=" + status + ", checkMan='" + user.CMemberName + "', checkTime='" + submitTime + "',info='" + info + "' where ID=" + mainId;
			result = jdb.ExecuteSQL(0, sql);
		}
		else
		{
			sql = "insert into asAnswer (planId, planDetailId, comId, submitType, status, submitMan, submitTime) values(" + planId + "," + planDetailId + "," + comId + 
				",1," + status + ",'" + user.CMemberName + "','" + submitTime + "')";
			result = jdb.ExecuteSQL(0, sql);
			mainId = jdb.getIntBySql(0, s);
		}
		String [] p = request.getParameterValues("asSysDetailId");
		for (int x = 0; x < p.length; x++)
		{
			String asSysDetailId = p[x];
			String value = WebChar.RequestForms(request, "value", x);
			int answerDetailId = jdb.getIntBySql(0, "select ID from asAnswerDetail where answerId=" + mainId + " and asSysDetailId=" + asSysDetailId);
			if (answerDetailId > 0)
				sql = "update asAnswerDetail set sValue='" + value + "' where ID=" + answerDetailId;
			else
				sql = "insert into asAnswerDetail(answerId, asSysDetailId, sValue) values(" + mainId + "," + asSysDetailId + ",'" + value + "')";
			result = jdb.ExecuteSQL(0, sql);
		}
		switch (status)
		{
		case 1:
			out.print("����ɹ�����ȫ����д��ɣ���ȷ��������ȷ��ʱ�ύ");
			break;
		case 2:
			out.print("�ύ�ɹ���лл��");
		case 3:
			out.print("���ͨ��");
			break;
		case 4:
			out.print("���δͨ�������˻���ҵ�������д");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	
	String items;
	if (isAdmin)
		items = jdb.getJsonBySql(0, "select top 300 ID, comName as item from company");
	else
		items = jdb.getJsonBySql(0, "select ID, comName as item from company where official='" + user.CMemberName + "'");

//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>��ҵ��̬����</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2019-4-28 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../bia/bia.js"></script>

<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"BIDynaForm", Role:<%=Purview%>};
var env = {com:"../com", proj:"../bia", fvs:"../biafvs", flow:"../biaflow", page:"../biapages"};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px ΢���ź�'>û��Ȩ��ʹ�ñ�ҳ��</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	
	var Tools = [
		{item:"����", img:"", action:Import, info:"", Attrib:0, Param:1},
		{item:"����", img:"", action:Output, info:"", Attrib:0, Param:1},
		{item:"����", img:"", action:Save, info:"", Attrib:0, Param:1},
		{item:"�ύ", img:"", action:Submit, info:"", Attrib:0, Param:1}
			];
	book.setTool(Tools);
//@@##151:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
	if (comItems.length == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px ΢���ź�'>ֻ����ҵ�û���ר��Ա�ſ���ʹ�ñ�ҳ�档</div>");
		return;
	}
	var o = book.setDocTop("������...", "Filter", "");
	for (var x = 0; x < comItems.length; x++)
		comItems[x].nType = 0;
	if (comItems.length > 1)
		book.Filter = new $.jcom.Cascade(o, comItems, {title:["��ҵ�б�","����ƻ�","�ƻ���ϸ"]});
	else
	{
		book.Filter = new $.jcom.Cascade(o, [], {title:["����ƻ�","�ƻ���ϸ"]});
		ClickFilter(0, comItems[0]);
	}
	book.Filter.onclick = ClickFilter;
	book.setPageObj(book.Filter);
	book.Filter.SkipPage(1, true);


//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##159:�ͻ����Զ������(�鵵��ע��,����ɾ��)
var comItems = <%=items%>;
function ClickFilter(obj, item)
{
	var node = "";
	if (typeof obj == "object")
		node = $(obj).attr("node");
	switch (item.nType)
	{
	case 0:
		$.get(location.pathname, {getPlan:1, comID: item.ID}, function(data)
		{
			var o = $.jcom.eval(data);
			if (typeof o == "string")
				return alert(o);
			for (var x = 0; x < o.Plans.length; x++)
			{
				o.Plans[x].nType = 1;
				o.Plans[x].child = [];
			}
			for (var x = 0; x < o.Details.length; x++)
			{
				o.Details[x].nType = 2;
				for (var y = 0; y < o.Plans.length; y++)
				{
					if (o.Plans[y].ID == o.Details[x].mainId)
						o.Plans[y].child[o.Plans[y].child.length] = o.Details[x];
				}
			}
			book.Filter.loadLegend(o.Plans, node);
			book.Filter.SkipPage(1, true);
		});
		break;
	case 1:
		book.Filter.SkipPage(1, true);
		break;
	case 2:
		var plan = book.Filter.getselItem(1);
		var com = book.Filter.getselItem(0);
		if (book.Page == undefined)
		{
			var o = book.getDocObj("Page")[0];
			book.Page = new AsSysInvestView(o, 0, {mode:2});
		}
		book.Page.loadAskPaper(com, plan, item);
		break;
	}	
}

function LoadPlanOK(data)
{
	book.Filter.alert(data);
}

function Import(obj, item)	//����
{
//
	$.get(location.pathname, {ImportOldData:1}, function(s){alert(s);});
}



function Output(obj, item)	//����
{
//

}



function Save(obj, item)	//����
{
//
	book.Page.SaveForm(1);
}



function Submit(obj, item)	//�ύ
{
//
	book.Page.SaveForm(2);

}


//(�鵵��ע��,����ɾ��)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
