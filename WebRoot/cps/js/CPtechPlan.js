function InitRecord(record)
{
	if (record.train_address == "")
		record.train_address = "����ʡί��У";
	if (record.train_style == "")
		record.train_style = "��ѵѧϰ�ڼ䣬У(Ժ)��ѧԱ���ˣ��Ժϸ��߰䷢��ҵ֤�飬�����ɲ�����Ȩ�ޣ������˽����������֯���²��š�";
	if (record.train_claim == "")
		record.train_claim = "��У(Ժ)��ί���쵼�£����񴦣�ѧԱ�����ֱ�ָ����ѧ��Ŀ�����ˡ������Σ������ƶ�ʵʩ��ѧ�ƻ���ѧԱ����������ѵ���ڽ�ѧ�����˺Ͱ����ε�ָ���£�ʵ�����ҹ���";
	return record;
}

function PlanDoc(domobj, cfg)
{
	var self = this;
	var resTree, CourseEditor, toolMenu;
	var User;
	var docData;
	var classItem;
	var coursesObj;
	var pEdit, dateEditor;
	var option = {
			CourseShowMode: 1,				/*��ѧ�ƻ��γ���ʾ�ṹ*/
			CourseNoMode: 1,				/*��ѧ�ƻ��γ���ű��ŷ�ʽ*/
			CourseNameMode: 0, 				/*��ѧ�ƻ��γ�������ʾ��ʽ*/
			TeacherShowMode: 0,				/*��ѧ�ƻ���У�ڿ�����ʾ��ʽ*/
			OuterTeacherShowMode: 0,		/*��ѧ�ƻ������ڿ�����ʾ��ʽ*/
			CourseNameEditEnable: 2,		/*��ѧ�ƻ��༭�γ���������*/
			CourseTimeEnable: 0,			/*��ѧ�ƻ��γ�ʱ����ʾ�༭����*/
			TeacherEditEnable: 0,			/*��ѧ�ƻ��༭�ڿ�������*/
			TeacherUnitEditEnable: 0,		/*��ѧ�ƻ��༭�ڿ��˵�λ����*/
			CourseLayerMode: 1,				/*��ѧ�ƻ��γ��Ű淽ʽ*/
			CourseFreeInfo: 1,				/*��ѧ�ƻ�ѡ�޿���ʾ����*/
			ActivityMode: 1,				/*��ѧ�ƻ���ѧ�����ʽ*/
			CourseShowRed: 1, 				/*����ר����еĿγ�*/
			CommonUnitCourseEditEnable: 0	/*�༭������Ԫ��γ�*/
			};

	
	function init()
	{
		cfg = $.jcom.initObjVal({mode:0, TMPID:0, url:location.pathname}, cfg);
		if (cfg.TMPID > 0)
			$.get("../com/inform.jsp", {DataID:cfg.TMPID, Ajax:1}, getUserPlanDocOK);
		else
			getUserPlanDocOK();
	}
	
	function getUserPlanDocOK(data)
	{
		if (data == undefined)
			docData = getDocData()
		else
			docData = "<h1 id=Term_id_ex align=center></h1><h1 id=Class_Name align=center></h1>" + data;
		$(domobj).html(docData);
		CourseEditor = new PlanCourseEditor($("#PlanCourseDoc")[0], [], option, {mode:0});
	}

	function getDocData()
	{
		if (typeof docData == "string")
			return docData;
		var tag = "<h1 id=Term_id_ex align=center></h1><h1 id=Class_Name align=center></h1><H1 align=center>��ѧ�ƻ�</H1>";
		tag += "<h2>һ����ѵĿ��</h2><p id=train_goal title=������ѵĿ�� class=pedit style=text-indent:30px;></p>";
		tag += "<h2>������ѵ����</h2><p id=train_object title=������ѵ���� class=pedit style=text-indent:30px;></p>";
		tag += "<h2>������ѵ����</h2><p style=text-indent:0px>�ƻ���ѵ����<span id=classmates class=pedit title=��������></span>�ˡ�</p>";
		tag += "<h2>�ġ���ѵʱ��</h2><p><span id=Class_BeginTime title=��ѵ��ʼʱ�� class=tedit style=text-indent:15px;></span>��<span id=Class_EndTime class=tedit title=��ѵ����ʱ��>" +
			"</span>�������ѵ��ֹʱ�䣺<span id=OuterBegin title=��ʼʱ�� class=tedit></span>�� <span id=OuterEnd class=tedit title=����ʱ�� style=text-indent:0px;></span>��</p>";
		tag += "<h2>�塢��ѵ�ص�</h2><p><span id=train_address title=������ѵ�ص� class=pedit style=text-indent:15px></span>��<span id=OuterArea title=���������ѵ�ص� class=pedit></span></p>";
		tag += "<h2>������ѵ����</h2><p id=train_content class=pedit title=������ѵ���� style=text-indent:30px></p>";
		tag += "<div id=PlanCourseDoc style='overflow:visible;'></div>";
		tag += "<h2>�ߡ�����ʽ�ͽ�ҵʽ</h2><div id=BECourseDiv></div>"
		tag += "<h2>�ˡ���ѧ��ѧԱ����</h2><p id=C_train_claim class=pedit title=�����ѧ��ѧԱ���� style=text-indent:30px></p>";
		tag += "<h2>�š�ѧԱ������䷢ѧҵ֤��</h2><p id=C_train_style class=pedit title=�������� style=text-indent:30px></p>";
		return tag;
	}
	
	this.LoadPlanDoc = function(Class_id)
	{
		$.get("../fvs/CPB_Class_Course.jsp", {getrecord:1, DataID: Class_id}, getClassPlanDataOK);
	};

	function getClassPlanDataOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		classItem = json;
		$.get(cfg.url, {getClassCourseData:1, DataID: classItem.Class_id, ClassCode:classItem.ClassCode}, getClassCourseDataOK);	
	}

	function getClassCourseDataOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
				return alert(json);
		coursesObj = json;
		classItem.train_goal = DealEnter(classItem.train_goal);
		classItem.train_object = DealEnter(classItem.train_object);
		classItem.train_content = DealEnter(classItem.train_content);
		classItem.Class_BeginTime =	$.jcom.GetDateTimeString(classItem.Class_BeginTime, 12);
		classItem.Class_EndTime = $.jcom.GetDateTimeString(classItem.Class_EndTime, 12);
		classItem.OuterBegin = $.jcom.GetDateTimeString(classItem.OuterBegin, 12);
		classItem.OuterEnd = $.jcom.GetDateTimeString(classItem.OuterEnd, 12);

		for (key in classItem)
		{
			var o = $("#" + key);
			if (o.length > 0)
				o.html(classItem[key]);
		}
		CourseEditor.LoadCoursePlan(classItem, coursesObj, 0);
	}

	function DealEnter(s)
	{
		s = s.replace(/ /g, "&nbsp;&nbsp;");
		return s.replace(/\n/g, "<br>");
	}

	this.LoadEditor = function(oMenu, res, sys)
	{
		if (classItem == undefined)
			return alert("����ѡ����");
		toolMenu = oMenu;
		resTree = res;
		User = sys;
		res.setClassItem(classItem);
		res.ApplyItem = ResApply;
		res.getClipItem = getClipItem;
		
		var def = [{item:"����",action:ImportPlan}, {item:"����",child:[{item:"������ѧ�ƻ����ļ�",action:self.OutFile},{item:"������ѧ�ƻ�������ĵ�", action:self.OutFile}]},
			{item:"����", action:CourseConfig},
			{item:"����", child:[{item:"��ռ��б��е�����", action:ClearClips},{item:"����Ĭ�Ͻ�ѧ��Ԫģ��", action:TeachUnit},{item:"ά����ѧ��ʽ",action:RunTeachStyle},
				{item:"ά��ר���",action:RunSubject},{item:"ά��ʦ�ʿ�",action:RunTeacher},{},{item:"�����ĵ�ģ��", action:SetFormModule},{},
				{item:"���α��еĿγ̸��Ƶ���ѧ�ƻ�", action:CopyfromSyllabuses}]}, 
			{item:"����", action:SaveDoc},{},{item:"�˳��༭", action:ExitEditor}];
		oMenu.reload(def);

		CourseEditor.onClipChange = ReloadClip;
		CourseEditor.SearchReq = res.RunSearch;
//		CourseEditor.onDblClick = DblClickPlan;
		BECourse = CourseEditor.getUnitCourse(0), 
	
		pEdit = new $.jcom.DynaEditor.Edit();
		pEdit.valueChange = PEditValueChange;
		var o = $(".pedit");
		dateEditor = new $.jcom.DynaEditor.Date(200, 200);
		dateEditor.valueChange = DateValueChange;
		var o = $(".tedit");
		PlanAttachEditor();
		
		CourseEditor.LoadCoursePlan(classItem, coursesObj, 1);		
	};

	function ResApply(item, e)
	{
		switch (item.nType)
		{
		case 8:	//������Ԫ
			CourseEditor.ApplyUnits(item.child);
			break;
		case 11:	//��Ԫ
			CourseEditor.ApplyOneUnit(item, true);
			CourseEditor.Option(option);
			break;
		case 12:	//��Ԫ�ڿγ̻򹫹��γ�
			if (e.shiftKey)
				return RemoveCourseRef(item);
			CourseEditor.ApplyCourseItem(item);
			break;
		case 13:	//ѡ�޿��µ�ʱ���
			break;
		case 32:	//ר��
			CourseEditor.ApplyCourseItem(item);
			break;
		case 51:	//��������Ԫ
			var oClip = CourseEditor.getClip();
			CourseEditor.ApplyOneUnit(oClip.clipUnits[item.refClip]);
			oClip.clipUnits.splice(item.refClip, 1);
			ReloadClip();
			CourseEditor.Option(option);
			break;
		case 52:	//��������Ԫ�е�ģ��
		case 53:	//�������еĽ�ѧ��ʽ
			break;
		case 54:	//�������µĽ�ѧģ�����ʽ�µĿγ̻�ģ���µĿγ̻�γ�
			if (CourseEditor.ApplyCourseItem(item, true) != true)
				return;
			var oClip = CourseEditor.getClip();
			if (typeof item.refClip == "number")
				oClip.clipCourses.splice(item.refClip, 1);
			else
			{
				if (item.refClip.length == 3)
					oClip.clipUnits[item.refClip[0]].child[item.refClip[1]].Course.splice(item.refClip[2], 1);
				else
					oClip.clipUnits[item.refClip[0]].Course.splice(item.refClip[1], 1);
			}
			ReloadClip();
			break;
		case 61:	//�༶�γ�
			CourseEditor.ApplyUnits(item.child);
			break;
		}		
	}
	function getClipItem(item)
	{
		var oClip = CourseEditor.getClip();
		item.child = [];
		var cnt = 0;
		for (var x = 0;  x < oClip.clipUnits.length; x++)
		{
			var o = $.extend(true, {}, oClip.clipUnits[x]);
			item.child[cnt ++] = o;
			o.refClip = x;
			o.item = "<img src=../pic/flow_bs_manage.png>��ѧ��Ԫ:" + o.Mode_Name;
			o.nType = 51;
			for (var y = 0; y < o.child.length; y++)
			{
				if (o.child[y].Style_Name == undefined)
				{
					o.child[y].item =  "<img src=../pic/flow_bs_manage.png>��ѧģ��:" + o.child[y].Mode_Name;
					o.child[y].nType = 52;
				}
				else
				{
					o.child[y].item =  "<img src=../pic/flow_bs_manage.png>��ѧ��ʽ:" + o.child[y].Style_Name;
					o.child[y].nType = 53;
					o.child[y].refClip = [x, y];
				}
				
				if (o.child[y].Course.length > 0)
				{
					o.child[y].child = o.child[y].Course;
					for (var z = 0; z < o.child[y].child.length; z++)
					{
						o.child[y].child[z].item = "<img src=../pic/flow_bs_manage.png>�γ�:" + o.child[y].child[z].Course_name;
						o.child[y].child[z].nType = 54;
						o.child[y].child[z].refClip = [x, y, z];
					}
				}
			}
			
			var z = o.child.length;
			for (var y = 0; y < o.Course.length; y++)
			{
				o.child[z] = o.Course[y];
				o.child[z].item = "<img src=../pic/flow_bs_manage.png>�γ�:" + o.Course[y].Course_name;
				o.child[z].nType = 54;
				o.child[z++].refClip = [x, y];
			}
		}

		for (var x = 0; x < oClip.clipSubUnits.length; x++)
		{
			item.child[cnt ++] = oClip.clipSubUnits[x];
			if (oClip.clipSubUnits[x].Style_Name == undefined)
				oClip.clipSubUnits[x].item = "<img src=../pic/flow_bs_manage.png>��ѧģ��:" + oClip.clipSubUnits[x].Mode_Name;
			else
				oClip.clipSubUnits[x].item = "<img src=../pic/flow_bs_manage.png>��ѧ��ʽ:" + oClip.clipSubUnits[x].Style_Name;
				
			if (oClip.clipSubUnits[x].Course.length > 0)
			{
				oClip.clipSubUnits[x].child = oClip.clipSubUnits[x].Course;
				for (var y = 0; y < oClip.clipSubUnits[x].child.length; y++)
					oClip.clipSubUnits[x].child[y].item = "<img src=../pic/flow_bs_manage.png>�γ�:" + StrAdd(oClip.clipSubUnits[x].child[y].Course_name, oClip.clipSubUnits[x].child[y].Teacher_name);
			}
		}			

		for (var x = 0; x < oClip.clipCourses.length; x++)
		{
			item.child[cnt ++] = oClip.clipCourses[x];
			oClip.clipCourses[x].item = "<img src=../pic/flow_bs_manage.png>�γ�:" + StrAdd(oClip.clipCourses[x].Course_name, oClip.clipCourses[x].Teacher_name);
			oClip.clipCourses[x].nType = 54;
			oClip.clipCourses[x].refClip = x;
		}
		return item.child;
	}
	
	function PlanAttachEditor(flag)
	{
		var o = $(".pedit");
		for (var x = 0; x < o.length; x++)
		{
			if ((flag == false) || (flag == undefined))
				pEdit.detach(o[x]);
			if ((flag == true) || (flag == undefined))
				pEdit.attach(o[x]);
		}
		var o = $(".tedit");
		for (var x = 0; x < o.length; x++)
		{
			if ((flag == false) || (flag == undefined))
				dateEditor.detach(o[x]);
			if ((flag == true) || (flag == undefined))
				dateEditor.attach(o[x]);
		}
	}	

	function PEditValueChange(obj)
	{
		classItem[obj.id] = obj.innerText;
	}

	function DateValueChange(obj)
	{
		classItem[obj.id] = obj.innerText;
		obj.innerText = $.jcom.GetDateTimeString(obj.innerText, 12);
	}

	this.OutFile = function (obj, item)
	{
		if (classItem == undefined)
			return alert("����ѡ����");
		var body = getDocData();
		var action = "../com/OutHtml.jsp";
		if (item.item == "������ѧ�ƻ�������ĵ�")
			action += "?OutToServer=1";
		
		var obj = {FileName:classItem.Class_Name + "-" + classItem.ClassCode + "��ѧ�ƻ�.doc", body:getDocData()}; 
		$.jcom.submit(action, obj, {fnReady:function(){}});
	};

	function OutHtmltoServerOK(id)
	{
		$.get(location.pathname + "?AffixName=" + classItem.Class_Name + "��ѧ�ƻ�.htm",
			{OutHTMLToServer:1, DataID:classItem.Class_id, AffixID:id}, OutHtmltoDocOK);
	}
	
	var ConfigWin;
	var planOptionFields = ["CourseShowMode", "CourseNoMode", "CourseNameMode", "TeacherShowMode", "OuterTeacherShowMode", "CourseNameEditEnable",
	 	"CourseTimeEnable", "TeacherEditEnable", "TeacherUnitEditEnable", "CourseLayerMode", "CourseFreeInfo", "ActivityMode", "CourseShowRed", "CommonUnitCourseEditEnable"];
	function CourseConfig()
	{
		if (typeof ConfigWin == "object")
			return ConfigWin.show();
		var span = "<span style=display:inline-block;width:120px>";
		ConfigWin = new $.jcom.PopupWin("<div id=PlanCourseConfig style=width:100%;height:100%;padding:8px;>" +
				span + "�γ���ʾ�ṹ</span><input name=CourseShowMode type=radio checked value=0>��Ԫ-��ѧ��ʽ-�γ�&nbsp;<input name=CourseShowMode type=radio value=1>��Ԫ-ģ��-�γ�<br>" +
				span + "�γ���ű��ŷ�ʽ</span><input name=CourseNoMode type=radio checked value=0>���������&nbsp;&nbsp;<input name=CourseNoMode type=radio value=1>�������<br>" +
				span + "�γ�������ʾ��ʽ</span><input name=CourseNameMode type=radio checked value=0>����ʾ����&nbsp;<input name=CourseNameMode type=radio value=1>��ʾ��ѧ��ʽ:����&nbsp;&nbsp;<br>" +
				span + "�༭�γ�����</span><input name=CourseNameEditEnable type=radio checked value=0>������&nbsp;&nbsp;<input name=CourseNameEditEnable type=radio value=1>����&nbsp;<input name=CourseNameEditEnable type=radio value=2>�ɽ�ѧ��ʽ����<br>" +
				span + "�γ��Ű淽ʽ</span><input name=CourseLayerMode type=radio checked value=0>�γ̺���̷�˾�����&nbsp;<input name=CourseLayerMode type=radio value=1>�γ̾����ڿ��˾���<br>" +
				span + "��У�ڿ�����ʾ��ʽ</span><input name=TeacherShowMode type=radio checked value=0>��ʾ����&nbsp;&nbsp;<input name=TeacherShowMode type=radio value=1>��ʾ����+����&nbsp;<br>" +
				span + "�����ڿ�����ʾ��ʽ</span><input name=OuterTeacherShowMode type=radio checked value=0>��ʾ���������룩&nbsp;&nbsp;<input name=OuterTeacherShowMode type=radio value=1>��ʾ����+��λ&nbsp;<br>" +
				span + "�༭�ڿ���</span><input name=TeacherEditEnable type=radio checked value=0>������&nbsp;&nbsp;<input name=TeacherEditEnable type=radio value=1>����&nbsp;<br>" +
				span + "�༭�ڿ���˵��</span><input name=TeacherUnitEditEnable type=radio checked value=0>������&nbsp;&nbsp;<input name=TeacherUnitEditEnable type=radio value=1>����&nbsp;<br>" +
				span + "��ʾ�༭�γ�ʱ��</span><input name=CourseTimeEnable type=radio checked value=0>������&nbsp;&nbsp;<input name=CourseTimeEnable type=radio value=1>����&nbsp;<br>" +
				span + "ѡ�޿���ʾ����</span><input name=CourseFreeInfo type=radio checked value=0>�γ�+�ڿ���&nbsp;&nbsp;<input name=CourseFreeInfo type=radio value=1>ʱ��+�γ�+�ڿ���+�ص�<br>" +
				span + "��ѧ�����ʽ</span><input name=ActivityMode type=radio checked value=0>��ר�⴦��&nbsp;&nbsp;<input name=ActivityMode type=radio value=1>��������&nbsp;&nbsp;<br>" +
				span + "����ר����пγ�</span><input name=CourseShowRed type=radio checked value=0>��&nbsp;&nbsp;<input name=CourseShowRed type=radio value=1>��&nbsp;&nbsp;<br>" +
				span + "�༭������Ԫ��γ�</span><input name=CommonUnitCourseEditEnable type=radio checked value=0>������&nbsp;&nbsp;<input name=CommonUnitCourseEditEnable type=radio value=1>����&nbsp;&nbsp;<br>" +
				"<br><br><center><input type=button value=����Ϊ�������� id=ConfirmOption>&nbsp;<input type=button value=����ΪȫУ���� id=ConfirmOption></center></div>", 
				{title:"����ѡ��", width:420, height:460, position:"fixed"});
		ConfigWin.close = ConfigWin.hide;
		$("input[id='ConfirmOption']").on("click", ConfirmPlanOption);
		for (var x = 0; x < planOptionFields.length; x++)
		{
			var o = $("input[name='" + planOptionFields[x] + "']");
			o.eq(option[planOptionFields[x]]).prop("checked", true);
		}
		
	}

	function ConfirmPlanOption(e)
	{
		var nType = 2;
		if (e.target.value == "����Ϊ��������")
			nType = 1;
		for (var x = 0; x < planOptionFields.length; x++)
		{
			var o = $("input[name='" + planOptionFields[x] + "']");
			for (var y = 0; y < o.length; y ++)
			{
				if (o.eq(y).prop("checked"))
						option[planOptionFields[x]] = parseInt(o.eq(y).val());
			}
		}

		var fun = function (data)
		{
			if (data != "OK")
				alert(data);
			ConfigWin.hide();
			CourseEditor.Option(option);
		}
		
		var tag = "";
		for (var key in option)
			tag += "&" + key + "=" + option[key];
		$.jcom.Ajax(cfg.url + "?SavePlanOption=1&ClassID=" + classItem.Class_id + "&nType=" + nType + tag, true, "", fun);	
	}

	function SaveDoc()
	{
//		if (typeof focusFieldObj == "object")
//			blurField(focusFieldObj);
		if 	(CourseEditor.ClearClips("����������Ȼ��δ��ճ�������ݣ��������Щ���ݽ��ᶪʧ���Ƿ������\���ȷ�������������档") == false)
			return;

		var text = CourseEditor.MakeSaveFormTag();
		for (var key in classItem)
			text += "<textarea name=" + key + ">" + classItem[key] + "</textarea>";
		$.jcom.submit(location.pathname + "?SaveFlag=1", text, {fnReady:SaveOK});
		menubar.setDisabled("����", true);
	}

	function SaveOK()
	{
		var doc = $("#SaveFormFrame")[0].contentWindow.document;
		if (doc.readyState != "complete")
			return;
		menubar.setDisabled("����", false);
		var result = doc.body.innerHTML;
		if (result.substr(0,2) != "OK")
			alert("����ʧ��:" + result);
		else
		{
			alert("����ɹ�");
			document.body.onbeforeunload = null;
			location.reload(true);
		}
	}
	function ReloadClip()
	{
		var obj = resTree.getNodeObj("nType", 5);
		resTree.reloadNode(obj, true);
	}

	function ClearClips()
	{
		CourseEditor.ClearClips("����ռ������е���������,�Ƿ�ȷ����");
		ReloadClip();
	}

	function TeachUnit()
	{
		window.open("../fvs/CPB_Mode_view_TeachUnit.jsp");
	}

	function RunSubject()
	{
		window.open("..fvs/CPB_Subject_Class_view.jsp");
	}

	function RunTeacher()
	{
		window.open("../fvs/CPB_Teacher_list.jsp");
	}

	function RunTeachStyle()
	{
		window.open("../fvs/CPB_Teach_Style_view.jsp");
	}


	function SetFormModule()
	{
		if (User.EName != "admin")
			return alert("ֻ�й���Ա����ʹ�ô˹��ܡ�");
		window.open("../fvs/UserDatas_viewExcel.jsp?");
	}
	function CopyfromSyllabuses()
	{
		if (window.confirm("ֻ�в�ͨ����ѧ�ƻ�ֱ���ſεĿγ̲���Ҫ���ƣ��Ƿ������"))
		{
			document.body.onbeforeunload = null;
			location.href = location.href + "&CopyfromSyllabuses=1";
		}
	}
	
	function ExitEditor()
	{
		if (window.confirm("��Ҫ�˳��༭���Ƿ������") == false)
			return;
		cfg.mode = 0;
		PlanAttachEditor(false);		
		CourseEditor.ExitEditMode();
		self.onExit();
	};
	
	this.onExit = function ()
	{
		
	};
	init();
}

