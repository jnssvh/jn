<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
//@@##188:�������û��Զ�����������(�鵵��ע��,����ɾ��)
//
private String getEqValue(int n)
{
	switch (n)
	{
	case 1:
		return ">";
	case 2:
		return ">=";
	case 3:
		return "=";
	case 4:
		return "<=";
	case 5:
		return "<";
	case 6:
		return "<>";
	}
	return ">";	
}

private String getAsSysSubFilter(String Filter, String field, String values)
{
	String [] ss = values.split(",");
	String sub = "";
	for (int x = 0; x < ss.length; x++)
	{
		String [] sss = ss[x].split("-");
		if (sss.length < 4)
			continue;
		if (!sub.equals(""))
				sub += " " + sss[0] + " ";
			sub += "(statSysDetailId=" + sss[1] + " and " + field + getEqValue(WebChar.ToInt(sss[2])) + sss[3] + ")";
	}
	if (sub.equals(""))
		return Filter;
	if (Filter.equals(""))
		return "(" + sub + ")";
	return Filter + " and (" + sub + ")";
}

private String getCompanySubFilter(String Filter, String field, String values, String sp)
{
	String [] ss = values.split(",");
	String sub = "";
	for (int x = 0; x < ss.length; x++)
	{
		if (ss[x].equals(""))
			continue;
		if (!sub.equals(""))
			sub += " or ";
		sub += field + "=" + sp + ss[x] + sp;
	}
	if (sub.equals(""))
		return Filter;
	if (Filter.equals(""))
		return "(" + sub + ")";
	return Filter + " and (" + sub + ")";
}

//(�鵵��ע��,����ɾ��)�������û��Զ����������� End##@@

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
	String CodeName="StatResult";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='StatResult' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##179:��������������(�鵵��ע��,����ɾ��)
