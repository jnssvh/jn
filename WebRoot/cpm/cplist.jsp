<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.text.*,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@page import="java.util.Date"%> 
<%@ include file="../init_comm.jsp"%>
<%!
public String AjaxGetData(JDatabase jdb, int DeptID, int year)
{
	if (year == 0)
		year = WebChar.ToInt(new SimpleDateFormat("yyyy").format(new Date()));
	String sql = "select ID, CName, CPDuty, CPFee, Info from CP_Member where CPDeptID=" + DeptID;
	String memberJSON = jdb.getJsonBySql(0, sql);
	sql = "select ID, nQuarter, Fees, OrgMan, nMember, Info, SubmitMan, SubmitTime from CP_Fees where CPDept=" + DeptID + " and nYear=" + year;
	String feeJSON = jdb.getJsonBySql(0, sql);
	sql = "select * from CP_ActionItem where CPDept=" + DeptID + " and actTime>='" + year + ".1.1' and actTime<='" + year + ".12.31' and ActionID=1";
	String actJSON1 = jdb.getJsonBySql(0, sql);
	sql = "select * from CP_ActionItem where CPDept=" + DeptID + " and actTime>='" + year + ".1.1' and actTime<='" + year + ".12.31' and ActionID=2";
	String actJSON2 = jdb.getJsonBySql(0, sql);
	sql = "select * from CP_ActionItem where CPDept=" + DeptID + " and actTime>='" + year + ".1.1' and actTime<='" + year + ".12.31' and ActionID=3";
	String actJSON3 = jdb.getJsonBySql(0, sql);
	return "{member:" + memberJSON + ", fee:" + feeJSON + ", act1: " + actJSON1 + ", act2:" + actJSON2 + ", act3:" + actJSON3 + "}";
}
%>
<%
	if (WebChar.RequestInt(request, "DeleteFlag") == 1)
	{
		int ID = WebChar.RequestInt(request, "CP_DeptID");
		if (ID > 0)
		{
			String sql = "delete from CP_Dept where ID=" + ID;
			out.print("Result:" + jdb.ExecuteSQL(0, sql));
			return;
		}
		ID = WebChar.RequestInt(request, "CP_MemberID");
		if (ID > 0)
		{
			String sql = "delete from CP_Member where ID=" + ID;
			out.print("Result:" + jdb.ExecuteSQL(0, sql));
			return;
		}
		ID = WebChar.RequestInt(request, "CP_FeeID");
		if (ID > 0)
		{
			String sql = "delete from CP_Fees where ID=" + ID;
			out.print("Result:" + jdb.ExecuteSQL(0, sql));
			return;
		}

		ID = WebChar.RequestInt(request, "CP_ActionID");
		if (ID > 0)
		{
			String sql = "delete from CP_ActionItem where ID=" + ID;
			out.print("Result:" + jdb.ExecuteSQL(0, sql));
			return;
		}
		return;
	}
	
	if(WebChar.RequestInt(request, "BatchAddFlag")== 1)
	{
		String users = WebChar.requestStr(request, "Users");
		int CPDeptID = WebChar.RequestInt(request, "DeptID");
		String sql = "select ID, CName,Dept,Mobile,EMail,Duty from Member where CName in ('" + users.replaceAll(",", "','") + "'" + ")";
		ResultSet rs = jdb.rsSQL(0, sql);
		while (rs.next())
		{
			sql = "select ID from CP_Member where CName='" + rs.getString("CName") + "'";
			ResultSet rs1 = jdb.rsSQL(0, sql);
			if (rs1.next())
				sql = "update CP_Member set CName='" + rs.getString("CName") + "', MemberID=" + rs.getString("ID") +
					", CPDeptID=" + CPDeptID + " where ID=" + rs1.getString("ID");
			else
				sql = "insert into CP_Member (CName, MemberID, CPDeptID) values('" + rs.getString("CName") +
					"'," + rs.getString("ID") + "," + CPDeptID + ")";
				jdb.ExecuteSQL(0, sql);
				jdb.rsClose(0, rs1);
		}
		jdb.rsClose(0, rs);
		out.print("OK");
		return;
	}

	if (WebChar.RequestInt(request, "Ajax") == 1)
	{
		int DeptID = WebChar.RequestInt(request, "DeptID");
		int year = WebChar.RequestInt(request, "year");
		out.print(AjaxGetData(jdb, DeptID, year));
		return;
	}
	String deptTree = jdb.getTreeJson(0, "CP_Dept", "DeptName", "ID", "ParentID", "", "", "");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head><title></title>   
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<link rel="stylesheet" type="text/css" href="../forum.css">
<style type="text/css">
#HeadTR TD
{
	border-top:		0px solid #cccccc;
}

