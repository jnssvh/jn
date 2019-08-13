function TermFilter(domobj, cfg)	//ѧ�ڼ���ѡ����
{
	var self = this;
	cfg = $.jcom.initObjVal( {title:["ѧ��"], itemimg:["#9726"], prep:"", Term_id:0}, cfg);
	var data = [];
	$.jcom.DBCascade.call(this, domobj, "../fvs/CPB_Term_class_view.jsp", {}, {OrderField:"Term_BeginTime", bDesc:1}, cfg);
	
	this.PrepareData = function (items, head)
	{
		for (var x = 0; x < items.length; x++)
		{
			items[x].item = items[x].Term_Name;
			items[x].child = null;
		}
		return items;
	};

	this.onReady = function (items)
	{
		if (cfg.Term_id > 0)
		{
			for (var x = 0; x < items.length; x++)
			{
				if (items[x].Term_id == cfg.Term_id)
				{
					self.select(x);
					return;
				}
			}
		}
		else if (items.length > 0)
			self.SkipPage(1, true);
	};
}

function TermClassFilter(domobj, cfg)	 //ѧ��-��� ����ѡ����
{
	var self = this;
	cfg = $.jcom.initObjVal( {title:["ѧ��", "���"], itemimg:["#9726", "#9908"], prep:"", Term_id:0, Class_id: 0}, cfg);
	var data = [];
	TermFilter.call(this, domobj, cfg);
		
	this.loadnode = function (item, node)
	{
		var fun = function(result)
		{
			var json = $.jcom.eval(result);
			if (typeof json == "string")
				return alert(json);
			var sub = -1;
			for (var x = 0; x < json.length; x++)
			{
				json[x].item = json[x].ClassCode + "-" + json[x].Class_Name;
				if (json[x].Class_id == cfg.Class_id)
					sub = x;					
			}
			item.child = json;
			self.loadnodeok(item, node);
			if (sub >= 0)
			{
				self.select(node + "," + sub);
				var obj = self.getsel(1);
//				var obj = $("span[node='" + node + "," + sub + "']")[0];
				self.onclick(obj, item.child[sub]);
				return;
			}
			else if (json.length > 0)
				self.SkipPage(1, true);
		};
		
		var ss = node.split(",");
		if (ss.length == 1)
			$.get("../fvs/CPB_Class_list1.jsp", {SeekKey: "CPB_Class.Term_id", SeekParam: item.Term_id, GetTreeData:1, nFormat:0}, fun);
		else
			self.loadNextNode(item, node);
	};
	
	this.loadNextNode = function(item, node)
	{
	};
	
	this.onclick = function(obj, item)
	{
		var node = $(obj).attr("node");
		if (node == undefined)
			return;
		var ss = node.split(",");
		switch (ss.length)
		{
		case 1:		//Term
			if ((item.child != null) && (item.child.length > 0) && (cfg.title.length > 1))
				self.SkipPage(1, true);
			self.onclickTerm(obj, item);
			break;
		case 2:		//Class
			self.onclickClass(obj, item);
			break;
		default:
			self.onclickOther(obj, item);
			break;
		}
	};

	this.onclickTerm = function(obj, item)
	{
	};
	
	this.onclickClass = function(obj, item)
	{
	};
	
	this.onclickOther = function (obj, item)
	{
	};
	
//	this.LinkAddParam = function(item, url)
//	{
//		var obj = self.getsel();
//		if (obj == undefined)
//			return url;
//		var items = self.getNodeItems(obj);
//		if (items.length == 1)
//			return url;
//		return url + "?Class_id=" + items[1].Class_id;
//	};
}

function TCSFilter(domobj, cfg)		//ѧ��-���-ѧԱ ����ѡ����
{
	var self = this;
	cfg = $.jcom.initObjVal( {title:["ѧ��", "���", "ѧԱ"], itemimg:["#9726", "#9908", "#9863"], prep:"", Term_id:0, Class_id: 0, Student_id: 0}, cfg);
	var data = [];
	TermClassFilter.call(this, domobj, cfg);
	self.loadNextNode = loadStudent;
	self.onclickOther = ClickOther;
	
	function loadStudent(item, node)
	{
		fun = function (data)
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				alert(json);
			var sub = -1;
			for (var x = 0; x < json.length; x++)
			{
				json[x].item = json[x].StdNo + "-" + json[x].StdName;
				if (json[x].RegID == cfg.Student_id)
					sub = x;					
			}
			self.loadLegend(json, node);
			if (sub >= 0)
			{
				self.select(node + "," + sub);
				var obj = $("span[node='" + node + "," + sub + "']")[0];
				self.onclick(obj, item.child[sub]);
				return;
			}
			else if (json.length > 0)
				self.SkipPage(1, true);			
		};

		  $.get("../fvs/FormStudentRpt.jsp", {GetClassStudentList:1, ClassID: item.Class_id}, fun);
	}
	
	this.onclickStudent = function (obj, item)
	{
	};

	function ClickOther(obj, item)
	{
		self.onclickStudent(obj, item);
	}
}

