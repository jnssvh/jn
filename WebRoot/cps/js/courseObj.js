/**
 * 
 */
function CourseResTree(domobj, cfg, treecfg)
{
	var self = this;
	var rootItems = [{item:"��ѧ�ƻ�", nType:1, img:"../pic/384.png", style:"font:normal normal normal 14px ΢���ź�;", child:null}, 
		{item:"����ר��", nType:2, img:"../pic/387.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
		{item:"ר���", nType:3, img:"../pic/385.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
		{item:"��ѧ�", nType:4, img:"../pic/382.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
		{item:"������", nType:5, img:"../pic/eut_bs_icon14.png", style:"font:normal normal normal 14px ΢���ź�;", child:null}];
	$.jcom.TreeView.call(this, domobj, rootItems, treecfg, []);
	cfg = $.jcom.initObjVal({classID:0, searchJSP:""}, cfg);
	SearchEdit = new $.jcom.DynaEditor.Edit();
	SearchEdit.config({editorMode:4});
	SearchEdit.onShow = SetSearchButton;
	SearchEdit.onBlur = CheckSearchButton;
	$("#SearchButton").on("click", ClearSearch);
	SearchEdit.onCharChange = DocSearch;
	SearchEdit.attach($("#SearchInput")[0]);
	
	this.loadnode = function(item, div)
	{
		var fun1 = function(data)
		{
			var jsonData = $.jcom.eval(data);
			if (typeof jsonData == "string")
				return alert(jsonData);

			item.child = DealUnitCourse(jsonData.Mode, jsonData.Course, 2, self.CheckItem);
			self.loadnodeok(item, div);
		};
		
		var fun2 = function(data)
		{
			alert(data);
			item.child = [];
			self.loadnodeok(item, div);
			
		};
		
		var fun3 = function(data)
		{
			var treedata = $.jcom.eval(data);
			if (typeof head == "string")
				return alert(treedata);
			PrepareSubjectData(treedata);
			item.child = treedata;
			self.loadnodeok(item, div);
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
				self.CheckItem(item.child[x], 2);
			}
			self.loadnodeok(item, div);
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
				self.CheckItem(item.child[x], 1);
			}
			self.loadnodeok(item, div);		
		};
		
		switch (item.nType)
		{
		case 1:	//��ѧ�ƻ�
			$.get("../fvs/CPB_Class_Course.jsp",{getClassCourseData:1, DataID:cfg.classID}, fun1);
			break;
		case 2:	//����ר��
			$.get("../fvs/CPB_Class_Course.jsp",{getNewSubject:1}, fun31);
			break;
		case 3:	//ר���
			$.get("../fvs/CPB_Subject_Class_view.jsp",{GetTreeData:1, nFormat:0}, fun3);
			break;
		case 4:	//��ѧ�
			$.get("../fvs/CPB_Activity_list.jsp",{GetTreeData:1, OrderField:"Activity_id"}, fun4);
			break;
		case 5:	//������
			item.child = self.getClipItem(51);
			self.loadnodeok(item, div);
			break;
		case 31:	//ר�����
			$.get("../fvs/CPB_Subject_list.jsp",{GetGridData:1, SeekKey:"CPB_Subject.Subject_class_id", SeekParam:item.Subject_Class_id}, fun31);
			break;
		}
	};
	
	this.getClipItem = function(nType)
	{
		return [];
	};
	
	this.dblclick = function(obj, e)
	{
		var item = self.getTreeItem(obj);
		if (item == undefined)
			return;
		if (item.nType < 10)
			return tree.expand(obj);
		self.ApplyItem(item, e);
	};

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
	
	function ClearSearch()
	{
		$("#SearchInput").html("");
		SearchEdit.checkTitle($("#SearchInput")[0], false);
		self.setdata(rootItems);
		CheckSearchButton();
	}

	function DocSearch(value)
	{
		if (value == "")
			return;
		$.get(cfg.searchJSP + "?SearchSubjectDoc=1&SeekKey=" + value, {}, DocSearchOK);
	}

	function DocSearchOK(data)
	{
		var list = eval(data);
		for (var x = 0; x < list.length; x++)
		{
			list[x].item = "<img src=../pic/384.png style=height:16px>&nbsp;" + list[x].Subject_name + "-" + list[x].Teacher_name;
			list[x].nType = 32;
//			CheckItem(item.child[x], 1);
		}
		
		self.setdata(list);
	}

	function SetSearchButton()
	{
		$("#SearchButton").attr("src", "../pic/delete1.gif");
	}

	function CheckSearchButton()
	{
		var data = self.getdata();
		if (data == rootItems)
			$("#SearchButton").attr("src","../pic/search.png");
		else
			$("#SearchButton").attr("src", "../pic/delete1.gif");
	}
	
	this.CheckItem = function ()
	{
	};
	
	this.ApplyItem = function (item, e)
	{
	};
	
	this.SetRes = function (ActivityOption, classID, searchJSP)
	{
		cfg.classID = classID;
		cfg.searchJSP = searchJSP;
		
		var obj = self.getNodeObj("nType", 4);
		if ((ActivityOption == 0) && (typeof obj != "object"))
		{
			var obj = self.getNodeObj("nType", 3);
			var index = parseInt($(obj).attr("node"));
			rootItems.splice(index, 0, {item:"��ѧ�", nType:4, img:"../pic/382.png", style:"font:normal normal normal 14px ΢���ź�;", child:null});
		}
		else if (typeof obj == "object")
		{
			var index = parseInt($(obj).attr("node"));
			rootItems.splice(index, 1);
		}
		rootItems[0].child = null;
		self.setdata(rootItems);
	};
}

function CourseTable(domobj, data, cfg, gridcfg)
{
	var self = this;
	var classObj, courseObj = [], FreeCourse = [], courseGrid, holiItems = [];
	var viewInfo = {nPage:1, PageSize:365, Records:0};
	
	cfg =  $.jcom.initObjVal({EditMode:2, viewMode:1, CourseTitle:"", nDayUse:3, nTitleRows:3, CourseWarningColor:"blue", CourseConflictColor:"red",
		CourseNoSaveStyle: "font-style:italic", CourseSaveStyle: "font-style:normal", coursePath:"../cps/jsp/course.jsp"}, cfg);
	this.options = {
			AMBegin:"8:30", AMEnd: "11:30", PMBegin: "15:00", PMEnd: "17:30", EVBegin: "19:30", EVEnd: "21:30",
			DayShowMode: 1, DateFormat: 1, ShowWeek: 1, ShowEndTime: 1,
			ShowAssistMan: 1, ShowAssistInfo: 1, ShowNote: 1, ShowRed: 1,
			ActivityOption: 1, SaveToCourseOption: 0, SaveInstantOption: 0,
			DelePasteItemOption: 1, SkipHolidayOption: 1, ShowWeekEnd: 0,
			ShowHoliday: 1, ShowOuterTeach: 1, ShowLongCourse: 1, ShowWorkdayIdle: ""};
	
	var viewhead = [{FieldName:"CourseTime", TitleName:"����", nWidth:66, nShowMode:1},
	    {FieldName:"Week", TitleName:"��<br>��", nWidth:20, nShowMode:1},
	    {FieldName:"ap", TitleName:"���", nWidth:36, nShowMode:1},
	    {FieldName:"BeginTime", TitleName:"�Ͽ�ʱ��", nWidth:56, nShowMode:1},
	    {FieldName:"EndTime", TitleName:"�¿�ʱ��", nWidth:56, nShowMode:1},
	    {FieldName:"Time", TitleName:"ʱ��", nWidth:40, nShowMode:6},
	    {FieldName:"Course", TitleName:"��ѧ����", nWidth:200, nShowMode:1},
	    {FieldName:"Teacher", TitleName:"�ڿ���", nWidth:60, nShowMode:1},
	    {FieldName:"ClassRoom", TitleName:"�ص�", nWidth:80, nShowMode:1},		
	    {FieldName:"AssistMan", TitleName:"������", nWidth:60, nShowMode:1},
	    {FieldName:"AssistInfo", TitleName:"��������", nWidth:80, nShowMode:1},
	    {FieldName:"Note", TitleName:"��ע", nWidth:60, nShowMode:1}];

//	    AdjectViewHead();
		gridcfg = $.jcom.initObjVal({footstyle:4,headstyle:3,nowrap:0,cellstyle:"border:1px solid #b0b0b0", resizeflag:0}, gridcfg);
		$.jcom.GridView.call(this, domobj, viewhead, [],{}, gridcfg);
		this.CellEditorTest = GridEditorTest;
		this.overRow = function () {};
		this.pageskip = ViewPageSkip;
		
		this.clickRow = function (td, event)	//���ػ���
		{
		if (td == undefined)
			return;
		var tr = td.parentNode;
		if (tr.rowIndex < 3)
			return;
		var shadow = self.getsel();
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
				
				window.getSelection().deleteFromDocument();		//				document.selection.empty();

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
			window.getSelection().deleteFromDocument();		//				document.selection.empty();
	};
		
	function GridEditorTest(td, headitem)
	{
		var tr = td.parentNode;
		if (tr.rowIndex < cfg.nTitleRows)
			return false;
		return true;
	}

	this.getViewSelRows = function()
	{
		var shadow = self.getsel();
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
	};
	
	function ViewPageSkip(nPage)
	{
		viewInfo.nPage = nPage;
//		courseObj = courseObj.sort(CompareCourseObj);
		self.RefreshCourse();
		
	}

	this.RefreshCourse = function()
	{
		courseObj = courseObj.sort(CompareCourseObj);
		var cd1 = $.jcom.makeDateObj(classObj.Class_BeginTime);
		var cd2 = $.jcom.makeDateObj(classObj.Class_EndTime);
		var oditems = getOuterItems();
		
		var d1 = cd1;
		var d2 = cd2;
		if (courseObj.length > 0)	//����γ�ʱ�䳬���༶��ʼ�ͽ���ʱ��֮�⡣
		{
			var dd = $.jcom.makeDateObj(courseObj[0].Syllabuses_date);
			if (dd < d1)
				d1 = dd;
			dd = $.jcom.makeDateObj(courseObj[courseObj.length - 1].Syllabuses_date);
			if (dd > d2)
				d2 = dd;
		}
		if (cfg.EditMode == 1)
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
		var childs = self.getChildren();
		var cols = childs.gridhead.getColumnCount();
		courseGrid[0].CourseTime = {value:classObj.Class_Name + "<br>�γ̱�", colspan:cols,prop:"align=center ", style:"font:normal normal 400 14pt ����;",tdstyle:"border:none"};
		courseGrid[1] = {};
		courseGrid[1].CourseTime = {value:"<div style=float:left>��α��:" + classObj.ClassCode + "</div><div style=float:right>��ѵʱ��:" + 
				classObj.Class_BeginTime + "��" + classObj.Class_EndTime + "</div>", colspan:cols, tdstyle:"border:none"};
		courseGrid[2] = {};
//		var viewhead = self.getHead();
		for (var x = 0; x < viewhead.length; x++)
		{
			courseGrid[2][viewhead[x].FieldName] = {value:viewhead[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt ����;"};
		}
		var y = 0;
	//var d1 =  $.jcom.makeDateObj("2018-5-21");
		for (var d = d1; d <= d2; d.setDate(d.getDate() + 1))
		{
			var lineControl = {};
			var datetype = getCourseDateNote(d, cd1, cd2,oditems);
			if (cfg.EditMode == 1)
			{
				switch (datetype)
				{
				case "��ѧǰ":
					lineControl = {bgcolor:"#c8c8c8"};
					break;
				case "��ҵ��":
					lineControl = {bgcolor:"#d0d0d0"};
					break;
				case "��ؽ�ѧ":
					lineControl = {bgcolor:"#e0e0ff"};
					break;
				default:
					if (self.isHoliday(d))
						lineControl = {bgcolor:"#e0ffe0"};				
					break;
				}
			}
			var x = courseGrid.length;
			if (cfg.EditMode == 1)
			{
				courseGrid[x] = InitCourseGridItem(self.options.AMBegin, self.options.AMEnd, 0, d, datetype, lineControl);
				courseGrid[x + 1] = InitCourseGridItem(self.options.PMBegin, self.options.PMEnd, courseGrid[x]);
				if (cfg.nDayUse == 3)
					courseGrid[x + 2] = InitCourseGridItem(self.options.EVBegin, self.options.EVEnd, courseGrid[x]);
			}
			else if (!self.isHoliday(d) && (self.options.ShowWorkdayIdle != "") && (self.options.ShowWorkdayIdle != "null"))
			{
				courseGrid[x] = InitCourseGridItem(self.options.AMBegin, self.options.AMEnd, 0, d, datetype, lineControl);
				courseGrid[x + 1] = InitCourseGridItem(self.options.PMBegin, self.options.PMEnd, courseGrid[x]);
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
						self.TransCourseItem(courseObj[y], courseGrid[x]);
					}
					else
						self.TransCourseGrid(courseObj[y], pos);
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
		if (cfg.EditMode == 1)
			return self.reset(courseGrid, viewInfo, viewhead);

		for (var x = cfg.nTitleRows; x < courseGrid.length; x++)
		{
			if (courseGrid[x].index < 0)
			{
//				if (!isHoliday(d) && (self.options.ShowWorkdayIdle != "null"))
					courseGrid[x].Course = {value:self.options.ShowWorkdayIdle, colspan:3};
					delete courseGrid[x].Teacher;
					delete courseGrid[x].ClassRoom;
			}
		}
		viewInfo.Records = courseGrid.length;
		if (self.PrepareCourseUserData(courseGrid, viewInfo, viewhead) == false)
			return;
		self.reset(courseGrid, viewInfo, viewhead);
	};

	this.PrepareCourseUserData = function (courseGrid, viewInfo, viewhead)
	{
		return true;
	};

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
	
	function getCourseDateNote(d, cd1, cd2, oditems)
	{
		if (d < cd1)
			return "��ѧǰ";
		if (d > cd2)
			return "��ҵ��";
		for (var x =0; x < oditems.length; x++)
		{
			if ((d >= oditems[x].b) && (d <= oditems[x].e))
				return "��ؽ�ѧ";
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
					return "�ڼ���";
				case 2:
					return "��Ϣ��";
				case 3:
					return "���� ��";
				}
			}
		}
		return "";
	}

	this.isHoliday = function(d)
	{
		var ap = self.getDateAP($.jcom.GetDateTimeString(d, 4));
		for (var x = 0; x < holiItems.length; x++)
		{
			var d1 = $.jcom.makeDateObj(holiItems[x].THoliday);
			if ((d1.getFullYear() == d.getFullYear()) && (d1.getMonth() == d.getMonth()) && (d1.getDate() == d.getDate()))
			{
				if (holiItems[x].nDateType == 1)	//ȫ��
					return (holiItems[x].nType == 1) || (holiItems[x].nType == 2);
				if ((holiItems[x].nDateType == 2) && (ap == "����"))
					return (holiItems[x].nType == 1) || (holiItems[x].nType == 2);
				if ((holiItems[x].nDateType == 3) && (ap == "����"))
					return (holiItems[x].nType == 1) || (holiItems[x].nType == 2);
			}
		}
		var w = d.getDay();
		return (w == 0)	|| (w == 6);
	};
	
	this.getDateAP = function(d)
	{
		if (typeof d == "object")
			d = d.value;
		var s = d.split(" ");
		if (s.length == 2)
			d = s[1];
		var ss = d.split(":");
		var h = parseInt(ss[0]);
		if (h < 12)
			return "����";
		if (h < 18)
			return "����";
		return "����";
	};

	this.TransCourseGrid = function(courseItem, index)
	{
		var gridItem = courseGrid[index];
		var b = $.jcom.GetDateTimeString(courseItem.BeginTime, 14);
		if (courseItem.nType == 2)	//ѡ�޿�
		{
			var flag = 0;	//Ĭ���ǲ��ϲ��ĵ�Ԫ��
			for (var x = index - 1; x >= 0; x --)
			{
				if (typeof courseGrid[x].BeginTime != "object")
					continue;
				if (courseGrid[x].BeginTime.ex != b)
					break;
				if (typeof courseGrid[x].BeginTime == "object")
				{
					if (courseGrid[x].BeginTime.rowspan == 1)
						courseGrid[x].BeginTime.value += "<br>ѡ�޿�";
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
			var ap = self.getDateAP(courseItem.BeginTime);
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
			if (self.options.ShowEndTime == 2)
			{
				gridItem.BeginTime.value = "<div id=Field_BeginTime style='width:100%;overflow-y:visible'>" + gridItem.BeginTime.value +
					"</div><div id=Field_EndTime style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;'>" + gridItem.EndTime.value + "</div>";
			}
//			else if (self.options.ShowEndTime == 2)
//				gridItem.BeginTime = {value:getDateAP(gridItem.BeginTime)};
		}
		self.TransCourseItem(courseItem, gridItem);
	};

	this.TransCourseItem = function (courseItem, gridItem)
	{
		if (typeof courseItem.Syllabuses_subject_name == "undefined")
			return;
		var c = self.getCourseName(courseItem);
		gridItem.Course = {value:c, ex:c};

		if ((courseItem.Syllabuses_activity_id == 0) && (courseItem.Syllabuses_course_id == 0) && (courseItem.Syllabuses_subject_id == 0) && (self.options.ShowRed == 1))
			gridItem.Course.color = cfg.CourseWarningColor;
		if ((courseItem.EditFlag == 1) || (courseItem.EditFlag == 2))
			gridItem.Course.style = cfg.CourseNoSaveStyle;
		else
			gridItem.Course.style = cfg.CourseSaveStyle;
		if (self.options.ShowNote == 2)
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
		if ((courseItem.Syllabuses_teacher_id == 0) && (self.options.ShowRed == 1))
			gridItem.Teacher = {value:courseItem.Syllabuses_teacher_name, color:cfg.CourseWarningColor};
		if ((courseItem.nConflict & 2) > 0)
			gridItem.Teacher = {value:courseItem.Syllabuses_teacher_name, color:cfg.CourseConflictColor, prop:"title='��ͻ����:" + courseItem.ConflictInfo + "'"};
		
		gridItem.AssistMan = {value:courseItem.AssistMan, color:"black"};
		if ((courseItem.nConflict & 4) > 0)
			gridItem.AssistMan = {value:courseItem.AssistMan, color:cfg.CourseConflictColor, prop:"title='��ͻ����:" + courseItem.ConflictInfo + "'"};
				
		if (self.options.ShowAssistMan == 2)
		{
			gridItem.Teacher.value = "<div id=Field_Teacher style='width:100%;overflow-y:visible'>" + gridItem.Teacher.value +
				"</div><div id=Field_AssistMan style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;color:" + 
				gridItem.AssistMan.color + "'>" + courseItem.AssistMan + "</div>";
		}
		gridItem.ClassRoom = courseItem.Syllabuses_ClassRoom;
		if ((courseItem.nConflict & 1) > 0)
			gridItem.ClassRoom = {value:courseItem.Syllabuses_ClassRoom, color:cfg.CourseConflictColor, prop:"title='��ͻ����:" + courseItem.ConflictInfo + "'"};
		gridItem.Note = courseItem.Syllabuses_bak;
		gridItem.AssistInfo = courseItem.AssistInfo;
	}

	this.getCourseName = function(item)
	{
		if (item.Syllabuses_activity_id > 0)
			 return item.Syllabuses_activity_name;
		else if (item.Syllabuses_subject_name > 0)
			return item.Syllabuses_subject_name;
		else
			return item.Syllabuses_course_name;
	};
	
	function AdjectViewHead()
	{
//		var viewhead = self.getHead();
		var fields = ["Week", "EndTime", "AssistMan", "AssistInfo", "Note"];
		for (var x = 0; x < fields.length; x++)
		{
			for (var y = 0; y < viewhead.length; y++)
			{
				if (viewhead[y].FieldName == fields[x])
				{
					if (self.options["Show" + fields[x]] == 1)
						viewhead[y].nShowMode = 1;
					else
						viewhead[y].nShowMode = 6;
				}
			}
		}
		if (self.options.ShowEndTime == 0)
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
	
	self.InsertCourseItem = function(index)
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
	};
	

	function getOuterItems()
	{
		var oditems = [];
		oditems[0] = {b: $.jcom.makeDateObj(classObj.OuterBegin), e: $.jcom.makeDateObj(classObj.OuterEnd)};
		for (var x = 0; x < classObj.OtherOuterTime.length; x++)
			oditems[oditems.length] = {b: $.jcom.makeDateObj(classObj.OtherOuterTime[x].OuterBegin), e: $.jcom.makeDateObj(classObj.OtherOuterTime[x].OuterEnd)};
		return oditems;
	}

	function findCourseGridPos(d, b)
	{
		var pos = courseGrid.length;
		var ap = self.getDateAP(d);
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
		self.InsertCourseItem(pos);
		return pos;
	}

	function InitCourseGridItem(begintime, endtime, parentItem, d, ex, lineControl)
	{
		var item = {};
		item.BeginTime = begintime;
		item.ap = self.getDateAP(begintime);
		if (self.options.ShowEndTime == 2)
		{
			item.BeginTime = {value: "<div id=Field_BeginTime style='width:100%;overflow-y:visible'>" + begintime + "</div>" +
				"</div><div id=Field_EndTime style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;'>" + endtime + "</div>", ex:begintime};
		}
//		else 
//		if (self.options.ShowEndTime == 2)
//			item.BeginTime = {value:getDateAP(begintime), ex:begintime};
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
		if ((self.options.ShowNote == 2) && (cfg.EditMode == 1))
		{
			item.Course = {value: "<div id=Field_Course style='width:100%;overflow-y:visible'></div>" +
				"<div id=Field_Note style='width:100%;height:20px;overflow-y:visible;border-top:1px solid #f0f0f0;'></div>", ex:""};
		}
		if ((self.options.ShowAssistMan == 2) && (cfg.EditMode == 1))
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
		
		switch (self.options.DateFormat)
		{
		case 1:	//��.�ָ�
			var dd = $.jcom.GetDateTimeString(d, 17);
			if (self.options.DayShowMode == 1)
				dd = $.jcom.GetDateTimeString(d, 16);
			break;
		case 2:	//��-�ָ�
			var dd = $.jcom.GetDateTimeString(d, 10);
			if (self.options.DayShowMode == 1)
				dd = $.jcom.GetDateTimeString(d, 1);
			break;
		case 0:
		default:
			var dd = $.jcom.GetDateTimeString(d, 13);
			if (self.options.DayShowMode == 1)
				dd = d.getFullYear() + "��<br>" + dd;
			break;
		}
		if (self.options.ShowWeek == 2)
			dd += "<br>(����" + $.jcom.getCWeekDay(d) + ")";
		item.CourseTime = {value:dd + "<br>" + ex, rowspan:1};
		item.Week = {value: $.jcom.getCWeekDay(d), rowspan:1};
		item.DateValue = $.jcom.GetDateTimeString(d, 1);
		return item;
	}
	
	this.LoadCourse = function (classID)
	{
		cfg.viewMode = 1;
		cfg.courseTitle = "";
		self.waiting();
		$.get(cfg.coursePath, {LoadCourse:1,ClassID:classID, EditMode:cfg.EditMode}, LoadCourseOK);
	}

	function LoadCourseOK(data)
	{
		var jsondata = $.jcom.eval(data);
		if (typeof jsondata == "string")
			return self.waiting(data);
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
			data += "����Ա��";
			AssistManEdit.setData(data);
		}
		
		courseObj = jsondata.Course;
//		FreeCourse = jsondata.FreeCourse;
		holiItems = jsondata.Holiday;
		for (var x = 0; x < holiItems.length; x++)
		{
			holiItems[x].THoliday = parseInt(holiItems[x].THoliday / 10000) + "-" + (parseInt(holiItems[x].THoliday / 100) % 100) + "-" + (holiItems[x].THoliday % 100);
			holiItems[x].PublicOption = 2;	//ȫ�ֽڼ���
		}
		for (var x = 0; x < jsondata.ClassHoliday.length; x++)
		{
			jsondata.ClassHoliday[x].THoliday = parseInt(jsondata.ClassHoliday[x].THoliday / 10000) + "-" + (parseInt(jsondata.ClassHoliday[x].THoliday / 100) % 100) + "-" + (jsondata.ClassHoliday[x].THoliday % 100);
			jsondata.ClassHoliday[x].PublicOption = 1;	//�༶�ڼ���
		}
		holiItems = holiItems.concat(jsondata.ClassHoliday);
		
		for (var key in jsondata.ClassCourseConfig)			//�༶����
			self.options[key] = jsondata.ClassCourseConfig[key];
		if (jsondata.ClassCourseConfig.PageSize != undefined)
			viewInfo.PageSize = jsondata.ClassCourseConfig.PageSize;
		self.options = jsondata.Options;
		classObj.OtherOuterTime = jsondata.OtherOuterTime;	//������ؽ�ѧʱ��
		for (var x = 0; x < courseObj.length; x++)
		{
			courseObj[x].EditFlag = 0;
			courseObj[x].nConflict = 0;
			courseObj[x].ConflictInfo = "";
			APtoDate(courseObj[x]);
		}
		self.onLoadCourseReady(jsondata);
		AdjectViewHead();
		self.RefreshCourse();
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
		case "����":
			item.BeginTime = d + " " + self.options.PMBegin;
			item.EndTime = d + " " + self.options.PMEnd;
			break;
		case "����":
			item.BeginTime = d + " " + self.options.EVBegin;
			item.EndTime = d + " " + self.options.EVEnd;
			break;
		case "����":
		default:
			item.BeginTime = d + " " + self.options.AMBegin;
			item.EndTime = d + " " + self.options.AMEnd;
			break;
		}
	}

	this.onLoadCourseReady = function(jsondata)
	{
	};
	
	this.LoadTermCourse = function(termID, courseTitle)
	{
		cfg.viewMode = 2;
		cfg.courseTitle = courseTitle;
		$.get(cfg.coursePath, {LoadTermCourse:1,Term_id:termID}, LoadTermCourseOK);		
	};

	function LoadTermCourseOK(data)
	{
		courseObj = $.jcom.eval(data);
		if (typeof courseObj == "string")
			alert(courseObj);
//		classObj = undefined;
		for (var x = 0; x < courseObj.length; x++)
			APtoDate(courseObj[x]);
		var head = [{FieldName:"CourseTime", TitleName:"����", nWidth:66, nShowMode:1},
		    		{FieldName:"BeginTime", TitleName:"ʱ��", nWidth:56, nShowMode:1},
		    		{FieldName:"Class_Name", TitleName:"���", nWidth:100, nShowMode:1},
		    	    {FieldName:"Course", TitleName:"����", nWidth:200, nShowMode:1},
		    	    {FieldName:"Teacher", TitleName:"�ڿ���", nWidth:60, nShowMode:1},
		    	    {FieldName:"ClassRoom", TitleName:"�ص�", nWidth:80, nShowMode:1}];
		
		courseGrid = [];
		var childs = self.getChildren();
		var cols = childs.gridhead.getColumnCount();
		courseGrid[0] = {CourseTime:{value:cfg.courseTitle, colspan:cols,prop:"align=center ", style:"font:normal normal 400 14pt ����;",tdstyle:"border:none"}};
		courseGrid[1] = {CourseTime:{value:"<div style=float:right>��ѵʱ��δ��</div>", colspan:cols, tdstyle:"border:none"}};
		if (courseObj.length > 0)
			courseGrid[1].CourseTime.value = "<div style=float:right>��ѵʱ��:" + $.jcom.GetDateTimeString(courseObj[0].Syllabuses_date, 1) + "��" + 
				$.jcom.GetDateTimeString(courseObj[courseObj.length - 1].Syllabuses_date, 1) + "</div>";
		courseGrid[2] = {};
		for (var x = 0; x < head.length; x++)
		{
			courseGrid[2][head[x].FieldName] = {value:head[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt ����;"};
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
				var dd = d2.getFullYear() + "��<br>" + $.jcom.GetDateTimeString(d2, 13) + "<br>(����" + $.jcom.getCWeekDay(d2) + ")";
				courseGrid[x + y] = {CourseTime:{value:dd, rowspan:1}};
				d1 = d2;
				index = x;
			}
			
			courseGrid[x + y].BeginTime = $.jcom.GetDateTimeString(courseObj[x].BeginTime, 14) + "<br>" + $.jcom.GetDateTimeString(courseObj[x].EndTime, 14);
//			if (self.options.ShowEndTime == 2)
//				courseGrid[x + y].BeginTime = getDateAP(courseGrid[x + y].BeginTime);

			courseGrid[x + y].Class_Name = courseObj[x].Class_Name;
			courseGrid[x + y].Course = self.getCourseName(courseObj[x]);
			courseGrid[x + y].Course = courseGrid[x + y].Course + "<br>" + courseObj[x].Syllabuses_bak;
			courseGrid[x + y].Teacher = courseObj[x].Syllabuses_teacher_name + "<br>" + courseObj[x].AssistMan;
			courseGrid[x + y].ClassRoom = courseObj[x].Syllabuses_ClassRoom;
			courseGrid[x + y].index = x;
		}
		self.reset([], viewInfo, head);
		viewInfo.Records = courseGrid.length;
		if (PrepareTermCourseUserData(courseGrid) == false)
			return;

		self.reset(courseGrid, viewInfo, head);
	}

	this.LoadManyClassCourse = function (classIDs, beginTime, endTime, option)
	{
		option = $.jcom.initObjVal({Title:"�����ܿα�", nType:1}, option);	
		if (option.nType == 1)
			var fun = LoadManyClassCourseViewV;
		else
			var fun = LoadManyClassCourseViewH;
		cfg.viewMode = option.nType + 2;
		cfg.courseTitle = option.Title;		
		self.waiting();
		$.get(cfg.coursePath, {LoadManyClassCourse:1,ClassIDs:classIDs, ClassBeginTime:beginTime, ClassEndTime:endTime}, fun);				
	};
	
	function LoadManyClassCourseViewH(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
//		classObj = undefined;
		courseObj = json.Course;
		var Classes = json.Classes;
//		var Classes = ManyCourseOptionView.getData();
		for (var x = 0; x < courseObj.length; x++)
			APtoDate(courseObj[x]);
		var head = [{FieldName:"CourseTime", TitleName:"����", nWidth:66, nShowMode:1},
		    		{FieldName:"Week", TitleName:"��<br>��", nWidth:20, nShowMode:1},
		    		{FieldName:"ap", TitleName:"���", nWidth:46, nShowMode:1}];
		for (var x = 0; x < Classes.length; x++)
		{
			head[head.length] = {FieldName: "Course_" + Classes[x].Class_id, TitleName: "��ѧ����", nWidth:70, nShowMode:1};
			head[head.length] = {FieldName: "Teacher_" + Classes[x].Class_id, TitleName: "�ڿν�ʦ������", nWidth:70, nShowMode:1};
			head[head.length] = {FieldName: "Room_" + Classes[x].Class_id, TitleName: "�ص�", nWidth:50, nShowMode:1};
		}
		courseGrid = [];
		courseGrid[0] = {};
		var childs = self.getChildren();
		var cols = head.length;
		courseGrid[0].CourseTime = {value:$("#ManyCourseTitle").val(), colspan:cols,prop:"align=center ", style:"font:normal normal 400 14pt ����;",tdstyle:"border:none"};
		courseGrid[1] = {};
		courseGrid[1].CourseTime = {value:"<div style=float:right>��ѵʱ��δ��</div>", colspan:cols, tdstyle:"border:none"};
		if (courseObj.length > 0)
			courseGrid[1].CourseTime.value = "<div style=float:right>��ѵʱ��:" + $.jcom.GetDateTimeString(courseObj[0].Syllabuses_date, 1) + "��" + 
				$.jcom.GetDateTimeString(courseObj[courseObj.length - 1].Syllabuses_date, 1) + "</div>";
		courseGrid[2] = {};
		courseGrid[3] = {};
		courseGrid[4] = {};
		courseGrid[5] = {};
		courseGrid[2].CourseTime = {value: "", colspan:3, rowspan:3};
		for (var x = 0; x < Classes.length; x++)
		{
			courseGrid[2]["Course_" + Classes[x].Class_id] = {value:Classes[x].Class_Name, colspan:3,prop:"align=center ",style:"font:normal normal 700 9pt ����;"};
			courseGrid[3]["Course_" + Classes[x].Class_id] = {value:"��֯Ա",prop:"align=center ",style:"font:normal normal 700 9pt ����;"};	
			courseGrid[3]["Teacher_" + Classes[x].Class_id] = {value:"��������",prop:"align=center ",style:"font:normal normal 700 9pt ����;"};
			courseGrid[3]["Room_" + Classes[x].Class_id] = {value:"�ƻ�����",prop:"align=center ",style:"font:normal normal 700 9pt ����;"};
			courseGrid[4]["Course_" + Classes[x].Class_id] = "";	
			courseGrid[4]["Teacher_" + Classes[x].Class_id] = "";
			courseGrid[4]["Room_" + Classes[x].Class_id] = "";
		}	

		for (var x = 0; x < head.length; x++)
		{
			courseGrid[5][head[x].FieldName] = {value:head[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt ����;"};
		}
		
		var d1 = $.jcom.makeDateObj("1970-1-1");
		var index = 6;
		for (var x = 0; x < courseObj.length; x++)
		{
			var d2 = $.jcom.makeDateObj(courseObj[x].Syllabuses_date);
			if ((d2.getYear() != d1.getYear()) || (d2.getMonth() != d1.getMonth()) || (d2.getDate() != d1.getDate()))
			{
				var dd = d2.getFullYear() + "��<br>" + $.jcom.GetDateTimeString(d2, 13);
				index = courseGrid.length;
				var ap = self.getDateAP(courseObj[x].BeginTime);
				courseGrid[index] = InitManyClassCourseItem(head, ap);
				courseGrid[index].CourseTime = {value:dd, rowspan:1};
				courseGrid[index].Week = {value:$.jcom.getCWeekDay(d2), rowspan:1};
				courseGrid[index].ap = {value:ap, rowspan:1};
				d1 = d2;
			}
			
			SetManyClassCourseGridV(index, courseObj[x], head);
		}
		
		for (var x = 3; x < courseGrid.length; x++)
		{
			for (var key in courseGrid[x])
			{
				if ((courseGrid[x][key] === "����") || (courseGrid[x][key] === "����") || (courseGrid[x][key] === "����"))
					courseGrid[x][key] = "";
			}	
		}
		
		viewInfo.Records = courseGrid.length;
		self.reset(courseGrid, viewInfo, head);
	}

	function SetManyClassCourseGridV(begin, course, head)
	{
		var field = "C_" + course.class_id;
		var ap = self.getDateAP(course.BeginTime);
		for (var x = begin; x < courseGrid.length; x ++)
		{
			if (courseGrid[x]["Course_" + course.class_id] == ap)
			{
				courseGrid[x]["Course_" + course.class_id] = self.getCourseName(course);
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

		courseGrid[x]["Course_" + course.class_id] = self.getCourseName(course);
		courseGrid[x]["Teacher_" + course.class_id] = course.Syllabuses_teacher_name + "<br>" + course.AssistMan;
		courseGrid[x]["Room_" + course.class_id] = course.Syllabuses_ClassRoom;
	}


	function LoadManyClassCourseViewV(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
//		classObj = undefined;
		courseObj = json.Course;
		var Classes = json.Classes;
//		var Classes = ManyCourseOptionView.getData();
		for (var x = 0; x < courseObj.length; x++)
			APtoDate(courseObj[x]);
		var head = [{FieldName:"CourseTime", TitleName:"����", nWidth:66, nShowMode:1},
		    		{FieldName:"Week", TitleName:"��<br>��", nWidth:20, nShowMode:6},
		    		{FieldName:"ap", TitleName:"���", nWidth:46, nShowMode:1},
		    		{FieldName:"RowHead", TitleName:"��Ŀ", nWidth:64, nShowMode:1}];
		for (var x = 0; x < Classes.length; x++)
		{
			head[head.length] = {FieldName: "C_" + Classes[x].Class_id, TitleName: Classes[x].Class_Name, nWidth:100, nShowMode:1};
		}
		
		courseGrid = [];
		courseGrid[0] = {};
		var childs = self.getChildren();
		var cols = head.length - 1;
		courseGrid[0].CourseTime = {value:$("#ManyCourseTitle").val(), colspan:cols, prop:"align=center ", style:"font:normal normal 400 14pt ����;",tdstyle:"border:none"};
		courseGrid[1] = {};
		courseGrid[1].CourseTime = {value:"<div style=float:right>��ѵʱ��δ��</div>", colspan:cols, tdstyle:"border:none"};
		if (courseObj.length > 0)
			courseGrid[1].CourseTime.value = "<div style=float:right>��ѵʱ��:" + $.jcom.GetDateTimeString(courseObj[0].Syllabuses_date, 1) + "��" + 
				$.jcom.GetDateTimeString(courseObj[courseObj.length - 1].Syllabuses_date, 1) + "</div>";
		courseGrid[2] = {};
		for (var x = 0; x < head.length; x++)
		{
			courseGrid[2][head[x].FieldName] = {value:head[x].TitleName, prop:"align=center ",style:"font:normal normal 700 9pt ����;"};
		}
		
		var d1 = $.jcom.makeDateObj("1970-1-1");
		var index = 2;
		for (var x = 0; x < courseObj.length; x++)
		{
			var d2 = $.jcom.makeDateObj(courseObj[x].Syllabuses_date);
			if ((d2.getYear() != d1.getYear()) || (d2.getMonth() != d1.getMonth()) || (d2.getDate() != d1.getDate()))
			{
				var dd = d2.getFullYear() + "��<br>" + $.jcom.GetDateTimeString(d2, 13) + "<br>(����" + $.jcom.getCWeekDay(d2) + ")";
				index = courseGrid.length;
				var ap = self.getDateAP(courseObj[x].BeginTime);
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
				if ((item === "����") || (item === "����") || (item === "����"))
					courseGrid[x]["C_" + Classes[y].Class_id] = "";
			}	
		}
		viewInfo.Records = courseGrid.length;
		self.reset(courseGrid, viewInfo, head);
	}

	function SetManyClassCourseGridH(begin, course, head)
	{
		var field = "C_" + course.class_id;
		var ap = self.getDateAP(course.BeginTime);
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
		courseGrid[index].RowHead = {value:"��ѧ����", color:"black"};
		courseGrid[index + 1].RowHead = {value:"�ڿν�ʦ������", color:"blue"};
		courseGrid[index + 2].RowHead = {value:"�ص�", color:"green"};
	}

	function TransClassCourseField(x, field, course)
	{
		courseGrid[x][field] = {value:self.getCourseName(course), color:"black"};
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

	this.OutWord = function()
	{
//		document.getElementById("FieldDataFrame").src = "CourseExport.jsp?class_id=" + classObj.Class_id;
//		view.OutHTML(classObj.Class_Name + "�γ̱�.htm");
		var	url = "../com/OutHtml.jsp", f, text;
		var head = "<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:w=\"urn:schemas-microsoft-com:office:word\" xmlns=\"http://www.w3.org/TR/REC-html40\">\n" +
		"<head>\n<meta http-equiv=Content-Type content=\"text/html; charset=gb2312\">\n" +
		"<!--[if gte mso 9]><xml>\n<w:WordDocument>\n<w:View>Print</w:View>\n</xml><![endif]-->\n" +
		"<style>\ntd {font: normal small-caps normal 14px ΢���ź�}\nthead td {font:normal small-caps bolder  14px ����}\n</style>\n</head>\n";

		var f = getOutFileName();
		switch (cfg.viewMode)
		{
		case 1:
		case 2:
			text = "<h2 align=center>" + f + "</h2><div align=center>" + self.outerDoc(2, {}, {cellstyle: "border:1px solid black"}) + "</div>";
			break;
		case 3:
			text = "<h2 align=center>" + f + "</h2><div align=center>" + self.outerDoc(2, {rowbegin:3}, {cellstyle: "border:1px solid black"}) + "</div>";
			break;
		case 4:
			text = "<h2 align=center>" + f + "</h2><div align=center><table id=BodyTable cellpadding=0 cellspacing=0 border=1 style='border-collapse:collapse;border:none;'>" +
				"<thead>" + self.outerDoc(102, {rowbegin:2, rowend:6}, {cellstyle: "border:1px solid black"}) + "</thead>" +
				self.outerDoc(102, {rowbegin:6}, {cellstyle: "border:1px solid black"}) + "</table></div>";
			break;
		}
		var obj = {FileName:f + ".doc", head:head, body:text};
		$.jcom.submit(url, obj);	
	};

	this.OutExcel = function()
	{	
		var f = getOutFileName();
		self.OutExcel(f + ".xls");
	};

	function getOutFileName()
	{
		if (cfg.viewMode == 1)
			var f = classObj.Class_Name + "�γ̱�";
		else
			var f = cfg.CourseTitle;
		return f;
	}

	function OutExceltoServer()
	{
//		var	url = "../com/OutExcel.jsp?OutToServer=1";
//		view.OutExcel(classObj.Class_Name + "�γ̱�.xls", url);
		var	url = "../com/OutHtml.jsp";
		self.OutExcel(classObj.Class_Name + "�γ̱�.htm", url);
	}

	function OutExceltoServerOK(id)
	{
		$.get(coursePath + "?AffixName=" + classObj.Class_Name + "�γ̱�.xls", 
			{OutExcelToServer:1, ClassID:classObj.Class_id, AffixID:id}, OutExceltoDocOK);
	}

	function OutExceltoDocOK(data)
	{
		alert(data);
	}

	this.getChild = function(name)
	{
		var o = {classObj: classObj, courseObj: courseObj, FreeCourse: FreeCourse, courseGrid: courseGrid, holiItems: holiItems, cfg: cfg, viewhead: viewhead};
		if (name == undefined)
			return o;
		return o[name];
	};
}

function CourseEditor(domobj, data, cfg, gridcfg)
{
	var self = this;
	var courseEdit, subjectObj, teacherObj, teacherEdit, noteEdit, timeEdit, roomtree, roomEdit, AssistManEdit, AssistInfoEdit;
	var clip = [], ConflictObj = [];
	var AutoSaveCourse = 0,rMenuEnable = true;
	var StateRight = {};
	cfg =  $.jcom.initObjVal({EditMode:1, tree:undefined}, cfg);	
	CourseTable.call(this,domobj, data, cfg, gridcfg);
	
	function init()
	{		
//		noteEdit = new $.jcom.DynaEditor.Text(0, 40);
		noteEdit = new $.jcom.DynaEditor.Edit();
		noteEdit.valueChange = NoteChange;
		timeEdit = new $.jcom.DynaEditor.Date(300, 300, {dateType:7});
		timeEdit.config({editorMode:4});
//		timeEdit.OverWrite(true);
//		timeEdit.cal = CalTime;
		timeEdit.valueChange = TimeChange;
		roomtree = new $.jcom.TreeView(0, 0, {});
		roomEdit = new $.jcom.DynaEditor.TreeList(roomtree, 200, 200);
		roomEdit.config({editorMode:4});
		roomEdit.valueChange = roomChange;
		AssistManEdit = new $.jcom.DynaEditor.List("����Ա��", 200, 200);
		AssistManEdit.config({editorMode:4});
		AssistManEdit.valueChange = AssistManChange;
		AssistInfoEdit = new $.jcom.DynaEditor.List(",����,һ��һ��,�ֳ���ѧ,ʡ�ڵ���,С��������̸,�ṹ����������,�ṹ�����۲���,ѧԱ��̳,�Ծ�,�Ծ�AB��,�࿼,�ľ�", 200, 200);
		AssistInfoEdit.config({editorMode:4});
		AssistInfoEdit.valueChange = AssistInfoChange;

		var rdef = [{item:"����",action:CutCourseItem},{item:"����", action:CopyCourseItem}, {item:"ճ��", action:PasteCourseItem},
			{item:"ѡ�õ�ǰ��α�", action:menuApplyCourse},{}, {item:"�����α�ǰ��", action:menuInsertCourseLine},{},{item:"ɾ��ѡ�����еĿγ�", action:menuDeleteCourseItem},{},
			{item:"����ѡ���еĿγ�Ϊ������", action:SetCommCourse}, {item:"����ѡ���еĿγ�Ϊѡ�޿�", action:SetFreeCourse},{},{item:"���ÿγ�ʱ��", action:SetCourseLen},{},
			{item:"���ҿγ���ص�ר��", action:FindSubject}];
		rmenu = new $.jcom.CommonMenu(rdef);
		self.bodymenu = CourseMenu;

		$.get("../fvs/Place_Course.jsp", {GetTreeData:2}, LoadPlaceOK);

		courseEdit = new $.jcom.DynaEditor.Search(CourseSearch);
		courseEdit.config({editorMode:4});
		courseEdit.valueChange = CourseChange;
		courseEdit.dblclick = EditCourseSubject;

		teacherEdit = new $.jcom.DynaEditor.Search(TeacherSearch);
		teacherEdit.config({editorMode:4});
		teacherEdit.valueChange = TeacherChange;
		teacherEdit.dblclick = EditTeacher;
		AttachEditor();	
		self.keydown = CourseKey;
	
		cfg.tree.getClipItem = getClipItem;
		cfg.tree.CheckItem = CheckItemInCourse;
		cfg.tree.ApplyItem = TreeApply;
		
	}

	function CalTime(value, step)
	{
		if (typeof value == "object")
			value = value.value;
		var ss = value.split(":");
		if (ss.length < 2)
			return self.options.AMBegin;
		var m = parseInt(ss[0]) + step;
		if (m < 7)
			m = 7;
		if (m > 23)
			m = 23;
		return  m + ":" + ss[1];
	}

	function CourseKey(e)
	{
	return;	//���Ҽ��˵��ˣ���ת���ݼ��������ϵͳ��ݼ���ͻ��
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
	
	function TreeApply(item, e)
	{
		if ((item.style != "") && (e.ctrlKey == false))
			return SkipToCourseItem(2, item.Subject_id);
		ApplyCourse(item);
	}
	
	function CheckItemInCourse(item, ntype)
	{
		var o = self.getChild();
		for (var x = 0; x < o.courseObj.length; x++)
		{
			if (o.courseObj[x].EditFlag == 3)	//delete flag
				continue;
			switch (ntype)
			{
			case 1:		//ר��
				if (o.courseObj[x].Syllabuses_subject_id == item.Subject_id)
				{
					item.style = "color:gray";
					return true;
				}
				break;
			case 2:		//��ѧ�
				if (o.courseObj[x].Syllabuses_activity_id == item.Activity_id)
				{
					item.style = "color:gray";
					return true;
				}
				break;
			case 3:		//��ѧ�ƻ�
				if (o.courseObj[x].Syllabuses_course_id == item.Course_id)
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

	function SkipToCourseItem(nType, value)
	{
		var o = self.getChild();
		for (var x = o.cfg.nTitleRows; x < o.courseGrid.length; x++)
		{
			if (o.courseGrid[x].index < 0)
				continue;
			if (nType == 1)		//��λ��Syllabuses_id
			{
				if (o.courseObj[o.courseGrid[x].index].Syllabuses_id == value)
					break;
			}
			else if (nType == 2)
			{
				if (o.courseObj[o.courseGrid[x].index].Syllabuses_subject_id == value)
					break;
			}
		}
		if (x >= o.courseGrid.length)
			return false;
		var tr = self.getRow(x);
		var e = $.Event( "keydown", {ctrlKey: false, shiftKey:false});
		self.clickRow($("#Course_TD", tr)[0], e);
		tr.scrollIntoView(false);
		return true;
	}

	function CourseMenu(td, e)
	{
		if ((td == undefined) || (e.ctrlKey) || (document.getSelection().type == "Text"))
			return;
		var tr = td.parentNode;
		if (tr.rowIndex < 3)
			return;
		if ((self.options.ShowEndTime == 0) && (td.id.substr(0, td.id.length -3) == "ap"))
		{
			self.clickRow(td, e);
			var dest = self.getViewSelRows();
			index = dest[0].rowIndex;
			if (courseGrid[index].index >= 0)
			{
				EditCourseTime(td, e);
				return false;
			}
		}
		if (rMenuEnable == false)
			return;
		self.clickRow(td, e);
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
		var dest = self.getViewSelRows();
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
				"<div style=width:260px><span style=width:100px>�Ͽ�ʱ��</span><span node=" + index + " class=Inline_BeginTime style=width:100px>" + b + "</span></div>" +
				"<div style=width:260px><span style=width:100px>�¿�ʱ��</span><span node=" + index + " class=Inline_EndTime style=width:100px>" + e + "</span></div>";
		}
		EditCourseTimeBox.setPopObj(tag);
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

	function getClipItem (nType)
	{
		for (var x = 0;  x < clip.length; x++)
		{
			clip[x].item = "<img src=../pic/flow_bs_manage.png>" + self.getCourseName(clip[x]) + "-" + clip[x].Syllabuses_teacher_name;
			clip[x].nType = nType;
		}
		return clip;
	}
	
	function LoadPlaceOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
		roomtree.setdata(json.data, json.head);
	}
	
	function NoteChange(obj)
	{
		var index = obj.parentNode.parentNode.rowIndex;
		if (index == undefined)
			index = obj.parentNode.parentNode.parentNode.rowIndex;
		var y = SetCourseObj(index);
//		self.setCell(index, "Note", obj.innerText);
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
		self.DisEditor();
		if (self.options.ShowEndTime == 0)	//����ʾ���
			self.setCell(index, "ap", self.getDateAP(obj.innerText));
		SetMode(3);
	}

	function roomChange(obj)
	{
		var index = obj.parentNode.parentNode.rowIndex;
		var o = self.getChild();
		var y = SetCourseObj(index);
		self.setCell(index, "ClassRoom", obj.innerText);
		o.courseObj[y].Syllabuses_ClassRoom = obj.innerText;
		var item = roomtree.getTreeItem();
		if ((typeof item == "object") && (item.item == obj.innerText))
			o.courseObj[y].Syllabuses_ClassRoom_id = item.ID;
		SetMode(3);
	}

	function AssistInfoChange(obj)
	{
		var index = obj.parentNode.parentNode.rowIndex;
		var y = SetCourseObj(index);
		SetMode(3);
		if ((event.shiftKey) && (courseObj[y].AssistInfo != ""))
			obj.innerText = courseObj[y].AssistInfo + "," + obj.innerText;
		var o = self.getChild();
		o.courseObj[y].AssistInfo = obj.innerText;
	}

	function AssistManChange(obj)
	{
		var index = obj.parentNode.parentNode.rowIndex;
		if (index == undefined)
			index = obj.parentNode.parentNode.parentNode.rowIndex;
		var y = SetCourseObj(index);
		if (obj.innerText == "����Ա��")
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
	
	function CourseChange(obj)
	{
		var tr = $.jcom.findParentObj(obj, document.body, "TR");
		if (tr == undefined)
			return;
		var index = tr.rowIndex;
		var o = self.getChild();
		if (typeof subjectObj == "object")
		{
			for (var x = 0; x < subjectObj.length; x++)
			{
				if (obj.innerText == subjectObj[x].Subject_name)
				{
					obj.style.style = o.cfg.CourseNoSaveStyle;
					if (self.options.ShowAssistMan == 2)
					{
						$("#Field_Teacher", tr).html(subjectObj[x].Teacher_name);
						$("#Field_Teacher", tr).css({color:"black"});
					}
					else
						self.setCell(index, "Teacher", subjectObj[x].Teacher_name);
					y = SetCourseObj(index);
					o.courseObj[y].Syllabuses_course_id = 0;
					o.courseObj[y].Syllabuses_course_name = subjectObj[x].Subject_name;
					o.courseObj[y].Syllabuses_subject_id = subjectObj[x].Subject_id;
					o.courseObj[y].Syllabuses_subject_name = subjectObj[x].Subject_name;
					o.courseObj[y].Syllabuses_teacher_id = subjectObj[x].Teacher_id;
					o.courseObj[y].Syllabuses_teacher_name = subjectObj[x].Teacher_name;
					o.courseObj[y].Syllabuses_Department = subjectObj[x].Department_name;
					SetMode(3);
					return;
				}
			}
		}
		if (obj.innerText == "")
		{
//			if (window.confirm("�Ƿ�ɾ�����еĿγ�?"))
				DeleteCourseItem(true, index);
			return;
		}

		var y = SetCourseObj(index);
		if (o.courseObj[y].Syllabuses_subject_name == obj.innerText)
			return;
		if (self.options.ShowRed == 1)
			obj.style.color = o.cfg.CourseWarningColor;
		
		var oCss = $.jcom.getStyleObjFromString(o.cfg.CourseNoSaveStyle);
		$(obj).css(oCss);
		o.courseObj[y].Syllabuses_subject_id = 0;
		o.courseObj[y].Syllabuses_course_id = 0;
		o.courseObj[y].Syllabuses_subject_name = obj.innerText;
		o.courseObj[y].Syllabuses_course_name = obj.innerText;
		SetMode(3);
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
		var data = cfg.tree.getdata();	//���ȴ��������ѧ�ƻ���ƥ��
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
		var o = self.getChild();
		$.get(o.cfg.coursePath + "?SearchSubject=1&SeekKey=" + value, {}, CourseSearchOK);
		return val;
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
		var o = self.getChild();
		if (value != "")
			$.get(o.cfg.coursePath + "?SearchTeacher=1&SeekKey=" + value, {}, TeacherSearchOK);
		return "";
	}

	function AttachEditor()
	{
		self.attachEditor("Course", courseEdit, false);
		self.attachEditor("Teacher", teacherEdit, false);
		self.attachEditor("Note", noteEdit, false);
		self.attachEditor("BeginTime", timeEdit, false);
		self.attachEditor("EndTime", timeEdit, false);
		self.attachEditor("ClassRoom", roomEdit, false);
		self.attachEditor("AssistInfo", AssistInfoEdit, false);
		self.attachEditor("AssistMan", AssistManEdit, false);
	}
	
	function EditCourseSubject()
	{
		var rows = self.getViewSelRows();
		if (rows.length == 0)
			return alert("����ѡ��γ�");
		var index = rows[0].rowIndex;
		var o = self.getChild();
		var	y = o.courseGrid[index].index;
		if (y == -1)
			return alert("�������ÿγ̣�û�пγ̲��ܱ༭��");
		var url = "../fvs/CPB_Subject_form.jsp";
		if (o.courseObj[y].Syllabuses_subject_id > 0)
			url += "?DataID=" + o.courseObj[y].Syllabuses_subject_id;
		else
			url +="?TeacherID=" + o.courseObj[y].Syllabuses_teacher_id;
		var result = showModalDialog(url, o.courseObj[y].Syllabuses_subject_name, "dialogWidth:850px;dialogHeight:600px;resizable:1;center:1");
		if ((typeof result == "string") && (result.substr(0, 2) == "OK"))
		{
			var ss = result.split("|||");
			self.setCell(index, "Course", {value: ss[2], style:o.cfg.CourseNoSaveStyle});
			self.setCell(index, "Teacher", {value:ss[5], color:"black"});
			y = SetCourseObj(index);
			o.courseObj[y].Syllabuses_subject_id = ss[1];
			o.courseObj[y].Syllabuses_subject_name = ss[2];
			o.courseObj[y].Syllabuses_teacher_id = ss[4];
			o.courseObj[y].Syllabuses_teacher_name = ss[5];
			o.courseObj[y].Syllabuses_Department = ss[3];
			SetMode(3);
		}
	}
	
	function TeacherChange(obj)
	{
		var index = obj.parentNode.parentNode.rowIndex;
		if (index == undefined)
			index = obj.parentNode.parentNode.parentNode.rowIndex;
		var o = self.getChild();
		if (typeof teacherObj == "object")
		{
			for (var x = 0; x < teacherObj.length; x++)
			{
				if (obj.innerText == teacherObj[x].Teacher_name)
				{
					obj.style.color = "black";
					y = SetCourseObj(index);
					o.courseObj[y].Syllabuses_teacher_id = teacherObj[x].Teacher_id;
					o.courseObj[y].Syllabuses_teacher_name = teacherObj[x].Teacher_name;
					o.courseObj[y].Syllabuses_Department = teacherObj[x].TeacherUnit;
					var cell = self.getCell(index, "Course");
					$(cell.firstChild).trigger("mousedown");
					$.get(o.cfg.coursePath + "?GetTeachSubject=1&TeacherID=" + teacherObj[x].Teacher_id, {}, CourseSearchOK);
					SetMode(3);
					return;
				}
			}
		}
		var y = SetCourseObj(index);
		if (self.options.ShowRed == 1)
			obj.style.color = o.cfg.CourseWarningColor;
		else
			obj.style.color = "black";
		o.courseObj[y].Syllabuses_teacher_id = 0;
		o.courseObj[y].Syllabuses_teacher_name = obj.innerText;
		SetMode(3);
	}

	function EditTeacher()
	{
		var rows = self.getViewSelRows();
		if (rows.length == 0)
			return alert("����ѡ��γ�");
		var index = rows[0].rowIndex;
		var	y = courseGrid[index].index;
		if (y == -1)
			return alert("�������ÿγ̣�û�пγ̲��ܱ༭��");
		var url = "../fvs/CPB_Teacher_form1.jsp";
		if (courseObj[y].Syllabuses_teacher_id > 0)
			url += "?DataID=" + courseObj[y].Syllabuses_teacher_id;
		var result = showModalDialog(url, courseObj[y].Syllabuses_teacher_name, "dialogWidth:850px;dialogHeight:600px;resizable:1;center:1");
		if ((typeof result == "string") && (result.substr(0, 2) == "OK"))
		{
			var ss = result.split(":");
			self.setCell(index, "Teacher", {value: ss[3] + " " + ss[2], color:"gray"});
			y = SetCourseObj(index);
			courseObj[y].Syllabuses_teacher_id = ss[1];
			courseObj[y].Syllabuses_teacher_name = ss[2];
			courseObj[y].Syllabuses_Department = ss[3];
			SetMode(3);
		}
	}

	function SetCourseObj(index)
	{
		var o = self.getChild();
		var x = o.courseGrid[index].index;
		if (x >= 0)
		{
		 	if (o.courseObj[x].EditFlag == 0)
				o.courseObj[x].EditFlag = 2;	//Update Flag;
		}
		else
		{
			x = self.NewCourseObjItem();
			o.courseGrid[index].index = x;
			if (o.courseGrid[index].DateValue == undefined)
				alert("ERRR");
			o.courseObj[x].Syllabuses_date = o.courseGrid[index].DateValue;
			
			if (typeof o.courseGrid[index].BeginTime == "object")
				o.courseObj[x].BeginTime = $.jcom.GetDateTimeString(o.courseObj[x].Syllabuses_date, 1) + " " + o.courseGrid[index].BeginTime.ex;
			else
				o.courseObj[x].BeginTime = o.courseObj[x].Syllabuses_date + " " + o.courseGrid[index].BeginTime;
			var e = o.courseGrid[index].EndTime;
			if (typeof e == "object")
				e = e.value;
			o.courseObj[x].EndTime = $.jcom.GetDateTimeString(o.courseObj[x].Syllabuses_date, 1) + " " + e;
		}
		return x;
	}

	this.NewCourseObjItem = function()
	{
		var o = self.getChild();
		x = o.courseObj.length;
		o.courseObj[x] = {EditFlag:1, Syllabuses_id:0,Syllabuses_subject_id:0, Syllabuses_subject_name:"", Syllabuses_activity_id:0,
			Syllabuses_activity_name:"", Syllabuses_course_id:0, Syllabuses_course_name:"", Syllabuses_Department:"",
			Syllabuses_teacher_id:0, Syllabuses_teacher_name:"", Syllabuses_ClassRoom_id:0, Syllabuses_ClassRoom:"", 
			Syllabuses_bak:"", AssistMan:"", AssistInfo:""};		//EditFlag=1,Insert Flag
		return x;	
	};

	function SaveDoc()
	{
	var data = "", deldata = "", cnt = 0;

		var o = self.getChild();
		if (self.options.ShowRed == 1)
		{
			for (var x = 0; x < o.courseObj.length; x++)
			{
				if (o.courseObj[x].Syllabuses_subject_id == 0)
				{
					if (window.confirm("��Ҫ��ʾ���γ̱��е���Щ�γ�δ����ר���(�γ̱��������ݣ�������Ҫ�������棬����Ҫ����ר�����ٱ��棿\n���Ҫ�������棬���ȷ����\n���Ҫ����ר�����ٱ��棬���ȡ������˫�����������ݣ����γ̼���ר��⡣")== true)
						break;
					return;
				}
			}
		}
		for (var x = 0; x < o.courseObj.length; x++)
		{
			switch (o.courseObj[x].EditFlag)
			{
			case 1:			//insert
			case 2:			//update
				if (data != "")
					data += "&";
				data += "index=" + x + "&Syllabuses_id=" + o.courseObj[x].Syllabuses_id +
					"&Syllabuses_date=" + o.courseObj[x].Syllabuses_date + 
					"&BeginTime=" + o.courseObj[x].BeginTime +
					"&EndTime=" + o.courseObj[x].EndTime +
					"&Syllabuses_course_id=" + o.courseObj[x].Syllabuses_course_id + 
					"&Syllabuses_subject_id=" + o.courseObj[x].Syllabuses_subject_id + 
					"&Syllabuses_subject_name=" + escString(o.courseObj[x].Syllabuses_subject_name) +
					"&Syllabuses_activity_id=" + o.courseObj[x].Syllabuses_activity_id +
					"&RefID=" + o.courseObj[x].RefID +
					"&Syllabuses_activity_name=" + escString(o.courseObj[x].Syllabuses_activity_name) +
					"&Syllabuses_Department=" + escString(o.courseObj[x].Syllabuses_Department) +
					"&Syllabuses_teacher_id=" + o.courseObj[x].Syllabuses_teacher_id +
					"&Syllabuses_teacher_name=" + escString(o.courseObj[x].Syllabuses_teacher_name) +
					"&Syllabuses_ClassRoom_id=" + o.courseObj[x].Syllabuses_ClassRoom_id +
					"&Syllabuses_ClassRoom=" + escString(o.courseObj[x].Syllabuses_ClassRoom) +
					"&AssistMan=" + escString(o.courseObj[x].AssistMan) +
					"&AssistInfo=" + escString(o.courseObj[x].AssistInfo) +
					"&Syllabuses_bak=" + escString(o.courseObj[x].Syllabuses_bak);
				cnt ++;
				break;
			case 3:			//delete
				if (o.courseObj[x].Syllabuses_id > 0)
				{
					if (deldata != "")
						deldata += ",";
					deldata += o.courseObj[x].Syllabuses_id;
				}
				break;
			}
		}
		$.jcom.Ajax(o.cfg.coursePath + "?SaveCourse=1&term_id=" + o.classObj.Term_id + "&ClassID=" + o.classObj.Class_id + "&Num=" + cnt, 
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
		var o = self.getChild();
		for (var x = 0; x < items.length; x++)
		{
			if (items[x].result == -1)
				err ++;
			else
			{
				o.courseObj[items[x].index].Syllabuses_id = items[x].id;
				o.courseObj[items[x].index].EditFlag = 0;
				var index = getCourseGridIndex(o, items[x].index);
				self.TransCourseItem(o.courseObj[items[x].index], o.courseGrid[index]);
				self.setCell(index, "Course", o.courseGrid[index].Course);
				self.setCell(index, "Teacher", o.courseGrid[index].Teacher);
				self.setCell(index, "AssistMan", o.courseGrid[index].AssistMan);
				self.setCell(index, "ClassRoom", o.courseGrid[index].ClassRoom);
			}
		}
		
		for (var x = 0; x < o.courseObj.length; x++)
		{
			if (o.courseObj[x].Syllabuses_id > 0)
				o.courseObj[x].Syllabuses_id = 0;
		}
		if (self.options.SaveToCourseOption == 1)
		{
			$.get("../fvs/CPB_Class_Course.jsp",{Ajax:1,CopyfromSyllabuses:1,DataID:o.classObj.Class_id}, SaveOKReload);
			return;
		}
		SaveOKReload();
	}

	function getCourseGridIndex(o, index)
	{
		for (var x = 0; x < o.courseGrid.length; x++)
		{
			if (o.courseGrid[x].index == index)
				return x;
		}
	}

	function SaveOKReload()
	{
		SetMode(2);
//		LoadCourse(classObj.Class_id);	
	}
	
	this.OuterReload = function()
	{
		
		self.RefreshCourse();
		SetMode(3);
	}

	function SetMode(mode)
	{
		if (cfg.EditMode != 1)
			return;
		switch (mode)
		{
		case 1:		//δ�򿪿α�
			break;
		case 2:		//�Ѵ򿪿α�δ�޸�
			$(window).off("beforeunload", SaveConfirm);
//			menubar.setDisabled("�༭", false);
			cfg.oMenu.setDisabled("����", true);
			break;
		case 3:		//�Ѵ򿪿α����޸�
			cfg.oMenu.setDisabled("����", false);
			$(window).on("beforeunload", SaveConfirm);
			if (AutoSaveCourse == 1)
				SaveDoc();
			break;
		}
	}

	function SaveConfirm()
	{
		event.returnValue="�γ̱������Ѹı�";
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
	
	this.loadMenu = function(oMenu)
	{
		cfg.oMenu = oMenu;
		var def = [{item:"����",action:CutCourseItem},{item:"����", action:CopyCourseItem}, {item:"ճ��", action:PasteCourseItem},{item:"ѡ��", action:menuApplyCourse},{},
				{item:"����һ��", action:menuInsertCourseLine},{item:"���һ��", action:menuDeleteCourseItem},{item:"�༭ѡ��",child:[{item:"����������еĿγ�", action:ViewClipCourse},{},
					{item:"����ѡ���еĿγ�Ϊ������", action:SetCommCourse}, {item:"����ѡ���еĿγ�Ϊѡ�޿�", action:SetFreeCourse},{item:"���ÿγ�ʱ��", action:SetCourseLen},
					{item:"ʹ��������Ϊ�ſ�ʱ��", action:SetnDayUse, img:"../pic/flow_end.png"},{},{item:"ɾ����ѧǰ�ͽ�ҵ��Ŀγ�", action:DeleteOldCourse},{},
					{item:"����α��ͻ���", action:CheckClassCourse},{item:"��ѧ�ڿα��ͻ�ܼ��", action:CheckCourse},{item:"��ͻ�������", action:ManageConflict},{},
					{},{item:"���ƽ�ѧ�ƻ�", action:RunTeachPlan},{item:"ʹ�ý�ѧ�ƻ��Զ��ſ�", action:AutoPlanCourse},{item:"���α����ݸ��Ƶ���ѧ�ƻ���", action:CopyfromSyllabuses},{},					
					{item:"�Զ�����༭�еĿα�", action:ToggleAutoSave},{item:"��ʹ�ñ�ϵͳ�ض�����Ҽ��˵�", img:"", action:SetRightMenu}]},
				{item:"����",child:[{item:"���ļ��е���",action:FileInput},{item:"�����α�EXCEL�ļ�",action:self.OutExcel},{item:"�����α�Word�ļ�",action:self.OutWord},{},
					{item:"����ר��",action:NewSubject},{item:"�༭ר��������ѡר��",action:EditSubject},
					{item:"�༭�γ̱�����ѡר��",action:EditCourseSubject},{},
					{item:"����ʦ��",action:NewTeacher},{item:"�༭�γ̱�����ѡʦ��",action:EditTeacher},{item:"У���ڿ��˲���ʦ�ʿ�ƥ��",action:CheckTeachers},{},
					{item:"����ǰ�������뵽������", action:null},{item:"��������ʹ����������", action:StartPlaceReq}, {item:"�ӳ������������л�ȡ������Ϣ", action:GetPlaceFromFlow},{},
					{item:"������ʷ��¼", action:CourseEditHis}]},
				{item:"����", child:[{item:"���ÿγ̱�״̬��Ȩ��", action:SetCourseState},{item:"����Ĭ�����¿�ʱ��", action:SetCourseTime}, 
					{item:"������ؽ�ѧ��ֹʱ��", action:SetOuterDate},{item:"���ýڼ��ջ�ǽ�ѧ��", action:SetHolyDay},{},
	      			{item:"��������ѡ��", action:OptionSet}]},{},
				{item:"����", action:SaveDoc, disabled:true},{item:"�˳��༭", action:ExitEditor}	
			];
		oMenu.reload(def);
		return;
	};
	
	function ExitEditor()
	{
		if (window.confirm("�Ƿ�ȷ��Ҫ�˳��༭ģʽ?") == false)
			return;
		self.DisEditor(true);
		self.waiting();
		self.onExit();
	}
	
	this.onExit = function ()
	{
	}
	
	function FileInput()
	{
		var obj = new CourseImport(self);
		obj.run();
	}
	
	function menuApplyCourse()
	{
		ApplyCourse();
	}
	
	function menuInsertCourseLine()
	{
		InsertCourseLine(1);
	}
	
	function menuDeleteCourseItem()
	{
		DeleteCourseItem();
	}

	function SetRightMenu(obj, item)
	{
		if (item.img == "")
		{
			rMenuEnable = false;
			item.img = "../pic/flow_end.png";
		}
		else
		{
			item.img = "";
			rMenuEnable = true;
		}
	}
	
	function SetnDayUse(obj, item)
	{
		var c = self.getChild("cfg");
		if (item.img == "")
		{
			c.nDayUse = 3;
			item.img = "../pic/flow_end.png";
		}
		else
		{
			c.nDayUse = 2;
			item.img = "";
		}
		self.RefreshCourse();
	}

	this.onLoadCourseReady = function(jsondata)
	{
		for (var key in jsondata.DefaultClassCourseTime)	//�༶Ĭ�����¿�ʱ��
			self.options[key] = jsondata.DefaultClassCourseTime[key];
		ConflictObj = jsondata.Conflict;
		StateRight = jsondata.StateRight;
			
		CheckClassCourseOK(jsondata.Conflict, true);
			
		EmptyClip();
			//�ø��༶��صĽ�ѧ�ƻ�ʧЧ���ȴ����¼���...
		var o = self.getChild();
		cfg.tree.SetRes(self.options.ActivityOption, o.classObj.Class_id, o.cfg.coursePath);
	};
	
	
	function CheckClassCourseOK(data, flag)
	{
		var o = self.getChild();
		if (flag != true)
		{
			ConflictObj = $.jcom.eval(data);
			if (typeof ConflictObj == "string")
				return alert(ConflictObj);
			for (var x = 0; x < o.courseObj.length; x++)
				o.courseObj[x].ConflictInfo = "";
		}

		for (var y = 0; y < ConflictObj.length; y++)
		{
			for (var x = 0; x < o.courseObj.length; x++)
			{
				if (o.courseObj[x].Syllabuses_id == ConflictObj[y].CourseID)
				{
					o.courseObj[x].nConflict = ConflictObj[y].nConflict;
					o.courseObj[x].ConflictInfo += "\n" + ConflictObj[y].Info;
				}
			}
		}
		if (flag != true)
		{
			CheckClassCourse();
			if (ConflictObj.length > 0)
				self.RefreshCourse();
		}
	}
		
	function EmptyClip()
	{
		clip = [];
		if (typeof clipview == "object")
			clipview.reload(clip);
		var obj = cfg.tree.getNodeObj("nType", 5);
		cfg.tree.reloadNode(obj, true);	
	}

	function CopyCourseItem()
	{
		var dest = self.getViewSelRows();
		if (dest.length == 0)
			return alert("���ڿγ̱���ѡ��һ����");
//		clip = [];
//		var y = 0;
		var y = clip.length;
		var o = self.getChild();
		for (var x = 0; x < dest.length; x++)
		{
			var index = dest[x].rowIndex;
			var index = o.courseGrid[dest[x].rowIndex].index;
			if (index >= 0)
				clip[y ++] = $.jcom.initObjVal(o.courseObj[index], {});
		}
		if (typeof clipWin == "object")
			clipview.reload(clip);
		var obj = cfg.tree.getNodeObj("nType", 5);
		cfg.tree.reloadNode(obj, true);	
		return true;
	}

	function CutCourseItem()
	{
		if (CopyCourseItem() == true)
			DeleteCourseItem(true);
	}

	function PasteCourseItem()
	{
		var dest = self.getViewSelRows();
		
		var o = self.getChild();
		var index = 0;
		if (dest.length > 0)
			index = dest[0].rowIndex;
		else
			index = skipCourseGrid(index);
		var flag = true;
		if (dest.length == 0)
			flag = false;
		if ((clip.length > 1) && (dest.length > 0))
			skipflag = window.confirm("�������еĿγ̳���һ��������Ҫ����ճ������ǰλ�ã�����Ҫճ�����α�Ŀհ�λ�ã�\n\n��ȷ����ճ������ǰλ�ã���ȡ����ճ�����հ�λ��");
		
		for (var y = 0; y < clip.length; y++)
		{
			if (flag == false)
			{
				index = skipCourseGrid(index);
				if (index >= o.courseGrid.length)
					break;
			}
			var x = SetCourseObj(index);
			o.courseObj[x].Syllabuses_activity_id = clip[y].Syllabuses_activity_id;
			o.courseObj[x].Syllabuses_activity_name = clip[y].Syllabuses_activity_name;
			o.courseObj[x].Syllabuses_subject_id = clip[y].Syllabuses_subject_id;
			o.courseObj[x].Syllabuses_subject_name = clip[y].Syllabuses_subject_name;
			o.courseObj[x].Syllabuses_course_id = clip[y].Syllabuses_course_id;
			o.courseObj[x].Syllabuses_course_name = clip[y].Syllabuses_course_name;		
			o.courseObj[x].Syllabuses_Department = clip[y].Syllabuses_Department;
			o.courseObj[x].Syllabuses_teacher_id = clip[y].Syllabuses_teacher_id;
			o.courseObj[x].Syllabuses_teacher_name = clip[y].Syllabuses_teacher_name;
			o.courseObj[x].Syllabuses_ClassRoom_id = clip[y].Syllabuses_ClassRoom_id;
			o.courseObj[x].Syllabuses_ClassRoom = clip[y].Syllabuses_ClassRoom;
			o.courseObj[x].Syllabuses_bak = clip[y].Syllabuses_bak;
			
			self.TransCourseItem(o.courseObj[x], o.courseGrid[index]);
			
			self.setCell(index, "Course", o.courseGrid[index].Course);
			self.setCell(index, "Teacher", o.courseGrid[index].Teacher);
			self.setCell(index, "AssistMan", o.courseGrid[index].AssistMan);
			self.setCell(index, "AssistInfo", o.courseGrid[index].AssistInfo);
			self.setCell(index, "ClassRoom", o.courseGrid[index].ClassRoom);
			self.setCell(index, "Note", o.courseGrid[index].Note);
			
			index ++;
		}
		if (self.options.DelePasteItemOption == 1)
		{
			clip.splice(0, y);
			var obj = cfg.tree.getNodeObj("nType", 5);
			cfg.tree.reloadNode(obj, true);
		}
		SetMode(3);
	}

	function DeleteCourseItem(bDisHint, index)
	{
		if (index == undefined)
		{
			var dest = self.getViewSelRows();
			if (dest.length == 0)
				return alert("���ڿγ̱���ѡ��һ����");
			for (var x = 0; x < dest.length; x++)
			{
				DeleteCourseItem(bDisHint, dest[x].rowIndex);
				bDisHint = true;
			}
			return;
		}
		var o = self.getChild();
		
		var x = o.courseGrid[index].index;
		if (x < 0)
			return;
		if (( x>= 0) && (o.courseObj[x].EditFlag == 0))
		{
			if (bDisHint != true)
			{
				if (window.confirm("�Ƿ�ɾ��ѡ�еĿγ�?") == false)
					return;
			}
		}
			
		self.TransCourseItem({BeginTime: o.courseObj[x].BeginTime, EndTime: o.courseObj[x].EndTime, 
			Syllabuses_activity_id:0, Syllabuses_subject_id:0, Syllabuses_subject_name:"", Syllabuses_course_id:0, Syllabuses_course_name:"", 
			Syllabuses_teacher_id:"", Syllabuses_teacher_name:"",
			nConflict:0, AssistMan:"", AssistInfo:"", Syllabuses_ClassRoom:"", Syllabuses_bak:""}, o.courseGrid[index]);

		self.setCell(index, "Course", o.courseGrid[index].Course);
		SetViewCell(index, "Teacher", o.courseGrid[index].Teacher);
		SetViewCell(index, "ClassRoom", "");
		SetViewCell(index, "AssistMan", "");
		self.setCell(index, "AssistInfo", "");
		self.setCell(index, "Note", "");
		
		o.courseGrid[index].index = -1;
		o.courseObj[x].EditFlag = 3;
		SetMode(3);
	}

	function SetViewCell(index, field, value)
	{
		var obj = self.getCell(index, field, value);
		if (obj == undefined)
			return;
		if (typeof value == "object")
			value = value.value;
		obj.firstChild.innerHTML = value;
		obj.firstChild.style.color = "black";
		obj.firstChild.title = "";
	}


	function InsertCourseLine(nType)
	{
		var dest = self.getViewSelRows();
		if (dest.length == 0)
			return alert("���ڿγ̱���ѡ��һ����");
		index = dest[0].rowIndex;

		var o = self.getChild();
		var b = o.courseGrid[index].BeginTime;
		if (typeof b == "object")
			b = b.ex;
		var e = o.courseGrid[index].EndTime;
		if (typeof e == "object")
			e = e.value;
		b = o.courseGrid[index].DateValue + " " + b;
		b = $.jcom.makeDateObj(b);
		b.setTime(b.getTime() + 1000 * 60 * 10);
		b = $.jcom.GetDateTimeString(b, 3);
		e = o.courseGrid[index].DateValue + " " + e;
		var item = self.InsertCourseItem(index + 1);
		self.TransCourseGrid({BeginTime: b, EndTime: e, Syllabuses_activity_id:0, Syllabuses_subject_id:0, Syllabuses_subject_name:"",Syllabuses_course_id:0, Syllabuses_course_name:"",
			Syllabuses_teacher_id:"", Syllabuses_teacher_name:"", nConflict:0, AssistMan:"", AssistInfo:"", Syllabuses_ClassRoom:"", Syllabuses_bak:"", nType:nType}, index + 1);
		self.reload(o.courseGrid);
		SetMode(3);
	}

	function skipCourseGrid(index)
	{
		var o = self.getChild();
		for (var x = index; x < o.courseGrid.length; x++)
		{
			if (o.courseGrid[x].index >= 0)
				continue;
			var t = o.courseGrid[x].BeginTime;
			if (typeof t == "object")
				t = t.ex;
			var d = $.jcom.makeDateObj(o.courseGrid[x].DateValue + " " + t);
			if ((self.options.SkipHolidayOption == 1) && self.isHoliday(d))
				continue;
			if (self.getDateAP($.jcom.GetDateTimeString(d, 3)) == "����")
				continue;
			return x;
		}
		return o.courseGrid.length;
	}
	
	function NewSubject()
	{
		var rows = self.getViewSelRows();
		if (rows.length > 0)
		{
			var index = rows[0].rowIndex;
			var	y = courseGrid[index].index;
			if ((y >= 0) && (courseObj[y].Syllabuses_subject_id == 0))
				return EditCourseSubject();
		}
		window.open("../fvs/CPB_Subject_form.jsp", "����ר��", "width=800,height=600,resizable=1");
	}

	function EditSubject()
	{
		var	item = tree.getTreeItem();
		if (typeof item != "object")
				return alert("����ѡ��ר��");
		if (item.Subject_id == undefined)
			return alert("��ѡ��ר�⣬����ר����ࡣ");
		window.open("../fvs/CPB_Subject_form.jsp?DataID=" + item.Subject_id, "_blank", "width=800,height=600,resizable=1");
	}

	function NewTeacher()
	{
		var rows = self.getViewSelRows();
		if (rows.length > 0)
		{
			var index = rows[0].rowIndex;
			var	y = courseGrid[index].index;
			if ((y >= 0) && (courseObj[y].Syllabuses_teacher_id == 0))
				return EditTeacher();
		}
		window.open("../fvs/CPB_Teacher_form1.jsp", "��������ʦ��", "width=800,height=600,resizable=1");
	}

	function FindSubject()
	{
	}

	function CopyfromSyllabuses()
	{
		if (window.confirm("ֻ�в�ͨ����ѧ�ƻ�ֱ���� �εĿγ̲���Ҫ���ƣ��Ƿ������") == false)
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
		if (window.confirm("��ɾ���γ̱����ڱ��࿪ʼʱ��ͽ���ʱ������Ŀγ̣��Ƿ�ȷ����\n\n(��ʾ����Щ�γ�ͨ������Ϊ�޸��˱���Ŀ�ʼ�ͽ���ʱ���������ȷʵ��Ҫ��Щ�γ̣�Ӧ���ƶ������ʵ�ʱ��λ��.)") == false)
			return;
		var o = self.getChild();
		$.get(o.cfg.coursePath, {DeleteOldCourse:1, ClassID:o.classObj.Class_id}, function (result) {alert(result);self.LoadCourse(o.classObj.Class_id);});
	}

	function AutoPlanCourse()
	{
		var rootItems = cfg.tree.getdata();
		if (rootItems[0].child == null)
		{
			var obj = cfg.tree.getNodeObj("nType", 1);	//��ѧ�ƻ�
			cfg.tree.reloadNode(obj, true);
			return alert("��ʾ�����ڽ�ѧ�ƻ�������ɺ��ٵ��ô˹��ܡ�");
		}
		var aUnit = rootItems[0].child;
		beUnit = aUnit[aUnit.length - 1].child;
		aUnit.splice(0, 0, {child:[]});
		for (var x = 0; x < beUnit.length; x++)
		{
			if (beUnit[x].Course_name == "����ʽ")
			{
				aUnit[0].child = beUnit.splice(x, 1);
				break;
			}
		}
		var index = 0;
		for (var x = 0; x < aUnit.length; x++)
			index = AutoPlanUnit(aUnit[x], index);
		
		var obj = cfg.tree.getNodeObj("nType", 1);
		cfg.tree.reloadNode(obj, true);
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

	function ApplyCourse(item)
	{
		if (typeof item != "object")
		{
			item = cfg.tree.getTreeItem();
			if (typeof item != "object")
				return alert("����ѡ����Ŀ");
		}
		var dest = self.getViewSelRows();
		if (dest.length == 0)
			return alert("���ڿγ̱���ѡ��һ����");

		var index = dest[0].rowIndex;
		var o = self.getChild();
		var b = o.courseGrid[index].BeginTime;
		if (typeof b == "object")
		{
			b = b.ex;
			if (b == undefined)
				b = "8:30";
		}
		var d = $.jcom.makeDateObj(o.courseGrid[index].DateValue + " " + b);
		if (self.isHoliday(d))
		{
			if (window.confirm("����ѡ����Ƿǹ����գ��Ƿ�Ҫ�ſΣ�") == false)
				return;
		}
		var x = o.courseGrid[index].index;
		if ( x >= 0)
		{
			if (window.confirm("�Ѿ��пγ��ˣ����Ƿ�ȷ��Ҫ�滻�����еĿγ�?") == false)
				return;
		}
		var obj;
		switch (item.nType)
		{
		case 11:		//��ѧ�ƻ��еĽ�ѧ��Ԫ
			AutoPlanUnit(item, index);
			break;
		case 12:		//��ѧ�ƻ��еĿγ�
			if (item.Subject_id > 0)
				obj = {CourseID: item.Course_id, CourseName:item.Course_name, ActID: 0, ActName:"", SubjID:item.Subject_id, SubjName:item.Course_name, 
					TeacherID:item.Teacher_id, TeacherName:item.Teacher_name, t:item.Course_time};
			else// if (item.Activity_id > 0)
				obj = {CourseID: item.Course_id, CourseName:item.Course_name, ActID: item.Activity_id, ActName:item.Course_name, SubjID:0, SubjName:"",
					TeacherID:item.Teacher_id, TeacherName:item.Teacher_name, t:item.Course_time};
			break;
		case 13:		//��ѧ�ƻ��еĽ�ѧ��Ԫ�е�ģ��
			AutoPlanUnit(item, index);
			break;
		case 32:		//ר����е�ר��		
			obj = {CourseID: 0, CourseName:item.Subject_name, ActID: 0, ActName:"", SubjID:item.Subject_id, SubjName:item.Subject_name,
				TeacherID:item.Teacher_id, TeacherName:item.Teacher_name, t:0};
			var rootItems = cfg.tree.getdata();
			obj.CourseID = FindCourseIDFromPlan(rootItems[0].child, obj);
			break;
		case 41:		//��ѧ�
			obj = {CourseID: 0, CourseName:item.Activity_name, ActID: item.Activity_id, ActName:item.Activity_name, SubjID:0, SubjName:"",
				TeacherID:0, TeacherName:item.Activity_Principals, t:0};
			break;
		case 51:		//������
			obj = {CourseID: item.Syllabuses_course_id, CourseName:item.Syllabuses_course_name, ActID:item.Syllabuses_activity_id, ActName:item.Syllabuses_activity_name, 
				SubjID:item.Syllabuses_subject_id, SubjName:item.Syllabuses_subject_name, TeacherID:item.Syllabuses_teacher_id, TeacherName:item.Syllabuses_teacher_name,
				room:item.Syllabuses_ClassRoom, roomid:item.Syllabuses_ClassRoom_id, bak:item.Syllabuses_bak, assist:item.AssistMan, ainfo:item.AssistInfo, t:0};
			break;
		default:
			return alert("δ֪������" + item.nType);
			break;
		}
		self.DisEditor();
		if (typeof obj == "object")
		{
			ApplyItem(index, obj);
			if ((item.nType == 51) && (self.options.DelePasteItemOption == 1))	//������
			{
				for (var y = 0; y < clip.length; y++)
				{
					if (item == clip[y])
					{
						clip.splice(y, 1);
						var oClip = cfg.tree.getNodeObj("nType", 5);
						tree.reloadNode(oClip, true);
						break;
					}
				}
			}
		}
		SetMode(3);	
	}

	function FindCourseIDFromPlan(items, obj)
	{
		if (items == null)
			return 0;
		for (var x = 0; x < items.length; x++)
		{
			if (typeof items[x].child == "object")
			{
				var id = FindCourseIDFromPlan(items[x].child, obj);
				if (id > 0)
					return id;
			}
			if (items[x].Subject_id == obj.SubjID)
				return items[x].Course_id;
		}
		return 0;
	}

	function ApplyItem(index, obj)
	{
		if  ((obj.t == 0) || (obj.t == undefined))
			obj.t = 0.5;
		var o = self.getChild();
		for (var z = 0; z < obj.t; z += 0.5)
		{
			var x = SetCourseObj(index);
			o.courseObj[x].Syllabuses_activity_id = obj.ActID;
			o.courseObj[x].Syllabuses_activity_name = obj.ActName;
			o.courseObj[x].Syllabuses_subject_id = obj.SubjID;
			o.courseObj[x].Syllabuses_subject_name = obj.SubjName;
			o.courseObj[x].Syllabuses_course_id = obj.CourseID;
			o.courseObj[x].Syllabuses_course_name = obj.CourseName;
			o.courseObj[x].Syllabuses_teacher_id = obj.TeacherID;
			o.courseObj[x].Syllabuses_teacher_name = obj.TeacherName;
			if ((typeof obj.room == "undefined") && (o.classObj.ClassRoom_id != ""))
			{
				obj.roomid = o.classObj.ClassRoom_id;
				if (o.classObj.ClassRoom == undefined)
				{
					var item = roomtree.getKeyItem("ID", obj.roomid);
					o.classObj.ClassRoom = "";
					if (typeof item == "object")
						o.classObj.ClassRoom = item.Name;
				}
				obj.room = o.classObj.ClassRoom;
			}
			
			if ((typeof obj.room != "undefined") && (o.courseObj[x].Syllabuses_ClassRoom == ""))
			{
				o.courseObj[x].Syllabuses_ClassRoom = obj.room;
				o.courseObj[x].Syllabuses_ClassRoom_id = obj.roomid;
			}
			if ((typeof obj.bak != "undefined") && (o.courseObj[x].Syllabuses_bak == ""))
				o.courseObj[x].Syllabuses_bak = o.bak;

			if ((typeof obj.assist != "undefined") && (o.courseObj[x].AssistMan == ""))
				o.courseObj[x].AssistMan = obj.assist;
			if ((typeof obj.ainfo != "undefined") && (o.courseObj[x].AssistInfo == ""))
					o.courseObj[x].AssistInfo = obj.ainfo;
			
			self.TransCourseItem(o.courseObj[x], o.courseGrid[index]);
			self.setCell(index, "Course", o.courseGrid[index].Course);
			SetViewCell(index, "Teacher", o.courseGrid[index].Teacher);
			SetViewCell(index, "ClassRoom", o.courseGrid[index].ClassRoom);
			SetViewCell(index, "AssistMan", o.courseGrid[index].AssistMan);
			self.setCell(index, "AssistInfo", o.courseGrid[index].AssistInfo);
			self.setCell(index, "Note", o.courseGrid[index].Note);

			index = skipCourseGrid(index);
			if (index >= o.courseGrid.length)
				break;
		}
	}

	var clipWin, clipview;
	function ViewClipCourse()
	{
		if (clipWin == undefined)
		{
			clipWin = new $.jcom.PopupWin("<div id=ClipCourse style=width:100%;height:100%></div>", 
					{title:"�������еĿγ��б�", width:600, height:480,position:"fixed"});
			var aFace = {x:0,y:30,node:1,a:{id:"clipTop"},b:{id:"clipBottom"}};
			var oLayer = new $.jcom.Layer($("#ClipCourse")[0], aFace, {border:"1px dotted gray"});
			var clipmenu = new $.jcom.CommonMenubar([{item:"ɾ��", action:DeleClip}, {item:"���", action:EmptyClip}, {item:"ճ�����α�", action:PasteCourseItem}], $("#clipTop")[0]);
			var head = [{FieldName:"Syllabuses_subject_name", TitleName:"����", nWidth:380, nShowMode:1},
			    		{FieldName:"Syllabuses_teacher_name", TitleName:"�ڿ���", nWidth:60, nShowMode:1},
			    		{FieldName:"Syllabuses_bak", TitleName:"��ע", nWidth:80, nShowMode:1}];
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
		var obj = cfg.tree.getNodeObj("nType", 5);
		tree.reloadNode(obj, true);	
	}

	function SetCourseLen()
	{
		var dest = self.getViewSelRows();
		if (dest.length == 0)
			return alert("���ڿγ̱���ѡ��γ�");
		
		var o = self.getChild();
		var index = o.courseGrid[dest[0].rowIndex].index;
		if (index < 0)
			return alert("���ڿγ̱���ѡ��γ�");
		var tag = "<select id=CurrentCourseLenSel><option value=0.5>����</option><option value=1>һ��</option><option value=1.5>һ���</option><option value=2>����</option><option value=2.5>�����</option><option value=3>����</option></select>";
		$.jcom.OptionWin("��ǰ�γ�ʱ��:" + tag ,"���ÿγ�ʱ��", [{item:"ȷ��", action:SetCourseLenRun}]);
		var len = GetCourseLen(o.courseObj[index], o) / 2;
		$("#CurrentCourseLenSel").val(len);	
	}

	function GetCourseLen(item, o)
	{
		var cnt = 0;
		for (var x = 0; x < o.courseObj.length; x++)
		{
			if (o.courseObj[x].EditFlag == 3)
				continue;
			if (((item.Syllabuses_subject_id > 0) && (o.courseObj[x].Syllabuses_subject_id == item.Syllabuses_subject_id))
				|| ((item.Syllabuses_activity_id > 0) && (o.courseObj[x].Syllabuses_activity_id == item.Syllabuses_activity_id)))
				cnt ++;
		}
		return cnt;
	}

	function SetCourseLenRun(obj, win)
	{
		var dest = self.getViewSelRows();
		var o = self.getChild();
		var index = o.courseGrid[dest[0].rowIndex].index;
		var oldlen = GetCourseLen(o.courseObj[index], o) / 2;
		var newlen = $("#CurrentCourseLenSel").val();
		win.close();
		if (newlen == oldlen)
			return;
		self.DisEditor();
		var item = o.courseObj[index];
		if (newlen > oldlen)
		{
			var item = {CourseID: item.Syllabuses_course_id, CourseName:item.Syllabuses_course_name, ActID:item.Syllabuses_activity_id, ActName:item.Syllabuses_activity_name, 
					SubjID:item.Syllabuses_subject_id, SubjName:item.Syllabuses_subject_name, TeacherID:item.Syllabuses_teacher_id, TeacherName:item.Syllabuses_teacher_name,
					room:item.Syllabuses_ClassRoom, roomid:item.Syllabuses_ClassRoom_id, bak:item.Syllabuses_bak, assist:item.AssistMan, ainfo:item.AssistInfo, t:newlen - oldlen};
			index = skipCourseGrid(index);
			if (index >= o.courseGrid.length)
				return alert("����ʱ��ʧ�ܣ�����������");
			ApplyItem(index, item);
		}
		else
		{
			var cnt = (oldlen - newlen) * 2;
			for (var x = o.courseGrid.length - 1; x >= o.cfg.nTitleRows; x--)
			{
				var y = o.courseGrid[x].index; 
				if (y < 0)
					continue;
				if (((item.Syllabuses_subject_id > 0) && (o.courseObj[y].Syllabuses_subject_id == item.Syllabuses_subject_id))
					|| ((item.Syllabuses_activity_id > 0) && (o.courseObj[y].Syllabuses_activity_id == item.Syllabuses_activity_id)))
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

	var setCommWin, commSetclassView;
	function SetCommCourse()
	{
		var dest = self.getViewSelRows();
		if (dest.length == 0)
			return alert("���ڿγ̱���ѡ��γ�");
		var o = self.getChild();
		var index = o.courseGrid[dest[0].rowIndex].index;
		if (index < 0)
			return alert("���ڿγ̱���ѡ��γ�");
		if (o.courseObj[index].Syllabuses_id == 0)
			return alert("���ȱ��浱ǰ�γ̺������ù�����");

		if (setCommWin == undefined)
		{
		 	setCommWin = new $.jcom.PopupWin("<div id=ClassDiv style=width:100%;height:420px;overflow:auto;></div><div style=float:left><input id=DelOldCommCourseFlag type=checkbox checked>���ͬʱ��ԭ�еĿγ�</div>" +
				"<div align=right style=width:100%;height:30px><input id=CommonCourseRun type=button value=���� >&nbsp;&nbsp;</div>", 
				{title:"ѡ��Ҫʹ�ù����γ̵İ�", width:400, height:480, mask:50,position:"fixed"});
			var h = [{FieldName:"Class_Name", TitleName:"�������", nWidth:325, nShowMode:1},
			    	    {FieldName:"Option", TitleName:"ѡ��", nWidth:60, nShowMode:1}];
			setCommWin.close = setCommWin.hide;
			$("#CommonCourseRun").on("click", RunSetCommonCourse);
			commSetclassView = new $.jcom.GridView(document.all.ClassDiv, h, [], {}, {footstyle:4});
		}
		else
			setCommWin.show();
		$.get(o.cfg.coursePath, {GetClassByTime:1, Term_id: o.classObj.Term_id, Class_id:o.classObj.Class_id, Time:o.courseObj[index].BeginTime}, SetCommonCourseDlg);
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
			return alert("����ѡһ���ࡣ");
		if (window.confirm("�����ڰ���ѡ�γ�����Ϊ�����Σ����ı���ѡͬ�ڰ�εĿα��Ƿ�ȷ��?") == false)
			return;

		var dest = self.getViewSelRows();
		var o = self.getChild();
		var index = o.courseGrid[dest[0].rowIndex].index;
		$.get(o.cfg.coursePath, {SetCommonCourse:1, Syllabuses_id:o.courseObj[index].Syllabuses_id, DelFlag:DelFlag, ClassIDs:IDs}, SetCommonCourseOK);
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

	function CheckCourse()
	{
		if (window.confirm("��ͻ��⽫��Ȿѧ�����пα��е��ڿ��ˡ������ˡ��ص�֮���Ƿ���ڳ�ͻ��������Ҫ�ķѽ϶��ʱ�䣬�Ƿ������") == false)
			return;
		var o = self.getChild();
		$.get(o.cfg.coursePath, {CheckCourse:1, ClassID:o.classObj.Class_id, Mode:1, TermID:o.classObj.Term_id}, CheckCourseOK);
	}


	function CheckCourseOK(data)
	{
		var	badCourseWin = new $.jcom.PopupWin("<div id=badCourse style=width:100%;height:100%></div>", 
				{title:"�α��ͻ�����", width:800, height:480,position:"fixed"});
		$("#badCourse").html(data);
		$("#badCourse").css("overflowY", "auto");
	}
		
	var conflictWin, conflictView;
	function CheckClassCourse()
	{
		if (conflictWin == undefined)
		{
			conflictWin = new $.jcom.PopupWin("<div id=conflictCourse style=width:100%;height:100%></div>", 
					{title:"����γ̳�ͻ�����(��ɫ�����ǳ�ͻ��)", width:640, height:480,position:"fixed"});
			var aFace = {x:0,y:30,node:1,a:{id:"conflictTop"},b:{id:"conflictBottom"}};
			var oLayer = new $.jcom.Layer($("#conflictCourse")[0], aFace, {border:"1px dotted gray"});
			var menu = new $.jcom.CommonMenubar([{item:"����ڿ���Ϊ����", nType:1, action:MarkConflictItem}, {item:"��Ǹ�����Ϊ����", nType:2, action:MarkConflictItem},
				{item:"��ǵص�Ϊ����", nType:3, action:MarkConflictItem}, {item:"�ٴμ��", action:RunCheckClassCourse}], $("#conflictTop")[0]);
			var head = [{FieldName:"Time", TitleName:"ʱ��", nWidth:80, nShowMode:1},{FieldName:"ClassName", TitleName:"���", nWidth:120, nShowMode:1},
				{FieldName:"CourseName", TitleName:"����", nWidth:220, nShowMode:1},{FieldName:"Teacher", TitleName:"�ڿ���", nWidth:60, nShowMode:1},
				{FieldName:"AssistMan", TitleName:"������", nWidth:60, nShowMode:1}, {FieldName:"ClassRoom", TitleName:"�ص�", nWidth:80, nShowMode:1}];
			conflictView = new $.jcom.GridView($("#conflictBottom")[0], head, [], {bodystyle:2, footstyle:4});
			conflictWin.close = conflictWin.hide;
			conflictView.dblclickRow = ToConflictCourse;
		}
		else
			conflictWin.show();
		var items = [];
		var o = self.getChild();
		for (var x = 0; x < ConflictObj.length; x++)
		{
			var ss = ConflictObj[x].Info.split("|");
			items[x] = {CourseID:ConflictObj[x].CourseID, Time: ss[1], ClassName: ss[0], CourseName:ss[2], Teacher: ss[3], AssistMan: ss[4],ClassRoom: ss[5]};
			if ((ConflictObj[x].nConflict & 1) > 0)		//�ص��ͻ
				items[x].ClassRoom = {value:items[x].ClassRoom, color:o.cfg.CourseConflictColor};		
			if ((ConflictObj[x].nConflict & 2) > 0)		//��ʦ��ͻ
				items[x].Teacher = {value:items[x].Teacher, color:o.cfg.CourseConflictColor};
			if ((ConflictObj[x].nConflict & 4) > 0)		//�����˳�ͻ
				items[x].AssistMan = {value:items[x].AssistMan, color:o.cfg.CourseConflictColor};
		}
		conflictView.reload(items, {nPage:1, PageSize:9999, Records:items.length, Order:"", bdesc:0});
	}

	function ToConflictCourse()
	{
		var item = conflictView.getItemData();
		if (SkipToCourseItem(1, item.CourseID) == false)
			alert("δ�ҵ��α��ж�Ӧ�Ĳ�����ͻ�Ŀγ�" + item.CourseID)
	}

	function MarkConflictItem(obj, item)
	{
		alert(item.item);
		nType = item.nType;
		alert(nType);
		var item = conflictView.getItemData();
		if (item == undefined)
			return alert("����ѡ��һ����ͻ��¼");
		
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
		var o = self.getChild();		
		$.get(o.cfg.coursePath + "?MarkConflictItem=1&nType=" + nType + "&Value=" + v, {}, function (data){alert(data);});
	}

	function ManageConflict()
	{
		function RemoveConflictExItem()
		{
			var item = tree.getTreeItem();
			if (item == undefined)
				return alert("����ѡ��������");
			if (typeof item.child == "object")
				return alert("��ѡ������");
			var Teacher_id = 0;
			if (item.Teacher_id > 0)
				Teacher_id = item.Teacher_id;
			var roomID = 0;
			if (item.ID > 0)
				roomID = item.ID
			var o = self.getChild();		
			$.get(o.cfg.coursePath, {GetConflictEx:1, Teacher_id: Teacher_id, roomID: roomID}, fun);
		};
		var win = new $.jcom.PopupWin("<div id=conflictEx style=width:100%;height:100%></div>", 
				{title:"��ͻ�������", width:640, height:480,position:"fixed"});
		var aFace = {x:0,y:30,node:1,a:{id:"conflictExTop"},b:{id:"conflictExBottom"}};
		var oLayer = new $.jcom.Layer($("#conflictEx")[0], aFace, {border:"1px dotted gray"});
		var menu = new $.jcom.CommonMenubar([{item:"ȥ������", action:RemoveConflictExItem}], $("#conflictExTop")[0]);
		var tree = new $.jcom.TreeView($("#conflictExBottom")[0], []);
		tree.waiting();
		var fun = function (data)
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				return alert(json);
			var data = [{item:"�ڿ��˻򸨽�������", child:json.ExTeachers},{item:"�ص�����", child:json.ExClassRooms}];
			tree.setdata(data);
		}
		var o = self.getChild();
		$.get(o.cfg.coursePath, {GetConflictEx:1}, fun);
	}

	function RunCheckClassCourse()
	{	
		conflictView.waiting();
		var o = self.getChild();
		$.get(o.cfg.coursePath, {CheckCourse:1, ClassID:o.classObj.Class_id, Mode:2, BeginTime:o.classObj.Class_BeginTime, EndTime:o.classObj.Class_EndTime}, CheckClassCourseOK);
	}

	function SetCourseTime()
	{
		var o = self.getChild();
		var dlg = new CourseTimeSetup(self.options, o.cfg.coursePath);
		dlg.show();
	}

	function SetOuterDate()
	{
		var o = self.getChild();
		var dlg = new OuterDateSetup(o.classObj, o.cfg.coursePath);
		dlg.show();
	}
	
	function SetHolyDay()
	{
		var o = self.getChild();
		var dlg = new HolidaySetup(o.holiItems, o.classObj, o.cfg.coursePath);
		dlg.show();
	}

	function OptionSet()
	{
		var dlg = new OptionSetup(self);
		dlg.show();
	}
	
	function StartPlaceReq()
	{
		var o = self.getChild();
		$.get(o.cfg.coursePath, {SearchFlow:1, ClassID:o.classObj.Class_id}, PlaceFlowReq);
	}

	function PlaceFlowReq(data)
	{
		var o = eval(data);
		var href = "../fvs/FlowPlaceReq.jsp?InstName=�ޱ���&ClassID=" + classObj.Class_id;
		if (o[0].StepID > 0)
			href = "../fvs/FlowPlaceReq.jsp?RunMode=12&StepID=" + o[0].StepID;
		window.open(href, "����ʹ������", "width=640,height=480,resizable=1,scrollbars=1");
	}

	function GetPlaceFromFlow()
	{
		var o = self.getChild();
		$.get(o.cfg.coursePath, {GetFlowData:1, ClassID:o.classObj.Class_id}, GetFlowPlaceData);
	}

	function GetFlowPlaceData(data)
	{
		var editflag = 0;
		var roomObj = eval(data);
		var o = self.getChild();
		for (var x = 0; x < roomObj.length; x++)
		{
			for (var y = o.cfg.nTitleRows; y < o.courseGrid.length; y++)
			{
				var index = o.courseGrid[y].index;
				if (index >= 0)
				{
					if (roomObj[x].SyllabusID == o.courseObj[index].Syllabuses_id)
					{
						if (o.courseObj[index].Syllabuses_ClassRoom_id != roomObj[x].PlaceID)
						{
							o.courseObj[index].Syllabuses_ClassRoom_id = roomObj[x].PlaceID;
							o.courseObj[index].Syllabuses_ClassRoom = roomObj[x].Name;
							o.courseObj[index].EditFlag = 2;	//Update Flag;
							self.setCell(y, "ClassRoom", roomObj[x].Name);
							editflag = 1;
						}
					}
				}
			}
		}
		if (editflag == 1)
			SetMode(3);
	}	
	init();
}

function CourseTimeSetup(options, jsp)
{
	var CourseTimeWin;
	if (typeof CourseTimeSetup.instance == "object")
		return CourseTimeSetup.instance;
	
	CourseTimeSetup.instance = this;
	this.show = function ()
	{
		CourseTimeWin.show();
	};
	
	function init()
	{
		CourseTimeWin = new $.jcom.PopupWin("<div id=freeeCourse style=width:100%;height:100%;padding:8px;>" +
			"Ĭ�������Ͽ�ʱ��&nbsp;<input name=AMBegin value=" + options.AMBegin + "><br>Ĭ�������¿�ʱ��&nbsp;<input name=AMEnd value=" + options.AMEnd +
			"><br>Ĭ�������Ͽ�ʱ��&nbsp;<input name=PMBegin value=" + options.PMBegin + "><br>Ĭ�������¿�ʱ��&nbsp;<input name=PMEnd value=" + options.PMEnd +
			"><br>Ĭ�������Ͽ�ʱ��&nbsp;<input name=EVBegin value=" + options.EVBegin + "><br>Ĭ�������¿�ʱ��&nbsp;<input name=EVEnd value=" + options.EVEnd +
			"><br><center><input type=button value=����Ϊ��������  name=ConfirmCourseTime><input type=button value=����ΪȫУ���� name=ConfirmCourseTime></center></div>", 
				{title:"����Ĭ�����¿�ʱ��", width:320, height:240,position:"fixed"});
		$("input[name='ConfirmCourseTime']").on("click", ConfirmCourseTime);		
		CourseTimeWin.close = CourseTimeWin.hide;
	}
	
	function ConfirmCourseTime(e)
	{
		var nType = 2;
		if (e.target.value == "����Ϊ��������")
			nType = 1;
		options.AMBegin = $("input[name='AMBegin']").val();
		options.AMEnd = $("input[name='AMEnd']").val();
		options.PMBegin = $("input[name='PMBegin']").val();
		options.PMEnd = $("input[name='PMEnd']").val();
		options.EVBegin = $("input[name='EVBegin']").val();
		options.EVEnd = $("input[name='EVEnd']").val();
			
		var fun = function (data)
		{
			alert(data);
			CourseTimeWin.hide();
			view.RefreshCourse();
		}
		$.jcom.Ajax(jsp + "?SaveDefaultCourseTime=1&ClassID=" + classObj.Class_id + "&nType=" + nType + "&AMBegin=" + options.AMBegin + "&AMEnd=" + options.AMEnd +
			"&PMBegin=" + options.PMBegin + "&PMEnd=" + options.PMEnd + "&EVBegin=" + options.EVBegin + "&EVEnd=" + options.EVEnd, true, "", fun);
	}
	init();
}

function OuterDateSetup(classObj, jsp)
{
	var OuterDateWin, dateEdit, OuterDateNum = 1;
	if (typeof OuterDateSetup.instance == "object")
		return OuterDateSetup.instance;
	
	OuterDateSetup.instance = this;
	this.show = function ()
	{
		OuterDateWin.show();
	};
	
	function init()
	{
		OuterDateWin = new $.jcom.PopupWin("<div id=freeeCourse style=width:100%;height:100%;padding:8px;>" +
			"��ؽ�ѧ��ʼʱ��&nbsp;<input name=OuterBegin value=" + classObj.OuterBegin + "><br>��ؽ�ѧ����ʱ��&nbsp;<input name=OuterEnd value=" +
			classObj.OuterEnd + "><br><center id=SetControl><input type=button value=���� id=AddOuterDate>&nbsp;&nbsp;<input type=button value=ȷ�� id=ConfirmOuterDate></center></div>", 
				{title:"������ؽ�ѧ��ֹʱ��", width:320, height:120,position:"fixed"});
		OuterDateWin.close = OuterDateWin.hide;
		dateEdit = new $.jcom.DynaEditor.Date(300, 200);
		dateEdit.attach($("input[name='OuterBegin']")[0]);
		dateEdit.attach($("input[name='OuterEnd']")[0]);
		$("#AddOuterDate").on("click", AddOuterDate);
		$("#ConfirmOuterDate").on("click", ConfirmOuterDate);
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
			return alert("��ؽ�ѧ��ʱ���̫��");
		if (typeof b != "string")
			b = "";
		if (typeof e != "string")
			e = "";
		$("#SetControl").before("��ؽ�ѧ��ʼʱ��&nbsp;<input name=OuterBegin" + OuterDateNum + " value='" + b + "'><br>��ؽ�ѧ����ʱ��&nbsp;<input name=OuterEnd" +
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
			view.RefreshCourse();
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
		$.get(jsp + "?SaveOuterDate=1&ClassID=" + classObj.Class_id + tag + "]", {}, fun);
	}
	init();
}

function HolidaySetup(holiItems, classObj, jsp)	//�ڼ���������, ��������
{
	var HolidayWin, holiview, holiC1, holiC2;
		
	if (typeof HolidaySetup.instance == "object")
		return HolidaySetup.instance;
	
	HolidaySetup.instance = this;
	this.show = function ()
	{
		HolidayWin.show();
	};

	function init()
	{
		HolidayWin = new $.jcom.PopupWin("<div id=HolidayDiv style=height:100%;overflow:hidden;></div>", 
			{title:"�ڼ��ջ�ǽ�ѧ������", width:640, height:520,position:"fixed"});
		var aFace = {x:0,y:260,node:1,a:{child:{x:310,y:0,node:3,a:{id:"Cel1"},b:{id:"Cel2"}}},b:{child:{x:560,y:0,node:2,a:{id:"HoliList"},b:{id:"Control"}}}};
		var oLayer = new $.jcom.Layer($("#HolidayDiv")[0], aFace);
		var head = [{FieldName:"THoliday", TitleName:"����", nWidth:80, nShowMode:1},
	    		{FieldName:"HolidayName", TitleName:"����", nWidth:160, nShowMode:1},
	    		{FieldName:"nType", TitleName:"�ڼ�������", nWidth:80, nShowMode:1, Quote:"(1:�ڼ���,2:��Ϣ��,3:������)"},
	    		{FieldName:"nDateType", TitleName:"ʱ������", nWidth:60, nShowMode:1, Quote:"(1:ȫ��,2:����,3:����)"},
	    		{FieldName:"PublicOption", TitleName:"��������", nWidth:100, nShowMode:1, Quote:"(1:�������ڱ���,2:���������а�)"}];
		holiview = new $.jcom.GridView($("#HoliList")[0], head, holiItems, {}, {footstyle:4});
		var holidayNameEdit = new $.jcom.DynaEditor.Edit();
		holiview.attachEditor("HolidayName", holidayNameEdit);
		var nTypeEdit = new $.jcom.DynaEditor.List("1:�ڼ���,2:��Ϣ��,3:������", 200, 200, 1);
		holiview.attachEditor("nType", nTypeEdit);
		var nDateTypeEdit = new $.jcom.DynaEditor.List("1:ȫ��,2:����,3:����", 200, 200, 1);
		holiview.attachEditor("nDateType", nDateTypeEdit);
		var publicOptionEdit = new $.jcom.DynaEditor.List("1:�������ڱ���,2:���������а�", 200, 200, 1);
		holiview.attachEditor("PublicOption", publicOptionEdit);
	
		HolidayWin.close = HolidayWin.hide;
		$("#Control").css({paddingLeft: "0px"});
		$("#Control").html("<br><br><br><br><input type=button value=����  id=AddHoliday><br><input type=button value=ɾ�� id=DelHoliday><br>" +
			"<input type=button value=���� id=OrderHoliday><br><input type=button value=���� id=SaveHoliday()><br><br>");
		$("#AddHoliday").on("click", AddHoliday);
		$("#DelHoliday").on("click", DelHoliday);
		$("#OrderHoliday").on("click", OrderHoliday);
		$("#SaveHoliday").on("click", SaveHoliday);
		$("#Cel2").css({borderLeft: "1px solid gray", paddingLeft: "0px"});
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
			return alert("ɾ��ǰҪ��ѡ��һ�С�");
		if (window.confirm("�Ƿ�Ҫɾ����ǰѡ����У�") == false)
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
			if (items[x].PublicOption == 2)	//���������а�
			{
				tag += "&THoliday=" + d + "&HolidayName=" + items[x].HolidayName + "&nDateType=" + items[x].nDateType + "&nType=" + items[x].nType;
			}
			else
			{
				tag1 += sp + "{THoliday:" + d + ", HolidayName:\"" + items[x].HolidayName + "\", nDateType:" + items[x].nDateType + ", nType:" + items[x].nType + "}";
				sp = ",";
			}
		}
		$.get(jsp + "?SaveHoliday=1&ClassID=" + classObj.Class_id + tag + "&ClassHoliday=" + tag1 + "]", {}, fun);
	}
	init();
}

function ManyClassCourseSetup(classObj, jsp)
{
	var ManyCourseWin, ManyCourseOptionView, menuItem;
	if (typeof ManyClassCourseSetup.instance == "object")
		return ManyClassCourseSetup.instance;
	
	ManyClassCourseSetup.instance = this;
	
	this.show = function ()
	{
			ManyCourseWin.show();
	};
	
	function init()
	{
		var BeginTime = "", EndTime = "";
		if (typeof classObj == "object")
		{
			BeginTime = $.jcom.GetDateTimeString(classObj.Class_BeginTime, 1);
			EndTime = $.jcom.GetDateTimeString(classObj.Class_EndTime, 1);
		}
		else if (courseObj.length > 0)
		{
			BeginTime = $.jcom.GetDateTimeString(courseObj[0].Syllabuses_date, 1);
			EndTime = $.jcom.GetDateTimeString(courseObj[courseObj.length - 1].Syllabuses_date, 1);
		}
		if (ManyCourseWin == undefined)
		{
			ManyCourseWin = new $.jcom.PopupWin("<p style=width:100%;height:30px><span>���⣺</span><span><input type=Text style=width:400px value=���οα� id=ManyCourseTitle></span></p>" +
				"<p style=width:100%;height:30px>��ѵʱ�䣺<span id=ClassBeginTime class=DateEditor style=width:70px>" + BeginTime + 
				"</span> ��  <span id=ClassEndTime class=DateEditor style=width:70px>" + EndTime + "</span>&nbsp;<input type=button value=������ѡʱ����ڵİ�� id=GetManyClass></p>" +
				"<div id=ClassCourseDiv style=width:100%;height:420px;overflow:auto;></div><div style=float:left><input type=button id=RemoveManyClassOne value=�Ƴ�>&nbsp;" +
				"<input type=button value=���� id=UpManyClassOne>&nbsp;<input type=button value=���� id=DownManyClassOne>&nbsp;</div>" +
				"<div align=right style=width:100%;height:30px><input type=button value=��� id=RunSetManyClassOption>&nbsp;&nbsp;</div>", 
				{title:"���οα�ʱ��Ͱ������", width:580, height:560, mask:50,position:"fixed"});
			var h = [{FieldName:"ClassCode", TitleName:"��α��", nWidth:80, nShowMode:1},
			         {FieldName:"Class_Name", TitleName:"�������", nWidth:260, nShowMode:1},
			         {FieldName:"Class_BeginTime", TitleName:"��ʼʱ��", nWidth:90, nShowMode:1},
			         {FieldName:"Class_EndTime", TitleName:"����ʱ��", nWidth:90, nShowMode:1}];
			ManyCourseWin.close = ManyCourseWin.hide;
			ManyCourseOptionView = new $.jcom.GridView($("#ClassCourseDiv")[0], h, [], {}, {footstyle:4});
			var dtEdit = new $.jcom.DynaEditor.Date(300, 300);
			$("#GetManyClass").on("click", GetManyClass);
			$("#RemoveManyClassOne").on("click", RemoveManyClassOne);
			$("#UpManyClassOne").on("click", UpManyClassOne);
			$("#DownManyClassOne").on("click", DownManyClassOne);
			$("#RunSetManyClassOption").on("click", RunSetManyClassOption);
			dtEdit.attach($("#ClassBeginTime")[0]);
			dtEdit.attach($("#ClassEndTime")[0]);
		}
	}
	
	function GetManyClass()
	{
		if (($("#ClassBeginTime").text() == "") && ($("#ClassEndTime").text() == ""))
			return alert("��ʼʱ��ͽ��ʱ�䲻��Ϊ��");
		$.get(jsp, {GetClassByBETime:1, ClassBeginTime:$("#ClassBeginTime").text(), ClassEndTime:$("#ClassEndTime").text()}, GetManyClassOK);
	}
	
	function RemoveManyClassOne()
	{
		var row = ManyCourseOptionView.getSelRow();
		if (row == undefined)
			return alert("�Ƴ�ǰҪ��ѡ��һ�С�");
		ManyCourseOptionView.deleteRow(row);
		
	}
	
	function UpManyClassOne()
	{
		var row = ManyCourseOptionView.getSelRow();
		if (row == undefined)
			return alert("��ѡ��һ����");
	
		var node = parseInt(row.node);
		if (node == 0)
			return alert("�ѵ���һ������������");
		var p = ManyCourseOptionView.deleteRow(node);
		ManyCourseOptionView.insertRow(p, node - 1);
		ManyCourseOptionView.select(node - 1);
	}
	
	function DownManyClassOne()
	{
		var row = ManyCourseOptionView.getSelRow();
		if (row == undefined)
			return alert("��ѡ��һ����");
	
		var node = parseInt(row.node);
		var data = ManyCourseOptionView.getData();
		if (node == data.length - 1)
			return alert("�ѵ����һ������������");
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
			return alert("����Ҫѡһ����");
		if (data.length > 10)
			return alert("���ѡ10����");
		ManyCourseWin.hide();
//		$("#TitleSpan").html(item.item);
		ClassIDs = data[0].Class_id;
		for (var x = 1; x < data.length; x++)
			ClassIDs += "," + data[x].Class_id;
		ManyClassCourseSetup.instance.setupOK(ClassIDs, $("#ClassBeginTime").text(), $("#ClassEndTime").text(),{Title:$("#ManyCourseTitle").val()});
	}

	this.setupOK = function (ClassIDs, beginTime, endTime, option)
	{
	};
	
	init();
}

function OptionSetup(courseView)
{
	var OptionWin;
	OptionSetup.courseView = courseView;
	if (typeof OptionSetup.instance == "object")
	{
		initData();
		return OptionSetup.instance;
	}	
	OptionSetup.instance = this;
	this.show = function ()
	{
		OptionWin.show();
	};
	
	function init()
	{
		OptionWin = new $.jcom.PopupWin("<div id=CourseOption style=width:100%;height:380px;padding:8px;>" +
				"</div><center><input type=button value=����Ϊ�������� onclick=ConfirmOption>&nbsp;<input type=button value=����ΪȫУ���� id=ConfirmOption></center>", 
					{title:"����ѡ��", width:420, height:480,position:"fixed"});
		OptionWin.close = OptionWin.hide;
		$("#ConfirmOption").on("click", ConfirmOption);
		initData();
	}
	
	function initData()
	{
		var cfg = OptionSetup.courseView.getChild("cfg");
		if (cfg.EditMode == 1)
			initEditable();
		else
			initReadOnly();
	}
	
	function initEditable()
	{
		var options = OptionSetup.courseView.options;
		$("#CourseOption").html("<span style=width:120px>������ʾ����ʽ</span><input name=DayShowMode type=radio checked value=1>��ʾ������&nbsp;<input name=DayShowMode type=radio value=10>��ʾ����" +
			"<br><span style=width:120px>������ʾ��ʽ</span><input name=DateFormat type=radio checked value=0>�������շָ�&nbsp;&nbsp;<input name=DateFormat type=radio value=1>��.�ָ�&nbsp;<input name=DateFormat type=radio value=2>��-�ָ�" +
			"<br><span style=width:120px>������ʾ��ʽ</span><input name=ShowWeek type=radio checked value=0>����ʾ&nbsp;&nbsp;<input name=ShowWeek type=radio value=1>������ʾ&nbsp;&nbsp;<input name=ShowWeek type=radio value=2>�����ںϲ���ʾ" +
			"<br><span style=width:120px>���¿�ʱ����ʾ��ʽ</span><input name=ShowEndTime type=radio checked value=0>����ʾ���&nbsp;<input name=ShowEndTime type=radio value=1>������ʾ&nbsp;<input name=ShowEndTime type=radio value=2>�ϲ���ʾ" +
			"<br><span style=width:120px>�Ƿ���ʾ������</span><input name=ShowAssistMan type=radio checked value=0>����ʾ&nbsp;<input name=ShowAssistMan type=radio value=1>������ʾ&nbsp;&nbsp;<input name=ShowAssistMan type=radio value=2>���ڿ��˺ϲ���ʾ" +
			"<br><span style=width:120px>�Ƿ���ʾ��������</span><input name=ShowAssistInfo type=radio checked value=0>����ʾ&nbsp;<input name=ShowAssistInfo type=radio value=1>��ʾ" +
			"<br><span style=width:120px>��ע��ʾ��ʽ</span><input name=ShowNote type=radio checked value=0>����ʾ&nbsp;&nbsp;<input name=ShowNote type=radio value=1>������ʾ&nbsp;&nbsp;<input name=ShowNote type=radio value=2>�����ݺϲ���ʾ" +
			"<hr><input name=ShowRed type=checkbox " + ((options.ShowRed == 1) ? "checked " : "") + "value=1>������ר���γ̺ͷ�ʦ�ʿ��ڿ���" +
			"<br><input name=ActivityOption type=checkbox " + ((options.ActivityOption == 1) ? "checked " : "") + "value=1>����ѧ���Ϊר�⴦��" +
			"<br><input name=SaveToCourseOption type=checkbox " + ((options.SaveToCourseOption == 1) ? "checked " : "") + "value=1>�γ̱�����Զ�ת����ѧ�ƻ�" +		
			"<br><input name=SaveInstantOption type=checkbox " + ((options.SaveInstantOption == 1) ? "checked " : "") + "value=1>�γ̱�����Զ���ͻ���" +
			"<br><input name=DelePasteItemOption type=checkbox " + ((options.DelePasteItemOption == 1) ? "checked " : "") + "value=1>�Զ�ɾ����ճ���ļ���������" +
			"<br><input name=SkipHolidayOption type=checkbox " + ((options.SkipHolidayOption == 1) ? "checked " : "") + "value=1>�Զ��ſ�ʱ�����ڼ���");
		if (options.DayShowMode == 10)
			$("input[name='DayShowMode']").eq(1).prop("checked", true);
		
		$("input[name='DateFormat']").eq(options.DateFormat).prop("checked", true);
		$("input[name='ShowWeek']").eq(options.ShowWeek).prop("checked", true);
		$("input[name='ShowEndTime']").eq(options.ShowEndTime).prop("checked", true);
		$("input[name='ShowAssistMan']").eq(options.ShowAssistMan).prop("checked", true);
		$("input[name='ShowAssistInfo']").eq(options.ShowAssistInfo).prop("checked", true);
		
		$("input[name='ShowNote']").eq(options.ShowNote).prop("checked", true);
	}
	
	function ConfirmOption(e)
	{
		var nType = 2;
		if (e.target.value == "����Ϊ��������")
			nType = 1;
		if (OptionSetup.EditMode != 1)
			return ReadOnlyConfirmOption(nType);
		
		var fields = ["DayShowMode", "DateFormat", "ShowWeek", "ShowEndTime", "ShowAssistMan", "ShowAssistInfo", "ShowNote"];
		for (var x = 0; x < fields.length; x++)
		{
			var o = $("input[name='" + fields[x] + "']");
			for (var y = 0; y < o.length; y ++)
			{
				if (o.eq(y).prop("checked"))
						options[fields[x]] = parseInt(o.eq(y).val());
			}
		}
	
		var fields = ["ShowRed", "ActivityOption", "SaveToCourseOption", "SaveInstantOption", "DelePasteItemOption", "SkipHolidayOption"];
		for (var x = 0; x < fields.length; x++)
		{
			if ($("input[name='" + fields[x] + "']").prop("checked"))
				options[fields[x]] = 1;
			else
				options[fields[x]] = 0;
		}
		SaveOption(nType);
	}
	
	function SaveOption(nType)
	{
		var options = OptionSetup.courseView.options;
		var fun = function (data)
		{
			if (data != "OK")
				alert(data);
			OptionWin.hide();
	
	//		AdjectViewHead();	
			OptionSetup.courseView.RefreshCourse();
		}
		if (event.ctrlKey)
			return fun("ע�⣺δ���棬����Ԥ��ʹ�á�");
		var tag = "";
		for (var key in options)
			tag += "&" + key + "=" + options[key];
		var cfg = OptionSetup.courseView.getChild("cfg");
		$.jcom.Ajax(cfg.coursePath + "?SaveFaceOption=1&ClassID=" + classObj.Class_id + "&nType=" + nType + "&EditMode=" + EditMode + tag, true, "", fun);	
	}
	
	function initReadOnly()
	{		
		var options = OptionSetup.courseView.options;
		$("#CourseOption").html("<span style=width:120px>������ʾ����ʽ</span><input name=DayShowMode type=radio checked value=1>��ʾ������&nbsp;<input name=DayShowMode type=radio value=10>��ʾ����" +
			"<br><span style=width:120px>������ʾ��ʽ</span><input name=DateFormat type=radio checked value=0>�������շָ�&nbsp;&nbsp;<input name=DateFormat type=radio value=1>��.�ָ�&nbsp;<input name=DateFormat type=radio value=2>��-�ָ�" +
			"<br><span style=width:120px>������ʾ��ʽ</span><input name=ShowWeek type=radio checked value=0>����ʾ&nbsp;&nbsp;<input name=ShowWeek type=radio value=1>������ʾ&nbsp;&nbsp;<input name=ShowWeek type=radio value=2>�����ںϲ���ʾ" +
			"<br><span style=width:120px>���¿�ʱ����ʾ��ʽ</span><input name=ShowEndTime type=radio checked value=0>����ʾ���&nbsp;<input name=ShowEndTime type=radio value=1>������ʾ&nbsp;<input name=ShowEndTime type=radio value=2>�ϲ���ʾ" +
			"<br><span style=width:120px>�Ƿ���ʾ������</span><input name=ShowAssistMan type=radio checked value=0>����ʾ&nbsp;<input name=ShowAssistMan type=radio value=1>������ʾ&nbsp;&nbsp;<input name=ShowAssistMan type=radio value=2>���ڿ��˺ϲ���ʾ" +
			"<br><span style=width:120px>�Ƿ���ʾ��������</span><input name=ShowAssistInfo type=radio checked value=0>����ʾ&nbsp;<input name=ShowAssistInfo type=radio value=1>��ʾ" +
			"<br><span style=width:120px>��ע��ʾ��ʽ</span><input name=ShowNote type=radio checked value=0>����ʾ&nbsp;&nbsp;<input name=ShowNote type=radio value=1>������ʾ&nbsp;&nbsp;<input name=ShowNote type=radio value=2>�����ݺϲ���ʾ" +
			"<hr><span style=width:160px>��Ϣ��δ�ſ�ʱ����ʾ��ʽ</span><input name=ShowWeekEnd type=radio checked value=0>����ʾ&nbsp;&nbsp;<input name=ShowWeekEnd type=radio value=1>�ϲ���ʾ&nbsp;&nbsp;<input name=ShowWeekEnd type=radio value=2>��ʾ" +
			"<br><span style=width:160px>�ڼ���δ�ſ�ʱ����ʾ��ʽ</span><input name=ShowHoliday type=radio checked value=0>����ʾ&nbsp;&nbsp;<input name=ShowHoliday type=radio value=1>�ϲ���ʾ&nbsp;&nbsp;<input name=ShowHoliday type=radio value=2>��ʾ" +
			"<br><span style=width:160px>��ؽ�ѧʱ����ʾ��ʽ</span><input name=ShowOuterTeach type=radio value=1>�ϲ���ʾ&nbsp;&nbsp;<input name=ShowOuterTeach type=radio value=2>������ʾ" +
			"<br><span style=width:160px>һ������Ͽγ���ʾ��ʽ</span><input name=ShowLongCourse type=radio value=1>�ϲ���ʾ&nbsp;&nbsp;<input name=ShowLongCourse type=radio value=2>������ʾ" +
			"<br><span style=width:160px>������δ�ſ�ʱ����ʾ����</span><input name=ShowWorkdayIdle value=''>");
		if (options.DayShowMode == 10)
			$("input[name='DayShowMode']").eq(1).prop("checked", true);
		var fields = ["DateFormat", "ShowWeek", "ShowEndTime", "ShowAssistMan", "ShowAssistInfo", "ShowNote", "ShowWeekEnd", "ShowHoliday", "ShowOuterTeach", "ShowLongCourse"];
		for (var x = 0; x < fields.length; x++)
		{
			var o = $("input[name='" + fields[x] + "']");
			o.eq(options[fields[x]]).prop("checked", true);
		}
		$("input[name='ShowWorkdayIdle']").val(options.ShowWorkdayIdle);
	}
	
	function ReadOnlyConfirmOption(nType)
	{
		var options = OptionSetup.courseView.options;
		var fields = ["DayShowMode", "DateFormat", "ShowWeek", "ShowEndTime", "ShowAssistMan", "ShowAssistInfo", "ShowNote", "ShowWeekEnd", "ShowHoliday", "ShowOuterTeach", "ShowLongCourse"];
		for (var x = 0; x < fields.length; x++)
		{
			var o = $("input[name='" + fields[x] + "']");
			for (var y = 0; y < o.length; y ++)
			{
				if (o.eq(y).prop("checked"))
						options[fields[x]] = parseInt(o.eq(y).val());
			}
		}
		options.ShowWorkdayIdle = $("input[name='ShowWorkdayIdle']").val();	
		SaveOption(nType);
	}
	init();
}


function CourseImport(view)
{
	var oImport;
	if (typeof CourseImport.instance == "object")
		return CourseImport.instance;
	CourseImport.instance = this;
	this.run = function ()
	{
		oImport.Import();
		
	};
	init();
	function init()
	{
			oImport = new $.jcom.OfficeImport();
			oImport.onFileSel = InportOfficeTable;
	//		oImport.onImport = self.onImport;
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
		var o = view.getChild();
		var d1 = $.jcom.makeDateObj(o.classObj.Class_BeginTime);
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
				index = getHeadIndex(cfg.HeadArray, "����");
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
		alert("������γ�" + count + "����");
		view.OuterReload();
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
		pos.tt = getHeadIndex(HeadArray, "���¿�ʱ��");
		pos.dt =  getHeadIndex(HeadArray, "����");
		pos.subject_name = getHeadIndex(HeadArray, "����");
		pos.teacher_name = getHeadIndex(HeadArray, "�ڿ���");
		pos.ClassRoom = getHeadIndex(HeadArray, "�ص�");
		pos.assistMan = getHeadIndex(HeadArray, "������");
		pos.assistInfo = getHeadIndex(HeadArray, "��������");
		pos.note = getHeadIndex(HeadArray, "��ע");
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
		var m = item.dt.indexOf("��");
		var d = item.dt.indexOf("��");
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
		var x = view.NewCourseObjItem();
		var o = view.getChild();
		o.courseObj[x].Syllabuses_date = $.jcom.GetDateTimeString(d2, 1);	
		o.courseObj[x].BeginTime = $.jcom.GetDateTimeString(o.courseObj[x].Syllabuses_date + " " + ttt[0], 3);
		o.courseObj[x].EndTime =  $.jcom.GetDateTimeString(o.courseObj[x].Syllabuses_date + " " + ttt[1], 3);
	
		o.courseObj[x].Syllabuses_subject_name = item.subject_name;
		o.courseObj[x].Syllabuses_course_name = item.subject_name;
		o.courseObj[x].Syllabuses_teacher_name = item.teacher_name;
		o.courseObj[x].Syllabuses_ClassRoom = item.ClassRoom;
		o.courseObj[x].AssistMan = item.assistMan;
		o.courseObj[x].AssistInfo = item.assistInfo;
		o.courseObj[x].Note = item.note;
		return 1;
	}
	
	var inportoptionwin, headSelEdit;
	function InportOption(cfg)
	{
		if (inportoptionwin == undefined)
		{
			inportoptionwin = new $.jcom.PopupWin("<div id=OffinceInportOption style=width:100%;height:100%></div>", {title:"����ѡ��", width:640, height:320, mask:50,position:"fixed"});
	//		headSelEdit = new $.jcom.DynaEditor.List("����,����,���¿�ʱ��,����,�ڿ���,�ص�,������,��������,��ע,�Ͽ�ʱ��,�¿�ʱ��,����,��", 200, 200);
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
		var seltxt = "<select id=HeadSel style='border:none;width:600px;font:normal normal normal 9pt ΢���ź�;'><option value=1>���� ���¿�ʱ�� ���� �ڿ��� �ص�</option><option value=2>���� ���� ���¿�ʱ�� ���� �ڿ��� �ص� ������ �������� ��ע</option></select>";
		var tag = "<div>Ҫ������ļ���<br>" + cfg.path + "</div><hr><div><span style=width:200px>ѡ��Ҫ����ڼ������:</span><input id=nDoc type=text value=1> ����" + cfg.count + "�����</div>" +
		"<div><span style=width:200px>�ӵڼ��п�ʼ����:</span><input id=nStartRow type=text value=2>ȥ����ͷ�ͱ�������Ŀα���ʼ��</div><hr><div>�α�ı�ͷ����˳��:</div><div>" + seltxt + 
		"</div><hr><div align=right><input id=RunOfficeInport type=button value=����>&nbsp;&nbsp;</div>";
		"</div><table id=OfficeColHead style=width:100%><tr>";
	//	for (var x = 0; x < cfg.dftCols.length; x++)
	//		tag += "<td>" + cfg.dftCols[x] + "</td>";
	//	tag += "</tr></table><hr><div align=right><input id=RunOfficeInport type=button value=����>&nbsp;&nbsp;</div>";
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
			alert("���ļ�����" + path);
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
		var o = view.getChild();
		var d1 = $.jcom.makeDateObj(o.classObj.Class_BeginTime);
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
		alert("������γ�" + count + "����");
		view.OuterReload();
	}
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
				{title:"У���ڿ��˲���ʦ�ʿ�ƥ��", width:640, height:480,position:"fixed"});
		var aFace = {x:0,y:30,node:1,a:{id:"CheckTeacherTop"},b:{id:"CheckTeacherBottom"}};
		var oLayer = new $.jcom.Layer($("#CheckTeacherDiv")[0], aFace, {border:"1px dotted gray"});
		var menu = new $.jcom.CommonMenubar([{item:"Ӧ��", action:ApplyCheckTeacher}, {item:"�༭", action:EditCheckTeachView}, {item:"����", action:SaveCheckTeach}], $("#CheckTeacherTop")[0]);

		var head = [{FieldName:"Teacher", TitleName:"ԭ�ڿ���", nWidth:120, nShowMode:1},
		    		{FieldName:"spTeacher", TitleName:"�ֽ����ڿ���", nWidth:120, nShowMode:1},
		    		{FieldName:"dbTeacherID", TitleName:"ʦ�ʿ���", nWidth:80, nShowMode:1},
		    		{FieldName:"dbTeacher", TitleName:"����", nWidth:60, nShowMode:1},
		    		{FieldName:"dbnType", TitleName:"����", nWidth:60, nShowMode:1},
		    		{FieldName:"dbUnit", TitleName:"��λ", nWidth:160, nShowMode:1}];
		checkTeacherView = new $.jcom.GridView($("#CheckTeacherBottom")[0], head, [], {bodystyle:2, footstyle:4});
		checkTeacherWin.close = checkTeacherWin.hide;
	}
	else
		checkTeacherWin.show();
	checkTeacherView.waiting("����У����ƥ���ڿ���...");
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
		view.OuterReload();
	}
}

function EditCheckTeachView()
{
}

function SaveCheckTeach()
{
}

function SetCourseState()
{
	if (classObj == undefined)
		return alert("û������Ȩ��");
	var setStatewin = new $.jcom.PopupWin("<div id=SetStateForm style=width:100%;height:100%></div>", 
			{title:"�γ̱�״̬��Ȩ��", mask:50, width:640, height:160, resize:0,position:"fixed"});
		var form = new $.jcom.FormView($("#SetStateForm")[0],
			[{CName:"�α�״̬", EName: "CourseState", InputType:3, Quote:"(0:δ����, 1:�༭��,10:�ѷ���)"},
			 {CName:"����༭����Ա", EName: "EditMembers", Relation:"!SelectCourseUser(this)"},
			 {CName:"�������ĵ���Ա", EName: "ViewMembers", Relation:"!SelectCourseUser(this)"}
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
