/**
 * 
 */
//菜单功能-文件
function OpenClass()
{
	if (typeof openwin == "object")
		return openwin.show();
	openwin = new $.jcom.PopupWin("<div id=ClassTree style=width:100%;height:420px;overflow:auto;></div>" +
		"<div align=right style=width:100%;height:30px><input type=button value=打开 onclick=RunOpenClass()>&nbsp;&nbsp;</div>", 
		{title:"选择班级课表", width:640, height:480, mask:50});
	openwin.close = openwin.hide;
	fun = function (data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
		classtree = new $.jcom.TreeView(document.all.ClassTree, [], {parentNode:"Term_id"}, json.head);
		classtree.setdata(json.data);
		classtree.dblclick = RunOpenClass;
	}
	$.get("../fvs/CPB_Class_docview.jsp", {GetTreeData:2}, fun);
}

function OpenReadOnlyClass()
{
	if (typeof classtree == "object")
		return RunOpenClass();
	fun = function (data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
		classtree = new $.jcom.TreeView($("#LeftDiv")[0], [], {parentNode:"Term_id"}, json.head);
		classtree.setdata(json.data);
		classtree.dblclick = RunOpenClass;
	}
	$.get("../fvs/CPB_Class_docview.jsp", {GetTreeData:2}, fun);
}

function RunOpenClass()
{
	var item = classtree.getTreeItem();
	if (typeof item != "object")
		return alert("请先选择");
	if (typeof item.Class_id == "undefined")
	{
		if ((EditMode == 1) || (EditMode == 0))
			return alert("请选择学期下的班次。");
		if (item.child.length == 0)
			return alert("所选学期无班次。");
		$("#TitleSpan").html(item.item);
		view.waiting();
		$.get(coursePath, {LoadTermCourse:1,Term_id:item.child[0].Term_id}, LoadTermCourseOK);
		return;
	}
	classID = item.Class_id;
	LoadCourse(classID);
	if (typeof openwin == "object")
		openwin.hide();
}