//

	if (WebChar.RequestInt(request, "LoadAverage") == 1)
	{
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		String sql = "select InvestDetailId, statSysDetailId, statMethodId, sValue, fillValue from asStatResult where statPlanId=" + statPlanId + " and comId=0";
		String items = jdb.getJsonBySql(0, sql);
		sql = "select ID, name, nType, dataType from asStatMethod";
		String methods = jdb.getJsonBySql(0, sql);
		out.print("{items:" + items + ", methods:" + methods + "}");
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "LoadStatRank") == 1)
	{
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		int statSysDetailId = WebChar.RequestInt(request, "statSysDetailId");
		int methodId = 0;
		if (statSysDetailId == 0)
			methodId = jdb.getIntBySql(0, "select ID from asStatMethod where name='��ҵ�ۺ�ָ��'");
		
		String sql = "select InvestDetailId, comId, comName, indexRank, valueRank, sValue, fillValue from asStatResult left join company on asStatResult.comId=company.ID where statPlanId=" + statPlanId + 
			" and statSysDetailId=" + statSysDetailId + " and statMethodId=" + methodId + " order by indexRank";
		String items = jdb.getJsonBySql(0, sql);
		out.print(items);
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "LoadCompanys") == 1)
	{
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		String companys = jdb.getStringBySql(0, "select companys from asStatPlan where ID=" + statPlanId);
		String items = jdb.getJsonBySql(0, "select ID, comName as item from company where ID in (" + companys + ")");

		out.print(items);
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "LoadStatPlan") == 1)
	{
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		ResultSet rs = jdb.rsSQL(0, "select * from asStatPlan where ID=" + statPlanId);
		if (!rs.next())
		{
			rs.close();
			jdb.closeDBCon();
			return;
		}
		int asSysMainId = rs.getInt("asSysMainId");
		String beginTime = rs.getString("beginTime");
		String endTime = rs.getString("endTime");
		String companys = rs.getString("companys");
		rs.close();
		String sql = "select ID, detailName from asInvestPlanDetail where beginTime>='" + beginTime + "' and endTime<='" + endTime 
			+ "' and mainId in (select ID from asInvestPlan where asSysMainId=" + asSysMainId + ") order by beginTime";
		String interval = jdb.getJsonBySql(0, sql);
		String tree = jdb.getTreeJson(0, "asSysDetail left join asStatSysDetail on asSysDetail.ID=asStatSysDetail.sysDetailId", "itemCName", "asSysDetail.ID", "parentId",
			"unit, asStatSysDetail.weight, asStatSysDetail.method", "asSysId=" + asSysMainId + " and asStatSysDetail.statPlanId=" + statPlanId, "");
				
		out.print("{ interval:" + interval + ", tree:" + tree + "}");	
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "CompanyFilter") == 1)
	{
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		String Filter = "";

		String estaDate = WebChar.requestStr(request, "estaDate");
		String [] ss = estaDate.split(",");
		for (int x = 0; x < ss.length; x++)
		{
			if (ss[x].equals(""))
				continue;
			if (ss[x].equals("1"))		//һ������
			{
			}
		}
		
		String industryType = WebChar.requestStr(request, "industryType");
		Filter = getCompanySubFilter(Filter, "industryType", industryType, "");

		String regCost = WebChar.requestStr(request, "regCode");
		
		String street = WebChar.requestStr(request, "street");
		Filter = getCompanySubFilter(Filter, "street", street, "'");

		String bFlag1 = WebChar.requestStr(request, "bFlag1");
		
		String tag1 = WebChar.requestStr(request, "tag1");
		Filter = getCompanySubFilter(Filter, "tag1", tag1, "'");
		
		String itemValue = WebChar.requestStr(request, "itemValue");
		String ff = getAsSysSubFilter("", "fillValue", itemValue);
		
		String itemIndex = WebChar.requestStr(request, "itemIndex");
		ff = getAsSysSubFilter(ff, "SValue", itemIndex);
		
		if (!ff.equals(""))
		{
			if (!Filter.equals(""))
				Filter += " and ";
			Filter += "ID in (select comId from asStatResult where statPlanId=" + statPlanId + " and comId>0 and " + ff + ")";		
		}
				
		String companys = jdb.getStringBySql(0, "select companys from asStatPlan where ID=" + statPlanId);
		if (Filter.equals(""))
			Filter = "ID in (" + companys + ")";
		else
			Filter = "(" + Filter + ") and ID in (" + companys + ")";
		String items = jdb.getJsonBySql(0, "select ID, comName as item from company where " + Filter);
		
		out.print(items);
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "LoadStatResult") == 1)
	{
		int comId = WebChar.RequestInt(request, "comId");
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		String sql = "select InvestDetailId, statSysDetailId, statMethodId, indexRank, valueRank, sValue, fillValue from asStatResult where statPlanId=" + statPlanId + " and comId=" + comId;
		String items = jdb.getJsonBySql(0, sql);
		out.print(items);
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "SaveChart") == 1)
	{
		int statPlanId = WebChar.RequestInt(request, "statPlanId");
		String chartName = WebChar.requestStr(request, "chartName");
		String chartOption = WebChar.requestStr(request, "chartOption");
		int id = jdb.getIntBySql(0, "select ID from asStatChart where chartName='" + chartName + "' and statPlanId=" + statPlanId);
		String sql, r;		
		if (id > 0)
		{
			sql = "update asStatChart set chartOption='" + chartOption + "', submitMan='" + user.CMemberName + "', submitTime='" + VB.Now() + "' where ID=" + id;
			r = "����ͼ�γɹ�";
		}
		else
		{
			sql = "insert into asStatChart(statPlanId, chartName, chartOption, typeName, submitMan, submitTime) values(" +
				statPlanId + ",'" + chartName + "','" + chartOption + "','δ����','" + user.CMemberName + "','" + VB.Now() + "')";
			r = "����ͼ�γɹ�";
		}
		jdb.ExecuteSQL(0, sql);
				
		out.print(r);
		jdb.closeDBCon();
		return;
	}
	


//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>�������</title>
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
<script type="text/javascript" src="<j:Prop key="ContextPath"/>js/ECharts/dist/echarts.min.js" charset='UTF-8'></script>

