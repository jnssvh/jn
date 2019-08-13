
$.jcom.BookPage = function(aFace, chapters, sys, cfg)	//��:������ҳ��
{//���������ͨ�õ�ҳ��
	var self = this;
	var catalog = $.extend(true, [], chapters);
	var headObj = {homeText:"<span tabindex=0>&#9679;&nbsp;</span>", leftText:"", rightText:"", leftMenu:undefined, rightMenu:[], 
		ToolMenu:undefined, root:catalog, items:[], nodes:[]};
	var minorDef, toolDef, browser, SysMenu;
	var oLayer, minorObj, leftObj, toolObj, linkObj, docObj;
	var PageSetupBox, PageSetupForm, PageRecord = {PageSize:1, PageWidth:794, LeftPadding:20, RightPadding:20, scale:1, LeftOption:2};
	var initWidth, initHeight;
	var editmode = 0; reloadFlag = false;
	var objRight = true, favs = [], oDiscuss, oSocket, clientList = [], clientViewBox, clientView, realMsgViewBox, realMsgList = [], realMsgView;
	
	function prepareCatalog(items)
	{
		for (var x = items.length - 1; x >= 0; x--)
		{
			if (typeof localPatch == "object")
			{
				for (var y = 0; y < localPatch.length; y++)
				{
					if (items[x].Code == localPatch[y].Code)
					{
						if (localPatch[y].item != undefined)
							items[x].item = localPatch[y].item;
						if (localPatch[y].Param != undefined)
							items[x].Param = localPatch[y].Param;
						if (localPatch[y].Status != undefined)
							items[x].Status = localPatch[y].Status;
						if (localPatch[y].img != undefined)
							items[x].img = localPatch[y].img;
						localPatch.splice(y, 1);
						break;
					}
				}
			}
			if (items[x].Status == 0)
				items.splice(x, 1);		
			else 
			{
//				if (items[x].img.substr(0, 1) == "#")
//				{
//					items[x].fontimg = items[x].img;
//					items[x].img = "<span style=width:30px;display:inline-block;color:gray;font-family:sfont;font-size:25px;>&" + items[x].img + "</span>";
//				}
				if (typeof items[x].child == "object")
					prepareCatalog(items[x].child);
			}
		}
	}
	
	function init()
	{
		cfg = $.jcom.initObjVal({doc:document, bodybgColor:"rgb(208,224,249)", docbgColor:"white", headid:"DocHead", leftid:"LeftBox", 
			leftwidth:160, lefttop:30,leftright:3, serverURL: "../com/pageSvr.jsp", Discussion:false, 
			docid:"Page", docwidth:794, docheight:1123, toptool:1, autoWidth:true}, cfg);
		browser = $.jcom.getBrowser();
		if (typeof sys == "object")
		{
			sys.PageName += window.location.hash;
			prepareCatalog(catalog);
			loadPageParam();
			loadRightandFavs();
			if ((window.opener == undefined) || (window.opener == null))
			{
				oSocket = new $.jcom.RealSocket(sys);
				oSocket.onMsg = RealMsg;
			}
		}
		if (cfg.docwidth == 794)
			cfg.docwidth = PageRecord.PageWidth;
		initWidth = cfg.docwidth;
		initHeight = cfg.docheight;

		$(cfg.doc.body).css({backgroundColor: cfg.bodybgColor, margin:"10px 0px 10px 0px"});
//		cfg.doc.body.leftMargin = 0;
		if (!browser.mobile)
			cfg.doc.body.className = "pcbody";
		var helptext = $("#HelpBox").html();
		var tag  = "<div id=DocArea align=center><div align=left id=DocFrame style='background-color:" + cfg.docbgColor + ";width:" + (cfg.docwidth - 40) + 
			"px;padding:60px 20px 40px 20px;overflow-x:hidden;overflow-y:visible;box-shadow: 1px 0px 5px #888888;'><div id=PrepDiv></div><div align=left id=" + cfg.docid +
			" style='min-height:" + cfg.docheight + "px;border:none;'></div></div></div>";
		if (cfg.doc.body.innerText.substr(0, 10) == "Loading...")
			cfg.doc.body.innerHTML = tag;
		else
			$(cfg.doc.body).append(tag);

		oLayer = new $.jcom.Layer($("#" + cfg.docid)[0], aFace, {dwidth:cfg.docwidth, dheight:cfg.docheight});
		$(document).on("mousewheel", scrollDoc);
		$(document).on("touchmove", scrollDoc);
		if (getHeadObj(catalog, sys.PageName))
		{	
			$("#DocArea").append("<div id=ScalePad></div><div id=AutoPageUp align=center style='display:none;width:" + (cfg.docwidth - 40) + 
				"px;padding:60px 20px 40px 20px;'>ҳ��������������Զ���ҳ...</div>");
			
			$("#DocArea").prepend("<div id=" + cfg.headid + " style='top:0px;width:" + (cfg.docwidth - 40) +
				"px;height:30px;overflow:hidden;background-color:white;position:fixed;z-index:1;margin:auto;padding:12px 20px 1px 20px;'>" +
				"<div id=HomeIcon style='float:left;font:normal normal normal 18px ΢���ź�'>" + headObj.homeText + "</div>" +
				"<div id=Shelf style='float:left;font:normal normal normal 18px ΢���ź�'>" + headObj.leftText + "</div>" +
				"<div id=ToolIcon style='float:right;text-align:right;font-size:16px;color:blue;width:25px;display:none;'>&#9776</div>" +
				"<div id=Chapter style='margin-top:3px;float:right;text-align:right;font:normal normal normal 14px ΢���ź�'>" + headObj.rightText +
				"</div><hr style=clear:both></div>");
			$("#AutoPageUp").on("click", PageUpRun);
			$("#HomeIcon").on("click", ShowHomeMenu);
			$("#Shelf").on("click", ShowShelfMenu);
			$("#Chapter").on("click", ShowChapterMenu);
			$("#ToolIcon").on("click", ShowToolMenu);
			$("#" + cfg.headid).on("click", goTop);
		}
		
		if (cfg.toptool == 1)
			setTopTool();
		setSysStatus();
		setLeftTree();
		if (cfg.Discussion)
		{
			var o = self.setBottom("DiscussBox", "");
			new $.jcom.Cascade(o[0], "<div id=DiscussDiv></div>", {title:["������"]});
			oDiscuss = new $.jcom.PageDiscuss($("#DiscussDiv")[0], sys, {url:cfg.serverURL});
		}
		
		if ((typeof helptext == "string") && (helptext != ""))
		{
			var o = self.setBottom("HelpBox", "");
			var oHelp = new $.jcom.Cascade(o[0], helptext, {title:["����˵��"]});
		}

		$(cfg.doc.body).append("<div id=RightBox style='overflow:visible;padding:4px;top:60px;width:200px;position:fixed;left:50%;margin-left:" +
			(cfg.docwidth / 2 + 6) + "px;'></div>");

//		self.setDocWidth(PageRecord.PageWidth);
		$("#Page").css({paddingLeft: PageRecord.LeftPadding + "px", paddingRight: PageRecord.RightPadding + "px"});
		if (PageRecord.scale != 1)
		{
			PageRecord.scale = 1;
			if (PageRecord.PageWidth <= 800)
				ZoomDoc();
		}

		resize();
		if (browser.mobile)
			$(window).on("orientationchange", resize);
		else
			$(window).on("resize", resize);
		if ($("#SysStatus").css("position") == "fixed")
			$("html, body").scrollTop(0).animate({scrollTop: 0});
		else
			$("html, body").scrollTop(0).animate({scrollTop: 80});
	}
	
	function setTopTool()
	{
		$(cfg.doc.body).append("<div id=TopToolBox style='position:fixed;margin:auto;top:0px;left:50%;height:25px;padding:4px;color:#3658b2;margin-left:-" +
				(cfg.docwidth/2 + 120) + "px;'>" +
				"<span id=SetupDoc style='padding:4px;font-size:21px;font-family:iconfont;' title=ҳ������>&#59195</span>" +
				"<span id=PrintDoc style='padding:4px;font-size:21px;font-family:iconfont;' title=��ӡ�ĵ�>&#59235</span>" +
				"<span id=ZoomDoc style='padding:4px;font-size:21px;font-family:iconfont;' title=�Ŵ�����>&#59389</span>" +
				"<span id=MyPage style='padding:4px;font-size:21px;' title=�ղص��ҵ�ҳ��>&#9734</span>" +
				"</div>");
		$("#SetupDoc").on("click", SetupDoc);
		$("#PrintDoc").on("click", PrintDoc);
		$("#ZoomDoc").on("click", ZoomDoc);
		$("#MyPage").on("click", AddMyPage);
		PageChange();
	}
	
	function goTop(e)
	{
		if (e.target.id == cfg.headid)
			window.scrollTo(0, 0);
	}
	
	function RealMsg(cmd, text)
	{
		if (self.onRealMsg(cmd, text))
			return;
		switch (cmd)
		{
		case "ClientList":
			clientList = $.jcom.eval(text);
			clientList.splice(0, 0, {info:navigator.userAgent, ip:"����"});
			SetClientStatus(clientList);
			break;
		case "ClientAdd":
			var o = $.jcom.eval(text);
			clientList[clientList.length] = o[0];
			SetClientStatus(clientList);
			break;
		case "ClientDel":
			var o = $.jcom.eval(text);
			for (var x = 0; x < clientList.length; x++)
			{
				if ((o[0].info == clientList[x].info) && (o[0].ip == clientList[x].ip))
				{
					clientList.splice(x, 1);
					break;
				}
			}
			SetClientStatus(clientList);
			break;
		case "onClose":
			clientList = [];
			SetClientStatus([]);
			break;
		case "SendMsg":
			var msg = oSocket.getMsgObj(text)
			var img = oSocket.getImg(msg.Photo, 24);
			self.showTopMsg(img + "&nbsp;<span style=font-size:12px;color:gray;vertical-align:top>" + msg.Sender + 
					":</span>&nbsp;<span style=vertical-align:top>" + msg.Content + "</span>", {lifeTime:5000});
			$("#RealMsgCount").css("backgroundColor", "FireBrick");
			realMsgList[realMsgList.length] = msg;
			$("#RealMsgCount").css("backgroundColor", "FireBrick");
			if (realMsgList.length > 99)
				$("#RealMsgCount").html("...");
			else
				$("#RealMsgCount").html(realMsgList.length);
			break;
		case "RoomMsg":
			alert(text);
			break;			
		}
	}

	this.showTopMsg = function(msg, option)		//��������ʾҳ�涥����Ϣ��
	{
		option = $.jcom.initObjVal({lifeTime: 0, hideButton:"#58994",linkPage:""}, option);
		if ($("#TopHintDiv").length > 0)
		{
			$("#hideTopMsgButton").off("click", HideTopMsg);
			$("#TopHintDiv").remove();
		}
		var tag = "<div align=left style='float:left;font-size:15px;padding:3px 8px;width:" + (cfg.docwidth - 80) + "px;'>" + msg + "</div>";
		if (option.hideButton != "")
			tag = $.jcom.getItemImg(option.hideButton, "float:right;font-size:20px;height:20px;", "div", "id=hideTopMsgButton align=right") + tag;
		tag = "<div id=TopHintDiv style='border:1px solid LightGrey;top:43px;width:" + (cfg.docwidth - 40) + "px;height:30px;overflow:hidden;" +
			"background-color:Beige;position:fixed;z-index:1;margin:auto;'>" + tag + "</div>";
		$("#DocArea").prepend(tag);
		$("#hideTopMsgButton").on("click", HideTopMsg);
		resize();
		if (option.lifeTime > 0)
			$("#TopHintDiv").delay(option.lifeTime).fadeOut("slow");
	};
	
	function HideTopMsg()
	{
		$("#TopHintDiv").css("display", "none");
	}
	
	this.onRealMsg = function (cmd, text)	//�¼�:ʵʱ��Ϣ�¼�������ֵΪfalse, ���������Ĭ�ϵĴ������򣬷��򣬺���Ĭ�ϴ�������
	{
		return false;
	};
	
	function loadRightandFavs(data)
	{
		if (data == undefined)
		{
			if (typeof sessionStorage.RightandFavs == "string")
				data = sessionStorage.RightandFavs;
			else
				return $.jcom.Ajax(cfg.serverURL + "?LoadRightAndFavs=1", true, "", loadRightandFavs);
		}
		else
			sessionStorage.RightandFavs = data;
		var o = $.jcom.eval(data);
		if (typeof o != "object")
		{
			sessionStorage.removeItem("RightandFavs");
			return;
		}
		favs = o.favs;
		objRight = o.objRight;
	}
	
	function loadPageParam()
	{
		if (!window.localStorage)
            return false;
		
		if (typeof localStorage.PageParam == "string")
		{
			var o = $.jcom.eval(localStorage.PageParam)
			if (typeof o == "object")
				PageRecord = $.jcom.initObjVal(PageRecord, o);
		}
	}

	function SavePageParam()
	{
		localStorage.PageParam = $.jcom.toJSONStr(PageRecord);
	}

	function setSysStatus()
	{
		if (typeof sys != "object")
			return;
		var c = "black";
		switch (sys.Role)
		{
		case 1:
			c = "blue";
			break;
		case 2:
			c = "green";
			break;
		case 4:
			c = "red";
			break;
		case 8:
			c = "yellow";
			break;
		case 16:
			c = "black";
			break;
		}
		var photo = "url(../images/photo.jpg)";
		if (sys.PhotoID > 0)
			photo = "url(../com/down.jsp?AffixID=" + sys.PhotoID  + ")";
		$(cfg.doc.body).append("<div id=SysStatus style='top:4px;color:#333333;position:fixed;left:50%;margin-left:" + 
				(cfg.docwidth /2 + 10) + "px;'><div id=UserPhotoDiv style='float:left;width:50px;height:50px;border-radius:50px;border:1px solid " + c +
				";background-image:" + photo + ";background-size:100% 100%'></div><div id=UserNameDiv align=center style='float:left;padding:8px;line-height:12px;color:" + c +
				"'><span>" + sys.CName + "</span><br><span>" + sys.EName + "</span><br><span id=ClientStatus style=font-family:iconfont></span></div>" +
				"<div id=RealMsgCount style='float:left;font-size:14px;width:24px;height:24px;border-radius:24px;color:white;text-align:center;overflow:hidden;margin-top:4px;'></div></div>");
		
		var items = [];
		if (typeof minorDef == "object")
		{
			for (var x = 0; x < minorDef[0].child.length; x++)
				items[items.length] = {item:minorDef[0].child[x].item, Code:minorDef[0].child[x].Code, img:minorDef[0].child[x].img, action:self.GoPage};
		}
		items.splice(items.length, 0, {}, {item:"��������", action:SetPassword, img:"#59016"},
				{item:"�ϴ�ͷ��", action:UploadPhoto, img:"#59340"},{},{item:"�˳�", action:ExitSys, img:"#59629"});
//		var items = [{item:"��������", action:SetPassword, img:"#59016"},{item:"�ϴ�ͷ��", action:UploadPhoto, img:"#59340"},{},{item:"�˳�", action:ExitSys, img:"#59629"}];		
		SysMenu = new $.jcom.CommonMenu(items, {itemstyle:"font:normal normal normal 16px ΢���ź�;height:36px;", position:"fixed"});
		$("#SysStatus").on("click", ClickUser);
		
	}

	function getClientStatus(item)
	{
		var c = "&#59323", t = "����";
		var b = $.jcom.getBrowser(item.info);
		if (b.mobile)
		{
			c = "&#59194";
			t = "�ֻ�";
		}
		if (b.iPad)
		{
			c = "&#59312";
			t = "�ֻ�";
		}
		return {tag:c, title:t};
	}

	function SetClientStatus(list)
	{
		var tag = "";
		for (var x = 0; x < list.length; x++)
		{
			var o = getClientStatus(list[x]);
			tag += o.tag;
		}
		if (tag == "")
			tag = "&#59395";
		$("#ClientStatus").html(tag);
	}
	
	function ClickUser(e)
	{
		switch (e.target.id)
		{
		case "UserPhotoDiv":
			var pos = $.jcom.getObjPos($("#SysStatus")[0]);
			var t = 0;//$(window).scrollTop();
			SysMenu.show(pos.left, t + pos.bottom, pos.left, t + pos.bottom);
			break;
		case "RealMsgCount":
			if (realMsgList.length == 0)
				return;
			var pos = $.jcom.getObjPos($("#RealMsgCount")[0]);
			if (typeof realMsgViewBox == "object")
			{
				return realMsgViewBox.show(pos.left, pos.bottom, pos.left, pos.bottom);
			}
			realMsgViewBox = new $.jcom.PopupBox("<div id=RealMsgDiv style='width:300px;height:400px;padding:8px;'>loading...</div>", 
				pos.left, pos.bottom, pos.left, pos.bottom, {autoHide:1, hideButton:"#58994", title:"δ�Ķ���ʵʱ��Ϣ", border:"1px solid gray"});
			break;
		default:
			var items = [];
			if (clientList.length == 0)
				return;
			for (var x = 0; x < clientList.length; x++)
			{
				var o = getClientStatus(clientList[x]);
				items[x] = {device: "<span style=font-family:iconfont;>" + o.tag + "</span> &nbsp;" + o.title, IP: clientList[x].ip};
				if (items[x].IP != "����")
					items[x].Button = "Զ����ֹ";
			}
			var pos = $.jcom.getObjPos($("#UserNameDiv")[0]);
			if (typeof clientViewBox == "object")
			{
				clientView.reload(items);
				return clientViewBox.show(pos.left, pos.bottom, pos.left, pos.bottom);
			}
			clientViewBox = new $.jcom.PopupBox("<div id=ClientDiv style='width:210px;height:300px;padding:8px 20px;'>loading...</div>", 
				pos.left, pos.bottom, pos.left, pos.bottom, {autoHide:1, hideButton:"#58994", title:"�ѵ�¼�ն�", border:"1px solid gray"});

			var h = [{FieldName:"device", TitleName:"�豸", nWidth:50, nShowMode:1},
	    		{FieldName:"IP", TitleName:"��ַ", nWidth:90, nShowMode:1},
	    		{FieldName:"Button", TitleName:"����", nWidth:50, nShowMode:1}];
			clientView = new $.jcom.GridView($("#ClientDiv")[0], h, items, {}, {footstyle:4});
			break;
		}
	}
	
	function SetPassword()
	{
		alert("==");
	}
	
	function ExitSys()
	{
		document.cookie = "loginname=; path=/";
		document.cookie = "loginpassword=; path=/";
		location.reload();
	}
	
	function UploadPhoto()
	{
		$.jcom.submit("../com/upfile.jsp?SecretType=6&saveto=UsersPhoto", "", {File:"LocalName", fValid:testPhotoFile, fnReady:SavePhotoOK});		
	}

	function testPhotoFile(file)
	{
		var pos = file.lastIndexOf(".");
		var ex = file.substr(pos + 1).toLowerCase();
		if ((ex == "jpg") || (ex == "jpeg") || (ex == "png") || (ex == "bmp") || (ex == "gif"))
			return true;
		alert("���ϴ�ͼƬ�ļ�");
		return false;
	}
	
	function SavePhotoOK(result)
	{
		var ss = result.split(":");
		if (ss[0] != "OK")
			return alert(result);
		sys.PhotoID = parseInt(ss[1]);
		$("#UserPhotoDiv").css({backgroundImage:"url(../com/down.jsp?AffixID=" + sys.PhotoID  + ")"});
		$.get(cfg.serverURL, {SaveMyPhoto: 1, photoid: sys.PhotoID});
	}
	
	function setLeftTree()
	{
		if  (PageRecord.LeftOption == 1)	//����ർ��
			return;
		if  (PageRecord.LeftOption == 2)	//����ʽ��ർ��
		{
			if (minorDef == undefined)
				return;
			$(cfg.doc.body).append("<div id=" + cfg.leftid + " style='left:50%;margin-left:-" + (cfg.docwidth / 2 + cfg.leftwidth + cfg.leftright) + "px;top:" + cfg.lefttop +
					"px;width:" + cfg.leftwidth + "px;position:fixed;'></div>");
			if (minorObj == undefined)
				minorObj = new $.jcom.ChapterTree($("#" + cfg.leftid)[0], minorDef, {rollbkcolor:0, itemstyle:"font:normal normal normal 14px ΢���ź�",expic:["#59283","#59284"]});
			else
				minorObj.setdomobj($("#" + cfg.leftid)[0]);
			return;
		}
		//���ʽ��ർ��
		if (catalog.length == 0)
			return;
//		var	def = [catalog[0]];
//		if (typeof minorDef == "object")
//			def[1] = minorDef[0];
		$(cfg.doc.body).append("<div id=" + cfg.leftid + " style='left:0px;top:" + cfg.lefttop +
				"px;width:300px;height:500px;overflow-y:auto;background-color:#f0f0ff;position:fixed;border:1px solid #c0c0c0;'></div>");
		if (leftObj == undefined)
			leftObj = new $.jcom.ChapterTree($("#" + cfg.leftid)[0], catalog, {initDepth:3, fontChange:0, rollbkcolor:0, currentCode:sys.PageName, itemstyle:"height:25px;overflow:hidden;font:normal normal normal 18px ΢���ź�;",expic:["#59283","#59284"]});
		else
			leftObj.setdomobj($("#" + cfg.leftid)[0]);
		resize();
	}
	
	function ResetLeftTree()
	{
		if (typeof leftObj == "object")
			leftObj.setdomobj();
		if (typeof minorObj == "object")
			minorObj.setdomobj();
		$("#" + cfg.leftid).remove();
		setLeftTree();
	}
	
	function resize()
	{
		var w = $(window).width();
		if (browser.mobile)
		{
			w = screen.availWidth;
			var h = screen.availHeight;
			if (window.orientation == 0)	//����
			{
				if (w > h)
					w = h;
			}
			else
			{
				if (w < h)
					w = h;
			}
		}
		var margin = Math.round((w - initWidth) / 2);
		if (margin < 0)
		{
			margin = 0;
//			$("#DocArea").prop("align", "left");
		}
//		$("#DocFrame").css({marginLeft:margin});
//		$("#AutoPageUp").css({marginLeft:margin});
		$("#" + cfg.headid).css({left:(margin + 0) + "px"});
		$("#TopHintDiv").css({left:(margin + 20) + "px"});

		if (w <= initWidth)
			$("#" + cfg.headid).width(w - 40);
		else
			$("#" + cfg.headid).width(initWidth - 40);			
	
		if (cfg.autoWidth)
		{
			var ww = parseInt(initWidth / PageRecord.scale) - 40;
			if (w <= initWidth)
				ww = parseInt(w / PageRecord.scale) - 40;
			$("#DocFrame").width(ww);
			$("#AutoPageUp").width(ww);
		}
		
		if (w > 1000)
		{
//			$("#SysStatus").css({display:""});	
			if ($("#SysStatus").css("position") != "fixed")
			{
				$("#SysStatus").css({position:"fixed", marginLeft: (cfg.docwidth / 2 + 10) + "px", float:""});
				$("#SysStatus").css({});
				$("#PrepDiv").css({height:""});
				$(cfg.doc.body).append($("#SysStatus"));
			}
			$("#TopToolBox").css({display:""});
			if (editmode == 0)
				$("#" + cfg.leftid).css({display:""});
			$("#ToolIcon").css({display:"none"});
			$("#RightBox").css({display:""});
		}
		else
		{
//			$("#SysStatus").css({display:"none"});
			if ($("#SysStatus").css("position") == "fixed")
			{
				$("#SysStatus").css({position:"",margin:"auto", float:"right"});
				$("#PrepDiv").css({height:"60px"});
				$("#PrepDiv").prepend($("#SysStatus"));
			}
			$("#TopToolBox").css({display:"none"});
			$("#" + cfg.leftid).css({display:"none"});
			if (toolObj != undefined)
				$("#ToolIcon").css({display:""});
			$("#RightBox").css({display:"none"});
		}
		var o = $(".BookLeftTree:not(:hidden)");
		var h = $(window).height() - cfg.lefttop - 20;
		var w = parseInt(($(window).width() - cfg.docwidth) / 2);
		if (o.css("position") == "fixed")
		{
			if (w < 50)
				o.css("display", "none");
			else
				o.css("display", "");
			o.css({width: w + "px"});
			o.children().last().css({height: h + "px"});
		}
		var o = $("#" + cfg.leftid);
		if (PageRecord.LeftOption == 3)
		{
			if (w < 50)
				o.css("display", "none");
			else
				o.css("display", "");
			if (w > 300)
				w = 300;
			else
				w -= 4;
			o.css({width: w + "px"});
			$("#" + cfg.leftid).css({height: h + "px"});
		}
	}
	
	function getPageNode(items, name, prep)
	{
		for (var x = 0; x < items.length; x++)
		{
			if (items[x].Code == name)
				return {item: items[x], node: prep + x};
			if (typeof items[x].child == "object")
			{
				var o = getPageNode(items[x].child, name, prep + x + ",");
				if (typeof o == "object")
					return o;
			}
		}
	}

	function getHeadObj(items, name)
	{
		var o = getPageNode(items, name, "");
		if (o == undefined)
			return false;
		var ss = o.node.split(",");
		var index = parseInt(ss[0]);
		if (index < items.length - 1)
			items.splice(index + 1, items.length - 1 - index);
		if (index > 0)
			items.splice(0, index);
		for (var x = 0; x < items[0].child.length; x++)	//�����ϵͳ
		{
			if (items[0].child[x].nType == 5)
			{
				minorDef = items[0].child.splice(x, 1);
				$.jcom.DataClearEmptyChild(minorDef);
				break;
			}
		}

		var o = getPageNode(items, name, "");
		var p = items;
		var prep = 0;
		if (typeof o != "object")
		{
			p = minorDef;
			o = getPageNode(p, name, "");
			prep = 100;
		}
		headObj.root = p;
		if (o == undefined)
			return false;
		var ss = o.node.split(",");
		for (var x = 0; x < ss.length; x++)
		{
			headObj.nodes[x] = parseInt(ss[x]);
			headObj.items[x] = p[headObj.nodes[x]];
			p = headObj.items[x].child;
		}
		if (items[0].img != "")
		{
			if (items[0].img.substr(0, 1) == "<")
				headObj.homeText = items[0].img;
			else
				headObj.homeText = "<img tabindex=0 src=" + items[0].img + ">";
		}
		switch (prep + headObj.nodes.length)
		{
		case 1:
			headObj.leftText = headObj.items[0].item;
			break;
		case 2:
			headObj.leftText = headObj.items[0].item;
			headObj.rightText = headObj.items[1].item;
			headObj.rightMenu[0] = ChapterToMenu(headObj.items[0].child, headObj.items[1]);
			break;
		case 3:
			headObj.leftText = headObj.items[1].item;
			headObj.leftMenu = ChapterToMenu(headObj.items[0].child, headObj.items[1]);
			headObj.rightText = headObj.items[2].item;
			headObj.rightMenu[0] = ChapterToMenu(headObj.items[1].child, headObj.items[2]);
			break;
		case 4:
			headObj.leftText = headObj.items[1].item;
			headObj.rightText = "<span tabindex=0>" + headObj.items[2].item + "</span>&bull;<span tabindex=1>" + headObj.items[3].item + "</span>";
			headObj.leftMenu = ChapterToMenu(headObj.items[0].child, headObj.items[1]);
			headObj.rightMenu[0] = ChapterToMenu(headObj.items[1].child, headObj.items[2]);
			headObj.rightMenu[1] = ChapterToMenu(headObj.items[2].child, headObj.items[3]);
			break;
		case 5:
			headObj.leftText = headObj.items[1].item;
			headObj.rightText = "<span tabindex=0>" + headObj.items[2].item + "</span>&bull;<span tabindex=1>" + headObj.items[3].item +
				"</span>&bull;<span tabindex=2>" + headObj.items[4].item + "</span>";
			headObj.leftMenu = ChapterToMenu(headObj.items[0].child);
			headObj.rightMenu[0] = ChapterToMenu(headObj.items[1].child, headObj.items[2]);
			headObj.rightMenu[1] = ChapterToMenu(headObj.items[2].child, headObj.items[3]);
			headObj.rightMenu[2] = ChapterToMenu(headObj.items[3].child, headObj.items[4]);
			break;
		case 101:
		case 102:
			headObj.leftText = catalog[0].item;
			headObj.rightText = headObj.items[headObj.items.length - 1].item;			
			break;
		}
		$.jcom.DataClearEmptyChild(items);
		return true;
	}
	
	function ChapterToMenu(items, current)
	{
		var m = [];
		for (var x = 0; x < items.length; x++)
		{
//			if (items[x] != current)
				m[m.length] = {item:items[x].item, Code:items[x].Code, img: items[x].img, action:self.GoPage};
		}
		var menu = new $.jcom.CommonMenu(m, {itemstyle:"font:normal normal normal 16px ΢���ź�;height:36px;", position:"fixed"});
		return menu;
	}

	function getSkipPage(step)
	{
		if (typeof docObj == "object")
		{
			var pageName = docObj.SkipPage(step);
			if (headObj.items.length == 0)
				return pageName;
			if (pageName != undefined)
				return headObj.items[headObj.items.length - 1].item + ": " + pageName; 
		}
		else
		{
			if ((typeof self.Page == "object") && (typeof self.Page.SkipPage == "function"))
			{
				self.setPageObj(self.Page);
				return getSkipPage(step);
			}
		}
		return getSkipChapter(step)
	}
	
	function getSkipChapter(step)
	{
		switch (step)
		{
		case 1:
			if (headObj.nodes.length == 0)
				break;
			var x = headObj.nodes.length - 1;
			if ((typeof headObj.items[headObj.nodes.length - 1].child == "object") && (headObj.items[x].child.length > 0))
				return  headObj.items[x].child[0];
			while (x > 0)
			{
				if (headObj.nodes[x] < headObj.items[x - 1].child.length - 1)
					return headObj.items[x - 1].child[headObj.nodes[x] + 1];
				x--;
			}
			break;
		case -1:
			for (var x = headObj.nodes.length - 1; x >= 0; x--)
			{
				if (headObj.nodes[x] > 0)
					return headObj.items[x - 1].child[headObj.nodes[x] - 1];
			}
			break;
		case 0:
			return headObj.rightText;
			break;
		}
	}

	function ShowHomeMenu(e)
	{
		if (editmode == 1)
			return;
		return self.GoPage(0, catalog[0]);
	}
	
	function ShowToolMenu(e)
	{
		if (toolObj == undefined)
			return;
		ReloadToolMenu();
		var pos = $.jcom.getObjPos($("#ToolIcon")[0]);
		var t = 0;//$(window).scrollTop();
		headObj.ToolMenu.show(pos.left, t + pos.bottom, pos.left, t + pos.bottom);
	}
	
	function ReloadToolMenu(flag)
	{
		if (headObj.ToolMenu == undefined)
		{
			var items = toolObj.getmenu();
			headObj.ToolMenu = new $.jcom.CommonMenu(items, {itemstyle:"font:normal normal normal 16px ΢���ź�", position:"fixed"});
			return;
		}
		if (flag != true)
			return;
		var items = toolObj.getmenu();
		headObj.ToolMenu.reload(items);		
	}
	
	function ShowShelfMenu(e)
	{
		if (editmode == 1)
			return;
		if (headObj.leftMenu == undefined)
			return self.GoPage(0, catalog[0]);

		var pos = $.jcom.getObjPos($("#Shelf")[0]);
		var t = 0;//$(window).scrollTop();
		headObj.leftMenu.show(pos.left, t + pos.bottom, pos.left, t + pos.bottom);
	}
	
	function ShowChapterMenu(e)
	{
		if (editmode == 1)
			return;
		if (headObj.rightMenu.length == 0)
			return;
		if (headObj.rightMenu.length == 1)
		{
			var pos = $.jcom.getObjPos($("#Chapter")[0]);
			var t = 0;//$(window).scrollTop();
			headObj.rightMenu[0].show(pos.left, t + pos.bottom, pos.left, t + pos.bottom);
			return;
		}
		var x = e.target.tabIndex;
		var pos = $.jcom.getObjPos(e.target);
		var t = 0;//$(window).scrollTop();
		headObj.rightMenu[x].show(pos.left, t + pos.bottom, pos.left, t + pos.bottom);
	}
	
	function PrintDoc()
	{
		$("#" + cfg.headid).css({display:"none"});
		$("#SysStatus").css({display:"none"});
		$("#TopToolBox").css({display:"none"});
		$("#" + cfg.leftid).css({display:"none"});
		$("#RightBox").css({display:"none"});
		$("#OutlineDiv").css({display:"none"});
		$("#DiscussBox").css({display:"none"});
		$(document).on("mousedown", PrintEnd);
		if (window.confirm("����Ҫֱ�Ӵ�ӡ��ҳ������Ҫ��Ԥ�����ٴ�ӡ��\n�����ȷ����ֱ�Ӵ�ӡ������������ȡ����������ѡ��������Ĵ�ӡԤ�����ܡ�\n��ʾ����ӡ��ɺ󣬵���ĵ����⴦��ָ�ԭ���档") == true)
			    window.print();
	}
	
	function PrintEnd(e)
	{
		if (e.button == 2)
			return;
		$("#" + cfg.headid).css({display:""});
		$("#SysStatus").css({display:""});
		$("#TopToolBox").css({display:""});
		$("#" + cfg.leftid).css({display:""});
		$("#RightBox").css({display:""});
		$("#OutlineDiv").css({display:""});
		$("#DiscussBox").css({display:""});
		$(document).off("mousedown", PrintEnd);
		resize();
//	    if (PrintNext())
//	      return;
	}
	
	function ZoomDoc()
	{
		if (PageRecord.scale == 1)
		{
			if (PageRecord.PageWidth > 820)
				return alert("ҳ����ȳ���A4�ߴ磬���ܷŴ�");
			PageRecord.scale = 2;
			$("#ZoomDoc").html("&#59390");
			$("#SetupDoc").css({display:"none"});
			$("#SetupDoc").css({display:"none"});
			$("#PrintDoc").css({display:"none"});
			$("#ScalePad").height($("#DocFrame")[0].offsetHeight);
			$("#DocFrame").css({transform: "scale(2, 2)", transformOrigin:"center top"});
			self.setDocWidth(cfg.docwidth * 2);
		}
		else
		{
			PageRecord.scale = 1;
			$("#ZoomDoc").html("&#59389");
			$("#SetupDoc").css({display:""});
			$("#PrintDoc").css({display:""});
			$("#DocFrame").css({transform: "none"});
			$("#ScalePad").height(0);
			self.setDocWidth(cfg.docwidth / 2);			
		}
		SavePageParam();
	}
		
	function SetupDoc(e)
	{
		var pos = $.jcom.getObjPos(e.target);
		if (typeof PageSetupBox == "object")
		{
			PageSetupForm.setRecord(PageRecord);
			return PageSetupBox.show(pos.left, pos.bottom, pos.left, pos.bottom);
		}
		PageSetupBox = new $.jcom.PopupBox("<div id=PageSetupDiv style='width:300px;height:170px;'></div>", 
			pos.left, pos.bottom, pos.left, pos.bottom, {autoHide:1, hideButton:"#58994", title:"ҳ������", border:"1px solid gray"});

		PageSetupForm = new $.jcom.FormView($("#PageSetupDiv")[0],
			[{CName:"ҳ�����", EName: "PageWidth", InputType:8, Relation:"<input type=range list=docWidthRange min=320 max=1600 style=width:200px list=Range name=PageWidth>" +
				"<datalist id=docWidthRange><option label=A4 value=794/><option label=A3 value=1123/><option label=A3H value=1588/></datalist>"},
			{CName:"��߾�", EName: "LeftPadding"},
			{CName:"�ұ߾�", EName: "RightPadding"},
			{CName:"��ർ��", EName: "LeftOption", InputType:3, Quote:"(1:��,2:����,3:���)"}], {}, {submitbutton:"����"});
		PageSetupForm.submit = SetUpDocRun;
		PageSetupForm.setRecord(PageRecord);
	}
	
	function SetUpDocRun()
	{
		PageRecord = PageSetupForm.getRecord();
		PageRecord.LeftOption = parseInt(PageRecord.LeftOption.value);
		self.setDocWidth(PageRecord.PageWidth);
		$("#Page").css({paddingLeft: PageRecord.LeftPadding + "px", paddingRight: PageRecord.RightPadding + "px"});
		SavePageParam();
		ResetLeftTree();
		PageSetupBox.hide();
		return false;
	}
	
	function AddMyPage()
	{
		var pagename = getSkipPage(0);
		AddFavs({PageCode:sys.PageName, PageTitle:pagename, nSerial:0, Status:1});
		PageChange();
	}
	
	function AddFavs(fav)
	{
		for (var x = 0; x < favs.length; x++)
		{
			if ((favs[x].PageCode == fav.PageCode) && (favs[x].PageTitle == fav.PageTitle))
			{
				favs.splice(x, 1);
				fav.Status = 0;
				break;
			}
		}
		if (fav.Status == 1)
			favs[favs.length] = fav;
		$.jcom.Ajax(cfg.serverURL + "?SaveFav=1", true, fav);
		var s = $.jcom.toJSONStr({objRight:objRight, favs:favs});		
		sessionStorage.RightandFavs = s;
	}
	
	function ClickLink(obj, item)
	{
		var ss = item.Code.split("#");
		hash = "";
		if (ss.length > 1)
			hash = "#" + ss[1];
		var pagename = getSkipPage(0);
		var x = pagename.indexOf(": ");
		if (x >= 0)
		{
			sessionStorage.bookmark = "GoLink" + pagename.substr(x);
			var url = ss[0] + ".jsp";
		}
		else
			var url = self.onLink(item, ss[0] + ".jsp");
		if (url != "")
		{
			if (obj.tagName == "SPAN")
				window.open(url + hash);
			else
				location.href = url + hash;
		}
	}

	function DisItems(items)
	{
		for (var x = items.length - 1; x >= 0; x--)
		{
			if (items[x].Attrib > sys.Role)
				items.splice(x, 1);
			else
			{
				if (typeof items[x].child == "object")
					DisItems(items[x].child);
			}
		}
		return items;
	}
	
	this.onLink = function(item, url)	//�¼�:��תǰΪ��תҳ����ϲ���
	{
		return url;
	};
	
	this.setPageObj = function (o)		//����:�����ⲿ��ҳ���������Զ���ҳ
	{
		docObj = o;
		o.onPageChange = PageChange;
		var bookmark = sessionStorage.bookmark;
		if (typeof bookmark == "string")
		{
			var x = bookmark.indexOf(": ");
			if (x < 0)
				x = 0;
			else
				x += 2;
			o.goBookMark(bookmark.substr(x));
			sessionStorage.removeItem("bookmark");
		}
	
	};

	function PageChange()
	{
		var pagetitle = getSkipPage(0);
		for (var x = 0; x < favs.length; x++)
		{
			if ((favs[x].PageCode == sys.PageName) && (favs[x].PageTitle == pagetitle))
			{
				$("#MyPage").html("&#9733");
				return true;
			}
		}
		$("#MyPage").html("&#9734");
	}
	
	this.getChild = function(name)		//����:��ȡ�Ӷ���
	{
		var o = {headObj: headObj, oLayer: oLayer, minorObj: minorObj, leftObj: leftObj, toolObj: toolObj, linkObj: linkObj, docObj: docObj, sys: sys, cfg: cfg, favs: favs, oSocket: oSocket};
		if (name == undefined)
			return o;
		return o[name];
	};
	
	this.setTool = function (items, option)		//����:���ù�����
	{
		toolDef = DisItems(items);
		if (items.length > 0)
		{
			option = $.jcom.initObjVal({border:"none", width:"120px", padding:"4px", css:"font:normal normal normal 12px ΢���ź�;line-height:25px"}, option);
			$("#RightBox").append("<br><div id=ToolBox style='width:" + option.width + ";border:" + option.border + ";padding:" + option.padding + ";overflow:visible;'></div>");
			toolObj = new $.jcom.CommonMenu(toolDef, {itemstyle:option.css, domobj:$("#ToolBox")[0], position:"fixed"});
			resize();
		}		
	};
	
	this.setLink = function (items, option)		//����:���òο�ҳ��
	{
		for (var x = 0; x < items.length; x++)
			items[x].img = "#9702";
		if (items.length > 0)
		{
			option = $.jcom.initObjVal({border:"none", padding:"4px", bgcolor:"", css:"font:normal normal normal 14px ΢���ź�;line-height:25px;color:blue", tcss:"color:blue;font:normal normal normal 16px ΢���ź�;"}, option);
			$("#RightBox").append("<br><div id=LinkBox style='width:" + option.width + ";border:" + option.border + 
				";background-color:" + option.bgcolor + ";padding:" + option.padding + ";overflow:visible;'></div>");
			var rollshadow = new $.jcom.CommonShadow(4, "&nbsp;&#10169&nbsp;", "color:gray");
			linkObj = new $.jcom.Cascade($("#LinkBox")[0], items, {itemstyle:option.css, title:["�ο�ҳ��"], itemtag:"div", tcss: option.tcss, rollDef:rollshadow});
			linkObj.onclick = ClickLink;
		}
	}
	
	this.setDocTop = function (text, id, option)	//����:��������ǰ��ǰ�ö������ڼ�������
	{
		option = $.jcom.initObjVal({border:"none", bgcolor:"white", css:"", outline:true}, option);
		var tag = "<div id=" + id + " style='border:" + option.border + ";width:100%;'>" + text + "</div>"
		if (option.outline && (!browser.mobile))
		{
			if ($("#OutlineImg").length == 0)
			{
				tag = "<div id=OutlineTitle style=width:100%;>" + $.jcom.getItemImg("#59282", "font-size:16px;color:gray;", "span", "id=OutlineImg") +
					"</div>" + tag;
				$("#DocFrame").css({paddingTop: "40px"});
				$("#" + cfg.docid).before("<div id=OutlineDiv style=background-color:" + option.bgcolor + ">" + tag + "</div>");
				$("#OutlineImg").on("click", self.ToggleOutline);
			}
			else
				$("#OutlineDiv").append(tag);
		}
		else
			$("#" + cfg.docid).before(tag);
			
		return $("#" + id)[0];
	};
	
	this.setDocBottom = function (text, id, option)		//�����������ڱ���ҳ����Ϣ��
	{
		option = $.jcom.initObjVal({border:"none", bgcolor:"white", css:""}, option);
		var tag = "<div id=" + id + " style='border:" + option.border + ";width:100%;'>" + text + "</div>"
		$("#" + cfg.docid).after(tag);
		return $("#" + id)[0];		
	};
	
	this.setPageLeft = function (title, id, option)		//����:���������
	{
		option = $.jcom.initObjVal({border:"1px solid gray", bgcolor:"white"}, option);
		var tag = "<div class=BookLeftTree id=UserLeftDiv style='position:fixed;left:1px;top:" + cfg.lefttop + "px;background-color:" +
			option.bgcolor + ";border:" + option.border + "'><div id=UserLeftTitle style='width:100%;height:20px;'>" + 
			$.jcom.getItemImg("#59282", "font-size:16px;color:gray;float:left", "div", "id=UserLeftButtonImg") + title +
			"</div><div id=" + id + " style='width:100%;overflow:auto;'></div></div>";		
		$(cfg.doc.body).append(tag);
		resize();
		return $("#" + id)[0];
	};
	
	this.setPageLeftStyle = function (style)		//����:������������
	{
		$("#UserLeftDiv").css(style);
	};
	
	this.setDocWidth = function (width)				//����:���������ĵ�����
	{
		cfg.docwidth = width;
		initWidth = cfg.docwidth;
		$("#DocFrame").width(parseInt(width / PageRecord.scale) - 40);
		$("#" + cfg.headid).width(width - 40);
		$("#RightBox").css({marginLeft: (width / 2 + 6) + "px"});
		$("#TopToolBox").css({marginLeft: -(width / 2 + 120) + "px"});
		$("#SysStatus").css({marginLeft: (width / 2 + 10) + "px"});
		if (PageRecord.LeftOption == 2) //���������
			$("#" + cfg.leftid).css({marginLeft: -(width / 2 + cfg.leftwidth + cfg.leftright) + "px"});
		resize();
	};
	
	this.ToggleOutline = function ()			//����:��ǰ�ö����л�����߻��ϱ�
	{
		var o = $("#OutlineDiv");
		o.toggleClass("BookLeftTree");
		if (o.css("position") != "fixed")
		{
//			$("#" + cfg.leftid).css({display:"none"});
			$("#OutlineImg", o).html("&#59285");
			$(cfg.doc.body).append(o);
			o.css({left: "1px", top: cfg.lefttop + "px", border: "1px solid gray", position:"fixed"});
		
			$("#OutlineTitle", o).prop("align", "right");
			$("#OutlineDiv div:last-child").eq(0).css({overflow: "auto"});
			resize();
		}
		else
		{
//			$("#" + cfg.leftid).css({display:""});
			$("#" + cfg.docid).before(o);
			o.css({width: "100%", border: "none", position:""});
			$("#OutlineTitle", o).prop("align", "");
			$("#OutlineImg", o).html("&#59282");
			$("#OutlineDiv div:last-child").eq(0).css({height: "", overflow: ""});			
		}
	};
	
	this.setBottom = function (id, text, option)	//����:���õײ�������Ҫ���ڷ�ҳ
	{
		option = $.jcom.initObjVal({border:"none", bgcolor:"white", css:""}, option);
		$("#" + cfg.docid).after("<div id=" + id + " style='border:" + option.border + ";background-color:" + option.bgcolor + ";width:100%;'>" + text + "</div>");
		return $("#" + id);
	};
		
	this.getDocObj = function (id)		//����:�õ����Ķ���
	{
		if (id == "Page")
			return $("#" + id);
		return oLayer.getObj(id);
	};
	
	this.prevpage = function()			//����:��ת����һҳ
	{
	};
	
	this.nextpage = function ()			//����:��ת����һҳ
	{
		return window.location.reload(true);
	};
	
	this.getItem = function (code)		//����:�õ�Ŀ¼��
	{
		return headObj.items[headObj.items.length - 1];
	};
	
	this.toggleEditMode = function ()	//����:�ڱ༭���Ķ�ģʽ֮���л�
	{
		ReloadToolMenu(true);
		if (editmode == 0)
		{
			editmode = 1;
			$("#OutlineDiv").addClass("hide");
			$("#OutlineDiv").css({display:"none"});
			$("#OutlineDiv").css({display:"none"});
			$("#LinkBox").css({display:"none"});
			$("#Shelf").css({color:"gray"});
			$("#Chapter").css({color:"gray"});
			$("#DiscussBox").css({display:"none"});
			$("#" + cfg.leftid).css({display:"none"});
			self.setPageLeftStyle({display:""});
			window.onbeforeunload = ExitHint;
		}
		else
		{
			editmode = 0;
			$("#OutlineDiv").removeClass("hide");
			$("#OutlineDiv").css({display:""});
			$("#LinkBox").css({display:""});
			$("#Shelf").css({color:""});
			$("#Chapter").css({color:""});
			$("#DiscussBox").css({display:""});
			$("#" + cfg.leftid).css({display:""});
			self.setPageLeftStyle({display:"none"});
			toolObj.reload(toolDef);
			window.onbeforeunload = null;
		}
		return editmode;
	};
	
	function ExitHint()
	{
		event.returnValue = "��ʾ��Ŀǰ�����ڱ༭״̬���˳��п��ܶ�ʧ�ѱ༭������.";
	}
	
	var timer, scrollcnt;
	function scrollDoc(event)
	{
		var maxTick = 5;
		if (editmode == 1)
			return;
		if (document.body.scroll == "no")
			return;
		if (reloadFlag)
			return false;
		if (typeof oDiscuss == "object")
			oDiscuss.Load(getSkipPage(0));
		if ($(window).scrollTop() + $(window).height() <= $("#DocFrame")[0].offsetHeight * PageRecord.scale)
		{
			$("#AutoPageUp").css("display", "none");
			if (timer != undefined)
			{
				window.clearTimeout(timer);
				timer = undefined;
			}
			return;
		}
		
		var item = getSkipPage(1);
		if (item == undefined)
			return;

		var pageName = item;
		var pageid = "InnerPageUp";
		if (typeof item == "object")
		{
			pageName = item.item;
			var pageid = "OuterPageUp";
			
		}
		if ($("#AutoPageUp").css("display") == "none")
		{
			if (PageRecord.scale == 2)
				$("#ScalePad").height($("#DocFrame")[0].offsetHeight);
			$("#AutoPageUp").html("<div id=" + pageid + ">��һҳ��" + pageName + "</div>");
			$("#AutoPageUp").css("display", "");
			timer = window.setTimeout(waitingPageUp, 1000);
			scrollcnt = 0;
			return;
		}

		if (scrollcnt ++ < maxTick)
			return;
		if (scrollcnt == maxTick + 1)
		{
			$("#AutoPageUp").html("<div id=" + pageid + ">��һҳ��" + pageName + "</div><div id=WaitingSkipSpan>" + maxTick + "����Զ�����һҳ.</div>");
			window.clearTimeout(timer);
			timer = window.setTimeout(WaitingSkip, 1000);
			return;
		}
		if (typeof item == "object")
			return;
		if (scrollcnt == 11)
		{
			item = getSkipChapter(1);
			if (typeof item == "object")
			{
				$("#AutoPageUp").html("<div id=InnerPageUp>��һҳ��" + pageName + "</div><br><div id=OuterPageUp>��һ��:" +
						item.item + "</div><div id=WaitingSkipSpan>" + maxTick + "����Զ�����һ��.</div>");
			}
		}
	}
	
	function WaitingSkip()
	{
		var text = $("#WaitingSkipSpan").html();
		var cnt = parseInt(text) - 1;
		if (cnt > 0)
		{
			$("#WaitingSkipSpan").html(cnt + text.substr(1) + ".");
			timer = window.setTimeout(WaitingSkip, 1000);
			return;
		}
		reloadFlag = false;
		if ($("#SysStatus").css("position") == "fixed")
			window.scrollTo(0, 0);
		else
			window.scrollTo(0, 80);			
		clickPageup($("#WaitingSkipSpan").prev()[0]);
	}
	
	function clickPageup(obj)
	{
		if (obj.id == "OuterPageUp")
		{
			var item = getSkipChapter(1);
			return self.GoPage(0, item);
		}
		else if (obj.id == "InnerPageUp")
		{
			$("#AutoPageUp").css("display", "none");
			docObj.SkipPage(1, true);
		}
	}
	
	function waitingPageUp()
	{
		$("#AutoPageUp").css("display", "none");
		timer = undefined;
	}

	function PageUpRun(e)
	{
		if (e.target.id == "WaitingSkipSpan")
			clickPageup($(e.target).prev()[0]);
		else
			clickPageup(e.target);
	}
	if ((aFace != undefined) && (chapters != undefined))	
		init();
}