function LoadTermCourseOK(data)
{
	courseObj = $.jcom.eval(data);
	if (typeof courseObj == "string")
		alert(courseObj);
	classObj = undefined;
	for (var x = 0; x < courseObj.length; x++)
		APtoDate(courseObj[x]);
	var head = [{FieldName:"CourseTime", TitleName:"日期", nWidth:66, nShowMode:1},
	    		{FieldName:"BeginTime", TitleName:"时间", nWidth:56, nShowMode:1},
	    		{FieldName:"Class_Name", TitleName:"班次", nWidth:100, nShowMode:1},
	    	    {FieldName:"Course", TitleName:"内容", nWidth:200, nShowMode:1},
	    	    {FieldName:"Teacher", TitleName:"授课人", nWidth:60, nShowMode:1},
	    	    {FieldName:"ClassRoom", TitleName:"地点", nWidth:80, nShowMode:1}];
	
	courseGrid = [];
	courseGrid[0] = {};
	var childs = view.getChildren();
	var cols = childs.gridhead.getColumnCount();
	courseGrid[0].CourseTime = {value:$("#TitleSpan").html(), colspan:cols,prop:"align=center ", style:"font:normal normal 400 14pt 黑体;",tdstyle:"border:none"};
	courseGrid[1] = {};
	courseGrid[1].CourseTime = {value:"<div style=float:right>培训时间未定</div>", colspan:cols, tdstyle:"border:none"};
	if (courseObj.length > 0)
		courseGrid[1].CourseTime.value = "<div style=float:right>培训时间:" + $.jcom.GetDateTimeString(courseObj[0].Syllabuses_date, 1) + "至" + 
			$.jcom.GetDateTimeString(courseObj[courseObj.length - 1].Syllabuses_date, 1) + "</div>";
	courseGrid[2] = {};
	for (var x = 0; x < head.length; x++)
	{
		courseGrid[2][head[x].FieldName] = {value:head[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};
	}
	
	var y = 3;
	var d1 = $.jcom.makeDateObj("1970-1-1");
	for (var x = 0; x < courseObj.length; x++)
	{
		var d2 = $.jcom.makeDateObj(courseObj[x].Syllabuses_date);
		if ((d2.getYear() == d1.getYear()) && (d2.getMonth() == d1.getMonth()) && (d2.getDate() == d1.getDate()))
		{
			courseGrid[x + y] = {};
			courseGrid[index + y].CourseTime.rowspan ++;
		}
		else
		{
			var dd = d2.getFullYear() + "年<br>" + $.jcom.GetDateTimeString(d2, 13) + "<br>(星期" + weekdays.substr(d2.getDay(), 1) + ")";
			courseGrid[x + y] = {CourseTime:{value:dd, rowspan:1}};
			d1 = d2;
			index = x;
		}
		
		courseGrid[x + y].BeginTime = $.jcom.GetDateTimeString(courseObj[x].BeginTime, 14) + "<br>" + $.jcom.GetDateTimeString(courseObj[x].EndTime, 14);
//		if (option.ShowEndTime == 2)
//			courseGrid[x + y].BeginTime = getDateAP(courseGrid[x + y].BeginTime);

		courseGrid[x + y].Class_Name = courseObj[x].Class_Name;
		courseGrid[x + y].Course = getCourseName(courseObj[x]);
		courseGrid[x + y].Course = courseGrid[x + y].Course + "<br>" + courseObj[x].Syllabuses_bak;
		courseGrid[x + y].Teacher = courseObj[x].Syllabuses_teacher_name + "<br>" + courseObj[x].AssistMan;
		courseGrid[x + y].ClassRoom = courseObj[x].Syllabuses_ClassRoom;
		courseGrid[x + y].index = x;
	}
	view.reset([], viewInfo, head);
	viewInfo.Records = courseGrid.length;
	if (PrepareTermCourseUserData(courseGrid) == false)
		return;

	view.reset(courseGrid, viewInfo, head);
}

function PrintCourse()
{
	document.body.scroll = "yes";
//	$("#SeekMenubar").css("display", "none");
//	$("#LeftDiv").css("display", "none");
	$("#Root").css("overflow", "visible");
	$("#RightDiv").css("overflow-y", "visible");
	layer.setProp("SeekMenubar", "y", 1);
	layer.setProp("LeftDiv", "x", 1);
return;
alert("OK");

	$("#RightDiv").css("overflow-y", "visible");
	$("#CourseTable").css("overflow", "visible");
	$("#_GridDiv").css("overflow", "visible");
	$("#BodyDiv").css("overflow", "visible");
	$("#CourseTable").off("resize", view.resize);
	$(document).on("mousedown", PrintEnd);
	if (window.confirm("您是要直接打印本页，还是要先预览后，再打印？\n点击【确定】直接打印，否则请点击【取消】后，自行选用浏览器的打印预览功能。\n提示：打印完成后，点击文档任意处则恢复原界面。") == true)
		window.print();
	
}

function PrintEnd()
{
	document.body.scroll = "no";
	$("#SeekMenubar").css("display", "");
	$("#CourseTable").on("resize", view.resize);

	$("#WorkDiv").css("overflow", "hidden");
	$("#RightDiv").css("overflow-y", "auto");
	$("#CourseTable").css("overflow", "");
	$("#_GridDiv").css("overflow", "hidden");
	$("#BodyDiv").css("overflow", "auto");

	$(document).off("mousedown", PrintEnd);
}


var oImport;

function FileInput()
{
	if (oImport == undefined)
	{
		oImport = new $.jcom.OfficeImport();
		oImport.onFileSel = InportOfficeTable;
//		oImport.onImport = self.onImport;
	}
	oImport.Import();
}

function InportOfficeTable(path)
{
	var ex = path.substr(path.lastIndexOf(".") + 1).toLowerCase();
	if ((ex == "xls") || (ex == "xlsx"))
		return InportExcelTable(path);
	return InportWordTable(path);
}

function InportExcelTable(path)
{
	var excel = oImport.InitOffice("Excel");
	var book = excel.Workbooks.Open(path);
	var cfg = {type: "Excel", obj:excel, doc:book, count:excel.Workbooks.Count, path:path, HeadSel:2};
	return InportOption(cfg);
}

function RunInportExcel(cfg)
{
	var excel = cfg.obj;
	var book = cfg.doc;
	var sheet = book.Sheets(cfg.nDoc);
	var rows = sheet.UsedRange.Rows.Count;
	var cols = sheet.UsedRange.Columns.Count;
	var d1 = $.jcom.makeDateObj(classObj.Class_BeginTime);
	var year = d1.getFullYear();
	var index, count = 0;
	var item = {year:year, d1:d1, dt:"", tt:"", subject_name:"", teacher_name:"", ClassRoom:"", assistMan:"", assistInfo:"", note:""};
	var pos = getColPos(cfg.HeadArray);

	var cells = sheet.UsedRange.Cells;
	for (var y = cfg.nStartRow; y <= rows; y++)
	{
		try
		{
			item.tt = getExcelCellText(cells, y, pos, "tt");
			item.dt = getExcelCellText(cells, y, pos, "dt");
//			var s = cells(y, index).Text;
//			if (s != "")
//				item.dt = cells(y, index).Text.replace(/[\s\7]+/g, "");
		}
		catch (e)
		{
			window.status = (y + "-" + x + e.description);
		}
		try
		{
			index = getHeadIndex(cfg.HeadArray, "内容");
			item.subject_name = cells(y, index).Text.replace(/[\s\7]+/g, "");
			if (item.subject_name == "")
				continue;
		}
		catch (e)
		{
			continue;
		}
		try
		{
			item.teacher_name = getExcelCellText(cells, y, pos, "teacher_name");
			item.ClassRoom = getExcelCellText(cells, y, pos, "ClassRoom");
			item.assistMan = getExcelCellText(cells, y, pos, "assistMan");
			item.assistInfo = getExcelCellText(cells, y, pos, "assistInfo");
			item.note = getExcelCellText(cells, y, pos, "note");
		}
		catch (e)
		{
		}
		count += InportItem(item);
	}
	excel.Workbooks.Close();
	oImport.QuitOffice();
	alert("共导入课程" + count + "条。");
//	courseObj = courseObj.sort(CompareCourseObj);
	RefreshCourse();
	SetMode(3);
}

function getExcelCellText(cells, row, pos, key)
{
	if (pos[key] >= 0)
		return cells(row, pos[key]).Text.replace(/[\s\7]+/g, "");
	return "";
}

function getColPos(HeadArray)
{
	var pos = {};
	pos.tt = getHeadIndex(HeadArray, "上下课时间");
	pos.dt =  getHeadIndex(HeadArray, "日期");
	pos.subject_name = getHeadIndex(HeadArray, "内容");
	pos.teacher_name = getHeadIndex(HeadArray, "授课人");
	pos.ClassRoom = getHeadIndex(HeadArray, "地点");
	pos.assistMan = getHeadIndex(HeadArray, "辅教人");
	pos.assistInfo = getHeadIndex(HeadArray, "辅教内容");
	pos.note = getHeadIndex(HeadArray, "备注");
	return pos;
}

function getHeadIndex(heads, key)
{
	for (var x = 0; x < heads.length; x++)
	{
		if (heads[x] == key)
			return x + 1;
	}
	return -1;
}

function InportItem(item)
{
	var m = item.dt.indexOf("月");
	var d = item.dt.indexOf("日");
	if ((m < 0) || (d < 0))
	{
		var d2 = $.jcom.makeDateObj(item.dt);
		if (d2 == null)
			return 0;
	}
	else
	{
		var d2 = $.jcom.makeDateObj(item.year + "-" + item.dt.substring(0, m) + "-" + item.dt.substring(m + 1, d));
		if (d2 < item.d1)
		{
			item.year ++;
			d2 = $.jcom.makeDateObj(item.year + "-" + item.dt.substring(0, m) + "-" + item.dt.substring(m + 1, d));
			item.d1 = d2;
		}
	}
	var ttt = item.tt.split("-");
	var x = NewCourseObjItem();
	courseObj[x].Syllabuses_date = $.jcom.GetDateTimeString(d2, 1);	
	courseObj[x].BeginTime = $.jcom.GetDateTimeString(courseObj[x].Syllabuses_date + " " + ttt[0], 3);
	courseObj[x].EndTime =  $.jcom.GetDateTimeString(courseObj[x].Syllabuses_date + " " + ttt[1], 3);

	courseObj[x].Syllabuses_subject_name = item.subject_name;
	courseObj[x].Syllabuses_teacher_name = item.teacher_name;
	courseObj[x].Syllabuses_ClassRoom = item.ClassRoom;
	courseObj[x].AssistMan = item.assistMan;
	courseObj[x].AssistInfo = item.assistInfo;
	courseObj[x].Note = item.note;
	return 1;
}

var inportoptionwin, headSelEdit;
function InportOption(cfg)
{
	if (inportoptionwin == undefined)
	{
		inportoptionwin = new $.jcom.PopupWin("<div id=OffinceInportOption style=width:100%;height:100%></div>", {title:"导入选项", width:640, height:320, mask:50});
//		headSelEdit = new $.jcom.DynaEditor.List("日期,星期,上下课时间,内容,授课人,地点,辅教人,辅教内容,备注,上课时间,下课时间,其它,无", 200, 200);
	}
	else
		inportoptionwin.show();
	inportoptionwin.close = function ()
	{
		switch (cfg.type)
		{
		case "Excel":
			cfg.obj.Workbooks.Close();
			break;
		case "Word":
			cfg.doc.Close();
			break;
		}
		oImport.QuitOffice();
		inportoptionwin.hide();
	};
	var seltxt = "<select id=HeadSel style='border:none;width:600px;font:normal normal normal 9pt 微软雅黑;'><option value=1>日期 上下课时间 内容 授课人 地点</option><option value=2>日期 星期 上下课时间 内容 授课人 地点 辅教人 辅教内容 备注</option></select>";
	var tag = "<div>要导入的文件：<br>" + cfg.path + "</div><hr><div><span style=width:200px>选择要导入第几个表格:</span><input id=nDoc type=text value=1> 共有" + cfg.count + "个表格</div>" +
	"<div><span style=width:200px>从第几行开始导入:</span><input id=nStartRow type=text value=2>去掉表头和标题栏后的课表起始行</div><hr><div>课表的表头排列顺序:</div><div>" + seltxt + 
	"</div><hr><div align=right><input id=RunOfficeInport type=button value=导入>&nbsp;&nbsp;</div>";
	"</div><table id=OfficeColHead style=width:100%><tr>";
//	for (var x = 0; x < cfg.dftCols.length; x++)
//		tag += "<td>" + cfg.dftCols[x] + "</td>";
//	tag += "</tr></table><hr><div align=right><input id=RunOfficeInport type=button value=导入>&nbsp;&nbsp;</div>";
	$("#OffinceInportOption").html(tag);
	$("#HeadSel").val(cfg.HeadSel);
//	var cols = $("td", $("#OfficeColHead"));
//	for (var x = 0; x < cols.length; x++)
//		headSelEdit.attach(cols[x]);
	$("#RunOfficeInport").on("click", function ()
	{
		
		cfg.nDoc = parseInt($("#nDoc").val());
		cfg.nStartRow = parseInt($("#nStartRow").val());
		cfg.HeadArray = $("#HeadSel option:selected").text().split(" ");
		inportoptionwin.hide();
		switch (cfg.type)
		{
		case "Excel":
			return RunInportExcel(cfg);
		case "Word":
			return RunInportWord(cfg);
		}
	});
}

function InportWordTable(path)
{
	var word = oImport.InitOffice("Word");
	try
	{
		var doc = word.Documents.Open(path);
		doc.ActiveWindow.Activate();
	}
	catch (e)
	{
		alert("打开文件出错：" + path);
		return;
	}
	var cfg = {type: "Word", obj:word, doc:doc, count:doc.Tables.Count, path:path, HeadSel:1};
	return InportOption(cfg);
}

function getWordCellText(table, row, pos, key)
{
	if (pos[key] >= 0)
		return table.Cell(row, pos[key]).Range.Text.replace(/[\s\7]+/g, "");
	return "";
}

function RunInportWord(cfg)
{
	var doc = cfg.doc;
	var word = cfg.obj;
	var t = doc.Tables(cfg.nDoc);
	var rows = t.Rows.Count;
	var cols = t.Columns.Count;
	var d1 = $.jcom.makeDateObj(classObj.Class_BeginTime);
	var year = d1.getFullYear();
	var count = 0;
	d1 = new Date(year - 1, 0, 1);
	var item = {year:year, d1:d1, dt:"", tt:"", subject_name:"", teacher_name:"", ClassRoom:"", assistMan:"", assistInfo:"", note:""};
	var pos = getColPos(cfg.HeadArray);
	for (var y = 2; y <= rows; y++)
	{
		try
		{
			item.tt = getWordCellText(t, y, pos, "tt");
			var dt = getWordCellText(t, y, pos, "dt");
			if (dt != "")
				item.dt = dt;
		}
		catch (e)
		{
		}

		try
		{
			item.subject_name = getWordCellText(t, y, pos, "subject_name");
		}
		catch (e)
		{
			continue;
		}

		try
		{
			item.teacher_name = getWordCellText(t, y, pos, "teacher_name");
			item.ClassRoom = getWordCellText(t, y, pos, "ClassRoom");
			item.assistMan = getWordCellText(t, y, pos, "assistMan");
			item.assistInfo = getWordCellText(t, y, pos, "assistInfo");
			item.note = getWordCellText(t, y, pos, "note");
		}
		catch (e)
		{
		}
		count += InportItem(item);		
	}
	doc.Close();
	oImport.QuitOffice();
	alert("共导入课程" + count + "条。");
//	courseObj = courseObj.sort(CompareCourseObj);
	RefreshCourse();
	SetMode(3);
}


function OutWord()
{
//	document.getElementById("FieldDataFrame").src = "CourseExport.jsp?class_id=" + classObj.Class_id;
//	view.OutHTML(classObj.Class_Name + "课程表.htm");
	var	url = "../com/OutHtml.jsp", f, text;
	var head = "<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:w=\"urn:schemas-microsoft-com:office:word\" xmlns=\"http://www.w3.org/TR/REC-html40\">\n" +
	"<head>\n<meta http-equiv=Content-Type content=\"text/html; charset=gb2312\">\n" +
	"<!--[if gte mso 9]><xml>\n<w:WordDocument>\n<w:View>Print</w:View>\n</xml><![endif]-->\n" +
	"<style>\ntd {font: normal small-caps normal 14px 微软雅黑}\nthead td {font:normal small-caps bolder  14px 黑体}\n</style>\n</head>\n";

	var f = getOutFileName();
	if (EditMode != 1)
	{
		var item = menubar.getItem("横向多班总课表");
		if (item.img != "")
		{
			text = "<h2 align=center>" + f + "</h2><div align=center><table id=BodyTable cellpadding=0 cellspacing=0 border=1 style='border-collapse:collapse;border:none;'>" +
				"<thead>" + view.outerDoc(102, {rowbegin:2, rowend:6}, {cellstyle: "border:1px solid black"}) + "</thead>" +
				view.outerDoc(102, {rowbegin:6}, {cellstyle: "border:1px solid black"}) + "</table></div>";
		}
		else
			text = "<h2 align=center>" + f + "</h2><div align=center>" + view.outerDoc(2, {rowbegin:3}, {cellstyle: "border:1px solid black"}) + "</div>";
	}
	else
		text = "<h2 align=center>" + f + "<br>课程表</h2><div align=center>" + view.outerDoc(2, {}, {cellstyle: "border:1px solid black"}) + "</div>";
	var obj = {FileName:f + "课程表.doc", head:head, body:text};
	$.jcom.submit(url, obj);	
}

function OutExcel()
{	
	var f = getOutFileName();
	view.OutExcel(f + "课程表.xls");
}

function getOutFileName()
{
	if (classObj == undefined)
		var f = $("#TitleSpan").html();
	else
		var f = classObj.Class_Name;
	return f;
}

function OutExceltoServer()
{
//	var	url = "../com/OutExcel.jsp?OutToServer=1";
//	view.OutExcel(classObj.Class_Name + "课程表.xls", url);
	var	url = "../com/OutHtml.jsp";
	view.OutExcel(classObj.Class_Name + "课程表.htm", url);
}

function OutExceltoServerOK(id)
{
	$.get(coursePath + "?AffixName=" + classObj.Class_Name + "课程表.xls", 
		{OutExcelToServer:1, ClassID:classObj.Class_id, AffixID:id}, OutExceltoDocOK);
}

function OutExceltoDocOK(data)
{
	alert(data);
}

function Preview()
{
	var id = classID;
	if (typeof classObj == "object")
		id = classObj.Class_id;
	window.open(coursePath + "?EditMode=2&ClassID=" + id);
}

//菜单功能-编辑
function CopyCourseItem()
{
	var dest = getViewSelRows();
	if (dest.length == 0)
		return alert("请在课程表中选择一行先");
//	clip = [];
//	var y = 0;
	var y = clip.length;
	for (var x = 0; x < dest.length; x++)
	{
		var index = dest[x].rowIndex;
		var index = courseGrid[dest[x].rowIndex].index;
		if (index >= 0)
			clip[y ++] = $.jcom.initObjVal(courseObj[index], {});
	}
	if (typeof clipWin == "object")
		clipview.reload(clip);
	var obj = tree.getNodeObj("nType", 5);
	tree.reloadNode(obj, true);	
	return true;
}

function CutCourseItem()
{
	if (CopyCourseItem() == true)
		DeleteCourseItem(true);
}

function PasteCourseItem()
{
	var dest = getViewSelRows();
	
	var index = 0;
	if (dest.length > 0)
		index = dest[0].rowIndex;
	else
		index = skipCourseGrid(index);
	var flag = true;
	if (dest.length == 0)
		flag = false;
	if ((clip.length > 1) && (dest.length > 0))
		skipflag = window.confirm("剪贴薄中的课程超过一条，您是要连续粘到到当前位置？还是要粘贴到课表的空白位置？\n\n【确定】粘贴到当前位置，【取消】粘贴到空白位置");
	
	for (var y = 0; y < clip.length; y++)
	{
		if (flag == false)
		{
			index = skipCourseGrid(index);
			if (index >= courseGrid.length)
				break;
		}
		var x = SetCourseObj(index);
		courseObj[x].Syllabuses_activity_id = clip[y].Syllabuses_activity_id;
		courseObj[x].Syllabuses_activity_name = clip[y].Syllabuses_activity_name;
		courseObj[x].Syllabuses_subject_id = clip[y].Syllabuses_subject_id;
		courseObj[x].Syllabuses_subject_name = clip[y].Syllabuses_subject_name;
		courseObj[x].Syllabuses_course_id = clip[y].Syllabuses_course_id;
		courseObj[x].Syllabuses_course_name = clip[y].Syllabuses_course_name;		
		courseObj[x].Syllabuses_Department = clip[y].Syllabuses_Department;
		courseObj[x].Syllabuses_teacher_id = clip[y].Syllabuses_teacher_id;
		courseObj[x].Syllabuses_teacher_name = clip[y].Syllabuses_teacher_name;
		courseObj[x].Syllabuses_ClassRoom_id = clip[y].Syllabuses_ClassRoom_id;
		courseObj[x].Syllabuses_ClassRoom = clip[y].Syllabuses_ClassRoom;
		courseObj[x].Syllabuses_bak = clip[y].Syllabuses_bak;
		
		TransCourseItem(courseObj[x], courseGrid[index]);
		
		view.setCell(index, "Course", courseGrid[index].Course);
		view.setCell(index, "Teacher", courseGrid[index].Teacher);
		view.setCell(index, "AssistMan", courseGrid[index].AssistMan);
		view.setCell(index, "AssistInfo", courseGrid[index].AssistInfo);
		view.setCell(index, "ClassRoom", courseGrid[index].ClassRoom);
		view.setCell(index, "Note", courseGrid[index].Note);
		
		index ++;
	}
	if (option.DelePasteItemOption == 1)
	{
		clip.splice(0, y);
		var obj = tree.getNodeObj("nType", 5);
		tree.reloadNode(obj, true);
	}
	SetMode(3);
}

function skipCourseGrid(index)
{
	for (var x = index; x < courseGrid.length; x++)
	{
		if (courseGrid[x].index >= 0)
			continue;
		var t = courseGrid[x].BeginTime;
		if (typeof t == "object")
			t = t.ex;
		var d = $.jcom.makeDateObj(courseGrid[x].DateValue + " " + t);
		if ((option.SkipHolidayOption == 1) && isHoliday(d))
			continue;
		if (getDateAP($.jcom.GetDateTimeString(d, 3)) == "晚上")
			continue;
		return x;
	}
	return courseGrid.length;
}

function isHoliday(d)
{
	var ap = getDateAP($.jcom.GetDateTimeString(d, 4));
	for (var x = 0; x < holiItems.length; x++)
	{
		var d1 = $.jcom.makeDateObj(holiItems[x].THoliday);
		if ((d1.getFullYear() == d.getFullYear()) && (d1.getMonth() == d.getMonth()) && (d1.getDate() == d.getDate()))
		{
			if (holiItems[x].nDateType == 1)	//全天
				return (holiItems[x].nType == 1) || (holiItems[x].nType == 2);
			if ((holiItems[x].nDateType == 2) && (ap == "上午"))
				return (holiItems[x].nType == 1) || (holiItems[x].nType == 2);
			if ((holiItems[x].nDateType == 3) && (ap == "下午"))
				return (holiItems[x].nType == 1) || (holiItems[x].nType == 2);
		}
	}
	var w = d.getDay();
	return (w == 0)	|| (w == 6);
}

var clipWin, clipview;
function ViewClipCourse()
{
	if (clipWin == undefined)
	{
		clipWin = new $.jcom.PopupWin("<div id=ClipCourse style=width:100%;height:100%></div>", 
				{title:"剪贴薄中的课程列表", width:600, height:480});
		var aFace = {x:0,y:30,node:1,a:{id:"clipTop"},b:{id:"clipBottom"}};
		var oLayer = new $.jcom.Layer($("#ClipCourse")[0], aFace, {border:"1px dotted gray"});
		var clipmenu = new $.jcom.CommonMenubar([{item:"删除", action:DeleClip}, {item:"清空", action:EmptyClip}, {item:"粘贴到课表", action:PasteCourseItem}], $("#clipTop")[0]);
		var head = [{FieldName:"Syllabuses_subject_name", TitleName:"内容", nWidth:380, nShowMode:1},
		    		{FieldName:"Syllabuses_teacher_name", TitleName:"授课人", nWidth:60, nShowMode:1},
		    		{FieldName:"Syllabuses_bak", TitleName:"备注", nWidth:80, nShowMode:1}];
		clipview = new $.jcom.GridView($("#clipBottom")[0], head, [], {bodystyle:2, footstyle:4});
		clipWin.close = clipWin.hide;
	}
	else
		clipWin.show();
	for (var x = 0; x < clip.length; x++)
	{
		
	}
	clipview.reload(clip);
	
}

function DeleClip()
{
	clipview.deleteRow();
	var obj = tree.getNodeObj("nType", 5);
	tree.reloadNode(obj, true);	
}

function EmptyClip()
{
	clip = [];
	if (typeof clipview == "object")
		clipview.reload(clip);
	var obj = tree.getNodeObj("nType", 5);
	tree.reloadNode(obj, true);	
}

function InsertCourseLine(nType)
{
	var dest = getViewSelRows();
	if (dest.length == 0)
		return alert("请在课程表中选择一行先");
	index = dest[0].rowIndex;

	var b = courseGrid[index].BeginTime;
	if (typeof b == "object")
		b = b.ex;
	var e = courseGrid[index].EndTime;
	if (typeof e == "object")
		e = e.value;
	b = courseGrid[index].DateValue + " " + b;
	b = $.jcom.makeDateObj(b);
	b.setTime(b.getTime() + 1000 * 60 * 10);
	b = $.jcom.GetDateTimeString(b, 3);
	e = courseGrid[index].DateValue + " " + e;
	var item = InsertCourseItem(index + 1);
	TransCourseGrid({BeginTime: b, EndTime: e, Syllabuses_activity_id:0, Syllabuses_subject_id:0, Syllabuses_subject_name:"",Syllabuses_course_id:0, Syllabuses_course_name:"",
		Syllabuses_teacher_id:"", Syllabuses_teacher_name:"", nConflict:0, AssistMan:"", AssistInfo:"", Syllabuses_ClassRoom:"", Syllabuses_bak:"", nType:nType}, index + 1);
	view.reload(courseGrid);
	SetMode(3);
}

function InsertCourseItem(index)
{
	var item = {};	
	courseGrid.splice(index, 0, item);
	for (var x = index - 1; x >= 0; x --)
	{
		if (typeof courseGrid[x].CourseTime == "object")
		{
			courseGrid[x].CourseTime.rowspan ++;
			courseGrid[x].Week.rowspan ++;
			item.DateValue = courseGrid[x].DateValue;
			break;
		}
	}
	if (courseGrid[index - 1]._lineControl != undefined)
		item._lineControl = courseGrid[index - 1]._lineControl;
	return item;
}

/*
function InsertFreeCourseItem(FreeIDs, index)
{
	var ss = FreeIDs.split(",");
	for (var x = index; x >= 0; x --)
	{
		if (typeof courseGrid[x].CourseTime == "object")
		{
			courseGrid[x].CourseTime.rowspan += ss.length - 1;
			courseGrid[x].Week.rowspan += ss.length - 1;
			break;
		}
	}
	
	courseGrid[index].FreeIndex = getFreeCourseItem(ss[0]);
	courseGrid[index].index = -1;
	for (var x = 0; x < ss.length - 1; x++)
		courseGrid.splice(index + 1, 0, {FreeIndex: getFreeCourseItem(ss[x + 1]), index:-1});

	for (var x = 0; x < ss.length; x++)
	{
		var o = FreeCourse[courseGrid[x + index].FreeIndex];
		TransCourseItem({Syllabuses_activity_id:0, Syllabuses_subject_id:o.Syllabuses_free_subject_id, Syllabuses_subject_name:o.Syllabuses_free_subject_name, 
			Syllabuses_course_id:o.Syllabuses_free_course_id, Syllabuses_course_name: o.Syllabuses_free_course_name, 
			Syllabuses_teacher_id:o.Syllabuses_free_teacher_id, Syllabuses_teacher_name:o.Syllabuses_free_teacher_name,
			nConflict:0, AssistMan:"", AssistInfo:"", Syllabuses_ClassRoom:o.Syllabuses_free_ClassRoom_name, Syllabuses_bak:""}, courseGrid[x + index]);
	}
	TransCourseItem(o, courseGrid[index]);
	courseGrid[index].BeginTime.value += "<br>选修课";
	courseGrid[index].BeginTime.rowspan = ss.length;
	courseGrid[index].EndTime = {value: courseGrid[index].EndTime, rowspan:ss.length};
	return ss.length - 1;
}

function getFreeCourseItem(id)
{
	for (var x = 0; x < FreeCourse.length; x++)
	{
		if (FreeCourse[x].Syllabuses_free_id == parseInt(id))
			return x;
	}
}
*/
function DeleteCourseItem(bDisHint, index)
{
	if (index == undefined)
	{
		var dest = getViewSelRows();
		if (dest.length == 0)
			return alert("请在课程表中选择一行先");
		for (var x = 0; x < dest.length; x++)
		{
			DeleteCourseItem(bDisHint, dest[x].rowIndex);
			bDisHint = true;
		}
		return;
	}
	var x = courseGrid[index].index;
	if (x < 0)
		return;
	if (( x>= 0) && (courseObj[x].EditFlag == 0))
	{
		if (bDisHint != true)
		{
			if (window.confirm("是否删除选中的课程?") == false)
				return;
		}
	}
		
	TransCourseItem({BeginTime: courseObj[x].BeginTime, EndTime: courseObj[x].EndTime, 
		Syllabuses_activity_id:0, Syllabuses_subject_id:0, Syllabuses_subject_name:"", Syllabuses_course_id:0, Syllabuses_course_name:"", 
		Syllabuses_teacher_id:"", Syllabuses_teacher_name:"",
		nConflict:0, AssistMan:"", AssistInfo:"", Syllabuses_ClassRoom:"", Syllabuses_bak:""}, courseGrid[index]);

	view.setCell(index, "Course", courseGrid[index].Course);
	SetViewCell(index, "Teacher", courseGrid[index].Teacher);
	SetViewCell(index, "ClassRoom", "");
	SetViewCell(index, "AssistMan", "");
	view.setCell(index, "AssistInfo", "");
	view.setCell(index, "Note", "");
	
	courseGrid[index].index = -1;
	courseObj[x].EditFlag = 3;
	SetMode(3);
}

function SetViewCell(index, field, value)
{
	var obj = view.getCell(index, field, value);
	if (obj == undefined)
		return;
	if (typeof value == "object")
		value = value.value;
	obj.firstChild.innerHTML = value;
	obj.firstChild.style.color = "black";
	obj.firstChild.title = "";
}

function ApplyCourse(item)
{
	if (typeof item != "object")
	{
		item = tree.getTreeItem();
		if (typeof item != "object")
			return alert("请先选择条目");
	}
//	if ((item.Subject_id == undefined) && (item.Activity_id == undefined))
//		return alert("请选择分类下的条目");

	var dest = getViewSelRows();
	if (dest.length == 0)
		return alert("请在课程表中选择一行先");

	var index = dest[0].rowIndex;
	var b = courseGrid[index].BeginTime;
	if (typeof b == "object")
	{
		b = b.ex;
		if (b == undefined)
			b = "8:30";
	}
	var d = $.jcom.makeDateObj(courseGrid[index].DateValue + " " + b);
	if (isHoliday(d))
	{
		if (window.confirm("您所选择的是非工作日，是否要排课？") == false)
			return;
	}
	var x = courseGrid[index].index;
	if ( x >= 0)
	{
		if (window.confirm("已经有课程了，您是否确定要替换掉已有的课程?") == false)
			return;
	}
	var o;
	switch (item.nType)
	{
	case 11:		//教学计划中的教学单元
		AutoPlanUnit(item, index);
		break;
	case 12:		//教学计划中的课程
		if (item.Subject_id > 0)
			o = {CourseID: item.Course_id, CourseName:item.Course_name, ActID: 0, ActName:"", SubjID:item.Subject_id, SubjName:item.Course_name, 
				TeacherID:item.Teacher_id, TeacherName:item.Teacher_name, t:item.Course_time};
		else// if (item.Activity_id > 0)
			o = {CourseID: item.Course_id, CourseName:item.Course_name, ActID: item.Activity_id, ActName:item.Course_name, SubjID:0, SubjName:"",
				TeacherID:item.Teacher_id, TeacherName:item.Teacher_name, t:item.Course_time};
		break;
	case 13:		//教学计划中的教学单元中的模块
		AutoPlanUnit(item, index);
		break;
	case 32:		//专题库中的专题		
		o = {CourseID: 0, CourseName:item.Subject_name, ActID: 0, ActName:"", SubjID:item.Subject_id, SubjName:item.Subject_name,
			TeacherID:item.Teacher_id, TeacherName:item.Teacher_name, t:0};
		o.CourseID = FindCourseIDFromPlan(rootItems[0].child, o);
		break;
	case 41:		//教学活动
		o = {CourseID: 0, CourseName:item.Activity_name, ActID: item.Activity_id, ActName:item.Activity_name, SubjID:0, SubjName:"",
			TeacherID:0, TeacherName:item.Activity_Principals, t:0};
		break;
	case 51:		//剪贴薄
		o = {CourseID: item.Syllabuses_course_id, CourseName:item.Syllabuses_course_name, ActID:item.Syllabuses_activity_id, ActName:item.Syllabuses_activity_name, 
			SubjID:item.Syllabuses_subject_id, SubjName:item.Syllabuses_subject_name, TeacherID:item.Syllabuses_teacher_id, TeacherName:item.Syllabuses_teacher_name,
			room:item.Syllabuses_ClassRoom, roomid:item.Syllabuses_ClassRoom_id, bak:item.Syllabuses_bak, assist:item.AssistMan, ainfo:item.AssistInfo, t:0};
//		item.Course_id = item.Syllabuses_course_id;
//		item.Course_name = "";
//		item.Activity_name = "";
//		item.Activity_id = 0;
		break;
	default:
		return alert("未知的类型" + item.nType);
		break;
	}
	view.DisEditor();
	if (typeof o == "object")
	{
		ApplyItem(index, o);
		if ((item.nType == 51) && (option.DelePasteItemOption == 1))	//剪贴薄
		{
			for (var y = 0; y < clip.length; y++)
			{
				if (item == clip[y])
				{
					clip.splice(y, 1);
					var obj = tree.getNodeObj("nType", 5);
					tree.reloadNode(obj, true);
					break;
				}
			}
		}
	}
	SetMode(3);	
}

function FindCourseIDFromPlan(items, o)
{
	if (items == null)
		return 0;
	for (var x = 0; x < items.length; x++)
	{
		if (typeof items[x].child == "object")
		{
			var id = FindCourseIDFromPlan(items[x].child, o);
			if (id > 0)
				return id;
		}
		if (items[x].Subject_id == o.SubjID)
			return items[x].Course_id;
	}
	return 0;
}

function ApplyItem(index, o)
{
	if  ((o.t == 0) || (o.t == undefined))
		o.t = 0.5;
	for (var z = 0; z < o.t; z += 0.5)
	{
		var x = SetCourseObj(index);
		courseObj[x].Syllabuses_activity_id = o.ActID;
		courseObj[x].Syllabuses_activity_name = o.ActName;
		courseObj[x].Syllabuses_subject_id = o.SubjID;
		courseObj[x].Syllabuses_subject_name = o.SubjName;
		courseObj[x].Syllabuses_course_id = o.CourseID;
		courseObj[x].Syllabuses_course_name = o.CourseName;
		courseObj[x].Syllabuses_teacher_id = o.TeacherID;
		courseObj[x].Syllabuses_teacher_name = o.TeacherName;
//		courseObj[x].Syllabuses_Department = item.Department_name;
		if ((typeof o.room == "undefined") && (classObj.ClassRoom_id != ""))
		{
			o.roomid = classObj.ClassRoom_id;
			if (classObj.ClassRoom == undefined)
			{
				var item = roomtree.getKeyItem("ID", o.roomid);
				classObj.ClassRoom = "";
				if (typeof item == "object")
					classObj.ClassRoom = item.Name;
			}
			o.room = classObj.ClassRoom;
		}
		
		if ((typeof o.room != "undefined") && (courseObj[x].Syllabuses_ClassRoom == ""))
		{
			courseObj[x].Syllabuses_ClassRoom = o.room;
			courseObj[x].Syllabuses_ClassRoom_id = o.roomid;
		}
		if ((typeof o.bak != "undefined") && (courseObj[x].Syllabuses_bak == ""))
			courseObj[x].Syllabuses_bak = o.bak;

		if ((typeof o.assist != "undefined") && (courseObj[x].AssistMan == ""))
			courseObj[x].AssistMan = o.assist;
		if ((typeof o.ainfo != "undefined") && (courseObj[x].AssistInfo == ""))
				courseObj[x].AssistInfo = o.ainfo;
		
		TransCourseItem(courseObj[x], courseGrid[index]);
		view.setCell(index, "Course", courseGrid[index].Course);
		SetViewCell(index, "Teacher", courseGrid[index].Teacher);
		SetViewCell(index, "ClassRoom", courseGrid[index].ClassRoom);
		SetViewCell(index, "AssistMan", courseGrid[index].AssistMan);
		view.setCell(index, "AssistInfo", courseGrid[index].AssistInfo);
		view.setCell(index, "Note", courseGrid[index].Note);

		index = skipCourseGrid(index);
		if (index >= courseGrid.length)
			break;
	}
}

//菜单功能-工具
function NewSubject()
{
	var rows = getViewSelRows();
	if (rows.length > 0)
	{
		var index = rows[0].rowIndex;
		var	y = courseGrid[index].index;
		if ((y >= 0) && (courseObj[y].Syllabuses_subject_id == 0))
			return EditCourseSubject();
	}
	window.open("../fvs/CPB_Subject_form.jsp", "新增专题", "width=800,height=600,resizable=1");
}

function EditSubject()
{
	var	item = tree.getTreeItem();
	if (typeof item != "object")
			return alert("请先选择专题");
	if (item.Subject_id == undefined)
		return alert("请选择专题，不是专题分类。");
	window.open("../fvs/CPB_Subject_form.jsp?DataID=" + item.Subject_id, "_blank", "width=800,height=600,resizable=1");
}

function EditCourseSubject()
{
	var rows = getViewSelRows();
	if (rows.length == 0)
		return alert("请先选择课程");
	var index = rows[0].rowIndex;
	var	y = courseGrid[index].index;
	if (y == -1)
		return alert("请先设置课程，没有课程不能编辑。");
	var url = "../fvs/CPB_Subject_form.jsp";
	if (courseObj[y].Syllabuses_subject_id > 0)
		url += "?DataID=" + courseObj[y].Syllabuses_subject_id;
	else
		url +="?TeacherID=" + courseObj[y].Syllabuses_teacher_id;
	var result = showModalDialog(url, courseObj[y].Syllabuses_subject_name, "dialogWidth:850px;dialogHeight:600px;resizable:1;center:1");
	if ((typeof result == "string") && (result.substr(0, 2) == "OK"))
	{
		var ss = result.split("|||");
		view.setCell(index, "Course", {value: ss[2], style:CourseNoSaveStyle});
		view.setCell(index, "Teacher", {value:ss[5], color:"black"});
		y = SetCourseObj(index);
		courseObj[y].Syllabuses_subject_id = ss[1];
		courseObj[y].Syllabuses_subject_name = ss[2];
		courseObj[y].Syllabuses_teacher_id = ss[4];
		courseObj[y].Syllabuses_teacher_name = ss[5];
		courseObj[y].Syllabuses_Department = ss[3];
		SetMode(3);
	}
}

function NewTeacher()
{
	var rows = getViewSelRows();
	if (rows.length > 0)
	{
		var index = rows[0].rowIndex;
		var	y = courseGrid[index].index;
		if ((y >= 0) && (courseObj[y].Syllabuses_teacher_id == 0))
			return EditTeacher();
	}
	window.open("../fvs/CPB_Teacher_form1.jsp", "新增外请师资", "width=800,height=600,resizable=1");
}

function EditTeacher()
{
	var rows = getViewSelRows();
	if (rows.length == 0)
		return alert("请先选择课程");
	var index = rows[0].rowIndex;
	var	y = courseGrid[index].index;
	if (y == -1)
		return alert("请先设置课程，没有课程不能编辑。");
	var url = "../fvs/CPB_Teacher_form1.jsp";
	if (courseObj[y].Syllabuses_teacher_id > 0)
		url += "?DataID=" + courseObj[y].Syllabuses_teacher_id;
	var result = showModalDialog(url, courseObj[y].Syllabuses_teacher_name, "dialogWidth:850px;dialogHeight:600px;resizable:1;center:1");
	if ((typeof result == "string") && (result.substr(0, 2) == "OK"))
	{
		var ss = result.split(":");
		view.setCell(index, "Teacher", {value: ss[3] + " " + ss[2], color:"gray"});
		y = SetCourseObj(index);
		courseObj[y].Syllabuses_teacher_id = ss[1];
		courseObj[y].Syllabuses_teacher_name = ss[2];
		courseObj[y].Syllabuses_Department = ss[3];
		SetMode(3);
	}
}

function CheckCourse()
{
	if (window.confirm("冲突检测将检测本学期所有课表中的授课人、辅教人、地点之间是否存在冲突，可能需要耗费较多的时间，是否继续？") == false)
		return;
	$.get(coursePath, {CheckCourse:1, ClassID:classObj.Class_id, Mode:1, TermID:classObj.Term_id}, CheckCourseOK);
}


function CheckCourseOK(data)
{
	var	badCourseWin = new $.jcom.PopupWin("<div id=badCourse style=width:100%;height:100%></div>", 
			{title:"课表冲突检测结果", width:800, height:480});
	$("#badCourse").html(data);
	$("#badCourse").css("overflowY", "auto");
}

var conflictWin, conflictView;
function CheckClassCourse()
{
	if (conflictWin == undefined)
	{
		conflictWin = new $.jcom.PopupWin("<div id=conflictCourse style=width:100%;height:100%></div>", 
				{title:"本班课程冲突检测结果(红色字体是冲突项)", width:640, height:480});
		var aFace = {x:0,y:30,node:1,a:{id:"conflictTop"},b:{id:"conflictBottom"}};
		var oLayer = new $.jcom.Layer($("#conflictCourse")[0], aFace, {border:"1px dotted gray"});
		var menu = new $.jcom.CommonMenubar([{item:"标记授课人为例外", action:"MarkConflictItem(1)"}, {item:"标记辅教人为例外", action:"MarkConflictItem(2)"},
			{item:"标记地点为例外", action:"MarkConflictItem(3)"}, {item:"再次检测", action:RunCheckClassCourse}], $("#conflictTop")[0]);
		var head = [{FieldName:"Time", TitleName:"时间", nWidth:80, nShowMode:1},{FieldName:"ClassName", TitleName:"班次", nWidth:120, nShowMode:1},
			{FieldName:"CourseName", TitleName:"内容", nWidth:220, nShowMode:1},{FieldName:"Teacher", TitleName:"授课人", nWidth:60, nShowMode:1},
			{FieldName:"AssistMan", TitleName:"辅教人", nWidth:60, nShowMode:1}, {FieldName:"ClassRoom", TitleName:"地点", nWidth:80, nShowMode:1}];
		conflictView = new $.jcom.GridView($("#conflictBottom")[0], head, [], {bodystyle:2, footstyle:4});
		conflictWin.close = conflictWin.hide;
		conflictView.dblclickRow = ToConflictCourse;
	}
	else
		conflictWin.show();
	var items = [];
	for (var x = 0; x < ConflictObj.length; x++)
	{
		var ss = ConflictObj[x].Info.split("|");
		items[x] = {CourseID:ConflictObj[x].CourseID, Time: ss[1], ClassName: ss[0], CourseName:ss[2], Teacher: ss[3], AssistMan: ss[4],ClassRoom: ss[5]};
		if ((ConflictObj[x].nConflict & 1) > 0)		//地点冲突
			items[x].ClassRoom = {value:items[x].ClassRoom, color:CourseConflictColor};		
		if ((ConflictObj[x].nConflict & 2) > 0)		//教师冲突
			items[x].Teacher = {value:items[x].Teacher, color:CourseConflictColor};
		if ((ConflictObj[x].nConflict & 4) > 0)		//辅教人冲突
			items[x].AssistMan = {value:items[x].AssistMan, color:CourseConflictColor};
	}
	conflictView.reload(items, {nPage:1, PageSize:9999, Records:items.length, Order:"", bdesc:0});
}

function ToConflictCourse()
{
	var item = conflictView.getItemData();
	if (SkipToCourseItem(1, item.CourseID) == false)
		alert("未找到课表中对应的产生冲突的课程" + item.CourseID)
}

function SkipToCourseItem(nType, value)
{
	for (var x = nTitleRows; x < courseGrid.length; x++)
	{
		if (courseGrid[x].index < 0)
			continue;
		if (nType == 1)		//定位到Syllabuses_id
		{
			if (courseObj[courseGrid[x].index].Syllabuses_id == value)
				break;
		}
		else if (nType == 2)
		{
			if (courseObj[courseGrid[x].index].Syllabuses_subject_id == value)
				break;
		}
	}
	if (x >= courseGrid.length)
		return false;
	var tr = view.getRow(x);
	var e = $.Event( "keydown", {ctrlKey: false, shiftKey:false});
	ClickViewCell($("#Course_TD", tr)[0], e);
	tr.scrollIntoView(false);
	return true;
}

function MarkConflictItem(nType)
{
	var item = conflictView.getItemData();
	if (item == undefined)
		return alert("请先选择一条冲突记录");
	
	var v = "";
	switch (nType)
	{
	case 1:
		v = item.Teacher;
		break;
	case 2:
		v = item.AssistMan;
		break;
	case 3:
		v = item.ClassRoom;
	}
	if (typeof v == "object")
		v = v.value;
	$.get(coursePath + "?MarkConflictItem=1&nType=" + nType + "&Value=" + v, {}, function (data){alert(data);});
}

function ManageConflict()
{
	function RemoveConflictExItem()
	{
		var item = tree.getTreeItem();
		if (item == undefined)
			return alert("请先选择例外项");
		if (typeof item.child == "object")
			return alert("请选择子项");
		var Teacher_id = 0;
		if (item.Teacher_id > 0)
			Teacher_id = item.Teacher_id;
		var roomID = 0;
		if (item.ID > 0)
			roomID = item.ID
		$.get(coursePath, {GetConflictEx:1, Teacher_id: Teacher_id, roomID: roomID}, fun);
	};
	var win = new $.jcom.PopupWin("<div id=conflictEx style=width:100%;height:100%></div>", 
			{title:"冲突例外管理", width:640, height:480});
	var aFace = {x:0,y:30,node:1,a:{id:"conflictExTop"},b:{id:"conflictExBottom"}};
	var oLayer = new $.jcom.Layer($("#conflictEx")[0], aFace, {border:"1px dotted gray"});
	var menu = new $.jcom.CommonMenubar([{item:"去除例外", action:RemoveConflictExItem}], $("#conflictExTop")[0]);
	var tree = new $.jcom.TreeView($("#conflictExBottom")[0], []);
	tree.waiting();
	var fun = function (data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		var data = [{item:"授课人或辅教人例外", child:json.ExTeachers},{item:"地点例外", child:json.ExClassRooms}];
		tree.setdata(data);
	}
	$.get(coursePath, {GetConflictEx:1}, fun);
}

function RunCheckClassCourse()
{	
	conflictView.waiting();
	$.get(coursePath, {CheckCourse:1, ClassID:classObj.Class_id, Mode:2, BeginTime:classObj.Class_BeginTime, EndTime:classObj.Class_EndTime}, CheckClassCourseOK);
}

function CheckClassCourseOK(data, flag)
{
	if (flag != true)
	{
		ConflictObj = $.jcom.eval(data);
		if (typeof ConflictObj == "string")
			return alert(ConflictObj);
		for (var x = 0; x < courseObj.length; x++)
			courseObj[x].ConflictInfo = "";
	}

	for (var y = 0; y < ConflictObj.length; y++)
	{
		for (var x = 0; x < courseObj.length; x++)
		{
			if (courseObj[x].Syllabuses_id == ConflictObj[y].CourseID)
			{
				courseObj[x].nConflict = ConflictObj[y].nConflict;
				courseObj[x].ConflictInfo += "\n" + ConflictObj[y].Info;
			}
		}
	}
	if (flag != true)
	{
		CheckClassCourse();
		if (ConflictObj.length > 0)
			RefreshCourse();
	}
}

function StartPlaceReq()
{
	$.get(coursePath, {SearchFlow:1, ClassID:classObj.Class_id}, PlaceFlowReq);
}

function PlaceFlowReq(data)
{
	var o = eval(data);
	var href = "../fvs/FlowPlaceReq.jsp?InstName=无标题&ClassID=" + classObj.Class_id;
	if (o[0].StepID > 0)
		href = "../fvs/FlowPlaceReq.jsp?RunMode=12&StepID=" + o[0].StepID;
	window.open(href, "场所使用申请", "width=640,height=480,resizable=1,scrollbars=1");
}

function GetPlaceFromFlow()
{
	$.get(coursePath, {GetFlowData:1, ClassID:classObj.Class_id}, GetFlowPlaceData);
}

function GetFlowPlaceData(data)
{
	var editflag = 0;
	var roomObj = eval(data);
	for (var x = 0; x < roomObj.length; x++)
	{
		for (var y = nTitleRows; y < courseGrid.length; y++)
		{
			var index = courseGrid[y].index;
			if (index >= 0)
			{
				if (roomObj[x].SyllabusID == courseObj[index].Syllabuses_id)
				{
					if (courseObj[index].Syllabuses_ClassRoom_id != roomObj[x].PlaceID)
					{
						courseObj[index].Syllabuses_ClassRoom_id = roomObj[x].PlaceID;
						courseObj[index].Syllabuses_ClassRoom = roomObj[x].Name;
						courseObj[index].EditFlag = 2;	//Update Flag;
						view.setCell(y, "ClassRoom", roomObj[x].Name);
						editflag = 1;
					}
				}
			}
		}
	}
	if (editflag == 1)
		SetMode(3);
}

function LoadPlaceOK(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		alert(json);
	roomtree.setdata(json.data, json.head);
}

/*
var fcview;
function OpenFreeCourse()
{
	var	freeeCourseWin = new $.jcom.PopupWin("<div id=freeeCourse style=width:100%;height:100%></div>", 
			{title:"选修课与大课引用", width:800, height:480});
	var aFace = {x:0,y:30,node:1,a:{id:"fcTop"},b:{id:"fcBottom"}};
	var oLayer = new $.jcom.Layer($("#freeeCourse")[0], aFace, {border:"1px dotted gray"});
	var fcmenu = new $.jcom.CommonMenubar([], $("#fcTop")[0],"<input type=button onclick=ApplyFreeCourse() value=应用到课程表>");
	var fun = function (result)
	{
		var json = $.jcom.eval(result);
		if (typeof json == "string")
				return alert(json);
		fcview = new $.jcom.GridView($("#fcBottom")[0], json.head, json.Data,json.info,{bodystyle:2, footstyle:4});
	}
	$.get("../fvs/CPB_Syllabuses_free_view.jsp", {GetGridData:2, SeekKey:"CPB_Syllabuses_free.term_id", SeekParam:classObj.Term_id}, fun);
}

function ApplyFreeCourse()
{
	var data = fcview.getData();
	var rows = fcview.getsel();
	for (var x = 0; x < rows.length; x++)
	{
		var dv = "";
		var z = parseInt(rows[x].node);
		for (var y = 0; y < courseGrid.length; y++)
		{
			var d1 = $.jcom.makeDateObj(data[z].BeginTime);
			if (typeof courseGrid[y].DateValue != "undefined")
				dv = courseGrid[y].DateValue;
			var d2 = $.jcom.makeDateObj(dv + " " + courseGrid[y].BeginTime);
			var d = d1.getTime() - d2.getTime();
			if ((d < 1000 * 3600) && (d > -1000 * 3600))
			{
				var index = SetCourseObj(x);
				if (data[z].Syllabuses_type == 1)
				{
					view.setCell(y, "Course", "选修课");
					courseObj[index].Syllabuses_subject_name = "选修课";
					courseObj[index].Syllabuses_subject_id = -1;
					var ids = data[z].Syllabuses_free_id;
					for (var xx = x + 1; xx < rows.length; xx ++)
					{
						var zz = parseInt(rows[xx].node);
						d1 = $.jcom.makeDateObj(data[zz].BeginTime);
						d = d1.getTime() - d2.getTime();
						if ((d < 1000 * 3600) && (d > -1000 * 3600))
						{
							ids += "," + data[zz].Syllabuses_free_id;
							x = xx;
						}
						else
							break;
					}
					courseObj[index].FreeIDs = ids;
//					alert(ids);
				}
				else
				{
					view.setCell(y, "Course", data[z].Syllabuses_free_subject_name);
					view.setCell(y, "ClassRoom", data[z].Syllabuses_free_ClassRoom_name);
					view.setCell(y, "Teacher", data[z].Syllabuses_free_teacher_name);
					view.setCell(y, "BeginTime", data[z].BeginTime_ex);
					view.setCell(y, "EndTime", data[z].EndTime_ex);
					courseObj[index].Syllabuses_subject_name = data[z].Syllabuses_free_subject_name;
					courseObj[index].Syllabuses_subject_id = data[z].Syllabuses_free_subject_id;
					courseObj[index].Syllabuses_teacher_id = data[z].Syllabuses_free_teacher_id;
					courseObj[index].Syllabuses_teacher_name = data[z].Syllabuses_free_teacher_name;
					courseObj[index].Syllabuses_ClassRoom_id = data[z].Syllabuses_free_ClassRoom_name;
					courseObj[index].Syllabuses_ClassRoom = data[z].Syllabuses_free_ClassRoom_id;
					courseObj[index].Syllabuses_ClassRoom = data[z].Syllabuses_free_ClassRoom_id;
					courseObj[index].BeginTime = data[z].BeginTime;
					courseObj[index].EndTime = data[z].EndTime;
					courseObj[index].FreeIDs = data[z].Syllabuses_free_id;
				}
			}
		
		}
	}
}
*/
function EditNote()
{
	alert("Note");
}

var HolidayWin, holiview, holiItems = [], holiC1, holiC2;
function SetHolyDay()
{
	if (classObj == undefined)
		return alert("没有权限");
	if (typeof HolidayWin == "object")
		return HolidayWin.show();
	HolidayWin = new $.jcom.PopupWin("<div id=HolidayDiv style=width:100%;height:100%;overflow:hidden;></div>", 
				{title:"节假日或非教学日设置", width:640, height:480});
//	var aFace = {x:0,y:200,node:1,a:{id:"Calendar"},b:{child:{x:0,y:252,node:2,a:{id:"HoliList"},b:{id:"HoliContr"}}}};
	var aFace = {x:0,y:220,node:1,a:{child:{x:310,y:0,node:3,a:{id:"Cel1"},b:{id:"Cel2"}}},b:{child:{x:560,y:0,node:2,a:{id:"HoliList"},b:{id:"Control"}}}};
	var oLayer = new $.jcom.Layer($("#HolidayDiv")[0], aFace);
	var head = [{FieldName:"THoliday", TitleName:"日期", nWidth:80, nShowMode:1},
	    		{FieldName:"HolidayName", TitleName:"名称", nWidth:160, nShowMode:1},
	    		{FieldName:"nType", TitleName:"节假日类型", nWidth:80, nShowMode:1, Quote:"(1:节假日,2:休息日,3:工作日)"},
	    		{FieldName:"nDateType", TitleName:"时间类型", nWidth:60, nShowMode:1, Quote:"(1:全天,2:上午,3:下午)"},
	    		{FieldName:"PublicOption", TitleName:"公共属性", nWidth:100, nShowMode:1, Quote:"(1:仅适用于本班,2:适用于所有班)"}];
	holiview = new $.jcom.GridView($("#HoliList")[0], head, holiItems, {}, {footstyle:4});
	
	var holidayNameEdit = new $.jcom.DynaEditor.Edit();
	holiview.attachEditor("HolidayName", holidayNameEdit);
	var nTypeEdit = new $.jcom.DynaEditor.List("1:节假日,2:休息日,3:工作日", 200, 200, 1);
	holiview.attachEditor("nType", nTypeEdit);
	var nDateTypeEdit = new $.jcom.DynaEditor.List("1:全天,2:上午,3:下午", 200, 200, 1);
	holiview.attachEditor("nDateType", nDateTypeEdit);
	var publicOptionEdit = new $.jcom.DynaEditor.List("1:仅适用于本班,2:适用于所有班", 200, 200, 1);
	holiview.attachEditor("PublicOption", publicOptionEdit);
	
	HolidayWin.close = HolidayWin.hide;
	$("#Control").css({paddingLeft: "10px"});
	$("#Control").html("<br><br><br><br><input type=button value=增加 onclick=AddHoliday()><br><input type=button value=删除 onclick=DelHoliday()><br>" +
			"<input type=button value=排序 onclick=OrderHoliday()><br><input type=button value=保存 onclick=SaveHoliday()><br><input type=button value=结束 onclick=HolidayWin.hide()><br>");
	$("#Cel2").css({borderLeft: "1px solid gray", paddingLeft: "10px"});
	var d = $.jcom.makeDateObj(classObj.Class_BeginTime);
	holiC1 = new $.jcom.CalendarBase(d, $("#Cel1")[0]);
	holiC1.show();
	holiC2 = new $.jcom.CalendarBase(d.getFullYear() + "-" + (d.getMonth() + 2) + "-1", $("#Cel2")[0]);
	holiC2.show();
	holiC1.dateChange = HoliDateChange;
	holiC2.dateChange = HoliDateChange;
	holiC1.dblclickDate = HolidaySetDate;
	holiC2.dblclickDate = HolidaySetDate;
}

function HoliDateChange(t, nType, obj)
{
	var tt = new Date(t);
	var o = holiC2;
	if ($("#Cel1").find(obj).length == 0)
	{
		o = holiC1;
		tt.setMonth(t.getMonth() - 1);
	}
	else
		tt.setMonth(t.getMonth() + 1);
	if (nType == 2)
		o.show(tt);
	o.selDateCell();
}

function HolidaySetDate(d, obj)
{
	var row = holiview.getSelRow();
	if (row == undefined)
		return AddHoliday(d);
	holiview.setCell(row, "THoliday", $.jcom.GetDateTimeString(d, 1));
}

function AddHoliday(d)
{
	if (d == undefined)
	{
		d = holiC1.getDate();
		if (typeof d == "string")
			d = holiC2.getDate();
	}
	var dd = $.jcom.GetDateTimeString(d, 1);
	holiview.insertRow({THoliday:dd, HolidayName:"", nType:1, nDateType:1, PublicOption:1});
}

function DelHoliday()
{
	var row = holiview.getSelRow();
	if (row == undefined)
		return alert("删除前要先选择一行。");
	if (window.confirm("是否要删除当前选择的行？") == false)
		return;
		
	holiview.deleteRow(row);
}

function OrderHoliday()
{
	var items = holiview.getData();
	var items = items.sort(sortHoliday);
	holiview.reload(items);
}

function sortHoliday(a, b)
{
	return $.jcom.makeDateObj(a.THoliday) - $.jcom.makeDateObj(b.THoliday);
}

function SaveHoliday()
{
	var fun = function (data)
	{
		alert(data);
	}
	var items = holiview.getData();
	var tag = "", tag1 = "[", sp = "";
	for (var x = 0; x < items.length; x++)
	{
		var d = $.jcom.makeDateObj(items[x].THoliday);
		d = d.getFullYear() * 10000  + (d.getMonth() + 1) * 100 + d.getDate();
		if (items[x].PublicOption == 2)	//适用于所有班
		{
			tag += "&THoliday=" + d + "&HolidayName=" + items[x].HolidayName + "&nDateType=" + items[x].nDateType + "&nType=" + items[x].nType;
		}
		else
		{
			tag1 += sp + "{THoliday:" + d + ", HolidayName:\"" + items[x].HolidayName + "\", nDateType:" + items[x].nDateType + ", nType:" + items[x].nType + "}";
			sp = ",";
		}
	}
	$.get(coursePath + "?SaveHoliday=1&ClassID=" + classObj.Class_id + tag + "&ClassHoliday=" + tag1 + "]", {}, fun);
}

var OuterDateWin, dateEdit, OuterDateNum = 1;
function SetOuterDate()
{
	if (classObj == undefined)
		return alert("没有权限");
	if (typeof OuterDateWin == "object")
		return OuterDateWin.show();
	OuterDateWin = new $.jcom.PopupWin("<div id=freeeCourse style=width:100%;height:100%;padding:8px;>" +
		"异地教学开始时间&nbsp;<input name=OuterBegin value=" + classObj.OuterBegin + "><br>异地教学结束时间&nbsp;<input name=OuterEnd value=" +
		classObj.OuterEnd + "><br><center id=SetControl><input type=button value=增加 onclick=AddOuterDate()>&nbsp;&nbsp;<input type=button value=确定 onclick=ConfirmOuterDate()></center></div>", 
			{title:"设置异地教学起止时间", width:320, height:120});
	OuterDateWin.close = OuterDateWin.hide;
	dateEdit = new $.jcom.DynaEditor.Date(300, 200);
	dateEdit.attach($("input[name='OuterBegin']")[0]);
	dateEdit.attach($("input[name='OuterEnd']")[0]);
	if (typeof classObj.OtherOuterTime != "object")
		return;
	for (var x = 0; x < classObj.OtherOuterTime.length; x++)
	{
		AddOuterDate(classObj.OtherOuterTime[x].OuterBegin, classObj.OtherOuterTime[x].OuterEnd);
	}
}

function AddOuterDate(b, e)
{
	if (OuterDateNum > 5)
		return alert("异地教学的时间段太多");
	if (typeof b != "string")
		b = "";
	if (typeof e != "string")
		e = "";
	$("#SetControl").before("异地教学开始时间&nbsp;<input name=OuterBegin" + OuterDateNum + " value='" + b + "'><br>异地教学结束时间&nbsp;<input name=OuterEnd" +
			OuterDateNum + " value='" + e + "'><br>");
	OuterDateWin.show(-1, -1, 320, 330);
	dateEdit.attach($("input[name='OuterBegin" + OuterDateNum + "']")[0]);
	dateEdit.attach($("input[name='OuterEnd" + OuterDateNum + "']")[0]);
	OuterDateNum ++;
}

function ConfirmOuterDate()
{
	var fun = function (data)
	{
		alert(data);
		OuterDateWin.hide();
		RefreshCourse();
	}
	classObj.OuterBegin = document.all.OuterBegin.value;
	classObj.OuterEnd = document.all.OuterEnd.value;
	var tag = "&OuterBegin=" + document.all.OuterBegin.value + "&OuterEnd=" + document.all.OuterEnd.value + "&OtherOuterTime=[";
	if (OuterDateNum > 1)
	{
		for (var x = 1, y = 0; x < OuterDateNum; x++)
		{
			var b = $("Input[name='OuterBegin" + x + "']").val();
			var e = $("Input[name='OuterEnd" + x + "']").val();
			if ((b != "") || (e != ""))
			{
				tag += "{OuterBegin:\"" + b + "\", OuterEnd:\"" + e + "\"}";
				classObj.OtherOuterTime[y].OuterBegin = b;
				classObj.OtherOuterTime[y].OuterEnd = b;
				y++;
			}
		}
	}
	$.get(coursePath + "?SaveOuterDate=1&ClassID=" + classObj.Class_id + tag + "]", {}, fun);
}
/*
function SetAllClassRoom()
{
	var rows = getViewSelRows();
	if (rows.length == 0)
		return alert("请先选择课程");
	var index = rows[0].rowIndex;
	var	y = courseGrid[index].index;
	if (y == -1)
		return alert("请先设置课程，没有课程不能设置。");
	var id = courseObj[y].Syllabuses_ClassRoom_id;
	var room = courseObj[y].Syllabuses_ClassRoom;
	
	for (var x = 0; x < courseGrid.length; x++)
	{
		if (courseGrid[x].index >= 0)
		{
			var index = SetCourseObj(x);
			if (courseObj[index].Syllabuses_ClassRoom_id != id)
			{
				courseObj[index].Syllabuses_ClassRoom_id = id;
				courseObj[index].Syllabuses_ClassRoom = room;
				view.setCell(x, "ClassRoom", room);
			 	if (courseObj[index].EditFlag == 0)
					courseObj[index].EditFlag = 2;	//Update Flag;
			}
		}
	}
}

function SetAllAssistMan()
{
	var rows = getViewSelRows();
	if (rows.length == 0)
		return alert("请先选择课程");
	var index = rows[0].rowIndex;
	var	y = courseGrid[index].index;
	if (y == -1)
		return alert("请先设置课程，没有课程不能设置。");

	for (var x = 0; x < courseGrid.length; x++)
	{
		if (courseGrid[x].index >= 0)
		{
			var index = SetCourseObj(x);
			if (courseObj[index].AssistMan != courseObj[y].AssistMan)
			{
				courseObj[index].AssistMan = courseObj[y].AssistMan;
				view.setCell(x, "AssistMan", courseObj[y].AssistMan);
			 	if (courseObj[index].EditFlag == 0)
					courseObj[index].EditFlag = 2;	//Update Flag;
			}
		}
	}
}

function SetAllAssistInfo()
{
	var rows = getViewSelRows();
	if (rows.length == 0)
		return alert("请先选择课程");
	var index = rows[0].rowIndex;
	var	y = courseGrid[index].index;
	if (y == -1)
		return alert("请先设置课程，没有课程不能设置。");

//	var text = enumAssistInfo[courseObj[y].AssistInfo];
//	var ss = text.split(":");

	for (var x = 0; x < courseGrid.length; x++)
	{
		if (courseGrid[x].index >= 0)
		{
			var index = SetCourseObj(x);
			if (courseObj[index].AssistInfo != courseObj[y].AssistInfo)
			{
				courseObj[index].AssistInfo = courseObj[y].AssistInfo;
				view.setCell(x, "AssistInfo", courseObj[y].AssistInfo);
			 	if (courseObj[index].EditFlag == 0)
					courseObj[index].EditFlag = 2;	//Update Flag;
			}
		}
	}
}

function SetAssistInfoCol(obj, item)
{
	if (item.img == "")
	{
		item.img = "../pic/flow_end.png";
		viewhead[9].nShowMode = 6;
	}
	else
	{
		item.img = "";
		viewhead[9].nShowMode = 1;
	}
	view.reset(courseGrid, viewInfo, viewhead);	
}
*/
function SetNoteCol(obj, item)
{
	if (item.img == "")
	{
		item.img = "../pic/flow_end.png";
		viewhead[10].nShowMode = 6;
	}
	else
	{
		item.img = "";
		viewhead[10].nShowMode = 1;
	}
	view.reset(courseGrid, viewInfo, viewhead);	
}

/*
function SetRed(obj, item)
{
	if (item.img == "")
	{
		item.img = "../pic/flow_end.png";
		for (var x = 0; x < courseGrid.length; x++)
		{
			if (typeof courseGrid[x].Course == "object")
				courseGrid[x].Course.color = "black";
			if (typeof courseGrid[x].Teacher == "object")
				courseGrid[x].Teacher.color = "black";
		}
		view.reset(courseGrid, viewInfo, viewhead);	
	}
	else
	{
		item.img = "";
		ReloadReadOnlyCourse();
	}
}
*/
var CourseTimeWin;
function SetCourseTime()
{
	if (classObj == undefined)
		return alert("没有权限");
	if (typeof CourseTimeWin == "object")
		return CourseTimeWin.show();
	CourseTimeWin = new $.jcom.PopupWin("<div id=freeeCourse style=width:100%;height:100%;padding:8px;>" +
		"默认上午上课时间&nbsp;<input name=AMBegin value=" + option.AMBegin + "><br>默认上午下课时间&nbsp;<input name=AMEnd value=" + option.AMEnd +
		"><br>默认下午上课时间&nbsp;<input name=PMBegin value=" + option.PMBegin + "><br>默认下午下课时间&nbsp;<input name=PMEnd value=" + option.PMEnd +
		"><br>默认晚上上课时间&nbsp;<input name=EVBegin value=" + option.EVBegin + "><br>默认晚上下课时间&nbsp;<input name=EVEnd value=" + option.EVEnd +
		"><br><center><input type=button value=保存为本班配置 onclick=ConfirmCourseTime(1)><input type=button value=保存为全校配置 onclick=ConfirmCourseTime(2)></center></div>", 
			{title:"设置默认上下课时间", width:320, height:240});
	CourseTimeWin.close = CourseTimeWin.hide;
}

function ConfirmCourseTime(nType)
{
	option.AMBegin = $("input[name='AMBegin']").val();
	option.AMEnd = $("input[name='AMEnd']").val();
	option.PMBegin = $("input[name='PMBegin']").val();
	option.PMEnd = $("input[name='PMEnd']").val();
	option.EVBegin = $("input[name='EVBegin']").val();
	option.EVEnd = $("input[name='EVEnd']").val();
		
	var fun = function (data)
	{
		alert(data);
		CourseTimeWin.hide();
		RefreshCourse();
	}
	$.jcom.Ajax(coursePath + "?SaveDefaultCourseTime=1&ClassID=" + classObj.Class_id + "&nType=" + nType + "&AMBegin=" + option.AMBegin + "&AMEnd=" + option.AMEnd +
		"&PMBegin=" + option.PMBegin + "&PMEnd=" + option.PMEnd + "&EVBegin=" + option.EVBegin + "&EVEnd=" + option.EVEnd, true, "", fun);
}

var OptionWin;
function FaceOptionSet()
{
	if (classObj == undefined)
		return alert("没有权限");
	if (typeof OptionWin == "object")
		return OptionWin.show();
	
	OptionWin = new $.jcom.PopupWin("<div id=freeeCourse style=width:100%;height:100%;padding:8px;>" +
		"每页显示的课表的天数&nbsp;<input size=3 name=PageSize value=" + viewInfo.PageSize + "><hr>" +
		"<span style=width:120px>日期显示的形式</span><input name=DayShowMode type=radio checked value=1>显示年月日&nbsp;<input name=DayShowMode type=radio value=10>显示月日" +
		"<br><span style=width:120px>日期显示格式</span><input name=DateFormat type=radio checked value=0>用年月日分隔&nbsp;&nbsp;<input name=DateFormat type=radio value=1>用.分隔&nbsp;<input name=DateFormat type=radio value=2>用-分隔" +
		"<br><span style=width:120px>星期显示方式</span><input name=ShowWeek type=radio checked value=0>不显示&nbsp;&nbsp;<input name=ShowWeek type=radio value=1>单列显示&nbsp;&nbsp;<input name=ShowWeek type=radio value=2>与日期合并显示" +
		"<br><span style=width:120px>上下课时间显示方式</span><input name=ShowEndTime type=radio checked value=0>仅显示午别&nbsp;<input name=ShowEndTime type=radio value=1>分列显示&nbsp;<input name=ShowEndTime type=radio value=2>合并显示" +
		"<br><span style=width:120px>是否显示辅教人</span><input name=ShowAssistMan type=radio checked value=0>不显示&nbsp;<input name=ShowAssistMan type=radio value=1>单列显示&nbsp;&nbsp;<input name=ShowAssistMan type=radio value=2>与授课人合并显示" +
		"<br><span style=width:120px>是否显示辅教内容</span><input name=ShowAssistInfo type=radio checked value=0>不显示&nbsp;<input name=ShowAssistInfo type=radio value=1>显示" +
		"<br><span style=width:120px>备注显示方式</span><input name=ShowNote type=radio checked value=0>不显示&nbsp;&nbsp;<input name=ShowNote type=radio value=1>单列显示&nbsp;&nbsp;<input name=ShowNote type=radio value=2>与内容合并显示" +
		"<hr><input name=ShowRed type=checkbox " + ((option.ShowRed == 1) ? "checked " : "") + "value=1>标蓝非专题库课程和非师资库授课人" +
		"<br><input name=ActivityOption type=checkbox " + ((option.ActivityOption == 1) ? "checked " : "") + "value=1>将教学活动作为专题处理" +
		"<br><input name=SaveToCourseOption type=checkbox " + ((option.SaveToCourseOption == 1) ? "checked " : "") + "value=1>课程保存后自动转到教学计划" +		
		"<br><input name=SaveInstantOption type=checkbox " + ((option.SaveInstantOption == 1) ? "checked " : "") + "value=1>课程保存后自动冲突检测" +
		"<br><input name=DelePasteItemOption type=checkbox " + ((option.DelePasteItemOption == 1) ? "checked " : "") + "value=1>自动删除已粘贴的剪贴薄内容" +
		"<br><input name=SkipHolidayOption type=checkbox " + ((option.SkipHolidayOption == 1) ? "checked " : "") + "value=1>自动排课时跳过节假日" +
		"<br><br><center><input type=button value=保存为本班配置 onclick=ConfirmOption(1)>&nbsp;<input type=button value=保存为全校配置 onclick=ConfirmOption(2)></center></div>", 
			{title:"设置选项", width:420, height:480});
	if (option.DayShowMode == 10)
		$("input[name='DayShowMode']").eq(1).prop("checked", true);
	
	$("input[name='DateFormat']").eq(option.DateFormat).prop("checked", true);
	$("input[name='ShowWeek']").eq(option.ShowWeek).prop("checked", true);
	$("input[name='ShowEndTime']").eq(option.ShowEndTime).prop("checked", true);
	$("input[name='ShowAssistMan']").eq(option.ShowAssistMan).prop("checked", true);
	$("input[name='ShowAssistInfo']").eq(option.ShowAssistInfo).prop("checked", true);
	
	$("input[name='ShowNote']").eq(option.ShowNote).prop("checked", true);
	OptionWin.close = OptionWin.hide;
}

function ConfirmOption(nType)
{
	viewInfo.PageSize = parseInt($("input[name='PageSize']").val());
	var fields = ["DayShowMode", "DateFormat", "ShowWeek", "ShowEndTime", "ShowAssistMan", "ShowAssistInfo", "ShowNote"];
	for (var x = 0; x < fields.length; x++)
	{
		var o = $("input[name='" + fields[x] + "']");
		for (var y = 0; y < o.length; y ++)
		{
			if (o.eq(y).prop("checked"))
					option[fields[x]] = parseInt(o.eq(y).val());
		}
	}

	var fields = ["ShowRed", "ActivityOption", "SaveToCourseOption", "SaveInstantOption", "DelePasteItemOption", "SkipHolidayOption"];
	for (var x = 0; x < fields.length; x++)
	{
		if ($("input[name='" + fields[x] + "']").prop("checked"))
			option[fields[x]] = 1;
		else
			option[fields[x]] = 0;
	}
	SaveOption(nType);
}

function SaveOption(nType)
{
	var fun = function (data)
	{
		if (data != "OK")
			alert(data);
		viewInfo.nPage = 1;
		OptionWin.hide();

		AdjectViewHead();	
		RefreshCourse();
	}
	if (event.ctrlKey)
		return fun("注意：未保存，仅供预览使用。");
	var tag = "";
	for (var key in option)
		tag += "&" + key + "=" + option[key];
	$.jcom.Ajax(coursePath + "?SaveFaceOption=1&ClassID=" + classObj.Class_id + "&nType=" + nType + "&EditMode=" + EditMode + "&PageSize=" + viewInfo.PageSize + tag, true, "", fun);	
}

function ReadOnlyFaceOptionSet()
{
	if (classObj == undefined)
		return alert("没有权限");
	if (typeof OptionWin == "object")
		return OptionWin.show();
	
	OptionWin = new $.jcom.PopupWin("<div id=freeeCourse style=width:100%;height:100%;padding:8px;>" +
		"<span style=width:120px>日期显示的形式</span><input name=DayShowMode type=radio checked value=1>显示年月日&nbsp;<input name=DayShowMode type=radio value=10>显示月日" +
		"<br><span style=width:120px>日期显示格式</span><input name=DateFormat type=radio checked value=0>用年月日分隔&nbsp;&nbsp;<input name=DateFormat type=radio value=1>用.分隔&nbsp;<input name=DateFormat type=radio value=2>用-分隔" +
		"<br><span style=width:120px>星期显示方式</span><input name=ShowWeek type=radio checked value=0>不显示&nbsp;&nbsp;<input name=ShowWeek type=radio value=1>单列显示&nbsp;&nbsp;<input name=ShowWeek type=radio value=2>与日期合并显示" +
		"<br><span style=width:120px>上下课时间显示方式</span><input name=ShowEndTime type=radio checked value=0>仅显示午别&nbsp;<input name=ShowEndTime type=radio value=1>分列显示&nbsp;<input name=ShowEndTime type=radio value=2>合并显示" +
		"<br><span style=width:120px>是否显示辅教人</span><input name=ShowAssistMan type=radio checked value=0>不显示&nbsp;<input name=ShowAssistMan type=radio value=1>单列显示&nbsp;&nbsp;<input name=ShowAssistMan type=radio value=2>与授课人合并显示" +
		"<br><span style=width:120px>是否显示辅教内容</span><input name=ShowAssistInfo type=radio checked value=0>不显示&nbsp;<input name=ShowAssistInfo type=radio value=1>显示" +
		"<br><span style=width:120px>备注显示方式</span><input name=ShowNote type=radio checked value=0>不显示&nbsp;&nbsp;<input name=ShowNote type=radio value=1>单列显示&nbsp;&nbsp;<input name=ShowNote type=radio value=2>与内容合并显示" +
		"<hr><span style=width:160px>休息日未排课时间显示方式</span><input name=ShowWeekEnd type=radio checked value=0>不显示&nbsp;&nbsp;<input name=ShowWeekEnd type=radio value=1>合并显示&nbsp;&nbsp;<input name=ShowWeekEnd type=radio value=2>显示" +
		"<br><span style=width:160px>节假日未排课时间显示方式</span><input name=ShowHoliday type=radio checked value=0>不显示&nbsp;&nbsp;<input name=ShowHoliday type=radio value=1>合并显示&nbsp;&nbsp;<input name=ShowHoliday type=radio value=2>显示" +
		"<br><span style=width:160px>异地教学时间显示方式</span><input name=ShowOuterTeach type=radio value=1>合并显示&nbsp;&nbsp;<input name=ShowOuterTeach type=radio value=2>分行显示" +
		"<br><span style=width:160px>一天或以上课程显示方式</span><input name=ShowLongCourse type=radio value=1>合并显示&nbsp;&nbsp;<input name=ShowLongCourse type=radio value=2>分行显示" +
		"<br><span style=width:160px>工作日未排课时间显示内容</span><input name=ShowWorkdayIdle value=''>" +
		"<br><br><center><input type=button value=保存为本班配置 onclick=ReadOnlyConfirmOption(1)>&nbsp;<input type=button value=保存为全校配置 onclick=ReadOnlyConfirmOption(2)></center></div>", 
			{title:"设置选项", width:420, height:480});
	if (option.DayShowMode == 10)
		$("input[name='DayShowMode']").eq(1).prop("checked", true);
	var fields = ["DateFormat", "ShowWeek", "ShowEndTime", "ShowAssistMan", "ShowAssistInfo", "ShowNote", "ShowWeekEnd", "ShowHoliday", "ShowOuterTeach", "ShowLongCourse"];
	for (var x = 0; x < fields.length; x++)
	{
		var o = $("input[name='" + fields[x] + "']");
		o.eq(option[fields[x]]).prop("checked", true);
	}
	$("input[name='ShowWorkdayIdle']").val(option.ShowWorkdayIdle);
	OptionWin.close = OptionWin.hide;
}

function ReadOnlyConfirmOption(nType)
{
	var fields = ["DayShowMode", "DateFormat", "ShowWeek", "ShowEndTime", "ShowAssistMan", "ShowAssistInfo", "ShowNote", "ShowWeekEnd", "ShowHoliday", "ShowOuterTeach", "ShowLongCourse"];
	for (var x = 0; x < fields.length; x++)
	{
		var o = $("input[name='" + fields[x] + "']");
		for (var y = 0; y < o.length; y ++)
		{
			if (o.eq(y).prop("checked"))
					option[fields[x]] = parseInt(o.eq(y).val());
		}
	}
	option.ShowWorkdayIdle = $("input[name='ShowWorkdayIdle']").val();	
	SaveOption(nType);
}

function AdjectViewHead()
{
var fields = ["Week", "EndTime", "AssistMan", "AssistInfo", "Note"];
	for (var x = 0; x < fields.length; x++)
	{
		for (var y = 0; y < viewhead.length; y++)
		{
			if (viewhead[y].FieldName == fields[x])
			{
				if (option["Show" + fields[x]] == 1)
					viewhead[y].nShowMode = 1;
				else
					viewhead[y].nShowMode = 6;
			}
		}
	}
	if (option.ShowEndTime == 0)
	{
		viewhead[2].nShowMode = 1;		//ap
		viewhead[3].nShowMode = 6;		//BeginTime
	}
	else
	{
		viewhead[2].nShowMode = 6;		//ap
		viewhead[3].nShowMode = 1;		//BeginTime
	}
}

function SaveDoc()
{
var data = "", deldata = "", cnt = 0;

	if (option.ShowRed == 1)
	{
		for (var x = 0; x < courseObj.length; x++)
		{
			if (courseObj[x].Syllabuses_subject_id == 0)
			{
				if (window.confirm("重要提示：课程表中的有些课程未加入专题库(课程标蓝的内容），您是要继续保存，还是要加入专题库后再保存？\n如果要继续保存，请点确定。\n如果要加入专题库后再保存，请点取消，并双击标蓝的内容，将课程加入专题库。")== true)
					break;
				return;
			}
		}
	}
	for (var x = 0; x < courseObj.length; x++)
	{
		switch (courseObj[x].EditFlag)
		{
		case 1:			//insert
		case 2:			//update
			if (data != "")
				data += "&";
			data += "index=" + x + "&Syllabuses_id=" + courseObj[x].Syllabuses_id +
				"&Syllabuses_date=" + courseObj[x].Syllabuses_date + 
				"&BeginTime=" + courseObj[x].BeginTime +
				"&EndTime=" + courseObj[x].EndTime +
				"&Syllabuses_course_id=" + courseObj[x].Syllabuses_course_id + 
				"&Syllabuses_subject_id=" + courseObj[x].Syllabuses_subject_id + 
				"&Syllabuses_subject_name=" + escString(courseObj[x].Syllabuses_subject_name) +
				"&Syllabuses_activity_id=" + courseObj[x].Syllabuses_activity_id +
				"&RefID=" + courseObj[x].RefID +
				"&Syllabuses_activity_name=" + escString(courseObj[x].Syllabuses_activity_name) +
				"&Syllabuses_Department=" + escString(courseObj[x].Syllabuses_Department) +
				"&Syllabuses_teacher_id=" + courseObj[x].Syllabuses_teacher_id +
				"&Syllabuses_teacher_name=" + escString(courseObj[x].Syllabuses_teacher_name) +
				"&Syllabuses_ClassRoom_id=" + courseObj[x].Syllabuses_ClassRoom_id +
				"&Syllabuses_ClassRoom=" + escString(courseObj[x].Syllabuses_ClassRoom) +
				"&AssistMan=" + escString(courseObj[x].AssistMan) +
				"&AssistInfo=" + escString(courseObj[x].AssistInfo) +
				"&Syllabuses_bak=" + escString(courseObj[x].Syllabuses_bak);
			cnt ++;
			break;
		case 3:			//delete
			if (courseObj[x].Syllabuses_id > 0)
			{
				if (deldata != "")
					deldata += ",";
				deldata += courseObj[x].Syllabuses_id;
			}
			break;
		}
	}
	$.jcom.Ajax(coursePath + "?SaveCourse=1&term_id=" + classObj.Term_id + "&ClassID=" + classObj.Class_id + "&Num=" + cnt, 
		true, data + "&DeleteIDs=" + deldata, SaveCourseOK);
	SetMode(2);	
}

function escString(s)
{
	if (typeof s != "string")
		return s;
	var ss = s.replace("\+", "&#43;");
	return escape(escape(ss));
}

function SaveCourseOK(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return alert(json);
	var err = 0;
	var items = json.SaveResult;
	ConflictObj = json.Conflict;
	CheckClassCourseOK(ConflictObj, true);

	for (var x = 0; x < items.length; x++)
	{
		if (items[x].result == -1)
			err ++;
		else
		{
			courseObj[items[x].index].Syllabuses_id = items[x].id;
			courseObj[items[x].index].EditFlag = 0;
			var index = getCourseGridIndex(items[x].index);
			TransCourseItem(courseObj[items[x].index], courseGrid[index]);
			view.setCell(index, "Course", courseGrid[index].Course);
			view.setCell(index, "Teacher", courseGrid[index].Teacher);
			view.setCell(index, "AssistMan", courseGrid[index].AssistMan);
			view.setCell(index, "ClassRoom", courseGrid[index].ClassRoom);
		}
	}
	
	for (var x = 0; x < courseObj.length; x++)
	{
		if (courseObj[x].Syllabuses_id > 0)
			courseObj[x].Syllabuses_id = 0;
	}
	if (option.SaveToCourseOption == 1)
	{
		$.get("../fvs/CPB_Class_Course.jsp",{Ajax:1,CopyfromSyllabuses:1,DataID:classObj.Class_id}, SaveOKReload);
		return;
	}
	SaveOKReload();
}

function getCourseGridIndex(index)
{
	for (var x = 0; x < courseGrid.length; x++)
	{
		if (courseGrid[x].index == index)
			return x;
	}
}

function SaveOKReload()
{
	SetMode(2);
//	LoadCourse(classObj.Class_id);	
}

//左边树（教学计划、专题库、教学活动、剪贴薄等）


function PrepareSubjectData(root)
{
	for (var x = 0; x < root.length; x++)
	{
		root[x].nType = 31;
		root[x].item = root[x].Subject_Class_name;
		if (root[x].child.length == 0)
			root[x].child = null;
		else
			PrepareSubjectData(root[x].child);
	}	
}

function LoadLeftTree(item, div)
{
	var fun1 = function(data)
	{
		var jsonData = $.jcom.eval(data);
		if (typeof jsonData == "string")
			return alert(jsonData);

//		aStyle = jsonData.Style;
/*
		var aUnit = jsonData.Mode;
		aUnit[aUnit.length] = {Mode_id:0, item:"开班式和结业式", nType:11};
		for (var x = 0; x < aUnit.length; x++)
		{
			aUnit[x].Mode_Name = aUnit[x].item;
			if (aUnit[x].Mode_id > 0)
			{
				aUnit[x].item = getUnitChineseNo(x, aUnit) + aUnit[x].Mode_Name;
				aUnit[x].nTYpe = 11;
			}
			aUnit[x].child = [];
			var z = 0;
			for (var y = 0; y < jsonData.Course.length; y++)
			{
				if (jsonData.Course[y].Mode_id == aUnit[x].Mode_id)
				{
					aUnit[x].child[z] = jsonData.Course[y];
					aUnit[x].child[z].item = aUnit[x].child[z].Course_name + "-" + aUnit[x].child[z].Teacher_name;
					var t = getCourseTime(aUnit[x].child[z].Course_time);
					if (t != "半天")
						aUnit[x].child[z].item += "(" + t + ")";
					aUnit[x].child[z].nType = 12;
					CheckItemInCourse(aUnit[x].child[z], 3);
					z++;
				}
			}
		}
		item.child = aUnit;
*/
		item.child = DealUnitCourse(jsonData.Mode, jsonData.Course, 2, CheckItemInCourse);
		tree.loadnodeok(item, div);
	};
	
	var fun2 = function(data)
	{
		alert(data);
		item.child = [];
		tree.loadnodeok(item, div);
		
	};
	
	var fun3 = function(data)
	{
		var treedata = $.jcom.eval(data);
		if (typeof head == "string")
			return alert(treedata);
		PrepareSubjectData(treedata);
		item.child = treedata;
		tree.loadnodeok(item, div);
	};
	
	var fun4 = function(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		item.child = json;
		for (var x = 0; x < json.length; x++)
		{
			item.child[x].item = "<img src=../pic/ico_groups24.gif style=height:16px>&nbsp;" + item.child[x].Activity_name + "-" + item.child[x].Activity_Principals;
			item.child[x].nType = 41;
			CheckItemInCourse(item.child[x], 2);
		}
		tree.loadnodeok(item, div);
	};
		
	var fun31 = function(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		item.child = json.Data;
		for (var x = 0; x < item.child.length; x++)
		{
			if (item.child[x].Teacher_name == "")
			{
				item.child[x].Teacher_name = item.child[x].Informant_name;
				item.child[x].Teacher_id = item.child[x].Informant_id;
			}
			item.child[x].item = "<img src=../pic/384.png style=height:16px>&nbsp;" + item.child[x].Subject_name + "-" + item.child[x].Teacher_name;
			item.child[x].nType = 32;
			CheckItemInCourse(item.child[x], 1);
		}
		tree.loadnodeok(item, div);		
	};
	
	switch (item.nType)
	{
	case 1:	//教学计划
		$.get("../fvs/CPB_Class_Course.jsp",{getClassCourseData:1, DataID:classID}, fun1);
		break;
	case 2:	//最新专题
		$.get("../fvs/CPB_Class_Course.jsp",{getNewSubject:1}, fun31);
		break;
	case 3:	//专题库
		$.get("../fvs/CPB_Subject_Class_view.jsp",{GetTreeData:1, nFormat:0}, fun3);
		break;
	case 4:	//教学活动
		$.get("../fvs/CPB_Activity_list.jsp",{GetTreeData:1, OrderField:"Activity_id"}, fun4);
		break;
	case 5:	//剪贴薄
		item.child = clip;
		for (var x = 0;  x < clip.length; x++)
		{
			clip[x].item = "<img src=../pic/flow_bs_manage.png>" + getCourseName(clip[x]) + "-" + clip[x].Syllabuses_teacher_name;
			clip[x].nType = 51;
		}
		tree.loadnodeok(item, div);
		break;
	case 31:	//专题分类
		$.get("../fvs/CPB_Subject_list.jsp",{GetGridData:1, SeekKey:"CPB_Subject.Subject_class_id", SeekParam:item.Subject_Class_id}, fun31);
		break;
	}
}

function CheckItemInCourse(item, ntype)
{
	for (var x = 0; x < courseObj.length; x++)
	{
		if (courseObj[x].EditFlag == 3)	//delete flag
			continue;
		switch (ntype)
		{
		case 1:		//专题
			if (courseObj[x].Syllabuses_subject_id == item.Subject_id)
			{
				item.style = "color:gray";
				return true;
			}
			break;
		case 2:		//教学活动
			if (courseObj[x].Syllabuses_activity_id == item.Activity_id)
			{
				item.style = "color:gray";
				return true;
			}
			break;
		case 3:		//教学计划
			if (courseObj[x].Syllabuses_course_id == item.Course_id)
			{
				item.style = "color:gray";
				return true;
			}
			break;
		}
	}
	item.style = "";
	return false;
}

function TreeDblClick(obj, e)
{
	var item = tree.getTreeItem(obj);
	if (item == undefined)
		return;
	if (item.nType < 10)
		return tree.expand(obj);
	if ((item.style != "") && (e.ctrlKey == false))
		return SkipToCourseItem(2, item.Subject_id);
	ApplyCourse(item);
}

//课表Grid操作
function ViewPageSkip(nPage)
{
	viewInfo.nPage = nPage;
//	courseObj = courseObj.sort(CompareCourseObj);
	RefreshCourse();
	
}

function CompareCourseObj(a, b)
{
	if ((a.BeginTime != "") && (b.BeginTime != ""))
	{
		var da = $.jcom.makeDateObj(a.BeginTime);
		var db = $.jcom.makeDateObj(b.BeginTime);
	}
	else
	{
		var da = $.jcom.makeDateObj(a.Syllabuses_date);
		var db = $.jcom.makeDateObj(b.Syllabuses_date);
	}
    if (da == db)
        return 0;
    if (da < db)
        return -1;
    else
        return 1; 
}

function CalTime(value, step)
{
	if (typeof value == "object")
		value = value.value;
	var ss = value.split(":");
	if (ss.length < 2)
		return option.AMBegin;
	var m = parseInt(ss[0]) + step;
	if (m < 7)
		m = 7;
	if (m > 23)
		m = 23;
	return  m + ":" + ss[1];
}

function CourseSearchOK(data)
{
	var list = eval(data);
	if (typeof subjectObj == "object")
		subjectObj = subjectObj.concat(list);
	else
		subjectObj = list;
	var value = "";
	for (var x = 0; x < subjectObj.length; x++)
	{
		if (value != "")
			value += ",";
		value += subjectObj[x].Subject_name;
	}
	if (value == "")
		return;
	courseEdit.setData(value);
	courseEdit.popDown();
}

function CourseSearch(value)
{
	subjectObj = [];
	if (value == "")
		return;
	var val = "";
	var data = tree.getdata();
	var items = data[0].child;
	if (items != null)
	{
		for (var x = 0; x < items.length; x++)
		{
			if (typeof items[x].child == "object")
			{
				for (var y = 0; y < items[x].child.length; y++)
				{
					if (items[x].child[y].item.indexOf(value) > 0)
					{
						var item = {};
						item.Subject_name = items[x].child[y].item;
						subjectObj[subjectObj.length] = item;
						if (val != "")
							val += ",";
						val += item.Subject_name;
					}
				}
			}
		}
	}
	$.get(coursePath + "?SearchSubject=1&SeekKey=" + value, {}, CourseSearchOK);
	return val;
}

function CourseChange(obj)
{
	var tr = $.jcom.findParentObj(obj, document.body, "TR");
	if (tr == undefined)
		return;
	var index = tr.rowIndex;
	if (typeof subjectObj == "object")
	{
		for (var x = 0; x < subjectObj.length; x++)
		{
			if (obj.innerText == subjectObj[x].Subject_name)
			{
				obj.style.style = CourseNoSaveStyle;
				if (option.ShowAssistMan == 2)
				{
					$("#Field_Teacher", tr).html(subjectObj[x].Teacher_name);
					$("#Field_Teacher", tr).css({color:"black"});
				}
				else
					view.setCell(index, "Teacher", subjectObj[x].Teacher_name);
				y = SetCourseObj(index);
				courseObj[y].Syllabuses_course_id = 0;
				courseObj[y].Syllabuses_course_name = subjectObj[x].Subject_name;
				courseObj[y].Syllabuses_subject_id = subjectObj[x].Subject_id;
				courseObj[y].Syllabuses_subject_name = subjectObj[x].Subject_name;
				courseObj[y].Syllabuses_teacher_id = subjectObj[x].Teacher_id;
				courseObj[y].Syllabuses_teacher_name = subjectObj[x].Teacher_name;
				courseObj[y].Syllabuses_Department = subjectObj[x].Department_name;
				SetMode(3);
				return;
			}
		}
	}
	if (obj.innerText == "")
	{
//		if (window.confirm("是否删除此行的课程?"))
			DeleteCourseItem(true, index);
		return;
	}

	var y = SetCourseObj(index);
	if (courseObj[y].Syllabuses_subject_name == obj.innerText)
		return;
	if (option.ShowRed == 1)
		obj.style.color = CourseWarningColor;
	
	var o = $.jcom.getStyleObjFromString(CourseNoSaveStyle);
	$(obj).css(o);
	courseObj[y].Syllabuses_subject_id = 0;
	courseObj[y].Syllabuses_course_id = 0;
	courseObj[y].Syllabuses_subject_name = obj.innerText;
	courseObj[y].Syllabuses_course_name = obj.innerText;
	SetMode(3);


}

function TeacherSearchOK(data)
{
	teacherObj = eval(data);
	var value = "";
	for (var x = 0; x < teacherObj.length; x++)
	{
		if (value != "")
			value += ",";
		value += teacherObj[x].Teacher_name;
	}
	teacherEdit.setData(value);
	teacherEdit.popDown();
}

function TeacherSearch(value)
{
	if (value != "")
		$.get(coursePath + "?SearchTeacher=1&SeekKey=" + value, {}, TeacherSearchOK);
	return "";
}

function TeacherChange(obj)
{
	var index = obj.parentNode.parentNode.rowIndex;
	if (index == undefined)
		index = obj.parentNode.parentNode.parentNode.rowIndex;
	if (typeof teacherObj == "object")
	{
		for (var x = 0; x < teacherObj.length; x++)
		{
			if (obj.innerText == teacherObj[x].Teacher_name)
			{
//				view.setCell(index, "Teacher", {value:teacherObj[x].Teacher_name,color:"black"});
				obj.style.color = "black";
				y = SetCourseObj(index);
				courseObj[y].Syllabuses_teacher_id = teacherObj[x].Teacher_id;
				courseObj[y].Syllabuses_teacher_name = teacherObj[x].Teacher_name;
				courseObj[y].Syllabuses_Department = teacherObj[x].TeacherUnit;
				var cell = view.getCell(index, "Course");
//				cell.firstChild.focus();
				cell.firstChild.fireEvent("onmousedown");
				$.get(coursePath + "?GetTeachSubject=1&TeacherID=" + teacherObj[x].Teacher_id, {}, CourseSearchOK);
				SetMode(3);
				return;
			}
		}
	}
	var y = SetCourseObj(index);
	if (option.ShowRed == 1)
		obj.style.color = CourseWarningColor;
	else
		obj.style.color = "black";
	courseObj[y].Syllabuses_teacher_id = 0;
	courseObj[y].Syllabuses_teacher_name = obj.innerText;
	SetMode(3);
}

function NoteChange(obj)
{
	var index = obj.parentNode.parentNode.rowIndex;
	if (index == undefined)
		index = obj.parentNode.parentNode.parentNode.rowIndex;
	var y = SetCourseObj(index);
//	view.setCell(index, "Note", obj.innerText);
	courseObj[y].Syllabuses_bak = obj.innerText;
	SetMode(3);
}

function TimeChange(obj)
{
	if (obj.tagName == "SPAN")
		return InlineTimeChange(obj);
	var tr = $.jcom.findParentObj(obj, document.body, "TR");
	if (tr == undefined)
		return;
	var index = tr.rowIndex;
	var field = obj.id.substr(6);
	if (field == "")
		field = obj.parentNode.id.substr(0, obj.parentNode.id.length - 3);
	var y = SetCourseObj(index);
	var d = $.jcom.GetDateTimeString(courseObj[y].Syllabuses_date, 1);
	var t = $.jcom.GetDateTimeString(d + " " + obj.innerText, 3);
	if (t != "")
		courseObj[y][field] = t;
	view.DisEditor();
	if (option.ShowEndTime == 0)	//仅显示午别
		view.setCell(index, "ap", getDateAP(obj.innerText));
	SetMode(3);
}

function roomChange(obj)
{
	var index = obj.parentNode.parentNode.rowIndex;
	var y = SetCourseObj(index);
	view.setCell(index, "ClassRoom", obj.innerText);
	courseObj[y].Syllabuses_ClassRoom = obj.innerText;
	var item = roomtree.getTreeItem();
	if ((typeof item == "object") && (item.item == obj.innerText))
		courseObj[y].Syllabuses_ClassRoom_id = item.ID;
	SetMode(3);
}

function AssistInfoChange(obj)
{
	var index = obj.parentNode.parentNode.rowIndex;
	var y = SetCourseObj(index);
	SetMode(3);
	if ((event.shiftKey) && (courseObj[y].AssistInfo != ""))
		obj.innerText = courseObj[y].AssistInfo + "," + obj.innerText;
	courseObj[y].AssistInfo = obj.innerText;
//	var text = enumAssistInfo[courseObj[y].AssistInfo];
//	var ss = text.split(":");
//	obj.innerText = ss[1];	
}

function AssistManChange(obj)
{
	var index = obj.parentNode.parentNode.rowIndex;
	if (index == undefined)
		index = obj.parentNode.parentNode.parentNode.rowIndex;
	var y = SetCourseObj(index);
	if (obj.innerText == "其它员工")
	{
		var	user = showModalDialog("../selmember.jsp", "","dialogWidth:580px;dialogHeight:500px;scroll:yes");
		if (user == undefined)
		{
			obj.innerText = courseObj[y].AssistMan;
			return;
		}
		obj.innerText = user;
	}
	courseObj[y].AssistMan = obj.innerText;
	SetMode(3);
}

function CourseKey(e)
{
return;	//有右键菜单了，不转义快捷键，避免和系统快捷键冲突。
	switch (e.keyCode)
	{
	case 46:		//DEL
		DeleteCourseItem();
		break;
	case 88:		//X
		if (e.ctrlKey)
			CutCourseItem();
		break;
	case 67:		//C
		if (e.ctrlKey)
			CopyCourseItem();
		break;
	case 86:		//V
		if (e.ctrlKey)
		{
			var text = window.clipboardData.getData("Text");
			if (text == null)
				PasteCourseItem();
		}	
		break;
	default:
	}
}

function LoadCourse(classID)
{
	view.waiting();
	$.get(coursePath, {LoadCourse:1,ClassID:classID, EditMode:EditMode}, LoadCourseOK);
}

function LoadCourseOK(data)
{
	var jsondata = $.jcom.eval(data);
	if (typeof jsondata == "string")
		return view.waiting(data);
	classObj = jsondata.classObj[0];
	classObj.Class_BeginTime = $.jcom.GetDateTimeString(classObj.Class_BeginTime, 1);
	classObj.Class_EndTime = $.jcom.GetDateTimeString(classObj.Class_EndTime, 1);
	if (classObj.OuterBegin == null)
		classObj.OuterBegin = "";
	if (classObj.OuterEnd == null)
		classObj.OuterEnd = "";
	classObj.Teachers = jsondata.Teachers;
	var d1 = $.jcom.makeDateObj(classObj.Class_BeginTime);
	var d2 = $.jcom.makeDateObj(classObj.Class_EndTime);
	if (typeof AssistManEdit == "object")
	{
		var data = "";
		if (classObj.TrainLeader_ex != "")
			data = classObj.TrainLeader_ex + ",";
		if (classObj.Teachers != "")
			data += classObj.Teachers + ",";
		data += "其它员工";
		AssistManEdit.setData(data);
	}
//	document.all.TitleSpan.innerText = classObj.Class_Name + "(" + $.jcom.GetDateTimeString(d1, 1) + "~" + $.jcom.GetDateTimeString(d2, 10) + ")";
	
	courseObj = jsondata.Course;
//	FreeCourse = jsondata.FreeCourse;
	holiItems = jsondata.Holiday;
	for (var x = 0; x < holiItems.length; x++)
	{
		holiItems[x].THoliday = parseInt(holiItems[x].THoliday / 10000) + "-" + (parseInt(holiItems[x].THoliday / 100) % 100) + "-" + (holiItems[x].THoliday % 100);
		holiItems[x].PublicOption = 2;	//全局节假日
	}
	for (var x = 0; x < jsondata.ClassHoliday.length; x++)
	{
		jsondata.ClassHoliday[x].THoliday = parseInt(jsondata.ClassHoliday[x].THoliday / 10000) + "-" + (parseInt(jsondata.ClassHoliday[x].THoliday / 100) % 100) + "-" + (jsondata.ClassHoliday[x].THoliday % 100);
		jsondata.ClassHoliday[x].PublicOption = 1;	//班级节假日
	}
	holiItems = holiItems.concat(jsondata.ClassHoliday);
	
	for (var key in jsondata.ClassCourseConfig)			//班级配置
		option[key] = jsondata.ClassCourseConfig[key];
	if (jsondata.ClassCourseConfig.PageSize != undefined)
		viewInfo.PageSize = jsondata.ClassCourseConfig.PageSize;
	classObj.OtherOuterTime = jsondata.OtherOuterTime;	//更多异地教学时间
	for (var x = 0; x < courseObj.length; x++)
	{
		courseObj[x].EditFlag = 0;
		courseObj[x].nConflict = 0;
		courseObj[x].ConflictInfo = "";
		APtoDate(courseObj[x]);
	}
	if (EditMode == 1)
	{
		for (var key in jsondata.DefaultClassCourseTime)	//班级默认上下课时间
			option[key] = jsondata.DefaultClassCourseTime[key];
		ConflictObj = jsondata.Conflict;
		StateRight = jsondata.StateRight;
		
		CheckClassCourseOK(jsondata.Conflict, true);
		
		EmptyClip();
		//让跟班级相关的教学计划失效，等待重新加载...
		var obj = tree.getNodeObj("nType", 1);
		$(obj.nextSibling).attr("unloadflag", 1);
		var item = tree.getTreeItem(obj);
		item.child = null;
		tree.expand(obj, true);
	}
	AdjectViewHead();
	RefreshCourse();
	
//	for (var x = 0; x < aUnit.length; x++)
//	{
//		for (var y = 0; y < aUnit[x].child.length; y++)
//		{
//			CheckItemInCourse(aUnit[x].child[y], 3);
//		}
//	}
//	if (typeof PlanTree.getdomobj() == "object")	
//		PlanTree.setdata(aUnit);
}

function APtoDate(item)
{
	var d = $.jcom.GetDateTimeString(item.Syllabuses_date, 1);
	if ((item.BeginTime == null) || (item.BeginTime == ""))
		item.BeginTime = d;
	var d1 = $.jcom.makeDateObj(item.BeginTime);
	if (d1.getHours() > 0)
		return;
	switch(item.Syllabuses_AP)
	{
	case "下午":
		item.BeginTime = d + " " + option.PMBegin;
		item.EndTime = d + " " + option.PMEnd;
		break;
	case "晚上":
		item.BeginTime = d + " " + option.EVBegin;
		item.EndTime = d + " " + option.EVEnd;
		break;
	case "上午":
	default:
		item.BeginTime = d + " " + option.AMBegin;
		item.EndTime = d + " " + option.AMEnd;
		break;
	}
}

function getDateAP(d)
{
	if (typeof d == "object")
		d = d.value;
	var s = d.split(" ");
	if (s.length == 2)
		d = s[1];
	var ss = d.split(":");
	var h = parseInt(ss[0]);
	if (h < 12)
		return "上午";
	if (h < 18)
		return "下午";
	return "晚上";
}

function InitCourseGridItem(begintime, endtime, parentItem, d, ex, lineControl)
{
	var item = {};
	item.BeginTime = begintime;
	item.ap = getDateAP(begintime);
	if (option.ShowEndTime == 2)
	{
		item.BeginTime = {value: "<div id=Field_BeginTime style='width:100%;overflow-y:visible'>" + begintime + "</div>" +
			"</div><div id=Field_EndTime style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;'>" + endtime + "</div>", ex:begintime};
	}
//	else 
//	if (option.ShowEndTime == 2)
//		item.BeginTime = {value:getDateAP(begintime), ex:begintime};
	item.EndTime = endtime;

	item.index = -1;
	item.Course = "";
	item.Teacher = "";
	item.ClassRoom = "";
	item.Note = "";
	item.AssistMan = "";
	item.AssistInfo = "";
	if (typeof lineControl == "object")
		item._lineControl = lineControl;
	if ((option.ShowNote == 2) && (EditMode == 1))
	{
		item.Course = {value: "<div id=Field_Course style='width:100%;overflow-y:visible'></div>" +
			"<div id=Field_Note style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;'></div>", ex:""};
	}
	if ((option.ShowAssistMan == 2) && (EditMode == 1))
	{
		item.Teacher = {value: "<div id=Field_Teacher style='width:100%;overflow-y:visible'></div>" +
			"<div id=Field_AssistMan style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;'></div>"};
	}	
	if (typeof parentItem == "object")
	{
		parentItem.CourseTime.rowspan ++;
		parentItem.Week.rowspan ++;
		item.DateValue = parentItem.DateValue;
		if (typeof parentItem._lineControl == "object")
			item._lineControl = parentItem._lineControl;
		return item;
	}
	
	switch (option.DateFormat)
	{
	case 1:	//以.分隔
		var dd = $.jcom.GetDateTimeString(d, 17);
		if (option.DayShowMode == 1)
			dd = $.jcom.GetDateTimeString(d, 16);
		break;
	case 2:	//以-分隔
		var dd = $.jcom.GetDateTimeString(d, 10);
		if (option.DayShowMode == 1)
			dd = $.jcom.GetDateTimeString(d, 1);
		break;
	case 0:
	default:
		var dd = $.jcom.GetDateTimeString(d, 13);
		if (option.DayShowMode == 1)
			dd = d.getFullYear() + "年<br>" + dd;
		break;
	}
	if (option.ShowWeek == 2)
		dd += "<br>(星期" + weekdays.substr(d.getDay(), 1) + ")";
	item.CourseTime = {value:dd + "<br>" + ex, rowspan:1};
	item.Week = {value: weekdays.substr(d.getDay(), 1), rowspan:1};
	item.DateValue = $.jcom.GetDateTimeString(d, 1);
	return item;
}

function RefreshCourse()
{
//	if (EditMode != 1)
//		return ReloadReadOnlyCourse();
	courseObj = courseObj.sort(CompareCourseObj);
	var cd1 = $.jcom.makeDateObj(classObj.Class_BeginTime);
	var cd2 = $.jcom.makeDateObj(classObj.Class_EndTime);
	var oditems = getOuterItems();
	
	var d1 = cd1;
	var d2 = cd2;
	if (courseObj.length > 0)	//如果课程时间超出班级开始和结束时间之外。
	{
		var dd = $.jcom.makeDateObj(courseObj[0].Syllabuses_date);
		if (dd < d1)
			d1 = dd;
		dd = $.jcom.makeDateObj(courseObj[courseObj.length - 1].Syllabuses_date);
		if (dd > d2)
			d2 = dd;
	}
	if (EditMode == 1)
	{
		viewInfo.Records = parseInt((d2.getTime() - d1.getTime()) / (1000 * 60 * 60 * 24) + 1);
		d1.setDate(d1.getDate() + (viewInfo.nPage - 1) * viewInfo.PageSize);
		var dd = new Date(d1.getTime());
		dd.setDate(dd.getDate() + viewInfo.PageSize);
		if (d2 > dd)
			d2 = dd;
	}
	courseGrid = [];
	courseGrid[0] = {};
	var childs = view.getChildren();
	var cols = childs.gridhead.getColumnCount();
	courseGrid[0].CourseTime = {value:classObj.Class_Name + "<br>课程表", colspan:cols,prop:"align=center ", style:"font:normal normal 400 14pt 黑体;",tdstyle:"border:none"};
	courseGrid[1] = {};
	courseGrid[1].CourseTime = {value:"<div style=float:left>班次编号:" + classObj.ClassCode + "</div><div style=float:right>培训时间:" + 
			classObj.Class_BeginTime + "至" + classObj.Class_EndTime + "</div>", colspan:cols, tdstyle:"border:none"};
	courseGrid[2] = {};
	for (var x = 0; x < viewhead.length; x++)
	{
		courseGrid[2][viewhead[x].FieldName] = {value:viewhead[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};
	}
	var y = 0;
//var d1 =  $.jcom.makeDateObj("2018-5-21");
	for (var d = d1; d <= d2; d.setDate(d.getDate() + 1))
	{
		var lineControl = {};
		var datetype = getCourseDateNote(d, cd1, cd2,oditems);
		if (EditMode == 1)
		{
			switch (datetype)
			{
			case "入学前":
				lineControl = {bgcolor:"#c8c8c8"};
				break;
			case "结业后":
				lineControl = {bgcolor:"#d0d0d0"};
				break;
			case "异地教学":
				lineControl = {bgcolor:"#e0e0ff"};
				break;
			default:
				if (isHoliday(d))
					lineControl = {bgcolor:"#e0ffe0"};				
				break;
			}
		}
		var x = courseGrid.length;
		if (EditMode == 1)
		{
			courseGrid[x] = InitCourseGridItem(option.AMBegin, option.AMEnd, 0, d, datetype, lineControl);
			courseGrid[x + 1] = InitCourseGridItem(option.PMBegin, option.PMEnd, courseGrid[x]);
			if (nDayUse == 3)
				courseGrid[x + 2] = InitCourseGridItem(option.EVBegin, option.EVEnd, courseGrid[x]);
		}
		else if (!isHoliday(d) && (option.ShowWorkdayIdle != "") && (option.ShowWorkdayIdle != "null"))
		{
			courseGrid[x] = InitCourseGridItem(option.AMBegin, option.AMEnd, 0, d, datetype, lineControl);
			courseGrid[x + 1] = InitCourseGridItem(option.PMBegin, option.PMEnd, courseGrid[x]);
		}
		
		while (y < courseObj.length)
		{
			var d3 = $.jcom.makeDateObj(courseObj[y].Syllabuses_date);
			if ((d3.getYear() == d.getYear()) && (d3.getMonth() == d.getMonth()) && (d3.getDate() == d.getDate()) && (courseObj[y].EditFlag != 3))
			{
				var pos = findCourseGridPos(courseObj[y].BeginTime, x);
				if (pos == -1)
				{
					courseGrid[x] = InitCourseGridItem(courseObj[y].BeginTime, courseObj[y].EndTime, 0, d3, datetype, lineControl);
					pos = x;
					TransCourseItem(courseObj[y], courseGrid[x]);
				}
				else
					TransCourseGrid(courseObj[y], pos);
				courseGrid[pos].index = y;
				y++;
			}
			else
			{
				if ((d > d3) || (courseObj[y].EditFlag == 3))
					y ++;
				else
					break;
			}
		}
	}
	if (EditMode == 1)
		return view.reset(courseGrid, viewInfo, viewhead);

	for (var x = nTitleRows; x < courseGrid.length; x++)
	{
		if (courseGrid[x].index < 0)
		{
//			if (!isHoliday(d) && (option.ShowWorkdayIdle != "null"))
				courseGrid[x].Course = {value:option.ShowWorkdayIdle, colspan:3};
				delete courseGrid[x].Teacher;
				delete courseGrid[x].ClassRoom;
		}
	}
	viewInfo.Records = courseGrid.length;
	if (PrepareCourseUserData(courseGrid) == false)
		return;
	view.reset(courseGrid, viewInfo, viewhead);

//	AttachEditor();
}

function findCourseGridPos(d, b)
{
	var pos = courseGrid.length;
	var ap = getDateAP(d);
//	if (ap == "晚上")
//	{
//		InsertCourseItem(pos);
//		return pos;
//	}
	if (b == courseGrid.length)
		return -1;
	for (var x = b; x < courseGrid.length; x++)
	{
		var ap1 = courseGrid[x].ap;
		if (typeof ap1 == "object")
			ap1 = ap1.value;
		if (ap == ap1)
		{
			if (courseGrid[x].index < 0)
				return x;
			pos = x + 1;
		}
	}
	InsertCourseItem(pos);
	return pos;
}

function TransCourseGrid(courseItem, index)
{
	var gridItem = courseGrid[index];
	var b = $.jcom.GetDateTimeString(courseItem.BeginTime, 14);
	if (courseItem.nType == 2)	//选修课
	{
		var flag = 0;	//默认是不合并的单元格
		for (var x = index - 1; x >= 0; x --)
		{
			if (typeof courseGrid[x].BeginTime != "object")
				continue;
			if (courseGrid[x].BeginTime.ex != b)
				break;
			if (typeof courseGrid[x].BeginTime == "object")
			{
				if (courseGrid[x].BeginTime.rowspan == 1)
					courseGrid[x].BeginTime.value += "<br>选修课";
				courseGrid[x].BeginTime.rowspan ++;
			}
			if (typeof courseGrid[x].EndTime == "object")
				courseGrid[x].EndTime.rowspan ++;
			flag = 1;
		}
		if (flag == 1)
			delete gridItem.BeginTime;
	}
	if (((courseItem.nType == 2) && (typeof gridItem.BeginTime != "undefined")) || (courseItem.nType != 2))
	{
		var ap = getDateAP(courseItem.BeginTime);
		var flag = 0;
		for (var x = index - 1; x >= 0; x --)
		{
			if (typeof courseGrid[x].ap == "undefined")
				continue;
			if (courseGrid[x].ap == ap)
			{
				courseGrid[x].ap = {value:courseGrid[x].ap, rowspan:2}
				flag = 1;
				break;
			}
			
			if (courseGrid[x].ap.value == ap)
			{
				courseGrid[x].ap.rowspan ++;
				flag = 1;
				break;
			}
			break;
		}
		if (flag == 0)
			gridItem.ap = ap;
		gridItem.BeginTime = {value:b, ex:b, rowspan:1};
		gridItem.EndTime = {value:$.jcom.GetDateTimeString(courseItem.EndTime, 14), rowspan:1};
		if (option.ShowEndTime == 2)
		{
			gridItem.BeginTime.value = "<div id=Field_BeginTime style='width:100%;overflow-y:visible'>" + gridItem.BeginTime.value +
				"</div><div id=Field_EndTime style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;'>" + gridItem.EndTime.value + "</div>";
		}
//		else if (option.ShowEndTime == 2)
//			gridItem.BeginTime = {value:getDateAP(gridItem.BeginTime)};
	}
	TransCourseItem(courseItem, gridItem);
}

function TransCourseItem(courseItem, gridItem)
{
	if (typeof courseItem.Syllabuses_subject_name == "undefined")
		return;
	var c = getCourseName(courseItem);
	gridItem.Course = {value:c, ex:c};

	if ((courseItem.Syllabuses_activity_id == 0) && (courseItem.Syllabuses_course_id == 0) && (courseItem.Syllabuses_subject_id == 0) && (option.ShowRed == 1))
		gridItem.Course.color = CourseWarningColor;
	if ((courseItem.EditFlag == 1) || (courseItem.EditFlag == 2))
		gridItem.Course.style = CourseNoSaveStyle;
	else
		gridItem.Course.style = CourseSaveStyle;
	if (option.ShowNote == 2)
	{
		if (EditMode == 1)
		{
			gridItem.Course.value = "<div id=Field_Course style='width:100%;overflow-y:visible'>" + gridItem.Course.value +
				"</div><div id=Field_Note style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;'>" + 
				courseItem.Syllabuses_bak + "</div>";
		}
		else
		{
			if (courseItem.Syllabuses_bak.substr(0, 1) == "!")
				gridItem.Course.value = courseObj[x].Syllabuses_bak;
			else if (courseItem.Syllabuses_bak.substr(0, 1) == "~")
				gridItem.Course.value = gridItem.Course.value + courseItem.Syllabuses_bak;
			else
				gridItem.Course = gridItem.Course.value + "<br>" + courseItem.Syllabuses_bak;
		}
	}
	gridItem.Teacher = {value:courseItem.Syllabuses_teacher_name, color:"black"};
	if ((courseItem.Syllabuses_teacher_id == 0) && (option.ShowRed == 1))
		gridItem.Teacher = {value:courseItem.Syllabuses_teacher_name, color:CourseWarningColor};
	if ((courseItem.nConflict & 2) > 0)
		gridItem.Teacher = {value:courseItem.Syllabuses_teacher_name, color:CourseConflictColor, prop:"title='冲突内容:" + courseItem.ConflictInfo + "'"};
	
	gridItem.AssistMan = {value:courseItem.AssistMan, color:"black"};
	if ((courseItem.nConflict & 4) > 0)
		gridItem.AssistMan = {value:courseItem.AssistMan, color:CourseConflictColor, prop:"title='冲突内容:" + courseItem.ConflictInfo + "'"};
			
	if (option.ShowAssistMan == 2)
	{
		gridItem.Teacher.value = "<div id=Field_Teacher style='width:100%;overflow-y:visible'>" + gridItem.Teacher.value +
			"</div><div id=Field_AssistMan style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;color:" + 
			gridItem.AssistMan.color + "'>" + courseItem.AssistMan + "</div>";
	}
	gridItem.ClassRoom = courseItem.Syllabuses_ClassRoom;
	if ((courseItem.nConflict & 1) > 0)
		gridItem.ClassRoom = {value:courseItem.Syllabuses_ClassRoom, color:CourseConflictColor, prop:"title='冲突内容:" + courseItem.ConflictInfo + "'"};
	gridItem.Note = courseItem.Syllabuses_bak;
	gridItem.AssistInfo = courseItem.AssistInfo;
}

function getCourseName(item)
{
	if (item.Syllabuses_activity_id > 0)
		 return item.Syllabuses_activity_name;
	else if (item.Syllabuses_subject_name > 0)
		return item.Syllabuses_subject_name;
	else
		return item.Syllabuses_course_name;
}

function AttachEditor()
{
	view.attachEditor("Course", courseEdit, false);
	view.attachEditor("Teacher", teacherEdit, false);
	view.attachEditor("Note", noteEdit, false);
	view.attachEditor("BeginTime", timeEdit, false);
	view.attachEditor("EndTime", timeEdit, false);
	view.attachEditor("ClassRoom", roomEdit, false);
	view.attachEditor("AssistInfo", AssistInfoEdit, false);
	view.attachEditor("AssistMan", AssistManEdit, false);
}

function getCourseDateNote(d, cd1, cd2, oditems)
{
	if (d < cd1)
		return "入学前";
	if (d > cd2)
		return "结业后";
	for (var x =0; x < oditems.length; x++)
	{
		if ((d >= oditems[x].b) && (d <= oditems[x].e))
			return "异地教学";
	}
	
	return getHolidayName(d);
}

function getHolidayName(d)
{
	for (var x = 0; x < holiItems.length; x++)
	{
		var d1 = $.jcom.makeDateObj(holiItems[x].THoliday);
		if ((d1.getFullYear() == d.getFullYear()) && (d1.getMonth() == d.getMonth()) && (d1.getDate() == d.getDate()))
		{
			if (holiItems[x].HolidayName != "")
				return holiItems[x].HolidayName;
			switch (holiItems[x].nType)
			{
			case 1:
				return "节假日";
			case 2:
				return "休息日";
			case 3:
				return "工作 日";
			}
		}
	}
	return "";
}


function getOuterItems()
{
	var oditems = [];
	oditems[0] = {b: $.jcom.makeDateObj(classObj.OuterBegin), e: $.jcom.makeDateObj(classObj.OuterEnd)};
	for (var x = 0; x < classObj.OtherOuterTime.length; x++)
		oditems[oditems.length] = {b: $.jcom.makeDateObj(classObj.OtherOuterTime[x].OuterBegin), e: $.jcom.makeDateObj(classObj.OtherOuterTime[x].OuterEnd)};
	return oditems;
}

/*
function ReloadReadOnlyCourse()
{
	var index = 0;
	courseGrid = [];
	courseGrid[0] = {};
	var childs = view.getChildren();
	var cols = childs.gridhead.getColumnCount();
	courseGrid[0].CourseTime = {value:classObj.Class_Name + "<br>课程表", colspan:cols,prop:"align=center ", style:"font:normal normal 400 14pt 黑体;",tdstyle:"border:none"};
	courseGrid[1] = {};
	courseGrid[1].CourseTime = {value:"<div style=float:left>班次编号:" + classObj.ClassCode + "</div><div style=float:right>培训时间:" + 
			classObj.Class_BeginTime + "至" + classObj.Class_EndTime + "</div>", colspan:cols, tdstyle:"border:none"};
	courseGrid[2] = {};
	for (var x = 0; x < viewhead.length; x++)
	{
		courseGrid[2][viewhead[x].FieldName] = {value:viewhead[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};
	}

	var cd1 = $.jcom.makeDateObj(classObj.Class_BeginTime);
	var cd2 = $.jcom.makeDateObj(classObj.Class_EndTime);
	var oditems = getOuterItems();
	
	var y = 3;
	var d1 = $.jcom.makeDateObj("1970-1-1");
	for (var x = 0; x < courseObj.length; x++)
	{
		var d2 = $.jcom.makeDateObj(courseObj[x].Syllabuses_date);
		var b = $.jcom.GetDateTimeString(courseObj[x].BeginTime, 14);
		var e = $.jcom.GetDateTimeString(courseObj[x].EndTime, 14);

		if ((d2.getYear() == d1.getYear()) && (d2.getMonth() == d1.getMonth()) && (d2.getDate() == d1.getDate()))
			courseGrid[y] = InitCourseGridItem(b, e, courseGrid[y - 1]);
		else
		{
			if (x > 0)
			{
				var t = Math.round((d2.getTime() - d1.getTime()) / (1000 * 60 * 60 * 24));
				for (var z = 1; z < t; z++)
				{
					d1.setDate(d1.getDate() + 1);
					if (!isHoliday(d1) && (option.ShowWorkdayIdle != "null"))
					{
						courseGrid[y] = InitCourseGridItem(option.AMBegin, option.AMEnd, 0, d1, getCourseDateNote(d1, cd1, cd2, oditems));
						courseGrid[y++].Course = option.ShowWorkdayIdle;
						courseGrid[y] = InitCourseGridItem(option.PMBegin, option.PMEnd, courseGrid[y - 1]);
						courseGrid[y++].Course = option.ShowWorkdayIdle;
					}
				}
			}
			if (getDateAP(b) != "上午")
				courseGrid[y] = InitCourseGridItem(option.AMBegin, option.AMEnd, 0, d1, getCourseDateNote(d1, cd1, cd2, oditems));
			courseGrid[y++].Course = option.ShowWorkdayIdle;
				
			courseGrid[y] = InitCourseGridItem(b, e, 0, d2, getCourseDateNote(d2, cd1, cd2, oditems));
			d1 = d2;
			index = x;
		}
		courseGrid[y].index = x;
		if (option.ShowEndTime == 2)
			courseGrid[y].BeginTime = courseGrid[y].BeginTime + "<br>" + courseGrid[y].EndTime;
//		else if (option.ShowEndTime == 2)
//			courseGrid[y].BeginTime = getDateAP(courseGrid[y].BeginTime);

		courseGrid[y].Course = getCourseName(courseObj[x]);
		if (option.ShowNote == 2)
		{
			if (courseObj[x].Syllabuses_bak.substr(0, 1) == "!")
				courseGrid[y].Course = courseObj[x].Syllabuses_bak;
			else if (courseObj[x].Syllabuses_bak.substr(0, 1) == "~")
				courseGrid[y].Course = courseGrid[y].Course + courseObj[x].Syllabuses_bak;
			else
				courseGrid[y].Course = courseGrid[y].Course + "<br>" + courseObj[x].Syllabuses_bak;
		}
		courseGrid[y].Teacher = courseObj[x].Syllabuses_teacher_name;
		if (option.ShowAssistMan == 2)
			courseGrid[y].Teacher = courseObj[x].Syllabuses_teacher_name + "<br>" + courseObj[x].AssistMan;
		courseGrid[y].ClassRoom = courseObj[x].Syllabuses_ClassRoom;
		courseGrid[y].Note = courseObj[x].Syllabuses_bak;
		courseGrid[y].AssistMan = courseObj[x].AssistMan;
		courseGrid[y].AssistInfo = courseObj[x].AssistInfo;

//		if (parseInt(courseObj[x].AssistInfo) > 0)
//		{
//			var ss = enumAssistInfo[parseInt(courseObj[x].AssistInfo)].split(":");
//			if (ss.length > 1)
//				courseGrid[y].AssistInfo = ss[1];	
//		}
		y++;
	}
	viewInfo.Records = courseGrid.length;
	if (PrepareCourseUserData(courseGrid) == false)
		return;
	view.reset(courseGrid, viewInfo, viewhead);

	if (RunOutToServer == 1)
	{
		RunOutToServer = 0;
		if (window.confirm("是否将课程表导出到服务器的班次文档中？") == true)
			OutExceltoServer();
	}
}
*/

function GridEditorTest(td, headitem)
{
	var tr = td.parentNode;
	if (tr.rowIndex < nTitleRows)
		return false;
	return true;
}

function ClickViewCell(td, event)
{
	if (td == undefined)
		return;
	var tr = td.parentNode;
	if (tr.rowIndex < 3)
		return;
	var shadow = view.getsel();
	if (event.shiftKey)
	{
		var objs = shadow.getShadow();
		if (objs.length > 0)
		{
			var min = objs[0].obj.parentNode.rowIndex;
			var max = min;
			for (var x = 1; x < objs.length; x++)
			{
				if (objs[x].obj.parentNode.rowIndex < min)
					min = objs[x].obj.parentNode.rowIndex;
				if (objs[x].obj.parentNode.rowIndex > max)
					max = objs[x].obj.parentNode.rowIndex;
			}
			var index = tr.rowIndex;
			if (index < min)
				min = index;
			else
				max = index;
			var t = tr.parentNode;
			shadow.show();
			for (var x = min; x <= max; x++)
			{
				tr = t.rows[x];
				shadow.show($("#Course_TD", tr)[0], true);
			}
			document.selection.empty();
			return;
		}
	}
	if  (event.ctrlKey == false)
		shadow.show();
	var len = td.rowSpan;
	for (var y = 0; y < len; y++)
	{
		var cells = tr.cells;
		for (var x = 0; x < cells.length; x++)
		{
			if (cells[x].id == "Course_TD")
				shadow.show(cells[x], true);
		}
		tr = tr.nextSibling;				
	}
	if  (event.ctrlKey || event.shiftKey)
		document.selection.empty();
}

function getViewSelRows()
{
	var shadow = view.getsel();
	var objs = shadow.getShadow();
	if (objs.length == 0)
		return [];
	var oo = [];		
	if (objs[0].obj.tagName == "TR")
	{
		for (var x = 0; x < objs.length; x++)
			oo[x] = objs[x].obj;
		return oo;
	}
	
	oo[0] = objs[0].obj.parentNode;
	var y = 0;
	for (var x = 1; x < objs.length; x++)
	{
		if (oo[y] != objs[x].obj.parentNode)
		{
			y ++;
			oo[y] = objs[x].obj.parentNode;
		}
	}
	return oo;	
}


function SetCourseObj(index)
{
	var x = courseGrid[index].index;
	if (x >= 0)
	{
	 	if (courseObj[x].EditFlag == 0)
			courseObj[x].EditFlag = 2;	//Update Flag;
	}
	else
	{
		x = NewCourseObjItem();
		courseGrid[index].index = x;
		if (courseGrid[index].DateValue == undefined)
			alert("ERRR");
		courseObj[x].Syllabuses_date = courseGrid[index].DateValue;

//		for (var y = 0; y < 100; y++)
//		{			
//			if(typeof courseGrid[index - y].CourseTime != "undefined")
//			{
//				courseObj[x].Syllabuses_date = courseGrid[index - y].DateValue;
//				break;
//			}
//		}
		
		if (typeof courseGrid[index].BeginTime == "object")
			courseObj[x].BeginTime = $.jcom.GetDateTimeString(courseObj[x].Syllabuses_date, 1) + " " + courseGrid[index].BeginTime.ex;
		else
			courseObj[x].BeginTime = courseObj[x].Syllabuses_date + " " + courseGrid[index].BeginTime;
		var e = courseGrid[index].EndTime;
		if (typeof e == "object")
			e = e.value;
		courseObj[x].EndTime = $.jcom.GetDateTimeString(courseObj[x].Syllabuses_date, 1) + " " + e;
	}
	return x;
}

function NewCourseObjItem()
{
	x = courseObj.length;
	courseObj[x] = {EditFlag:1, Syllabuses_id:0,Syllabuses_subject_id:0, Syllabuses_subject_name:"", Syllabuses_activity_id:0,
		Syllabuses_activity_name:"", Syllabuses_course_id:0, Syllabuses_course_name:"", Syllabuses_Department:"",
		Syllabuses_teacher_id:0, Syllabuses_teacher_name:"", Syllabuses_ClassRoom_id:0, Syllabuses_ClassRoom:"", 
		Syllabuses_bak:"", AssistMan:"", AssistInfo:""};		//EditFlag=1,Insert Flag
	return x;	
}

function SetMode(mode)
{
	if (EditMode != 1)
		return;
	switch (mode)
	{
	case 1:		//未打开课表
		break;
	case 2:		//已打开课表，未修改
		$(window).off("beforeunload", SaveConfirm);
//		menubar.setDisabled("编辑", false);
		menubar.setDisabled("保存", true);
		break;
	case 3:		//已打开课表，已修改
		menubar.setDisabled("保存", false);
		$(window).on("beforeunload", SaveConfirm);
		if (AutoSaveCourse == 1)
			SaveDoc();
		break;
	}
}

function SaveConfirm()
{
	event.returnValue="课程表内容已改变";
}

$.jcom.DynaEditor.TeachAssistEditor = function (width, height)
{
	var self = this;
	var calendar;
	$.jcom.DynaEditor.Base.call(this, width, height);
	
	this.createPop = function ()
	{
		var obj = self.oBox.getdomobj();
		calendar = new $.jcom.CalendarBase(0, obj);
		obj.className = "CanlendarDiv";
		obj.style.border = "1px solid gray";
		obj.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray)";
		obj.style.width = self.width;
		obj.style.height = self.height;
		calendar.clickDate = this.confirm;
	};
		
	this.onpop = function ()
	{
		calendar.show(self.oEdit.firstChild.value);
		var d = calendar.getDate();
		self.oEdit.firstChild.value = d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
		calendar.selDateCell(d);
	};
};

function CopyfromSyllabuses()
{
	if (window.confirm("只有不通过教学计划直接排 课的课程才需要复制，是否继续？") == false)
		return;
	$.get("../fvs/CPB_Class_Course.jsp",{Ajax:1,CopyfromSyllabuses:1,DataID:classID}, function (s){alert(s);});
}

function RunTeachPlan()
{
	window.open("../fvs/CPB_Class_Course.jsp?EditMode=1&DataID=" + classID);
}

function CourseEditHis()
{
	if (classID > 0)
		window.open("../fvs/DownLog_CourseView.jsp?ClassID=" + classID);
}

function DeleteOldCourse()
{
	if (window.confirm("将删除课程表中在本班开始时间和结束时间以外的课程，是否确定？\n\n(提示：这些课程通常是因为修改了本班的开始和结束时间引起。如果确实需要这些课程，应该移动到合适的时间位置.)") == false)
		return;
	$.get(coursePath, {DeleteOldCourse:1, ClassID:classObj.Class_id}, function (result) {alert(result);location.reload(true);});
}

function AutoPlanCourse()
{
	if (rootItems[0].child == null)
	{
		var obj = tree.getNodeObj("nType", 1);	//教学计划
		tree.reloadNode(obj, true);
		return alert("提示：请在教学计划加载完成后再调用此功能。");
	}
	var aUnit = rootItems[0].child;
	beUnit = aUnit[aUnit.length - 1].child;
	aUnit.splice(0, 0, {child:[]});
	for (var x = 0; x < beUnit.length; x++)
	{
		if (beUnit[x].Course_name == "开班式")
		{
			aUnit[0].child = beUnit.splice(x, 1);
			break;
		}
	}
	var index = 0;
	for (var x = 0; x < aUnit.length; x++)
		index = AutoPlanUnit(aUnit[x], index);
	
	var obj = tree.getNodeObj("nType", 1);
	tree.reloadNode(obj, true);
	SetMode(3);
}

function AutoPlanUnit(u, index)
{
	for (var y = 0; y < u.child.length; y++)
	{
		var item = u.child[y];
		if (typeof item.child == "object")
		{
			for (var z = 0; z < item.child.length; z ++)
				index = ApplyPlanItem(item.child[z], index);
		}
		else
			index = ApplyPlanItem(item, index);
		if (index >= courseGrid.length)
			break;
	}
	return index;
}

function ApplyPlanItem(item, index)
{
	if (CheckItemInCourse(item, 3))
		return index;
	index = skipCourseGrid(index);
	if (index >= courseGrid.length)
		return index;
	if (item.Subject_id > 0)
		o = {CourseID: item.Course_id, CourseName:item.Course_name, ActID: 0, ActName:"", SubjID:item.Subject_id, SubjName:item.Course_name, 
			TeacherID:item.Teacher_id, TeacherName:item.Teacher_name, t:item.Course_time};
	else// if (item.Activity_id > 0)
		o = {CourseID: item.Course_id, CourseName:item.Course_name, ActID: item.Activity_id, ActName:item.Course_name, SubjID:0, SubjName:"",
			TeacherID:item.Teacher_id, TeacherName:item.Teacher_name, t:item.Course_time};
	ApplyItem(index, o)
	return index + 1;
}

function NormalView()
{
	$("#CourseTable").css({width:"100%", height:"100%",overflowY:"hidden",padding:"0px", border:"none"});
	$("#RightDiv").attr({align:"left"});
	$("#RightDiv").css({overflow:"hidden", backgroundColor: "white"});

	var item = menubar.getItem("普通视图");
	item.img = "../pic/flow_end.png";
	item = menubar.getItem("页面视图");
	item.img = "";
	view.reset(true);
}

function PageView()
{
	$("#RightDiv").attr({align:"center"});
	$("#RightDiv").css({overflow:"auto", backgroundColor: "#c0c0c0"});
	$("#CourseTable").css({width:"798px", height:"1000px", overflowX:"hidden", overflowY:"visible",padding:"20px 100px 20px 100px", 
		borderLeft:"1px solid black", borderBottom:"1px solid black", borderRight:"3px solid black"});
	view.reset(true);

	var item = menubar.getItem("页面视图");	
	if (item == undefined)
		return;
	item.img = "../pic/flow_end.png";
	item = menubar.getItem("普通视图");
	item.img = "";
}

function ClearSearch()
{
//	var data = tree.getdata();
//	if (data == rootItems)
//	{		
//		$("#SearchInput")[0].fireEvent("onmousedown");
//		return;
//	}
	$("#SearchInput").html("");
	SearchEdit.checkTitle($("#SearchInput")[0], false);
	tree.setdata(rootItems);
	CheckSearchButton();
}

function DocSearch(value)
{
	if (value == "")
		return;
	$.get(coursePath + "?SearchSubjectDoc=1&SeekKey=" + value, {}, DocSearchOK);
}

function DocSearchOK(data)
{
	var list = eval(data);
	for (var x = 0; x < list.length; x++)
	{
		list[x].item = "<img src=../pic/384.png style=height:16px>&nbsp;" + list[x].Subject_name + "-" + list[x].Teacher_name;
		list[x].nType = 32;
//		CheckItemInCourse(item.child[x], 1);
	}
	
	tree.setdata(list);	
}

function SetSearchButton()
{
	$("#SearchButton").attr("src", "../pic/delete1.gif");
}

function CheckSearchButton()
{
	var data = tree.getdata();
	if (data == rootItems)
		$("#SearchButton").attr("src","../pic/search.png");
	else
		$("#SearchButton").attr("src", "../pic/delete1.gif");
}

var setCommWin, commSetclassView;
function SetCommCourse()
{
	var dest = getViewSelRows();
	if (dest.length == 0)
		return alert("请在课程表中选择课程");
	var index = courseGrid[dest[0].rowIndex].index;
	if (index < 0)
		return alert("请在课程表中选择课程");
	if (courseObj[index].Syllabuses_id == 0)
		return alert("请先保存当前课程后再设置公共课");

	if (setCommWin == undefined)
	{
	 	setCommWin = new $.jcom.PopupWin("<div id=ClassDiv style=width:100%;height:420px;overflow:auto;></div><div style=float:left><input id=DelOldCommCourseFlag type=checkbox checked>清除同时段原有的课程</div>" +
			"<div align=right style=width:100%;height:30px><input id=CommonCourseRun type=button value=设置 onclick=RunSetCommonCourse()>&nbsp;&nbsp;</div>", 
			{title:"选择要使用公共课程的班", width:400, height:480, mask:50});
		var h = [{FieldName:"Class_Name", TitleName:"班次名称", nWidth:325, nShowMode:1},
		    	    {FieldName:"Option", TitleName:"选择", nWidth:60, nShowMode:1}];
		setCommWin.close = setCommWin.hide;
		commSetclassView = new $.jcom.GridView(document.all.ClassDiv, h, [], {}, {footstyle:4});
	}
	else
		setCommWin.show();
	$.get(coursePath, {GetClassByTime:1, Term_id: classObj.Term_id, Class_id:classObj.Class_id, Time:courseObj[index].BeginTime}, SetCommonCourseDlg);
}

function SetCommonCourseDlg(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return commSetclassView.waiting(json);
	
	for (var x = 0; x < json.length; x++)
		json[x].Option = "<input type=checkbox checked name=ClassOption value=" + json[x].Class_id + ">";
	commSetclassView.reload(json);
}

function RunSetCommonCourse()
{
	var o = $("input[name='ClassOption']");
	var IDs = "", sp ="";
	for (var x = 0; x < o.length; x++)
	{
		if (o[x].checked)
		{
			IDs += sp + o[x].value;
			sp = ",";
		}
	}
	var DelFlag = 0;
	if ($("#DelOldCommCourseFlag").prop("checked"))
		DelFlag = 1;
	if (IDs == "")
		return alert("至少选一个班。");
	if (window.confirm("您正在把所选课程设置为公共课，将改变所选同期班次的课表，是否确定?") == false)
		return;

	var dest = getViewSelRows();
	var index = courseGrid[dest[0].rowIndex].index;		
	$.get(coursePath, {SetCommonCourse:1, Syllabuses_id:courseObj[index].Syllabuses_id, DelFlag:DelFlag, ClassIDs:IDs}, SetCommonCourseOK);
}

function SetCommonCourseOK(data)
{
	alert(data);
	setCommWin.hide();
	
}

function SetFreeCourse()
{
	alert("==");
}

function CourseMenu(td, e)
{
	if ((td == undefined) || (e.ctrlKey) || (document.selection.type == "Text"))
		return;
	var tr = td.parentNode;
	if (tr.rowIndex < 3)
		return;
	if ((option.ShowEndTime == 0) && (td.id.substr(0, td.id.length -3) == "ap"))
	{
		ClickViewCell(td, e);
		var dest = getViewSelRows();
		index = dest[0].rowIndex;
		if (courseGrid[index].index >= 0)
		{
			EditCourseTime(td, e);
			return false;
		}
	}
	var item = menubar.getItem("不使用本系统重定义的右键菜单");	
	if (item == undefined)
		return;
	if (item.img != "")
		return;
	ClickViewCell(td, e);
	rmenu.show();
	return false;
}

var EditCourseTimeBox;
function EditCourseTime(obj, e)
{
	var pos = $.jcom.getObjPos(e.target);
	if (EditCourseTimeBox == undefined)
	{
		EditCourseTimeBox = new $.jcom.PopupBox("", pos.left, pos.top, pos.left, pos.bottom - 1);
		var o = EditCourseTimeBox.getdomobj();
		o.style.border = "1px solid gray";
		o.style.padding = "8px";
		o.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray)";
	}
	var tag = "";
	var dest = getViewSelRows();
	for (var x = 0; x < dest.length; x++)
	{
		index = dest[x].rowIndex;
		var b = courseGrid[index].BeginTime;
		if (typeof b == "object")
			b = b.value;
		var e = courseGrid[index].EndTime;
		if (typeof e == "object")
			e = e.value;
		if (tag != "")
			tag += "<hr size=1 style=width:300px>";
		tag += "<div style=width:260px>" + courseGrid[index].Course.ex  + "</div>" +
			"<div style=width:260px><span style=width:100px>上课时间</span><span node=" + index + " class=Inline_BeginTime style=width:100px>" + b + "</span></div>" +
			"<div style=width:260px><span style=width:100px>下课时间</span><span node=" + index + " class=Inline_EndTime style=width:100px>" + e + "</span></div>";
	}
	EditCourseTimeBox.setPopObj(tag);
//	$("#InlineCourseBeginTime").val(b);
//	$("#InlineCourseEndTime").val(e);
	EditCourseTimeBox.show(pos.left, pos.top, pos.left, pos.bottom - 1);
	for (var x = 0; x < $(".Inline_BeginTime").length; x++)
	{
		timeEdit.attach($(".Inline_BeginTime")[x]);
		timeEdit.attach($(".Inline_EndTime")[x]);
	}
	$(document).on("mousedown",EditCourseTimeBoxHide);
}

