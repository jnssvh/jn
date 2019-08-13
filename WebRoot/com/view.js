var layer, menubar, grid, tree;

function InitView(head, mode)
{
	if (mode == undefined)
		mode = ViewMode;
	switch (mode)
	{
	case 1:			//列表视图
		var aFace = {x:0,y:30,node:1,a:{id:"SeekMenubar"},b:{id:"TableDoc"}};
		layer = new $.jcom.Layer($("#MainView")[0], aFace, {});
		menubar.setDOMObj($("#SeekMenubar")[0]);
		InitSeek();
		grid = new $.jcom.GridView($("#TableDoc")[0], head, [], {}, {});
		ReloadGrid();
		break;
	case 2:			//树型视图
		var aFace = {x:0,y:30,node:1,a:{id:"SeekMenubar"},b:{id:"TableDoc"}};
		layer = new $.jcom.Layer($("#MainView")[0], aFace, {});
		menubar.setDOMObj($("#SeekMenubar")[0]);
		InitSeek();
		tree = new $.jcom.TreeView($("#TableDoc")[0], [], {parentNode:treeParentNode}, head);
		if (typeof UserClick == "function")
			tree.click = UserClick;
		if (typeof UserDblClick == "function")
			tree.dblclick = UserDblClick;
		ReloadTree();
		break;
	case 5:			//组合视图
		var aFace = {x:0,y:30,node:1,a:{id:"SeekMenubar"},b:{id:"TableDoc",child:{x:177,y:-1,node:2,a:{id:"LeftView"},b:{id:"RightView"}}}};
		layer = new $.jcom.Layer($("#MainView")[0], aFace, {});
		menubar.setDOMObj($("#SeekMenubar")[0]);
		InitSeek();
		tree = new $.jcom.TreeView($("#LeftView")[0], [], {parentNode:treeParentNode}, head);
		if (typeof UserClick == "function")
			tree.click = UserClick;
		if (typeof UserDblClick == "function")
			tree.dblclick = UserDblClick;
		ReloadTree();
		break;
	case 9:			//树表视图
//类似代码未写
		ReloadTreeGrid();
		break;
	case 10:		//自定义视图
//类似代码由用户自己写
		break;
	case 13:		//三列查询视图
	case 14:		//四列查询视图
	case 15:		//五列查询视图
		MakeSearchPane(head, ViewMode - 10);
		grid = new $.jcom.GridView($("#TableDoc")[0], head, [], {}, {});
		ReloadGrid();
		break;
	}

}

function ReloadGrid(data)
{
	if (typeof data == "undefined")
	{
		grid.pageskip = GridPageSkip;
		grid.orderField = GridOrderField;
		grid.waiting();
		$.get(href,{OrderField: OrderField, bDesc: bDesc, SeekKey: SeekKey, SeekParam: SeekParam, GetGridData: 1}, ReloadGrid);
		return;
	}
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return grid.waiting(json);
	grid.reload(json.Data, json.info);
}

function GridPageSkip(nPage)
{
	grid.waiting();
	$.get(href,{OrderField: OrderField, bDesc: bDesc, SeekKey: SeekKey, SeekParam: SeekParam, Page: nPage, GetGridData: 1}, ReloadGrid);
}

function GridOrderField(Field, desc)
{
	grid.waiting();
	OrderField = Field;
	bDesc = desc
	$.get(href,{OrderField: OrderField, bDesc: bDesc, SeekKey: SeekKey, SeekParam: SeekParam, GetGridData: 1}, ReloadGrid);
}

function ReloadTree(data)
{
	if (typeof data == "undefined")
	{
		tree.waiting();
		var url = AppendURLParam(href, "OrderField=" + OrderField + "&bDesc=" + bDesc + "&SeekKey=" + SeekKey + "&SeekParam=" + SeekParam);
		return AjaxRequestPage(url + "&GetTreeData=1", true, "", ReloadTree);
	}
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return tree.waiting(json);
	tree.setdata(json);

}