////////////////////////

var importPlanWin;
function ImportPlan()
{
  importPlanWin = new $.jcom.PopupWin("<div id=ImportForm style=width:100%;height:100%><textarea id=PlanText style=width:100%;height:540px></textarea>" +
    "<div>��ʾ�����Ƚ����Ӱ�Ľ�ѧ�ƻ��ı����ƺ�ճ�����Ϸ��ı���   <input type=button value=���� onclick=RunImportPlan(this)></div></div>", 
      {title:"�����ѧ�ƻ�", width:640, height:600, resize:0, absolute:"fixed"});
}

function RunImportPlan(obj)
{
	PlanAttachEditor(false);
	obj.disabled = true;
	obj.value = "���ڵ���...";
	var texts = $("#PlanText")[0].innerText.split("\n");
	var tmpl = [{key:"һ����ѧĿ��", id:"train_goal"},
				{key:"����ѧϰʱ��", id:"train_time"},
				{key:"������ѧ����", id:"train_style"},
				{key:"�ġ���ѧ���ݰ���", id:"train_content"},
				{key:"��ѧ", id:"CourseBegin"},
				{key:"�塢ѧϰҪ��", id:"train_claim"},
				{key:"������ѧ�ƻ���ʵʩ", alias:"������ѧ�ƻ�ʵʩ", id:"PlanPara1"},
				{key:"�ߡ�ѧϰ�ο���Ŀ", id:"Books"},
				{key:"�ˡ�����", id:"PlanNote"}];

	for (var x = 0, y = 0; x < texts.length; x++)
	{
		if ((texts[x].indexOf(tmpl[y].key) >= 0) || (texts[x].indexOf(tmpl[y].alias) >=0))
		{
			tmpl[y].pos = x;
			x ++;
			if (y ++ >= tmpl.length - 1)
				break;
		}
	}
	
	var oklog = "";
	tmpl[tmpl.length] = {id:"TheEnd", pos: texts.length - 1};
	for (var x = 0; x < tmpl.length - 1; x ++)
	{
		if ((tmpl[x].pos == undefined) || (tmpl[x + 1].pos == undefined))
		{
			oklog += "�������ʧ�ܣ�δ�ҵ�����:" + tmpl[x].key + "\n";
			continue;
		}
		oklog += "�������ɹ�:" + tmpl[x].key + "\n";
		
		var value = texts[tmpl[x].pos + 1];
		for (var y = tmpl[x].pos + 2; y < tmpl[x + 1].pos; y++)
			value += "<br>" + texts[y];
		value = value.replace(/ /g, "&nbsp;&nbsp;");
		classItem[tmpl[x].id] = value;
		$("#" + tmpl[x].id).html(value);
	}
	oklog += ImportPlanCourse(texts, tmpl[4].pos, tmpl[5].pos);
	var aUnit = CourseEditor.getUnits();
	RemoveOld(aUnit);
	$("#PlanText").val(oklog + "\n�����Զ���Ӧ����γ̵�ר����...\n");
	coursecnt = 0;
	AutoFindSubjectID(aUnit, $("#PlanText"), 0, 0, 0);
	CourseEditor.Option(option);
	PlanAttachEditor(true);
	obj.value = "�������";
}