function InlineTimeChange(obj)
{
	var field = obj.className.substr(7);
	var index = $(obj).attr("node");
	var y = SetCourseObj(index);
	var d = $.jcom.GetDateTimeString(courseObj[y].Syllabuses_date, 1);
	var t = $.jcom.GetDateTimeString(d + " " + obj.innerText, 3);
	if (t != "")
		courseObj[y][field] = t;
	courseGrid[index][field].value = obj.innerText;
	SetMode(3);
	
}

function EditCourseTimeBoxHide(e)
{
	if (timeEdit.isBoxShow())
		return;
	var b = EditCourseTimeBox.getdomobj();
	if ((b == e.target) || ($(e.target).parents().is($(b))))
		return;
	for (var x = 0; x < $(".Inline_BeginTime").length; x++)
	{
		timeEdit.detach($(".Inline_BeginTime")[x]);
		timeEdit.detach($(".Inline_EndTime")[x]);
	}
	$(document).off("mousedown",EditCourseTimeBoxHide);
	EditCourseTimeBox.hide();	
}

function SetRightMenu(obj, item)
{
	if (item.img == "")
		item.img = "../pic/flow_end.png";
	else
		item.img = "";
}

function OneClassView()
{
	var item = menubar.getItem("班次或学期课表");
	if (item.img != "")
		return;
 	$("#LeftDiv").css({width:"360px"});
	$("#RightDiv").css({width:"auto", overflow:"auto", backgroundColor: "#c0c0c0"});
	$("#CourseTable").css({width:"798px", height:"1000px", overflowX:"hidden", overflowY:"visible",padding:"20px 100px 20px 100px", 
		borderLeft:"1px solid black", borderBottom:"1px solid black", borderRight:"3px solid black"});
	layer.refresh(0, false);
	item.img = "../pic/flow_end.png";
	item = menubar.getItem("纵向多班总课表");
	item.img = "";
	item = menubar.getItem("横向多班总课表");
	item.img = "";
	$("#TitleSpan").html("班次或学期课表");
	view.waiting();
    if (classID > 0)
    	LoadCourse(classID);
    else
    	OpenReadOnlyClass();
}