<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"StatResult", Role:<%=Purview%>};
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
//@@##180:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//��������:Filter
	var o = book.setDocTop("������...", "Filter", "");
	book.Filter = new $.jcom.DBCascade(o, env.fvs + "/asStatPlan_view.jsp", {}, {}, {title:["ͳ�Ʒ���","ͳ�����"]});
	book.Filter.onclick = ClickFilter;
	book.setPageObj(book.Filter);

	o = book.setDocTop("������...", "ComPane", "");
	book.Pane = new ComSeekPane(o, {});
	book.Pane.ComChange = ComChange;

	o = book.setDocTop("������...", "SysPane", "");
	new $.jcom.Cascade(o, "<div id=SeekSysTree style='padding:0px 20px;overflow:hidden;'></div>", {title:["����ָ��"]});
	book.Tree = new $.jcom.TreeView($("#SeekSysTree")[0],  [], {initDepth:2, nowrap:0});
	book.Tree.click = ClickTree;
	TreeShow(0);

	o = book.getDocObj("Page");	
	book.Page = new AsSysStatResultView(o[0], 0, {title:"ͳ�Ʊ���", mode:3});

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##181:�ͻ����Զ������(�鵵��ע��,����ɾ��)
//
function ComChange(item)
{
	book.Page.LoadCom(item);
}

function ClickFilter(obj, item)
{
	var node = "";
	if (typeof obj == "object")
		node = $(obj).attr("node");
	var ss = node.split(",");
	switch (ss.length)
	{
	case 1:
		if (item.status == 1)
			return alert("��ͳ�Ʒ������������У���ȴ�������ɺ�ˢ���ٿ���");
		if (item.status == 0)
		{
			if (window.confirm("��ͳ�Ʒ���δ�����㣬�Ƿ������������㣿"))
				$.get("StatEdit.jsp", {StartStat:1,statPlanId: item.ID}, function(s){alert(s);}); 
			return;	
		}
		book.Filter.loadLegend([{item:"��ҵͳ��"},{item:"��ҵ����"},{item:"�ۺ�ͳ��"}], node);
		book.Filter.SkipPage(1, true);
		loadSys(item);
		book.Pane.loadStatCom(item.ID, item.asSysMainId);
		break;
	case 2:
		var statplan = book.Filter.getselItem(0);
		var config = book.Filter.config();
		switch (item.item)
		{
		case "��ҵͳ��":
			book.Pane.show(1);
			TreeShow(0);
			break;
		case "��ҵ����":
			book.Pane.show(0);
			TreeShow(1);
			break;
		case "�ۺ�ͳ��":
			book.Pane.show(0);
			TreeShow(0);
			book.Page.LoadSysAvg(statplan);
			break;
		}
		break;
	}
}

function TreeShow(nShow)
{
	if (nShow == 0)
		$("#SysPane").css({display:"none"});
	else
		$("#SysPane").css({display:""});
}

function loadSys(statItem)
{
	$.get(location.pathname, {LoadStatPlan:1, statPlanId: statItem.ID}, function (data)
	{
		var o = $.jcom.eval(data);
		if (typeof o == "string")
			return alert(o);
		var items = $.extend(true, [], o.tree);
		var sysDetail = [{item:"�ۺ�ָ��", ID:0, parentId:0, child:items}];
		book.Tree.setdata(sysDetail);
		book.Pane.loadSys(sysDetail);
		book.Page.loadSys(statItem, o);
	});
};

function ClickTree(obj, e)
{
	book.Tree.select(obj);
	var item = book.Tree.getTreeItem();	
	book.Page.LoadSysRank(item);
}