var coursecnt = 0;
function AutoFindSubjectID(aUnit, txtobj, xx, yy, zz)
{
	var fun = function (data)
	{
		item.Subject_id = parseInt(data);
		txtobj.val(txtobj.val() + coursecnt++ + "." + item.Course_name + "����Ӧ��ר������" + item.Subject_id + "\n");
		AutoFindSubjectID(aUnit, txtobj, x, y, z);
	};
	
	for (var x = xx; x < aUnit.length - 1; x++, yy = 0, zz = 0)
	{
		
		if ((typeof aUnit[x].child == "object") && (yy < aUnit[x].child.length))
		{		
			for (var y = yy; y < aUnit[x].child.length; y++, zz = 0)
			{
				for (var z = zz; z < aUnit[x].child[y].Course.length; z++)
				{
					var item = aUnit[x].child[y].Course[z];
					if (item.Subject_id == 0)
					{
						$.jcom.Ajax(location.pathname + "?FindSubjectByName=1&Subject_name=" + item.Course_name +
							"&Teacher_name=" + item.Teacher_name, true, "", fun);
						z++;
						return;
					}
				}
			}
		}
		y = 999;
		for (var z = zz; z < aUnit[x].Course.length; z++)
		{
			var item = aUnit[x].Course[z];
			if (item.Subject_id == 0)
			{
				$.jcom.Ajax(location.pathname + "?FindSubjectByName=1&Subject_name=" + item.Course_name +
						"&Teacher_name=" + item.Teacher_name, true, "", fun);
				z++;
				return;	
			}
		}
	}
	CourseEditor.Option(option);
}

function RemoveOld(aUnit)
{
	for (var x = aUnit.length - 1; x >= 0; x--)
	{
		if (aUnit[x].newflag != 1)
		{
			var dels = aUnit.splice(x, 1);
			CourseEditor.RemoveUnit(dels[0]);
			continue;
		}
		else
			delete aUnit[x].newflag;
		
		for (var y = aUnit[x].Course.length - 1; y >= 0; y--)
		{
			if (aUnit[x].Course[y].newflag != 1)
			{
				var del = aUnit[x].Course.splice(y, 1);
				CourseEditor.RemoveCourse(del[0]);
			}
			else
				delete aUnit[x].Course[y].newflag;
		}
		
		if (typeof aUnit[x].child == "object")
			RemoveOld(aUnit[x].child);
	}

}