var ManyCourseWin, ManyCourseOptionView, menuItem;
function ManyClassView(obj, item)
{
	menuItem = item;
	var ClassID = "";
	var BeginTime = "", EndTime = "";
	if (typeof classObj == "object")
	{
		ClassID = classObj.Class_id;
		BeginTime = $.jcom.GetDateTimeString(classObj.Class_BeginTime, 1);
		EndTime = $.jcom.GetDateTimeString(classObj.Class_EndTime, 1);
	}
	else if (courseObj.length > 0)
	{
		ClassID = courseObj[0].class_id;
		BeginTime = $.jcom.GetDateTimeString(courseObj[0].Syllabuses_date, 1);
		EndTime = $.jcom.GetDateTimeString(courseObj[courseObj.length - 1].Syllabuses_date, 1);
	}
//	if (ClassID == "")
//		return alert("没有数据,不能切换");
	if (ManyCourseWin == undefined)
	{
		ManyCourseWin = new $.jcom.PopupWin("<p style=width:100%;height:30px><span>标题：</span><span><input type=Text style=width:400px value=总课表 id=ManyCourseTitle></span></p>" +
			"<p style=width:100%;height:30px>培训时间：<span id=ClassBeginTime class=DateEditor style=width:70px>" + BeginTime + 
			"</span> 至  <span id=ClassEndTime class=DateEditor style=width:70px>" + EndTime + "</span>&nbsp;<input type=button value=根据时间段载入班次 onclick=GetManyClass()></p>" +
			"<div id=ClassCourseDiv style=width:100%;height:420px;overflow:auto;></div><div style=float:left><input type=button onclick=RemoveManyClassOne() value=移除>&nbsp;" +
			"<input type=button value=上移 onclick=UpManyClassOne()>&nbsp;<input type=button value=下移 onclick=DownManyClassOne()>&nbsp;</div>" +
			"<div align=right style=width:100%;height:30px><input type=button value=完成 onclick=RunSetManyClassOption()>&nbsp;&nbsp;</div>", 
			{title:"总课表时间和班次设置", width:580, height:560, mask:50});
		var h = [{FieldName:"ClassCode", TitleName:"班次编号", nWidth:80, nShowMode:1},
		         {FieldName:"Class_Name", TitleName:"班次名称", nWidth:260, nShowMode:1},
		         {FieldName:"Class_BeginTime", TitleName:"开始时间", nWidth:90, nShowMode:1},
		         {FieldName:"Class_EndTime", TitleName:"结束时间", nWidth:90, nShowMode:1}];
		ManyCourseWin.close = ManyCourseWin.hide;
		ManyCourseOptionView = new $.jcom.GridView($("#ClassCourseDiv")[0], h, [], {}, {footstyle:4});
		var dtEdit = new $.jcom.DynaEditor.Date(300, 300);
		dtEdit.attach($("#ClassBeginTime")[0]);
		dtEdit.attach($("#ClassEndTime")[0]);
	}
	else
		ManyCourseWin.show();
}

