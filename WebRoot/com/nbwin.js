function NBWindow(title, oFeatures, titleObj, nStyle)
{
	var posMode, posx, posy, nDockMode, bDocking, nDocking;
	var minWidth = 216, minHeight = 82, dockEnable = 0, ModalDialog = 0; 
	var resizable = external.resizable;
	var topmost = external.TopMost;
	var oframe, self = this;
	this.close = function ()
	{
		external.close();
		event.cancelBubble=true;
	};
	
	this.Maximize = function ()
	{
		if (external.Maximized)
		{
			//document.all.NBWinMaxbox.src = "netbox:/pic/max.gif"
			external.Maximized = false;
		}
		else
		{
			//document.all.NBWinMaxbox.src = "netbox:/pic/max1.gif"
			external.Maximized = true;
			external.moveWindow(0, 0, screen.availWidth, screen.availHeight);
		}
	};
	
	this.Minimize = function ()
	{
		external.Minimized = true;
	}
	
	this.Resize = function (w, h)
	{
		if (w > screen.availWidth)
		{
			w = screen.availWidth;
			external.scrollbar = true;
		}
		if (external.Left + w > screen.availWidth)
			external.Left = screen.availWidth - w;
		if (h > screen.availHeight)
		{
			h = screen.availHeight;
			external.scrollbar = true;
		}
			
		if (external.Top + h > screen.availHeight)
			external.Top = screen.availHeight - h;
		external.ResizeTo(w, h);
	}

	this.SetCaption = function(title)
	{
		document.all.TitleTextObj.innerHTML = title+(ModalDialog?"\u2014\u5bf9\u8bdd\u6846":"");
	};

	this.SetCaptionImg = function(img)
	{
		if ((typeof img != "string") || (img == "")){
			var capImgx=document.all.CaptionImg
			capImgx.style.display = "none";
			//==这里由于logo图标消失了导致旁边的文字上下对齐高度受影响,估要减少3px调整
			capImgx.nextSibling.style.paddingTop=(parseInt(capImgx.nextSibling.style.paddingTop.replace("px",""))-3)+"px";
		}
		else 
		{
			document.all.CaptionImg.style.display = "inline";
			document.all.CaptionImg.src = img;
		}
	};

	this.setMinSize = function(w, h)
	{
		minWidth = w;
		minHeight = h;
	};

	function resizeframe()
	{
		oframe.style.height = document.body.clientHeight - 34;
		var o = oframe.contentWindow.document.body;
		if (o == null)
			return;
		var scroll = "no";
		if (o.clientHeight + 10 < o.scrollHeight)
			scroll = "yes";
		if (o.clientWidth + 10 < o.scrollWidth)
			scroll = "yes";
		o.scroll = scroll;
	}

	function InitNBWin()
	{
		if (typeof(oFeatures) == "object")
		{
			if (typeof(oFeatures.minWidth) != "undefined")
				minWidth = oFeatures.minWidth;
			if (typeof(oFeatures.minHeight) != "undefined")
				minHeight = oFeatures.minHeight;
			if (typeof(oFeatures.minWidth) != "undefined")
				dockEnable = oFeatures.dockEnable;
			if (typeof(oFeatures.resizable) != "undefined")
				resizable = oFeatures.resizable;
			if (typeof(oFeatures.ModalDialog) != "undefined")
				ModalDialog = oFeatures.ModalDialog;
			oframe = oFeatures.oFrame;
			if (typeof oframe == "object")
			{
				window.onresize = resizeframe;
				resizeframe();
			}
		}
		var tag;
		switch (nStyle)
		{
		case 1:		//EUT QQ
		case 2:		//EUT WIN
		 	tag = "<table border=0 cellpadding=0 id=\"NBWinTopedge\" style=\"width:100%;height:32px;border-collapse:collapse;\">" +
				"<tr><td style=\"background:url('netbox:/pic/back_04.gif');\">" +
				"<div id=\"NBWinTitlebar\" nowrap style=\"width:100%;height:100%;padding:4px;overflow:hidden;background:url(netbox:/pic/back_03.gif) no-repeat; left bottom\">" +
				"<img id=CaptionImg src='images/client/top/logo.jpg' onerror=\"this.src='../images/client/top/logo.jpg'\"/>" +
				"<span id=TitleTextObj style='color:#EB880E;padding-left:8px;font:normal normal bolder 12px 微软雅黑;height:100%;padding-top:7px;overflow:hidden;cursor:default;'>" + title+(ModalDialog?"\u2014\u5bf9\u8bdd\u6846":"") + "</span></div></td>";
			tag += "<td style=\"width:28px;background-image:url('netbox:/pic/back_05.gif');";
			tag += "background-position:right bottom;background-repeat:no-repeat;cursor:default;\">&nbsp;";
			tag += "<div nowrap style='height:19px;overflow:hidden;margin:0px;padding:0px;position:absolute;top:1px;right:1px;'>";
			if (resizable){
				tag += "<span id=NBWinMinbox ><img title='\u6700\u5c0f\u5316' src=\"netbox:/pic/top/top_03.gif\" onmousedown=\"this.src='netbox:/pic/top/top_09.gif';event.cancelBubble=true;\" onmouseover=\"this.src='netbox:/pic/top/top_06.gif';\" onmouseout=\"this.src='netbox:/pic/top/top_03.gif';\"></span>" +
					"<span id=NBWinMaxbox><img title='\u6700\u5927\u5316' onmousedown=\"this.src='netbox:/pic/top/top_10.gif';event.cancelBubble=true;\" onmouseover=\"this.src='netbox:/pic/top/top_07.gif';\" onmouseout=\"this.src='netbox:/pic/top/top_04.gif';\" src=\"netbox:/pic/top/top_04.gif\"></span>";
			}
			tag += "<span id=NBWinClosebox><img title='\u5173\u95ed' onmousedown=\"this.src='netbox:/pic/top/top_11.gif';event.cancelBubble=true;\" src=\"netbox:/pic/top/top_05.gif\" onmouseover=\"this.src='netbox:/pic/top/top_08.gif';\" onmouseout=\"this.src='netbox:/pic/top/top_05.gif';\"></span>";
			tag += "</div>";
			tag += "</td></tr></table>";
			break;
		default:			//JNET
			tag = "<table id=NBWinTopedge width=100% height=7 align=center cellspacing=0 cellpadding=0>" +
				"<tr><td width=7><img src=netbox:/pic/JMLT.gif></td>" +
				"<td width=100% style='background:#70716C url(netbox:/pic/JMT.gif) repeat-x top left'></td>" +
				"<td align=right width=7><img src=netbox:/pic/JMRT.gif></td></tr></table>" +
				"<table id=NBWinTitlebar UNSELECTABLE=on width=100% style=cursor:default;background:#70716C;>" +
				"<tr><td width=20px><img id=CaptionImg src=netbox:/pic/jofo16.gif></td>" +
				"<td><B id=TitleTextObj style=color:white;font-size:9pt>" + title + "</B></td><td align=right>";
			if (resizable)
				tag += "<img id=NBWinMinbox src=netbox:/pic/min.gif style=cursor:hand;>&nbsp;" +
					"<img id=NBWinMaxbox src=netbox:/pic/max.gif style=cursor:hand;>&nbsp;";
			tag += "<img id=NBWinClosebox src=netbox:/pic/close.gif style=cursor:hand;>&nbsp;" +
				"</td></tr></table>";
		break;
		}
		if (typeof(titleObj) != "object")
			document.body.insertAdjacentHTML("afterBegin", tag);
		else	
			titleObj.outerHTML = tag;

		//==operate PNG
		if (document.all&&!window.XMLHttpRequest) {
			correctPNG();
			alphaBackgrounds();
		}

		var rect = {l:external.Left, t:external.Top, w: external.Width, h: external.Height};
		//==eut全局标志win样式拉伸拖拽方式使用，jnet保持不变===lxt 2012.1.6
		window.isWinStyleDragx=(nStyle==1||nStyle==2)?true:false;
		if(!window.isWinStyleDragx) //==这个调用会影响下面window样式的拖拽实现
			external.SetMaxTrackSize(400, 400); 
		//============================
	//	external.Visible = false;
		switch (nStyle)
		{
		case 1:
			external.SetTransparentMask("netbox:/pic/EUTMask.gif", 20, 20, 40, 40);
			break;
		case 2:
			external.SetTransparentMask("netbox:/pic/EUTMainMask.gif", 20, 20, 60, 60);
		break;
		default:
			external.SetTransparentMask("netbox:/pic/JNetMask.gif", 20, 20, 60, 60);
			break;
		}
		external.Left = rect.l;
		external.Top = rect.t;
		external.Width = rect.w;
		external.Height = rect.h;
//		external.moveWindow(rect.l, rect.t, rect.w, rect.h);
		if (ModalDialog != 1)
			external.Visible = true;
		else{ 
			//==防止在失去焦点后消失及保持父窗口之上 lxt 2012.1.10
			external.topMost=external.browser.getProperty("HTMLWinParent").external.topMost;
		}
		/*=========实现window样式的拉伸拖拽 lxt 2012.1.5==============*/
		if(window.isWinStyleDragx){
			document.all.NBWinTopedge.onmousedown=function(){
				var dirct=ChangeCursor();
				if(dirct>0) return;
				event.cancelBubble=true;
				if (external.Maximized) return;
				//external.resizable=true;
				//==这里timeout让窗口的windows样式虚框是粗线而不是细线效果
				//setTimeout("external.border=false;", 1);
				external.drag(0);
			};
			document.body.onmousedown = function(){
				var dirct=ChangeCursor();
				if(dirct>0){
					//external.resizable=true;
					//setTimeout("external.border=false;", 1);
					external.drag(dirct);
				}
			};
		}else{
			document.body.onmousedown = DragWin;
		}
		/*=============================*/
		document.body.onmousemove = ChangeCursor;
		document.body.onmouseout = OutWin;
		document.body.onmouseover = InWin;
	
		if (resizable)
		{
			document.all.NBWinTopedge.ondblclick = self.Maximize;
			document.all.NBWinMaxbox.onclick = self.Maximize;
			document.all.NBWinMinbox.onclick = self.Minimize;
			if (nStyle != 1 && nStyle != 2)
			{//jnet
				document.all.NBWinMinbox.onmouseover = OverButton;
				document.all.NBWinMinbox.onmouseout = OutButton;
				document.all.NBWinMaxbox.onmouseover = OverButton;
				document.all.NBWinMaxbox.onmouseout = OutButton;
			}
		}
		document.all.NBWinClosebox.onclick = self.close;
		if (nStyle !=1 && nStyle != 2)
		{//jnet
			document.all.NBWinClosebox.onmouseover = OverCloseButton;
			document.all.NBWinClosebox.onmouseout = OutButton;
		}
	}
	
	function OverCloseButton()
	{
		var obj = event.srcElement;
		if (obj.tagName != "SPAN")
			obj = obj.parentNode;
		obj.style.background = "url(netbox:/pic/top/gb.png) no-repeat left top";
	}

	function OverButton()
	{
		var obj = event.srcElement;
		if (obj.tagName != "SPAN")
			obj = obj.parentNode;
		obj.style.background = "url(netbox:/pic/top/bg.png) no-repeat left top";
	}
	
	function OutButton()
	{
		var obj = event.srcElement;
		if (obj.tagName != "SPAN")
			obj = obj.parentNode;
		obj.style.background = "";
	}

	function DragWin()
	{
		if (event.srcElement.onclick != null)
			return;
		if (external.Maximized)
			return;
		PopMenuItem();
		posMode = ChangeCursor();
		if (posMode == 0)
		{	
			posx = event.screenX - external.Left;
			posy = event.screenY - external.Top;
			nDockMode = 0;
			bDocking = 1;
			if (event.y > 30)
				return;
		}
		document.body.onmousemove = Draging;
		document.body.setCapture();
		document.body.onmouseup = function ()
		{
			document.body.releaseCapture();
			document.body.onmousemove = ChangeCursor;
			bDocking = 0;
			document.body.onmouseup = null;
			if (nDockMode > 0)
				external.TopMost = true;
			else
				external.TopMost = topmost;
		}
	}
	
	function Draging()
	{
	var x;
		if (event.button == 0)
			return document.body.fireEvent("onmouseup");
		if (posMode == 0)
		{
			nDockMode = 0;
			if (dockEnable)
			{
				if (event.screenY == 0)
				{
					nDockMode = 2;
					posy = 0;
				}
				if (event.screenY == screen.height - 1)
				{
					nDockMode = 4;
					posy = external.Height - 1;
				}
				if (event.screenX == 0)
				{
					nDockMode = 1;
					posx = 0;
				}
				if (event.screenX == screen.width - 1)
				{
					nDockMode = 3;
					posx = external.Width - 1;
				}
			}
			external.moveTo(event.screenX - posx, event.screenY - posy);
			return;
		}
		if ((posMode == 1) || (posMode == 4) ||(posMode == 7))
		{
			x = external.Width + external.Left - event.screenX;
			if (x > minWidth)
			{
				external.Width = x;
				external.Left = event.screenX;
			}
		}
		if ((posMode == 2) || (posMode == 5) ||(posMode == 8))
		{
			x = event.screenX - external.Left;
			if (x > minWidth)
				external.Width = x;
		}
		if ((posMode == 3) || (posMode == 4) ||(posMode == 5))
		{
			x = external.Height + external.Top - event.screenY;
			if (x > minHeight)
			{
				external.Height = x;
				external.Top = event.screenY;
			}
		}
		if ((posMode == 6) || (posMode == 7) ||(posMode == 8))
		{
			x = event.screenY - external.Top;
			if (x > minHeight)
				external.Height = x;
		}
	}
	
	function OutWin()
	{
		if ((event.screenX > external.Left) && (event.screenX < external.Left + external.Width)
			&& (event.screenY > external.Top) && (event.screenY < external.Top + external.Height))
			return;
		if(window.isWinStyleDragx){//==win样式时才用 lxt 2011.1.6
			nDockMode = 0;
			bDocking=0;
			if (dockEnable)
			{
				if (external.top <2)//==top hidden
					nDockMode = 2;
				if (external.left== 0)//==left hidden
					nDockMode = 1;
				if (external.left == screen.width - 1)//==right hidden
					nDockMode = 3;
			}
		}
		if ((document.body.onmouseup == null) && (nDockMode > 0) && (bDocking == 0))
		{
			bDocking = 1;
			DockWin(nDockMode);
		}
	}
	
	function InWin()
	{
		if(window.isWinStyleDragx){//==win样式时才用 lxt 2011.1.6
			if (nDockMode>0&&0<external.left&&external.left<screen.width - 1&&external.top >1){
					nDockMode = 0;
					return;
			}
		}
		if ((document.body.onmouseup == null) && (nDockMode > 0) && (bDocking == 0))
		{
			bDocking = 1;
			DockWin(nDockMode + 4);
		}
	}
	
	function DockWin(nDock)
	{
		var d = 32;
		var t = 10;
		if (typeof nDock != "undefined")
			nDocking = nDock;
		switch (nDocking)
		{
		case 1:		//Left
			if (external.Left + external.Width - d > 2)
			{
				external.Left -= d;
				setTimeout(DockWin, t);
			}
			else
			{
				external.Left = 2 - external.Width;
				bDocking = 0;
			}
			break;
		case 2:		//Top
			if (external.Top + external.Height - d > 2)
			{
				external.Top -= d;
				setTimeout(DockWin, t);
			}
			else
			{
				external.Top = 2 - external.Height;
				bDocking = 0;
			}
			break;
		case 3:		//Right
			if (external.Left + d < screen.width - 2)
			{
				external.Left += d;
				setTimeout(DockWin, t);
			}
			else
			{
				external.Left = screen.width - 2;
				bDocking = 0;
			}
			break;
		case 4:		//Bottom
			if (external.Top + d < screen.height - 2)
			{
				external.Top += d;
				setTimeout(DockWin, t);
			}
			else
			{
				external.Top = screen.height - 2;
				bDocking = 0;
			}
			break;
		case 5:
			if (external.Left + d < 0)
			{
				external.Left += d;
				setTimeout(DockWin, t);
			}
			else
			{
				external.Left = -1;
				bDocking = 0;
			}
			break;
		case 6:
			if (external.Top + d < 0)
			{
				external.Top += d;
				setTimeout(DockWin, t);
			}
			else
			{
				external.Top = -1;
				bDocking = 0;
			}
			break;
			break;
		case 7:
			if (external.Left + external.Width - d > screen.width)
			{
				external.Left -= d;
				setTimeout(DockWin, t);
			}
			else
			{
				external.Left = screen.width - external.Width;
				bDocking = 0;
			}
			break;
		case 8:
			if (external.Top + external.Height - d > screen.height)
			{
				external.Top -= d;
				setTimeout(DockWin, t);
			}
			else
			{
				external.Top = screen.height - external.Height;
				bDocking = 0;
			}
			break;
		}
	}
	
	function ChangeCursor()
	{
		if (resizable == false)
		{
			document.body.style.cursor = "auto";
			return 0;
		}
		
		if ((event.clientX < 8) && (event.clientY < 4))//==<8的话太大的了 lxt 2011.12.28
		{
			document.body.style.cursor = "NW-resize";
			return 4;
		}
	
	
		if ((event.clientX > document.body.clientWidth - 8) && (event.clientY < 4))
		{
			document.body.style.cursor = "NE-resize";
			return 5;
		}

		if (event.clientY < 4)
		{
			document.body.style.cursor = "N-resize";
			return 3;
		}

		if ((event.clientX > document.body.clientWidth - 8) && (event.clientY > document.body.clientHeight - 8))
		{
			document.body.style.cursor = "SE-resize";
			return 8;
		}
	
		if ((event.clientX < 8) && (event.clientY > document.body.clientHeight - 8))
		{
			document.body.style.cursor = "SW-resize";
			return 7;
		}
	
		if (event.clientX < 8)
		{
			document.body.style.cursor = "W-resize";
			return 1;
		}
	
		if (event.clientY > document.body.clientHeight - 8)
		{
			document.body.style.cursor = "S-resize";
			return 6;
		}
	
		if (event.clientX > document.body.clientWidth - 8)
		{
			document.body.style.cursor = "E-resize";
			return 2;
		}
	
		document.body.style.cursor = "auto";
		return 0;
	}	
	
	document.onfocusin = function()
	{
		if (external.Maximized)
			external.moveWindow(0, 0, screen.availWidth, screen.availHeight);
//		InWin();
	//	document.all.TitleTextObj.style.color = "white";
	}
	
	
	document.onfocusout = function()
	{
//		OutWin();
	//	document.all.TitleTextObj.style.color = "black";
	}
	
	window.onblur = function()
	{
	//	document.all.TitleTextObj.style.color = "black";
	//	document.all.TitleTextObj.innerText = new Date().getTime();
	}
	
	document.body.onactivate = function()
	{
		InWin();
	//	document.all.TitleTextObj.style.color = "white";
	//	document.all.TitleTextObj.innerText = new Date().getTime();
	}
	InitNBWin();
}