$.jcom.BookPage.prototype.GoPage = function (obj, item)		//����:��ת��ָ�����������ҳ��
{
	var code = item;
	if (typeof item == "object")
		code = item.Code;
	var ss = code.split("#");
	hash = "";
	if (ss.length > 1)
		hash = "#" + ss[1];
	location.href = ss[0] + ".jsp" + hash;
};

$.jcom.ChapterTree = function(domobj, chapters, cfg)	//��:Ŀ¼��
{//������Ŀ¼�����ࣺTreeView
	var self = this;
	cfg = $.jcom.initObjVal({initDepth:2,vpadding:3, imgstyle:"font-size:25px;color:gray;", fontChange:1, currentCode:""}, cfg);
	if (cfg.fontChange == 1)
		prepare(chapters, 0);
	$.jcom.TreeView.call(this, domobj, chapters, cfg);
	SetCurrent(chapters, cfg.currentCode);
	this.click = function (o, e)	//�¼�:����¼�
	{
		var item = self.getTreeItem($(o).attr("node"));
		if (typeof item == "object")
			$.jcom.BookPage.prototype.GoPage(0, item);
//			location.href = item.Code + ".jsp";
	};
	
	function prepare(items, depth)
	{
		if (items == undefined)
			return;
		for (var x = 0; x < items.length; x++)
		{
			items[x].style = "font:normal normal normal " + (20 - depth * 3) + "px ΢���ź�;height:" + (40 - depth * 3) + "px";
			items[x].item += "<span style=color:#c0c0c0;font-size:12px;padding:8px;>" + items[x].Info + "</span>";
			if (typeof items[x].child == "object")
				prepare(items[x].child, depth + 1);
		}
	}
	
	function SetCurrent(items, code)
	{
		if (cfg.currentCode == "")
			return;
		var node = self.getItemNode("Code", code);
		if (node == undefined)
			return;
		var ss = node.split(",");
		var pnode = "", sp = "";
		for (var x = 0; x <ss.length; x++)
		{
			pnode += sp + ss[x];
			sp = ",";
			var obj = self.getNodeObj(0, pnode);
			self.expand(obj, true);
		}
		var obj = self.getNodeObj("Code", code);
		self.select(obj);
	}
}