function GetManyClass()
{
	if (($("#ClassBeginTime").text() == "") && ($("#ClassEndTime").text() == ""))
		return alert("开始时间和结果时间不可为空");
	$.get(coursePath, {GetClassByBETime:1, ClassBeginTime:$("#ClassBeginTime").text(), ClassEndTime:$("#ClassEndTime").text()}, GetManyClassOK);
}

function RemoveManyClassOne()
{
	var row = ManyCourseOptionView.getSelRow();
	if (row == undefined)
		return alert("删除前要先选择一行。");
	ManyCourseOptionView.deleteRow(row);
	
}

function UpManyClassOne()
{
	var row = ManyCourseOptionView.getSelRow();
	if (row == undefined)
		return alert("请选择一行先");

	var node = parseInt(row.node);
	if (node == 0)
		return alert("已到第一条，不能上移");
	var p = ManyCourseOptionView.deleteRow(node);
	ManyCourseOptionView.insertRow(p, node - 1);
	ManyCourseOptionView.select(node - 1);
}

function DownManyClassOne()
{
	var row = ManyCourseOptionView.getSelRow();
	if (row == undefined)
		return alert("请选择一行先");

	var node = parseInt(row.node);
	var data = ManyCourseOptionView.getData();
	if (node == data.length - 1)
		return alert("已到最后一条，不能下移");
	var p = ManyCourseOptionView.deleteRow(node);
	ManyCourseOptionView.insertRow(p, node + 1);
	ManyCourseOptionView.select(node + 1);
}