function ImportPlanCourse(texts, b, e)
{
	var log = "";
	if ((b == undefined) || (e == undefined))
		return log;
	var aUnit = CourseEditor.getUnits();
	var upos = 0, spos = 0, cpos = 0;
	for (var x = b; x < e; x++)
	{
		var text = $.trim(texts[x]);
		var lineType = getLineType(text);
		if (lineType == 0)
			continue;
		switch (lineType)
		{
		case 10:	//��ͨ��Ԫ
		case 11:	//���ⵥԪ
		case 12:	//ѡ�޿�
		case 15:	//���ⵥԪ+������Ԫ
		case 16:	//ѡ�޿�+������Ԫ
			var u = scanUnitName(text);
			log += "���뵥Ԫ�ɹ�:" + u.Mode_Name + "\n";
			ImportUnit(aUnit, u, upos++, lineType);
			spos = 0;
			cpos = 0;
			break;
		case 20:	//��Ԫ����Ľ�ѧ�ջ�ѧϰ��
			aUnit[upos-1].Mode_time = getUnitTime(text);
			break;
		case 30:	//��Ԫ�µĽ�ѧģ��
			var u = scanSubUnitName(text);
			log += "���뵥Ԫ�µĽ�ѧģ��ɹ�:" + u.Mode_Name + "\n";
			ImportSubUnit(aUnit[upos - 1].child, u, spos++);
			break;
		case 40:	//�γ�
			var text1 = texts[x + 1];
			var nexttype = getLineType(text1);
			if (nexttype == 60)
				x ++;
			else
				text1 = "";
			var c = scanCourse(text, text1);
			if ((spos > 0) && (aUnit[upos - 1].child[spos - 1].value != undefined))
			{
				c.Note = aUnit[upos - 1].child[spos - 1].value;
				var r = c.Teacher_name.match(/\(|��/g);
				if (r != null)
				{
					c.room = c.Teacher_name.substr(r.lastIndex, c.Teacher_name.length - r.lastIndex - 1);
					c.Teacher_name = c.Teacher_name.substr(0, r.lastIndex - 1);
					c.Note += "|" + c.room;
				}
			}
			ImportCourse(aUnit, c, upos - 1, spos - 1, cpos++);
			break;
		case 50:	//ѡ�޿��µ�����
			var y = $.jcom.makeDateObj(classItem.Class_BeginTime).getFullYear();
			var d = $.jcom.makeDateObj(y + "��" + text);
			var t = $.jcom.GetDateTimeString(d, 1) + " 15:00";
			aUnit[upos - 1].child[spos++] = {Time:text, value:t, Course:[], newflag:1};
			break;
		case 60:	//��������
			break;
		}
	}
	return log;
}

function getLineType(s, lastType)
{
	if (s == "")
		return 0;
	var pos = s.search(/\d+[\.����]/);
	if (pos >= 0)
		return 40;
	var lTmpl = [{key:"��ѧ",type:11},
		{key:"��Ԫ", type:10}, {key:"��ѧģ��", type:30},
		{key:"�����̳", type:15}, {key:"�߶˽�̳",type:15},
		{key:"���齲̳", type:15}, {key:"ר�ⱨ��", type:15},
		{key:"ʱ��ר��", type:15}, {key:"���ϰ", type:15}, 
		{key:"ѧԱ����", type:15}, {key:"ѡ�޿�", type:16},
		{key:"����ѧϰ", type:15},
		{key:"ѧϰ��", type:20}, {key:"��ѧ��", type:20}
	];
	for (var x = 0; x < lTmpl.length; x++)
	{
		var pos = s.indexOf(lTmpl[x].key); 
		if ((pos >= 0) && (pos <= 6))
			return lTmpl[x].type;		
	}
	var pos = s.search(/\d+��\d+��/);
	if (pos >=0)
		return 50;
	return 60;
}

function scanUnitName(text)
{
	var pos = text.search(/[\(\s\:����]/g);
	var u = CourseEditor.getBlankUnit();
	if (pos > 0)
	{
		u.Mode_Name = text.substr(0, pos);
		var s = $.trim(text.substr(pos + 1));
		var t = getUnitTime(s);
		if (t != undefined)
			u.Mode_time = t;
		else
		{
			if (u.Mode_Name.indexOf("��Ԫ") > 0)
				u.Mode_Name = s;
			else
				u.Mode_Note = s;
		}
	}
	else
		u.Mode_Name = text;
	if (u.Mode_Name.substr(0, 1) == "*")
	{
		u.Mode_name = u.Mode_name.substr(1);
		u.RefID = -1;		
	}
	return u;
}

function scanSubUnitName(text)
{
	var pos = text.search(/[\s\:��]/g);
	var u = CourseEditor.getBlankUnit(true);
	if (pos > 0)
		u.Mode_Name = $.trim(text.substr(pos + 1));
	return u;
}

function getUnitTime(s)
{
	var pos = s.search(/��ѧ��|ѧϰ��/);
	if (pos > 0)
	{
		var r = s.match(/\d+/);
		if (r.length > 0)
			return parseInt(r[0]);
	}
}

function scanCourse(text, text1)
{
	var c = CourseEditor.getBlankCourse(0);
	var pos = text.search(/[\.����]/g);
	if (pos >= 0)
		text = $.trim(text.substr(pos + 1));
	pos = text.search(/\s/);
	if (pos > 0)
	{
		c.Course_name = text.substr(0, pos);
		c.Teacher_name = $.trim(text.substr(pos + 1));
	}
	else
	{
		var s = $.trim(text1);
		pos = text1.search(/\S/);
		if (pos > 6)
		{
			c.Course_name = text;
			c.Teacher_name = s;
		}
		else
		{
			pos = s.search(/\s/);
			if (pos > 0)
			{
				c.Teacher_name = $.trim(s.substr(pos + 1));
				c.Course_name = text + s.substr(0, pos);
			}
			else
				c.Course_name = text + s;
		}
	}
	pos = c.Course_name.search(/(\(|��)\d��(\)|��)/);		//
	if (pos > 0)
	{
		c.Course_time = parseFloat(c.Course_name.substr(pos + 1));
		c.Course_name = c.Course_name.substr(0, pos);
	}
	if (c.Course_name.substr(0, 1) == "*")	//�����γ̼Ǻ�
	{
		c.Course_name = c.Course_name.substr(1);
		c.RefID = -1;
	}
	return c;
}

function ImportUnit(aUnit, u, pos, prop)
{
	for (var x = 0; x < aUnit.length; x++)
	{
		if (aUnit[x].Mode_Name == u.Mode_Name)
		{
			aUnit[x].newflag = 1;
			if (x == pos)
				return;
			var del = aUnit.splice(x, 1);
			aUnit.splice(pos, 0, del[0]);
			return;
		}
	}
	prop = prop % 10;
	if (((prop & 4) >> 2) > 0)
		u.RefID = -1;
	u.Mode_other = prop & 3;
	aUnit.splice(pos, 0, u);
	aUnit[pos].newflag = 1;
}

function ImportSubUnit(SubUnits, u, pos)
{
	for (var x = 0; x < SubUnits.length; x++)
	{
		if (SubUnits[x].Mode_Name == u.Mode_Name)
		{
			SubUnits[x].newflag = 1;
			if (x == pos)
				return;
			var del = SubUnits.splice(x, 1);
			SubUnits.splice(pos, 0, del[0]);
			return;
		}
	}
	u.newflag = 1;
	SubUnits.splice(pos, 0, u);
}

function getCourseByPlan(aUnit, Course)
{
	for (var x = 0; x < aUnit.length; x++)
	{
		for (var y = 0; y < aUnit[x].Course.length; y++)
		{
			if (aUnit[x].Course[y].Course_name == Course.Course_name)
			{
				var del = aUnit[x].Course.splice(y, 1);
				return del[0];
			}
		}
		
		for (var y = 0; y < aUnit[x].child.length; y++)
		{
			for (var z = 0; z < aUnit[x].child[y].Course.length; z++)
			{
				if (aUnit[x].child[y].Course[z].Course_name == Course.Course_name)
				{
					var del = aUnit[x].child[y].Course.splice(z, 1);
					return del[0];
				}
			}
		}		
	}
}

function ImportCourse(aUnit, Course, upos, spos, cpos)
{
	var c = getCourseByPlan(aUnit, Course);
	if (c != undefined)
	{
		Course.Subject_id = c.Subject_id;
		Course.Course_id = c.Course_id;
//		Course.Course_name = "*" + Course.Course_name;
	}
	var u = aUnit[upos];
	if (spos >= 0)
		u = u.child[spos];
	Course.newflag = 1;
	u.Course.splice(cpos + 1, 0, Course);
}


//////////////////////////////////////////


function PlanResTree(domobj, cfg, treecfg)
{
	var self = this;
	var classItem;
	rootItems = [{item:"����ר��", nType:2, img:"../pic/eut_bs_icon19.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
	 	{item:"������Ԫ", nType:8, img:"../pic/382.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
	 	{item:"�����γ�", nType:9, img:"../pic/eut_bs_icon16.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
		{item:"���ڿγ�", nType:6, img:"../pic/384.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
		{item:"���ڿγ�", nType:7, img:"../pic/388.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
		{item:"ר���", nType:3, img:"../pic/385.png", style:"font:normal normal normal 14px ΢���ź�;", child:null},
		{item:"������", nType:5, img:"../pic/eut_bs_icon14.png", style:"font:normal normal normal 14px ΢���ź�;", child:null}];
	$.jcom.TreeView.call(this, domobj, rootItems, treecfg, []);
	cfg = $.jcom.initObjVal({classID:0, searchJSP:""}, cfg);
	var SearchEdit = new $.jcom.DynaEditor.Edit();
	SearchEdit.config({editorMode:4});
	SearchEdit.onShow = SetSearchButton;
	SearchEdit.onBlur = CheckSearchButton;
	$("#SearchButton").on("click", ClearSearch);
	SearchEdit.onCharChange = DocSearch;
	SearchEdit.attach($("#SearchInput")[0]);

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

	function ClearSearch()
	{
//		var data = tree.getdata();
//		if (data == rootItems)
//		{		
//			$("#SearchInput")[0].fireEvent("onmousedown");
//			return;
//		}
		$("#SearchInput").html("");
		SearchEdit.checkTitle($("#SearchInput")[0], false);
		self.setdata(rootItems);
		CheckSearchButton();
	}

	function DocSearch(value)
	{
		if ($.trim(value) == "")
			return;
		$.jcom.Ajax("../fvs/CPB_Class_Course.jsp?SearchSubject=1", true, {SeekKey: value}, DocSearchOK);
	}

	function DocSearchOK(data)
	{
		var list = eval(data);
		for (var x = 0; x < list.length; x++)
		{
			if (list[x].Teacher_name == "")
			{
				list[x].Teacher_name = list[x].Informant_name;
				list[x].Teacher_id = list[x].Informant_id;
			}
			list[x].item = "<img src=../pic/384.png style=height:16px>&nbsp;" + list[x].Subject_name + "-" + list[x].Teacher_name;
			list[x].nType = 32;
//			CheckItemInCourse(item.child[x], 1);
		}
		self.setdata(list);	
	}
	
	this.loadnode = function(item, div)
	{
		var fun1 = function(data)	//�༶�γ�
		{
			var jsonData = $.jcom.eval(data);
			if (typeof jsonData == "string")
				return alert(jsonData);

			item.child = DealUnitCourse(jsonData.Mode, jsonData.Course, 1);
			self.loadnodeok(item, div);
		};
		
		var fun2 = function(data)	//??
		{
			alert(data);
			item.child = [];
			self.loadnodeok(item, div);
			
		};
		
		var fun3 = function(data)	//ר���
		{
			var treedata = $.jcom.eval(data);
			if (typeof head == "string")
				return alert(treedata);
			PrepareSubjectData(treedata);
			item.child = treedata;
			self.loadnodeok(item, div);
		};
		
		var fun4 = function(data)	//��ѧ�
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				return alert(json);
			item.child = json;
			for (var x = 0; x < json.length; x++)
			{
				item.child[x].item = "<img src=../pic/ico_groups24.gif style=height:16px>&nbsp;" + StrAdd(item.child[x].Activity_name, item.child[x].Activity_Principals);
				item.child[x].nType = 41;
//				CheckItemInCourse(item.child[x], 2);
			}
			self.loadnodeok(item, div);
		};
		
		var fun6 = function (data)	//���ڿγ�
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				return alert(json);
			item.child = json;
			for (var x = 0; x < item.child.length; x++)
			{
				item.child[x].item = "<img src=../pic/qt.png style=height:16px>&nbsp;" +  StrAdd(item.child[x].ClassCode, item.child[x].Class_Name);
				item.child[x].style = "font:normal bolder normal 14px ����;"
				item.child[x].nType = 61;
				item.child[x].child = null;
			}
			self.loadnodeok(item, div);		
		};
		
		var fun7 = function(data)	//���ڿγ�
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				return alert(json);
			item.child = json;
			for (var x = 0; x < item.child.length; x++)
			{
				item.child[x].item = "<img src=../pic/calendar16.gif style=height:16px>&nbsp;" +  item.child[x].Term_Name;
				item.child[x].nType = 71;
				item.child[x].child = null;
//				CheckItemInCourse(item.child[x], 1);
			}
			self.loadnodeok(item, div);		
		};
		
		var fun8 = function(data)	//������Ԫ
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				return alert(json);
			item.child = DealUnitCourse(json.Mode, json.Course, 0);
			self.loadnodeok(item, div);	
		};
			
		var fun31 = function(data)	//����ר��
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				return alert(json);
			item.child = json.Data;
			for (var x = 0; x < item.child.length; x++)
			{
				item.child[x].item = "<img src=../pic/wendang.png style=height:16px>&nbsp;" + StrAdd(item.child[x].Subject_name, item.child[x].Teacher_name);
				item.child[x].nType = 32;
//				CheckItemInCourse(item.child[x], 1);
			}
			self.loadnodeok(item, div);		
		};
		
		var fun9 = function (data)	//�����γ�
		{
			var json = $.jcom.eval(data);
			if (typeof json == "string")
				return alert(json);
			item.child = json;
			for (var x = 0; x < item.child.length; x++)
			{
				item.child[x].item = "<img src=../pic/yjs6.png style=height:16px>&nbsp;" + StrAdd(item.child[x].Course_name, item.child[x].Teacher_name);
				item.child[x].nType = 12;
//				CheckItemInCourse(item.child[x], 1);
			}
			self.loadnodeok(item, div);		
			
		};
		
		switch (item.nType)
		{
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
			item.child = self.getClipItem(item);
			self.loadnodeok(item, div);
			break;
		case 6:	//���ڿγ�
			$.get("../fvs/CPB_Class_Course.jsp",{getLastClass:1, DataID:classItem.Class_id}, fun6);
			break;
		case 7:	//���ڿγ�
			$.get("../fvs/CPB_Class_Course.jsp",{getOldTerm:1, DataID:classItem.Class_id}, fun7);
			break;
		case 8:		//������Ԫ
			$.get("../fvs/CPB_Class_Course.jsp",{getCommUnit:1, DataID:classItem.Class_id, Term_id:classItem.Term_id}, fun8);
			break;
		case 9:		//�����γ�
			$.get("../fvs/CPB_Class_Course.jsp",{getCommCourse:1, DataID:classItem.Class_id, Term_id:classItem.Term_id}, fun9);
			break;
		case 31:	//ר�����
			$.get("../fvs/CPB_Subject_list.jsp",{GetGridData:1, SeekKey:"CPB_Subject.Subject_class_id", SeekParam:item.Subject_Class_id}, fun31);
			break;
		case 61:	//�༶�γ�
			$.get("../fvs/CPB_Class_Course.jsp",{getClassCourseData:1, DataID:item.Class_id}, fun1);
			break;
		case 71:	//ѧ��
			$.get("../fvs/CPB_Class_Course.jsp",{getOldClass:1, Term_id:item.Term_id}, fun6);
			break;
//		case 81:	//��Ԫ�µĿγ�
//			$.get(location.pathname,{getCommUnitCourse:1, DataID:classItem.Class_id, Mode_id:item.Mode_id}, fun81);
//			break;
		}
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

	this.dblclick = function(obj, e)
	{
		var item = self.getTreeItem(obj);
		if (item.child == null)
			return self.expand(obj);
		self.ApplyItem(item, e)
	};
	
	this.ApplyItem = function (item, e)
	{
	};
	
	this.setClassItem = function(item)
	{
		classItem = item;
	};
	
	this.getClipItem = function(item)
	{
		return [];
	};
	
	this.RunSearch = function(value)
	{
		$("#SearchInput").html(value);
		SearchEdit.preshow({target:$("#SearchInput")[0]});
		DocSearch(value);
	};

}

function PlanCourseEditor(domobj, data, option, cfg)
{
var self = this;
var classItem;
var aStyle, aPlace, styleEditor, courseTimeEditor, freeBeginEditor, roomtree, roomEditor, aUnit, delCourseIds = [], delModeIds = [], BECourse = [];
var focusObj, focusTitleObj, controls, dynaEdit, unitMoreControl, courseMoreControl;
var clipUnits = [], clipSubUnits = []; clipCourses = [];

	function prepareData(jsonData)
	{	
		if ((jsonData == undefined) || (jsonData.Option == undefined))
			return;
		for (var key in jsonData.Option)			//�༶����
			option[key] = jsonData.Option[key];
		aStyle = jsonData.Style;
		aPlace = jsonData.Place;

		if (aStyle.length == 0)
			aStyle[0] = {Style_id:0, Style_name:"ר���ѧ", Style_type:0};

		aUnit = jsonData.Mode;
		if (jsonData.Mode.length == 0)
		{
			aUnit = jsonData.ModeBase;
			for (var x = 0; x < aUnit.length; x++)
			{
				aUnit[x].Class_id = classItem.Class_id;
				aUnit[x].Mode_id = 0;
				aUnit[x].Course = [];
				aUnit[x].child = [];
				AddCourseArray(aUnit[x].Course, 0, aStyle[0].Style_id);
			}
			if (jsonData.Mode.length == 0)
			{
				aUnit[0] = {};
				aUnit[0].Class_id = classItem.Class_id;
				aUnit[0].Mode_id = 0;
				aUnit[0].Course = [];
				aUnit[0].Mode_Name = "";
				aUnit[0].child = [];
				AddCourseArray(aUnit[0].Course, 0, aStyle[0].Style_id);
			}
			return;
		}
		
		if (option.CourseShowMode == 1)
		{
			for (var x = 0; x < aUnit.length; x++)
			{
				aUnit[x].Course = [];
				aUnit[x].Mode_Name = aUnit[x].item;
				for (var y = 0; y < aUnit[x].child.length; y++)
				{
					var z = 0;
					aUnit[x].child[y].Mode_Name = aUnit[x].child[y].item;
					aUnit[x].child[y].Course = [];
					for (var yy = 0; yy < jsonData.Course.length; yy++)
					{
						if (jsonData.Course[yy].Mode_id == aUnit[x].child[y].Mode_id)
						{
							aUnit[x].child[y].Course[z++] = jsonData.Course[yy];
							jsonData.Course[yy] = "";
						}
					}
//					aUnit[x].child[y].Course.sort(sortCourse);
				}
				z = 0;
				for (var y = 0; y < jsonData.Course.length; y ++)
				{
					if (jsonData.Course[y].Mode_id == aUnit[x].Mode_id)
					{
						aUnit[x].Course[z ++] = jsonData.Course[y];
						jsonData.Course[y] = "";
					}
//					aUnit[x].Course.sort(sortCourse);

				}
				if ((aUnit[x].Course.length == 0) && (aUnit[x].child.length == 0))
					AddCourseArray(aUnit[x].Course, 0, aStyle[0].Style_id);
			}
			var u = undefined, z = 0;
			for (var x = 0; x < jsonData.Course.length; x++)
			{
				if (typeof jsonData.Course[x] == "object")
				{
					if (u == undefined)
						u = self.getBlankUnit();
					u.Course[z++] = jsonData.Course[x];
				}
			}
			if (u != undefined)
				aUnit[aUnit.length]	= u;
		}
		else
		{
			for (var x = 0; x < aUnit.length; x++)
			{
				aUnit[x].Mode_Name = aUnit[x].item;
				aUnit[x].child = [];
				aUnit[x].Course = [];
				var Style_id = -1;
				for (var y = 0; y < jsonData.Course.length; y++)
				{
					if (jsonData.Course[y].Mode_id == aUnit[x].Mode_id)
					{
						if (jsonData.Course[y].Style_id != Style_id)
						{
							var zz = aUnit[x].child.length;
							Style_id = jsonData.Course[y].Style_id;
							var index = getStyleIndex(aStyle, Style_id);
							if (index == -1)
								index = 0;
							aUnit[x].child[zz] = {Style_id: jsonData.Course[y].Style_id, Style_name: aStyle[index].Style_name, Course: []};
							var z = 0;
						}
						aUnit[x].child[zz].Course[z++] = jsonData.Course[y];
					}
				}
				if (aUnit[x].child.length == 0)
				{
					aUnit[x].child[0] = {Style_id: aStyle[0].Style_id, Style_name: aStyle[0].Style_name, Course: []};					
					AddCourseArray(aUnit[x].child[0].Course, 0, aStyle[0].Style_id);
				}
			}
		}
		for (var x = 0; x < aUnit.length; x++)
		{
			if (aUnit[x].Mode_other == 2)
				PrepareFreeCourse(aUnit[x]);
		}
	}
	
	function sortCourse(a, b)
	{
		return a.nOrder - b.nOrder;
	}
	
	function PrepareFreeCourse (u)
	{
		for (var x = 0; x < u.Course.length; x++)
		{
			var ss = u.Course[x].Note.split("|");
			u.Course[x].time = ss[0];
			u.Course[x].room = "";
			if (ss.length == 2)
				u.Course[x].room = ss[1]; 
		}
		u.Course = u.Course.sort(CompareCourse);
		var d = "0000-1-1", y = 0, z = 0;
		for (var x = 0; x < u.Course.length; x++)
		{
			var ss = u.Course[x].Note.split("|");
			if (d != ss[0])
			{
				d = ss[0];
				u.child[y++] = {Time:d, Course:[]};
				z = 0;
			}
			u.Course[x].room = "";
			if (ss.length == 2)
				u.Course[x].room = ss[1]; 
			u.child[y - 1].Course[z++] = u.Course[x];
		}
		u.Course = [];
	}
	
	function UnPrepareFreeCourse(u)
	{
		var z = 0;
		for (var x = 0; x < u.child.length; x++)
		{
			if (u.child[x].Time != undefined)
			{
				for (var y = 0; y < u.child[x].Course.length; y++)
					u.Course[z++] = u.child[x].Course[y];
			}
		}
		u.child = [];
	}
	
	function getTeachText()
	{
		var tag = "";
		if (aUnit == undefined)
			return tag;
		for (var x = 0; x < aUnit.length; x++)
			tag += getUnitText(x);
		return tag;
	}

	function getUnitText(x)
	{
		var tag = "<h3 style=clear:left><em>" + getUnitChineseNo(x, aUnit) + "</em><span class=dEdit title='���뵥Ԫ����' id=U_Mode_Name_" + x + ">" + aUnit[x].Mode_Name + "</span>";
		if (option.CourseTimeEnable == 1)
			tag += "<span style='font:normal normal normal 15px ����;'>����<span class=dEdit title='������ѧϰ��' id=L_Mode_time_" + x + ">" + aUnit[x].Mode_time + "</span>��ѧϰ�գ�</span>";
		tag += "</h3><div>";
		var y = 0, z = 1;
//		if (option.CourseShowMode == 1)
//		{
			for (y = 0; y < aUnit[x].Course.length; y++)
				tag += getCourseText(x, y);
			for (y = 0; y < aUnit[x].child.length; y++)
				tag += getSubUnitText(x, y);
			return tag + "<br></div>";
//		}
/*		
		while (y < aUnit[x].Course.length)
		{
			var o = getStyleText(x, y, z);
			z ++;
			y = o.y;
			tag += o.tag;
		}
		return tag + "<br><br></div>";
*/
	}
	
	function getSubUnitText(x, y)
	{
		if (aUnit[x].child.length < y + 1)
			return "";
		
		if (aUnit[x].child[y].Time != undefined)
			var tag = "<h4 style=clear:left><em>(" + $.jcom.getChineseNumber(y + 1) + ")</em><span title=������ѡ�޿�ʱ�� class=tEdit id=Free_BeginTime_" + x + "_" + y + ">" + getAP(aUnit[x].child[y].Time) + "</span></h4><div>";
		else if (aUnit[x].child[y].Style_id != undefined)
			var tag = "<h4 style=clear:left><em>(" + $.jcom.getChineseNumber(y + 1) + ")</em><span class=dList id=Style_Name_" + x + "_" + y + ">" + aUnit[x].child[y].Style_name + "</span></h4><div>";
		else
			var tag = "<h4 style=clear:left><em>��ѧģ��" + $.jcom.getChineseNumber(y + 1) + ":</em><span class=dEdit title=�����ѧģ������ id=M_Mode_Name_" + x + "_" + y + ">" + 
				aUnit[x].child[y].Mode_Name + "</span></h4><div>";
		for (var cnt = 0; cnt < aUnit[x].child[y].Course.length; cnt++)
			tag += getCourseText(x, cnt, y);
		if (aUnit[x].child[y].Course.length == 0)
		{
			AddCourseArray(aUnit[x].child[y].Course, 0, aStyle[0].Style_id);
			tag += getCourseText(x, 0, y);
		}

		return tag + "</div>";
	}

	function getStyleIndex(aStyle, id)
	{
		for (var x = 0; x < aStyle.length; x++)
		{
			if (aStyle[x].Style_id == id)
				return x;
		}
		return -1;
	}

	function getCourseText(x, y, c)
	{
		var u = getUnitByIndex({x:x, c:c});
		var xx = x;
		if (c != undefined)
			xx = x + "_" + c;
		var index = getStyleIndex(aStyle, u.Course[y].Style_id);
		var Style_type = 0;
		if (index >= 0)
			Style_type = aStyle[index].Style_type;
		else
			index = 0;
		
		var color = "color:black";
		if (u.Course[y].Subject_id == 0)
			color = "color:red";
		var tag = "<em style=vertical-align:top;" + color + ">" + getCoursePrefix(x, y, c, u.Course[y].RefID, u.Course[y].Course_state) + "</em>";
		var nameMode = option.CourseNameMode;
		if (option.CourseShowMode == 0)
			nameMode = 0;
//		if (EditMode == 0)
//		{
//			if (nameMode == 1)
//				tag += aStyle[index].Style_name + ":"; 
//			tag += u.Course[y].Course_name + "</div>";

//			if (option.CourseLayerMode == 0)
//				tag += "<div title=�ڿ���>" + u.Course[y].Teacher_name + "&nbsp;&nbsp;&nbsp;1" + u.Course[y].Department + "</div>";
//			else
//				tag = "<div style='float:right;vertical-align:bottom;border:1px solid red;height:100%;' title=�ڿ���>" + u.Course[y].Teacher_name + "&nbsp;" + u.Course[y].Department + "</div><p style=float:left>" + tag + "</p>";
	
//			return "<div style='width:100%;border-bottom:1px solid red'>" + tag + "</div>";
//		}
		var CourseNameEditEnable = option.CourseNameEditEnable;
		if (option.CourseNameEditEnable == 2)
		{
			if (Style_type == 2)
				CourseNameEditEnable = 1;
			else
				CourseNameEditEnable = 0;
		}

		if (nameMode == 1)
			if (nameMode == 1)
				tag += "<span id=Style_Name_" + xx + "_" + y + " class=dList>" + aStyle[index].Style_name + "</span>:";
		if  (CourseNameEditEnable)
		{
			tag += "<span class=dEdit title=��ѡ�������γ����� id=S_Course_name_" + xx + "_" + y + ">" + u.Course[y].Course_name + "</span>";
		}
		else
		{
			var text = "��ӽ�ѧ��Դ��ѡ��ר��";
			if (u.Course[y].Course_name != "")
			{
				color = "color:black";
				text = u.Course[y].Course_name;
			}
			else
				color = "color:gray";

			tag += "<span id=S_Course_name_" + xx + "_" + y + " style=" + color + ";>" + text + "</span> ";
		}
		
		if (option.CourseTimeEnable == 1)
			tag += "(<span id=Course_Time_" + xx + "_" + y + " class=tList>" + getCourseTime(u.Course[y].Course_time) + "</span>)"
		var h = ""
		if (option.TeacherUnitEditEnable == 1)
			h = "class=dEdit title=�ڿ���˵�� ";
		var free = "";
		if (u.Time != undefined)	//ѡ�޿�
		{
			if (u.Course[y].room == undefined)
				u.Course[y].room = "";
			free = "(<span class=rlist title=ѡ�޿εص�>" + u.Course[y].room + "</span>)";
		}
		var teacher = u.Course[y].Teacher_name;
		if (option.TeacherEditEnable == 1)
			teacher = "<span class=dEdit title=�ڿ��� id=T_Teacher_" + xx + "_" + y + ">" + u.Course[y].Teacher_name + "</span>";
		if (option.CourseLayerMode == 0)
			tag = "<p>" + tag + "</p><div title=�ڿ���>�ڿ���:" + teacher + "&nbsp;<span " + h + "id=D_Department_" + xx + "_" + y +
				">" + u.Course[y].Department + "</span>" + free + "</div>";
		else
			tag = "<div style=float:right;clear:right title=�ڿ���>" + teacher + "&nbsp;<span " + h + "id=D_Department_" + xx + "_" + y +
				">" + u.Course[y].Department + "</span>" + free + "</div><p style=float:left;clear:left>" + tag + "</p>";
		return "<div style='width:100%;height:30px;overflow:visible;'>" + tag + "</div>";
	}
	
	function getCoursePrefix(x, y, c, RefID, state)
	{
		var z = getCourseFirstNo(x, c) + y + 1;
		var dot = ".";
		if (RefID != 0)
			dot = ".*";
		switch (state)
		{
		case 1:
			dot += "(����)";
			break;
		case 2:
			dot += "(����)";
			break;
		}
		return + z + dot +"&nbsp;";
	}
	
	
	function AddUnit(obj)
	{
		var u = self.getBlankUnit();
		AddCourseArray(u.Course, 0, aStyle[0].Style_id);
		AddOneUnit(obj, u);
	}

	this.getBlankUnit = function(subflag)
	{
		var u = {Mode_id:0, Class_id:classItem.Class_id, Mode_Name:"", 
					Mode_other:0, Mode_time:0, Note:"", CSS:"", RefID:0, Course:[]};
		if (subflag != true)
			u.child = [];
		return u;
	};
	
	function AddOneUnit(obj, u)
	{
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		var y = o.y + 1;
		aUnit.splice(y, 0, u);	
		var tag = getUnitText(y);
		obj.nextSibling.insertAdjacentHTML("afterEnd", tag);
		ReIndexUnit();
		attachEditor();
		$("#U_Mode_Name_" + y)[0].scrollIntoView();
	}

	function DeleteUnit(obj)
	{
		if (aUnit.length <= 1)
			return alert("����ɾ��������Ҫ��һ����ѧ��Ԫ.");
		if (window.confirm("��ɾ������ѧ��Ԫ�µ����н�ѧ���ݣ��Ƿ�ȷ����") == false)
			return;

		var delUnit = DelOneUnit(obj);
		self.RemoveUnit(delUnit);

//		for (var x = 0; x < delUnit.Course.length; x++)
//		{
//			if (delUnit.Course[x].Course_id > 0)
//				delCourseIds[delCourseIds.length] = delUnit.Course[x].Course_id;
//		}

//		if (delUnit.Mode_id > 0)
//			delModeIds[delModeIds.length] =  delUnit.Mode_id;
	}

	function DelOneUnit(obj)
	{
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		var dels = aUnit.splice(o.y, 1);
		obj.nextSibling.removeNode(true);
		obj.removeNode(true);
		ReIndexUnit();
		return dels[0];
	}

	function ReIndexUnit()
	{
		var em = $("h3 em");
		for (var x = 0; x < em.length; x++)
		{
			em[x].innerHTML = getUnitChineseNo(x, aUnit);
			em[x].nextSibling.id = "U_Mode_Name_" + x;
			var div = $(em[x].parentNode.nextSibling);
			if (aUnit[x].child.length == 0)
				ReIndexCourse(div, x);
			else
				ReIndexSubUnit(div, x);
		}
	}

	function CutUnit(obj)
	{
		if (aUnit.length <= 1)
			return alert("���ܼ��У�����Ҫ��һ����ѧ��Ԫ.");
		clipUnits[clipUnits.length] = DelOneUnit(obj);
		self.onClipChange();
	}

	function PasteUnit(obj)
	{
		if (clipUnits.length == 0)
			return alert("���������Ѿ�û�н�ѧ��Ԫ�ˡ�");
		for (var x = 0; x < clipUnits.length; x++)
			AddOneUnit(obj, clipUnits[x]);
		clipUnits = [];
		self.onClipChange();
	}

	function MenuAddSubUnit()
	{
		AddSubUnit(focusObj);
	}
	
	function AddSubUnit(obj)
	{
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		if (isNaN(o.x))
			o = {x:o.y, y:0};
		else
			obj = obj.parentNode.previousSibling;

		if (option.CourseShowMode == 1)
		{
			if ((aUnit[o.x].child.length > 0) && (aUnit[o.x].child[0].Time != undefined))
				var u = {Time:"", Course:[]};
			else
				var u = self.getBlankUnit(true);
		}
		else
		{
			var u = getUnitNoUsedStyle(o.x);
			if (u == undefined)
				return alert("û�и���Ľ�ѧ��ʽ��");
			u.Course = [];
		}
		attachEditor(false);
		AddOneSubUnit(obj, o, u);	
		var tag = getUnitText(o.x);
		obj.nextSibling.removeNode(true);		
		obj.insertAdjacentHTML("afterEnd", tag);
		obj.removeNode(true);
		ReIndexUnit();
		attachEditor(true);
	}
	
	function AddOneSubUnit(obj, o, u)
	{
		aUnit[o.x].child[aUnit[o.x].child.length] = u;
		if (aUnit[o.x].child.length == 1)	//������Ԫ�µĿγ��ƶ���ģ���
		{
			aUnit[o.x].child[0].Course = aUnit[o.x].Course;
			aUnit[o.x].Course = [];
		}
		else if (aUnit[o.x].child.length == 0)
			AddCourseArray(u.Course, 0, aStyle[0].Style_id);
	}

	function SetUnitComm()
	{
		var o = getCourseIndex(focusObj.firstChild.nextSibling.id);
		if (aUnit[o.y].RefID > 0)
			return alert("����ȡ��������Ԫ��");
		if (aUnit[o.y].RefID == 0)
			aUnit[o.y].RefID = -1;
		else
			aUnit[o.y].RefID = 0;
		ReIndexUnit();
	}
	
	function SetUnitOther()
	{
		var o = getCourseIndex(focusObj.firstChild.nextSibling.id);
		if (aUnit[o.y].Mode_other == 1)
			aUnit[o.y].Mode_other = 0;
		else
			aUnit[o.y].Mode_other = 1;
		ReIndexUnit();
	}
	
	function SetUnitNote()
	{
	}
	
	function SetFreeCourse()
	{
		var o = getCourseIndex(focusObj.firstChild.nextSibling.id);
		if (aUnit[o.y].Mode_other == 2)
		{
			aUnit[o.y].Mode_other = 0;
			UnPrepareFreeCourse(aUnit[o.y]);
		}
		else
		{
			aUnit[o.y].Mode_other = 2;
			if (aUnit[o.y].RefID == 0)
				aUnit[o.y].RefID = -1;
			PrepareFreeCourse(aUnit[o.y]);
		}
		var obj = focusObj;
		attachEditor(false);
		var tag = getUnitText(o.y);
		obj.nextSibling.insertAdjacentHTML("afterEnd", tag);
		obj.nextSibling.removeNode(true);
		obj.removeNode(true);
		ReIndexUnit();
		attachEditor(true);
	}
	
	function DeleteSubUnit(obj, cutflag)
	{
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		if ((option.CourseShowMode == 0) && (aUnit[o.x].child.length <= 1)) 
		{
			if (cutflag == 1)
				return alert("���ܼ��У�����Ҫ��һ�ֽ�ѧ��ʽ��");
			return alert("����ɾ��������Ҫ��һ�ֽ�ѧ��ʽ��");
		}
		if (cutflag != 1)
		{
			if (window.confirm("��ɾ���������µ�����ר�⣬�Ƿ�ȷ����") == false)
			return;
		}
		attachEditor(false);
		obj.nextSibling.removeNode(true);
		var op = obj.parentNode;
		obj.removeNode(true);
		var dels = aUnit[o.x].child.splice(o.y, 1);
		
		if ((aUnit[o.x].child.length == 0) && (aUnit[o.x].Course.length == 0))
		{
			AddCourseArray(aUnit[o.x].Course, 0, aStyle[0].Style_id);
			var tag = getCourseText(o.x, 0);
			op.insertAdjacentHTML("afterBegin",  tag);
		}
		
		ReIndexUnit();
		attachEditor(true);

		if (cutflag == 1)
			return dels[0];
		
		self.RemoveUnit(dels[0]);
//		if (dels[0].Mode_id > 0)
//			delModeIds[delModeIds.length] = dels[0].Mode_id;
//		for (var x = 0; x < dels[0].Course.length; x++)
//		{
//			if (dels[0].Course.Course_id > 0)
//				delCourseIds[delCourseIds.length] = dels[0].Course.Course_id;
//		}
	}
	
	this.RemoveUnit = function(u)
	{
		if (u.Mode_id > 0)
			delModeIds[delModeIds.length] = u.Mode_id;
		for (var x = 0; x < u.Course.length; x++)
			self.RemoveCourse(u.Course[x]);

		if (typeof u.child == "object")
		{
			for (var x = 0; x < u.child.length; x++)
				self.RemoveUnit(u.child[x]);
		}
	};
	
	this.RemoveCourse = function (c)
	{
		if (c.Course_id > 0)
			delCourseIds[delCourseIds.length] = c.Course_id;
	}
	
	function CutSubUnit(obj)
	{
		var del = DeleteSubUnit(obj, 1);
		if (del == undefined)
			return;
		clipSubUnits[clipSubUnits.length] = del;
		self.onClipChange();
	}
	
	function PasteSubUnit(obj)
	{
		if (clipSubUnits.length == 0)
			return alert("���������Ѿ�û�н�ѧģ���ˡ�");
		
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		for (var x = 0; x < clipSubUnits.length; x++)
			AddOneSubUnit(obj, o, clipSubUnits[x]);

		attachEditor(false);
		var tag = getUnitText(o.x);
		var h3 = obj.parentNode.previousSibling;
		obj.parentNode.removeNode(true);//div		
		h3.insertAdjacentHTML("afterEnd", tag);
		h3.removeNode(true);
		ReIndexUnit();
		attachEditor(true);
		clipSubUnits = [];
		
		self.onClipChange();
	}
	
	
	function getUnitNoUsedStyle(index)
	{
		var ids = [aUnit[index].child[0].Style_id];
		var z = 0;
		for (var x = 0; x < aUnit[index].child.length; x++)
		{
			if (aUnit[index].child[x].Style_id != ids[z])
			{
				ids[++z] = aUnit[index].child[x].Style_id;
			}
		}
		
		for (var x = 0; x < aStyle.length; x++)
		{
			for (var y = 0; y < ids.length; y ++)
			{
				if (ids[y] == aStyle[x].Style_id)
					break;
			}
			if (y == ids.length)
				return {Style_id: aStyle[x].Style_id, Style_name: aStyle[x].Style_name};
		}
		return;
	}

	function ReIndexSubUnit(div, x)
	{
		var em = div.find("h4 em");
		for (var y = 0; y < aUnit[x].child.length; y++)
		{
			if (aUnit[x].child[y].Time != undefined)
			{
				em[y].nextSibling.id = "Free_BeginTime_" + x + "_" + y;
			}
			else if (aUnit[x].child[y].Style_id != undefined)
			{
				em[y].innerText = "(" + $.jcom.getChineseNumber(y + 1) + ")";
				em[y].nextSibling.id = "Style_Name_" + x + "_" + y;
			}
			else
			{
				em[y].innerText = "��ѧģ��" + $.jcom.getChineseNumber(y + 1) + ":";
				em[y].nextSibling.id = "M_Mode_Name_" + x + "_" + y;
			}
			var divsub = $(em[y].parentNode.nextSibling);
			ReIndexCourse(divsub, x, y);
		}		
	}
	
	function ReIndexCourse(div, x, c)
	{
		var p = div.find("p");
		var z = getCourseFirstNo(x, c);
		var aU = aUnit[x];
		if (c != undefined)
		{
			aU = aU.child[c];
			x = x + "_" + c;
		}
		for (var y = 0; y < aU.Course.length; y++)
		{
			z++;
			p[y].firstChild.nextSibling.id = "S_Course_name_" + x + "_" + y;
			p[y].firstChild.innerHTML = z + ".&nbsp;";
		}
	}
	
	function getCourseFirstNo(index, c)
	{
		if (option.CourseNoMode == 0)
			return 0;
		var cnt = 0;
		for (var x = 0; x < index; x++)
		{
			cnt += aUnit[x].Course.length;
			for (var y = 0; y < aUnit[x].child.length; y++)
				cnt += aUnit[x].child[y].Course.length;
		}
		if ((aUnit[index].child.length == 0) || (c== undefined))
			return cnt;
		for (var x = 0; x < c; x++)
			cnt += aUnit[index].child[x].Course.length;
		return cnt;
	}

	function AddCourse(obj)
	{
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		var u = getUnitByIndex(o);
		var	Style_id = u.Course[o.y].Style_id;
		var c = AddCourseArray(u.Course, o.y + 1, Style_id);
		if (typeof u.Time != "undefined")
			c.Note = u.Time;
		attachEditor(false);
		var tag = getCourseText(o.x, o.y + 1, o.c);
		obj.parentNode.insertAdjacentHTML("afterEnd", tag);
		ReIndexUnit();
		attachEditor(true);
	}

	function getCourseIndex(id)
	{
		var o = {};	
		var ss = id.split("_");
		o.x = parseInt(ss[ss.length - 2]);
		if (parseInt(ss[ss.length - 3]) >= 0)
		{
			o.c = o.x;
			o.x = parseInt(ss[ss.length - 3]);
		};
		o.y = parseInt(ss[ss.length - 1]);
		return o;
	}

	function getUnitByIndex(o)
	{
		if (o.c == undefined)
		{
			if (isNaN(o.x))
				return aUnit[o.y];
			return aUnit[o.x];
		}
		return aUnit[o.x].child[o.c];
	}
	
	function AddCourseArray(aCourse, y, Style_id)
	{
		var o = self.getBlankCourse(Style_id);
		if (y >= aCourse.length)
			aCourse[aCourse.length] = o;
		else
			aCourse.splice(y, 0, o);
		return o;
	}

	this.getBlankCourse = function (Style_id)
	{
		var o = {Course_id:0, Subject_id:0, Style_id:Style_id, Course_name:"", Course_time:0.5, Note:"", Teacher_id:"", Teacher_name:"", Department:"", RefID:0, Course_state: 0};
		return o;
	};
	
	function DeleteCourse(obj, cutflag)
	{
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		var u = getUnitByIndex(o);
		if (u.Course.length <= 1)
		{
			if (cutflag == 1)
				return alert("���ܼ��У�����Ҫ��һ�ſγ̡�");
			return alert("����ɾ��������Ҫ��һ�ſγ̡�");
		}
		if (cutflag != 1)
		{
			if (window.confirm("��ɾ����ר�⣬�Ƿ�ȷ����") == false)
				return;
		}
		var dels = u.Course.splice(o.y, 1);
		obj.parentNode.removeNode(true);
		ReIndexUnit();
		if (cutflag == 1)
			return dels[0];
		self.RemoveCourse(dels[0]);
//		if (dels[0].Course_id > 0)
//			delCourseIds[delCourseIds.length] = dels[0].Course_id;
	}

	function CutCourse(obj)
	{
		var del = DeleteCourse(obj, 1);
		if (del == undefined)
			return;
		clipCourses[clipCourses.length] = del;
		self.onClipChange();
	}

	function PasteCourse(obj)
	{
		if (clipCourses.length == 0)
			return alert("���������Ѿ�û�пγ��ˡ�");
		
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		var u = getUnitByIndex(o);
		var	Style_id = u.Course[o.y].Style_id;
		var tag = "";
		for (var x = 0; x < clipCourses.length; x++)
		{
			if (option.CourseShowMode == 0)
				clipCourses[x].Style_id = Style_id;
			u.Course.splice(o.y + 1, 0, clipCourses[x]);
			tag += getCourseText(o.x, o.y + 1, o.c);
		}
		obj.parentNode.insertAdjacentHTML("afterEnd", tag); 
		ReIndexUnit();
		clipCourses = [];
		self.onClipChange();
	}

	this.ClearClips = function(str) 
	{
		if ((clipUnits.length == 0) && (clipSubUnits.length == 0) && (clipCourses.length == 0))
			return true;
		if (str != undefined)
		{
			if (window.confirm(str) == false)
				return false;
		}
		
		for (var x = 0; x < clipUnits.length; x++)
		{
			if (clipUnits[x].Mode_id > 0)
				delModeIds[delModeIds.length] =  clipUnits[x].Mode_id;
			for (var y = 0; y < clipUnits[x].child.length; y++)
			{
				if (clipUnits[x].child[y].Mode_id > 0)
					delModeIds[delModeIds.length] =  clipUnits[x].child[y].Mode_id;
				for (var z = 0; z < clipUnits[x].child[y].Course.length; z++)
				{
					if (clipUnits[x].child[y].Course[z].Course_id > 0)
						delCourseIds[delCourseIds.length] = clipUnits[x].child[y].Course[z].Course_id;		
				}
			}
			for (var y = 0; y < clipUnits[x].Course.length; y++)
			{
				if (clipUnits[x].Course[y].Course_id > 0)
					delCourseIds[delCourseIds.length] = clipUnits[x].Course[y].Course_id;		
			}
		}
		clipUnits = [];
		for (var x = 0; x < clipSubUnits.length; x++)
		{
			for (var y = 0; y < clipSubUnits[x].length; y++)
			{
				if (clipSubUnits[x][y].Course_id > 0)
					delCourseIds[delCourseIds.length] = clipSubUnits[x][y].Course_id;		
			}
		}
		clipSubUnits = [];
		for (var x = 0; x < clipCourses.length; x++)
		{
			if (clipCourses[x].Course_id > 0)
				delCourseIds[delCourseIds.length] = clipCourses[x].Course_id;		
		}
		clipCourses = [];
		return true;
	};

	function styleChange(obj)
	{
		var index = parseInt(obj.node);
		var o = getCourseIndex(obj.id);
		if (option.CourseShowMode == 1)
		{
			var u = getUnitByIndex(o);
			u.Course[o.y].Style_id = aStyle[index].Style_id;
			return;
		}

		for (var x = 0; x < aUnit[o.x].child[o.y].Course.length; x++)
			aUnit[o.x].child[o.y].Course[x].Style_id = aStyle[index].Style_id;
		
//		var o = getStyleCourse(o.x, o.y);
//		obj.parentNode.nextSibling.innerHTML = o.tag;
	}

	function courseTimeChange(obj)
	{
		var o = getCourseIndex(obj.id);
		var u = getUnitByIndex(o);
		u.Course[o.y].Course_time = obj.node;
		if (u.Course[o.y].RefID > 0)
			u.Course[o.y].RefID = -1;
	}
	
	function freeBeginChange(obj)
	{
		var o = getCourseIndex(obj.id);
		for (var x = 0; x < aUnit[o.x].child[o.y].Course.length; x++)
		{
			var Note = aUnit[o.x].child[o.y].Course[x].Note;
			var ss = Note.split("|");
			aUnit[o.x].child[o.y].Course[x].Note = obj.innerText;
			if (ss.length == 2)
				aUnit[o.x].child[o.y].Course[x].Note = obj.innerText + "|" + ss[1];
			if (aUnit[o.x].child[o.y].Course[x].RefID > 0)
				aUnit[o.x].child[o.y].Course[x].RefID = -1;
		}
		freeBeginEditor.setValue(obj.innerText, getAP(obj.innerText));
//		obj.innerText = getAP(obj.innerText);
	}
	
	function getAP(date)
	{
		if ($.trim(date) == "")
			return "";
		var d = date.split(" ");
		if (d.length < 2)
			return d;
		var ss = d[1].split(":");
		var h = parseInt(ss[0]);
		if (h < 12)
			return d[0] + " ����";
		if (h < 18)
			return d[0] + " ����";
		return d[0] + " ����";
	}
	
	function roomEditorChange(obj)
	{
		var o = getCourseIndex(obj.parentNode.firstChild.nextSibling.id);
		var u = getUnitByIndex(o);
		var ss = u.Course[o.y].Note.split("|");
		u.Course[o.y].Note = ss[0] + "|" + obj.innerText;
		if (u.Course[o.y].RefID > 0)
			u.Course[o.y].RefID = -1;
	}
	
	function attachEditor(flag)
	{
		if (flag == false)
		{
			$(controls).detach();
			focusTitleObj = undefined;
		}
		
		var o = $(".dEdit", domobj);
		for (var x = 0; x < o.length; x++)
		{
			if ((flag == false) || (flag == undefined))
				dynaEdit.detach(o[x]);
			if ((flag == true) || (flag == undefined))
				dynaEdit.attach(o[x]);
		}
		o = $(".dList", domobj);
		for (var x = 0; x < o.length; x++)
		{
			if ((flag == false) || (flag == undefined))
				styleEditor.detach(o[x]);
			if ((flag == true) || (flag == undefined))
				styleEditor.attach(o[x]);
		}
		o = $(".tList", domobj);
		for (var x = 0; x < o.length; x++)
		{
			if ((flag == false) || (flag == undefined))
				courseTimeEditor.detach(o[x]);
			if ((flag == true) || (flag == undefined))
				courseTimeEditor.attach(o[x]);
		}
		o = $(".tEdit", domobj)
		for (var x = 0; x < o.length; x++)
		{
			if ((flag == false) || (flag == undefined))
				freeBeginEditor.detach(o[x]);
			if ((flag == true) || (flag == undefined))
				freeBeginEditor.attach(o[x]);
		}
		o = $(".rlist", domobj)
		for (var x = 0; x < o.length; x++)
		{
			if ((flag == false) || (flag == undefined))
				roomEditor.detach(o[x]);
			if ((flag == true) || (flag == undefined))
				roomEditor.attach(o[x]);
		}
		
		
	}
	
	function ShowControl(event)
	{
		var o = findObj(event.target);
		if (o == focusTitleObj)
			return;
		if (typeof focusTitleObj == "object")
		{
			$(controls).detach();
			focusTitleObj = undefined;
		}

		focusTitleObj = o;
		if (typeof o != "object")
			return;
		var a = $("a", controls);
		switch (o.tagName)
		{
		case "H3":
		case "P":
			a.eq(4).css("display", "inline");
			$(o).append(controls);
			break;
		case "H4":
			a.eq(4).css("display", "none");
			$(o).append(controls);
			break;
		}
//		a.css("display", "inline");
	}

	function ShowFocus(event)
	{
		var o;
		if (typeof event == "object")
		{
			o = findObj(event.target);
			if (o == focusObj)
				return;
		}
		if (typeof focusObj == "object")
		{
			$(focusObj.firstChild).css("backgroundColor", "white");
			focusObj = undefined;
		}

		if (typeof o != "object")
			return;
		switch (o.tagName)
		{
		case "H3":
		case "H4":
		case "P":
			focusObj = o;
			$(focusObj.firstChild).css("backgroundColor", "#c0c0c0");
			break;
		}
	}
	
	function DocDblClick(event)
	{
		if (typeof focusObj != "object")
			return;
		var o = getCourseIndex(focusObj.firstChild.nextSibling.id);
		switch (focusObj.tagName)
		{
		case "H3":
			self.onDblClick(1, focusObj, aUnit[o.y], event);
			break;
		case "H4":
			self.onDblClick(2, focusObj, aUnit[o.x].child[o.c], event);
			break;
		case "P":
			var u = getUnitByIndex(o);
			self.onDblClick(3, focusObj, u.Course[o.y], event);
			break;
		}
	}
	
	this.onDblClick = function(nType, obj, item, event)
	{
		switch (nType)
		{
		case 1:
		case 2:
			break;
		case 3:
			CheckCourse(obj, item, event);
			break;
		}		
	};

	var checkCourseBox, courseItem;
	function CheckCourse(obj, item, event)
	{
		if (item.Course_name == "")
			return;
		courseItem = item;
		var tag = "&nbsp;������<span style=cursor:hand;color:blue onclick=CheckCourseValue(1)>��ר�����Ƽ���</span>, " +
					"&nbsp;������:<span style=cursor:hand;color:blue onclick=CheckCourseValue(2)>���ڿ��˼���</span>";
		CheckCourseValue(1);
		var fun = function (data)
		{
			alert(data);
		};
		if (item.Subject_id == 0)
		{
			tag = "&nbsp;<input id=SaveCourseToSubject type=button value=���γ̼���ר��� onclick=SaveCourseToSubject(this)>" +
				"<br>&nbsp;��ʾ������ר����أ���ȷ��ר������޴�ר��ʱ����Ӧ���γ̼���ר��� ��<br>Ϊ��Ч���أ�<br>" + tag;
		}
		else
			tag += "<br>&nbsp;��������ֿγ̶�Ӧ����ר�����ƻ��ڿ��˲�׼ȷ��<br>��������ֱ���޸Ŀγ����ƺ��ڿ��ˣ����޸ĺ�:<input id=SaveCourseToSubject type=button value=���浽ר��� onclick=SaveCourseToSubject(this)>&nbsp;";
		var pos = $.jcom.getObjPos(obj);
		if (checkCourseBox == undefined)
		{
			checkCourseBox = new $.jcom.PopupBox("", pos.left, pos.top, pos.left, pos.bottom - 1);
			var o = checkCourseBox.getdomobj();
			o.style.border = "1px solid gray";
			o.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray)";
		}
		checkCourseBox.setPopObj(tag);
		checkCourseBox.show(pos.left, pos.top, pos.left, pos.bottom - 1);
		$("#SaveCourseToSubject").attr("disabled", false)
		$(document).on("mousedown",CourseBoxHide);
	}


	function SaveCourseToSubject(obj)
	{
		var fun = function (data)
		{
			courseItem.Subject_id = parseInt(data);
			var o = $("Q", CourseEditor.getFocusObj());
			o.css("color", "black");
			checkCourseBox.hide();
		}
		$.jcom.Ajax(location.pathname + "?SaveCourseToSubject=1&Subject_id=" + courseItem.Subject_id + "&Subject_name=" + courseItem.Course_name +
			"&Teacher_name=" + courseItem.Teacher_name + "&Department=" + courseItem.Department, true, "", fun);	
		obj.disabled = true;	
	}

	function CourseBoxHide(e)
	{
		var b = checkCourseBox.getdomobj();
		if ((b == e.target) || ($(e.target).parents().is($(b))))
			return;
		$(document).off("mousedown",CourseBoxHide);
		checkCourseBox.hide();	
	}

	function CheckCourseValue(ntype)
	{
		if (ntype == 1)
			var value = courseItem.Course_name;
		else
			var value = courseItem.Teacher_name;
		self.SearchReq(value);
	}
	
	this.SearchReq = function (value)
	{	
	};
	
	function findObj(o)
	{
		try
		{
			if (o.parentNode.parentNode.firstChild.tagName == "EM")
				return o.parentNode.parentNode;
			if (o.parentNode.firstChild.tagName == "EM")
				return o.parentNode;
			if ((o.firstChild != null) && (o.firstChild.tagName == "EM"))
				return o;
			if ((o.parentNode.firstChild.nextSibling.firstChild != null) && (o.parentNode.firstChild.nextSibling.firstChild.tagName == "EM"))
				return o.parentNode.firstChild.nextSibling;
			if ((o.firstChild.nextSibling.firstChild != null) && (o.firstChild.nextSibling.firstChild.tagName == "EM"))
				return o.firstChild.nextSibling;
		}
		catch (e)
		{
		}
	}
	
	function ControlRun(e)
	{
		if (focusTitleObj == undefined)
			return;
		var o = e.target.parentNode.parentNode;
		switch (focusTitleObj.tagName + "_" + e.target.innerText)
		{
		case "H3_���":
			AddUnit(o);
			break;
		case "H3_ɾ��":
			DeleteUnit(o);
			break;
		case "H3_����":
			CutUnit(o);
			break;
		case "H3_ճ��":
			PasteUnit(o);
			break;
		case "H3_......":
			UnitMoreMenuShow(o, e);
			break;
		case "H4_���":
			AddSubUnit(o);
			break;
		case "H4_ɾ��":
			DeleteSubUnit(o);
			break;
		case "H4_����":
			CutSubUnit(o);
			break;
		case "H4_ճ��":
			PasteSubUnit(o);
			break;
		case "P_���":
			AddCourse(o);
			break;
		case "P_ɾ��":
			DeleteCourse(o);
			break;
		case "P_����":
			CutCourse(o);
			break;
		case "P_ճ��":
			PasteCourse(o);
			break;
		case "P_......":
			CourseMoreMenuShow(o, e);
			break;
		}
	}

	function UnitMoreMenuShow(obj, e)
	{
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		var u = getUnitByIndex(o);
		var item = unitMoreControl.getmenu("����Ϊ���ⵥԪ");
		if (u.Mode_other == 1)
			item.img = "../pic/flow_end.png";
		else
			item.img = "";

		var item = unitMoreControl.getmenu("����Ϊѡ�޿�");
		if (u.Mode_other == 2)
			item.img = "../pic/flow_end.png";
		else
			item.img = "";
			
		var item = unitMoreControl.getmenu("����Ϊ������Ԫ");
		if (u.RefID != 0)
			item.img = "../pic/flow_end.png";
		else
			item.img = "";
		var pos = $.jcom.getObjPos(e.target);
		unitMoreControl.show(pos.left, pos.bottom, pos.left, pos.bottom);
	}
	
	function CourseMoreMenuShow(obj, e)
	{
		var o = getCourseIndex(obj.firstChild.nextSibling.id);
		var u = getUnitByIndex(o);
		var item = courseMoreControl.getmenu("����Ϊ�����γ�");
		if (u.Course[o.y].RefID != 0)
			item.img = "../pic/flow_end.png";
		else
			item.img = "";
		var item = courseMoreControl.getmenu("����Ϊʹ�ÿγ�");
		if (u.Course[o.y].Course_state == 0)
			item.img = "../pic/flow_end.png";
		else
			item.img = "";
		var item = courseMoreControl.getmenu("����Ϊ���ÿγ�");
		if (u.Course[o.y].Course_state == 1)
			item.img = "../pic/flow_end.png";
		else
			item.img = "";
		var item = courseMoreControl.getmenu("����Ϊ���ÿγ�");
		if (u.Course[o.y].Course_state == 2)
			item.img = "../pic/flow_end.png";
		else
			item.img = "";
		
		var pos = $.jcom.getObjPos(e.target);
		courseMoreControl.show(pos.left, pos.bottom, pos.left, pos.bottom);
	}
	
	function SetCommonCourse()
	{
		var o = getCourseIndex(focusObj.firstChild.nextSibling.id);
		var u = getUnitByIndex(o);
		if (u.Course[o.y].RefID > 0)
			return alert("�ÿγ̲��ܸ�Ϊ�ǹ����γ̡�");
		if (u.Course[o.y].RefID == 0)
			u.Course[o.y].RefID = -1;
		else if (u.Course[o.y].RefID == -1)
			u.Course[o.y].RefID = 0;

		$("EM", focusObj).html(getCoursePrefix(o.x, o.y, o.c, u.Course[o.y].RefID, u.Course[o.y].Course_state));
	}
	
	function SetCourseState(obj, def)
	{
		var state = 0;
		switch (def.item)
		{
		case "����Ϊʹ�ÿγ�":
			state = 0;
			break;
		case "����Ϊ���ÿγ�":
			state = 1;
			break;
		case "����Ϊ���ÿγ�":
			state = 2;
			break;
		}
		var o = getCourseIndex(focusObj.firstChild.nextSibling.id);
		var u = getUnitByIndex(o);
		u.Course[o.y].Course_state = state;
		$("EM", focusObj).html(getCoursePrefix(o.x, o.y, o.c, u.Course[o.y].RefID, state));
	}

	function DelStateCourse(obj)
	{
		
	}
	
	function EditChange(obj)
	{
		var value = obj.innerText;
		switch (obj.id.substr(0, 1))
		{
		case "B":		//����ʽ
			BECourse[0][obj.id.substr(2)] = value;
			break;
		case "F":		//��ҵʽ
			BECourse[1][obj.id.substr(2)] = value;
			break;
		case "U":		//��ѧ��Ԫ
			var o = getCourseIndex(obj.id);
			aUnit[o.y].Mode_Name = value;
			if (aUnit[o.y].RefID > 0)
				aUnit[o.y].RefID = -1;
			break;
		case "L":		//�γ� ʱ��
			var o = getCourseIndex(obj.id);
			value = parseFloat(value);
			if (isNaN(value))
				obj.innerText = 0;
			else
				aUnit[o.y].Mode_time = value;
			break;
		case "S":		//�γ�����
			var o = getCourseIndex(obj.id);
			var u = getUnitByIndex(o);
			u.Course[o.y].Course_name = value;
			break;
		case "T":		//�ڿ���
			var o = getCourseIndex(obj.id);
			var u = getUnitByIndex(o);
			u.Course[o.y].Teacher_name = value;
			break;
		case "M":		//��ѧģ��
			var o = getCourseIndex(obj.id);
			aUnit[o.x].child[o.y].Mode_Name = value;
			break;
		case "D":		//�ڿ��˵�λ����
			var o = getCourseIndex(obj.id);
			var u = getUnitByIndex(o);
			u.Course[o.y].Department = value;
			break;
		default:
			alert(obj.id);
			break;
		}
	}
	
	function findBlankCourse()
	{
		var o, z;
		for (var x = 0; x < aUnit.length; x++)
		{
			for (var y = 0; y < aUnit[x].child.length; y++)
			{
				z = findBlankCoursefromUnit(aUnit[x].child[y]);
				if (z >= 0)
				{
					o = $("#S_Course_name_" + x + "_" + y + "_" + z, domobj);
					break;
				}
			}
			if (o == undefined)
			{
				z = findBlankCoursefromUnit(aUnit[x]);
				if (z >= 0)
					o = $("#S_Course_name_" + x + "_" + z, domobj);
			}
			if (o != undefined)
				break;
		}
		return o;
	}
	
	function findBlankCoursefromUnit(u)
	{
		for (var x = 0; x < u.Course.length; x++)
		{
			if (u.Course[x].Course_name == "")
				return x;
		}
		return -1;
	}
	
	this.ApplyCourseItem = function(item)
	{
		if (typeof focusObj != "object")
		{
			var o = findBlankCourse();
			if (o == undefined)
				return alert("����ѡ��һ����Ҫ���µ�ר�⡣");
			o[0].scrollIntoView();
			focusObj = o[0].parentNode;
			$(focusObj.firstChild).css("backgroundColor", "#c0c0c0");
			return;
		}
		var obj = focusObj.firstChild.nextSibling;
		if (obj.id.substr(0, 1) != "S")
		{
			ShowFocus();
			self.ApplyCourseItem(item);
			return;
		}
		var o = getCourseIndex(obj.id);
		var u = getUnitByIndex(o);
		if ((item.RefID > 0) && (u.Course[o.y].RefID != 0))	
			return alert("�����γ̲������滻�����γ�.");

		if (item.Subject_name == undefined)
		{
			u.Course[o.y].Course_name = item.Course_name;
			u.Course[o.y].Department = item.Department;
		}
		else
		{
			u.Course[o.y].Course_name = item.Subject_name;
			u.Course[o.y].Department = item.Department_name;
		}
		u.Course[o.y].Subject_id = item.Subject_id;
		if (u.Course[o.y].Teacher_name == "")
		{
			u.Course[o.y].Teacher_id = item.Teacher_id;
			u.Course[o.y].Teacher_name = item.Teacher_name;
		}
		if ((item.RefID > 0) && (u.Course[o.y].RefID == 0))	//�����γ̿����滻�ǹ����γ�
			u.Course[o.y].RefID = item.RefID;
		else if (u.Course[o.y].RefID > 0)
			u.Course[o.y].RefID = -1;
		attachEditor(false);
		var tag = getCourseText(o.x, o.y, o.c);
		focusObj.parentNode.insertAdjacentHTML("afterEnd", tag);
		focusObj.parentNode.removeNode(true);
		focusObj = undefined;
		attachEditor(true);
		return true;
//		obj.innerHTML = item.Subject_name + "<br>�ڿ���:" + item.Teacher_name + "&nbsp;<span id=D_Department_" + o.x + "_" + o.y + "title=�ڿ��˵�λ������>" + item.Department_name + "</span>";
//		obj.style.color = "black";
	};
	
	this.getFocusObj = function()
	{
		return focusObj;
	};
	
	this.ApplyUnits = function (units)
	{
		for (var x = 0; x < units.length; x++)
			self.ApplyOneUnit(units[x], true);
		self.Option(option);
	};
	
	this.ApplyOneUnit = function (unit, flag)
	{
		var u = $.jcom.initObjVal(unit,{});
		delete u.item;
		if (u.RefID > 0)
		{
			for (var x = 0; x < aUnit.length; x++)
			{
				if (aUnit[x].RefID == u.RefID)		//�Ѿ������ˡ�
					return false;
			}
		}

		u.Mode_id = 0;
		if (flag)
		{
			var child = u.child;
			u.Course = [];
			u.child = [];
			for (var x = 0; x < child.length; x++)
			{
				if ((typeof child[x].Mode_Name == "string") || (typeof child[x].Time != "undefined"))	//��ѧģ���ѡ�޿�
				{
					var su = $.jcom.initObjVal(child[x], {});
					delete su.item;
					delete su.child;
					su.Mode_id = 0;
					var z = u.child.length;
					u.child[z] = su;

					u.child[x].Course = [];
					for (var y = 0; y < child[x].child.length; y++)
					{
						var c = $.jcom.initObjVal(child[x].child[y], {});
						c.Course_id = 0;
						delete c.item;
						u.child[z].Course[u.child[z].Course.length] = c;
					}
				}
				else	//�γ�
				{
					var c = $.jcom.initObjVal(child[x], {});
					c.Course_id = 0;
					delete c.item;
					u.Course[u.Course.length] = c;
				}
			}
		}
		aUnit[aUnit.length] = u;
	};
	
	this.getUnits = function ()
	{
		return aUnit;
	};
	
	this.getClip = function()
	{
		return {clipUnits: clipUnits, clipSubUnits: clipSubUnits, clipCourses: clipCourses};
	};
	
	this.onClipChange = function ()
	{
	};
	
	this.getUnitCourse = function (nUnit)
	{
		if (nUnit == undefined)
			return aUnit;
		return aUnit[nUnit].Course;
	};
		
	this.MakeSaveFormTag = function()
	{
		var text = "<input name=delModeIds value='" + delModeIds.join(",") + "'>";
		text += "<input name=delCourseIds value='" + delCourseIds.join(",") + "'>";
		
		for (var x = 0; x < aUnit.length; x++)
		{
			text += "<input name=Mode_id value='" + aUnit[x].Mode_id + "'>";
			text += "<input name=Mode_Name value='" + aUnit[x].Mode_Name + "'>";
			text += "<input name=Mode_other value='" + aUnit[x].Mode_other + "'>";
			text += "<input name=Mode_time value='" + aUnit[x].Mode_time + "'>";
			text += "<input name=RefID value='" + aUnit[x].RefID + "'>";
			for (var y = 0; y < aUnit[x].Course.length; y++)
			{
				if ((aUnit[x].Course[y].Course_id == 0) && (aUnit[x].Course[y].Course_name == ""))
					continue;
				text += makeCourseTag(x, aUnit[x].Course[y], aUnit[x].RefID);
			}
			
			for (var y = 0; y < aUnit[x].child.length; y++)
			{
				if (aUnit[x].child[y].Mode_Name == undefined)
				{
					for (var z = 0; z < aUnit[x].child[y].Course.length; z++)
					{
						if ((aUnit[x].child[y].Course[z].Course_id == 0) && (aUnit[x].child[y].Course[z].Course_name == ""))
							continue;
						text += makeCourseTag(x, aUnit[x].child[y].Course[z], aUnit[x].RefID);
					}
				}
				else
				{
					text += "<input name=SubMode_id_" + x + " value='" + aUnit[x].child[y].Mode_id + "'>";
					text += "<input name=SubMode_Name_" + x + " value='" + aUnit[x].child[y].Mode_Name + "'>";
					if ((aUnit[x].RefID != 0) && (aUnit[x].child[y].RefID == 0))
						aUnit[x].child[y].RefID = -1;
					text += "<input name=RefID_" + x + " value='" + aUnit[x].child[y].RefID + "'>";
					
					for (var z = 0; z < aUnit[x].child[y].Course.length; z++)
					{
						if ((aUnit[x].child[y].Course[z].Course_id == 0) && (aUnit[x].child[y].Course[z].Course_name == ""))
							continue;
						text += makeCourseTag(x + "_" + y, aUnit[x].child[y].Course[z], aUnit[x].RefID);
					}
				}
			}
		}
		for (var x = 0; x < BECourse.length; x++)
		{
			for (var key in BECourse[x])
				text += "<input name=" + key + " value='" + BECourse[x][key] + "'>";
		}
		return text;
	};
	
	function makeCourseTag(suf, Course, RefID)
	{
		if ((RefID != 0) && (Course.RefID == 0))
			Course.RefID = -1;
		var text = "<input name=Course_id_" + suf + " value='" + Course.Course_id + "'>";
		text += "<input name=Subject_id_" + suf + " value='" + Course.Subject_id + "'>";
		text += "<input name=Style_id_" + suf + " value='" + Course.Style_id + "'>";
		text += "<input name=Course_name_" + suf + " value='" + Course.Course_name + "'>";
		text += "<input name=Teacher_id_" + suf + " value='" + Course.Teacher_id + "'>";
		text += "<input name=Teacher_name_" + suf + " value='" + Course.Teacher_name + "'>";
		text += "<input name=Department_" + suf + " value='" + Course.Department + "'>";
		text += "<input name=Course_time_" + suf + " value='" + Course.Course_time + "'>";
		text += "<input name=Note_" + suf + " value='" + Course.Note + "'>";
		text += "<input name=RefID_" + suf + " value='" + Course.RefID + "'>";
		text += "<input name=Course_state_" + suf + " value='" + Course.Course_state + "'>";
		return text;
	}
	
	this.setBECourse = function(div, option)
	{
		if (typeof div != "object")
			return;
		var Course = data.Course;
		BECourse = [{}, {}];
		BECourse[0] = {BE_id:0, BETime:classItem.Class_BeginTime, BEname:"����ʽ", BEaddress:classItem.train_address, BEnote:""};
		BECourse[1] = {BE_id:0, BETime:classItem.Class_EndTime, BEname:"��ҵʽ", BEaddress:classItem.train_address, BEnote:""};
		for (var x = 0; x < Course.length; x++)
		{
			if (Course[x].Mode_id == 0)
			{
				var beitem;
				if (Course[x].Course_name == "��ҵʽ")
					var beitem = BECourse[1];
				else if (Course[x].Course_name == "����ʽ")
					beitem = BECourse[0];
				else
				{
					aUnit[0].Course[aUnit[0].Course.length] = Course[x];
					continue;
				}
				beitem.BE_id = Course[x].Course_id;
				var ss = Course[x].Note.split("|");
				if (ss.length >= 2)
				{
					beitem.BETime = ss[0];
					beitem.BEaddress = ss[1];
					beitem.BEnote = ss[2];
				}
			}
		}
		var tag = "<p>1��<span id=B_BETime class=dedit title=����ʽʱ��>" + $.jcom.GetDateTimeString(BECourse[0].BETime, 12) +  "</span>��" +
			"<span id=B_BEaddress class=dedit title=����ʽ�ص�>" + BECourse[0].BEaddress + "</span>���п�����ʽ��<span id=B_BEnote class=dedit title=����ʽ��ע>" + BECourse[0].BEnote + "<span></p>" +
			"<p>2��<span id=F_BETime class=dedit title=����ʽʱ��>" + $.jcom.GetDateTimeString(BECourse[1].BETime, 12) +  "</span>��" +
			"<span id=F_BEaddress class=dedit title=��ҵʽ�ص�>" + BECourse[0].BEaddress + "</span>���н�ҵ��ʽ��<span id=F_BEnote class=dedit title=��ҵʽ��ע>" + BECourse[0].BEnote + "<span></p>";
		div.innerHTML = tag;
		if (cfg.mode > 0)
		{
		}
	};
	
	this.Option = function (o)
	{
		if (o == undefined)
			return option;
		option = o;
		attachEditor(false);	
		var tag = getTeachText();	//$(domobj).html(getTeachText());�ô˷������¼���������ľֲ�������Ϊʲô��
		domobj.innerHTML = tag;
		attachEditor(true);
	};
	
	this.LoadCoursePlan = function (classObj, courses, mode)
	{
		classItem = classObj;
		data = courses;
		cfg.mode = mode;
		init();
	};
	
	this.ExitEditMode = function()
	{
		$(controls).off("click", ControlRun);
		$(domobj).off("mousemove", ShowControl);
		$(domobj).off("click", ShowFocus);
		$(domobj).off("dblclick", DocDblClick);
		attachEditor(false);	
		cfg.mode = 0;
		init();
	}
	
	function init()
	{
		prepareData(data);
		var tag = getTeachText();	//$(domobj).html(getTeachText());�ô˷������¼���������ľֲ�������Ϊʲô��
		domobj.innerHTML = tag;
		if (cfg.mode == 0)
			return;
		if (controls == undefined)
		{
//			controls = document.createElement("<span style='padding-left:10px;color:gray;font:normal normal normal 12px ΢���ź�;'></span>");
			controls = document.createElement("span");
			$(controls).css({paddingLeft:"10px", color: "gray", font:"normal normal normal 12px ΢���ź�"});
			controls.innerHTML = "<a>���</a>&nbsp;&nbsp;<a>ɾ��</a>&nbsp;&nbsp;<a>����</a>&nbsp;&nbsp;<a>ճ��</a>&nbsp;&nbsp;<a>......</a>";

			unitMoreControl = new $.jcom.CommonMenu([{item:"��ӽ�ѧģ��", action:MenuAddSubUnit},{}, {item:"����Ϊ���ⵥԪ", action:SetUnitOther}, {item:"����Ϊ������Ԫ", action:SetUnitComm},
				{item:"����Ϊѡ�޿�", action:SetFreeCourse},{}, {item:"��дģ�鱸ע", action:SetUnitNote}]);
			courseMoreControl = new $.jcom.CommonMenu([{item:"����Ϊ�����γ�", action:SetCommonCourse},{}, {item:"����Ϊʹ�ÿγ�", action:SetCourseState}, {item:"����Ϊ���ÿγ�", action:SetCourseState},
		                                			{item:"����Ϊ���ÿγ�", action:SetCourseState},{}, {item:"����ɾ�����ÿγ�", action:DelStateCourse},{item:"����ɾ�����ÿγ�", action:DelStateCourse}]);
			dynaEdit = new $.jcom.DynaEditor.Edit();
			dynaEdit.valueChange = EditChange;
			var tag = "0:" + aStyle[0].Style_name;
			for (var x = 1; x < aStyle.length; x++)
				tag += "," + x + ":" + aStyle[x].Style_name;
			styleEditor = new $.jcom.DynaEditor.List(tag, 200, 300, 1);
			styleEditor.valueChange = styleChange;
			courseTimeEditor = new $.jcom.DynaEditor.List("0.5:����,1:һ��,1.5:һ���,2:����,2.5:�����,3:����", 200, 300, 1);
			courseTimeEditor.valueChange = courseTimeChange;
			freeBeginEditor = new $.jcom.DynaEditor.Date(200, 200, {dateType:3});
			freeBeginEditor.config({editorMode:4, bHint:true});
			freeBeginEditor.valueChange = freeBeginChange;
		
			roomtree = new $.jcom.TreeView(0, aPlace, {});
			roomEditor = new $.jcom.DynaEditor.TreeList(roomtree, 200, 200);
			roomEditor.config({editorMode:4, bHint:true});
			roomEditor.valueChange = roomEditorChange;
		}
		$(controls).on("click", ControlRun);
		$(domobj).on("mousemove", ShowControl);
		$(domobj).on("click", ShowFocus);
		$(domobj).on("dblclick", DocDblClick);
		
		attachEditor(true);
	}
}