function TCCFilter(domobj, cfg)		//ѧ��-���-�γ̼���ѡ����
{
	var self = this;
	cfg = $.jcom.initObjVal({mode:1, title:["ѧ��", "���", "�γ�"], itemimg:["#9726", "#9908", "#9826"], prep:"", Term_id:0, Class_id: 0}, cfg);
	var data = [];
	TermClassFilter.call(this, domobj, cfg);
	self.onclickOther = ClickOther;
	switch (cfg.mode)
	{
	case 1:		//����������γ�
		self.loadNextNode = loadEVCourse;
		break;
	case 2:		//����ȫ���γ�
		self.loadNextNode = loadCourse;
		break;
	case 3:		//���뿼�ڿγ�
		self.loadNextNode = loadAttendanceCourse;
		break;	
	}
	
	function loadEVCourse(item, node)
	{
		fun = function (data)
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				alert(json);
			for (var x = 0; x < json.Data.length; x++)
			{
				json.Data[x].item = json.Data[x].Syllabuses_date_ex + json.Data[x].Syllabuses_AP + " " + json.Data[x].Syllabuses_course_name +
				"(" + json.Data[x].Syllabuses_teacher_name + ")";
			}
			self.loadLegend(json.Data, node);
			if (json.Data.length > 0)
				self.SkipPage(1, true);			
		};
		$.get("../fvs/CPB_Syllabuses_EVview.jsp", {GetGridData:1, class_id: item.Class_id}, fun);
	}
	
	function loadCourse(item, node)
	{
		fun = function (data)
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				alert(json);
			for (var x = 0; x < json.Data.length; x++)
			{
				json.Data[x].item = json.Data[x].Syllabuses_date_ex + json.Data[x].Syllabuses_AP + " " + json.Data[x].Syllabuses_course_name +
				"(" + json.Data[x].Syllabuses_teacher_name + ") - " + json.Data[x].Syllabuses_ClassRoom;
//				json.Data[x].item = json.Data[x].Syllabuses_course_name +
//				"<br>" + json.Data[x].Syllabuses_teacher_name + "<br>" + json.Data[x].Syllabuses_ClassRoom;
			}
			self.loadLegend(json.Data, node);
			if (json.Data.length > 0)
				self.SkipPage(1, true);			
		};
		$.get("../fvs/CPB_Syllabuses_view.jsp", {GetGridData:1, SeekKey:"CPB_Syllabuses.Class_id", SeekParam: item.Class_id, OrderField:"BeginTime"}, fun);
		
	}
	
	function loadAttendanceCourse(item, node)
	{
		
	}
	
	this.onclickCourse = function (obj, item)
	{
	};

	this.onclickLegend4 = function (obj, item)
	{
	};
	
	function ClickOther(obj, item)
	{
		var node = $(obj).attr("node");
		if (node == undefined)
			return;
		var ss = node.split(",");
		switch (ss.length)
		{
		case 3:
			self.onclickCourse(obj, item);
			break;
		default:
			self.onclickLegend4(obj, item);
		}
	}
}

function TCEFilter(domobj, cfg)		//ѧ��-���-����������ѡ����
{
	var self = this;
	cfg = $.jcom.initObjVal({mode:1, title:["ѧ��", "���", "��������"], itemimg:["#9726", "#9908", "#9826"], prep:"", Term_id:0, Class_id: 0}, cfg);
	var data = [];
	TermClassFilter.call(this, domobj, cfg);
	self.onclickOther = ClickOther;
	self.loadNextNode = loadEVTask;

	function loadEVTask(item, node)
	{
		fun = function (data)
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				alert(json);
			for (var x = 0; x < json.Data.length; x++)
			{
				json.Data[x].item = "(" + $.jcom.GetDateTimeString(json.Data[x].BeginTime,1) + "~" + $.jcom.GetDateTimeString(json.Data[x].EndTime, 10) + ") " + json.Data[x].TaskName;
			}
			self.loadLegend(json.Data, node);
			if (json.Data.length > 0)
				self.SkipPage(1, true);
		};
		$.get("../fvs/CPB_EvaluateTask_view.jsp", {GetGridData:1, ClassIDs:item.Class_id}, fun);
	}

	this.onclickEVTask = function (obj, item)
	{
	};
	
	this.onclickLegend4 = function (obj, item)
	{
	};
	
	function ClickOther(obj, item)
	{
		var node = $(obj).attr("node");
		if (node == undefined)
			return;
		var ss = node.split(",");
		switch (ss.length)
		{
		case 3:
			self.onclickEVTask(obj, item);
			break;
		default:
			self.onclickLegend4(obj, item);
		}
	}
}