$.jcom.PageDiscuss = function (domobj, sys, cfg)	//��:ҳ��������
{
	var self = this;
	var initflag = false;
	var PageTitle = "δ����...";
	var grid;
	function init()
	{
		var tag = "";
		if (sys.Role >= 1)
			tag +="<input type=radio name=DiscussType checked value=2><span title=���������˿ɼ�>����&nbsp;</span>";
		if (sys.Role >= 2)
			tag +="<input type=radio name=DiscussType value=3><span title=���������ߺͱ༭�Ľ��������߲��ɼ�>����&nbsp;</span>";
		if (sys.Role >= 8)
			tag +="<input type=radio name=DiscussType value=4><span title=��ʾ����������ߺͱ༭��ָʾ�����߲��ɼ�>��ʾ</span>";
		domobj.innerHTML = "<span style='float:left;font-size:20pt;font-family:iconfont;'>&#58899&nbsp;</span>" + tag +
			"<textarea id=DiscussText placeholder=���������˿ɼ� style='height:100px;border:1px solid gray;width:100%;'></textarea>" +
			"<div style=float:left><input id=SetupButton type=button value=����></div><div align=right style=float:right><input id=SubmitButton type=button style='width:100px;font:normal normal normal 16px ΢���ź�' value=�ύ></div>" +
			"<div id=DiscussHis style=clear:both></div>";
		grid = new $.jcom.DBGrid($("#DiscussHis")[0], "../fvs/PageDiscuss_view.jsp", {formitemstyle:"font:normal normal normal 16px ΢���ź�", 
			formvalstyle:"width:400px"}, {PageCode: sys.PageName, PageTitle:PageTitle}, {headstyle:3, gridstyle:4, resizeflag:0});
		$("input[name='DiscussType']", domobj).on("click", ClickType);
		$("#SubmitButton", domobj).on("click", SendMsg);
		$("#SetupButton", domobj).on("click", Setup);
		initflag = true;
	}
	
	function Setup()
	{
		alert("==");
	}
	
	function SendMsg()
	{
		var o = {DiscussType:$("input[name='DiscussType']:checked", domobj).val(), Content: $("#DiscussText", domobj).val(), PageCode:sys.PageName, PageTitle:PageTitle};
		if (o.msg == "")
			return alert("���ܷ��Ϳ���Ϣ��");
		$.jcom.Ajax(cfg.url + "?SaveDiscuss=1", true, o, SendMsgOK);
	}

	function SendMsgOK(data)
	{
		if (data != "OK")
			return alert(data);
		var items = grid.getData();
		items.splice(0, 0, {Writer:sys.CName, Content:$("#DiscussText", domobj).val(), DiscussType:$("input[name='DiscussType']:checked", domobj).val(), SubmitTime:$.jcom.GetDateTimeString(new Date(), 2)});
		$("#DiscussText", domobj).val("");
		grid.reload(items);
	}
	
	function ClickType(e)
	{
		$("#DiscussText", domobj).attr("placeholder", e.target.nextSibling.title);
	}
	
	this.Load = function(title)		//����:��������
	{
		if (initflag == false)
		{	
			PageTitle = title;
			init();
			return;
		}

		if (title != PageTitle)
		{
			PageTitle = title;
			grid.ReloadGrid({PageCode: sys.PageName, PageTitle: PageTitle});
		}
	};
};