function ReloadTreeGrid(data)
{
	if (typeof data == "undefined")
	{
		grid.waiting();
		var url = AppendURLParam(href, "OrderField=" + OrderField + "&bDesc=" + bDesc + "&SeekKey=" + SeekKey + "&SeekParam=" + SeekParam);
		return AjaxRequestPage(url + "&GetTreeData=1", true, "", ReloadTreeGrid);
	}
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return grid.waiting(json);
	grid.reload(json);
}



function NewRecord()
{
	window.open(FormAction);
}

function EditRecord()
{
	
	var tr = grid.getSelRow();
	if (tr == undefined)
		return alert("请选择一条记录先。");
	var data = grid.getData();
	var key = "ID";
	for (var x = 0; x < head.length; x++)
	{
		if (head[x].bPrimaryKey == 1)
			key = head[x].FieldName;
	}
	window.open(FormAction + "?DataID=" + data[tr.node][key]);
}

function CreateGrid(domobj, url)
{

}

function MakeSearchPane(head, cols)
{
	var tag = "<tr>", y = 1;
	for (var x = 0; x < head.length; x++)
	{
		if (head[x].bSeek == 1)
		{
			tag += "<td nowrap>" + head[x].TitleName + "</td><td><input name=" + head[x].EName + "></td>";
			if ((y ++ % cols) == 0)
				tag += "</tr><tr>";
		}
	}
	if (y == 1)
		return;
	tag += "</tr>";
	document.all.TableDoc.insertAdjacentHTML("beforeBegin", "<table id=ToolbarTable>" + tag + "</table>");
	var oTD = document.all.ToolbarTable.rows[0].insertCell();
	oTD.rowSpan = parseInt(y /cols);
	oTD.vAlign = "bottom";
	oTD.innerHTML = "&nbsp;<select><option value=1>并且</option><option value=2>或者</option></select>&nbsp;<input type=button value=查询>";
}

function ResizeView()
{
	$("#TableDoc").height($(document.body).prop("clientHeight") - $("#TableDoc").prop("offsetTop"));
	if (typeof split == "object")
		split.refresh();
}

function InitSeek()
{
	var fun = function(data)
	{
		if (data != "")
		{
			window.oSearch.setData(data);
			window.oSearch.popDown();
		}
	};
	window.oSearch = new $.jcom.DynaEditor.Search(function (value)
	{
		if (value != "")
			AjaxRequestPage(AppendURLParam(href, "SeekKey=$AjaxGetKeyword$&SeekParam=" + value), true, "", fun);
		return "";
	}, TableWholeDocSeek);
	
	if (typeof document.all.SearchInput == "object")
	{
		if ((SeekKey == "$ClipSearch$") || (SeekKey == "$WholeDoc$"))
		{
			document.all.SearchInput.value = unescape(SeekParam);
		}
		window.oSearch.insert(document.all.SearchInput, 200, 20, document.all.SearchInput.value);
		document.all.SearchInput.style.display = "none";
		window.oSearchOption = new $.jcom.CommonMenu([{item:"清除搜索结果",action:"TableWholeDocSeek('')"},
		{item:"启用跟踪剪贴板搜索",action:ClipSearch},{item:"高级搜索",action:TableMenuComplexSeek}]);
		document.all.SearchInput.previousSibling.style.cursor = "hand";
		document.all.SearchInput.previousSibling.onclick = function ()
		{
			window.oSearchOption.show();
		};
		
		if (SeekKey == "$ClipSearch$")
		{
			ClipSearch.value = document.all.SearchInput.value;
			ClipSearch();
		}				
	}	
}

function ClipSearch()
{
	var menu = window.oSearchOption.getmenu();
	if (typeof ClipSearch.timer  != "undefined")
	{
		window.clearInterval(ClipSearch.timer);
		ClipSearch.timer = undefined;
		window.oSearch.oEdit.lastChild.src="../pic/search.png";
		menu[1].img = "";
		return;
	}
	window.oSearch.oEdit.lastChild.src="../pic/360.png";
	menu[1].img = "../pic/flow_end.png";
	ClipSearch.timer = window.setInterval(function()
	{
		var text = window.clipboardData.getData("Text");
		if (text == null)
			return;
		var value = text.replace(/[ 　]+/g, "");
		if ((text.length > 0) && (text.length < 100) && (value != ClipSearch.value))
		{
			ClipSearch.value = value;
			window.oSearch.setValue(value);
			ClipSearch();
			TableWholeDocSeek(value, "$ClipSearch$");
		}
	},500);
}