function GetManyClassOK(data)
{
	var items = $.jcom.eval(data);
	ManyCourseOptionView.reload(items);
}

function RunSetManyClassOption()
{
	var data = ManyCourseOptionView.getData();
	if (data.length == 0)
		return alert("至少要选一个班");
	if (data.length > 19)
		return alert("最多选20个班");
	ManyCourseWin.hide();
	var item = menuItem;
	item.img = "../pic/flow_end.png";
	$("#TitleSpan").html(item.item);
	var item1 = menubar.getItem("班次或学期课表");
	item1.img = "";

	if (item.item == "纵向多班总课表")
	{
	 	$("#LeftDiv").css({width:"0px"});
		$("#CourseTable").css({width:"1191px", height:"1000px", overflowX:"hidden", overflowY:"visible",padding:"20px 100px 20px 100px", 
			borderLeft:"1px solid black", borderBottom:"1px solid black", borderRight:"3px solid black"});
		$("#RightDiv").css({width:"100%"});
		var item1 = menubar.getItem("横向多班总课表");
		item1.img = "";
		var fun = LoadManyClassCourseViewV;
	}
	if (item.item == "横向多班总课表")
	{
	 	$("#LeftDiv").css({width:"0px"});
		$("#CourseTable").css({width:"1596px", height:"1000px", overflowX:"visible", overflowY:"visible",padding:"20px 100px 20px 100px", 
			borderLeft:"1px solid black", borderBottom:"1px solid black", borderRight:"3px solid black"});
		$("#RightDiv").css({width:"100%"});
		var item1 = menubar.getItem("纵向多班总课表");
		item1.img = "";		
		var fun = LoadManyClassCourseViewH;
	}
	view.waiting();
	ClassIDs = "" , sp = "";
	for (var x = 0; x < data.length; x++)
	{
		ClassIDs += sp + data[x].Class_id;
		sp = ",";
	}
	$.get(coursePath, {LoadManyClassCourse:1,ClassIDs:ClassIDs, ClassBeginTime:$("#ClassBeginTime").text(), ClassEndTime:$("#ClassEndTime").text()}, fun);
	
}

