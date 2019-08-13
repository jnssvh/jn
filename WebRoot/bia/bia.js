function AsSysInvestView(domobj, SysId, cfg)		//������ϵ������ʾ�
{
	var self = this;
	var oCom, oPlan, oDetail;
	self.grid = undefined;

	this.reload = function (id, option)
	{
		SysId = id;
		if (self.grid == undefined)
		{
			self.grid = new $.jcom.DBGrid(domobj, env.fvs + "/asSysDetail_view.jsp", 
					{URLParam:"?asSysId=" + id, formitemstyle:"font:normal normal normal 16px ΢���ź�", formvalstyle:"width:400px",gridtree:2},
					{SeekKey:"", SeekParam:""}, {gridstyle:1, footstyle:4, initDepth:4, nowrap:0, resizeflag:0});
			self.grid.PrepareData = PrepareGrid;
			var title = cfg.title;
			if (title.substr(0, 1) != "<")
				title = "<h2 align=center>" + title + "</h2>"
			self.grid.TitleBar(title);
		}
		else
		{
			self.grid.config({URLParam:"?asSysId=" + id});
			self.grid.ReloadGrid();
		}
	};
	
	this.loadAskPaper = function (comItem, planItem, detailItem)
	{
		oCom = comItem;
		oPlan = planItem;
		oDetail = detailItem;
		if (planItem.asSysMainId != SysId)
			return self.reload(planItem.asSysMainId);
		loadAnswer();
	}
	
	function loadAnswer()
	{
		cfg.title = "<h2 align=center>" + oCom.item + "<h2><h1 align=center>�����ʾ�</h1><h4 align=center>" + oPlan.item + "." + oDetail.item + "<h4>" +
			"<p>�Ҫ��" + oPlan.fillReq + "</p><p>������ֹʱ��: " + $.jcom.GetDateTimeString(oDetail.beginTime, 1) + " ~ " + $.jcom.GetDateTimeString(oDetail.endTime, 1) +
			"</p><p>���ֹʱ��: " + $.jcom.GetDateTimeString(oDetail.fillBeginTime, 1) + " ~ " + $.jcom.GetDateTimeString(oDetail.fillEndTime, 1) + "</p>";
		self.grid.TitleBar(cfg.title);
		$.get(cfg.jsp, {LoadComAnswer:1, comId: oCom.ID, planId: oPlan.ID, planDetailId: oDetail.ID}, loadAnswerOK);
	}
	
	function loadAnswerOK(data)
	{
		var o = $.jcom.eval(data);
		if (typeof o == "string")
			return alert(o);
		$(":input", domobj).val("");
		for (var x = 0; x < o.Details.length; x++)
		{
			$("input[node='" + o.Details[x].asSysDetailId + "']", domobj).val(o.Details[x].sValue);
		}
		var tag = ""
		if (o.Main.length > 0)
		{
			tag = "�ύ�ˣ�" + o.Main[0].submitMan + "<br>�ύʱ�䣺" + o.Main[0].submitTime;
			if (o.Main[0].checkMan != "")
			{
				tag += "<br>����ˣ�" + o.Main[0].checkMan + "<br>���ʱ�䣺" + o.Main[0].checkTime;
				if (o.Main[0].status > 1)
				{
					if (cfg.mode == 3)
						tag += "<br>���״̬:<input name=status type=radio value=3" + (o.Main[0].status == 3 ? " checked" : "") + ">���ͨ��&nbsp;" +
							"<input name=status type=radio value=4" + (o.Main[0].status == 4 ? " checked" : "") + ">��˲�ͨ��" +
							"<br>������:<textarea id=Info style=width:300px;height:40px>" + o.Main[0].info + "</textarea>";
					else
						tag += "<br>״̬:" + o.Main[0].status;
				}
					
			}
		}
		var foot = self.grid.getChildren("pagefoot");
		foot.reload(tag);
	}
	
	this.SaveForm = function(status)
	{
		var objs = $(":input", domobj);
		var info = "";
		if (status > 2)
			info = $("#Info", domobj).val();
		var records = [{comId: oCom.ID, planId: oPlan.ID, planDetailId: oDetail.ID, status: status, info:info}];
		for (var x = 0; x < objs.length; x++)
		{
			if (objs.eq(x).attr("node") != undefined)
				records[records.length] = {asSysDetailId: objs.eq(x).attr("node"), value:objs.eq(x).val()};
		}
		$.jcom.submit(cfg.jsp + "?SaveFormFlag=1", records, {wincfg:{title:"���ڱ���..."}});
	}
	
	this.VerifyForm = function ()
	{
		var o = $("input[name='status']", domobj);
		if (o.length == 0)
			return alert("�������");
		var o = $("input[name='status']:checked", domobj);
		if (o.length == 0)
			return alert("���״̬δѡ��");
		
		self.SaveForm($("input[name='status']:checked", domobj).val());
	}
	
	function PrepareGrid(items, head, depth)
	{
		if (depth == undefined)
		{
			depth = 0;
			for (var x = 0; x < head.length; x++)
			{
				switch (head[x].FieldName)
				{
				case "itemCName":
					head[x].TitleName = "����";
					break;
				case "info":
					head[x].TitleName = "����";
					break;
				case "weight":
				case "dataType":
					head[x].nShowMode = 6;
					break;					
				}
			}
		}
		for (var x = 0; x < items.length; x++)
		{
			var cname = items[x].itemCName;
			if (items[x].fillName != "")
				cname = items[x].fillName;
			items[x].itemCName = {value:cname, style:"font:normal normal normal " + (18 - depth * 2) + "px ΢���ź�;"}
			if (typeof items[x].child == "object")
			{
				if (items[x].child.length == 0)
					items[x].child = undefined;
				else
					PrepareGrid(items[x].child, head, depth + 1);
			}
			if (typeof items[x].child != "object")
			{
				var info = "<input node=" + items[x].ID + " style=width:100%;border:none; placeholder=" + items[x].info + ">";
				items[x].info = {value:info, style:"font:normal normal normal 13px ����;"};
			}	
		}
		if (cfg.mode > 1)
			loadAnswer();
		return items;
	}
	
	cfg = $.jcom.initObjVal({mode:1, title:"", jsp:location.pathname}, cfg);	//mode��1-�ʾ�����, 2-�,3-:���
	if (SysId > 0)
		this.reload(SysId);
}