function TableWholeDocSeek(param, seekkey)
{
	if (typeof(param) == "undefined")
	{

		InlineHTMLDlg("查询", "<br>&nbsp;请输入全文检索关键字：<br><br><center><input id=InlineInputObj type=text>" + 
			"<BR><BR><input type=button id=TableWholeDocSeekButton value=确定>&nbsp;&nbsp;" +
			"<input type=button onclick=CloseInlineDlg() value=取消>&nbsp;&nbsp;" +
			"<input type=button onclick=CloseInlineDlg();TableMenuComplexSeek() value=更多></center>", 300, 200);
		window.oSearch.insert(document.all.InlineInputObj, "afterEnd");
		window.oSearch.oEdit.lastChild.style.display = "none";
		window.oSearch.oEdit.style.width = "200px";
		document.all.InlineInputObj.removeNode();
		document.all.TableWholeDocSeekButton.onclick = function ()
		{
			window.oSearch.oEdit.lastChild.click();
		}
		return;
	}
	if (param == "")
		return TableKeySeek("", "");
	if (typeof seekkey != "string")
		seekkey = "$WholeDoc$";
	if (typeof(param) == "string")
	{
		if (typeof SeekParamEx == "string" && SeekParamEx != "")
			param = param + "||" + SeekParamEx.replace(/\?/g, param);
		location.href = AppendURLParam(href, "ViewMode=" + ViewMode + "&SeekKey=" + seekkey + "&SeekParam=" + param);
	}
}

function TableMenuComplexSeek(param)
{
	if (typeof(param) == "string")
			location.href = AppendURLParam(href, "ViewMode=" + ViewMode + param);
	else
	{
		var Action = AppendURLParam(href, "ComplexSeek=1");
		NewFrameWin(Action, "Width=480px,Height=315px,scroll=0;");
		return;
//		var aFace = 
		var win = new $.jcom.PopupWin("<div id=SeekDiv style=width:100%;height:100%></div>",
			{title:"复合查询选择",width:480,height:315,mask:30});
	}

}

var excelform, exceltmplid;
function InitExcelForm(domobj, ExcelFormID, fields, record)
{
	var form = new $.jcom.FormView($("#FormDiv")[0], fields, record, {title:"学籍登记表", nCols:2, ex:"", spaninput:1, gridformid:ExcelFormID});
	return;

	var fun  = function (data)
	{
		excelform = new ExcelForm(domobj,data, fields, record);
		if (typeof AfterLoadExcelForm == "function")
			AfterLoadExcelForm(record);
	}
	exceltmplid = ExcelFormID;
	$.get("../com/inform.jsp", {DataID:ExcelFormID, Ajax:1}, fun);
}