$.jcom.RealSocket = function (sys)		//��:ʵʱͨѶ��
{//WebSocket��Ӧ��
	var self = this;
	var path = $.jcom.GetRootPath();
	var ws;
	function init()
	{
		if (sys == undefined)
			return;
		ws = new WebSocket("ws://" + path.substr(7) + "/WebRealServer/" + sys.nType + "." + sys.EName);
		ws.onopen = function()
		{
		};

		ws.onmessage = function(event)
		{
			var x = event.data.indexOf("&");
			var cmd = event.data.substr(0, x);
			var text = event.data.substr(x + 1);
			self.onMsg(cmd, text);
		};

		ws.onclose = function(event)
		{ 
			sessionStorage.removeItem("RealBegin");
			self.onMsg("onClose", "");
		};
	}

	this.onMsg = function (cmd, text)		//�¼�:�յ��������ı���Ϣ
	{
	};

	this.send = function (cmd, text)		//����:������������ı���Ϣ
	{
		ws.send(cmd + "&" + text);
		
	};

	init();
}

$.jcom.RealSocket.prototype.getMsgObj = function(text)	//����:���ı�ת������Ϣ����
{
	var ss = text.split("|");
	if (ss.length < 5)
		return;
	var photoID = 0, Sender = ss[2];
	var sss = ss[2].split(",");
	if (sss.length > 1)
	{
		Sender = sss[0];
		photoID = sss[1];
	}
	var Receiver = ss[3], GroupName = "";
	var sss = ss[3].split(",");
	if (sss.length > 1)
	{
		Receiver = sss[0];
		GroupName = sss[1];
	}
	return {ID: ss[0], SendDate: ss[1], Sender: Sender, Photo: photoID, Receiver: Receiver, GroupName: GroupName, Mark: ss[4], 
		Content:text.substr(ss[0].length + ss[1].length + ss[2].length + ss[3].length + ss[4].length + 5)}
};