.test{width:0; height:0; border-width:20px 10px; border-style:solid; border-color:#ff3300 #ff3300 #ffffff #ffffff;}
</style>
<script language=javascript src=../com/psub.jsp></script>
<script language=javascript src=../com/common.js></script>
<script type="text/javascript">
var deptList, yearList;
var menubar, tree, split;
var memberview, feeview, actid, actionview, actionview1, actionview2, actionview3;
var deptData = <%=deptTree%>;
var deptID = 0;
var year = (new Date()).getFullYear();
var treemenu, membermenu, feemenu, actmenu;
function window.onload()
{
	split = new Split(document.all.LeftDiv, document.all.RightDiv, 0, 0, 0, 1);
	document.all.YearSpan.innerText = year;
	document.all.YearSel.innerText = year;
	tree = new TreeView(document.all.DeptTreeDiv, deptData, {initDepth:3,vpadding:4});
	tree.setexpic(["../com/pic/minus.gif", "../com/pic/plus.gif"]);
	tree.click = treeDeptChange;
	tree.contextmenu = TreeMenuRun;
	tree.dblclick = EditCPDept;
	treemenu = new CommonMenu([{item:"新建支部", action:NewCPDept}, 	
		{item:"编辑支部", action:EditCPDept},	{item:"删除支部", action:DeleteCPDept}]);
	membermenu = new CommonMenu([{item:"新增党员", action:NewMember},
					{item:"从组织机构中导入党员", action:ImportMember},{},
					{item:"编辑党员", action:EditMember},{},
					{item:"删除党员", action:DeleteMember}]);
	feemenu = new CommonMenu([{item:"新增党费收缴记录", action:NewFee},
					{item:"编辑党费收缴记录", action:EditFee},
					{item:"删除党费收缴记录", action:DeleteFee}]);
	actmenu = new CommonMenu([{item:"新增", action:NewAction},
					{item:"编辑", action:EditAction},
					{item:"删除", action:DeleteAction}]);
//					{item:"查看员工信息", action:ViewMember},
//					{item:"查看党员信息", action:ViewCPMember},{},
		
	memberview = new GridView(document.all.CPInfo,
	[{FieldName:"CName", TitleName:"姓名", nWidth:90, nShowMode:1},
	{FieldName:"CPDuty", TitleName:"党内职务", nWidth:80, nShowMode:1},
	{FieldName:"CPFee", TitleName:"党费基准", nWidth:48, nShowMode:1},
	{FieldName:"Info", TitleName:"说明", nWidth:280, nShowMode:1}],[],{}, 
	{gridstyle:1, headstyle:1, bodystyle:1, footstyle:0, 
		bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff", 
		nowrap:0,
		rightmenu:null});
	memberview.dblclickRow = EditMember;
	feeview = new GridView(document.all.CPFee,
	[{FieldName:"nQuarter", TitleName:"季度", nWidth:48, nShowMode:1},
	{FieldName:"nMember", TitleName:"党员人数", nWidth:80, nShowMode:1},
	{FieldName:"Fees", TitleName:"党费数量", nWidth:80, nShowMode:1},
	{FieldName:"OrgMan", TitleName:"组织委员", nWidth:60, nShowMode:1},
	{FieldName:"Info", TitleName:"说明", nWidth:180, nShowMode:1},
	{FieldName:"SubmitMan", TitleName:"提交人", nWidth:60, nShowMode:1}],[],{}, 
	{gridstyle:1, headstyle:1, bodystyle:1, footstyle:0, 
		bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff", 
		nowrap:0,
		rightmenu:null});
	feeview.dblclickRow = EditFee;
	var Field = [{FieldName:"ActTime", TitleName:"活动时间", nWidth:90, nShowMode:1, exp:"&d:1"},
		{FieldName:"OtherDept", TitleName:"参加支部", nWidth:80, nShowMode:1},
		{FieldName:"ActPlace", TitleName:"活动地点", nWidth:80, nShowMode:1},
		{FieldName:"Leader", TitleName:"负责人", nWidth:60, nShowMode:1},
		{FieldName:"nMembers", TitleName:"人数", nWidth:40, nShowMode:1},
		{FieldName:"ActName", TitleName:"名称", nWidth:180, nShowMode:1},
		{FieldName:"ActNote", TitleName:"备注", nWidth:120, nShowMode:1}];
	
	actionview1 = new GridView(document.all.CPAction1,Field, [],{},
		{gridstyle:1, headstyle:1, bodystyle:1, footstyle:0, 
		bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff", 
		nowrap:0, rightmenu:null});
	actionview1.dblclickRow = EditAction1;

	actionview2 = new GridView(document.all.CPAction2, Field, [],{}, 
		{gridstyle:1, headstyle:1, bodystyle:1, footstyle:0, 
		bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff", 
		nowrap:0, rightmenu:null});
	actionview2.dblclickRow = EditAction2;

	actionview3 = new GridView(document.all.CPAction3, Field, [],{}, 
	{gridstyle:1, headstyle:1, bodystyle:1, footstyle:0, 
		bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff", 
		nowrap:0, rightmenu:null});
	actionview3.dblclickRow = EditAction3;
	memberview.bodymenu = MemberMenuRun;
	feeview.bodymenu = FeeMenuRun;
	actionview1.bodymenu = ActionMenuRun1;
	actionview2.bodymenu = ActionMenuRun2;
	actionview3.bodymenu = ActionMenuRun3;
	
	deptList = new DynaEditor.TreeList(deptData, 300, 200);
	deptList.setexpic(["../com/pic/minus.gif", "../com/pic/plus.gif"]);
	deptList.attach(document.all.DeptSpan, 1);
	deptList.valueChange = deptChange;
	yeardata = "" + year;
	for (var x = 1; x < 20; x ++)
		yeardata += "," + (year - x)
	yearList = new DynaEditor.List(yeardata, 100, 100);
	yearList.attach(document.all.YearSpan, 1);
	yearList.attach(document.all.YearSel, 1);
	yearList.valueChange = yearChange;
	
	var obj = tree.getNodeObj(0, "0,0");
	if (typeof obj == "object")
		treeDeptChange(obj);
}

function GetDeptData(data)
{
	eval("var json = " + data + ";");
	
	memberview.reload(json.member);
	feeview.reload(json.fee);
	actionview1.reload(json.act1);
	actionview2.reload(json.act2);
	actionview3.reload(json.act3);	
}

function treeDeptChange(obj)
{
	tree.select(obj);
	document.all.DeptSpan.innerText = obj.innerText;
	deptID = getDeptIDByName(deptData, obj.innerText);
	if (typeof deptID != "undefined")
		AjaxRequestPage(location.pathname + "?Ajax=1&DeptID=" + deptID + "&year=" + year, true, "", GetDeptData);
}

function deptChange(obj)
{
	var obj = tree.getNodeObj("item", obj.innerText);
	treeDeptChange(obj);
}

function yearChange(obj)
{
	year = obj.innerText;
	AjaxRequestPage(location.pathname + "?Ajax=1&DeptID=" + deptID + "&year=" + year, true, "", GetDeptData);
	document.all.YearSpan.innerText = year;
	document.all.YearSel.innerText = year;
}

function getDeptIDByName(data, name)
{
	for (var x = 0; x < data.length; x++)
	{
		if (name == data[x].item)
			return data[x].ID;
		if (typeof data[x].child == "object")
		{
			var id = getDeptIDByName(data[x].child, name);
			if (typeof id != "undefined")
				return id;
		}
	}
}

function TreeMenuRun(obj)
{
		tree.select(obj);
		treemenu.show();
		return false;
}

function MemberMenuRun()
{
	memberview.clickRow(event.srcElement.parentNode);
	membermenu.show();
	return false;
}

function FeeMenuRun()
{
	feemenu.show();
	return false;
}

function ActionMenuRun()
{
	actmenu.show();
	return false;
}

function ActionMenuRun1()
{
	actionview = actionview1;
	actid = 1;
	return ActionMenuRun();
}

function ActionMenuRun2()
{
	actionview = actionview2;
	actid = 2;
	return ActionMenuRun();
}

function ActionMenuRun3()
{
	actionview = actionview3;
	actid = 3;
	return ActionMenuRun();
}

function NewCPDept()
{
	NewHref("../fvs/CP_Dept_form.jsp", "width=1024", "_blank", 2);
}

function EditCPDept(obj)
{
	var item = tree.getTreeItem();
	NewHref("../fvs/CP_Dept_form.jsp?DataID=" + item.ID, "width=1024", "_blank", 2);
}

function DeleteCPDept()
{
	if (window.confirm("删除支部不可恢复，是否确定") == false)
		return;
	var item = tree.getTreeItem();
	AjaxRequestPage(location.pathname + "?DeleteFlag=1&CP_DeptID=" + item.ID, true, "", "location.reload()");
}

function NewMember()
{
	NewHref("../fvs/CP_Member_form.jsp?CPDeptID=" + deptID, "", "_blank", 2);
}

function ImportMember()
{
	var item = tree.getTreeItem();
	var result = SelectDialog("", "../selmember.jsp", "dialogWidth:580px;dialogheight:480px;scroll:0;help:0;status:0", "");
	if (typeof(result) == "undefined")
		return;
	AjaxRequestPage(location.pathname + "?BatchAddFlag=1&DeptID=" + item.ID + "&Users=" + result, true, "", function(data){alert(data);});

}

function EditMember()
{
	var item = memberview.getItemData();
	NewHref("../fvs/CP_Member_form.jsp?DataID=" + item.ID, "", "_blank", 2);
}

function ViewMember()
{
	NewHref("../fvs/CP_Member_form.jsp", "", "_blank", 2);
}

function ViewCPMember()
{
	NewHref("../fvs/CP_Member_form1.jsp", "", "_blank", 2);
}

function DeleteMember()
{
	if (window.confirm("删除党员不可恢复，是否确定") == false)
		return;
	var item = memberview.getItemData();
	AjaxRequestPage(location.pathname + "?DeleteFlag=1&CP_MemberID=" + item.ID, true, "", "location.reload()");
}

function NewFee()
{
	NewHref("../fvs/CP_Fees_form.jsp?CPDeptID=" + deptID + "&year=" + year, "", "_blank", 2);
}

function EditFee()
{
	var item = feeview.getItemData();
	NewHref("../fvs/CP_Fees_form.jsp?DataID=" + item.ID, "", "_blank", 2);
}

function DeleteFee()
{
	if (window.confirm("删除党费记录不可恢复，是否确定") == false)
		return;
	var item = feeview.getItemData();
	AjaxRequestPage(location.pathname + "?DeleteFlag=1&CP_FeeID=" + item.ID, true, "", "location.reload()");
}

function NewAction(ActionID)
{
	if (typeof ActionID == "undefined")
		ActionID = actid;
	NewHref("../fvs/CP_ActionItem_form.jsp?CPDeptID=" + deptID + "&ActionID=" + ActionID, "width=1024", "_blank", 2);
}

function EditAction()
{
	var item = actionview.getItemData();
	NewHref("../fvs/CP_ActionItem_form.jsp?DataID=" + item.ID, "width=1024", "_blank", 2);
}

function EditAction1()
{
	actionview = actionview1;
	actid = 1;
	EditAction();
}

function EditAction2()
{
	actionview = actionview2;
	actid = 2;
	EditAction();
}

function EditAction3()
{
	actionview = actionview3;
	actid = 3;
	EditAction();
}

function DeleteAction()
{
	if (window.confirm("删除党建活动不可恢复，是否确定") == false)
		return;
	var item = actionview.getItemData();
	AjaxRequestPage(location.pathname + "?DeleteFlag=1&CP_ActionID=" + item.ID, true, "", "location.reload()");
}
</script>
</head>
<body topmargin="0" leftmargin="0" scroll=no>
<div id=LeftDiv style="float:left;width:200px;height:100%;border-bottom:1px solid gray;border-right:1px solid gray;overflow:hidden;">
<div style="width:100%;border-bottom:1px solid gray">年度：<span id=YearSel></span></div>
<div id=DeptTreeDiv style=width:100%;></div>
</div>
<div id=RightDiv style="float:left;height:100%;padding:0px;overflow-y:auto">
<h5 align=center><span style=cursor:hand; id=DeptSpan></span>&nbsp;&nbsp;<span id=YearSpan></span>年度</h5>
<p>党员信息&nbsp;&nbsp;<img src=../pic/jiahao.png style=cursor=hand; onclick=NewMember()></p>
<div id=CPInfo style=width:100%;></div>
<p>党费收缴&nbsp;&nbsp;<img src=../pic/jiahao.png style=cursor=hand; onclick=NewFee()></p>
<div id=CPFee></div>
<p>三会一课&nbsp;&nbsp;<img src=../pic/jiahao.png style=cursor=hand; onclick=NewAction(1)></p>
<div id=CPAction1></div>
<p>支部工作&nbsp;&nbsp;<img src=../pic/jiahao.png style=cursor=hand; onclick=NewAction(2)></p>
<div id=CPAction2></div>
<p>党员活动&nbsp;&nbsp;<img src=../pic/jiahao.png style=cursor=hand; onclick=NewAction(3)></p>
<div id=CPAction3></div>
</div>
</body>
</html>