function AsSysStatResultView(domobj, statPlanId, cfg)		//ͳ�Ʒ���������ϵѡ��
{
	var self = this;
	var statItem, interval, sysDetail;
	var grids = [], comData = [], chartData = [];
	var showMode = 0, oEChart;
	var comHead = [{FieldName:"item", TitleName:"ָ������", nWidth:160, nShowMode:9, bTag:1},
		{FieldName:"rank", TitleName:"����", nWidth:100, nShowMode:1},
		{FieldName:"sValue", TitleName:"ָ��ֵ", nWidth:100, nShowMode:1},
		{FieldName:"fillValue", TitleName:"ָ��ֵ", nWidth:100, nShowMode:1},
		{FieldName:"unit", TitleName:"��λ", nWidth:50, nShowMode:1},
		{FieldName:"weight", TitleName:"Ȩ��", nWidth:50, nShowMode:1},
		{FieldName:"ID", TitleName:"�Զ����", nWidth:0, nShowMode:3, bPrimaryKey:1}];	
	var rankHead = [{FieldName:"indexRank", TitleName:"����", nWidth:30, nShowMode:1},
		{FieldName:"comName", TitleName:"��ҵ����", nWidth:200, nShowMode:9, bTag:1},
		{FieldName:"sValue", TitleName:"ָ��ֵ", nWidth:50, nShowMode:1},
		{FieldName:"Map", TitleName:"��״ͼ", nWidth:360, nShowMode:1},
		{FieldName:"fillValue", TitleName:"ָ��ֵ", nWidth:100, nShowMode:3},
		{FieldName:"ID", TitleName:"�Զ����", nWidth:0, nShowMode:3, bPrimaryKey:1}];
	var avgHead = [{FieldName:"item", TitleName:"ָ������", nWidth:160, nShowMode:9, bTag:1},
		{FieldName:"sValue", TitleName:"ƽ��ָ��", nWidth:80, nShowMode:1},
		{FieldName:"fillValue", TitleName:"ƽ��ָ��", nWidth:80, nShowMode:1},
		{FieldName:"maxValue", TitleName:"���ָ��", nWidth:80, nShowMode:1},
		{FieldName:"minValue", TitleName:"��Сָ��", nWidth:80, nShowMode:1},
		{FieldName:"rangeValue", TitleName:"ָ�꼫��", nWidth:80, nShowMode:1},
		{FieldName:"sumValue", TitleName:"ָ���ܺ�", nWidth:80, nShowMode:1},
		{FieldName:"ID", TitleName:"�Զ����", nWidth:0, nShowMode:3, bPrimaryKey:1}];
	var statOption = {
		legend: {selected:{}, top: '30px'},
		tooltip: {trigger: 'axis'},
		dataset: {source: []},
		grid: {show:true,left:"10%", right:"30px", borderColor:"#c45455", bottom:"30px", top:"80px"},
		xAxis: {type: 'category', axisLabel : {interval:0}},
		yAxis: [{name:'', type:"value"}],
		series: [{type: 'bar'},{type:'bar'}, {type:'bar'}, {type:'bar'},{type:'bar'},{type:'bar'},{type:'bar'}]
		};
				
	var rankOption = {
	    tooltip: {trigger: 'axis'},
	    dataset: {source: []},
		grid:{show:true, left:"250px", right:"50px", borderColor:"#c45455", bottom:"50px",top:"80px"},
	    xAxis: {type: 'value', axisLabel : {interval:0}},
	    yAxis: [{name:'', type:"category", inverse:true, axisLabel : {textStyle:{fontSize:'13'}}}],
	    series: [{type: 'bar', seriesLayoutBy: 'row', yAxisIndex: 0, itemStyle:{normal: {label: {show: true, position: 'insideRight',}, color:'#717afe'}}}]
		};

	this.loadSys = function (item, o)
	{
		statItem = item;
		statPlanId = statItem.ID;
		self.unload();
		interval = o.interval;
		if (statItem.sumRptName == "")
			statItem.sumRptName = "���ܱ�";
		if (interval.length > 1)
			interval.splice(0, 0, {ID:0, detailName:statItem.sumRptName});
		sysDetail = [{item:"�ۺ�ָ��", ID:0, parentId:0, child:o.tree}];
		
<<<<<<< StatResult.jsp
		$(domobj).html("<div id=StatRptTitle></div><div id=StatMap></div>");
=======
		$(domobj).html("<div id=StatRptTitle></div><div id=StatMap style=width:100%;height:500px></div>");
		chartData[0] = ['ָ��'];
>>>>>>> 1.9
		PrepareGrid(sysDetail, comHead, 0);
		for (var x = 0; x < interval.length; x++)
		{
			$(domobj).append("<div id=StatRpt_" + x + "></div>");
			comData[x] = $.extend(true, [], sysDetail);
			grids[x] = new $.jcom.GridView($("#StatRpt_" + x , domobj)[0], comHead, comData[x], 
				{}, {gridstyle:1, footstyle:4, initDepth:5, nowrap:0, resizeflag:0});
			grids[x].TitleBar("<h2 align=center>" + interval[x].detailName + "</h2>");
			chartData[x + 1] = [interval[x].detailName];
			for (var y = 1; y < chartData[0].length; y++)
				chartData[x + 1][y] = 0;
		}
		oEChart = echarts.init($("#StatMap")[0]);
		oEChart.on("dblclick", SaveChart);
	};

	function SaveChart()
	{
		if (window.confirm("�Ƿ񽫵�ǰͳ��ͼ���浽չʾͼ����У�")== false)
			return;
		switch (showMode)
		{
		case 1:
		case 3:
			var s = $.jcom.toJSONStr(statOption);
			break;
		case 2:
			var s = $.jcom.toJSONStr(rankOption);
			break;
		default:
			return;
		}
		var o = {SaveChart:1, chartName:$("#StatRptTitle", domobj).text(), statPlanId:statPlanId, chartOption:s};
		$.jcom.submit(cfg.jsp, o);
	}
	
	this.unload = function()
	{
		for (var x = 0; x < grids.length; x++)
			grids[x].setDomObj();
	};
	
	this.LoadCom = function (comItem)
	{
		GridWaiting();
		$("#StatRptTitle", domobj).html("<H1 align=center>" + comItem.item + "</H1>");
		$.get(cfg.jsp, {LoadStatResult:1, statPlanId: statPlanId, comId:comItem.ID}, loadComOK);
	};

	function loadComOK(data)
	{
		var o = $.jcom.eval(data);
		for (var x = 0; x < o.length; x++)
		{
			for (var y = 0; y < interval.length; y++)
			{
				if (o[x].InvestDetailId == interval[y].ID)
				{
					var item = getSysItems(comData[y], o[x].statSysDetailId);
					if (typeof item == "object")
					{
						item.rank = o[x].indexRank;
						item.sValue = (o[x].sValue * 100 ).toFixed(2);
						item.fillValue = (o[x].fillValue * 1).toFixed(2);
						setChartItem(item, y);
					}
				}
			}
						
		}
		for (var x = 0; x < interval.length; x++)
			grids[x].reload(comData[x], comHead);
		showMode = 1;
		setChart(statOption, chartData);
	}

	this.LoadSysRank = function (item)
	{
		GridWaiting();
		$("#StatRptTitle", domobj).html("<H1 align=center>" + statItem.item + item.item + "��ҵ����</H1>");
		$.get(cfg.jsp, {LoadStatRank:1, statPlanId: statPlanId, statSysDetailId:item.ID}, LoadSysRank);
	};

	function LoadSysRank(data)
	{
		var o = $.jcom.eval(data);
		var rankData = [], rankMap = [['��ҵ'],['ָ��']];
		var color, w, cnt = 0;
		for (var y = 0; y < interval.length; y++)
		{
			rankData[y] = [];
			for (var x = 0; x < o.length; x++)
			{
				if (o[x].InvestDetailId == interval[y].ID)
				{
					o[x].sValue = (o[x].sValue * 100 ).toFixed(2);
					o[x].fillValue = (o[x].fillValue * 1).toFixed(2);
					w = parseInt(o[x].sValue * 3.50);
					if (w > 0)
						color = "blue";
					else
					{
						color = "red";
						w = -1 * w;
					}
					o[x].Map = "<div style='height:10px;background-color:" + color + ";width:" + w +"px;'></div>";
					rankData[y][rankData[y].length] = o[x];
					if (y == 0)
					{
						cnt ++;
						if (cnt < 11)
						{
							rankMap[0][cnt] = o[x].comName;
							rankMap[1][cnt] = o[x].sValue;
						}
					}
				}					
			}						
			grids[y].reload(rankData[y], rankHead);
		}
		showMode = 2;
		setChart(rankOption, rankMap);
	}

	function setChart(option, data)
	{
		oEChart.clear();
		option.dataset.source = data;
		oEChart.setOption(option);
	}
	
	function getSysItems(items, id)
	{
		for (var x = 0; x < items.length; x++)
		{
			if (items[x].ID == id)
				return items[x];
			if (typeof items[x].child == "object")
			{
				var result = getSysItems(items[x].child, id);
				if (typeof result == "object")
					return result;
			}
		}
	}
	
	function setChartItem(item, y)
	{
		for (var x = 1; x <chartData[0].length; x++)
		{
			if (chartData[0][x] == item.item.value)
				chartData[y + 1][x] = item.sValue;
		}
	}
	
	function GridWaiting()
	{
		for (var x = 0; x < interval.length; x++)
			grids[x].waiting();
	}

	this.LoadSysAvg = function (item)
	{
		GridWaiting();
		$("#StatRptTitle", domobj).html("<H1 align=center>" + statItem.item + "�ۺ�ͳ��</H1>");
		$.get(cfg.jsp, {LoadAverage:1, statPlanId:item.ID}, LoadSysAvgOK);
	};
	
	function LoadSysAvgOK(data)
	{
		var o = $.jcom.eval(data);
		for (var x = 0; x < o.items.length; x++)
		{
			for (var y = 0; y < interval.length; y++)
			{
				if (o.items[x].InvestDetailId == interval[y].ID)
				{
					var item = getSysItems(comData[y], o.items[x].statSysDetailId);
					
					if (typeof item != "object")
						continue;
					for (var z = 0; z < o.methods.length; z ++)
					{
						if (o.items[x].statMethodId == o.methods[z].ID)
						{
							switch (o.methods[z].name)
							{
							case "������ҵƽ��ָ��":
								
								item.sValue = (o.items[x].sValue * 100 ).toFixed(2);
								item.fillValue = (o.items[x].fillValue * 1).toFixed(2);
								setChartItem(item, y);
								break;
							case "���ֵ":
								item.maxValue = (o.items[x].fillValue * 1).toFixed(2);
								break;
							case "��Сֵ":
								item.minValue = (o.items[x].fillValue * 1).toFixed(2);
								break;
							case "����":
								item.rangeValue = (o.items[x].fillValue * 1).toFixed(2);
								break;
							case "�ܺ�":
								item.sumValue = (o.items[x].fillValue * 1).toFixed(2);
								break;
							}
						}
					}
				}
			}			
		}
		for (var x = 0; x < interval.length; x++)
			grids[x].reload(comData[x], avgHead);
		showMode = 3;
		setChart(statOption, chartData);
	}
	
	function PrepareGrid(items, head, depth)
	{
		for (var x = 0; x < items.length; x++)
		{
			if (depth < 2)
				chartData[0][chartData[0].length] = items[x].item;
			items[x].item = {value:items[x].item, style:"font:normal normal normal " + (18 - depth * 2) + "px ΢���ź�;"}
			if (typeof items[x].child == "object")
			{
				if (items[x].child.length == 0)
					items[x].child = undefined;
				else
					PrepareGrid(items[x].child, head, depth + 1);
			}
		}
		return items;
	}
	cfg = $.jcom.initObjVal({ title:"", jsp:location.pathname}, cfg);
}