//用NB HTMLWindow实现的系统右键菜单类
//用法:	var sysmenu = new NBMenu([{item:"菜单项", img:"pic.gif", action:"alert()"},{item:""},{item:"子菜单,child:[...]}]);
//		sysmenu.show();
function NBMenu(menudef)
{
	var wnd;
	function NBMenuWindow(x1, y1, x2, y2)
	{
		var rootWin;
		var subMenu;
		var menudef = external.Argument;
		var oMenuDiv, oRoll;
		var oTimeout = null;
		function InitMenu()
		{
			setTimeout(checkFocus, 500);
			rootWin = external.Browser.GetProperty("HTMLWinParent");
			if (typeof(menudef) != "object")
				return external.Close();
			var tag = "";
			for (var x = 0; x < menudef.length; x++)
			{
				if (menudef[x].item == "")
					tag += "<tr height=8px><td bgcolor=#e8edf0 colspan=3></td><td colspan=3 style='padding:4px 4px 0px 2px;'><div style='overflow:hidden;width:100%;height:3px;border-top:1px solid #e8edf0'></div></td><td></td></tr>";
				else
				{
					tag += "<tr height=24px action='" + menudef[x].action + "'><td bgcolor=#e8edf0></td><td bgcolor=#e8edf0></td>"
					if ((typeof menudef[x].img == "string") && (menudef[x].img != ""))
						tag += "<td bgcolor=#e8edf0 align=center><img src=" + menudef[x].img + "></td>";
					else
						tag += "<td bgcolor=#e8edf0></td>";
					tag += "<td nowrap style=font-size:9pt;padding-left:10px>" + menudef[x].item + "</td>";
					if (typeof menudef[x].child == "object")
						tag += "<td align=right node=" + x + " style='font:normal normal normal 14px webdings'>4</td>";
					else
						tag += "<td></td>";
					tag += "<td></td><td></td></tr>";
				}
			}
			tag = "<table id=MenuTable cellpadding=0 cellspacing=0 border=0 width=120px style='border:1px solid gray;cursor:default'>" +
				"<tr height=3px><td bgcolor=#e8edf0><div style=width:2px;height:3px;overflow:hidden;></div></td>" +
				"<td bgcolor=#e8edf0><div style=width:3px;height:3px;overflow:hidden;></div></td>" + 
				"<td bgcolor=#e8edf0><div style=width:30px;height:3px;overflow:hidden;></div></td><td></td>" +
				"<td><div style=width:32px;height:3px;overflow:hidden;></div></td>" +
				"<td><div style=width:3px;height:3px;overflow:hidden;></div></td>" +
				"<td><div style=width:2px;height:3px;overflow:hidden;></div></td></tr>" + tag +
				"<tr height=3px><td bgcolor=#e8edf0></td><td bgcolor=#e8edf0></td><td bgcolor=#e8edf0></td>" +
				"<td></td><td></td></tr></table>";
			oMenuDiv = document.createElement("DIV");
			document.body.insertBefore(oMenuDiv);
			oMenuDiv.innerHTML = tag;
	 		oMenuDiv.onmousemove = RollMenu;
	 		oMenuDiv.onmouseout = RollMenu;
	 		oMenuDiv.onclick = ActionMenu;

			var left = x2, top = y1;
			if (y1 + document.all.MenuTable.clientHeight + 2 >= window.screen.height)
				top = y2 - document.all.MenuTable.clientHeight - 2;
			if (x2 + document.all.MenuTable.clientHeight + 2 >= window.screen.width)
				left = x1 - document.all.MenuTable.clientWidth - 2
			if (top < 0)
				top = 0;
			if (left < 0)
				left = 0;
			external.moveWindow(left, top, document.all.MenuTable.clientWidth + 2, document.all.MenuTable.clientHeight + 2);
			
			external.DropShadow = true;
		}
	
		function RollMenu()
		{
			var oTR = rootWin.FindParentObject(event.srcElement, oMenuDiv, "TR");
			if (oTR == oRoll)
				return;
			if (typeof oRoll == "object")
			{
				oRoll.cells[1].style.background = "#e8edf0";
				oRoll.cells[2].style.background = "#e8edf0";
				oRoll.cells[3].style.background = "";
				oRoll.cells[4].style.background = "";
				oRoll.cells[5].style.background = "";
				oRoll.style.color = "black";
				if (oTimeout != null)
				{
					window.clearTimeout(oTimeout);
					oTimeout = null;
				}
				if (typeof subMenu == "object")
				{
					subMenu.hide();
					external.focus();
					subMenu = 0;
				}
			}
			oRoll = 0;	
			if ((typeof(oTR) == "object") && (oTR.height > 10))
			{
				oTR.cells[1].style.background = "url(com/pic/menusel1.png) repeat-x top left";
				oTR.cells[2].style.background = "url(com/pic/menusel2.png) repeat-x top left";
				oTR.cells[3].style.background = "url(com/pic/menusel2.png) repeat-x top left";
				oTR.cells[4].style.background = "url(com/pic/menusel2.png) repeat-x top left";
				oTR.cells[5].style.background = "url(com/pic/menusel3.png) repeat-x top left";
				oTR.style.color = "white";
				if (typeof oTR.cells[4].node != "undefined")
					oTimeout = window.setTimeout(ShowSubMenu, 500);
				oRoll = oTR;
			}	
		}
	
		function ShowSubMenu()
		{
			var index = oRoll.cells[4].node;
			if (typeof index == "undefined")
				return;
			if (typeof menudef[index].child == "object")
			{
				var pos = rootWin.GetObjPos(oRoll);
				subMenu = new rootWin.NBMenu(menudef);
//				subMenu = new rootWin.NBMenu(menudef[index].child);
				subMenu.show(window.screenLeft + pos.left, window.screenTop + pos.top, window.screenLeft + pos.right, window.screenTop + pos.bottom);
			}
		}
	
		function ActionMenu()
		{
			if (typeof oRoll == "object")
			{
				eval("rootWin." + oRoll.action);
				external.Close();
			}
		}
	
		function checkFocus()
		{
			if(external.isActived() == false)
			{
				if (oTimeout != null)
				{
					window.clearTimeout(oTimeout);
					oTimeout = null;
				}
				if (typeof subMenu != "object")
					external.Close();
				if (subMenu.isShow())
					external.Close();			
			}
			setTimeout(checkFocus, 500);
		}
		InitMenu();
 	}

	this.show = function (x1, y1, x2, y2)
	{
		if (typeof x1 == "undefined")
		{
			x1 = event.screenX;
			y1 = event.screenY;
		}
		if (typeof x2 == "undefined")
		{
			x2 = x1;
			y2 = y1;
		}
		
		wnd = NewNBWin("about:blank", "scrollbar=0,Caption=0,ToolWindow=1,border=0,TopMost=1,DropShadow=1,Width=2,Height=2,Left=" +
			x1 + ",Top=" + y1, "_blank", menudef);
		wnd.Browser.Document.write("<html><head><title>系统菜单</title></head><body topmargin=0 leftmargin=0></body>" +
			"<script language=javascript>\n" + NBMenuWindow + "\nw = new NBMenuWindow(" + x1 + "," + y1 + "," + x2 + "," + y2 + ");\n" +
			"\n</script></html>");
		wnd.Browser.Document.close();
		return wnd;
	};
	
	this.hide = function ()
	{
		if (this.isShow() == false)
			wnd.Close();
	};
	
	this.isShow = function()
	{
		if (typeof wnd == "object")
			return wnd.isClosed();
		return true;
	
	};
}

function NBLog(str)
{
	var Shell = new ActiveXObject("Shell");
	Shell.Console.WriteLine(str);
}