function ExcelForm(domobj, exceldata, fields, record, cfg)
{

var self = this;
self.menubar = undefined;
self.view = undefined;
var oLayer, App;
	
	function SelectCell(td, event)
	{
		var o = $(td).find("span");
		if (o.prop("contentEditable"))
		{
			o[0].focus();
		}
	}

	this.Import = function()
	{
		if (typeof $("#ImportExcelFrame")[0] == "object")
			$("#ImportExcelFrame").remove();
		document.body.insertAdjacentHTML("afterBegin", "<iframe id=ImportExcelFrame style=display:none></iframe>");
		var doc = $("#ImportExcelFrame")[0].contentWindow.document;
		doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
	    "</head><body><form id=ImportForm method=post action=../com/inform.jsp?ImportExcelFlag=1&Ajax=1" +
    	" enctype=multipart/form-data><input type=file name=LocalName></form></body></html>");
		doc.charset = "gbk";
		doc.getElementById("LocalName").onchange = self.StartImportExcelFile;
		doc.getElementById("LocalName").click();
		$("#ImportExcelFrame")[0].onreadystatechange = ImportOK;
	};

	function ImportOK()
	{
		var doc = $("#ImportExcelFrame")[0].contentWindow.document;
		if (doc.readyState != "complete")
			return;
		var json = $.jcom.eval(doc.body.innerHTML);
		if (typeof json == "string")
		{
			return alert(json);
		}
		var data = self.view.getData();
		var cnt = 0;
		for (var key in record)
		{
			if ($("#" + key).length > 0)
			{
				var td = $.jcom.findParentObj($("#" + key)[0], domobj, "TD");
				if (typeof td == "object")
				{
					var index = td.parentNode.node;
					var fieldName = td.id.substr(0, td.id.length - 3);
					if (index < json.data.length)
					{
						var val = json.data[index][fieldName];
						if (val != undefined)
						{
							if (typeof val == "object")
								val = val.value;
							$("#" + key).text("???");
							var begin = td.innerText.indexOf("???");
							var end = td.innerText.length - begin - 3;
							record[key] = self.TranslateValue(key, val.substring(begin, val.length - end));
							cnt ++;
						}
					}
				}
			}
		}
		self.onImport(json, record, fields,cnt);
	}
	
	this.TranslateValue = function(EName, value)
	{
		if (value == "")
			return value;
		var x = self.getFieldsIndex(EName);
		if (x == -1)
			return value;
		if (fields[x].editor == undefined)
			return value;
		switch (fields[x].editor.type)
		{
		case 2:		//List
				var data = fields[x].editor.getData();
				var ss = data.split(",");
				for (var y = 0; y < ss.length; y++)
				{
					var sss = ss[y].split(":");
					if ((value == sss[0]) || (value == sss[1]) || (value == ss[y]))
						return {value: sss[0], ex: sss[1]};
				}
				break;
		case 1:		//Date
			if (self.CheckValue(x, value) == "")
				break;
			var ss = value.split("-");
			switch (ss.length)
			{
			case 1:
				ss = value.split(".");
				if (ss.length == 1)
				{
					if (isNaN(parseInt(value)))
						return "1900-1-1";
					return parseInt(value) + "-1-1";
				}
			case 2:
				return ss[0] + "-" + ss[1] + "-1";
			case 3:
				return ss[0] + "-" + ss[1] + "-" + ss[2];
			}
		}
		return value;
	};
	
	this.getFieldsIndex = function(value, propName)
	{
		if (propName == undefined)
			propName = "EName";
		for (var x = 0; x < fields.length; x++)
		{
			if (fields[x][propName] == value)
				return x;
		}
		return -1;
	};
	
	this.onImport = function(json, record, fields, cnt)
	{
		self.reload();
		self.clearRed();
		alert("导入数据" + cnt +  "项");
		self.CheckForm();
	};
	
	this.StartImportExcelFile = function()
	{
		var doc = $("#ImportExcelFrame")[0].contentWindow.document;
		var file = doc.getElementById("LocalName").value;
		if (file != "")
		{
			if (file.substr(file.length - 3).toLowerCase() == "xls")
				doc.getElementById("ImportForm").submit();
			else
				self.ImportWord(file);
		}
	}

	this.ImportWord = function(filename)
	{
		if (typeof App != "object")
		{
			try
			{
				App = new ActiveXObject("Word.Application");
				window.onbeforeunload = function()
				{
					App.Quit();
				}

			} catch (e)
			{
				alert("未能打开本地的OFFICE程序。" + e.description);
				return false;
			}
		}
		var doc = App.Documents.Open(filename);
		doc.ActiveWindow.Activate();
		var rows = doc.Tables(1).Rows.Count;
		var cols = doc.Tables(1).Columns.Count;
		var cnt = 0;
		for (var y = 0; y < rows; y++)
		{
			for (var x = 0; x < cols; x++)
			{
				try
				{
					var cell = doc.Tables(1).Cell(y + 1, x + 1);
				}
				catch (e)
				{
					window.status = (y + "-" + x + e.description);
					continue;
				}
				
				var text = cell.Range.Text.replace(/[\s\7]+/g, "");
				var index = self.getFieldsIndex(text, "CName");
				if (index > 0)
				{
					text = doc.Tables(1).Cell(y + 1, x + 2).Range.Text;
					if (fields[index].FieldLen <= 100)
						text = text.replace(/[\s\7]+/g, "");
					record[fields[index].EName] = self.TranslateValue(fields[index].EName, text);
					x++;
					cnt ++;
				}
			}
		}
		if (cnt > 0)
		{
			var fso = new ActiveXObject("Scripting.FileSystemObject");
			var tfolder = fso.GetSpecialFolder(2);
			doc.SaveAs(tfolder + "\\Student.htm", 8); //wdFormatFilteredHTML
			doc.Close();
			var file = tfolder + "\\Student.files\\image001.jpg";
			if (!fso.FileExists(file))
				var file = tfolder + "\\Student.files\\image001.png";
			if (fso.FileExists(file))
				record.Photo = {value:file, ex:"<img height=100% width=100% src=" + file + ">"};
			else
				record.Photo = "";
		}
		alert("共导入" + cnt + "条");
		self.reload(record);
	};

	this.Output = function()
	{
		self.view.OutExcel("Excel.xls");
		
	};
	
	this.clearRed = function ()
	{
		for ( var x = 0; x < fields.length; x++)
			$(domobj).find("#" + fields[x].EName).parent().css("border", "");
	}
	
	this.CheckValue = function (fieldIndex, value)
	{
		if (typeof value == "object")
			value = value.value;
		if (fields[fieldIndex].nRequired == 1)
		{
			if (value == "")
				return fields[fieldIndex].CName + "字段应为必填项\n";
		}
	
		switch (fields[fieldIndex].FieldType)
		{
		case 1:			//文本
			if (value.length > fields[fieldIndex].FieldLen)
				return fields[fieldIndex].CName + "字段长度超长，允许最大长度为" + fields[fieldIndex].FieldLen + ",实际长度为:" + value.length + "\n";
			break;
		case 2:			//备注
			break;
		case 5:			//自动编号
		case 3:			//数字
		case 6:			//单精度浮点
		case 7:			//双精度浮点
			if (isNaN(Number(value)))
			{
				$(domobj).find("#" + fields[fieldIndex].EName).parent().css("border", "1px solid red");
				return fields[fieldIndex].CName + "字段应为数值型\n";
			}
			break;
		case 4:			//日期
			if (value == "")
				break;
			var ss = value.split(" ")
			var sss = ss[0].split("-")
			if (isNaN(Number(sss[0])) || isNaN(sss[1]) || isNaN(sss[2]))
				return fields[fieldIndex].CName + "字段日期格式错误\n";
			var dd = new Date(Number(sss[0]), Number(sss[1]) - 1, Number(sss[2]));
			if ((dd.getFullYear() != Number(sss[0])) || (dd.getMonth() != Number(sss[1]) - 1) || (dd.getDate() != Number(sss[2])))
				return fields[fieldIndex].CName + "字段日期格式错误\n";
			if (ss.length < 2)
				break;
			sss = ss[1].split(":");
			for (var xx = 0; xx < sss.length; xx++)
			{
				if (sss.length > 3 || isNaN(Number(sss[xx])) || (Number(sss[xx]) > 59) || (Number(sss[xx]) < 0) || (Number(sss[0]) >= 24))
					return fields[fieldIndex].CName + "字段日期格式错误\n";
			}
			break;
		case 8:			//二进制
			break;
		case 9:			//是/否
			break;
		case 10:		//货币
			break;			
		}
		return "";
	}

	this.CheckForm = function ()
	{
		var errcnt = 0, hint = "";
		
		self.getRecord();
		self.clearRed();
		for ( var x = 0; x < fields.length; x++)
		{
			var result = self.CheckValue(x, record[fields[x].EName]);
			if (result != "")
			{
				$(domobj).find("#" + fields[x].EName).parent().css("border", "1px solid red");
				hint += result;
				errcnt ++;
			}
		}
		if (errcnt > 0)
			alert("不能提交表单，原因是存在如下不合格的输入项：\n" + hint);
		return errcnt;
	}
	
	this.SaveForm = function()
	{
		if (self.CheckForm() > 0)
			return false;
		var text = "";
		result = self.submit();
		if (result == false)
			return false;
		for (var key in record)
		{
			var value = record[key];
			if (typeof value == "object")
				value = record[key].value;
			text += "<input name=" + key + " value=\"" + value + "\">";
		}
		if (typeof $("#OutExcelFrame")[0] == "object")
			$("#OutExcelFrame").remove();
		document.body.insertAdjacentHTML("beforeEnd", "<iframe id=OutExcelFrame style=display:none></iframe>");
		var doc = $("#OutExcelFrame")[0].contentWindow.document;
		doc.write("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=GBK\">" +
			"</head><body><form id=OutExcelForm method=post action=" + cfg.action + ">" + text + "</form></body></html>");
		doc.charset = "gbk";
		doc.getElementById("OutExcelForm").submit();
	}
	
	this.submit = function ()
	{
		return true;
	}
	
	this.reload = function (r)
	{
		if (typeof r == "object")
			record = r;
		for (var key in record)
		{
			var value = record[key];
			if (typeof value == "object")
				value = record[key].ex;
			$("#" + key).html(value);
		}
	};

	this.getRecord = function ()
	{
		for (var key in record)
		{
			if ($("#" + key).length > 0)
			{
				if ($("#" + key)[0].contentEditable == "true")
					record[key] = self.TranslateValue(key, $("#" + key).text());
			}
		}
		return record;
	};
	
	this.getFields = function ()
	{
		return fields;
	};
	
	function LoadEnum(x)
	{
		var fun = function (data)
		{
			LoadenumOK(x, data)
		}
		$.get("../com/seleenum.jsp", {EnumType: fields[x].Quote.substr(1), AjaxMode:1}, fun);
	}
	
	function LoadenumOK(x, data)
	{
		fields[x].editor = new $.jcom.DynaEditor.List(data,300, 400, 1);
		fields[x].editor.attach($(domobj).find("#" + fields[x].EName)[0]);
	}
	
	function init()
	{
		for (var x = 0; x < fields.length; x++)
		{
			var prop = "";
			if (fields[x].nReadOnly == 0)
				prop = " CONTENTEDITABLE";
			exceldata = exceldata.replace("(" + fields[x].EName + ")", "<span id=" + fields[x].EName + prop + " style=height:100%;></span>");		
		}
		json = $.jcom.eval(exceldata);
		if (typeof json == "string")
			return alert(json);
		var aFace = {x:0,y:30,node:1,a:{id:"SeekMenubar"},b:{id:"GridDiv"}};
		oLayer = new $.jcom.Layer(domobj, aFace, {});

		self.menubar = new $.jcom.CommonMenubar([{item:"导入",action:self.Import},{item:"导出",action:self.Output},{item:"保存", action:self.SaveForm}], $("#SeekMenubar")[0], "");
		self.view = new $.jcom.GridView($("#GridDiv")[0], json.head, json.data, {}, {footstyle:4,headstyle:3,nowrap:0});
		self.view.clickRow = SelectCell;
		self.view.overRow = function (){};
		self.reload();
		var dateeditor;
		for (var x = 0; x < fields.length; x++)
		{
			if ((fields[x].nReadOnly == 1) || (fields[x].nShow == 0) || (fields[x].nWidth == 0))
				continue;
			switch (fields[x].Quote.substr(0, 1))
			{
			case "(":
				LoadenumOK(x , fields[x].Quote.substr(1, fields[x].Quote.length - 2));
				break;
			case "@":
				LoadEnum(x);
				break;
			case "$":
				break;
			default:
				break;
				var ss = quote.split(",")
				if (ss.length == 1)
					return false;
				var s1 = ss[0].split(".");
				if (s1[1] == ss[1])
					return false;
				AjaxRequestPage(psubdir + "SeleQuoteTable.jsp?AjaxMode=1&nDB=&TableName=" + s1[0] + "&QuoteField=" + s1[1] + "&AliasField=" + ss[1],
					true, "", fun);
				return true;
			}
			if (fields[x].FieldType == 4)
			{
				if (dateeditor == undefined)
					dateeditor = new $.jcom.DynaEditor.Date(200, 200);
				fields[x].editor = dateeditor;
				var o = $(domobj).find("#" + fields[x].EName);
				fields[x].editor.attach($(domobj).find("#" + fields[x].EName)[0]);
			}
		}
	}
	cfg = $.jcom.initObjVal({action:location.pathname + "?FormSaveFlag=1", target: "", timeout:20}, cfg);

	init();
}