function ComSeekPane(domobj, cfg)		//��ҵ��ѯ���
{
var self = this;
var form, cas;
var statPlanId = 0, sysMainId = 0;
var systree,dynatree;
	function init()
	{
		$(domobj).html("<div id=PaneDiv style=width:100%></div><div id=ResultDiv style=width:100%></div>")
		new $.jcom.Cascade($("#PaneDiv")[0], "<div id=SeekPane style='padding:0px 20px;overflow:hidden;'></div>", {title:["��ѯ���"]});
		form = new $.jcom.DBForm($("#SeekPane")[0],  env.fvs + "/company_form_filter.jsp");
		form.onready = FormReady;
		form.onchange = FormChange;
		form.onclick = FormClick;
		cas = new $.jcom.Cascade($("#ResultDiv")[0], [], {title:["ѡ����ҵ"]});
		cas.onclick = ClickCom;
		self.show(0);
	}

	function FormReady(fields, record, title, jsp)
	{
//		alert("ready");
	}
	
	function FormClick(field, e)
	{
		switch (e.target.id)
		{
		case "Ins_itemValue":
		case "Ins_itemIndex":
			var p = e.target.parentNode;
			field = form.getFields(e.target.id.substr(4));
			$(p).after(field.Relation.substr(1));
			var o = $("select[id='" + field.EName + "Link']");
			o.css({visibility: ""});
			o.first().css({visibility: "hidden"});
			break;
		case "Del_itemIndex":
		case "Del_itemValue":
			var p = e.target.parentNode;
			field = form.getFields(e.target.id.substr(4));
			if ($("#" + field.EName + "Link", p).css("visibility") == "hidden")
			{
				$("#" + field.EName + "Name", p).val("");
				$("#" + field.EName + "Val", p).val("");
			}
			else
				$(p).remove();
			UserChange(e, field);
			break;
		case "itemValueName":
		case "itemIndexName":
			if (dynatree == undefined)
				dynatree = new $.jcom.DynaEditor.TreeList(systree);
			dynatree.preshow(e);
			break;
		}
	}
	
	function FormChange(field, e)
	{
		if (field == undefined)
		{
			var result = UserChange(field, e);
			if (result == false)
				return;
		}
		var record = form.getRecord(1);
		$.jcom.Ajax(cfg.jsp + "?CompanyFilter=1&statPlanId=" + statPlanId, true, record, loadStatComOK);
	}

	function UserChange(field, e)
	{
		if (field == undefined)
		{
			var field = form.getFields(e.target.id.substr(0, 9));
			var p = e.target.parentNode;
			var v1 = $("#" + field.EName + "Name", p).val();
			var v2 = $("#" + field.EName + "Val", p).val();
			if ((v1 == "") || (v2 == ""))
				return false;
		}	
		var o = $("input[id='" + field.EName + "Name']");
		var val = "";
		for (var x = 0; x < o.length; x++)
		{
			v1 = o.eq(x).val();
			v2 = $("input[id='" + field.EName + "Val']").eq(x).val();
			if ((v1 == "") || (v2 == ""))
				continue;
			if (val != "")
				val += ",";
			v1 = o.eq(x).attr("node");
			val += $("select[id='" + field.EName + "Link']").eq(x).val() + "-" + v1 + "-" + $("select[id='" + field.EName + "Eq']").eq(x).val() + "-" + v2;
		}
		$("input[name='" + field.EName + "']", domobj).val(val);
		return true;
	}
	
	function ClickCom(obj, item)
	{
		self.ComChange(item);
	}
	
	this.ComChange = function(item)
	{
	};
	 
	this.show = function (bShow)
	{
		if (bShow == 1)
			$(domobj).css({display: ""});
		else
			$(domobj).css({display: "none"});
	};
	
	this.loadSys = function (sysDetail)
	{
		systree = new $.jcom.TreeView(0,  sysDetail, {initDepth:4, nowrap:0});
	};	
	
	this.loadStatCom = function (id, sysid)
	{
		statPlanId = id;
		sysMainId = sysid;		
		$.get(cfg.jsp, {LoadCompanys:1, statPlanId:id}, loadStatComOK);
	};
	
	function loadStatComOK(data)
	{
		var coms = $.jcom.eval(data);
		if (typeof coms == "string")
			return alert(coms);
		cas.reload(coms);
	}
	
	cfg = $.jcom.initObjVal({jsp:location.pathname}, cfg);
	init();
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