$.jcom.RealSocket.prototype.getImg = function(Photo, height)	//����:�õ�ͼƬ
{
	if (Photo == 0)
		return "<img src=../pic/366.jpg style=height:" +height + "px>";
	else
		return "<img src=../com/down.jsp?AffixID=" + Photo + " style=height:" + height + "px>";
};

$.jcom.DBFun = function (jsp, cfg)		//��:��ɾ�Ĺ���
{//��DBGrid,DBTree�ȵ����ϻ��࣬Ҳ�ɵ���ʹ��
	var self = this;
	var EditWin, editform;
	var EditWinForm = [];
	var w = $(window).width();
	if (w > 640)
		w = 640;
	cfg = $.jcom.initObjVal({title:["����","�༭"], width:w, height:480, mask:50, bAutoClose:true, itemstyle:"", valstyle:""}, cfg);
	
	this.NewRecord = function(option)		//����:������¼
	{
		this.EditRecord("", option);
	};
	
	this.EditRecord = function(dataID, option)		//����:�༭��¼
	{
		var title = cfg.title[1];
		if ((dataID == "") || (dataID == 0))
			title = cfg.title[0];
		option = $.jcom.initObjVal({EditAction:jsp, title:title, width:cfg.width, height:cfg.height, 
			mask:cfg.mask, itemstyle:cfg.itemstyle, valstyle:cfg.valstyle, URLParam:""}, option);
		
		if (option.EditAction != "")
			option.EditAction = self.getFormURL(jsp, option.EditAction);
		if (option.EditAction == "")
			return alert("���ܱ༭");
		var x = getWinFormIndex(option.EditAction);
		if (x == undefined)
		{
			x = EditWinForm.length;
			var o = {};
		 	o.win = new $.jcom.PopupWin("<div id=EditFormDiv node=\"" + option.EditAction + "\" style=width:100%;height:100%;overflow:auto;></div>", 
				{title:option.title, width:option.width, height:option.height, mask:option.mask,position:"fixed"});
			o.form = new $.jcom.DBForm($("#EditFormDiv[node='" + option.EditAction + "']")[0], option.EditAction, 
				{DataID: dataID, URLParam:option.URLParam}, {itemstyle:option.itemstyle, valstyle:option.valstyle});
			o.form.onready = FormReady;
			o.form.onSaveOK = SaveOK;
			o.win.close = o.win.hide;
			o.action = option.EditAction;
			EditWinForm[x] = o;
			return true;
		}
		EditWinForm[x].win.show();
		EditWinForm[x].form.getDBRecord(dataID, {URLParam:option.URLParam});
		return false;
	};
	
	function getWinFormIndex(jsp)
	{
		for (var x = 0; x < EditWinForm.length; x++)
		{
			if (EditWinForm[x].action == jsp)
				return x;
		}
	}
	
	function FormReady(fields, record, title, jsp)
	{
		var x = getWinFormIndex(jsp);
		if (x == undefined)
			return;
		EditWinForm[x].win.setTitle(title);
		self.onFormReady(fields, record, title, EditWinForm[x]);
	}
	
	function SaveOK(jsp)
	{
		if (cfg.bAutoClose == true)
		{
			var x = getWinFormIndex(jsp);
			if (x != undefined)
					EditWinForm[x].win.hide();
		}
		self.onRecordChange(2, jsp);
	}
	
	this.DelRecord = function(dataID, option)		//����:ɾ����¼
	{
		option = $.jcom.initObjVal({EditAction:jsp, hint:true, fun:undefined}, option);
		if (option.hint != false)
		{
			if (typeof option.hint != "string")
				option.hint = "��׼��ɾ����¼���Ƿ�ȷ��?";
			if (window.confirm(option.hint) == false)
				return;
		}
		if (option.fun == undefined)
		{
			option.fun = function (result)
			{
				if (result == "OK")
				{
					self.onRecordChange(1);
					//self.deleteRow();
				}
				else
					alert(result);
			};
		}
		
		if (option.EditAction != "")
			$.get(self.getFormURL(jsp, option.EditAction), {FormSaveFlag:1, I_DeleteFlag:1, DataID: dataID}, option.fun);
		else
			$.get(self.getFormURL(jsp, option.SeekAction), {BatchAction:1, BatchValue:dataID, Ajax:1}, option.fun);
	};
	
	this.NewItem = function (option)		//����:��ѡ��������������ͼ��̳�
	{
		ModifyRecord("", option)
	};
	
	this.EditItem = function (option)		//����:��ѡ��༭��������ͼ��̳�
	{
		var DataID = self.getSelItemKeyValue();
		if (DataID == undefined)
			return alert("����ѡ��һ����¼");
		ModifyRecord(DataID, option);
	};
	
	function ModifyRecord(id, option)
	{
		option = $.jcom.initObjVal(self.getOption(1), option);
		self.EditRecord(id, option);
	}

	this.DeleteItem = function (option)		//����:��ѡ��ɾ����������ͼ��̳�
	{
		var DataID = self.getSelItemKeyValue();
		if (DataID == undefined)
			return alert("����ѡ��һ����¼");
		option = $.jcom.initObjVal(self.getOption(2), option);
		return self.DelRecord(DataID, option);
	};
	
	this.getSelItemKeyValue = function()		//����:���ѡ�����ֵ���鷽��������ͼ��̳�ʵ��
	{
		alert("�麯�����ܵ���");
	};

	this.getOption = function(nType)		//����:�õ�ѡ��鷽��������ͼ��̳�ʵ��
	{
		alert("�麯�����ܵ���");
	};
	
	this.getFormURL = function(jsp, form)		//����:���ݱ������õ������ķ�������URL
	{
		if ((form == undefined) || (form == ""))
			return "";
		if (form.substr(form.length - 4) == ".jsp")
			return form;
		if (typeof env == "object")
			return env.fvs + "/" + form + ".jsp";
		var b =jsp.lastIndexOf("/");
		return jsp.substr(0, b + 1) + form + ".jsp";
	};
	
	this.jspfile = function (file)		//����:���û��ȡ����URL
	{
		if (typeof file == "string")
			jsp = self.getFormURL(jsp, file);
		return jsp;
	};
	
	this.onFormReady = function (fields, record, title, winform)		//�¼�:������׼����
	{
	};
	
	this.onRecordChange = function(nType, jsp)		//�¼�:��¼�Ѹı�
	{
	};
};