function EvalutionPaper(domobj, cfg)		//�ʾ���
{
	var self = this;
	cfg = $.jcom.initObjVal( {jsp:"../fvs/CPB_Evaluate_Item_view.jsp", viewmode:1}, cfg); //viewmode - 1:���ģʽ, 2:����ģʽ��3:����Ķ�ģʽ, 4:���ܱ�
	var modetag = "", tailtag = "";
	var treecfg = {itemstyle:cfg.itemstyle, expic:[]};
	var evItem, taskItem, answerItems, answerRecord, answerAction;
	$(domobj).html("<div id=TitleBar align=center style='padding:4px;'></div><div id=TitleInfo align=center></div><div id=Content></div><div id=FootBar align=center></div>");
	if (cfg.viewmode != 1)
	{
		treecfg.rollbkcolor = false;
		treecfg.selbkcolor = false;
	}
	$.jcom.DBTree.call(this, $("#Content", domobj)[0],  cfg.jsp, {initflag:false}, treecfg);
	
	this.PrepareData = function (items, head)
	{
		if (evItem.question_action == "studentsystem/course_evaluation/question_form.jsp")
			items[items.length] = {Evaluate_item_id: 0, Evaluate_item_name: "�����������", item_level:2, item_type:3, remark: ""};
		prepare(items, 0);
		return items;
	};
	
	function prepare(items, depth)
	{
		var total = 0;
		for (var x = 0; x < items.length; x++)
		{
			items[x].item = (x + 1) + "��" + items[x].Evaluate_item_name;
			items[x].style = "font-size:" + (14 - depth * 2) + "pt;font-weight:" + (900 - depth * 400) + ";padding-top:20px;";
			if (items[x].item_level == 2)
			{
				var tag = getItemInput(items[x]);
				if (items[x].item_type == 0)
				{
					total += parseInt(items[x].Evaluate_item_value);
					items[x].item += "����ֵ" + items[x].Evaluate_item_value + ")";
				}
				items[x].item += "<p style=" + items[x].style + ">" + tag + "</p>";
				if (items[x].remark != "")
					items[x].item += "<p style=" + items[x].style + ">" + items[x].remark + "</p>";
			}
			if (typeof items[x].child == "object")
			{
				var t = prepare(items[x].child, depth + 1);
				if (t > 0)
					items[x].item += "(����" + t + ") ";
			}
		}
		return total;
	}
	
	function getItemInput(item)
	{
		item.item_type = parseInt(item.item_type);
		if (isNaN(item.item_type))
			item.item_type = 0;
		if (item.item_level == 1)
			return "";
		var tag = "";
		switch (cfg.viewmode * 100 + item.item_type)
		{
		case 100:		//���ģʽ �����
			return "<input disabled=true>";
		case 101:		//���ģʽ ��ѡ��
			var ss = item.select_item.split(",");
			for (var x = 0; x < ss.length; x ++)
				tag += "<input type=radio disabled=true>&nbsp;" + ss[x] + "&nbsp;";
			tag = tag.replace(/\?/, "&nbsp;<input disabled=true>");
			return tag;
		case 102:		//���ģʽ ��ѡ��		
			var ss = item.select_item.split(",");
			for (var x = 0; x < ss.length; x ++)
				tag += "<input type=checkbox disabled=true>&nbsp;" + ss[x] + "&nbsp;";
			tag = tag.replace(/\?/, "<input disabled=true name=other_" + item.Evaluate_item_id + ">");
			return tag;
		case 103:		//���ģʽ ������
			return "<textarea style=width:80% rows=6 disabled=true></textarea>";
		case 200:		//����ģʽ �����
			return "<input name=item_" + item.Evaluate_item_id + " value='" + getDetailInputValue(item.Evaluate_item_id, answerRecord, "score") + "'>";
		case 201:		//����ģʽ ��ѡ��
			var ss = item.select_item.split(",");
			var val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "score");
			for (var x = 0; x < ss.length; x ++)
			{
				var c = "";
				if (val == (x + 1))
						c = "checked=true ";
				tag += "<input type=radio " + c + "name=item_" + item.Evaluate_item_id + " value=" + (x + 1) + ">&nbsp;" + ss[x] + "&nbsp;";
			}
			val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "Evalute_opinion");
			tag = tag.replace(/\?/, "&nbsp;<input name=other_" + item.Evaluate_item_id + " value='" + val + "'>");
			return tag;
		case 202:		//����ģʽ ��ѡ��
			var ss = item.select_item.split(",");
			var val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "score");
			for (var x = 0; x < ss.length; x ++)
			{
				var c = "";
				if ((val & (1 << x)) > 0)
						c = "checked=true ";
				tag += "<input type=checkbox " + c + "name=item_" + item.Evaluate_item_id + " value=" + (1 << x) + ">&nbsp;" + ss[x] + "&nbsp;";
			}
			val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "Evalute_opinion");
			tag = tag.replace(/\?/, "<input name=other_" + item.Evaluate_item_id + " value='" + val + "'>");
			return tag;
		case 203:		//����ģʽ ������
			if ((item.Evaluate_item_id == 0) && (typeof answerRecord == "object"))
				tag = $.trim(answerRecord.Main.feedback);
			else
				tag = getDetailInputValue(item.Evaluate_item_id, answerRecord, "Evalute_opinion");
			return "<textarea style=width:80% rows=6 name=item_" + item.Evaluate_item_id + ">" + tag + "</textarea>";
		case 300:		//���ģʽ �����
			return "<input readonly=true value='" + getDetailInputValue(item.Evaluate_item_id, answerRecord, "score") + "'>";
		case 301:		//���ģʽ ��ѡ��
			var ss = item.select_item.split(",");
			var val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "score");
			for (var x = 0; x < ss.length; x ++)
			{
				var c = "disabled=true ";
				if (val == (x + 1))
						c = "checked=true ";
				tag += "<input type=radio " + c + ">&nbsp;" + ss[x] + "&nbsp;";
			}
			val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "Evalute_opinion");
			tag = tag.replace(/\?/, "&nbsp;<input readonly=true value='" + val + "'>");
			return tag;
		case 302:		//���ģʽ ��ѡ��
			var ss = item.select_item.split(",");
			var val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "score");
			if (val > 0)
			{
				for (var x = 0; x < ss.length; x ++)
				{
					var c = "disabled=true ";
					if ((val & (1 << x)) > 0)
							c = "checked=true ";
					tag += "<input type=checkbox " + c + ">&nbsp;" + ss[x] + "&nbsp;";
				}
				val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "Evalute_opinion");
				tag = tag.replace(/\?/, "<input readonly=true value='" + val + "'>");
			}
			else
			{
				val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "Evalute_opinion");
				var op = val.split(",");
				for (var x = 0; x < ss.length; x ++)
				{
					var c = $.jcom.getItemImg("#9744", "font-size:24px;color:gray;");
					for (var y = 0; y < op.length; y++)
					{
						if (parseInt(op[y]) == x + 1)
							c = $.jcom.getItemImg("#9745", "font-size:24px;color:black;");
					}
					tag += c + "&nbsp;" + ss[x] + "&nbsp;";
				}
		
			}
			val = getDetailInputValue(item.Evaluate_item_id, answerRecord, "Evalute_opinion");
			tag = tag.replace(/\?/, "<input readonly=true value='" + val + "'>");
			return tag;
		case 303:		//���ģʽ ������
			if ((item.Evaluate_item_id == 0) && (typeof answerRecord == "object"))
				tag = $.trim(answerRecord.Main.feedback);
			else
				tag = getDetailInputValue(item.Evaluate_item_id, answerRecord, "Evalute_opinion");
			return "<textarea readonly=true style=width:80% rows=6>" + tag + "</textarea>";
		case 400:		//����ģʽ �����
			var cnt = 0, total = 0, min = 1000, max = 0;
			for (var x = 0; x < answerItems.Detail.length; x++)
			{
				if (answerItems.Detail[x].Evaluate_item_id == item.Evaluate_item_id)
				{
					cnt ++;
					total += answerItems.Detail[x].score;
					if (answerItems.Detail[x].score < min)
						min = answerItems.Detail[x].score;
					if (answerItems.Detail[x].score > max)
						max = answerItems.Detail[x].score;
				}
			}
			if (cnt == 0)
				return "��������:0";
			return "ƽ����:" + (total / cnt).toFixed(2) + "(" + total + "/" + cnt + "), ��߷�:" + max + ", ��ͷ�:" + min;
		case 401:		//����ģʽ ��ѡ��
			var cnt = 0;
			var ss = item.select_item.split(",");
			var result = [];
			for (var x = 0; x < ss.length + 1; x++)
				result[x] = 0;
			for (var x = 0; x < answerItems.Detail.length; x++)
			{
				if (answerItems.Detail[x].Evaluate_item_id == item.Evaluate_item_id)
				{
					cnt ++;
					result[answerItems.Detail[x].score] ++;
				}
			}
			for (var x = 0; x < ss.length; x ++)
			{
				var p = "";
				if (cnt > 0)
					p = "-" + (result[x + 1] * 100 / cnt).toFixed(1) + "%";
				tag += $.jcom.getItemImg("#9673", "font-size:24px;color:gray;") + "&nbsp;" + ss[x] + "&nbsp;:" + result[x + 1] + p + "<br>";
			}
			return tag;			
		case 402:		//����ģʽ  ��ѡ��
			var cnt = 0;
			var ss = item.select_item.split(",");
			var result = [];
			for (var x = 0; x < ss.length + 1; x++)
				result[x] = 0;
			for (var x = 0; x < answerItems.Detail.length; x++)
			{
				if (answerItems.Detail[x].Evaluate_item_id == item.Evaluate_item_id)
				{
					cnt ++;
					if (answerItems.Detail[x].score == 0)
					{
						var op = answerItems.Detail[x].Evalute_opinion.split(",");
						for (var y = 0; y < op.length; y++)
							result[parseInt(op[y])] ++;
					}
					else
					{
						for (var y = 0; y < ss.length; y++)
						{
							if ((answerItems.Detail[x].score & (1 << y)) > 0)
								result[y] ++;								
						}
					}
				}
			}
			for (var x = 0; x < ss.length; x ++)
			{
				var p = "";
				if (cnt > 0)
					p = "-" + (result[x + 1] * 100 / cnt).toFixed(1) + "%";
				tag += $.jcom.getItemImg("#9745", "font-size:20px;color:gray;") + "&nbsp;" + ss[x] + "&nbsp;:" + result[x + 1] + p + "<br>";
			}
			return tag;
		case 403:		//����ģʽ ������
			var cnt = 0;
			if (item.Evaluate_item_id == 0)
			{
				for (var x = 0; x < answerItems.Main.length; x++)
				{
					var note = $.trim(answerItems.Main[x].feedback);
					if ((note != "") && (note != "��") && (note != "�ޡ�") && (note != "��"))
					{
						cnt ++;
						tag += cnt + "��" + note + "<br>";
					}
				}	
			}
			else
			{
				for (var x = 0; x < answerItems.Detail.length; x++)
				{
					if (answerItems.Detail[x].Evaluate_item_id == item.Evaluate_item_id)
					{
						var note = $.trim(answerItems.Detail[x].Evalute_opinion);
						if ((note != "") && (note != "��") && (note != "�ޡ�") && (note != "��"))
						{
							cnt ++;
							tag += cnt + "��" + note + "<br>";
						}
					}
				}
			}
			return "<div style=font-size:12pt;font-weight:100>" + tag + "</div>";
		}
	}
	
	function getDetailInputValue(itemid, answer, field)
	{
		if (typeof answer != "object")
			return "";
		for (var x = 0; x < answer.Detail.length; x++)
		{
			if (answer.Detail[x].Evaluate_item_id == itemid)
				return answer.Detail[x][field];
		}
		return "";
	}
	
	this.loadPaper = function(item)		//����:���ؿհ��ʾ��������ʾ���¼���ʾ����
	{
		if (typeof item == "object")
		{
			evItem = item;
			$("#TitleBar", domobj).html("<h1>" + item.evaluate_name + "</h1>");
			self.config({URLParam:"?Evaluate_id=" + item.evaluate_id});
			self.reload();
			return;
		}
		var fun = function (data)
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				alert(json);
			json.evaluate_id = item;
			self.loadPaper(json);
		};
		if ((typeof evItem == "object") && (evItem.evalute_id == item))
			self.loadPaper(evItem);
		else
			$.get("../fvs/CPB_Evaluate_form.jsp", {getrecord:1, DataID: item}, fun);		
	}
	
	this.loadEVTaskForm = function (task, answer, act)		//����:��������������������ʾ�����ѧԱ��д,����γ̼�¼�ʹ����¼���ύ��ַ
	{
		cfg.viewmode = 2;
		taskItem = task;
		answerRecord = answer;
		answerAction = act;
		var title = "<h2 align=center>" + task.TermID_ex + "&nbsp;" + task.ClassIDs_ex + "</h2><h2>" + task.TaskName + "</h2><h2>" + task.Teachers + "</h2>";
		if (typeof answerRecord == "object")
			title += "<h3 align=left>�ܷ�:" + answer.Main.score + ", �ύʱ��:" + $.jcom.GetDateTimeString(answer.Main.submit_time, 2) + "</h3>";
				
		$("#TitleInfo", domobj).html(title);
		$("#SubmitAnswer", domobj).off("click", SubmitForm);
		var now = new Date();
		var value = "�ύ";
		if ($.jcom.makeDateObj(task.BeginTime) > now)
			value = "δ������ʱ��";
		else if (($.jcom.makeDateObj(task.EndTime) < new Date()) && (task.DelayMode == 1))
			value = "���������ѽ���";
		else if ((task.ReEditable == 0) && (typeof answer == "object"))
			value = "������";
		else if (task.AttendanceReq)
		{
			if (task.AttendObj == undefined)
				value = "û�п��ڼ�¼";
			else
			{
				if ((task.AttendObj.Status > 2) && (task.AttendObj.Status < 9))
					value = task.AttendObj.Status_ex;
			}
		}
		if (value == "�ύ")
		{
			if (task.bAnonymous == 1)
				value = "�����ύ";
			$("#FootBar", domobj).html("<input id=SubmitAnswer type=button value=" + value + ">");
			$("#SubmitAnswer", domobj).on("click", SubmitForm);
		}
		else
			$("#FootBar", domobj).html(value);
		self.loadPaper(task.EvaluateID);
	};

	function SubmitForm()
	{
		$("[id='FormErrHint']", domobj).remove();
		var items = self.getdata();
		var instance_id = 0;
		if (typeof answerRecord == "object")
			instance_id = answerRecord.Main.instance_id;
		var result = {cnt:0, Detail:[{instance_id:instance_id, TaskID: taskItem.ID, Syllabuses_id: taskItem.CourseID, evaluate_id:taskItem.EvaluateID, Total:0, feedback:""}]};
		getFormDetail(items, result);
		if (result.cnt > 0)
			return alert("δ��ɴ������" + result.cnt + "������δ��д����д�������顣");
		$("#SubmitAnswer", domobj).attr("disabled", true);
		$("#SubmitAnswer", domobj).val("�����ύ...");
		$.jcom.submit(answerAction, result.Detail, {fnReady:SaveFormOK});
	}
	
	function SaveFormOK(data)
	{
		alert(data);
		if (data == "OK:�ύ����ɹ���")
			location.reload();
	}
	
	function getFormDetail(items, result)
	{
		for (var x = 0; x < items.length; x++)
		{
			if (items[x].item_level == 2)
			{
				var obj = $("[name='item_" + items[x].Evaluate_item_id + "']", domobj);
				var val = 0, text = "";
				switch (items[x].item_type)
				{
				case 0:		//�����
					val = parseInt(obj.val());
					if (isNaN(val))
						FormItemError(obj.parent(), result);
					result.Detail[0].Total += val;
					break;
				case 1:		//��ѡ��
					for (var y = 0; y < obj.length; y++)
					{
						if (obj[y].checked)
							val = obj[y].value;
					}
					var o = $("[name='other_" + items[x].Evaluate_item_id + "']", domobj);
					if (o.length > 0)
						text = o.val();
					if (val == 0)
						FormItemError(obj.parent(), result);
					break;
				case 2:		//��ѡ��
					for (var y = 0; y < obj.length; y++)
					{
						if (obj[y].checked)
							val += obj[y].value;
					}
					var o = $("[name='other_" + items[x].Evaluate_item_id + "']", domobj);
					if (o.length > 0)
						text = o.val();
					if (val == 0)
						FormItemError(obj.parent(), result);
					break;
				case 3:		//�ʴ���
					text = obj.val();
					break;
				}
				if (items[x].Evaluate_item_id == 0)
					result.Detail[0].feedback = text;
				else
					result.Detail[result.Detail.length] = {Evaluate_item_id:items[x].Evaluate_item_id, score: val, Evalute_opinion:""};
	
			}
			if (typeof items[x].child == "object")
				getFormDetail(items[x].child, result);
		}		
	}
	
	function FormItemError(obj, result)
	{
		obj.append("<span id=FormErrHint style=color:red>&nbsp;����⣡</span>");
		result.cnt ++;
	}
	
	this.loadEvTaskAnswer = function (evtask, answer)		//����:����һ�����μ�¼����������������¼�ʹ𰸼�¼
	{
		cfg.viewmode = 3;
		taskItem = evtask;
		answerRecord = answer;
		$("#TitleInfo", domobj).html("<h2 align=center>" + evtask.TermID_ex + "&nbsp;" + evtask. ClassIDs_ex + "</h2><h2>" + evtask.TaskName + "</h2></h2><h2>" +
			evtask.Teachers + "<h1>���</h1><h3 align=left>�ܷ�:" + answer.Main.score + ", �ύʱ��:" + $.jcom.GetDateTimeString(answer.Main.submit_time, 2) + "</h3>");
		self.loadPaper(evtask.EvaluateID);
	};
	
	this.loadEVTaskRpt = function (evtask, answers)	//���������ؿγ̵����λ��ܣ�����γ̼�¼�ʹ����¼��
	{
		taskItem = evtask;
		answerItems = answers;
		cfg.viewmode = 4;
		$("#TitleInfo", domobj).html("<h2 align=center>" + evtask.TermID_ex + "&nbsp;" + evtask. ClassIDs_ex + "</h2><h2>" + evtask.TaskName + "</h2><h2>" + evtask.Teachers +
			"</h2><h1>���ܱ�</h1><p align=left>��������:" + evtask.nType_ex + ", ���ο�ʼʱ��:" + evtask.BeginTime + ",����ʱ��:" + evtask.EndTime + 
			"</p><p align=left>�������:" + answerItems.Main.length + ", ��������:" + answerItems.Users.length + "</p><p align=left>" + getTotal() +
			"</p><p align=left>δ������Ա:" + getAbsence(answerItems.Users, answerItems.Main) + "</p>");
		self.loadPaper(evtask.EvaluateID);
	};
	
	function getAbsence(Users, Mains)
	{
		for (var x = 0; x < Users.length; x++)
		{
			Users[x].flag = 0;
		}
		
		for (var x = 0; x < Mains.length; x++)
		{
			for (var y = 0; y < Users.length; y++)
			{
				if (Mains[x].submit_man == Users[y].RegID)
					Users[y].flag = 1;
			}
		}
		var tag = "", cnt = 0;
			
		for (var x = 0; x < Users.length; x++)
		{
			if (Users[x].flag == 0)
			{
				tag += ",&nbsp" + Users[x].StdName;
				cnt ++;
			}
		}
		return "��" + cnt + "��" + tag;
	}
	
	function getTotal()
	{
		var cnt = 0, total = 0, min = 1000, max = 0;
		for (var x = 0; x < answerItems.Main.length; x++)
		{
			cnt ++;
			total += answerItems.Main[x].score;
			if (answerItems.Main[x].score < min)
				min = answerItems.Main[x].score;
			if (answerItems.Main[x].score > max)
				max = answerItems.Main[x].score;
		}
		if (cnt == 0)
			return "��������:0";
		return "��ƽ����:" + (total / cnt).toFixed(2) + "(" + total + "/" + cnt + "), ��߷�:" + max + ", ��ͷ�:" + min + ", ʱ���:" + 
		$.jcom.GetDateTimeString(answerItems.Main[0].submit_time, 9) + " ~ " + $.jcom.GetDateTimeString(answerItems.Main[answerItems.Main.length - 1].submit_time, 9);
		
	}
}