function LoadManyClassCourseViewH(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		alert(json);
	classObj = undefined;
	courseObj = json.Course;
//	var Classes = json.Classes;
	var Classes = ManyCourseOptionView.getData();
	for (var x = 0; x < courseObj.length; x++)
		APtoDate(courseObj[x]);
	var head = [{FieldName:"CourseTime", TitleName:"日期", nWidth:66, nShowMode:1},
	    		{FieldName:"Week", TitleName:"星<br>期", nWidth:20, nShowMode:1},
	    		{FieldName:"ap", TitleName:"午别", nWidth:46, nShowMode:1}];
	for (var x = 0; x < Classes.length; x++)
	{
		head[head.length] = {FieldName: "Course_" + Classes[x].Class_id, TitleName: "教学内容", nWidth:70, nShowMode:1};
		head[head.length] = {FieldName: "Teacher_" + Classes[x].Class_id, TitleName: "授课教师或负责部门", nWidth:70, nShowMode:1};
		head[head.length] = {FieldName: "Room_" + Classes[x].Class_id, TitleName: "地点", nWidth:50, nShowMode:1};
	}
	courseGrid = [];
	courseGrid[0] = {};
	var childs = view.getChildren();
	var cols = head.length;
	courseGrid[0].CourseTime = {value:$("#ManyCourseTitle").val(), colspan:cols,prop:"align=center ", style:"font:normal normal 400 14pt 黑体;",tdstyle:"border:none"};
	courseGrid[1] = {};
	courseGrid[1].CourseTime = {value:"<div style=float:right>培训时间未定</div>", colspan:cols, tdstyle:"border:none"};
	if (courseObj.length > 0)
		courseGrid[1].CourseTime.value = "<div style=float:right>培训时间:" + $.jcom.GetDateTimeString(courseObj[0].Syllabuses_date, 1) + "至" + 
			$.jcom.GetDateTimeString(courseObj[courseObj.length - 1].Syllabuses_date, 1) + "</div>";
	courseGrid[2] = {};
	courseGrid[3] = {};
	courseGrid[4] = {};
	courseGrid[5] = {};
	courseGrid[2].CourseTime = {value: "", colspan:3, rowspan:3};
	for (var x = 0; x < Classes.length; x++)
	{
		courseGrid[2]["Course_" + Classes[x].Class_id] = {value:Classes[x].Class_Name, colspan:3,prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};
		courseGrid[3]["Course_" + Classes[x].Class_id] = {value:"组织员",prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};	
		courseGrid[3]["Teacher_" + Classes[x].Class_id] = {value:"理论助教",prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};
		courseGrid[3]["Room_" + Classes[x].Class_id] = {value:"计划人数",prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};
		courseGrid[4]["Course_" + Classes[x].Class_id] = "";	
		courseGrid[4]["Teacher_" + Classes[x].Class_id] = "";
		courseGrid[4]["Room_" + Classes[x].Class_id] = "";
	}	

	for (var x = 0; x < head.length; x++)
	{
		courseGrid[5][head[x].FieldName] = {value:head[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};
	}
	
	var d1 = $.jcom.makeDateObj("1970-1-1");
	var index = 6;
	for (var x = 0; x < courseObj.length; x++)
	{
		var d2 = $.jcom.makeDateObj(courseObj[x].Syllabuses_date);
		if ((d2.getYear() != d1.getYear()) || (d2.getMonth() != d1.getMonth()) || (d2.getDate() != d1.getDate()))
		{
			var dd = d2.getFullYear() + "年<br>" + $.jcom.GetDateTimeString(d2, 13);
			index = courseGrid.length;
			var ap = getDateAP(courseObj[x].BeginTime);
			courseGrid[index] = InitManyClassCourseItem(head, ap);
			courseGrid[index].CourseTime = {value:dd, rowspan:1};
			courseGrid[index].Week = {value:weekdays.substr(d2.getDay(), 1), rowspan:1};
			courseGrid[index].ap = {value:ap, rowspan:1};
			d1 = d2;
		}
		
		SetManyClassCourseGridV(index, courseObj[x], head);
	}
	
	for (var x = 3; x < courseGrid.length; x++)
	{
		for (var key in courseGrid[x])
		{
			if ((courseGrid[x][key] === "上午") || (courseGrid[x][key] === "下午") || (courseGrid[x][key] === "晚上"))
				courseGrid[x][key] = "";
		}	
	}
	
	viewInfo.Records = courseGrid.length;
	view.reset(courseGrid, viewInfo, head);
}

function SetManyClassCourseGridV(begin, course, head)
{
	var field = "C_" + course.class_id;
	var ap = getDateAP(course.BeginTime);
	for (var x = begin; x < courseGrid.length; x ++)
	{
		if (courseGrid[x]["Course_" + course.class_id] == ap)
		{
			courseGrid[x]["Course_" + course.class_id] = getCourseName(course);
			courseGrid[x]["Teacher_" + course.class_id] = course.Syllabuses_teacher_name + "<br>" + course.AssistMan;
			courseGrid[x]["Room_" + course.class_id] = course.Syllabuses_ClassRoom;
			return;
		}
	}
	courseGrid[x] = InitManyClassCourseItem(head, ap);
	courseGrid[begin].CourseTime.rowspan ++;
	courseGrid[begin].Week.rowspan ++;
	if (ap == courseGrid[begin].ap.value)
		courseGrid[begin].ap.rowspan += 1;
	else
		courseGrid[x].ap = {value: ap, rowspan:1};

	courseGrid[x]["Course_" + course.class_id] = getCourseName(course);
	courseGrid[x]["Teacher_" + course.class_id] = course.Syllabuses_teacher_name + "<br>" + course.AssistMan;
	courseGrid[x]["Room_" + course.class_id] = course.Syllabuses_ClassRoom;
}


function LoadManyClassCourseViewV(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		alert(json);
	classObj = undefined;
	courseObj = json.Course;
//	var Classes = json.Classes;
	var Classes = ManyCourseOptionView.getData();
	for (var x = 0; x < courseObj.length; x++)
		APtoDate(courseObj[x]);
	var head = [{FieldName:"CourseTime", TitleName:"日期", nWidth:66, nShowMode:1},
	    		{FieldName:"Week", TitleName:"星<br>期", nWidth:20, nShowMode:6},
	    		{FieldName:"ap", TitleName:"午别", nWidth:46, nShowMode:1},
	    		{FieldName:"RowHead", TitleName:"栏目", nWidth:64, nShowMode:1}];
	for (var x = 0; x < Classes.length; x++)
	{
		head[head.length] = {FieldName: "C_" + Classes[x].Class_id, TitleName: Classes[x].Class_Name, nWidth:100, nShowMode:1};
	}
	
	courseGrid = [];
	courseGrid[0] = {};
	var childs = view.getChildren();
	var cols = head.length - 1;
	courseGrid[0].CourseTime = {value:$("#ManyCourseTitle").val(), colspan:cols, prop:"align=center ", style:"font:normal normal 400 14pt 黑体;",tdstyle:"border:none"};
	courseGrid[1] = {};
	courseGrid[1].CourseTime = {value:"<div style=float:right>培训时间未定</div>", colspan:cols, tdstyle:"border:none"};
	if (courseObj.length > 0)
		courseGrid[1].CourseTime.value = "<div style=float:right>培训时间:" + $.jcom.GetDateTimeString(courseObj[0].Syllabuses_date, 1) + "至" + 
			$.jcom.GetDateTimeString(courseObj[courseObj.length - 1].Syllabuses_date, 1) + "</div>";
	courseGrid[2] = {};
	for (var x = 0; x < head.length; x++)
	{
		courseGrid[2][head[x].FieldName] = {value:head[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt 宋体;"};
	}
	
	var d1 = $.jcom.makeDateObj("1970-1-1");
	var index = 2;
	for (var x = 0; x < courseObj.length; x++)
	{
		var d2 = $.jcom.makeDateObj(courseObj[x].Syllabuses_date);
		if ((d2.getYear() != d1.getYear()) || (d2.getMonth() != d1.getMonth()) || (d2.getDate() != d1.getDate()))
		{
			var dd = d2.getFullYear() + "年<br>" + $.jcom.GetDateTimeString(d2, 13) + "<br>(星期" + weekdays.substr(d2.getDay(), 1) + ")";
			index = courseGrid.length;
			var ap = getDateAP(courseObj[x].BeginTime);
			courseGrid[index] = InitManyClassCourseItem(head, ap);
			courseGrid[index].CourseTime = {value:dd, rowspan:3};
			courseGrid[index].ap = {value:ap, rowspan:3};
			courseGrid[index + 1] = InitManyClassCourseItem(head, "");
			courseGrid[index + 2] = InitManyClassCourseItem(head, "");
			SetRowHead(index);			
			d1 = d2;
		}
		
		SetManyClassCourseGridH(index, courseObj[x], head);
	}
	for (var x = 3; x < courseGrid.length; x+=3)
	{
		for (var y = 0; y < Classes.length; y++)
		{
			var item = courseGrid[x]["C_" + Classes[y].Class_id];
			if ((item === "上午") || (item === "下午") || (item === "晚上"))
				courseGrid[x]["C_" + Classes[y].Class_id] = "";
		}	
	}
	viewInfo.Records = courseGrid.length;
	view.reset(courseGrid, viewInfo, head);
}

function SetManyClassCourseGridH(begin, course, head)
{
	var field = "C_" + course.class_id;
	var ap = getDateAP(course.BeginTime);
	for (var x = begin; x < courseGrid.length; x += 3)
	{
		if (courseGrid[x][field] == ap)
		{
			TransClassCourseField(x, field, course);
			return;
		}
	}
	courseGrid[x] = InitManyClassCourseItem(head, ap);
	courseGrid[x + 1] = InitManyClassCourseItem(head, "");
	courseGrid[x + 2] = InitManyClassCourseItem(head, "");
	courseGrid[begin].CourseTime.rowspan += 3;
	if (ap == courseGrid[begin].ap.value)
		courseGrid[begin].ap.rowspan += 3;
	else
		courseGrid[x].ap = {value: ap, rowspan:3};

	TransClassCourseField(x, field, course);
	SetRowHead(x);
}

function SetRowHead(index)
{
	courseGrid[index].RowHead = {value:"教学内容", color:"black"};
	courseGrid[index + 1].RowHead = {value:"授课教师或负责部门", color:"blue"};
	courseGrid[index + 2].RowHead = {value:"地点", color:"green"};
}

function TransClassCourseField(x, field, course)
{
	courseGrid[x][field] = {value:getCourseName(course), color:"black"};
	courseGrid[x + 1][field] = {value:course.Syllabuses_teacher_name + "<br>" + course.AssistMan, color:"blue"}
	courseGrid[x + 2][field] = {value:course.Syllabuses_ClassRoom, color:"green"};
}

function InitManyClassCourseItem(head, value)
{
	var item = {};
	for (var x = 3; x < head.length; x++)
	{
		item[head[x].FieldName] = value;
	}
	return item;
}

function SetCourseLen()
{
	var dest = getViewSelRows();
	if (dest.length == 0)
		return alert("请在课程表中选择课程");
	var index = courseGrid[dest[0].rowIndex].index;
	if (index < 0)
		return alert("请在课程表中选择课程");
	var tag = "<select id=CurrentCourseLenSel><option value=0.5>半天</option><option value=1>一天</option><option value=1.5>一天半</option><option value=2>两天</option><option value=2.5>两天半</option><option value=3>三天</option></select>";
	$.jcom.OptionWin("当前课程时长:" + tag ,"设置课程时长", [{item:"确定", action:SetCourseLenRun}]);
	var len = GetCourseLen(courseObj[index]) / 2;
	$("#CurrentCourseLenSel").val(len);
	
//	if (courseObj[index].Syllabuses_id == 0)
//		return alert("请先保存当前课程后再设置时长");	
}

function GetCourseLen(item)
{
	var cnt = 0;
	for (var x = 0; x < courseObj.length; x++)
	{
		if (courseObj[x].EditFlag == 3)
			continue;
		if (((item.Syllabuses_subject_id > 0) && (courseObj[x].Syllabuses_subject_id == item.Syllabuses_subject_id))
			|| ((item.Syllabuses_activity_id > 0) && (courseObj[x].Syllabuses_activity_id == item.Syllabuses_activity_id)))
			cnt ++;
	}
	return cnt;
}

function SetCourseLenRun(obj, win)
{
	var dest = getViewSelRows();
	var index = courseGrid[dest[0].rowIndex].index;
	var oldlen = GetCourseLen(courseObj[index]) / 2;
	var newlen = $("#CurrentCourseLenSel").val();
	win.close();
	if (newlen == oldlen)
		return;
	view.DisEditor();
	var item = courseObj[index];
	if (newlen > oldlen)
	{
		var o = {CourseID: item.Syllabuses_course_id, CourseName:item.Syllabuses_course_name, ActID:item.Syllabuses_activity_id, ActName:item.Syllabuses_activity_name, 
				SubjID:item.Syllabuses_subject_id, SubjName:item.Syllabuses_subject_name, TeacherID:item.Syllabuses_teacher_id, TeacherName:item.Syllabuses_teacher_name,
				room:item.Syllabuses_ClassRoom, roomid:item.Syllabuses_ClassRoom_id, bak:item.Syllabuses_bak, assist:item.AssistMan, ainfo:item.AssistInfo, t:newlen - oldlen};
		index = skipCourseGrid(index);
		if (index >= courseGrid.length)
			return alert("增加时长失败，课已排满。");
		ApplyItem(index, o);
	}
	else
	{
		var cnt = (oldlen - newlen) * 2;
		for (var x = courseGrid.length - 1; x >= nTitleRows; x--)
		{
			var y = courseGrid[x].index; 
			if (y < 0)
				continue;
			if (((item.Syllabuses_subject_id > 0) && (courseObj[y].Syllabuses_subject_id == item.Syllabuses_subject_id))
				|| ((item.Syllabuses_activity_id > 0) && (courseObj[y].Syllabuses_activity_id == item.Syllabuses_activity_id)))
			{
				cnt --;
				DeleteCourseItem(true, x);
				if (cnt <= 0)
					break;
			}
		}
	}
	SetMode(3);
}

function FindSubject()
{
}

var checkTeacherWin, checkTeacherView;
function CheckTeacherResult(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return checkTeacherView.waiting(json);
	
	for (var x = 0; x < json.length; x++)
	{
		var y = json[x].id;
		if (y == undefined)
			continue;
		if (typeof y == "object")
			json[x].Teacher = {value: courseObj[y.value].Syllabuses_teacher_name, rowspan: y.rowspan};
		else
			json[x].Teacher = courseObj[y].Syllabuses_teacher_name;
	}
	checkTeacherView.reload(json);
}

function CheckTeachers()
{
	var tag = "", cnt = 0;
	for (var x = nTitleRows; x < courseGrid.length; x++)
	{
		var y = courseGrid[x].index;
		if (y >= 0)
		{
			if (((courseObj[y].Syllabuses_teacher_id == "0") || (courseObj[y].Syllabuses_teacher_id == "")) && (courseObj[y].Syllabuses_teacher_name != ""))
			{
				tag += "&id=" + y + "&Teacher=" + courseObj[y].Syllabuses_teacher_name;
				cnt ++;
			}
		}
	}
	if (checkTeacherWin == undefined)
	{
		checkTeacherWin = new $.jcom.PopupWin("<div id=CheckTeacherDiv style=width:100%;height:100%></div>", 
				{title:"校正授课人并与师资库匹配", width:640, height:480});
		var aFace = {x:0,y:30,node:1,a:{id:"CheckTeacherTop"},b:{id:"CheckTeacherBottom"}};
		var oLayer = new $.jcom.Layer($("#CheckTeacherDiv")[0], aFace, {border:"1px dotted gray"});
		var menu = new $.jcom.CommonMenubar([{item:"应用", action:ApplyCheckTeacher}, {item:"编辑", action:EditCheckTeachView}, {item:"保存", action:SaveCheckTeach}], $("#CheckTeacherTop")[0]);

		var head = [{FieldName:"Teacher", TitleName:"原授课人", nWidth:120, nShowMode:1},
		    		{FieldName:"spTeacher", TitleName:"分解后的授课人", nWidth:120, nShowMode:1},
		    		{FieldName:"dbTeacherID", TitleName:"师资库编号", nWidth:80, nShowMode:1},
		    		{FieldName:"dbTeacher", TitleName:"姓名", nWidth:60, nShowMode:1},
		    		{FieldName:"dbnType", TitleName:"类型", nWidth:60, nShowMode:1},
		    		{FieldName:"dbUnit", TitleName:"单位", nWidth:160, nShowMode:1}];
		checkTeacherView = new $.jcom.GridView($("#CheckTeacherBottom")[0], head, [], {bodystyle:2, footstyle:4});
		checkTeacherWin.close = checkTeacherWin.hide;
	}
	else
		checkTeacherWin.show();
	checkTeacherView.waiting("正在校正与匹配授课人...");
	$.jcom.Ajax(coursePath + "?CheckTeacher=1&num=" + cnt, true, tag, CheckTeacherResult);
}

function ApplyCheckTeacher()
{
	var items = checkTeacherView.getData();
	var cnt = 0;
	for (var x = 0; x < items.length; x++)
	{
		var y = items[x].id;
		if (typeof y == "object")
		{
			var ids = "", teachers = "", sp = "";
			for (var z = 0; z < y.rowspan; z++)
			{
				if ((items[x + z].dbTeacherID.indexOf(",") >= 0) || (items[x + z].dbTeacherID == ""))
					break;
				ids += sp + items[x + z].dbTeacherID;
				teachers += sp + items[x + z].dbTeacher;
				sp = ",";
			}
			if (z == y.rowspan)
			{
				courseObj[y.value].Syllabuses_teacher_id = ids;
				courseObj[y.value].Syllabuses_teacher_name = teachers;
				courseObj[y.value].EditFlag = 2;
				cnt ++;
			}
			x += y.rowspan - 1;
		}
		else
		{
			var id = items[x].dbTeacherID;
			if (id == "")
				continue;
			var ss = id.split(",");
			if (ss.length > 1)
				continue;
			courseObj[y].Syllabuses_teacher_id = id;
			courseObj[y].Syllabuses_teacher_name = items[x].spTeacher;
			courseObj[y].EditFlag = 2;
			cnt ++;
		}
	}
	if (cnt > 0)
	{
		RefreshCourse();
		SetMode(3);
	}
}

function EditCheckTeachView()
{
}

function SaveCheckTeach()
{
}

function SetnDayUse(obj, item)
{
	if (item.img == "")
	{
		nDayUse = 3;
		item.img = "../pic/flow_end.png";
	}
	else
	{
		nDayUse = 2;
		item.img = "";
	}
	RefreshCourse();
}

function SetCourseState()
{
	if (classObj == undefined)
		return alert("没有设置权限");
	var setStatewin = new $.jcom.PopupWin("<div id=SetStateForm style=width:100%;height:100%></div>", 
			{title:"课程表状态及权限", mask:50, width:640, height:160, resize:0});
		var form = new $.jcom.FormView($("#SetStateForm")[0],
			[{CName:"课表状态", EName: "CourseState", InputType:3, Quote:"(0:未定义, 1:编辑中,10:已发布)"},
			 {CName:"允许编辑的人员", EName: "EditMembers", Relation:"!SelectCourseUser(this)"},
			 {CName:"允许审阅的人员", EName: "ViewMembers", Relation:"!SelectCourseUser(this)"}
			], {}, {action:location.pathname + "?SaveCourseStateFlag=1&ClassID=" + classObj.Class_id});
		form.submit = RunSetCourseState;
		form.setRecord(StateRight);
}

function RunSetCourseState()
{
}

function SelectCourseUser(oImg)
{
	var data = showModalDialog("../selmember.jsp?type=app", "", "dialogWidth:600px;dialogHeight:510px;caption:0;border:0;scroll:0;help:0;status:0");
	if (typeof(data) != "string")
		return;
	oImg.previousSibling.value = data;
}

function ToggleAutoSave(obj, item)
{
	if (AutoSaveCourse == 0)
	{
		item.img = "../pic/flow_end.png";
		AutoSaveCourse = 1;
	}
	else
	{
		item.img = "";
		AutoSaveCourse = 0;
	}
}