$.jcom.DBGrid = function(domobj, jsp, cfg, seekcfg, gridcfg)	//��:����GRid��
{//��ƽ̨�б���ͼƥ����࣬���ࣺGridView
//domobj:��������
//jsp:ƽ̨���ɵ���ͼ�����ֻ�URL
//cfg:����ѡ���������
//URLParam:""--��Ҫ���͸���ͼ��URL����--
//EditAction:""--��ͼ��Ӧ�ı༭����������--
//ViewAction:""--��ͼ��Ӧ�Ĳ鿴����������--
//SeekAction:""--��ͼ��Ӧ�Ĺ��˲�ѯ����������--
//InAction:""--��ͼ��Ӧ������ȫ���༭�ı���������--
//Menubar:""--�˵�--
//formitemstyle:""--Ҫ�򿪵ı���������--
//formvalstyle:""--Ҫ�򿪵ı����ı������--
//gridtree:0--�Ƿ�ʹ��������ͼ--����ƽ̨��������ͼ����Ҫ������ֶ�����Ϊ����
//seekcfg:��ѯѡ���Ĭ���������£�
//SeekKey:""--��Ҫ��ѯ�Ĺؼ�������--
//SeekParam:""--��Ҫ��ѯ������--
//OrderField:""--�����ֶ�--
//bDesc:""--�������--
//ViewMode:1--��ͼģʽ--Ҫ������
//Page:1--��ǰҳ��--
//GetTreeData:cfg.gridtree--�Ƿ�ʹ������--	
//gridcfg:����GridView������ѡ��μ�GridView
	
	var self = this;
	$.jcom.GridView.call(this, domobj, [], [], {}, gridcfg);
	cfg = $.jcom.initObjVal({URLParam:"", EditAction:"", ViewAction:"", SeekAction:"", InAction:"", Menubar:"", formitemstyle:"", formvalstyle:"",gridtree:0}, cfg);
	$.jcom.DBFun.call(this, cfg.EditAction, {itemstyle:cfg.formitemstyle, valstyle: cfg.formvalstyle});

	var head, inform, filterform;
	var TableName, TableCName;
	var hostMenuDef;
	var editMode = 0;
	var seekWin, complexSeekWin, seekMode = 0;
	function initgrid(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
		{
			domobj.innerText = json;
			return;
		}
		head = json.head;
		TableName = json.TableName;
		TableCName = json.TableCName;
		if (cfg.EditAction == "")
			cfg.EditAction = self.getFormURL(jsp, json.EditForm);
		if (cfg.ViewAction == "")
			cfg.ViewAction = self.getFormURL(jsp, json.ViewForm);
		if (cfg.SeekAction == "")
			cfg.SeekAction = self.getFormURL(jsp, json.SeekForm);
		if (cfg.InAction == "")
			cfg.InAction = self.getFormURL(jsp, json.AllEditForm);
		
		if (cfg.gridtree > 0)
		{
			var items = self.PrepareData(json.data, head);
			self.reset(items, {}, head);
		}
		else
		{
			var items = self.PrepareData(json.Data, head);
			if (json.ThumbNail == "")
				self.reset(items, json.info, head);
			else
				self.reset(items, json.info, head, {ThumbNail:json.ThumbNail});
			self.pageskip = GridPageSkip;
			self.orderField = GridOrderField;
		}
		self.onPageChange();
	}

	this.PrepareData = function(items, head)	//�¼�:׼�����ݣ����������ݽ���ת��
	{
		return items;
	};

	this.ReloadGrid = function(data)		//����:���¼�������
	{//
	//data:���ݣ�������Ϊundefined�����Զ��ӷ��������أ���ΪJSON��ʽ���ı�����ת���ɶ�����أ���Ϊ�����򵱳���seekcfg����
		if ((typeof data == "undefined") || (typeof data == "object"))
		{
			self.waiting();
			if (typeof data == "object")
				seekcfg = $.jcom.initObjVal(seekcfg, data);
			$.jcom.Ajax(jsp + cfg.URLParam, true, seekcfg, self.ReloadGrid);
			return;
		}
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return self.waiting(json);
		var items = json.Data;
		if (items == undefined)
			items = json.data;
		items = self.PrepareData(items, head);
		self.reload(items, json.info);
		self.onPageChange();
		self.onReloadReady();
	};
	
	this.onReloadReady = function ()	//�¼�:������ɺ����
	{};
	
	function GridOrderField(Field, desc)
	{
		seekcfg = $.jcom.initObjVal(seekcfg, {GetGridData:1, OrderField:Field, bDesc:desc, Page:1});
		self.ReloadGrid();
		return true;
	}

	function GridPageSkip(nPage)
	{
		seekcfg = $.jcom.initObjVal(seekcfg, {GetGridData:1, Page:nPage});
		self.ReloadGrid();
	}
	
	this.SkipPage = function (delta, bRun)		//����:���ݵ�ǰҳ��ת
	{
		var c = self.getChildren();
		var info = c.pagefoot.footinfo();
		if ((info.nPage + delta <= 0) || (info.nPage + delta > info.PageCount))
			return;
		if ((bRun) || (bRun == 1))
			GridPageSkip(info.nPage + delta);
		var title = "��" + (info.nPage + delta) + "ҳ";
		var info = "",  sp = "";
		if (seekcfg.OrderField != "")
		{
			info = "����:" + seekcfg.OrderField;
			if (seekcfg.bDesc != 1)
				info += "+";
			else
				info += "-";
			sp = ",";
			
		}
		if (seekcfg.SeekParam != "")
		{
			if (seekcfg.SeekKey == "$WholeDoc$")
			{
				info += sp + "ȫ�ļ���:" + seekcfg.SeekParam;
			}
			else if (seekcfg.seekKey != "")
			{
				info += sp + "�ֶ�:" + seekcfg.seekKey + ",�ؼ���:" + seekcfg.SeekParam;				
			}
			else
			{
				info += sp +"���ϲ�ѯ:" + seekcfg.SeekParam;				
			}
		}
		if (info != "")
			info = "(" + info + ")";
		return title + info;
	};
	
	this.onPageChange = function ()		//�¼�:ҳ��ı��¼�
	{
		
	};
	
	this.goBookMark = function(bk)		//����:��ת����ǩҳ
	{
		if (bk.substr(0, 1) != "��")
			return;
		seekcfg.Page = parseInt(bk.substr(1));
		
		var b = bk.indexOf("(");
		var e = bk.indexOf(")");
		if ((b >0) && (e >0))
		{
			s = bk.substr(b + 1, e - b - 1);
			var ss = s.split(",");
			for (var x = 0; x <ss.length; x++)
			{
				if (ss[x].substr(0, 3) == "����:")
				{
					seekcfg.OrderField = ss[x].substr(3, ss[x].length - 4);
					if (ss[x].substr(ss[x].length - 1) == "-")
						seekcfg.bDesc = 1;
					else
						seekcfg.bDesc = 0;
				}
				else if (ss[x].substr(0, 5) == "ȫ�ļ���:")
				{
					seekcfg.SeekKey = "$WholeDoc$";
					seekcfg.SeekParam = ss[x].substr(5);
				}
				else if (ss[x].substr(0, 5) == "�ֶ�:")
					seekcfg.SeekKey = ss[x].substr(3);
				else if (ss[x].substr(0, 4) == "�ؼ���:")
					seekcfg.SeekParam = ss[x].substr(4);
				else if (ss[x].substr(0, 5) == "���ϲ�ѯ:")
					seekcfg.SeekParam = ss[x].substr(5);
			}
		}
		self.ReloadGrid();
	};
	
	this.init = function(url, option)		//����:��ʼ����ͼ
	{
		if ((url == "") || (typeof url != "string"))
			return;
		jsp = self.getFormURL(0, url);
		self.waiting("���ڼ���...");
		if (cfg.gridtree > 0)
			seekcfg = $.jcom.initObjVal({SeekKey:"", SeekParam:"", OrderField:"", bDesc:"", ViewMode:1, GetTreeData:cfg.gridtree}, option);
		else
			seekcfg = $.jcom.initObjVal({SeekKey:"", SeekParam:"", OrderField:"", bDesc:"", ViewMode:1, GetGridData:2}, option);
		$.jcom.Ajax(jsp + cfg.URLParam, true, seekcfg, initgrid);
	};
	
	this.Seek = function (value, key)		//����:�ؼ��ֲ�ѯ
	{
		if (value == undefined)
		{
			var f1 = function ()
			{
				self.Seek($("#InlineInputObj").val());
			};
			var f2 = function ()
			{
				seekWin.hide();
				self.ComplexSeek();
			}
			if (seekMode == 1)
				return self.ComplexSeek();
			if (seekWin == undefined)
			{
				seekWin = $.jcom.OptionWin("������ȫ�ļ����ؼ��֣�<br><br><center><input id=InlineInputObj type=text>", 
					"��ѯ", [{item:"����", action:f2}, {item:"ȷ��", action:f1}], {mask:-1});
				seekWin.close = seekWin.hide;
			}
			else
				seekWin.show();
			return seekWin;
		}
		if (value == "")
		{
			seekcfg = $.jcom.initObjVal(seekcfg, {SeekKey:"", SeekParam:"", Page:1});
			return self.ReloadGrid();
		}
		if (typeof key != "string")
			key = "$WholeDoc$";
		seekcfg = $.jcom.initObjVal(seekcfg, {GetGridData:1, Page:1, SeekKey:key, SeekParam:value});
		self.ReloadGrid();
	};
	
	this.ComplexSeek = function ()		//����:���ϲ�ѯ
	{
		if (complexSeekWin == undefined)
		{
			complexSeekWin = new $.jcom.PopupWin("<div id=ContentDiv style=padding:8px></div>", {title:"���ϲ�ѯ", width:480, height:320, mask:-1});
			complexSeekWin.close = complexSeekWin.hide;
			var seekPanel = new $.jcom.ComplexSeekPanel($("#ContentDiv")[0], head, TableName);


			seekPanel.onApply = ComplexSeekRun;
			seekPanel.onReturn = ComplexSeekReturn;
//			seekPanel.onClose = complexSeekWin.hide;
		}
		else
			complexSeekWin.show();
		seekMode = 1;
	};
	
	this.Filter = function ()		//����:��������
	{
		if (typeof filterform == "object")
			return;
		var o = self.TitleBar("<fieldset><legend style='FONT-SIZE:9pt;padding:0px 10px 0px 10px'><span id=FilterButton style=font-size:16px;>&#9698&nbsp;</span>ɸѡ</legend>" +
				"<div id=FilterDiv style=padding:20px;overflow:hidden;></div></fieldset>");
		var div = $("#FilterDiv", o);
		$("#FilterButton", o).on("click", FilterShow);
		filterform = new $.jcom.DBForm(div[0], cfg.SeekAction, {}, {submitbutton:"��ѯ"});
		filterform.beforesubmit = FilterRun;
	};
	
	function ComplexSeekReturn()
	{
		complexSeekWin.hide();
		seekWin.show();
		seekMode = 0;
	}
	
	function ComplexSeekRun(param)
	{
		seekcfg = $.jcom.initObjVal(seekcfg, {GetGridData:1, Page:1, SeekKey:"", SeekParam:param});
		self.ReloadGrid();
	}
	
	function FilterShow(e)
	{
		var o = e.target.parentNode.nextSibling;
		if (o.style.display == "none")
		{
			o.style.display = "";
			e.target.innerHTML = "&#9698&nbsp;";
		}
		else
		{
			o.style.display = "none";
			e.target.innerHTML = "&#9655&nbsp;";
		}
	}
	
	function FilterRun()
	{
		var record = filterform.getRecord();
		var param = "";
		for(var key in record)
		{
			if (record[key] != "")
			{
				if (param != "")
					param += " and ";
				var field = filterform.getFields(key);
				switch (field.FieldType)
				{
				case 3:					//Integer
				case 5:					//Counter
				case 6:					//Double
				case 7:
					param += key + "=" + record[key];
					break;
				case 9:					//Yes/No
					break;
				case 4:					//DateTime
				default:
					param += key + "='" + record[key] + "'";
				break;
				}
			}
		}
		seekcfg = $.jcom.initObjVal(seekcfg, {GetGridData:1, Page:1, SeekKey:"", SeekParam:param});
		self.ReloadGrid();
		return false;
	}
	
	this.getSelItemKeyValue = function()		//����:��õ�ǰѡ���������
	{
		var item = self.getItemData();
		if (item == undefined)
			return;
		return self.getItemKeyValue(item);		
	};
	
	this.getOption = function (nType)		//����:�����Ӧ�ı�������ͼ��URL
	{
		switch (nType)
		{
		case 1:
			return {EditAction:cfg.EditAction};
		case 2:
			return {SeekAction:jsp};
		}
	};
	
	this.ReadItem = function ()		//����:�򿪶�ȡҳ�棬������δʵ��
	{
	};
	
	this.toggleEditMode = function (book, option)		//����:��ȫ���༭ģʽ���Ķ�ģʽ֮���л�
	{
		if (editMode == 0)
		{
			if (typeof book == "object")
			{
				book.toggleEditMode();
				cfg.Menubar = book.getChild("toolObj");
				cfg.book = book;
			}
			editMode = 1;
			if (cfg.InAction == "")
				cfg.InAction = cfg.EditAction;
			if (cfg.InAction == "")
				return alert("���ܱ༭");
			if (inform == undefined)
			{
				inform = new $.jcom.DBForm(0, cfg.InAction);
				inform.onready = setEditor;
			}
			else
			{
				var fields = inform.getFields();
				setEditor(fields);
			}
			if (typeof cfg.Menubar == "object")
			{
				hostMenuDef = cfg.Menubar.getmenu();
				var def = [{item:"����", img:"#59356", action:self.InFormNew}, {item:"ɾ��", img:"#59412", action:self.InFormDel}, 
					       	    {item:"����", img:"#59432", action:self.InFormSave},{item:"����",img:"#59470", action:self.toggleEditMode}];
				cfg.Menubar.reload(def);
			}
		}
		else
		{
			if (window.confirm("�Ƿ�ȷ��Ҫ�˳��༭ģʽ?") == false)
				return;
			editMode = 0;
			if (typeof cfg.book == "object")
				cfg.book.toggleEditMode();
			else if (typeof cfg.Menubar == "object")
				cfg.Menubar.reload(hostMenuDef);
			self.DisEditor(1);
			self.reload();
		}
	}


	this.InFormNew = function ()		//����:����һ����¼����ȫ���༭��ʽ��
	{
		var fun = function (data)
		{
			var item = $.jcom.eval(data);
			if (typeof item == "string")
				return alert(item);
			var keyField = getKeyFieldName();
			item[keyField] = "";
			self.insertRow(item);
		};
		inform.getDBRecord(0, {dataReady:fun});
		
	};

	this.InFormDel = function ()		//����:ɾ��һ����¼����ȫ���༭��ʽ��
	{
		var DataID = self.getSelItemKeyValue();
		if (DataID == undefined)
			return alert("����ѡ��һ����¼");
		if (DataID == "")
			self.deleteRow();
		else
			alert("Ϊ��ȫ�����Ŀǰ��֧�ֶ��ѱ����¼��ɾ��");
		
	};
	
	this.ImportExcel = function(option)		//����:ͨ��EXCEL������򣬵����б�
	{
		option = $.jcom.initObjVal({js:"", ImportInfo:"", target:"SaveFormFrame"}, cfg);
		$.get(jsp, {GetFieldInfo: 1}, function (data)
		{
			$.jcom.submit("../com/infile.jsp?SaveFlag=1", {FieldInfo: data, ImportInfo:cfg.ImportInfo, cinc:cfg.js}, 
					{target:cfg.target, File:"LocalName",wincfg:{title:"��Excel�ļ��е�������", width:800, height:600}});
		});
	};

	this.InFormSave = function ()		//����:����༭�������ȫ���༭��ʽ��
	{
		if (editMode == 0)
			return;
		var errors = "";
		var items = self.getData();
		for (var x = 0; x < items.length; x++)
		{
			if (items[x]._Editflag == 1)
			{
				var err = inform.CheckForm(items[x], true);
				for (var y = 0; y < err.length; y ++)
				{
					errors += err[y].err;
					var v = items[x][err[y].field];
					if (typeof v == "object")
						v.color = "red";
					else
						v = {value: v, color:"red"};
					self.setCell(x, err[y].field, v);
				}
			}
		}
		if (errors != "")
			return alert("���ܱ��棬�����´�����Ҫ������\n\n" + errors);
		var keyField = getKeyFieldName();
		var text = "", cnt = 0;
		for (var x = 0; x < items.length; x++)
		{
			if (items[x]._Editflag == 1)
			{
				for (var key in items[x])
				{
					if (key == "_Editflag")
						continue;
					if (key.lastIndexOf("_ex") == key.length - 3)
						continue;
					var value = items[x][key];
					if (typeof value == "object")
						value = items[x][key].value;
					if (key == keyField)
					{
						key = "LineDataID";
						if (cnt == 0)
							text += "<input name=I_DataID value=" + value + ">";
					}
					text += "<textarea name=" + key + ">" + value + "</textarea>";	//
				}
				cnt ++;
			}
		}
		if (cnt == 0)
			return alert("����δ�ı�");
		var cfg = inform.getCfg();
		$.jcom.submit(cfg.action + "&Ajax=1&Count=" + cnt, text, {fnReady: InFormSaveOK});
	};
	
	this.onRecordChange = function (nType)		//�¼�:��¼�ı����
	{
		self.ReloadGrid();
	};
	
	function getKeyFieldName()
	{
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].bPrimaryKey == 1)
				return head[x].FieldName;
		}
	}
	
	function InFormSaveOK(result)
	{
		if (result.substr(0,2) != "OK")
			return alert("����ʧ��:" + result);
		var items = self.getData();
		for (var x = 0; x < items.length; x++)
		{
			if (items[x]._Editflag == 1)
				items[x]._Editflag = 0;
		}
			alert("����ɹ�");
	}
	
	function setEditor(fields, record)
	{
		for (var x = 0; x < head.length; x++)
		{ 
			if (head[x].nShowMode = 1)
			{
				var field = inform.getFields(head[x].FieldName);
				if (typeof field == "object")
				{
					if (field.nReadOnly == 0)
					{
						inform.getquote(field, dataOK);
						setOneEditor(field, x);
					}
				}
			}
		}
		self.reload();
	}

	function dataOK(field)
	{
		var headitem = self.getHead(field.EName);
		headitem.DBEditor.setData(field.data);
	}
	
	function setOneEditor(field, index)
	{
		if (index == undefined)
			var headitem = self.getHead(field.EName);
		else
			var headitem = head[index];
		if (typeof headitem.DBEditor != "object")
		{
			if ((field.Quote == "") || (field.data == "~δʵ��~"))
			{
				if (field.FieldType == 4)
					headitem.DBEditor = new $.jcom.DynaEditor.Date(240,280);
				else
				headitem.DBEditor = new $.jcom.DynaEditor.Edit();
			}
			else
				headitem.DBEditor = new $.jcom.DynaEditor.List(field.data, 0, 0, 1);
		}
		self.attachEditor(field.EName, headitem.DBEditor);
	}
	
	this.showFilterPanel = function ()		//����:��ʾ����������δʵ��
	{
	};
	
	this.config = function (c) //����:��ȡ����������
	{
		cfg = $.jcom.initObjVal(cfg, c);
		return cfg;
	};
	
	self.init(jsp, seekcfg);
};