function SiteSeatMap(domobj, cfg)
{
	var self = this;
	var setMapwin, form, siteitem;
//	cfg = $.jcom.initObjVal({mode:1}, cfg);
//	switch (cfg.mode)
//	{
//	case 1:			//��ʾ����λ��ͼ
//		break;
//	case 2:			//�༭����λ��ͼ
//		break;
//	case 3:			//��ʾ��λ����ͼ
//		break;
//	case 4:			//�༭��λ����ͼ
//		break;
//	}
	$.jcom.GridView.call(this, domobj, [], [], {}, {headstyle:2,footstyle:4, rollbkcolor:false, resizeflag:0});
	this.waiting("δ������λ");
	
	this.clickRow = function (td, event)	//���ػ���
	{
		if (td == undefined)
			return;
		if ((td.id.substr(0, 3) != "Col") || (td.innerText == ""))
			return;
		var shadow = self.getsel();
		shadow.show(td);
	};

	this.getSelSeat = function()
	{
		var shadow = self.getsel();
		var objs = shadow.getShadow();
		if (objs.length == 0)
			return;
		var tr = objs[0].obj.parentNode;
		var items = self.getData();
		return {items: items, row:tr.rowIndex - 1, field:objs[0].obj.id.substr(0, objs[0].obj.id.length - 3)};
	};
	
	function NewMap(record)
	{
		var head = [{FieldName:"Num",TitleName:"&nbsp;",nShowMode:1,nWidth:36,FieldType:1, align:"center"}];
		var items = [];
		var cols = Math.max(record.chairmanCols, record.seatCols);
		var walkCols = record.walkColNums.split(",");
		var walkRows = record.walkRowNums.split(",");
		var x, y, z = 0;
		for (x = 0; x < cols; x++)
		{
			head[head.length] = {FieldName:"Col_" + x,TitleName: x + 1,nShowMode:1,nWidth:66, align:"center"};
			
			if ((x + 1) == parseInt(walkCols[z]))
				head[head.length] = {FieldName:"walk_" + z++,TitleName: "",nShowMode:1,nWidth:20, align:"center"};
		}
		
		items[0] = {Num: $.jcom.getChineseNumber(record.chairmanRows)};
		setcol(items[0], cols, "��:");
		for (y = 0; y < walkCols.length; y++)
			items[0]["walk_" + y] = {value:"", rowspan: record.chairmanRows, tdstyle:"border:none"};

		for (x = 1; x < record.chairmanRows; x++)
		{
			items[x] = {Num: $.jcom.getChineseNumber(record.chairmanRows - x)};
			setcol(items[x], cols, "��:");
		}

		items[record.chairmanRows] = {Num: {value:"��̨", colspan:head.length, tdstyle:"border:none"}};
		
		var offset = record.chairmanRows + 1;
		items[offset] = {Num: $.jcom.getChineseNumber(1)};
		setcol(items[offset], cols, "");
		for (y = 0; y < walkCols.length; y++)
			items[offset]["walk_" + y] = {value:"", rowspan: record.seatRows + walkRows.length, tdstyle:"border:none"};
		
		for (x = 1, z = 0; x < record.seatRows; x ++)
		{
			items[x + offset] = {Num: $.jcom.getChineseNumber(x + 1)};
			setcol(items[x + offset], cols, "");
			if ((x + 1) == parseInt(walkRows[z]))
			{
				offset ++;
				z++;
				items[x + offset] = {Num: {value:"", tdstyle:"border:none"}};
				for (y = 0; y < cols; y++)
					items[x + offset]["Col_" + y] = {value: "", tdstyle:"border:none", color:"gray"};
			}
		}
		return {head:head, data:items};
	}

	function setcol(item, cols, prep)
	{
		for (var x = 0; x < cols; x++)
			item["Col_" + x] = {ex: prep + item.Num + "��" + (x + 1) + "��", value: "&nbsp;<br>" + prep + item.Num + "��" + (x + 1) + "��",
				tdstyle:"border:none", color:"gray"};		
	}
	
	function RunSetMap()
	{
		var r = form.getRecord();
		var d = NewMap(r);
		self.reload(d.data, d.head)
		setMapwin.hide();
		return false;
		
	}	
	
	this.SetMap = function()
	{
		if (typeof setMapwin == "object")
		{
			setMapwin.show();
			return;
		}
		setMapwin = new $.jcom.PopupWin("<div id=SetMapForm style=width:100%;height:100%></div>", 
			{title:"��λ����", mask:50, width:360, height:380, resize:0,position:"fixed"});
		form = new $.jcom.FormView($("#SetMapForm")[0],
			[{CName:"����", EName: "SiteType", FieldType:3, InputType:3, Quote:"(1:����/������,2:������,4:����)"},
			 {CName:"��ϯ̨����", EName: "chairmanRows", FieldType:3},
			 {CName:"��ϯ̨����", EName: "chairmanCols", FieldType:3},
			 {CName:"��λ����", EName: "seatRows", FieldType:3},
			 {CName:"��λ����", EName: "seatCols", FieldType:3},
			 {CName:"�����ߵ�λ��", EName: "walkColNums"},
			 {CName:"�����ߵ�λ��", EName: "walkRowNums"}
			], {}, {});
		setMapwin.close = setMapwin.hide;
		form.setRecord({SiteType:1, chairmanRows:0, chairmanCols:6, seatRows:8,seatCols:6, walkColNums:2, walkRowNums:8});
		form.submit = RunSetMap;
	};

	this.LoadMap = function (record)
	{
		if (typeof record != "object")
		{
			var fun = function (data)
			{
				var json = $.jcom.eval(data);
				if (typeof json == "string")
					return alert(json);
				if (json.Data.length == 0)
					self.LoadMap({});
				else
					self.LoadMap(json.Data[0]);
			};
			$.get("../fvs/Place_Archive.jsp", {GetGridData:1, SeekKey:"Place.ID", SeekParam: record}, fun);
			return;
		}
		siteitem = record;
		if ((siteitem.SeatMap =="") || (siteitem.SeatMap == undefined))
		{
			self.reload([],[]);
			return self.waiting("��λδ���á�");
		}
		
		var d = $.jcom.eval(siteitem.SeatMap);
		if (typeof d == "string")
			return alert(d);
		self.reload(d.data, d.head)
	};
	this.LoadCourseMap = function (course, url)
	{
		var fun = function (data)
		{
			if ((data == "") || (data == "null"))
				return self.waiting("��λδ���á�");
			var d = $.jcom.eval(data);
			if (typeof d != "object")
				return self.waiting("��λ�������" + d);
			self.reload(d.data, d.head);
			self.loadCourseMapReady(d.data);
		};
		
		$.get(url, {GetCourseMap:1, Class_id: course.class_id, ClassRoomID: course.Syllabuses_ClassRoom_id, courseID: course.Syllabuses_id}, fun);
	};

	this.loadCourseMapReady = function(items)
	{
		
	};
	
	this.getMapData = function()
	{
//		if (siteitem == undefined)
//			return;
		var griddata = {head:self.getHead(), data:self.getData()};
		return $.jcom.toJSONStr(griddata);
		
	};
	
	this.SaveMap = function (url)
	{
		var ss = self.getMapData();
		if (ss == undefined)
			return alert("���ܱ��棬δָ������");
		siteitem.SeatMap = ss;
		$.jcom.submit(url, {DataID: siteitem.ID, SeatMap: ss});
	}
}