$.jcom.ComplexSeekPanel = function (domobj, head, table)	//��:���ϲ�ѯ��
{//������ͼ�ĸ��ϲ�ѯ����ԭ�����������ɵĴ���ĳɿͻ�������
	var self = this;
	var grid, form;
	var listEditor, timeEditor, lastEditor;
	function init()
	{
		if (domobj == undefined)
			return;
		var op = "";
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].bSeek == 1)
				op += "<option value=" + head[x].FieldName + " node=" + x + ">" + head[x].TitleName + "</option>";
		}
		if (op == "")
		{
			for (var x = 0; x < head.length; x++)
			{
				if ((head[x].nShowMode != 4) && (head[x].nShowMode != 6) && (head[x].nShowMode != 7) && (head[x].FieldType != 0))
					op += "<option value=" + head[x].FieldName + " node=" + x + ">" + head[x].TitleName + "</option>";
			}
		}
		var tag = "<table id=FilterTable cellpadding=0 cellspacing=0 border=0>" + 
			"<tr bgcolor=white><td width=150>�ֶ�</td><td width=40>����</td><TD width=100>����</td><td width=40>����</td>" + 
			"<td bgcolor=white rowspan=2>&nbsp;<input id=InsertConditionButton type=button value=����></td></tr>" +
			"<tr height=25px bgcolor=white><td><select id=FieldsSel style=width:150px;>" + op +
			"</select></td><td><select id=ChoiceSel><option value=1>����</option><option value=2>������</option>" + 
			"<option value=3>����</option><option value=4>С��</option><option value=5>���ڵ���</option>" + 
			"<option value=6>С�ڵ���</option><option value=7>�����</option><option value=8>�Ұ���</option>" + 
			"<option value=9>ȫ����</option></select></td><Td bgcolor=white>" + 
			"<input id=Content type=text FieldType=1 style=width:130px;height:20px;></td>" + 
			"<td><select id=ConnectSel><option value=and>����</option><option value=or>����</option></select></td></tr></table>" +
			"<table><tr><td id=ContentTitleTD colspan=2>�����ӵĲ�ѯ����:</td></tr><tr><td>" + 
			"<div id=SelectedDiv style=\"width:400px;height:190px;overflow-x:hidden;overflow-y:auto;border:1px solid gray\"></div></td><td>" +
			"<input id=DeleteButton type=button disabled value=ɾ��><br><br>" + 
			"<input id=SeekButton type=button value=��ѯ><br><br><br>" + 
			"<input id=ReturnButton type=button value=����><br>" + 
			"<input id=CancelButton type=button value=����></td></tr></table>";
		domobj.innerHTML = tag;
		$("#InsertConditionButton", domobj).on("click", InsertCondition);
		$("#FieldsSel", domobj).on("change", FieldChange);
		$("#Content", domobj).on("keydown", Presskey);
		$("#DeleteButton", domobj).on("click", DeleteCondition);
		$("#SeekButton", domobj).on("click", ConfirmCondition);
		$("#ReturnButton", domobj).on("click", onReturn);
		$("#CancelButton", domobj).on("click", onClose);
		form = new $.jcom.FormBase(0, head);
		var h = [{FieldName:"key", TitleName:"�ֶ�", nWidth:150, nShowMode:1},
		    		{FieldName:"eq", TitleName:"����", nWidth:40, nShowMode:1},
		    		{FieldName:"value", TitleName:"����", nWidth:140, nShowMode:1},
		    		{FieldName:"connect", TitleName:"����", nWidth:40, nShowMode:1}];
		grid = new $.jcom.GridView($("#SelectedDiv", domobj)[0], h, [], {}, {headstyle:3, footstyle:4});
		grid.clickRow = GridClickRow;
	}
	
	function GridClickRow(td, e)
	{
		grid.select(td);
		var f = false;
		if (typeof td != "object")
			f = true;
		$("#DeleteButton", domobj).attr("disabled", f);
	}
	
	function Presskey()
	{
	}
	
	function InsertCondition()
	{
		var obj = $("#Content", domobj);
		var value = obj.val();
		if (value == "")
		{
			alert("���ݲ���Ϊ��");
			obj[0].focus();
			return;
		}
		var field = getField();
		if ((field.Quote != "") && (field.Quote != undefined))
			value = obj.attr("node");

		if ((field.FieldType == 3) || ( field.FieldType == 5) || (field.FieldType == 6) || (field.FieldType == 7))
		{
			if (isNaN(parseFloat(value)))
			{
				alert("���ݲ��Ϸ�����������ֵ");
				obj[0].focus();
				return;
			}
		}
		var s = $("#ChoiceSel option:selected", domobj);
		var c = $("#ConnectSel option:selected", domobj);
		var f = field.FieldName;
		if ((typeof table == "string") && (table != ""))
			f = table + "." + f;
		
		var o = {key:field.TitleName, eq:s.text(), value:obj.val(), connect:c.text(), SeekKey:f, SeekValue:value, SeekConnect:c.val(), FieldType:field.FieldType};
		grid.insertRow(o);
		obj.val("");
	}
	
	function getField()
	{
		var sel = $("#FieldsSel", domobj);
		var option = sel[0].options[sel[0].selectedIndex];
		return head[$(option).attr("node")];
	}
	
	function FieldChange()
	{
		var field = getField();
		var o = $("#Content", domobj);
		o.val("");
		if (typeof lastEditor == "object")
		{
			lastEditor.detach(o[0]);
 			lastEditor = undefined;
		}
		if (field.FieldType == 4)
		{
			if (timeEditor == undefined)
				timeEditor = new $.jcom.DynaEditor.Date();
			timeEditor.attach(o[0]);
			lastEditor = timeEditor;
			return;
		}
		if ((field.Quote != "") && (field.Quote != undefined))
		{
			if (listEditor == undefined)
				listEditor = new $.jcom.DynaEditor.List("...", 0,0, 1);
			
			if (form.getquote(field, dataOK))
				dataOK(field);
			listEditor.attach(o[0]);
			lastEditor = listEditor;
		}
	}
	
	function dataOK(field)
	{
		listEditor.setData(field.data);
	}
	
	function DeleteCondition()
	{
		grid.deleteRow();
		$("#DeleteButton", domobj).prop("disabled", true);
	}
	
	function ConfirmCondition()
	{
		var obj = $("#Content", domobj)[0];
		var value = obj.value;
		if (value != "")
			InsertCondition();
		var items = grid.getData();
		if (items.length == 0)
			return alert("�������Ӳ�ѯ����");

		var param = "", item, andor = "";
		for (var x = 0; x < items.length; x++)
		{
			item = GetSeekItem(items[x].SeekKey, items[x].SeekValue, items[x].eq, items[x].FieldType);
			param += andor + item
			andor = " " + items[x].SeekConnect + " ";
		}
		self.onApply(param);
	}
	
	function GetSeekItem(SeekKey, SeekParam, SeekChoice, KeyType)
	{
	var ch;
		if (SeekParam.length > 50)
			SeekParam = SeekParam.substr(0, 50);
		switch (SeekChoice)
		{
		case "����":
			return SeekKey + "=" + GetFieldTypeValue(SeekParam, KeyType)
		case "������":
			return SeekKey + "<>" + GetFieldTypeValue(SeekParam, KeyType)
		case "����":
			return SeekKey + ">" + GetFieldTypeValue(SeekParam, KeyType)
		case "С��":
			return SeekKey + "<" + GetFieldTypeValue(SeekParam, KeyType)
		case "���ڵ���":
			return SeekKey + ">=" + GetFieldTypeValue(SeekParam, KeyType)
		case "С�ڵ���":
			return SeekKey + "<=" + GetFieldTypeValue(SeekParam, KeyType)
		case "�����":
			return SeekKey + " like '" + SeekParam + "*'"
		case "�Ұ���":
			return SeekKey + " like '*" + SeekParam + "'"
		case "ȫ����":
			return SeekKey + " like '*" + SeekParam + "*'"
		default:
			return "true";
		}
	}

	function GetFieldTypeValue(value, KeyType)
	{
		switch (KeyType)
		{
		case 3:					//Integer
		case 5:					//Counter
		case 6:					//Double
		case 7:
			return value;
		case 9:					//Yes/No
			if (value != 0)
				return "true";
			return "false";
		case 4:					//DateTime
			if (value == "")
				return "null";
			return "'" + value + "'";
		default:
			return "'" + value + "'";
		}
	}
	function onReturn()
	{
		self.onReturn();
	}
	
	function onClose()
	{
		self.onClose();
	}
	
	this.onReturn = function ()		//�¼�:���·��ؼ�����
	{
	};
	
	this.onApply = function (filter)		//�¼�:����ȷ�ϼ�����
	{
	};
	
	this.onClose = function()		//�¼�:���¹رռ�����
	{
	};
		
	init();
}

$.jcom.DBTree = function (domobj, jsp, cfg, treecfg)	//��:����������ͼ
{//��ƽ̨��ͼ��ϵ�������ͼ�����ࣺTreeView
	var self = this;
	$.jcom.TreeView.call(this, domobj, [], treecfg, []);
	$.jcom.DBFun.call(this, jsp);
	var head;
	var TableName, TableCName;
	jsp = self.getFormURL(0, jsp);
	cfg = $.jcom.initObjVal({URLParam:"", EditAction:"", ViewAction:"", SeekAction:"", InAction:"", Menubar:"", initflag:true}, cfg);
	var seekcfg = {SeekKey:"", SeekParam:"", OrderField:"", bDesc:"", ParentNode:0, nFormat:0, GetTreeData:2};
	
	function inittree(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
		{
			domobj.innerText = json;
			return;
		}
		head = json.head;
		TableName = json.TableName;
		TableCName = json.TableCName;
		if (cfg.EditAction == "")
			cfg.EditAction = self.getFormURL(jsp, json.EditForm);
		if (cfg.ViewAction == "")
			cfg.ViewAction = self.getFormURL(jsp, json.ViewForm);
		if (cfg.SeekAction == "")
			cfg.SeekAction = self.getFormURL(jsp, json.SeekForm);
		if (cfg.InAction == "")
			cfg.InAction = self.getFormURL(jsp, json.AllEditForm);
		var items = self.PrepareData(json.data, head);
		self.setdata(items, head);
	}
	
	function init()
	{
		self.waiting("���ڼ���...");
		$.get(jsp + cfg.URLParam, seekcfg, inittree);
	}
	
	this.getOption = function (nType)		//����:��ñ�������ͼ�ķ�����URL
	{
		switch (nType)
		{
		case 1:
			return {EditAction:cfg.EditAction};
		case 2:
			return {SeekAction:jsp};
		}
	};
	
	this.reload = function (skcfg)		//����:���¼���
	{
		seekcfg = $.jcom.initObjVal(seekcfg, skcfg);
		init();
	};
	
	this.onRecordChange = function (nType)		//�¼�:��¼�Ѹı�
	{
		init();
	};

	this.config = function (c) //����:�õ�����������
	{
		cfg = $.jcom.initObjVal(cfg, c);
		return cfg;
	};
	
	this.PrepareData = function (items, head)		//�¼�:׼�����ݣ����������ݽ���ת��
	{
		return items;
	};
	
	if (cfg.initflag)
		init();
};

$.jcom.DBCascade = function (domobj, jsp, cfg, seekcfg, cccfg)		//��:���ݼ���ѡ���
{//��ƽ̨��ͼ��ϵļ���ѡ��򣬻��ࣺCascade
	var self = this;
	$.jcom.Cascade.call(this, domobj, [], cccfg);
	$.jcom.DBFun.call(this, jsp);
	var head;
	var TableName, TableCName;
	
	function init(data)
	{
		if (data == undefined)
			return self.refresh(seekcfg);
		
		var json = $.jcom.eval(data);
		if (typeof json == "string")
		{
			domobj.innerText = json;
			return;
		}
		head = json.head;
		TableName = json.TableName;
		TableCName = json.TableCName;
		if (cfg.EditAction == "")
			cfg.EditAction = self.jspfile(json.EditForm);
		if (cfg.ViewAction == "")
			cfg.ViewAction = self.getFormURL(jsp, json.ViewForm);
		var tagName;
		for (var x = 0; x < head.length; x++)
		{
			if ((head[x].nShowMode == 9) || (head[x].bTag == 1))
			{
				tagName = head[x].FieldName;
				break;
			}
		}

		for (var x = 0; x < json.Data.length; x++)
			json.Data[x].item = json.Data[x][tagName];
		var items = self.PrepareData(json.Data);
		if (items === false)
			return;
		self.reload(items);
		self.onReady(items);
	}
	
	this.init = init;
	
	this.PrepareData = function (items, head)		//�¼�:׼�����ݣ����������ݽ���ת��
	{
		return items;
	};
	
	this.onReady = function (items)		//�¼�:������غ����
	{
	};
	
	this.getSelItemKeyValue = function(depth)		//����:�õ�ѡ���������ֵ
	{
		var items = self.getNodeItems();
		if (items == undefined)
			return;
		if (depth == undefined)
			depth = 0;
		if (depth >= items.length)
			return;
		var item = items[depth];
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].bPrimaryKey == 1)
				break;
		}
		return item[head[x].FieldName];		
	};

	this.getOption = function (nType)		//����:�õ���������ͼ��Ӧ�ķ�����URL
	{
		switch (nType)
		{
		case 1:
			return {EditAction:cfg.EditAction};
		case 2:
			return {SeekAction:jsp};
		}
	};

	this.onRecordChange = function (nType)	//�¼�:��¼�ı����
	{
		init();
	};
	
	this.refresh = function(skcfg)		//����:ˢ�¶���
	{
//		self.waiting("���ڼ���...");
		seekcfg = $.jcom.initObjVal({SeekKey:"", SeekParam:"", OrderField:"", bDesc:"", GetGridData:2}, skcfg);
		$.get(jsp + cfg.URLParam, seekcfg, init);
	};

	cfg = $.jcom.initObjVal({URLParam:"", EditAction:"", ViewAction:"", prep:"", initflag: true}, cfg);
	if (cfg.initflag)
		init();
}


$.jcom.DBForm = function (domobj, jsp, cfg, formcfg)	//��:���ݱ�����
{//��ƽ̨��ͼ��ϵı��������ࣺFormView
//domobj:����DOM����
//jsp:ƽ̨���ɵ���ͼ������
//cfg:����ѡ��,��Ա����
// URLParam:""--������ͼʱ��Ҫ���ݵ�URL����--
//DataID:"" --���ݼ�¼������--
//bTitle:0--�Ƿ���ʾ�����ڲ�����--
//formcfg:����FormView������ѡ������в��ݲ�����ƽ̨�����������μ�ƽ̨˵����FormView�Ĺ���ע��
	var self = this;
	var fromdef, record, DataID;
	$.jcom.FormView.call(this, domobj, undefined, {}, formcfg);
	
	function initform(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		formdef = json[0];
		record = json[1];
		DataID = json[2].DataID;
		var t = getTitle(DataID);
		if (json[2].ExcelFormID > 0)
			formcfg = $.jcom.initObjVal(formcfg, {title:formdef.title, spaninput:1, menudef:false, gridformid:json[2].ExcelFormID});
		else
			formcfg = $.jcom.initObjVal(formcfg, {title:formdef.title, action:jsp + "?FormSaveFlag=1&Ajax=1", formtype:formdef.formtype, nCols:formdef.nCols, ex:formdef.ex});
		if (cfg.bTitle == 0)
			formcfg.title = "";
		formdef.fields[formdef.fields.length] = {EName:"I_DataID", InputType:21, nShow:1};
		record.I_DataID = DataID;
		self.PrepareData(formdef.fields, record, formcfg);
		self.reset(formdef.fields, record, formcfg);
//		self.appendHidden("I_DataID", DataID);
		self.onready(formdef.fields, record, t, jsp, cfg, formcfg);
	}
	
	function getTitle(id)
	{
		var title = formdef.title.split(",");
		if (title.length == 0)
			return "";
		var t = title[0];
		if ((id != "0") && (id != "") && (title.length > 1))
			t = title[1];
		return t;
	}
	
	this.PrepareData = function(fields, record, cfg)	//�¼�:׼�����ݣ����������ݽ���ת��
	{};
	
	this.onready = function (fields, record, title, jsp)		//�¼�:������ɺ����
	{};
	
	this.getDBRecord = function(dataID, option)		//����:�õ����ݼ�¼
	{
		option = $.jcom.initObjVal({dataReady:getDBRecordOK, URLParam:cfg.URLParam}, option);
		DataID = dataID;
		cfg.URLParam = option.URLParam;
		$("input[name='I_DataID']", domobj).val(dataID);
		$.get(jsp + cfg.URLParam, {getrecord:1, DataID: dataID}, option.dataReady);
	};
	
	this.DeleteRecord = function(id, hint, fun)		//����:ɾ����¼
	{
		if (hint != false)
		{
			if (typeof hint != "string")
				hint = "��׼��ɾ����¼���Ƿ�ȷ��?";
			if (window.confirm(hint) == false)
				return;
		}
		if (fun == undefined)
		{
			fun = function (result)
			{
				alert(result);
			};
		}
		$.get(jsp, {FormSaveFlag:1, I_DeleteFlag:1, DataID: id}, fun);
	};
	
	function getDBRecordOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		record = json;
		record.I_DataID = DataID;
		self.setRecord(record);
		var t = getTitle(DataID);
		self.onready(formdef.fields, record, t, jsp);
		
	}
	
	this.aftersubmit = function (result)		//�¼�:�ύ�󷵻صĽ�
	{
		if (result.substr(0, 2) == "OK")
			self.onSaveOK(jsp);
		else
			alert(result);
	};
	
	this.onSaveOK = function (jsp)		//�¼�:����ɹ������
	{
		alert("����ɹ�");	
	};
	
	this.DesignForm = function ()		//����:���ñ������
	{
		if (formcfg.gridformid > 0)
			window.open("../com/inform.jsp?DataID=" + formcfg.gridformid);
		else
		{
			var FormName= jsp.replace(/(.*\/)*([^.]+).*/ig,"$2");  //�������ʽ��ȡ�ļ�����������׺
			$.jcom.submit("../com/inform.jsp?ImportExcelFlag=1&FormName=" + FormName, "", {target:"_blank", File:"LocalName",fValid:testExcelFile});	
		}
	};
	
	function testExcelFile(file)
	{
		var pos = file.lastIndexOf(".");
		var ex = file.substr(pos + 1).toLowerCase();
		if (ex == "xls") 
			return true;
		alert("���ϴ�EXCEL�ļ�");
		return false;
	}
	
	function init()
	{
		if (domobj == undefined)
			return;
		cfg = $.jcom.initObjVal({URLParam:"", DataID:"", bTitle:0}, cfg);
		domobj.innerText = "���ڼ���...";
		$.get(jsp + cfg.URLParam, {getflowform:1, DataID:cfg.DataID}, initform);
	}
	init();
};

$.jcom.SlideBox = function (domobj, id, cfg)	//��:����������
{//�޶�������ָ���Ŀ����ڣ�һ���������ͳ��ֺ��������
	if (domobj == undefined)
		return;
	domobj.innerHTML = "<div align=center id=" + id + " style='overflow-x:auto;border:none;'></div>";
};


//�ֻ��ͻ���Ӧ��
var loadCount = 0;
function loadPlus() {
	loadCount ++;
	if (loadCount > 10)
	{
		return;
	}
	if (typeof plus == "undefined")
	{
		setTimeout("loadPlus()", 100);
		return;
	}
	plusFun();

		var info = plus.push.getClientInfo();
		var os=plus.os.name;
		var clientid=info.clientid;
		alert(clientid);
		document.cookie = "clientid=" + clientid + "; path=/";

			// ���������Ϣ�¼�  
			plus.push.addEventListener( "click", function( msg ) {
				var payload=(plus.os.name=='iOS')?msg.payload:JSON.parse(msg.payload);
			}, false );  

			// ����������Ϣ�¼�  
			plus.push.addEventListener( "receive", function( msg ) {  
				logoutPushMsg( msg );  
				//alert(222+msg);
			}, false );  
}


function plusFun() {
	document.addEventListener('plusready', function() {
      var webview = plus.webview.currentWebview();
      plus.key.addEventListener('backbutton', function() {
          webview.canBack(function(e) {
              if(e.canBack && !/main.jsp|studentSys.jsp/.test(location.toString())) {
                  webview.back();             
              } else {
					//alert(plus.os.name)
					if (plus.os.name.toLowerCase() == "android")
					{
						var main = plus.android.runtimeMainActivity();
						main.moveTaskToBack(false);
					}
					/*
					else {
						//webview.close(); //hide,quit
						//plus.runtime.quit();
						//��ҳ���ؼ�����
						//�����߼���1���ڣ��������ΰ����ؼ������˳�Ӧ�ã�
						var first = null;
						plus.key.addEventListener('backbutton', function() {
							//�״ΰ�������ʾ���ٰ�һ���˳�Ӧ�á�
							if (!first) {
								first = new Date().getTime();
								console.log('�ٰ�һ���˳�Ӧ��');
								try
								{
									//parent.mui.toast('�ٰ�һ���˳�Ӧ��');
								}
								catch (e)
								{
									//alert(e);
								}
								setTimeout(function() {
									first = null;
								}, 2000);
							} else {
								if (new Date().getTime() - first < 2500) {
									plus.runtime.quit();
								}
							}
						}, false);
					}
					*/
              }
          })
      });
  });
}

loadPlus();



//��ȡ��͸����  
function logoutPushMsg( msg ) {  
  if ( msg.payload ) {  
      if ( typeof(msg.payload)=="string" ) {  
          createLocalPushMsg(msg.content);  
      } else {  
          var data = JSON.parse(msg.payload);  
          createLocalPushMsg(data.content);  
      }  
  } else {  
      console.log( "payload: undefined" );  
  }  
}  

//������������  
function createLocalPushMsg(content){  

  var options = {cover:false};  
  plus.push.createMessage(content, "LocalMSG", options );  
  if(plus.os.name=="iOS"){  
      alert('*����޷�������Ϣ���뵽"����"->"֪ͨ"������Ӧ����֪ͨ������ʾ!');  
  }  

} 