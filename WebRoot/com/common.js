/**不弹窗上传文件。
*var autoSltFile = new AutoSelectFile();
*autoSltFile.frameName = "submit1";
*autoSltFile.uploadInfo = {filepath:"/thinkmanager/mib",loadtype:"mib", selectFileAfter:function};
*autoSltFile.init();

autoSltFile.selectFile()
*/
  
function AutoSelectFile()
{
	this.frameName = "";
	this.className = "";
	this.uploadInfo = null;
	this.fileName0 = "";
	this.waitImageStatus = "";
}
//var autoSltFile;
AutoSelectFile.start = function (frameName, up_info)
{
	if (typeof window.autoSltFile == "undefined")
	{
		window.autoSltFile = new AutoSelectFile();
	}
	autoSltFile.frameName = frameName;
	autoSltFile.uploadInfo = up_info;
	if (autoSltFile.init())
		autoSltFile.selectFile();
	return autoSltFile;
}

AutoSelectFile.prototype.init = function ()
{
	
	if (this.className == "")
	{
		this.className = "autoSltFile";
	}
	if (this.frameName == "")
	{
		alert("错误，不能实例化AutoSelectFile，没有隐含frame.");
		return false;
	}
	if (this.uploadInfo == undefined)
	{
		alert("错误，不能实例化AutoSelectFile.");
		return false;
	}
	
	if (this.uploadInfo.direct == undefined)
	{
		this.uploadInfo.direct = "";
	}
	if (this.uploadInfo.filepath == undefined)
	{
		this.uploadInfo.filepath = "";
	}
	if (this.uploadInfo.rename == undefined)
	{
		this.uploadInfo.rename = "";
	}
	if (this.uploadInfo.formname == undefined)
	{
		this.uploadInfo.formname = "";
	}
	if (this.uploadInfo.script == undefined)
	{
		this.uploadInfo.script = "";
	}
	else
	{
		this.uploadInfo.script = this.uploadInfo.script.replace(/\+/g, "%2b");
	}
	if (this.uploadInfo.referrer == undefined)
	{
		this.uploadInfo.referrer = "";
	}
	if (this.uploadInfo.ParentName != undefined)
	{
		this.uploadInfo.saveto = this.uploadInfo.ParentName;
	}
	if (this.uploadInfo.saveto == undefined)
	{
		this.uploadInfo.saveto = "";
	}
	if (this.uploadInfo.loadtype == undefined)
	{
		if (this.uploadInfo.saveto == "")
		{
			alert("错误，不能实例化AutoSelectFile,没有文件类型.");
			return false;
		}
		else
			this.uploadInfo.loadtype = "";
	}
	if (this.uploadInfo.plusStr == undefined)
	{
		this.uploadInfo.plusStr = "";
	}
	if (this.uploadInfo.instanceName == undefined)
	{
		this.uploadInfo.instanceName = "autoSltFile";		//实例名称，上传后要为fileName0赋值
	}
	if (this.uploadInfo.isMore == undefined)
	{
		this.uploadInfo.isMore = "";		//实例名称，上传后要为fileName0赋值
	}
	if (this.fileName0 == "" && this.uploadInfo.deleteFile != undefined)	//只在第一次接受页面传过来的参数
	{
		this.fileName0 = this.uploadInfo.deleteFile;		//实例名称，上传后要为fileName0赋值
	}
	if (this.uploadInfo.selectFileAfter == undefined)
	{
		this.uploadInfo.selectFileAfter = null;
	}
	if (this.uploadInfo.forward == undefined)
	{
		this.uploadInfo.forward = "";
	}
	return true;
}

AutoSelectFile.prototype.selectFile = function()
{
	var url = "";
	if (this.uploadInfo.saveto == "")
	{
		url = psubdir + "uploadform.jsp?direct=" + this.uploadInfo.direct + "&filepath=" + this.uploadInfo.filepath + 
			"&formname=" + this.uploadInfo.formname + "&loadtype=" + this.uploadInfo.loadtype +
			"&script=" + this.uploadInfo.script + "&rename=" + this.uploadInfo.rename +
			"&referrer=" + this.uploadInfo.referrer  + "&plusStr=" + this.uploadInfo.plusStr  
			+ "&instanceName=" + this.uploadInfo.instanceName+ "&isMore=" + this.uploadInfo.isMore + "&forward=" + this.uploadInfo.forward;
	}
	else
	{
		url = psubdir + "uploadform.jsp?direct=" + this.uploadInfo.direct + "&formname=" + this.uploadInfo.formname
			+ "&script=" + this.uploadInfo.script + "&saveto=" + this.uploadInfo.saveto  + "&plusStr=" + this.uploadInfo.plusStr  
			+ "&instanceName=" + this.uploadInfo.instanceName + "&isMore=" + this.uploadInfo.isMore
			+ "&loadtype=" + this.uploadInfo.loadtype + "&forward=" + this.uploadInfo.forward;
	}
	document.getElementsByName(this.frameName)[0].src = url;		//载入表单
	
	// 解决IE外的浏览器在，单点浏览文件时还会阻塞代码引发的问题 lxt 2014.05.13
	window.clearTimeout(window.g_timerForIsClickingFileInpt);
	window.g_timerForIsClickingFileInpt=0;
	window.g_isClickingFileInptTimes=0;
	
	window.setTimeout(this.className + ".waitingSubmitFile()", 500);	//检查载入完成，出现载入框
}

AutoSelectFile.prototype.waitingSubmitFile = function()
{
	var upload;
	upload = document.getElementsByName(this.frameName)[0].contentWindow;
	if (this.waitImageStatus == ""&&!window.g_timerForIsClickingFileInpt) {
		try {
				upload.document.getElementsByName("LocalName")[0].click();	//点击文件上传按钮，出现文件选择框
		} catch (e) {
			window.setTimeout(this.className + ".waitingSubmitFile()", 500);
			return;
		}
	}
	
	if (upload.document.getElementsByName("LocalName")[0].value == "")
	{
		// 解决IE外的浏览器在，单点浏览文件时还会阻塞代码引发的问题 lxt 2014.05.13
		if(window.navigator.userAgent.indexOf("IE ")<0&&window.g_isClickingFileInptTimes++<200)
		window.g_timerForIsClickingFileInpt=window.setTimeout(this.className + ".waitingSubmitFile()", 500);
		return;
	}
	
	//已经选好文件了
	if (typeof this.uploadInfo.selectAfter == "function") {
		if (this.waitImageStatus == "") {	//第一次运行
			var result = this.uploadInfo.selectAfter.call(this, upload);
			if (typeof result == "boolean") {
				if (!this.uploadInfo.selectAfter.call(this, upload)) {
					return;
				}
			} else {
				return;
			}
		} else {
			if (this.waitImageStatus == "return") {
				this.waitImageStatus = "";
				if (this.handle != "") {
					clearTimeout(this.handle);
					this.handle = "";
				}
				return;
			}
		}
		
	}
	if (this.uploadInfo.isMore == "false" && !/^(0|)$/.test(this.fileName0))		//处理前一个附件
	{
		AjaxRequestPage(psubdir + "upload.jsp?option=DeleteFile&fileName0=" + this.fileName0, true, "", function(str){
		  str = unescape(str);
		  if (str == "ok" || str == "")
		  {
		    
		  }
		  else
		  {
		    alert(str);
		  }
		} );
	}
	if (this.uploadInfo.maxSize != undefined) {
		var thisObj = this;
		window.imgObj = new Image();
		imgObj.onload = function(){
			if (thisObj.checkLimitForImage(window.imgObj.fileSize, window.imgObj.width, window.imgObj.height)) {
				(function(){
					thisObj.continueUpload();
				})();
			}
			imgObj = null;
			thisObj = null;
		};
		imgObj.src = upload.document.getElementsByName("LocalName")[0].value;
		setTimeout("AutoSelectFile.checkOnload()", 1000);
	} else {
		this.continueUpload();
	}
	upload = null;
};
AutoSelectFile.checkOnload = function() {

	if (typeof img == "undefined" || img == null || img.readyState == "complete") {
		
	} else {
		alert("请将本站点加入安全站点,再进行上传.")
	}
}

AutoSelectFile.prototype.continueUpload = function(){
	var upload;
	try
	{
		upload = document.getElementsByName(this.frameName)[0].contentWindow;
	} catch(e) {}
	if (this.uploadInfo.selectFileAfter == null)
	{
		if (typeof this.uploadInfo.beforeUpload == "function") {
			this.uploadInfo.beforeUpload.call(this);
		}
		upload.xianshi();		//提交表单
	}
	else if (typeof this.uploadInfo.selectFileAfter == "function")
	{
		this.uploadInfo.selectFileAfter.call(this);
	}
	upload = null;

}

AutoSelectFile.prototype.checkLimitForImage = function(sizeOfImage, widthOfImage, heightOfImage) {
	var result = false;
	var isSize = false, isWidth = false, isHeight = false;
	var maxSizeOfImage = -1, maxWidthOfImage = -1, maxHeightOfImage = -1;
	if (this.uploadInfo.maxSize != undefined) {
		maxSizeOfImage = this.uploadInfo.maxSize;
	}
	if (this.uploadInfo.maxWidth != undefined) {
		maxWidthOfImage = this.uploadInfo.maxWidth;
	}
	if (this.uploadInfo.maxHeight != undefined) {
		maxHeightOfImage = this.uploadInfo.maxHeight;
	}
	if (maxSizeOfImage < 0 && maxWidthOfImage < 0 && maxHeightOfImage < 0) {
		result = true;
	} else if (maxSizeOfImage == 0 || maxWidthOfImage == 0 || maxHeightOfImage == 0) {
		alert("系统限制，不能上传图片。");
		result = false;
	} else {
		if (maxSizeOfImage > 0) {
			if (sizeOfImage <= maxSizeOfImage * 1024) {
				isSize = true;
			} else {
				alert("文件大小(" + (sizeOfImage+"").replace(/(\d{1,2})(\d{3})(?=(\d{3})*$)/g, "$1,$2")
					 + "B)超出限制" + maxSizeOfImage + "KB。");
				return false;
			}
		} else {
			isSize = true;
		}
		if (maxWidthOfImage > 0) {
			if (widthOfImage <= maxWidthOfImage) {
				isWidth = true;
			} else {
				alert("图像宽度(" + widthOfImage + "像素)超出限制" + maxWidthOfImage + "像素。");
				return false;
			}
		} else {
			isWidth = true;
		}
		if (maxHeightOfImage > 0) {
			if (heightOfImage <= maxHeightOfImage) {
				isHeight = true;
			} else {
				alert("图像高度(" + heightOfImage + "像素)超出限制" + maxHeightOfImage + "像素。");
				return false;
			}
		} else {
			isHeight = true;
		}
		result = isSize && isWidth && isHeight;
	}
	return result;
}

AutoSelectFile.prototype.uploadFile = function()
{
	var upload;
	try
	{
		upload = document.getElementsByName(this.frameName)[0].contentWindow;
	} catch(e) {}
	upload.xianshi();		//提交表单
	upload = null;
}


//多文档窗口类
function MDIWindows(oContainer, cfg)
{
	var mdibar, divbar, divdoc, morebutton;
	var self = this;
	
	this.Create = function(url, title, nNewDoc, windef)
	{
		if ((typeof(nNewDoc) == "undefined") || (nNewDoc != 1))
		{
			var bar = mdibar.getmenu();
			for (var x = 0; x < bar.length; x++)
			{
				var o = bar[x].data;//document.getElementById(bar[x].data);
				if ((o == url) || (o.src == url))
					return mdibar.run(x);
			}
		}

		if ((typeof(title) == "undefined") || (title == ""))
			title = "正在载入...";

		windef = FormatObjvalue({dblclick:ClosePage}, windef);
		var bar = mdibar.getmenu();
		var item = {item:title, className:"CommonPage", type:2, action:ClickPage, dblclick:windef.dblclick,zorder:bar.length + 1};

		var oPage;
		if (typeof url == "object")
			oPage = url;
		else
		{
			oPage = document.createElement("IFRAME");
			oPage.noResize = true;
			oPage.scrilling = "no";
			oPage.frameBorder = 0;
			oPage.src = url;
			objevent(oPage, "load", function()
			{
				if (title == "正在载入...")
				{
					try {
						mdibar.setmenutext(index, event.srcElement.contentWindow.document.title);
					} catch (e) {
						mdibar.setmenutext(index, "已加载");
					}
				}
				self.pageready(bar[x]);
			});
		}
		oPage.style.width = "100%";
		oPage.style.height = "100%";
		item.data = oPage;
		var index = mdibar.append(item);
		divdoc.firstChild.appendChild(oPage);
		mdibar.run(item);
		SetPropPageScroll();
		return item;
	}
	
	this.pageready = function(item)
	{
	};
	
	this.ShowBar = function(nShow)
	{
		if (nShow == 1)
		{
			divbar.style.display = "block";
			divdoc.style.margin = "";
			divdoc.style.padding = "";
		}
		else
		{
			divbar.style.display = "none";
			divdoc.style.margin = "0px";
			divdoc.style.padding = "0px";
		}
		
	};
	
	function ActPage(obj, item)
	{
		self.ActivePage(item.data);
	}

	this.ActivePage = function(item)
	{
		mdibar.run(item);
		SetPropPageScroll();
	};
	
	this.onactive = function(item)
	{
	};
	
	this.GetActivePage = function(nType)
	{
		var bardef = mdibar.getmenu();
		for (var x = 0; x < bardef.length; x++)
		{
			if (bardef[x].status == 1)
			{
				switch (nType)
				{
				case 1:			//名称
					return bardef[x].item;
				case 2:			//iframe object
					return bardef[x].data;//document.getElementById(bardef[x].data);
				case 3:
					return bardef[x];
				default:
					return x;
				}
			}
		}
	};

	this.setPage = function (page, src)
	{
		var bardef = mdibar.getmenu();
		for (var x = 0; x < bardef.length; x++)
		{
			if ((bardef[x].item == page) || (x == page) || (bardef[x] == page))
			{
				bardef[x].data.scr = src;//document.getElementById(bardef[x].data).src = src;
				break;
			}	
		}
		
	};

	function ClickPage(obj, item)
	{
		var bar = mdibar.getmenu();
		var active;
		for (var x = 0; x < bar.length; x++)
		{
			var page = bar[x].data;
			if (bar[x] == item)
			{
				page.style.display = "block";
				self.onactive(item);
				active = x;
			}
			else
			{
				page.style.display = "none";
			}
		}
		for (var x = 0; x < bar.length; x++)
		{
			if (bar[x].zorder > bar[active].zorder)
				bar[x].zorder --;
		}
		bar[active].zorder = bar.length;
	};

	function SetPropPageScroll()
	{
	var x, cnt = 0;
		var bar = mdibar.getmenu();
		if (bar.length == 0)
		{
			oContainer.firstChild.style.display = "none";
			return;
		}
		oContainer.firstChild.style.display = "block";

		if (oContainer.clientWidth == 0)
			return;
		if (bar.length * 71 < oContainer.clientWidth - 60)
		{
			if (morebutton != undefined)
			{
				morebutton.parentNode.removeChild(morebutton);
				for (var x = 0; x < bar.length; x++)
					mdibar.showItem(x, true);
				morebutton = undefined;
			}
			return;
		}
		if (morebutton == undefined)
		{
			mdibar.insertHTML("<span id=MoreButton style=font-family:webdings;padding-left:4px;>4</span>", "beforeEnd");
			morebutton = objall(divbar, "MoreButton");
			morebutton.onmousedown = ShowMorePage;
		}

		var nPos = self.GetActivePage(4);
		var pages = parseInt((oContainer.clientWidth - 60) / 71);
		for (x = nPos; x >= 0; x--)
		{
			if (cnt < pages)
			{
				cnt ++;
				mdibar.showItem(x, true);
			}
			else
				mdibar.showItem(x, false);
		}
		for (x = nPos + 1; x < bar.length; x++)
		{
			if (cnt < pages)
			{
				cnt ++;
				mdibar.showItem(x, true);
			}
			else
				mdibar.showItem(x, false);
		}
	};
	
	function ShowMorePage()
	{
		var bar = mdibar.getmenu();
		var nPos = self.GetActivePage(4);
		var menudef = [];
		for (var x = 0; x < bar.length; x++)
		{
			menudef[x] = {};
			if (mdibar.showItem(x) == true)
				menudef[x].style = "color:gray";
			if (x == nPos)
				menudef[x].img = "<span style='color:red;font:18px webdings'>a</span>";
			menudef[x].item = bar[x].item;
			menudef[x].data = x;
			menudef[x].action = ActPage;
		}
		menudef[bar.length] = {};
		menudef[bar.length + 1] = {item:"关闭全部窗口(总数:" + (bar.length - 1) + ")", 
			img: "<span style=color:red;font-family:webdings;>r</span>", action:self.closeAll};
		var menu = new CommonMenu(menudef);
		menu.show();
		return false;
	};
	
	this.closeAll = function()
	{
		if (window.confirm("是否关闭全部窗口？") == false)
			return;
		var bar = mdibar.getmenu();
		for (var x = bar.length - 1; x >= 0; x--)
			self.Close(bar[x]);
	};


	this.Close = function(item)
	{
		var menuitem = mdibar.getmenu(item);
		if (typeof menuitem != "object")
			return;
		var frm = menuitem.data;//document.getElementById(menuitem.data);
		try
		{
			if (frm.contentWindow.document.body.onbeforeunload != null)
			{
				if (window.confirm("该文档的内容已经改变，尚未保存，是否需要放弃退出？") == false)
					return;
			}
		}
		catch (e)
		{
		}
		frm.parentNode.removeChild(frm);
		var o = mdibar.remove(item);
		SetPropPageScroll();
		cfg.fnClose(mdibar, o[0]);
		var bar = mdibar.getmenu();
		for (var x = 0; x < bar.length; x++)
		{
			if (bar[x].zorder == bar.length)
				return mdibar.run(x);
		}
		mdibar.run(0);
	};	

	this.onClose = function(mdibar, obj)
	{
	};

	function ClosePage(obj, item)
	{
		if (typeof obj == "undefined")
			self.Close(self.GetActivePage(4));
		else
			self.Close(parseInt(objattr(obj, "node")));
	}

	function InitMDIWin()
	{
		cfg = FormatObjvalue({barClass:"MDIBar", winClass:"MDIWindow",fnClose:self.onClose, closeButton:0}, cfg);
		oContainer.innerHTML = "<div style='width:100%;height:100%;overflow:hidden;display:none'>" +
			"<div class=" + cfg.barClass + "></div><div class=" + cfg.winClass + "><div></div></div>";
		var button = "";
		if (cfg.closeButton == 1)
			button = "<span id=CloseWinButton style=font-family:webdings;>r</span>";
		mdibar = new CommonMenubar([], oContainer.firstChild.firstChild, {className:"CommPageContainer", title:button});
		divbar = oContainer.firstChild.firstChild;
		divdoc = oContainer.firstChild.lastChild;
		oContainer.onresize = SetPropPageScroll;
		if (cfg.closeButton == 1)
			objall(divbar, "CloseWinButton").onclick = ClosePage;
	}
	if (typeof oContainer == "object")
		InitMDIWin();	
}


//分隔条类
//在两个DOM容器之间加上分隔条,以实现横向或纵向改变容器尺寸.当第二个容器obj2省略,则obj2为第一个容器的下一个对象.
function Split(obj1, obj2, fn, minedge, maxedge, nStyle)
{
	var obj, button, hv = 0, delta = 0;
	var self = this;
	
	function onsize()
	{
		if (document.onmouseup == null)
		{
			var pos = GetObjPos(obj1);
			if (hv == 1)
				obj.style.left = (pos.right + 3) + "px";
			else
				obj.style.top = (pos.bottom + 3) + "px";
		}
		obj.style.display = obj2.style.display;
	}

	this.refresh = function ()
	{
		if (obj.style.display == "none")
			return;
		var pos = GetObjPos(obj1, obj.offsetParent);
		if (hv == 1)
		{
			obj.style.left = pos.right + "px";
//			obj.style.height = obj1.style.height;
			obj.style.height = obj1.offsetHeight + "px";
			obj.style.top = pos.top + "px";
		}
		else
		{
			obj.style.left = pos.left + "px";
//			obj.style.width = obj1.style.width;
			obj.style.width = obj1.offsetWidth + "px";
			obj.style.top = pos.bottom + "px";
		}
	};

	this.show = function (nShow)
	{
		switch (nShow)
		{
		case 0:
			obj.style.display = "none";
			break;
		case 1:
			obj.style.display = "block";
			break;
		}
	};
	
	this.onsplit = function (left, top){};
		
	function Create()
	{
		var p1 = GetObjPos(obj1);
		var p2 = GetObjPos(obj2);
		if (p1.top == p2.top)
		{
			hv = 1;
			obj1.insertAdjacentHTML("afterEnd", 
				"<div style='position:absolute;height:24px;width:16px;font-family:webdings;font-size:16px;overflow:hidden;cursor:hand;filter:alpha(opacity=70);display:none;'>3</div>");
			button = obj1.nextSibling;
			obj1.insertAdjacentHTML("afterEnd", 
				"<div style='position:absolute;width:8px;overflow:hidden;cursor:col-resize;margin-left:-3px;filter:alpha(opacity=0);background-color:gray;'></div>");
			obj = obj1.nextSibling;
		}
		else if (p1.left == p2.left)
		{
			hv = 0;
			obj1.insertAdjacentHTML("afterEnd", 
				"<div style='position:absolute;height:16px;width:16px;font-family:webdings;font-size:16px;overflow:hidden;cursor:hand;filter:alpha(opacity=70);display:none;'>5</div>");
			button = obj1.nextSibling;
			obj1.insertAdjacentHTML("afterEnd", 
				"<div style='position:absolute;height:8px;overflow:hidden;cursor:row-resize;margin-top:-3px;filter:alpha(opacity=0);background-color:gray;'></div>");
			obj = obj1.nextSibling;
		}
		obj.onmouseover = overSplit;
		button.onmouseout = OutButton;
		obj.onmouseout = OutSplit;
		button.onclick = ClickButton;
		obj.onmousedown = BeginSplit;
//		if (obj1.parentNode.tagName == "BODY")
//			obj1.attachEvent("onresize", onsize);
	}

	function overSplit()
	{
		if (obj.onmousemove != null)
			return;
		var pos = GetObjPos(obj2, obj.offsetParent);
		if (hv == 1)
		{
			button.style.top = pos.top + parseInt((pos.bottom - pos.top) / 2) - 12;
			if (obj1.style.display != "none")
				button.style.left = (pos.left - 9) + "px";
		}
		else
		{
			button.style.left = pos.left + parseInt((pos.right - pos.left) / 2) - 12;
			if (obj1.style.display != "none")
				button.style.top = (pos.top - 15) + "px";
			else
				button.style.top = (pos.top - 10) + "px";
		}
		if (nStyle == 1)
			button.style.display = "block";
	};

	function OutButton()
	{
//		var evt = getEvent();
//		if (evt.toElement != obj)
//			button.style.display = "none";
	}
	
	function OutSplit ()
	{
		var evt = getEvent();
		if (evt.toElement != button)
			button.style.display = "none";
	}
	
	function ClickButton()
	{
		if (hv == 1)
		{
			button.style.top = (obj1.offsetTop + parseInt((obj2.offsetHeight - obj1.offsetTop) / 2) - 12) + "px";
			button.style.left = "-4px";
			if (obj1.style.display == "none")
			{
				obj1.style.display = "block";
				obj.style.left = obj1.offsetWidth + "px";
				button.innerHTML = 3;
				obj.style.cursor = "col-resize";
			}
			else
			{
				button.innerHTML = 4;
				obj1.style.display = "none";
				obj.style.cursor = "default";
				obj.style.left = "0px";
			}
		}
		else
		{
			if (obj1.style.display == "none")
			{
				obj1.style.display = "block";
				var pos = GetObjPos(obj2, obj.offsetParent);
				obj.style.top = pos.top + "px";
				button.innerHTML = 5;
				obj.style.cursor = "row-resize";
			}
			else
			{
				button.innerHTML = 6;
				obj1.style.display = "none";
				obj.style.cursor = "default";
				var pos = GetObjPos(obj2, obj.offsetParent);
				obj.style.top = pos.top + "px";
			}
			obj.onmouseover();
		}
		if (typeof(fn) == "function")
			fn(parseInt(obj.style.left), parseInt(obj.style.top))
	}
	
	function BeginSplit()
	{
		if (obj2.style.display == "none")
			return;
		button.style.display = "none";
		if (obj1.style.display == "none")
			return button.onclick();
		obj.onmousemove = Splitting;
		obj.onmouseup = EndSplit;
		obj.ondragstart = Splitting;
		obj.style.filter = "alpha(opacity=60)";
		obj.setCapture();
		Splitting(1);
	};
	
	function Splitting(startflag)
	{
		var pos = GetObjPos(obj);
		var p1 = GetObjPos(obj1.parentNode);
		var evt = getEvent();
		if (hv == 1)
		{
			if (startflag == 1)
				delta = pos.left - evt.clientX;
			if (evt.clientX - p1.left < minedge)
				obj.style.left = (p1.left + minedge - pos.left + parseInt(obj.style.left)) + "px";
			else if (p1.right - evt.clientX < maxedge)
				obj.style.left = (p1.right - maxedge - pos.left + parseInt(obj.style.left)) + "px";
			else
				obj.style.left = (evt.clientX - pos.left + delta + parseInt(obj.style.left)) + "px";
		}
		else
		{
			if (startflag == 1)
				delta = pos.top - evt.clientY;
			if (evt.clientY - p1.top < minedge)
				obj.style.top = (p1.top + minedge - pos.top + parseInt(obj.style.top)) + "px";
			else if (p1.bottom - evt.clientY < maxedge)
				obj.style.top = (p1.bottom - maxedge - pos.top + parseInt(obj.style.top)) + "px";
			else
				obj.style.top = (evt.clientY - pos.top + delta + parseInt(obj.style.top)) + "px";
		}
	}

	function EndSplit()
	{
		obj.style.filter = "alpha(opacity=0)";
		var pos = GetObjPos(obj1, obj.offsetParent);
		if (hv == 1)
		{
			obj1.style.width = (parseInt(obj.style.left) - pos.left) + "px";
//			obj2.style.pixelWidth -= obj.style.pixelLeft  - pos.right;
		}
		else
		{
			obj1.style.height = (parseInt(obj.style.top) - pos.top) + "px";
//			obj2.style.pixelHeight -= obj.style.pixelTop  - pos.top;
		}
//		self.onsplit(obj.style.pixelLeft, obj.style.pixelTop);
		obj.onmousemove = null;
		obj.onmouseup = null;
		obj.ondragstart = null;
		document.releaseCapture();
		self.refresh();
		self.onsplit(parseInt(obj.style.left), parseInt(obj.style.top));
	}

	function Init()
	{
		if (typeof obj1 != "object")
			return;
		if (typeof fn == "function")
			this.onsplit = fn;

		if (typeof(obj2) != "object")
		{
			try {
				for (obj2 = obj1.nextSibling; obj2.nodeType == 3; obj2 = obj2.nextSibling);
			} catch (e) {
				
			}
		}
		if (minedge == undefined)
			minedge = 0;
		if (maxedge == undefined)
			maxedge = 0;
		Create();
		self.refresh();

	}
	Init();
}

//文档内弹出框, 自动在矩形x1, y1, x2, y2的位置周围出现, 只要本身面积不大于文档,即不超出出文档边界.可用于弹出菜单等。
function PopupBox(tag, x1, y1, x2, y2)
{
var oDiv;
	this.show = function()
	{
		x1 = arguments[0];
		y1 = arguments[1];
		x2 = arguments[2];
		y2 = arguments[3];
		if (typeof x1 == "undefined")
		{
			x1 = document.body.scrollLeft;
			y1 = document.body.scrollTop;
			var evt = getEvent();
			if (evt != null)
			{
				x1 = evt.clientX;
				y1 = evt.clientY;
			}
		}
		if (typeof x2 == "undefined")
		{
			x2 = x1;
			y2 = y1;
		}
		this.unselect();

		oDiv.style.display = "block";
		var left = x2, top = y1;
		if (x1 == x2)
			top = y2;
		if ((y1 != y2) && (top + oDiv.clientHeight + 2 >= document.body.clientHeight + document.body.scrollTop))
		{
			top = y2 - oDiv.clientHeight;		//x1,x2,y1,y2如为矩形,则作为菜单条样式，根据空间位置，显示在菜单条周围
			if (x1 == x2)
				top = y1 - oDiv.clientHeight - 2;//x1,x2,y1,y2如为垂直竖线，则作为弹出框样式，根据空间位置，显示在下面或上面
		}
		if ((x1 != x2) && (x2 + oDiv.clientWidth >= document.body.clientWidth + document.body.scrollLeft))
			left = x1 - oDiv.clientWidth;	//对应于菜单显示，如右边空间不够，就放到左边
		if (top + oDiv.clientHeight > document.body.clientHeight + document.body.scrollTop)
			top = document.body.clientHeight - oDiv.clientHeight + document.body.scrollTop;
		if (left + oDiv.clientWidth > document.body.clientWidth + document.body.scrollLeft)
			left = document.body.clientWidth - oDiv.clientWidth + document.body.scrollLeft;
		
		if (top < 0)
			top = 0;	//如上或左也不够，就从上或左原点开始
		if (left < 0)
			left = 0;
		oDiv.style.left = left + "px";
		oDiv.style.top = top + "px";
	};

	this.isShow = function()
	{
		if (oDiv.style.display == "none")
			return false;
		return true;
	};
	
	this.hide = function()
	{
		oDiv.style.display = "none";
	};
	
	this.remove = function()
	{
		oDiv.parentNode.removeChild(oDiv);
		oDiv = undefined;
	};
	this.getdomobj = function()
	{
		return oDiv;
	};
	
	this.unselect = function()
	{
		var all = objall(oDiv);
		for (var x = 0; x < all.length; x++)
		{
			all[x].UNSELECTABLE = "on";
			all[x].style.MozUserSelect = "none";		//firebox
			all[x].style.WebkitUserSelect = "none";	//chrome
		}
	};
	
	this.setSize = function(width, height)
	{
		if (typeof width == "number")
			oDiv.style.width = width + "px";
		if (typeof height == "number")
			oDiv.style.height = height + "px";
	};

	this.setPopObj = function (obj)
	{
		tag = obj;
		if (typeof tag == "string")
			oDiv.innerHTML = tag;
		if (typeof tag == "object")
			oDiv.insertAdjacentElement("afterBegin", tag);
		if (typeof x1 == "number")
			this.show(x1, y1, x2, y2);
	};
	
	oDiv = document.createElement("DIV");
//	oDiv = document.createElement("<DIV UNSELECTABLE=on style='display:none;position:absolute;background-color:white;z-index:99;overflow:visible;'></div>");
	objcss(oDiv, {display: "none", position: "absolute", backgroundColor: "white", zIndex: 99, overflow: "visible"});
	document.body.insertBefore(oDiv, null);
	
	this.setPopObj(tag);
}

//文档内弹出窗口
function PopupWin(href, cfg)
{
	var self = this;
	var box, mask, sizebox;
	function init()
	{
		var htmlText = "";
		if (typeof href == "string")
		{
			if (href.substr(0, 1) != "<")
				htmlText = "<iframe name=IFrameDlg frameborder=0 style='width:100%;height:100%' src=" + href + "></iframe>";
			else
				htmlText = href;
		}
		var top = document.body.scrollTop;
		var left = document.body.scrollLeft;
		if (cfg.mask >= 0)
		{
			mask = document.createElement("<div style='position:absolute;left:" + left + "px;top:" + 
				top + "px;width:100%;height:100%;background-color:white;filter:alpha(opacity=" + cfg.mask + ");'></div>");
			document.body.appendChild(mask);
		}
		if (cfg.top < 0)
			cfg.top = top + (document.body.clientHeight - cfg.height) / 2;
		if (cfg.left < 0)
			cfg.left = left + (document.body.clientWidth - cfg.width) / 2;
		if (cfg.top < 0)
			cfg.top = 0;
		if (cfg.left < 0)
			cfg.left = 0;
		var tag = "<div id=InDlgBox style='position:static;width:" + cfg.width + "px;height:100%;' class=" + cfg.css + 
			"><div nowrap id=RTDiv><div id=LTDiv><div id=TDiv>" +
			"<div id=CloseButton onmouseover=this.className='ClsBox_Roll'; onmouseout=this.className='ClsBox'; class=ClsBox></div>" +
			"<b id=titlebar style=width:100%;overflow:hidden>" + cfg.title + "</b></div></div></div><div id=RDiv style=height:" +
			(cfg.height - 32) + "px;><div id=LDiv><div id=MDiv>" + htmlText +
			"</div></div></div><div id=RBDiv><div id=LBDiv><div id=BDiv></div></div></div></div>";

		box = new PopupBox(tag);
		box.unselect = function (){};
		box.show(cfg.left, cfg.top, cfg.left, cfg.top);

		var div = box.getdomobj();
		if ((cfg.title == "") && (objall(div, "IFrameDlg") != null))
			objall(div, "IFrameDlg").onload = frameOK;
		if ((cfg.bClose == 1) || (cfg.bClose == true))
			objall(div, "CloseButton").onclick = closePopWin;
		else
			objall(div, "CloseButton").style.display = "none";
		box.setSize(cfg.width, cfg.height);
		sizebox = new SizeBox(cfg.resize, "transparent");
		objall(div, "titlebar").onmousedown = sizebox.start;
		objall(div, "titlebar").ondblclick = sizebox.runMax;
		div.onresize = ResizeWin;
		sizebox.attach(div);
	}
	
	function closePopWin()
	{
		self.close();
	}

	function ResizeWin()
	{
		var div = box.getdomobj();
		div.style.overflow = "hidden";
		objall(div, "RDiv").style.height = (parseInt(div.style.height) - 32) + "px";
		objall(div, "InDlgBox").style.width = div.style.width;
		div.style.overflow = "visible";
	}

	function frameOK()
	{
		var div = box.getdomobj();
		objall(div, "titlebar").innerHTML = objall(div, "IFrameDlg").contentWindow.document.title;
	}

	this.show = function (left, top, width, height)
	{
		if (typeof mask == "object")
			mask.style.display = "block";
		box.show(left, top, left, top);
		box.setSize(width, height);
		var div = box.getdomobj();
		sizebox.attach(div);
	}

	this.hide = function ()
	{
		if (typeof mask == "object")
			mask.style.display = "none";
		box.hide();
		sizebox.detach();
	};

	this.runMax = function (nType)
	{
		sizebox.runMax(nType);
	};

	this.close = function ()
	{
		self.onclose();
		if (typeof mask == "object")
			mask.parentNode.removeChild(mask);
		box.remove();
		sizebox.remove();
	};

	this.isShow = function()
	{
		return box.isShow();
	}

	cfg = FormatObjvalue({left:-1, top:-1, width:300, height:350, css:"InlineDlg", title:"", resize:1, mask:-1, bClose:1}, cfg);

	this.onclose = function ()
	{
	};

	init();
}

//通用下拉菜单类
//用法:	var sysmenu = new CommonMenu([{item:"菜单项", img:"pic.gif", action:"alert()"},{item:""},{item:"子菜单,child:[...]}]);
//		sysmenu.show();
function CommonMenu(menudef, oParentMenu)
{
	var oMenuBox, oRoll;
	var oSubMenu;
	var oTimeout = null;
	var self = this;
	function InitMenu(x1, y1, x2, y2)
	{
		if (typeof(menudef) != "object")
			return;
		var tag = "", bLine = false;
		for (var x = 0; x < menudef.length; x++)
		{
			if (menudef[x].status == 1)
				continue;
				
			if ((menudef[x].item == "") || (typeof menudef[x].item == "undefined"))
			{
				if (bLine == true)
					tag += "<tr height=8px><td bgcolor=#e8edf0 colspan=3></td><td colspan=3 style='padding:4px 4px 0px 2px;'>" +
						"<div style='overflow:hidden;width:100%;height:3px;border-top:1px solid #e8edf0'></div></td><td></td></tr>";
				bLine = false;
			}				
			else
			{
				tag += "<tr height=24px node=" + x + "><td bgcolor=#e8edf0></td><td bgcolor=#e8edf0></td>";
				if ((typeof menudef[x].img == "string") && (menudef[x].img != ""))
				{
					if (menudef[x].img.substr(0, 1) == "<")
						tag += "<td bgcolor=#e8edf0 align=center>" + menudef[x].img + "</td>";
					else
						tag += "<td bgcolor=#e8edf0 align=center><img src=" + menudef[x].img + "></td>";
				}
				else
					tag += "<td bgcolor=#e8edf0></td>";
				var style = "";
				if (typeof menudef[x].style == "string")
					style = menudef[x].style;
				tag += "<td nowrap style=font-size:9pt;padding-left:10px;" + style + ">" + menudef[x].item + "</td>";
				if (typeof menudef[x].child == "object")
					tag += "<td align=right style='font:normal normal normal 14px webdings'>4</td>";
				else
					tag += "<td></td>";
				tag += "<td></td><td></td></tr>";
				bLine = true;
			}
		}
		tag = "<table cellpadding=0 cellspacing=0 border=0 style='filter:progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray);background-color:white;border:1px solid gray;cursor:default;'>" +
			"<tr height=3px><td bgcolor=#e8edf0><div style=width:2px;height:3px;overflow:hidden;></div></td>" +
			"<td bgcolor=#e8edf0><div style=width:3px;height:3px;overflow:hidden;></div></td>" + 
			"<td bgcolor=#e8edf0><div style=width:30px;height:3px;overflow:hidden;></div></td><td></td>" +
			"<td><div style=width:32px;height:3px;overflow:hidden;></div></td>" +
			"<td><div style=width:3px;height:3px;overflow:hidden;></div></td>" +
			"<td><div style=width:2px;height:3px;overflow:hidden;></div></td></tr>" + tag +
			"<tr height=3px><td bgcolor=#e8edf0></td><td bgcolor=#e8edf0></td><td bgcolor=#e8edf0></td>" +
			"<td></td><td></td></tr></table>";
		oMenuBox = new PopupBox(tag);
		oMenuBox.show(x1, y1, x2, y2);
		var oMenuDiv = oMenuBox.getdomobj();
//		oMenuDiv.firstChild.onfocusout = CheckFocus;
 		oMenuDiv.onmousemove = RollMenu;
 		oMenuDiv.onmouseout = RollMenu;
 		oMenuDiv.onclick = ActionMenu;
 		try {
 			oMenuDiv.firstChild.focus();	//ie8报错，先屏蔽?
 		} catch (e) {
 			//alert(e.desciption);
 		}
		oMenuDiv.firstChild.onblur = CheckFocus;
	}

	function RollMenu()
	{
		var oMenuDiv = oMenuBox.getdomobj();
		var evt = getEvent();
		var oTR = FindParentObject(evt.srcElement, oMenuDiv, "TR");
		if (oTR == oRoll)
			return;
		if (typeof oRoll == "object")
		{
			oRoll.cells[1].className = "RMenuItem1";
			oRoll.cells[2].className = "RMenuItem1";
			oRoll.cells[3].className = "RMenuItem2";
			oRoll.cells[4].className = "RMenuItem2";
			oRoll.cells[5].className = "RMenuItem2";
			if (oTimeout != null)
			{
				window.clearTimeout(oTimeout);
				oTimeout = null;
			}
			if (typeof oSubMenu == "object")
				oSubMenu.hide();
			oSubMenu = 0;
			oMenuDiv.firstChild.focus();
		}
		oRoll = 0;	
		if ((typeof(oTR) == "object") && (oTR.offsetHeight > 10))
		{
			oTR.cells[1].className = "RMenuSelItem1";
			oTR.cells[2].className = "RMenuSelItem2";
			oTR.cells[3].className = "RMenuSelItem2";
			oTR.cells[4].className = "RMenuSelItem2";
			oTR.cells[5].className = "RMenuSelItem3";
			if (oTR.cells[4].firstChild != null)
				oTimeout = window.setTimeout(ShowSubMenu, 500);
			oRoll = oTR;
		}	
	}

	function ShowSubMenu()
	{
		var index = objattr(oRoll, "node");
		if (typeof menudef[index].child == "object")
		{
			var pos = GetObjPos(oRoll);
			if (typeof oMenuBox == "object")
			{
				oSubMenu = new CommonMenu(menudef[index].child, self);
				oSubMenu.show(pos.left, pos.top, pos.right, pos.bottom);
			}
		}
	}

	function ActionMenu()
	{
		if ((typeof oRoll == "object") && (typeof oSubMenu != "object"))
		{
			var index = objattr(oRoll, "node");
			if (typeof menudef[index].child == "object")
			{
				if (oTimeout != null)
				{
					window.clearTimeout(oTimeout);
					oTimeout = null;
				}
				return ShowSubMenu();
			}
			self.hide(true);
			if (typeof menudef[index].action == "string")
				eval(menudef[index].action);
			if (typeof menudef[index].action == "function")
				return menudef[index].action(oRoll, menudef[index]);
		}
	}

	function CheckFocus()
	{
		if (typeof oMenuBox != "object")
			return;
		var evt = getEvent();
		if (isParentObj(evt.srcElement, oMenuBox.getdomobj()))
			return;
		if ((typeof oSubMenu == "object") && (oSubMenu.isShow() == true))
			return;
		self.hide(true);
	}
	
	this.show = function (x1, y1, x2, y2)
	{
		if (typeof oMenuBox == "object")
			oMenuBox.show(x1, y1, x2, y2);
		else
			InitMenu(x1, y1, x2, y2);
		window.setTimeout(function(){ objevent(document.body, "mousedown", CheckFocus);}, 1);
	};
	
	this.hide = function (flag)
	{
		if (typeof oMenuBox == "object")
		{
			if (typeof oSubMenu == "object")
				oSubMenu.hide();
			oMenuBox.remove();
			oMenuBox = 0;
		}
		if ((flag == true) && (typeof oParentMenu == "object"))
			oParentMenu.hide(true);
		objevent(document.body, "mousedown", CheckFocus, 1);
	};
	
	this.isShow = function ()
	{
		if (typeof oMenuBox == "object")
			return true;
		return false;
	};
	
	//过滤菜单项显示
	//例: filter = {	disable:1, str:"发送即时消息,发送内部邮件,查阅个人资料,查阅对话记录,查阅往来内部邮件,添加为我的好友"};
	//或: filter = {	disable:1, str:""};
	this.setMenuFilter = function(filter)
	{
		if (typeof filter != "object")
			return;
		var ss = filter.str.split(",");
//		var flag = 1, delflag;
		var status = 0 ,inistatus = 0;
		if (filter.disable == 1)
			status = 1;
		else
			inistatus = 1;
		for (var x = 0; x < menudef.length ; x++)
		{
			menudef[x].status = inistatus;
			for (var y = 0; y < ss.length; y++)
			{
				if (menudef[x].item == ss[y])
				{
					menudef[x].status = status;
					break;
				}
			}
		}
	};

	this.getmenu = function(item)
	{
		if (typeof item == "undefined")
			return menudef;
//		var obj = this.getDomItem(item);
//		if (typeof obj == "object")
//			return menudef[obj.node];
	};
}

//通用菜单条、工具栏、属性页标题类,菜单条创建在给定的容器内.容器内原有的内容被覆盖.
//用法:	var menubar = new CommonMenubar([{item:"菜单项", img:"pic.gif", action:"alert()"},{item:""},{item:"子菜单,child:[...]}], domobj);
//
function CommonMenubar(menudef, domObj, cfg)
{
	var oRoll;
	var nStatus = 0;
	var self = this;
	var childMenu;
	
	function InitMenu()
	{
		if (domObj == null || typeof domObj != "object")
			return;
		if (typeof cfg == "string")
			cfg = {title:cfg};
		cfg = FormatObjvalue({title:"", nMode:1, className:"CommonMenubar"}, cfg);

		var tag = "";
		for (var x = 0; x < menudef.length; x++)
			tag += getMenuItemHTML(menudef[x], x);
		domObj.innerHTML = "<table cellpadding=0 cellspacing=0 border=0 class=" + cfg.className +
			"><tr><td nowrap>" + tag + "</td><td nowrap id=titletd align=right>" + cfg.title +
			"</td></tr></table>";
 		var objs = domObj.getElementsByTagName("BUTTON");
// 		domObj.onmousemove = RollMenu;
 		for (x = 0; x < objs.length; x++)
 		{
 			objs[x].onmouseover = RollMenu;
 			objs[x].onmouseout = OutMenu;
	 	}	
 		domObj.onclick = ActionMenu;
 		domObj.onmousedown = PushMenu;
 		domObj.ondblclick = DblClickMenu;
	}
	
	function getMenuItemHTML(item, node)
	{
		if (typeof item == "string")
			return item;
		if ( (item.item == undefined) && (item.img == undefined) && (item.action == undefined))
			return "&nbsp;";
		var tag = "<button UNSELECTABLE=on node=" + node;
		if ((item.disabled == true) || ((typeof item.action == "undefined") && (typeof item.child == "undefined")))
			tag += " disabled";
		if (typeof item.className == "string")
			tag += " class=" + item.className + "0";
		else
			tag += " class=CommonMenubarItem0";
		if (typeof item.style == "string")
			tag += " style=\"" + item.style + "\"";
		if ((typeof item.title == "string") && (item.title != ""))
			tag += " title=\"" + item.title + "\"";
		if ((typeof item.img == "string") && (item.img != ""))
			tag += "><img UNSELECTABLE=on align=texttop src=" + item.img;
		if ((typeof item.item == "string") && (item.item != ""))
				tag += ">" +  item.item + "</button>";
		else
			tag += "></button>";
		return tag;
	}
	
	function OutMenu(obj)
	{
		if ((nStatus == 1) && (typeof childMenu == "object"))
			return;
		self.hide();
	}
	
	function RollMenu()
	{
		var evt = getEvent();
		var oSrc = FindParentObject(evt.srcElement, domObj, "BUTTON");
		if (oRoll == oSrc)
			return;
		if (typeof oSrc != "object")
			return;
		var node = objattr(oSrc, "node");
		if ((oSrc.tagName == "BUTTON") && (typeof node != "undefined"))
		{
			if (oSrc.disabled)
				return;
			if (typeof oRoll == "object")
				self.hide();
			oRoll = oSrc;
			if (node >= menudef.length)
				return;
			if ((menudef[node].type == 2) && (menudef[node].status == 1))
				return;
			if ((nStatus == 1) && (typeof menudef[node].child == "object"))
				PushMenu();
			else
			{
				nStatus = 0;
				oRoll.className = oRoll.className.substr(0, oRoll.className.length - 1) + "1";
				if (typeof childMenu == "object")
				{
					childMenu.hide();
					childMenu = 0;
				}
			}
		}
	}
		
	function PushMenu()
	{
		if (typeof oRoll != "object")
			return;
		if ((objattr(oRoll, "type") == 2) && (objattr(oRoll, "status") == 1))
			return;
		nStatus = 1;
		oRoll.className = oRoll.className.substr(0, oRoll.className.length - 1) + "2";
		if (typeof childMenu == "object")
		{
			childMenu.hide();
			childMenu = 0;
			var evt = getEvent();
			if (evt.type == "mousedown")
				return;
		}
		var node = objattr(oRoll, "node");
		if (node >= menudef.length)
			return;
		if (typeof menudef[node].child == "object")
		{
			var pos = GetObjPos(oRoll, childMenu);
			childMenu = new CommonMenu(menudef[node].child, self);
			childMenu.show(pos.left, pos.bottom, pos.left, pos.bottom);	
		}
	}
		
	function ActionMenu()
	{
		if ((typeof oRoll == "object") && (typeof childMenu != "object")) 
		{
			var x = objattr(oRoll, "node");
			oRoll.blur();
			if (x >= menudef.length)
				return;
			switch (menudef[x].type)
			{
			case 1:
				if (menudef[x].status == 1)
					menudef[x].status = 0;
				else
					menudef[x].status = 1;
				break;
			case 2:
				for (var y = 0; y < menudef.length; y++)
				{
					if (x != y)
					{
						menudef[y].status = 0;
						SetDomItem(self.getDomItem(y));
					}
				}
				menudef[x].status = 1;
				break;
			}
			if (typeof menudef[x].action == "string")
				eval(menudef[x].action);
			if (typeof menudef[x].action == "function")
				menudef[x].action(oRoll, menudef[x]);
			self.hide(true);
			nStatus = 0;
		}
	}
	
	function DblClickMenu()
	{
		if ((typeof oRoll == "object") && (typeof childMenu != "object")) 
		{
			var x = objattr(oRoll, "node");
			if (x >= menudef.length)
				return;
			if (typeof menudef[x].dblclick == "string")
				eval(menudef[x].dblclick);
			if (typeof menudef[x].dblclick == "function")
				menudef[x].dblclick(oRoll, menudef[x]);
		
		}
	}
	
	function SetDomItem(obj)
	{
		var node = objattr(obj, "node");
		if (node >= menudef.length)
			return;
		if (((menudef[node].type == 1) || (menudef[node].type == 2))
			&& (menudef[node].status == 1))
			obj.className = oRoll.className.substr(0, obj.className.length - 1) + "2";
		else
			obj.className = obj.className.substr(0, obj.className.length - 1) + "0";	
	}
		
	this.run = function(item)
	{
		oRoll = this.getDomItem(item);
		if (typeof oRoll == "object")
			oRoll.click();
	};
	
	this.setStatus = function(item, status)
	{
		var obj = this.getDomItem(item);
		menudef[objattr(obj, "node")].status = status;
		SetDomItem(obj);
	}
	
	this.setDisabled = function (item, disabled)
	{
		var obj = this.getDomItem(item);
		obj.disabled = disabled;
	};
	
	this.getDomItem = function(item)
	{
		var oo = domObj.getElementsByTagName("BUTTON");
		for (var x = 0; x < oo.length; x++)
		{
			switch (typeof item)
			{
			case "number":
				if (objattr(oo[x], "node") == item)
					return oo[x];
				break;
			case "string":
				if ((oo[x].innerHTML == item) || (oo[x].title == item))
					return oo[x];
				break;
			case "object":
				if (menudef[objattr(oo[x], "node")] == item)
					return oo[x];
			}
		}
	};

	this.hide = function (flag)
	{
		if (flag == 1)
			nStatus = 0;
		if (typeof oRoll != "object")
			return;
		SetDomItem(oRoll);
		oRoll = 0;
		if ((typeof childMenu == "object") && (childMenu.isShow()))
			childMenu.hide();
	};
	
	this.append = function(obj)
	{
		
		var node = menudef.length;
		menudef[node] = obj;
		var tag = getMenuItemHTML(obj, node);
		var o = self.getDomItem(node - 1);
		if (o == null)
		{
			domObj.firstChild.rows[0].cells[0].insertAdjacentHTML("afterBegin", tag);
			domObj.firstChild.lastChild.onmouseover = RollMenu;
 			domObj.firstChild.lastChild.onmouseout = OutMenu;		
		}
		else
		{
			o.insertAdjacentHTML("afterEnd", tag);
			o.nextSibling.onmouseover = RollMenu;
 			o.nextSibling.onmouseout = OutMenu;
		}
		return node;
	};

	this.remove = function(item)
	{
		var obj = this.getDomItem(item);
		for (var x = parseInt(objattr(obj, "node")) + 1; x < menudef.length; x ++)
		{
			var o = this.getDomItem(x);
			objattr(o, "node",  parseInt(objattr(o, "node")) - 1);
		}
		var o = menudef.splice(objattr(obj, "node"), 1);
		obj.parentNode.removeChild(obj);
		return o;
	};
	
	this.showItem = function(item, bshow)
	{
		var obj = this.getDomItem(item);
		if (typeof bshow == "undefined")
			return (obj.style.display == "none") ? false : true;
		if ((bshow == 0) || (bshow == false))
			obj.style.display = "none";
		else
			obj.style.display = "inline";
	};

	this.insertHTML = function(tag, sWhere)
	{
		domObj.firstChild.rows[0].cells[0].insertAdjacentHTML(sWhere, tag);
	};

	this.getmenu = function(item)
	{
		if (typeof item == "undefined")
			return menudef;
		var obj = this.getDomItem(item);
		if (typeof obj == "object")
			return menudef[objattr(obj, "node")];
	};

	this.setmenutext = function(item, text)
	{
		var obj = this.getDomItem(item);
		menudef[objattr(obj, "node")].item = text;
		obj.innerHTML = text;
	};

	InitMenu();
}

//通用阴影对象
//
function CommonShadow(mode, param1, param2, oDoc)
{
var old, div;
	if (typeof oDoc == "undefined")
		oDoc = document.body;
	old = [];
	this.show = function(obj, bMulti)
	{
		if ((typeof obj != "object") || (obj == null))
			return this.hide();
		if ((old.length == 1) && (old[0].obj == obj))
			return;
		var len  = 0;
		switch (mode)
		{
		case 0:				//设置元素的背景色
			if ((bMulti != 1) && (bMulti != true))
				this.hide();
			len = old.length;
			old[len] = {};
			old[len].value = obj.style.backgroundColor
			obj.style.backgroundColor = param1;
			break;
		case 1:				//设置元素的CSS名称
			if ((bMulti != 1) && (bMulti != true))
				this.hide();
			len = old.length;
			old[len] = {};
			old[len].value = obj.className;
			obj.className = param1;
			break;
		case 2:				//创建一个被元素遮档的新元素,以实现光影
			if (typeof div != "object")
			{
				div = document.createElement("DIV");
				div.style.position = "absolute";
				div.style.backgroundColor = param1;
				div.style.filter = "progid:DXImageTransform.Microsoft.alpha(opacity=50) progid:DXImageTransform.Microsoft.Blur(pixelradius=" + 
					param2 + ")";
				oDoc.appendChild(div);
			}
			old[len] = {};
			div.style.zIndex = obj.style.zIndex - 1;
			var pos = GetObjPos(obj, oDoc);
			div.style.width = (pos.right - pos.left) + "px";
			div.style.height = (pos.bottom - pos.top) + "px";
			div.style.top = (pos.top - param2) + "px";
			div.style.left = (pos.left - param2) + "px";
			div.style.display = "block";
			break;
		case 3:				//创建一个被元素遮档的指定新元素
			if (typeof div != "object")
			{
				div = document.createElement("DIV");
				div.style.position = "absolute";
				div.innerHTML = param1;
				oDoc.appendChild(div);
			}
			old[len] = {};
			div.style.zIndex = obj.style.zIndex - 1;
			var pos = GetObjPos(obj, oDoc);
			div.style.width = (pos.right - pos.left) + "px";
			div.style.height = (pos.bottom - pos.top) + "px";
			div.style.top = pos.top + "px";
			div.style.left = pos.left + "px";
			div.style.display = "block";
		}
		old[len].obj = obj;
	};
		
	this.hide = function()
	{
		for (var x = 0; x < old.length; x++)
		{
			switch (mode)
			{
			case 0:
				old[x].obj.style.backgroundColor = old[x].value;
				break;
			case 1:
				old[x].obj.className = old[x].value;
				break;
			case 2:
			case 3:
				div.style.display = "none";
				break;
			}
		}
		old = [];
	};
	
	this.getObj = function()
	{
		if (old.length == 0)
			return;
		if (old.length == 1)
			return old[0].obj;
		return old;
	};
	
	this.getShadow = function ()
	{
		return old;
	}
	
	this.isShadow = function (obj)
	{
		for (var x = 0; x < old.length; x++)
		{
			if (obj == old[x].obj)
				return true;
		}
		return false;
	}
}

//自定义桌面对象
function Desktop(nMode, domObj)
{
var drag;
var self = this;
var root = document.body;
var css = "Widget";
	function getWidget(x, y)
	{
		var evt = getEvent();
		switch (typeof x)
		{
		case "object":
			return x;
		case "undefined":
			return evt.srcElement.parentNode.parentNode.parentNode.parentNode;
		case "string":
			return objall(domObj)[x];
		default:
			return domObj.childNodes[col].childNodes[row];
		}
	}

	function OverBtn()
	{
		var evt = getEvent();
		evt.srcElement.className = evt.srcElement.className.substr(0, evt.srcElement.className.length - 1) + "1";
	}

	function OutBtn()
	{
		var evt = getEvent();
		evt.srcElement.className = evt.srcElement.className.substr(0, evt.srcElement.className.length - 1) + "0";
	}

	
	function LayerDlg()
	{
		var text = "<div align=left style='padding:20px;'>" +
			"<span style=width:200px;><input name=layer type=radio value=3 style=vertical-align:top;margin-top:30px><table width=100px height=80 border=0 bgcolor=#ADD6F5 cellspacing=5 cellpadding=3 style=display:inline><td bgcolor=white></td><td bgcolor=white></td><td bgcolor=white></td></table></span>" +
			"<span style=width:120px><input name=layer type=radio value=2 style=vertical-align:top;margin-top:30px><table width=100px height=80 border=0 bgcolor=#ADD6F5 cellspacing=5 cellpadding=3 style=display:inline><td bgcolor=white></td><td bgcolor=white></td></table></span>" +
			"<br><br><span style=width:200px><input name=layer type=radio value=22 style=vertical-align:top;margin-top:30px><table width=100px height=80 border=0 bgcolor=#ADD6F5 cellspacing=5 cellpadding=3 style=display:inline><td width=33% bgcolor=white></td><td bgcolor=white></td></table></span>" +
			"<span style=width:120px><input name=layer type=radio value=12 style=vertical-align:top;margin-top:30px><table width=100px height=80 border=0 bgcolor=#ADD6F5 cellspacing=5 cellpadding=3 style=display:inline><td width=67% bgcolor=white></td><td bgcolor=white></td></table></span>" +
			"</div><hr size=1><div align=right style='margin-right:30px;'><input id=OKButton type=button value=确定 onclick=''>&nbsp;&nbsp;<input type=button value=取消 onclick=CloseInlineDlg()></div>"
		InlineHTMLDlg("更改自定义桌面版式", text, 380, 310);
		var oo = idobj("InDlgDiv").getElementsByTagName("INPUT");
		for (var x = 0; x < oo.length; x++)
		{
			if (oo[x].value == nMode)
				oo[x].checked = true;
		}
		objall(idobj("InDlgDiv"), "OKButton").onclick = setLayer;
	} 
	
	function setLayer(nLayer)
	{
		if (typeof nLayer == "undefined")
		{
			var oo = idobj("InDlgDiv").getElementsByTagName("INPUT");
//			var oo = objall(idobj("InDlgDiv"), "layer");
			for (var x = 0; x < oo.length; x++)
			{
				if (oo[x].checked)
					nLayer = parseInt(oo[x].value);
			}
		}
		changeLayer(nLayer);
		CloseInlineDlg();
		if (typeof self.desktopChange == "function")
			self.desktopChange("layerChange", null, nLayer);
	}
	
	this.minimize = function (x, y)
	{
	var widget, btn, body, evttype;
		widget = getWidget(x, y);
		btn = widget.firstChild.firstChild.lastChild.firstChild.nextSibling;
		body = widget.firstChild.lastChild;
		if (body.style.display == "none")
		{
			body.style.display = "block";
			btn.className = btn.className.replace("_Restore_", "_Minimize_");
			evttype = "restore";
		}
		else
		{
			body.style.display = "none";
			btn.className = btn.className.replace("_Minimize_", "_Restore_");
			evttype = "minimize";
		}
		if (typeof self.desktopChange == "function")
			self.desktopChange(evttype, widget);
	}
		
	this.close = function(x, y)
	{
		var o = getWidget(x, y);
		if (typeof self.desktopChange == "function")
			self.desktopChange("beforeClose", o);
		o.parentNode.removeChild(o);
	}

	function Drag()
	{
		var evt = getEvent();
		switch (evt.srcElement.tagName)
		{
		case "DIV":
			if (evt.srcElement.className.indexOf("_Toolbar") > 0)
				drag = evt.srcElement.parentNode.parentNode.parentNode;
			else
				drag = evt.srcElement.parentNode.parentNode;
			break;
		case "H5":
			drag = evt.srcElement.parentNode.parentNode.parentNode;
			break;
		default:
			return;
		}
		var pos = GetObjPos(drag);
		drag.style.border = "2px dashed gray";
		var status = self.getStatus(drag);
		var oDiv = document.createElement("div");
		oDiv.style.display = "block";
		oDiv.style.position = "absolute";
		oDiv.style.filter = "alpha(opacity=70)";
		oDiv.style.zIndex = 100;
		domObj.appendChild(oDiv);
		drag.style.height = pos.bottom - pos.top;
		oDiv.appendChild(drag.firstChild);
		oDiv.style.left = pos.left + "px";
		oDiv.style.top = pos.top + "px";
		oDiv.style.width = (pos.right - pos.left) + "px";
		var clickleft = evt.screenX - pos.left;
		var clicktop = evt.screenY - pos.top;
		var oTimer = null;
		var scrollHeight = root.scrollHeight + oDiv.clientHeight;
		function draging()
		{
			var evt = getEvent();
			oDiv.style.left = (evt.screenX - clickleft) + "px";
			oDiv.style.top = (evt.screenY - clicktop) + "px";
			if ((evt.y + 10 > root.clientHeight) || (evt.y < 10))
			{
				if ((oTimer == null) && ((root.scrollTop + root.clientHeight < scrollHeight) || (root.scrollTop > 0)))
				{
					var delta = 4;
					if (evt.y < 10)
						delta = -4;
					oTimer = window.setInterval(function()
					{
						root.scrollTop += delta;
						if (parseInt(oDiv.style.top) + delta > 0)
						{
							oDiv.style.top = (paseInt(oDiv.style.top) + delta) + "px";
							clicktop -= delta;
							if ((root.scrollTop + root.clientHeight >= scrollHeight) || (root.scrollTop == 0))
							{
								window.clearInterval(oTimer);
								oTimer = null;
							}
						}
					}, 40);
				}
			}
			else
			{
				if (oTimer != null)
				{
					window.clearInterval(oTimer);
					oTimer = null;
				}
			}
			evt.returnValue = false;
			for (var y = 0; y < domObj.childNodes.length; y++)
			{
				pos = GetObjPos(domObj.childNodes[y]);
				if ((evt.x >= pos.left) && (evt.x < pos.right))
				{
					for (var x = 0; x < domObj.childNodes[y].childNodes.length; x++)
					{
						pos = GetObjPos(domObj.childNodes[y].childNodes[x]);
						if (evt.y + root.scrollTop < pos.bottom - (pos.bottom - pos.top) / 2)
							return domObj.childNodes[y].childNodes[x].insertAdjacentElement("beforeBegin", drag);
					}
					return domObj.childNodes[y].appendChild(drag);
				}
			}
		}

		function dragend()
		{
			objevent(document, "mousemove", draging, 1);
			objevent(document, "mouseup", dragend, 1);
			if (oTimer != null)
			{
				window.clearInterval(oTimer);
				oTimer = null;
			}
			document.releaseCapture();
			drag.appendChild(oDiv.firstChild);
			drag.style.border = "none";
			drag.style.height = "auto";
			oDiv.parentNode.removeChild(oDiv);
			if (self.getStatus(drag) != status)
			{
				if (typeof self.desktopChange == "function")
					self.desktopChange("posChange", drag, status);
			}
			drag = 0;
			oDiv = 0;
		}
		objevent(document, "mousemove", draging);
		objevent(document, "mouseup", dragend);
		root.setCapture(true);	
	}

	this.createWidget = function(id, title, col, tag)
	{
		if (col >= domObj.childNodes.length)
			col = 0;
		var o = domObj.childNodes[col];
		
		o.insertAdjacentHTML("beforeEnd", "<div id=" + id + " style='width:100%;padding:2px 4px;'>" +
			"<div class=" + css + "_Box><div class=" + css + "_Titlebar><h5 style=float:left;>" + title +
			"</h5><div class=" + css + "_Toolbar><span class=" + css +
			"_Option_Button_0 style=visibility:hidden;></span><span class=" + css + "_Minimize_Button_0></span>" +
			"<span class=" + css + "_Close_Button_0></span></div></div><div></div></div></div>");
		switch (typeof tag)
		{
		case "string":
			o.lastChild.firstChild.lastChild.insertAdjacentHTML("beforeEnd", tag);
			break;
		case "object":
			o.lastChild.firstChild.lastChild.appendChild(tag);
			break;
		}
		o = o.lastChild.firstChild.firstChild.lastChild;
		o.parentNode.onmousedown = Drag;
		o.firstChild.onmouseover = OverBtn;
		o.firstChild.onmouseout = OutBtn;
		o.firstChild.onclick = WidgetOption;

		o.firstChild.nextSibling.onmouseover = OverBtn;
		o.firstChild.nextSibling.onmouseout = OutBtn;
		o.firstChild.nextSibling.onclick = this.minimize;

		o.lastChild.onmouseover = OverBtn;
		o.lastChild.onmouseout = OutBtn;
		o.lastChild.onclick = this.close;
		return o.parentNode.parentNode.parentNode;
	};

	this.setContext = function(widget, tag)
	{
		if (typeof widget == "object")
			widget.firstChild.lastChild.insertAdjacentHTML("beforeEnd", tag);
	};

	this.setOption = function(widget, menudef)
	{
		
	};
	
	function WidgetOption()
	{
	}
	
	this.Option = function()
	{
		var oMenuItems = [];
//		if (typeof self.setupWidgetDlg == "function")
//			oMenuItems[0] = {item:"设置", action:self.setupWidgetDlg};
//		oMenuItems[oMenuItems.length] = {};
		oMenuItems[oMenuItems.length] = {item:"更改版式", action:LayerDlg};
		if (typeof self.appendWidgetDlg == "function")
			oMenuItems[oMenuItems.length] = {item:"添加内容", action:self.appendWidgetDlg};
		oMenuItems[oMenuItems.length] = {item:"刷新", action:"location.reload(true);"};
				
		var oMenu = new CommonMenu(oMenuItems);
		oMenu.show();
	};
	
	this.getStatus = function(widget)
	{
		widget = getWidget(widget);
		if (typeof widget != "object")
			return 0002;
		for (var y = 0; y < domObj.childNodes.length; y++)
		{
			for (var x = 0; x < domObj.childNodes[y].childNodes.length; x++)
			{
				if (domObj.childNodes[y].childNodes[x] == widget)
				{
					if (widget.firstChild.lastChild.style.display == "none")
						return y * 1000 + x * 10 + 1;
					return y * 1000 + x * 10;
				}
			}
		}
		return -1;
	};

	function changeLayer(newMode)
	{
		var colold = nMode % 10;
		var colnew = newMode % 10;
		for (var x = 0; x < colnew - colold; x++)
			domObj.insertAdjacentHTML("beforeEnd", "<div style='float:right;width:33%;overflow-x:hidden;'></div>");
			
		for (var x = 0; x < colold - colnew; x++)
		{
			for (var y = domObj.childNodes[colnew + x].childNodes.length - 1; y >= 0; y--)
				domObj.childNodes[0].appendChild(domObj.childNodes[colnew + x].childNodes[y]);
			domObj.removeChild(domObj.childNodes[colnew + x]);	
		}
		switch (newMode)
		{
		case 1:
			domObj.childNodes[0].style.width = "100%";
			break;
		case 2:
			domObj.childNodes[0].style.width = "50%";
			domObj.childNodes[1].style.width = "50%";
			break;
		case 3:
			domObj.childNodes[0].style.width = "33%";
			domObj.childNodes[1].style.width = "34%";
			domObj.childNodes[2].style.width = "33%";
			break;
		case 12:
			domObj.childNodes[0].style.width = "66%";
			domObj.childNodes[1].style.width = "34%";
			break;
		case 22:
			domObj.childNodes[0].style.width = "34%";
			domObj.childNodes[1].style.width = "66%";
			break;
		}
		nMode = newMode;
	}

	if (typeof domObj != "object")
		domObj = root;
	switch (nMode)
	{
	case 1:
		domObj.insertAdjacentHTML("beforeEnd", "<div style='float:left;width:100%;overflow-x:hidden;overflow-y:visible;'></div>");
		break;
	case 2:
		domObj.innerHTML = "<div style='float:left;width:50%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:50%;overflow-x:hidden;overflow-y:visible;'></div>";
		break;
	case 3:
		domObj.innerHTML = "<div style='float:left;width:33%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:34%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:33%;overflow-x:hidden;overflow-y:visible;'></div>";
		break;
	case 12:
		domObj.innerHTML = "<div style='float:left;width:66%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:34%;overflow-x:hidden;overflow-y:visible;'></div>";
		break;
	case 13:
		domObj.innerHTML = "<div style='float:left;width:40%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:40%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:20%;overflow-x:hidden;overflow-y:visible;'></div>";
		break;
	case 22:
		domObj.innerHTML = "<div style='float:left;width:34%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:64%;overflow-x:hidden;overflow-y:visible;'></div>";
		break;
	case 23:
		domObj.innerHTML = "<div style='float:left;width:20%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:40%;overflow-x:hidden;overflow-y:visible;'></div>" +
			"<div style='float:left;width:40%;overflow-x:hidden;overflow-y:visible;'></div>";
		break;
	}
}


//日历牌对象
function CalendarBase(tday, domobj, lunarDis)
{
	var self = this;
	var oDiv, year, month, day, oSel, mode = 0;
	this.show = function(d)
	{
		InitDate(d);
		var daytext = "";
		var today = new Date();
		var mday = new Date(tday.getTime());
		mday.setDate(1);
		var ww = mday.getDay();
		var lunar;
		var tag = "<tr>";
		for (var x = 0; x < ww; x++)
			tag += "<td id=weekday" + x + "></td>";
		if ((typeof lunarDis == "undefined") || (lunarDis == false))
			lunar = new LunarDate(mday);
		while (month == mday.getMonth() + 1)
		{
			if (ww == 0)
				tag += "</tr><tr>";
			if (typeof lunar == "object")
			    daytext = "<div class=\"day\" style=\"display:block;font:9px 微软雅黑;color:gray;\">" + 
					 lunar.toString(3) + "</div>";
			tag += "<td id=weekday" + x + " node=" + mday.getDate() + ">";
			if ((mday.getDate() == today.getDate()) && (mday.getFullYear() == today.getFullYear())
				&&(mday.getMonth() == today.getMonth()))	
				tag += "<b>" +  mday.getDate() + daytext + "</b></td>";
			else
				tag += mday.getDate() + daytext + "</td>";
					
			mday.setDate(mday.getDate() + 1);
			if (typeof lunar == "object")
				lunar.setLunar(mday);
			ww = mday.getDay();
		}
		if (ww > 0)
		{
			for (x = ww; x < 7; x++)
				tag += "<td id=weekday" + x + "></td>";
		}
		ShowTitle(tday.getFullYear(), month);
		oDiv.innerHTML = "<table border=0 cellpadding=0 cellspacing=0 style=width:100%;height:100%;><tr><th id=week0>日</th><th id=week1>一</th>" +
			"<th id=week2>二</th><th id=week3>三</th><th id=week4>四</th><th id=week5>五</th><th id=week6>六</th></th>" + tag + "</tr></table>";
		oSel = new CommonShadow(0, "#f4b77e");
		if (typeof this.onReady == "function")
			this.onReady();
	};

	function InitDate(d)
	{
		if (typeof d != "undefined")
			tday = d;
		if ((typeof tday == "string") && (tday != ""))
			tday = GetDate(tday);

		if ((typeof tday != "object") || isNaN(tday))
			tday = new Date();
		year = tday.getFullYear();
		month = tday.getMonth() + 1;
		day = tday.getDate();
	}
	
	function ShowTitle(year, month)
	{
		objall(domobj, "YearSpan").innerHTML = year;
		if ((typeof month == "undefined") || (month == 0))
			objall(domobj, "MonthTag").style.display = "none";
		else
		{
			objall(domobj, "MonthTag").style.display = "inline";
			objall(domobj, "MonthSpan").innerHTML = month;
		}
	}
	
	function ClickTitle()
	{
		var evt = getEvent();
		switch (evt.srcElement.id)
		{
		case "DecMonth":
			switch (mode)
			{
			case 0:
				InitDate(year + "-" + (month - 1) + "-" + day);
				break;
			case 1:
				InitDate((year - 1) + "-" + month + "-" + day);
				break;
			case 2:
				InitDate((year - 20) + "-" + month + "-" + day);
				break;
			}
//			oDiv.filters[0].Motion = "forward";
//			oDiv.filters[0].apply();
			ShowAll(mode);
//			oDiv.filters[0].play();
			break;
		case "AddMonth":
			switch (mode)
			{
			case 0:
				InitDate(year + "-" + (month + 1) + "-" + day);
				break;
			case 1:
				InitDate((year + 1) + "-" + month + "-" + day);
				break;
			case 2:
				InitDate((year + 20) + "-" + month + "-" + day);
				break;
			}
//			oDiv.filters[0].Motion = "reverse";
//			oDiv.filters[0].apply();
			ShowAll(mode);
//			oDiv.filters[0].play();
			break;
		case "MonthSpan":
			ShowAll(1);
			break;
		case "YearSpan":
		default:
			ShowAll(2);
			break;
		}
	}
	
	function ShowAll(m)
	{
		var tag, y;
		mode = m;
		switch (mode)
		{
		case 0:
			self.show();
			return;
		case 1:
			ShowTitle(year);
			tag = "<tr><td>一月</td><td>二月</td><td>三月</td><td>四月</td></tr>" +
				"<tr><td>五月</td><td>六月</td><td>七月</td><td>八月</td></tr>" +
				"<tr><td>九月</td><td>十月</td><td>十一月</td><td>十二月</td></tr>";
			break;
		case 2:
			var y0 = year - year % 20;
			ShowTitle(y0 + "-" + (y0 + 19));
			for (tag = "", y = y0; y < y0 + 20; y += 4)
				tag += "<tr><td>" + y + "</td><td>" + (y + 1) + "</td><td>" + (y + 2) + "</td><td>" + (y + 3) + "</td></tr>";
			break;
		}
		oDiv.innerHTML = "<table border=0 cellpadding=0 cellspacing=0 style=width:100%;>" + tag + "</table>";
		var all = objall(oDiv);
		for (var x = 0; x < all.length; x++)
			all[x].UNSELECTABLE = "on";
	}
	
	function ClickTable()
	{
		var evt = getEvent();
		if (objattr(evt.srcElement, "node") == "")
			return;
		var obj;
		if (evt.srcElement.tagName == "TD")
			 obj = evt.srcElement;
		if (evt.srcElement.parentNode.tagName == "TD") 
			obj = evt.srcElement.parentNode;
		if (typeof obj != "object")
			return;
		oSel.show(obj);
		switch (mode)
		{
		case 0:
			day = objattr(obj, "node");
			if (typeof self.clickDate == "function")
				self.clickDate(year + "-" + month + "-" + day, obj);
			break;
		case 1:
			InitDate(year + "-" + (obj.parentNode.rowIndex * 4 + obj.cellIndex + 1) + "-" + day);
			ShowAll(0);
			break;
		case 2:
			year = parseInt(obj.innerHTML);
			ShowAll(1);
			break;
		}
	}
	
	this.setDateCellProp = function(d, item, value)
	{
		var o = this.getCellObject(d);
		if (o != null)
		{
			if (item.substr(0, 1) == "."){
				// w3c no support style.setAttribute lxt 2017.2.25
				if(o.style.setAttribute)
					o.style.setAttribute(item.substr(1), value);
				else o.style[item.substr(1)]=value;
			}else{
				o.setAttribute(item, value);
			}
		}
	};
	
	this.getDateCellProp = function(d, item)
	{
		var o = this.getCellObject(d);
		if (o != null)
		{
			if (item.substr(0, 1) == ".")
				return o.style.getAttribute(item.substr(1));
			else
				return o.getAttribute(item);
		}
	};
	
	this.getCellObject = function(d)
	{
		if (typeof d == "string")
			d = GetDate(d);
		var rows = oDiv.firstChild.rows;
		for (var y = 0; y < rows.length; y++)
		{
			for (var x = 0; x < rows[y].cells.length; x++)
			{
				if (d.getDate() == objattr(rows[y].cells[x], "node"))
					return rows[y].cells[x];
			}
		}
		return null;
	};
		
	this.getDate = function()
	{
		return new Date(year, month - 1, day);
	};
	
	this.selDateCell = function(d)
	{
		var o = this.getCellObject(d);
		if (o != null)
			oSel.show(o);
	};

	function Init()
	{
		if (typeof domobj != "object")
			return;
		domobj.innerHTML = "<div id=TitleDiv><span title=后退 id=DecMonth style=font-family:webdings;cursor:hand;>3</span>&nbsp;" +
			"<span id=YearSpan style='color:#000;'></span>年<span id=MonthTag><span id=MonthSpan style='color:#000;'></span>月</span>&nbsp;" +
			"<span id=AddMonth title=前进 style=font-family:webdings;cursor:hand;>4</span></div><div style='margin-top:-20px;padding-top:20px;" +
			"overflow:hidden;height:100%;filter:progid:DXImageTransform.Microsoft.GradientWipe(GradientSize=0.00,wipestyle=0,motion=c)'></div>";
		oDiv = domobj.lastChild;
		oDiv.onclick = ClickTable;
		domobj.firstChild.onclick = ClickTitle;
	}
	Init();
}

//农历对象
function LunarDate(dateobj)
{
	if (typeof LunarDate.TermData == "undefined")
	{
		LunarDate.TermData = [0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989,
		    308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758];

		LunarDate.lunarInfo = [0x4bd8, 0x4ae0, 0xa570, 0x54d5, 0xd260, 0xd950, 0x5554, 0x56af,
			0x9ad0, 0x55d2, 0x4ae0, 0xa5b6, 0xa4d0, 0xd250, 0xd255, 0xb54f, 0xd6a0, 0xada2,
			0x95b0, 0x4977, 0x497f, 0xa4b0, 0xb4b5, 0x6a50, 0x6d40, 0xab54, 0x2b6f, 0x9570,
			0x52f2, 0x4970, 0x6566, 0xd4a0, 0xea50, 0x6a95, 0x5adf, 0x2b60, 0x86e3, 0x92ef,
			0xc8d7, 0xc95f, 0xd4a0, 0xd8a6, 0xb55f, 0x56a0, 0xa5b4, 0x25df, 0x92d0, 0xd2b2,
			0xa950, 0xb557, 0x6ca0, 0xb550, 0x5355, 0x4daf, 0xa5b0, 0x4573, 0x52bf, 0xa9a8,
			0xe950, 0x6aa0, 0xaea6, 0xab50, 0x4b60, 0xaae4, 0xa570, 0x5260, 0xf263, 0xd950,
			0x5b57, 0x56a0, 0x96d0, 0x4dd5, 0x4ad0, 0xa4d0, 0xd4d4, 0xd250, 0xd558, 0xb540,
			0xb6a0, 0x95a6, 0x95bf, 0x49b0, 0xa974, 0xa4b0, 0xb27a, 0x6a50, 0x6d40, 0xaf46,
			0xab60, 0x9570, 0x4af5, 0x4970, 0x64b0, 0x74a3, 0xea50, 0x6b58, 0x5ac0, 0xab60,
			0x96d5, 0x92e0, 0xc960, 0xd954, 0xd4a0, 0xda50, 0x7552, 0x56a0, 0xabb7, 0x25d0,
			0x92d0, 0xcab5, 0xa950, 0xb4a0, 0xbaa4, 0xad50, 0x55d9, 0x4ba0, 0xa5b0, 0x5176,
			0x52bf, 0xa930, 0x7954, 0x6aa0, 0xad50, 0x5b52, 0x4b60, 0xa6e6, 0xa4e0, 0xd260, 
			0xea65, 0xd530, 0x5aa0, 0x76a3, 0x96d0, 0x4afb, 0x4ad0, 0xa4d0, 0xd0b6, 0xd25f,
			0xd520, 0xdd45, 0xb5a0, 0x56d0, 0x55b2, 0x49b0, 0xa577, 0xa4b0, 0xaa50, 0xb255,
			0x6d2f, 0xada0, 0x4b63, 0x937f, 0x49f8, 0x4970, 0x64b0, 0x68a6, 0xea5f, 0x6b20,
			0xa6c4, 0xaaef, 0x92e0, 0xd2e3, 0xc960, 0xd557, 0xd4a0, 0xda50, 0x5d55, 0x56a0,
			0xa6d0, 0x55d4, 0x52d0, 0xa9b8, 0xa950, 0xb4a0, 0xb6a6, 0xad50, 0x55a0, 0xaba4,
			0xa5b0, 0x52b0, 0xb273, 0x6930, 0x7337, 0x6aa0, 0xad50, 0x4b55, 0x4b6f, 0xa570,
			0x54e4, 0xd260, 0xe968, 0xd520, 0xdaa0, 0x6aa6, 0x56df, 0x4ae0, 0xa9d4, 0xa4d0, 
			0xd150, 0xf252, 0xd520];

		LunarDate.chMonth = "正二三四五六七八九十冬腊";
		LunarDate.chDate = "初一初二初三初四初五初六初七初八初九初十十一十二十三十四十五十六十七十八十九二十廿一廿二廿三廿四廿五廿六廿七廿八廿九三十";
		LunarDate.TianGan = "甲乙丙丁戊己庚辛壬癸";
		LunarDate.DiZhi = "子丑寅卯辰巳午未申酉戌亥";
		LunarDate.Animals = "鼠牛虎兔龙蛇马羊猴鸡狗猪";
		LunarDate.TermName = "小寒大寒立春雨水惊蛰春分清明谷雨立夏小满芒种夏至小暑大暑立秋处暑白露秋分寒露霜降立冬小雪大雪冬至";
	}
	var year, month, isLeap, day, term, sterm;

	function lYearDays(y)	//传回农历 y年的总天数
	{  
		var sum = 348;
		for (var x = 0x8000; x > 0x8; x >>= 1) 
			sum += (LunarDate.lunarInfo[y - 1900] & x) ? 1: 0;
 		return sum + leapDays(y);
	}

	function leapDays(y)	//传回农历 y年闰月的天数
	{
		if (leapMonth(y) == 0)
			return 0;
		return ((LunarDate.lunarInfo[y - 1899] & 0xf) == 0xf) ? 30 : 29;
	}



	function leapMonth(y)	//传回农历 y年闰哪个月 1-12 , 没闰传回 0
	{
		var rtn = LunarDate.lunarInfo[y - 1900] & 15;
		if (rtn == 15)
			return 0;
		return rtn;
	}

	function monthDays(y, m)	//传回农历 y年m月的总天数
	{
		return (LunarDate.lunarInfo[y - 1900] & (0x10000 >> m)) ? 30: 29;
	}

	function toDate(dt)
	{
		if (typeof dt == "object")
			return dt;
		if (typeof dt == "string")
		{
			var ss = dt.split("-");
			if (ss.length > 2)
				return new Date(ss[0], parseInt(ss[1]) - 1, ss[2]);
		}
		return new Date();
	}

	this.setLunar = function(dt)
	{
		var leap = 0, temp, x;
		dt = toDate(dt);
//	   	if ((dt.getFullYear() < 1900) || (dt.getFullYear() > 2100))
//			return;
		var baseDate = new Date(1900,0,31);
		var offset = parseInt((dt - baseDate) / 86400000);	//24*3600*1000 = 86400000

		this.dayCyl = offset + 40;
		this.monCyl = 14;
		dateobj = dt;

		for (var x = 1900; x < 2100 && offset > 0; x ++)
		{
			temp = lYearDays(x);
			offset -= temp;
			this.monCyl += 12;
		}
		if (offset < 0)
		{
		 	offset += temp;
			x --;
			this.monCyl -= 12;
		}
		year = x;
//		this.yearCyl = x - 1864;

	   leap = leapMonth(x); //闰哪个月
	   isLeap = false;

		for (x = 1; x < 13 && offset > 0; x ++)
		{	//闰月
			if (leap > 0 && x == (leap + 1) && isLeap == false)
			{
				x --;
				isLeap = true;
				temp = leapDays(year);
			}
			else
				temp = monthDays(year, x);

			//解除闰月
			if (isLeap == true && x == (leap + 1))
				isLeap = false;

			offset -= temp;
//			if (this.isLeap == false)
//				this.monCyl ++;
		}

 		if (offset == 0 && leap > 0 && x == leap + 1)
 		{
      		if(isLeap)
				isLeap = false;
			else
			{
				isLeap = true;
				x --;
//				this.monCyl --;
			}
		}
		if (offset < 0)
		{
			offset += temp;
			x --;
//			this.monCyl --;
		}

		month = x;
		day = offset + 1;
		term = 0;
		sterm = "";
		offset = dateobj.getMonth() * 2;
		for (x = offset; x < offset + 2; x++)
		{
			temp = (31556925974.7 * (dateobj.getFullYear() - 1900) + LunarDate.TermData[x] * 60000);
			baseDate = new Date(1900, 0, 6, 2, 5);
			baseDate.setTime(baseDate.getTime() + temp);
			if (baseDate.getDate() == dateobj.getDate())
			{
				term = x + 1;
				sterm = LunarDate.TermName.substring(x * 2, term * 2);
				break;
			}
		}
	};

	this.toString = function (nType)
	{
		if ((dateobj.getFullYear() < 1900) || (dateobj.getFullYear() > 2100))
			return "";
		switch (nType)
		{
		case 1:			//年月日
			return LunarDate.TianGan.substring((year - 1864) % 10, (year - 1864) % 10 + 1) + 
				LunarDate.DiZhi.substring((year - 1864) % 12, (year - 1864) % 12 + 1) +
				"年 " + LunarDate.chMonth.substring(month - 1, month) + "月 " +
				LunarDate.chDate.substring(day * 2 - 2, day * 2);
		case 2:			//月日
			return LunarDate.chMonth.substring(month - 1, month) + "月 " +
				LunarDate.chDate.substring(day * 2 - 2, day * 2);
		case 3:			//(节气/月/日)
			if (sterm != "")
				return sterm;
			if (day == 1)
				return LunarDate.chMonth.substring(month - 1, month) + "月";
			return LunarDate.chDate.substring(day * 2 - 2, day * 2);
		default:		//年 属相 月 日 节气
			return LunarDate.TianGan.substring((year - 1864) % 10, (year - 1864) % 10 + 1) + 
				LunarDate.DiZhi.substring((year - 1864) % 12, (year - 1864) % 12 + 1) +
				"年 属相:" + LunarDate.Animals.substring((year - 1864) % 12, (year - 1864) % 12 + 1) +
				" " + LunarDate.chMonth.substring(month - 1, month) + "月 " +
				LunarDate.chDate.substring(day * 2 - 2, day * 2) + sterm;
		}
	};
	this.setLunar(dateobj);
} 

function GridView(domobj, head, data, info, cfg)
{
var self = this;
var dragobj, dragindex, dragdelta, evtobj, dragparam;
var headmenu, rollshadow, selshadow, quirks = 0;
var expic = [".TreeArrawOpen", ".TreeArrawClose"];
var headtdtmp;

	function createGrid()
	{
		if (typeof head != "object")
			return;
		var tag = "<div id=_GridDiv style='width:100%;height:100%;overflow:hidden;'>" +
			"<div id=HeadDiv style='width:100%;overflow:hidden;background-color:#78BCED'>" +
			"<table id=FieldsHead cellpadding=0 cellspacing=0 border=0 class=gridhead>";
		tag += "<tr id=HeadTR>";
		if (cfg.bodystyle == 2)
			tag += "<td nowrap align=center><div style=width:20px><input type=checkbox></div></td>";
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].nWidth == 0)
				head[x].nWidth = 100;
			if ((head[x].nShowMode == 1) || (head[x].nShowMode == 7) || (head[x].nShowMode == 9))
			{
				tag += "<td nowrap node=" + head[x].FieldName + "><div style=width:" + head[x].nWidth + "px;overflow:hidden;>" + head[x].TitleName + "</div></td>";
			}
		}
		tag += "<td nowrap style='width:100%'><div style=width:30px></div></td></tr></table></div><div style='height:100%;overflow:hidden'>" +
			"<div id=BodyDiv class=gridbodycontainer style=width:100%;height:100%;overflow:auto;>" +
			"<table id=BodyTable height=100% cellpadding=3 cellspacing=1 border=0 bgcolor=#DDDDDD>";
		domobj.innerHTML = tag + "</table></div></div>" + getfoot() + "</div>";
		objall(domobj, "_GridDiv").onresize = scroll;
		objall(domobj, "FieldsHead").onclick = click;
		objall(domobj, "FieldsHead").ondblclick = dblclick;
		objall(domobj, "FieldsHead").onmousedown = mousedown;
		objall(domobj, "FieldsHead").onmouseover = rollgrid;
		if (objall(domobj, "PageSkip") != null)
			objall(domobj, "PageSkip").onclick = clickFoot;
		if (objall(domobj, "PageFootSel") != null)
			objall(domobj, "PageFootSel").onchange = clickFoot;
		if (cfg.headstyle == 1)
			objall(domobj, "FieldsHead").oncontextmenu = showheadmenu;
		setheadorder();
		self.reload(data);
		var h = objall(domobj, "HeadDiv").clientHeight;
		if (objall(domobj, "PageFoot") != null)
			h += objall(domobj, "PageFoot").clientHeight;
		objall(domobj, "_GridDiv").style.paddingBottom = (h + 3) + "px";
	}

	function createTable()
	{
		var tag = "<div style='width:100%;height:100%;padding-bottom:25px;overflow:hidden'><div style=width:100%;height:100%;overflow:auto>" +
			"<table id=SeekTable width=100% height=100% cellpadding=3 cellspacing=0 border=0>";
		tag += "<tr id=SeekTitleTR>"; 
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].nShowMode == 1)
				tag += "<td node=" + head[x].FieldName + ">" + head[x].TitleName + "</td>";
		}
		tag += "</tr>" + getbody(cfg.gridstyle);
		domobj.innerHTML = tag +"</table></div>" + getfoot() + "</div>";
		objall(domobj, "SeekTable").onclick = click;
		objall(domobj, "SeekTable").onmouseover = rollgrid;
	}

	function getbody(nStyle, items, depth, node)
	{
		var tag = "", divstyle = "";
		var bk = ["white"];
		if (typeof cfg.bodybkcolor == "string")
			bk = cfg.bodybkcolor.split(",");
		var fg = "black";
		if (typeof cfg.bodycolor == "string")
			fg = cfg.bodycolor;
		var hint, tds, nowrap = " nowrap";
		if (cfg.nowrap == 0)
			nowrap = "";
		if (typeof items != "object")
			items = data;
		if (typeof depth != "number")
			depth = 0;
		if (depth > 0)
			divstyle = "padding-left:" + depth * cfg.nIndent + "px;";
		if ((node == "") || (typeof node == "undefined"))
			node = "";
		else
			node += ",";
		var treeflag = 0;
		for (var y = 0; y < items.length; y++)
		{
			hint = "";
			tds = "";
			for (var x = 0; x < head.length; x++)
			{
				var value = items[y][head[x].FieldName];
				if ((cfg.transText > 0) && (typeof items[y][head[x].FieldName + "_ex"] != "undefined"))
				{
					if (cfg.transText == 1)
						value = items[y][head[x].FieldName + "_ex"];
					else
						value = value + ":" + items[y][head[x].FieldName + "_ex"];
				}
				switch (head[x].nShowMode)
				{
				case 1:			//标题
				case 7:			//转义
				case 9:			//树型
					if (((head[x].nShowMode != 9) && (head[x].bTag != 1)) || (typeof items[y].child != "object"))
					{
						tds += getTDTag(value, x, nStyle, fg, nowrap, "");
						break;
					}
					treeflag = 1;
					var index = 0;
					if (depth >= cfg.initDepth - 1)
						index = 1;
					var ex = "<img id=BtExTree ex=" + index + " unloadflag=" + index + " src=" + expic[index] + ">&nbsp;";
					if (expic[0].substr(0, 1) == ".")
						ex = "<span id=BtExTree ex=" + index + " unloadflag=" + index + " class=" + expic[index].substr(1) + "></span>";
					if (typeof value == "object")
						value.value = ex + value.value;
					else
						value = ex + value;
					tds += getTDTag(value, x, nStyle, fg, nowrap, divstyle);
					break;
//					else
//						tds += getTDTag(value, x, nStyle, fg, nowrap, divstyle);
//					break;
				case 2:			//内文
					break;
				case 3:			//注释
					hint += head[x].TitleName + ":" + value + "\n";
					break;
				case 4:			//禁止
					break;
				case 5:			//浮窗
					break;
				case 6:			//隐藏
					break;
				case 8:			//附属
					break;
				}
			}
			if (cfg.bodystyle == 2)
				tds = "<td nowrap align=center><div style=width:20px><input type=checkbox></div></td>" + tds;
			var c = bk[y % bk.length];
			if (typeof items[y]._lineControl == "object")
			{
				items[y]._lineControl = FormatObjvalue({bgcolor:"white"}, items[y]._lineControl);
				c = items[y]._lineControl.bgcolor;
			}
			tag += "<tr node=" + (node + y) + " bgcolor=" + c + " title=\"" + hint + "\">" + tds + "</tr>";
			if ((treeflag == 1) && (typeof items[y].child == "object") && (depth < cfg.initDepth - 1))
				tag += getbody(nStyle, items[y].child, depth + 1, node + y);
		}
		return tag;
	}

	function getTDTag(value, x, nStyle, color, nowrap, divstyle)
	{
		if (typeof value == "undefined")
			return "";
		if (typeof value == "object")
		{
			value = FormatObjvalue({value:"", colspan:1, rowspan:1, tdstyle:""}, value);
			var tag = "<td" + nowrap + " colspan=" + value.colspan + " rowspan=" + value.rowspan;
			if (value.tdstyle != "")
				tag += " style=" + value.tdstyle;
			tag += " id=" + head[x].FieldName + "_TD>";
			if ((value.colspan > 1) || (value.rowspan > 1))
				quirks = 1;
			value = value.value;
		}
		else
			var tag = "<td" + nowrap + " id=" + head[x].FieldName + "_TD>";
		if (nStyle == 1)
			tag += "<div style=\"width:" + head[x].nWidth + "px;color:" +
				color + ";overflow-x:hidden;" + divstyle + "\">" + getvalue(value, head[x].exp) + "</div></td>";
		else
			tag += value + "</td>";
		return tag;
	}
	
	function getvalue(value, exp)
	{
		if (typeof exp == "function")
			return exp(value);

		if (typeof exp == "string")
		{
			switch (exp.substr(0, 1))
			{
			case "&":
				if (exp.substr(1, 1) == "d")
				{
					var d = GetDate(value);
					switch (exp.substr(3,1))
					{
					case "1":
						return d.getYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
					case "2":
						return d.getYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate() +
							" " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds();
					case "3":
						return d.getYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate() +
							" " + d.getHours() + ":" + d.getMinutes();
					case "4":
						return d.getHours() + ":" + d.getMinutes();
					}
				}
				break;
			case "(":
				exp = exp.substr(1, exp.length - 2);
			default:
				var ss = exp.split(",");
				for (var x = 0; x < ss.length; x++)
				{
					var sss = ss[x].split(":");
					if (value == sss[0])
						return sss[1];
				}
			}
		}
		return value;
	}

	function getfoot()
	{
		if (cfg.footstyle > 3)
			return "";
		var nPages = parseInt((info.Records + info.PageSize - 1)/ info.PageSize);
		var div = "<div id=PageFoot style='height:25px;padding-top:4px'>";
		if (nPages <= 1)
			return div + "&nbsp;共" + info.Records + "条</div>";
		var d1 = "";
		
        var d2 = "<span style=width:40px;overflow:hidden><select name=PageFootSel style=width:60px;margin:-2px;'>";
		for (var x = 1; x <= nPages; x++)
		{
			if (x == info.nPage)
				d2 += "<option value=" + x + " selected>" + x + "</option>";
			else
				d2 += "<option value=" + x + ">" + x + "</option>";
		}
		d2 += "</select></span>";
		
		switch (cfg.footstyle)
		{
		case 0:
			var nStart, nEnd;
				nStart = info.nPage - 5;
				if (nStart < 1)
					nStart = 1;
				nEnd = nStart + 9;
				if (nEnd > nPages)
				{
					nEnd = nPages;
					nStart = nEnd - 9;
					if (nStart < 1)
						nStart = 1;
				}
				for (x = nStart; x <= nEnd; x++)
				{
					if (x == info.nPage)
						d1 += "<span class=PageSpan style='border:1px solid transparent;'>" + x + "</span>";
					else
						d1 += "<span class=PageSpan style='color:gray;' node=" + x + ">" + x + "</span>";
				}
				if (info.nPage > 1)
					d1 = "<span class=PageSpan style='font-family:webdings;' node=" + (info.nPage - 1) + ">3</span>" + d1;
				if (info.nPage < nPages)
					d1 += "<span class=PageSpan style='font-family:webdings;' node=" + (info.nPage + 1) + ">4</span>";
				if (nStart > 1)
					d1 = "<span class=PageSpan style='font-family:webdings;' node=1>7</span>" + d1;
				if (nEnd < nPages)
					d1 += "<span class=PageSpan style='font-family:webdings;' node=" + nPages + ">8</span>";
				d1 = "<span id=PageSkip>" + d1 + "</span>";
				break;
		case 1:
		case 2:
			break;
		}
			return div + "<div style=float:left>&nbsp;页次：" + d2 + "&nbsp每页" + info.PageSize + 
				"条，共" + nPages + "页，" + info.Records +"条</div><div style=float:right>" + d1 + "</div></div>";
	}
	
	function clickFoot()
	{
		var evt = getEvent();
		if (evt.srcElement.tagName == "SELECT")
			return self.pageskip(evt.srcElement.value);
		if (objattr(evt.srcElement, "node") == null)
			return;
		self.pageskip(objattr(evt.srcElement, "node"));
	}
	
	function showheadmenu()
	{
		var evt = getEvent();
		if (evt.shiftKey)
			return;
		if (typeof headmenu != "object")
		{
			var menudef = [{item:"从小到大排序", img:"<span>↓</span>", action:selorder, node:0},{item:"从大到小排序", img:"<span>↑</span>", action:selorder, node:1}, {}];
			for (var x = 0; x < head.length; x++)
			{
				menudef[x + 3] = {};
				menudef[x + 3].item = head[x].TitleName;
				menudef[x + 3].img = "<input type=checkbox";
				if ((head[x].nShowMode == 1) || (head[x].nShowMode == 7))
					menudef[x + 3].img += " checked";
				menudef[x + 3].img += ">";
				menudef[x + 3].action = hidecol;
				menudef[x + 3].FieldName = head[x].FieldName;
			}
			headmenu = new CommonMenu(menudef);
		}
		headtdtmp = FindParentObject(evt.srcElement, domobj, "TD");
		headmenu.show();
		return false;
	}
	
	
	function selorder(obj, item)
	{
		if (typeof headtdtmp != "object")
			return;
		self.orderField(headtdtmp.node, item.node);
	}
	
	function setheadorder()
	{
		var cells = objall(domobj, "FieldsHead").rows[0].cells;
		for (var x = 0; x < cells.length; x++)
		{
			var text = cells[x].firstChild.innerHTML.replace(/[↓↑]/, "");
			if (objattr(cells[x], "node") == info.Order)
			{
				if (info.bDesc == 1)
					text += "↑";
				else
					text += "↓";
			}
			cells[x].firstChild.innerHTML = text;
		}
	}
	
	function hidecol(obj, item)
	{
		var index = sethead(item.FieldName);
		if (head[index].nShowMode == 1)
		{
			item.img = "<input type=checkbox>";
			head[index].nShowMode = 3;
		}
		else
		{
			item.img = "<input type=checkbox checked>";
			head[index].nShowMode = 1;
		}
		init();
	}

	function scroll()
	{
		objall(domobj, "HeadDiv").scrollLeft = objall(domobj, "BodyDiv").scrollLeft;
	}
	
	function rollgrid()
	{
		var evt = getEvent();
		if (evt.srcElement.tagName == "TD")
		{
			var pos = GetObjPos(evt.srcElement);
			if (evt.clientX >= pos.right - 2)
				evt.srcElement.style.cursor = "col-resize";
			else
				evt.srcElement.style.cursor = "default";
			if (evt.srcElement.firstChild.scrollWidth > evt.srcElement.firstChild.offsetWidth)
				evt.srcElement.title = evt.srcElement.firstChild.innerHTML;
			else
				evt.srcElement.removeAttribute("title");
		}
		else
			evt.srcElement.style.cursor = "default";
		
		var td = FindParentObject(evt.srcElement, domobj, "TD");
		if (typeof td != "object")
			return; 
		if ((td.parentNode.id != "SeekTitleTR") && (td.parentNode.id != "HeadTR"))
			self.overRow(td);
	}
	
	function mousedown()
	{
		var evt = getEvent();
		evtobj = evt.srcElement;
		if (evtobj.style.cursor != "col-resize")
		{
			if ((evtobj.parentNode.parentNode.id == "HeadTR") && (evt.shiftKey == false))
			{
				if (sethead(objattr(evtobj.parentNode, "node")) >= 0)
				{
					dragdelta = 0;
					objevent(document, "mousemove", draghead);
					objevent(document, "mouseup", dragheadend);
				}
			}
			if (cfg.bodystyle == 3)	//拖动多选
			{
				objevent(document, "mouseup", selearea);
				
			}
			return false;
		}
		if (evtobj.parentNode.id == "HeadTR")
			dragindex = evtobj.cellIndex;
		else
			dragindex = sethead(evtobj.id.substr(0, evtobj.id.length - 3));
		var pos = GetObjPos(domobj);
		var h = pos.bottom - pos.top;
		if (cfg.footstyle > 0)
			h -= 25;
		dragobj = document.createElement("<div style=position:absolute;width:1px;background-color:gray;overflow:hidden;left:" +
			evt.clientX + ";top:" + pos.top + ";height:" + h + ";cursor:col-resize></div>");
		dragobj.setCapture();
		document.body.insertBefore(dragobj, null);
		objevent(document, "onmousemove", splitting);
		objevent(document, "mouseup", splitend);
	}
	
	function draghead()
	{
		if ((dragdelta < 5) && (typeof dragobj != "object"))
		{
			dragdelta ++;
			return false;
		}
		var evt = getEvent();
		if (typeof dragobj != "object")
		{
			var pos = GetObjPos(evtobj.parentNode);
			dragobj = document.createElement("<div style='position:absolute;background-color:#78BCED;width:" +
				(pos.right - pos.left) + "px;height:" + (pos.bottom - pos.top) + "px;top:" +
				pos.top + "px;left:" + pos.left + "px;overflow:hidden;border:1px solid gray;'></div>");
			document.body.insertBefore(dragobj, null);
			dragobj.innerHTML = evtobj.innerHTML;
			dragdelta = evt.x - pos.left;
			dragindex = evtobj.parentNode.cellIndex;
			dragobj.setCapture();
			evtobj = undefined;
		}
		dragobj.style.left = (evt.x - dragdelta) + "px";
		var tr = objall(domobj, "HeadTR");
		for (var x = 0; x < tr.cells.length; x++)
		{
			var cell = objall(domobj, "FieldsHead").rows[0].cells[x];
			if ((x < tr.cells.length - 1) && (sethead(objattr(cells, "node")) < 0))
				continue;
			var pos = GetObjPos(tr.cells[x]);
			if ((evt.x - dragdelta > pos.left) && (evt.x - dragdelta < pos.right))
			{
				if (typeof evtobj != "object")
				{
					var p = GetObjPos(domobj);
					evtobj = document.createElement("<div style='position:absolute;width:1px;background-color:green;top:" +
						p.top + "px;height:" + (p.bottom - p.top - 25) + "px;overflow:hidden;'></div>");				
					document.body.insertBefore(evtobj, null);
				}
				evtobj.style.left = pos.left + "px";
				dragparam = x;
				break;
			}
		}
	}
	
	function dragheadend()
	{
		objevent(document, "mousemove", draghead, 1);
		objevent(document, "mouseup", dragheadend, 1);
		document.releaseCapture();
		if (typeof dragobj != "object")
			return;
		dragobj.parentNode.removeChild(dragobj);
		dragobj = undefined;
		evtobj.parentNode.removeChild(evtobj);
		evtobj = undefined;

		if (dragparam == dragindex)
			return;
		var tab = objall(domobj, "FieldsHead");
		var dndx = sethead(objattr(tab.rows[0].cells[dragparam], "node"));
		var sndx = sethead(objattr(tab.rows[0].cells[dragindex], "node"));
		if (dndx < 0)
		{
			var item = head.splice(sndx, 1);
			head[head.length] = item[0];
		}
		else
		{
			var item = head.splice(sndx, 1);
			if (sndx < dndx)
				dndx --;
			head.splice(dndx, 0, item[0]);
		}
		if (dragparam < dragindex)
			dragindex ++;
		var tab = objall(domobj, "FieldsHead");
		tab.rows[0].insertCell(dragparam);
		tab.rows[0].cells[dragparam].replaceNode(tab.rows[0].cells[dragindex]);
		if (quirks == 0)
		{
			tab = objall(domobj, "BodyTable");
			for (var x = 0; x < tab.rows.length; x++)
			{
				tab.rows[x].insertCell(dragparam);
				tab.rows[x].cells[dragparam].replaceNode(tab.rows[x].cells[dragindex]);
			}
		}
		else
			self.reload(data);
		scroll();		
	}
	
	function selearea()
	{
		objevent(document, "mouseup", selearea, 1);
		var evt = getEvent();
		if (evt.shiftKey)
			return;
return;
 		var rg = document.selection.createRange();
 		window.status = rg.boundingTop + "-" + rg.boundingHeight;
		var el = rg.parentElement();
//		alert(el.tagName);
 		return;
 		var oRcts = rg.getClientRects();
		for (var x = 0; x < oRcts.length; x++)
   			window.status = (oRcts[x].top + "," + oRcts[x].bottom);
	}
	
	function splitting()
	{
		var evt = getEvent();
		dragobj.style.left = (evt.x - 2) + "px";
	}
	
	function splitend()
	{
		objevent(document, "mousemove", splitting, 1);
		objevent(document, "onmouseup", splitend, 1);
		document.releaseCapture();
		dragobj.parentNode.removeChild(dragobj);
		dragobj = undefined;
		var tab = objall(domobj, "FieldsHead");
		var pos = GetObjPos(tab.rows[0].cells[dragindex]);
		var evt = getEvent();
		var w = evt.x - pos.left - 3;
		if (w < 2)
			w = 2;
		tab.rows[0].cells[dragindex].firstChild.style.width = w + "px";
		sethead(tab.rows[0].cells[dragindex].node, "nWidth", w);
		if (quirks == 0)
		{
			var tab = objall(domobj, "BodyTable");
			for (var x = 0; x < tab.rows.length; x++)
				tab.rows[x].cells[dragindex].firstChild.style.width = w + "px";
		}
		else
			self.reload(data);
		scroll();
	}
	
	function sethead(name, prop, value)
	{
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].FieldName == name)
			{
				if (typeof prop != "undefined")
					head[x][prop] = value;
				return x;
			}
		}
		return -1;
	}
	
	function click()
	{
		var evt = getEvent();
		if (evt.srcElement.id == "BtExTree")
			return expandTreeLine(evt.srcElement);
		var td = FindParentObject(evt.srcElement, domobj, "TD");
		if (typeof td != "object")
			return;
		if ((td.parentNode.id != "SeekTitleTR") && (td.parentNode.id != "HeadTR"))
		{
			self.clickRow(td);
		}
		else
			self.clickHead(td);
	}

	function expandTreeLine(obj, flag)
	{
		var tr = obj.parentNode.parentNode.parentNode;
		var depth = tr.node.split(",").length;
		if ((((flag == 1) || (flag == true)) && (obj.ex == 0))
			|| (((flag == 0) || (flag == false)) && (obj.ex == 1)))
			return
		if (obj.ex == 1)
		{
			obj.ex = 0;
			if (obj.tagName == "IMG")
				obj.src = expic[0];
			else
				obj.className = expic[0].substr(1);
			var dis = "inline";
			if (obj.unloadflag == 1)
			{
				var oDiv = document.createElement("DIV");
				var item = self.getItemData(tr.node);
				oDiv.innerHTML = "<table>" + getbody(cfg.gridstyle, item.child, depth + 1, tr.node) + "</table>";
				for (var x = oDiv.firstChild.rows.length - 1; x >= 0; x--)
					tr.insertAdjacentElement("afterEnd", oDiv.firstChild.rows[x]);
				obj.removeAttribute("unloadflag");
				oDiv.parentNode.removeChild(oDiv);
			}
		}
		else
		{
			obj.ex = 1;
			if (obj.tagName == "IMG")
				obj.src = expic[1];
			else
				obj.className = expic[1].substr(1);
			var dis = "none";
		}

		for (var x = tr.rowIndex + 1; x < tr.parentNode.rows.length; x++)
		{
			var d = tr.parentNode.rows[x].node;
			if (tr.parentNode.rows[x].node.split(",").length <= depth)
				break;
			tr.parentNode.rows[x].style.display = dis;
		}
	}
	
	function dblclick()
	{
		var evt = getEvent();
		var td = FindParentObject(evt.srcElement, domobj, "TD");
		if (typeof td != "object")
			return;
		if ((td.parentNode.id != "SeekTitleTR") && (td.parentNode.id != "HeadTR"))
			self.dblclickRow(td);
		else
			self.dblclickHead(td);
	}
	
	function setEditor(headindex)
	{
		if (typeof head[headindex].Editor != "object")
			return;
		if (self.cellchange != null)
			head[headindex].Editor.valueChange = self.cellchange;
		var tab = objall(domobj, "BodyTable");
		for (var x = 0; x < tab.rows.length; x++)
			head[headindex].Editor.attach(objall(tab.rows[x], head[headindex].FieldName + "_TD").firstChild);
	}

	this.DisEditor = function()
	{
		if (typeof head != "object")
			return;
		for (var x = 0; x < head.length; x++)
		{
			if (typeof head[x].Editor == "object")
				head[x].Editor.hide();
		}
	};

	this.cellchange = function (obj)
	{
		var value = objtext(obj);
		var index = obj.parentNode.parentNode.rowIndex;
		var FieldName = obj.parentNode.id.split("_")[0];
		if (typeof data[index][FieldName] == "object")
			data[index][FieldName].value = value;
		else
			data[index][FieldName] = value;
	};

	this.setexpic = function(pic)
	{
		expic = pic;
		init();
	};
	
	this.bodymenu = function () {};
	
	this.bodyonload = function (){};
	
	this.clickRow = function (td)
	{
		var min = -1, max = -1, index, x;
		rollshadow.hide();
		var tab = objall(domobj, "BodyTable");
		var evt = getEvent();
		if (evt.shiftKey && (cfg.bodystyle == 3))
		{
			for (x = 0; x < tab.rows.length; x++)
			{
				if (selshadow.isShadow(tab.rows[x]) && (min == -1))
					min = x;
				if (selshadow.isShadow(tab.rows[x]) && (x > max))
					max = x;
			}
			index = td.parentNode.rowIndex;
			
			if ((min == -1) && (max == -1))
				selshadow.show(td.parentNode);

			if (index < min)
				min = index;
			else
			{
				if (index > max)
					max = index;
				else
					min = index
			}
		selshadow.hide();
		for (x = min; x <= max; x++)
			selshadow.show(tab.rows[x], true);
		document.selection.empty();
			
		}
		else
			selshadow.show(td.parentNode, evt.ctrlKey && (cfg.bodystyle == 3));
	};
	
	this.dblclickRow = function (td) {};
	
	this.clickHead = function (td)
	{
		var evt = getEvent();
		var td = FindParentObject(evt.srcElement, domobj, "TD");
		var node = objattr(td, "node");
		if (node == info.Order)
			this.orderField(node, info.bDesc ^ 1);
		else
			this.orderField(node, 0);		
	};
	
	this.dblclickHead = function (td) 
	{
	
	};
	
	this.keydown = function () {};
	
	this.overRow = function (td) 
	{
		if (selshadow.isShadow(td.parentNode))
			rollshadow.hide();
		else
			rollshadow.show(td.parentNode);
	};
	
	this.orderField = function (Field, bDesc)
	{
	};
	
	this.reload = function (body, h)
	{
		self.DisEditor();
		data = body;
		if (typeof h == "object")
		{
			if (typeof h.Records == "undefined")
				head = h;
			else
				info = h;
			return init();
		}
		var div = objall(domobj, "BodyDiv");
		div.innerHTML = "<table id=BodyTable cellpadding=3 cellspacing=1 border=0 bgcolor=#DDDDDD>" +
			getbody(cfg.gridstyle) + "</table>";
		var tab = objall(domobj, "BodyTable");
		tab.onclick = click;
		tab.ondblclick = dblclick;
		tab.onmouseover = rollgrid;
		tab.onmousedown = mousedown;
		div.onscroll = scroll;
		div.onmousewheel = self.DisEditor; 
		tab.onkeydown = self.keydown;
		tab.oncontextmenu = self.bodymenu;
		
		selshadow.hide();
		rollshadow.hide();
		for (var x = 0; x < head.length; x++)
		{
			if ((head[x].nShowMode == 1) || (head[x].nShowMode == 7))
				setEditor(x);
		}
		this.bodyonload();
	};

	this.setCell = function (index, FieldName, value)
	{
		var rows = objall(domobj, "BodyTable").rows;
		var cellobj = objall(rows[index], FieldName + "_TD").firstChild;
		if (typeof value == "string")
		{
			cellobj.innerHTML = value;
			if (typeof data[index][FieldName] == "object")
				data[index][FieldName].value = value;
			else
				data[index][FieldName] = value;
		}
		else
		{
			data[index][FieldName] = value;
			cellobj.innerHTML = value.value;
			cellobj.style.color = value.color;
		}
	};
	this.getCell = function (index, FieldName)
	{
		var tab = objall(domobj, "BodyTable");
		return objall(tab.rows[index], FieldName + "_TD");
	};
	
	this.getCellData = function (td)
	{
		var FieldName = td.td.id.split("_")[0];
		return data[td.parentNode.rowIndex][FieldName];
	};
	
	this.getRow = function(index)
	{
		return objall(domobj, "BodyTable").rows[index];
	};

	this.attachEditor = function (FieldName, editor)
	{
		var y = sethead(FieldName);
		if (typeof head[y].Editor == "object")
			this.detachEditor(FieldName);
		head[y].Editor = editor;
		setEditor(y);
	};
	
	this.detachEditor = function (FieldName)
	{
		var y = sethead(FieldName);
		var editor = head[y].Editor;
		if (typeof editor == "undefined")
			return;
		var tab = objall(domobj, "BodyTable");
		for (var x = 0; x < tab.rows.length; x++)
			editor.detach(objall(tab.rows[x], FieldName + "_TD").firstChild);
		head[y].Editor = undefined;
	};
	
	this.getSelRow = function()
	{
		return selshadow.getObj();
	};
	
	this.getsel = function ()
	{
		return selshadow;
	};
	
	this.getData = function ()
	{
		return data;
	};

	this.getHead = function ()
	{
		return head;
	};
	
	this.getBodyTable = function ()
	{
		return objall(domobj, "BodyTable");
	};
	
	this.outerDoc = function()
	{
		var tag = "<table cellpadding=3 cellspacing=0 border=0><tr>";
		for (var x = 0; x < head.length; x++)
		{
			if (head[x].nShowMode == 1)
				tag += "<td width=" + head[x].nWidth + "px>" + head[x].TitleName + "</td>";
		}
		return tag + "</tr>" + getbody(0) + "</table>";
	};
	
	this.selCol = function (index)
	{
		selshadow.hide();
		var tab = objall(domobj, "BodyTable");
		for (x = 0; x < tab.rows.length; x++)
			selshadow.show(tab.rows[x].cells[index], true);
	}

	this.deleteRow = function(row)
	{
		if (typeof row == "undefined")
		{
			var rows = selshadow.getShadow();
			for (var x = 0; x < rows.length; x++)
				this.deleteRow(rows[x].obj);
			return;
		}
		if (typeof row == "number")
			return this.deleteRow(this.getRow(row));
		if (row.tagName != "TR")
		 	return;
		data.splice(row.rowIndex, 1);
		row.parentNode.removeChild(row);
	}
	
	this.insertRow = function (linedata)
	{
		var index = data.length;
		var rows = selshadow.getShadow();
		if (rows.length > 0)
		{
		 	if (rows[0].obj.tagName == "TR")
				index = rows[rows.length - 1].obj.rowIndex + 1;
		}
		if (index == data.length)
			data[index] = linedata;
		else
			data.splice(index, 0, linedata);
//		this.reload(data);
	}
	
	this.insertCol = function (headitem)
	{
		var index = data.length;
		var rows = selshadow.getShadow();
		if (rows.length > 0)
		{
		 	if (rows[0].obj.tagName == "TD")
				index = rows[rows.length - 1].obj.cellIndex + 1;
		}
		if (index == head.length)
			head[index] = headitem;
		else
			head.splice(index, 0, headitem);
	}
	
	this.waiting = function (s)
	{
		if (typeof s == "undefined")
			s = "载入中...";
		objall(domobj, "BodyDiv").innerHTML = s;		
	};

	this.getItemData = function(node)
	{
		if (typeof node == "undefined")
			node = objattr(this.getSelRow(), "node");
		if (typeof node == "number")
			return data[node];
		if (typeof node == "object")
			node = objattr(node, "node");
		var ss = node.split(",");
		var item, items = data;
		for (var x = 0; x < ss.length; x++)
		{
			item = items[parseInt(ss[x])];
			items = item.child;
		}
		return item;		
	};

	this.expand = function(row, flag)
	{
		if (typeof row == "undefined")
		{
			var rows = selshadow.getShadow();
			for (var x = 0; x < rows.length; x++)
				this.expand(rows[x].obj, flag);
			return;
		}

		var img = objall(row, "BtExTree");
		if (img != null)
			expandTreeLine(img, flag);
	};

	this.expandall = function (flag)
	{
		var tab = objall(domobj, "BodyTable");
		for (x = 0; x < tab.rows.length; x++)
			self.expand(tab.rows[x], flag);
	}

	this.pageskip = function (nPage)
	{
	}
	
	function init()
	{
		switch (cfg.gridstyle)
		{
		case 1:
			createGrid();
			break;
		case 2:
			createTable();
		}
	}
	
	cfg = FormatObjvalue({gridstyle:1, headstyle:1, bodystyle:3, footstyle:0, transText:1,
			bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff",selbkcolor:"#B7E3FE", 
			nowrap:1, rightmenu:null, initDepth:1, nIndent:20}, cfg);
	info = FormatObjvalue({nPage:1, PageSize:100, Records:0, Order:"", bdesc:0}, info);
	
	selshadow = new CommonShadow(0, cfg.selbkcolor);
	rollshadow = new CommonShadow(0, cfg.rollbkcolor);
	if (typeof data == "undefined")
		data = [];
	init();
}

function TreeView(domobj, data, cfg, head)
{
var self = this;
var expic = [".TreeArrawOpen", ".TreeArrawClose"];
var rollshadow, selshadow;
	function init()
	{
		if (typeof data != "object")
			return;
		var tag = "";
		for (var x = 0; x < data.length; x++)
			tag += getnodetag(data[x], 0, x);
		domobj.innerHTML = tag;
		domobj.onclick = mouseevent;
		domobj.ondblclick = mouseevent;
		domobj.onmouseover = mouseevent;

		domobj.oncontextmenu = mouseevent;
		selshadow = new CommonShadow(0, cfg.selbkcolor);
		rollshadow = new CommonShadow(0, cfg.rollbkcolor);
	}

	function getnodetag(item, depth, node)
	{
		var nowrap = "";
		if ((cfg.nowrap == 1) || (cfg.nowrap == true))
			nowrap = "white-space:nowrap;";
		item = FormatObjvalue({item:undefined, title:"", style:"", img:"", child:""}, item);
		if (typeof item.item == "undefined")
			translateItem(item);
		var title = " title=\"" + item.title + "\"";
		var style = item.style;
		var div = "<div node=" + node + " style=\"padding:" + cfg.vpadding + "px 2px " + cfg.vpadding + "px " +
			(depth * cfg.nIndent) + "px;" + nowrap +  style + "\"" + title + ">"; 
		var img = item.img;
		if ((img != "") && (img.substr(0, 1) != "<"))
			img = "&nbsp;<img src='" + img + "' style=VERTICAL-ALIGN:middle>&nbsp;";
		var text = img + "<span>" + item.item + "</span>";
		if (typeof item.child != "object")
			return div + text + "</div>";

		var ex = "<img id=BtExTree src=" + expic[1] + " style=VERTICAL-ALIGN:middle>";
		if (expic[0].substr(0, 1) == ".")
			ex = "<span id=BtExTree class=" + expic[1].substr(1) + "></span>";
		if ((depth >= cfg.initDepth - 1) || (item.child == null))
			return div + ex + text + "</div><div id=subdiv unloadflag=1 style=display:none;></div>";
		var tag = "";
		for (var x = 0; x < item.child.length; x++)
			tag += getnodetag(item.child[x], depth + 1, node + "," + x);
		var ex = "<img id=BtExTree src=" + expic[0] + " style=VERTICAL-ALIGN:middle>";
		if (expic[0].substr(0, 1) == ".")
			ex = "<span id=BtExTree class=" + expic[0].substr(1) + "></span>";
		return div + ex + text + "</div><div id=subdiv>" + tag + "</div>";
	}

	function translateItem(item)
	{
		if (typeof head != "object")
			return;
			
		for (var x = 0; x < head.length; x++)
		{
			var value = item[head[x].FieldName];
			if ((cfg.transText > 0) && (typeof item[head[x].FieldName + "_ex"] != "undefined"))
			{
				if (cfg.transText == 1)
					value = item[head[x].FieldName + "_ex"];
				else
					value = value + ":" + item[head[x].FieldName + "_ex"];
			}
			switch (head[x].nShowMode)
			{
			case 1:			//标题
			case 7:			//转义
			case 9:			//树型
				if ((head[x].nShowMode == 9) || (head[x].bTag == 1))
				{
						item.item = value;
						break;
				}
			case 3:			//注释
				item.title += head[x].TitleName + ":" + value + "\n";
				break;
			case 2:			//内文
				break;
			case 5:			//浮窗
				break;
			case 6:			//隐藏
				break;
			case 8:			//附属
				break;
			case 4:			//禁止
				break;
			}
		}
	}

	function mouseevent()
	{
		var evt = getEvent();
		var o = findparentnode(evt.srcElement);
		if (typeof o == "undefined")
			return;
		switch (evt.type)
		{
		case "dblclick":
			return self.dblclick(o);
		case "contextmenu":
			return self.contextmenu(o);
		case "click":
			if (evt.srcElement.id == "BtExTree")
				return expand(evt.srcElement);
			return self.click(o);
		case "mouseover":
			return self.mouseover(o);
		default:
			alert(evt.type);
		}
	}

	function expand(img, flag)
	{
		var odiv = img.parentNode.nextSibling;
		if ((((flag == 1) || (flag == true)) && (odiv.style.display != "none"))
			|| (((flag == 0) || (flag == false)) && (odiv.style.display == "none")))
			return;
		if (odiv.style.display == "none")
		{
			odiv.style.display = "block";
			if (img.tagName == "IMG")
				img.src = expic[0];
			else
				img.className = expic[0].substr(1);
			if (odiv.unloadflag == 1)
			{
				odiv.unloadflag = 2;
				var item = self.getTreeItem(objattr(img.parentNode, "node"));
				if (item.child == null)
				{
					odiv.innerHTML = "<span style=color:gray;>加载中...</span>";
					self.loadnode(item, odiv);
				}
				else
					self.loadnodeok(item, odiv);
			}
		}
		else
		{
			odiv.style.display = "none";
			if (img.tagName == "IMG")
				img.src = expic[1];
			else
				img.className = expic[1].substr(1);
		}
	}

	function findparentnode(obj)
	{
		for (var o = obj; o != domobj; o = o.parentNode)
		{
			if (obj == null)
				return;
			if (objattr(o, "node") != null)
				return o;
		}
	}

	function translatedata(d)
	{
		if ((cfg.parentNode == "") || (typeof head != "object"))
			return d;
		var keys = cfg.parentNode.split(",");
		var root = [], node, items = [], links = [];
		links[0] = root;
		for (var y = 0; y < d.length; y++)
		{
			for (x = 0; x < keys.length; x ++)
			{
				if (d[y][keys[x]] != items[x])
				{
					node = links[x];
					var value = d[y][keys[x]];
					if (typeof d[y][keys[x] + "_ex"] == "string")
						value = d[y][keys[x] + "_ex"];
					node[node.length] = {item: value, child:[]};
					node = node[node.length - 1].child;
					links[x + 1] = node;
					items[x] = d[y][keys[x]];
				}
			}
			node[node.length] = d[y];
		}
		return root;
	}

	this.click = function (obj)
	{
		this.select(obj);
	};

	this.expand = function (obj, flag)
	{
		var img = objall(obj, "BtExTree");
		if (img != null)
			expand(img, flag);
	};

	this.reloadNode = function (obj)
	{
		if (typeof obj == "undefined")
			obj = selshadow.getObj();
		obj.nextSibling.unloadflag = 1;
		self.expand(obj, false);
		self.expand(obj, true);
	};

	this.select = function (obj)
	{
		rollshadow.hide();
		selshadow.show(obj);
	};

	this.dblclick = function (obj)
	{
		this.expand(obj);
	};

	this.contextmenu = function (obj)
	{
	};

	this.mouseover = function (obj)
	{
		if (selshadow.isShadow(obj))
			rollshadow.hide();
		else
			rollshadow.show(obj);
	};

	this.getdata = function ()
	{
		return data;
	};
	
	this.getnode = function(key, value)
	{
		for (var x = 0; x < data.length; x++)
		{
			if (data[x][key] == value)
				return data[x];
		}
	};

	this.getTreeItem = function(node)
	{
		if (typeof node == "undefined")
			node = objattr(selshadow.getObj(), "node");
		if (typeof node == "object")
			node = objattr(node, "node");
		if (typeof node == "number")
			return data[node];
		var ss = node.split(",");
		var item = data[parseInt(ss[0])];
		for (var x = 1; x < ss.length; x++)
			item = item.child[parseInt(ss[x])];
		return item;
	};
	
	this.setNodeText = function (node, text)
	{
		var item = getTreeItem(node);
		item.item = text;
	};
	
	this.getNodeObj = function(key, value)
	{
		var node = value;
		if ((typeof key == "string") && (key != ""))
			node = this.getItemNode(key, value);
		if (typeof node == "undefined")
			return;
		var objs = domobj.getElementsByTagName("DIV");
		for (var x = 0; x < objs.length; x++)
		{
			if (objattr(objs[x], "node") == node)
				return objs[x];
		}
	};
	
	this.getItemNode = function(key, value, treedata, initnode)
	{
		if (typeof treedata == "undefined")
			treedata = data;
		if (typeof initnode == "undefined")
			initnode = "";
		var node;
		for (var x = 0; x < treedata.length; x++)
		{
			if (initnode == "")
				node = initnode + x;
			else
				node = initnode + "," + x;
			if (value == treedata[x][key])
				return node;
			if (typeof treedata[x].child == "object")
			{
				node = this.getItemNode(key, value, treedata[x].child, node);
				if (typeof node != "undefined")
					return node;
			}
		}
	};

	this.setexpic = function(pic)
	{
		expic = pic;
		init();
	};

	this.waiting = function (s)
	{
		if (typeof s == "undefined")
			s = "载入中...";
		domobj.innerHTML = s;		
	};

	this.setdata = function(d)
	{
		data = translatedata(d);
		init();
	};

	this.setDataParentNode = function (node)
	{
		cfg.parentNode = node;
	}

	this.getsel = function ()
	{
		return selshadow;
	};

	this.append = function(d)
	{
		var len = data.length;
		data.splice(len, 0, d);
		var tag = "";
		for (var x = len; x < data.length; x++)
			tag += getnodetag(data[x], 0, x);
		domobj.insertAdjacentHTML("beforeEnd", tag);
	};

	this.loadnode = function(item, odiv)
	{
		item.child = [];
		this.loadnodeok(item, odiv);
	};

	this.loadnodeok = function(item, odiv)
	{
		if (odiv.firstChild != null)
			odiv.removeChild(odiv.firstChild);
		var node = objattr(odiv.previousSibling, "node");
		var ss = node.split(",");
		var tag = "";
		for (var x = 0; x < item.child.length; x++)
			tag += getnodetag(item.child[x], ss.length, node + "," + x);
		odiv.innerHTML = tag;
		odiv.removeAttribute("unloadflag");
	};

	this.attachEditor = function (editor)
	{
	};
	
	this.detachEditor = function ()
	{
	};

	this.count = function (item)
	{
		if (typeof item != "object")
			item = data;
		if (typeof item.length != "number")
		{
			if (typeof item.child == "object")
				return this.count(item.child) + 1;
			return 1;
		}
		var cnt = 0;
		for (var x = 0; x < item.length; x++)
		{
			if (typeof item[x].child == "object")
				cnt += this.count(item[x].child);
		}
		return cnt + item.length;
	};

	cfg = FormatObjvalue({bodycolor:"black", bodybkcolor:"white", rollbkcolor: "#f8f8ff",selbkcolor:"#B7E3FE", 
			transText:1, nowrap:1, rightmenu:null,initDepth:3, nIndent:20,vpadding:1, parentNode:""}, cfg);
	init();
}

function FormView(domobj, items, data, cfg)
{
	var self = this;
	var form, layer;
	this.enumurl = "../com/seleenum.jsp?AjaxMode=1&EnumType=";
	this.quoteimg = "../com/pic/search.png";
	function init()
	{
		if (typeof domobj != "object")
			return;
		if (typeof cfg.ex == "object")
			return initLayerForm();
		var tag = "<table border=0 cellpadding=3 cellspacing=1 class=jformtable" + cfg.css + ">";
		if ((cfg.title != "") && (cfg.title != "null"))
			tag += "<tr><td colspan=" + cfg.nStyle * cfg.nCols + " class=jformtitle" + cfg.css + ">" + cfg.title + "</td></tr><tr>";
		var htag = "";
		var rows = 1, cols = 0;
		for ( var x = 0; x < items.length; x++)
		{
			items[x] = FormatObjvalue({CName:"", EName:"", nShow:1, nReadOnly:0, nRequired: 0, InputType: 1, 
				Relation:"", Quote:"", nCol:1, nRow:1, nWidth:1, nHeight:1, Hint:"", click:null, dblclick:null, change:null, keypress:null},  items[x]);
			getquote(items[x]);
			cols += items[x].nWidth;
			if ((rows < items[x].nRow) || (cols > cfg.nCols))
			{
				tag += "</tr><tr>";
				rows = items[x].nRow;
				cols = items[x].nWidth;
			}
			var required = "";
			if (items[x].nRequired == 1)
				required = "<span style=color:red>*</span>";
			var objtag = "";
			if ((items[x].nWidth == 0) || (items[x].InputType == 21))
				htag += "<input type=hidden name=" + items[x].EName + ">";
			else
			{
				objtag = getobj(items[x]);
				switch (cfg.nStyle)
				{
				case 1:
					tag += "<td class=jformval" + cfg.css + " colspan=" + items[x].nWidth + ">" + items[x].CName + required + "<br>" + objtag + "</td>";
					break;
				case 2:
					tag += "<td class=jformcon" + cfg.css + ">" + items[x].CName + required + 
						"</td><td class=jformval" + cfg.css + " colspan=" + (items[x].nWidth * 2 - 1) + ">" + objtag + "</td>";
					break;
				case 3:
					tag += "<td class=jformcon" + cfg.css + " nowrap>" + items[x].CName + required + 
						"</td><td class=jformval" + cfg.css + " width=40% colspan=" + (items[x].nWidth * 3 - 2) + ">" + objtag + 
						"</td><td style=width:30%;color:gray;>" + items[x].Hint + "</td>";
					break;
				}
			}
		}
		tag += "</tr></table>" + htag + getbar();
		if (cfg.nType != 8)
			tag = "<form action=" + cfg.action + " method=POST name=ActionSave>" + tag + "</form>";
			
		domobj.innerHTML = tag;
		for (var x = 0; x < items.length; x++)
			prepare(items[x]);
		self.setdata(data);
		form = domobj.firstChild;
		form.onkeydown = keydown;
		form.onkeypress = keypress;
		form.onclick = click;
		form.ondblclick = dblclick;
		form.onresize = resize;
		form.onsubmit = beforesubmit;
	}

	function resize()
	{
		alert("resize");
	}

	function getobj(item)
	{
		var tag = "";
		var readonly = "";
		if (item.nReadOnly == 1)
			readonly = " readonly";
		switch (item.InputType)
		{
		case 1:		//编辑框
			if (item.Quote == "")
				return "<input type=text class=text name=" + item.EName + readonly + ">" + getitemquote(item);
			return "<input type=hidden name=" + item.EName + "><input type=text class=text name=Alias_" + item.EName + readonly + ">" + getitemquote(item);
		case 2:		//检查框
			return "<input type=checkbox name=" + item.EName + readonly + ">";
			break;
		case 3:		//单选框
			return tag = "<div id=" + item.EName + "_DIV style=width:100%;height:" + item.nHeight * 30 + "px;></div>";
		case 4:		//下拉框
			return "<select name=" + item.EName + "></select>";
		case 5:		//文本框
			return "<textarea class=txt style=width:100%; name=" + item.EName + " rows=" + item.nHeight + readonly + "></textarea>" + getitemquote(item);
		case 6:		//密码框
			return "<input type=password name=" + item.EName + readonly + ">";
		case 7:		//超文本框
			return "<div class=spantext id=" + item.EName + "_DIV style='overflow:hidden;width:100%;height:" + item.nHeight * 30 + "'></div>";
		case 8:		//自定义类型
		case 9:		//组合框
		case 10:	//表格
		case 11:	//分栏
		case 12:	//分页
		case 13:	//表单
		case 14:	//视图
		case 15:	//图片
		case 16:	//页面
		case 17:	//明细表
		case 22:	//OFFICE文档
		case 23:	//文件框
		case 24:	//预定义
			break;
		case 21:	//隐藏框
			break;
		}
		return tag;
	}

	function getitemquote(item)
	{
		switch (item.Relation.substr(0, 1))
		{
		case "!":
			return "<img src=" + self.quoteimg + " onclick=" + item.Relation.substr(1) + " style=cursor:hand;margin-left:-20px>";
		case "?":
			return item.Relation.substr(1);
		default:
		}
		return "";
	}

	function prepare(item)
	{
		
		switch (item.InputType)
		{
		case 3:		//单选框
			if ((typeof item.data != "string") || (item.data == ""))
				return;
			if (item.data == "~未加载~")
				return self.loadItemData(item);
			var ss = item.data.split(",");
			var readonly = "";
			if (item.nReadOnly == 1)
				readonly = " readonly";
			for (var tag = "", x = 0; x < ss.length; x ++)
			{
				var sss = ss[x].split(":");
				if (sss.length == 1)
					sss[1] = sss[0];
				tag += "<input type=radio name=" + item.EName + " value=" + sss[0] + readonly + ">" + sss[1] + "&nbsp;";
			}
			var obj = objall(domobj, item.EName + "_DIV");
			obj.innerHTML = tag;
			break;
		case 4:		//下拉框
			if ((typeof item.data != "string") || (item.data == ""))
				return;
			if (item.data == "~未加载~")
				return self.loadItemData(item);
			var ss = item.data.split(",");
			var obj = objall(domobj, item.EName);
			for (var x = 0; x < ss.length; x ++)
			{
				var sss = ss[x].split(":");
				if (sss.length == 1)
					sss[1] = sss[0];
				var o = document.createElement("OPTION");
				o.value = sss[0];
				o.text = sss[1];
				obj.options.add(o);
			}
			break;
		case 7:		//超文本框
			var nType = 1;
			if (item.Relation == "short" || item.Relation == "3")
				nType = 3;
			if (item.Relation == "middle" || item.Relation == "2")
				nType = 2;
			if (item.Relation == "hidden" || item.Relation == "0")
				nType = 0;
			item.obj = new HTMLEditor(objall(domobj, item.EName + "_DIV"), {EName: item.EName, nType: nType});
			break;
		}
	}

	function getbar()
	{
		var tag = "<div id=FormButtonDiv align=center class=jformtail" + cfg.css + ">";
		switch (cfg.nType)
		{
		case 1:		//查看
			break;
		case 2:		//修改
			tag += "<input type=submit value='提 交' name=SubmitButton>&nbsp;";
			break;
		case 3:		//打印
			break;
		case 4:		//自定义
			break;
		case 5:		//浏览
			break;
		case 6:		//编辑
			break;
		case 7:		//查询
			break;
		case 8:		//页面
			return "";
		}
		return tag + "</div>";
	}

	function initLayerForm()
	{
		if (cfg.nType != 8)
		{
			domobj.innerHTML = "<form action=" + cfg.action + " method=POST name=ActionSave></form>";
			form = domobj.firstChild;
		}
		else
			form = domobj;
		layer = new Layer(form, cfg.ex);
		var tag = form.innerHTML;
		for ( var x = 0; x < items.length; x++)
		{
				objtag = getobj(items[x]);
				tag = tag.replace("(" + items[x].EName + ")", objtag);		
		}
		tag = tag.replace("(@@Submit@@)", "<input type=submit value='提 交' name=SubmitButton>&nbsp;");
		tag = tag.replace("(@@Close@@)", "<input type=button value='关闭' onclick=window.close()>&nbsp;");
		form.innerHTML = tag;
	}

	function keydown()
	{
//		alert("KEYDOWN");
	}

	function keypress()
	{
	}

	function click()
	{
//		alert("click");
	}

	function dblclick()
	{
		alert("dblclick");
	} 

	function getquote(item)
	{
		switch (item.Quote.substr(0, 1))
		{
		case "(":
			item.data = item.Quote.substr(1, item.Quote.length - 2);
			break;
		case "$":
			break;
		case "@":
			item.data = "~未加载~";
			break;
		default:
			item.data = "~未加载~";
			break;
		}

	}

	function beforesubmit()
	{
		var result = true;
		for ( var x = 0; x < items.length; x++)
		{
			if (items[x].nRequired == 1)
			{
				if (objall(form, items[x].EName).value == "")
				{
					result = false;
					objall(form, items[x].EName).style.border = "1px solid red";
//					alert(items[x].CName + "必填");
				}
			}
			if (items[x].InputType == 7)
				items[x].obj.copydata();
		}
		
		if (result)
			return self.submit();
		return false;
	}
	this.keypress = function (key)
	{
	};

	this.onchange = function(obj)
	{
	};

	this.submit = function ()
	{
		return true;
	};

	this.attachEvent = function(item, evt, fun)
	{
	};

	this.detachEvent = function(item, evt, fun)
	{
	};

	this.setdata = function (d)
	{
		data = d;
		for (var key in d)
		{
			var o = objall(domobj, key);
			if (o != null)
				o.value = d[key];
		}
	};

	this.loadItemData = function (item)
	{
		function loadItemDataOK(data)
		{
			item.data = data;
			prepare(item);
		}
		AjaxRequestPage(this.enumurl + item.Quote, true, "", loadItemDataOK);
	}
	
	this.bind = function(obj)
	{
		domobj = obj;
		init();
	}
	
	this.appendHidden = function (item, value)
	{
		form.insertAdjacentHTML("afterBegin", "<input type=hidden name=\"" + item + "\" value=\"" + value + "\">");
	}
	
	cfg = FormatObjvalue({title:"", action:location.pathname + "?FormSaveFlag=1", nType:2, nStyle:2,nCols:1,headTxt: "", footTxt: "", 
		ex:"", width:0,height:0,viewpage:"", css:"1"}, cfg);
	init();
}

function HTMLEditor(domobj, cfg)
{
	var self = this;
	var tool, ruler, doc, spos;
	var cb, bb, pb, menudef, propwin;

	function getRngObj(obj, tag)
	{
		obj.focus();
		var target = null, item;
		var ttype = doc.selection.type;
		var selrange = doc.selection.createRange();
		
		switch(ttype)
		{
		case 'Control' :
			if (selrange.length > 0 ) 
				target = selrange.item(0);
			break;
		case 'None' :
			target = selrange.parentElement();
			break;
		case 'Text' :
			target = selrange.parentElement();
			break;
		}
	
		if ((tag == "") || (tag == undefined))
			return target;
		for (item = target; (item != null) && (item != obj); item = item.parentElement)
		{
			if (item.tagName == tag)
				return item;
		}
		return null;
	}

	function execCommand(obj, item)
	{
		doc.execCommand(item.cmd);
		SetStatus();
	}

	function EditorMenu()
	{
	}

	function KeyFilter()
	{
	}

	function SetStatus()
	{
	var x, value, o;
		if (cfg.nType == 0)
			return;
		
		for (x = spos; x < spos + 9; x++)
		{
			value = doc.queryCommandValue(menudef[x].cmd);
			o = tool.getDomItem(menudef[x]);
			o.style.backgroundColor = value ? "#d0d0d0" : "";
		}
		if (cfg.nType == 3)
			return;

		value = doc.queryCommandValue("ForeColor");
		cb.firstChild.style.backgroundColor = rgb(value);
		value = doc.queryCommandValue("BackColor");
		bb.firstChild.style.backgroundColor = rgb(value);
		value = doc.queryCommandValue("FormatBlock");
		o = objall(domobj, "psel");
		for (x = 0; x < o.options.length; x++)
		{
			if (o.options[x].innerHTML == value)
			{
				o.value = o.options[x].value;
				break;
			}
		}
		value = doc.queryCommandValue("FontName");
		o = objall(domobj, "fsel");
		for (var x = 0; x < o.options.length; x++)
		{
			if (o.options[x].innerHTML == value)
			{
				o.selectedIndex = x;
				break;
			}
		}
		value = getRngObj(doc.body).currentStyle.fontSize;
		o = objall(domobj, "ssel");
		for (x = 0; x < o.options.length; x++)
		{
			if (o.options[x].innerHTML == value)
			{
				o.selectedIndex = x;
				break;
			}
		}
		if (x == o.options.length)
			o.value = "";
		if (cfg.nType == 2)
			return;			
		if ((typeof propwin == "object") && (propwin.closed == false))
		{
			pb.style.backgroundColor = "#d0d0d0";
			doc.body.focus();
			o = getRngObj(doc.body, "");
			propwin.InitObject(o);
		}
		else
			pb.style.backgroundColor = "";
	}

	function rgb(color)
	{
		if (color == null)
			color = 0;
		var c = "00000" + color.toString(16);
		c = c.substr(c.length - 6);
		return "#" + c.substr(4, 2) + c.substr(2, 2) + c.substr(0, 2);
	}

	function prop()
	{
		if ((typeof propwin == "object") && (propwin.closed == false))
			return;
		propwin = window.showModelessDialog("/HTMLProp.htm", getRngObj(doc.body, ""),
			"dialogWidth:320px;dialogHeight:400px;status:0;scroll:0;help:0");
	}

	function setcolor(obj, item)
	{
		var color = SelectColor(0);
		doc.body.focus();
		if (typeof(color) != "string")
			return;
		doc.execCommand(item.cmd, false, color);
		obj.firstChild.style.backgroundColor = color;
	}

	function insertTable()
	{
		var tag = showModalDialog("/HTMLtable.htm", window, "dialogWidth:22em; dialogHeight:18em; status:0;scroll:no;");
		doc.body.focus();
		if (typeof(tag) == "string")
		{
	 		var oRange = document.selection.createRange();
			oRange.pasteHTML(tag);
		}
	}

	function insertRow()
	{
		var tab = getRngObj(doc.body, "TABLE");
		if (tab == null)
			return;
		var row = tab.insertRow();
		for (var x = 0; x < tab.rows[0].cells.length; x++)
		{
			var cell = row.insertCell();
			cell.bgColor = tab.rows[0].cells[x].bgColor;
		}
	}

	function deleteRow()
	{
		var tr = getRngObj(doc.body, "TR");
		if (tr != null)
			tr.parentNode.removeChild(tr);
	}

	function insertCol()
	{
		var tab = getRngObj(doc.body, "TABLE");
		if (tab == null)
			return;
		for (var x = 0; x < tab.rows.length; x++)
		{
			var cell = tab.rows[x].insertCell();
			cell.bgColor = tab.rows[x].cells[0].bgColor;
		}
	}

	function deleteCol()
	{
		var td = getRngObj(doc.body, "TD");
		if (td == null)
			return;
		var tab = td.parentNode.parentNode.parentNode;
		var pos = td.cellIndex;
		for(var x = 0; x < tab.rows.length; x++)
			tab.rows[x].removeChild(tab.rows[x].cells[pos]);
	}

	function insertCell()
	{
		var td = getRngObj(doc.body, "TD");
		if (td == null)
			return;
		var cell = td.parentNode.insertCell();
		cell.bgColor = td.bgColor;
	}

	function deleteCell()
	{
		var td = getRngObj(doc.body, "TD");
		if (td != null)
			td.parentNode.removeChild(td);
	}

	function exCell(obj, item)
	{
		var td = getRngObj(doc.body, "TD");
		if (td == null)
			return;
		if (item.cmd == 1)
			td.colSpan += 1;
		if (item.cmd == 2)
			td.rowSpan += 1;
	}

	function insertImg()
	{
		var tag = showModalDialog("/SelectImg.htm", doc, "dialogWidth:480px; dialogHeight:220px; status:0;scroll:no;");
		doc.body.focus();
		if (typeof tag != "string")
			return;
	 	var oRange = doc.selection.createRange();
		oRange.pasteHTML(tag);
	}

	function preview()
	{
		var win = new PopupWin("<iframe id=pview frameborder=0 style=width:100%;height:100%></iframe>",{title:"页面预览",width:500,height:400,mask:30});
		idobj("pview").contentWindow.document.write(doc.getElementsByTagName("HTML")[0].outerHTML);
	}

	function viewsource()
	{
		var win = new PopupWin("<div style='width:100%;height:100%;padding-bottom:30px;'><textarea id=hsrc style=width:100%;height:100%;>" +
			"</textarea></div><div align=right style=position:relative;top:-28px><input id=runsrc type=button value=应用>&nbsp;</div>",
			{title:"HTML代码",width:500,height:400,mask:30});
		idobj("hsrc").value = doc.getElementsByTagName("HTML")[0].outerHTML;
		win.show(-1, -1, 640, 480);
		idobj("runsrc").onclick = applysrc;
	}

	function applysrc()
	{
		doc.write(idobj("hsrc").value);
		doc.close();
	}

	function formatblock()
	{
		doc.body.focus();
		var evt = getEvent();
		doc.execCommand("FormatBlock", false, "<" + evt.srcElement.value + ">");
	}

	function selfont()
	{
		var evt = getEvent();
		doc.body.focus();
		doc.execCommand("FontName", false, evt.srcElement.options[evt.srcElement.selectedIndex].innerHTML);
	}

	function selsize()
	{
		doc.body.focus();
		var evt = getEvent();
	 	var oRange = doc.selection.createRange();
		if (oRange.boundingWidth > 0)
		{
			doc.execCommand("FontName", false, "eWebEditor_Temp_FontName");
			var fs = doc.getElementsByTagName("FONT");
			for (var x = 0; x < fs.length; x++)
			{
				if (fs[x].face == "eWebEditor_Temp_FontName")
				{
					fs[x].removeAttribute("face");
					fs[x].style.fontSize = evt.srcElement.options[evt.srcElement.selectedIndex].innerHTML;
				}
			}
			return;
		}
		var tag = "<span id=TEMPSPAN style=width:8px;font-size:" + evt.srcElement.options[evt.srcElement.selectedIndex].innerHTML + "></span>";
		var mark = oRange.getBookmark();
		var x = oRange.move("character", 1);
		if (x > 0)
		{
			oRange.moveToBookmark(mark);
			oRange.pasteHTML(tag);
		}
		else
		{
			var o = oRange.parentElement();
			if (o.currentStyle.display == "block")
				oRange.pasteHTML(tag);
			else
				o.insertAdjacentHTML("afterEnd", tag);
		}
		oRange.moveToElementText(idobj("TEMPSPAN", doc));
		idobj("TEMPSPAN", doc).style.width = "";
		idobj("TEMPSPAN", doc).removeAttribute("id");
		oRange.select();
	}

	function Init()
	{
		if (typeof domobj != "object")
			return;
		var text = domobj.innerHTML;
		domobj.innerHTML = "<div class=HTMLEditToolbar></div>" +
			"<div style='width:100%;height:100%;padding-bottom:28px;overflow:hidden;'>" +
			"<iframe id=HTMLEditFrame class=HTMLEditorFrame frameborder=0></iframe></div>" +
			"<textarea style=border:0;width:100%;height:100%;display:none; name=" + cfg.EName + "></textarea>";
//			"<div style='width:100%;height:26px;background-color:" + cfg.footbkcolor + "'></div>";
		menudef = [];
		if (cfg.nType == 1)	//compelete
		{
			menudef[0] = {title:"查看", img:cfg.pdir + "tasks16.gif", child:[
				{item:"页面预览", action:preview}, {item:"查看HTML源代码", action:viewsource}]}; 
			menudef[1] = {}; 
			menudef[2] = {title:"剪切", cmd:"Cut", img:cfg.pdir + "cut.gif", action:execCommand};
			menudef[3] = {title:"复制", cmd:"Copy", img:cfg.pdir + "copy.gif", action:execCommand};
			menudef[4] = {title:"粘贴", cmd:"Paste", img:cfg.pdir + "paste.gif", action:execCommand};
			menudef[5] = {title:"属性", img:cfg.pdir + "property.gif", action:prop};
			menudef[6] = {};
		}
		if ((cfg.nType == 1) || (cfg.nType == 2))	//compelete or middle
		{	
			menudef[menudef.length] = "<select id=psel align=middle style=width:54px><option value=P>普通</option>" +
				"<option value=H1>标题1</option><option value=H2>标题2</option><option value=H3>标题3</option>" +
				"<option value=H4>标题4</option><option value=H5>标题5</option><option value=H6>标题6</option>" +
				"<option value=PRE>已编排格式</option><option value=ADDRESS>地址</option></select>";
			menudef[menudef.length] = "<select id=fsel align=middle style=width:54px><option value=宋体>宋体</option>" +
				"<option>仿宋</option><option>黑体</option><option>楷体</option><option>隶书</option><option>幼圆</option>" +
				"<option>新宋体</option><option>微软雅黑</option><option>细明体</option>" +
				"<option>Arial</option><option>Arial Black</option><option>Arial Narrow</option>" +
				"<option>Bradley Hand ITC</option><option>Brush Script MT</option><option>Century Gothic</option>" +
				"<option>Comic Sans MS</option><option>Courier</option><option>MS Sans Serif</option>" +
				"<option>Script</option><option>System</option><option>Times New Roman</option>" +
				"<option>Viner Hand ITC</option><option>Verdana</option><option>Wide Latin</option><option>Wingdings</option></select>";
			menudef[menudef.length] = "<select id=ssel align=middle style=width:44px><option>9px</option><option>10px</option><option>11px</option>" +
				"<option>12px</option><option>13px</option><option>14px</option><option>15px</option>" +
				"<option>16px</option><option>18px</option><option>20px</option><option>22px</option>" +
				"<option>24px</option><option>26px</option><option>28px</option><option>36px</option>" +
				"<option>48px</option><option>72px</option></select>";
			menudef[menudef.length] = {title:"字体颜色", cmd:"ForeColor", img:cfg.pdir + "fgcolor1.gif", action:setcolor};
			menudef[menudef.length] = {title:"背景颜色", cmd:"BackColor", img:cfg.pdir + "fbcolor1.gif", action:setcolor};
			menudef[menudef.length] = {};
		}
		if ((cfg.nType == 1) || (cfg.nType == 2) || (cfg.nType == 3))	//compelete or middle or short
		{
			spos = menudef.length;
			menudef[menudef.length] = {title:"粗体", cmd:"Bold", img:cfg.pdir + "bold.gif", action:execCommand};
			menudef[menudef.length] = {title:"斜体", cmd:"Italic", img:cfg.pdir + "italic.gif", action:execCommand};
			menudef[menudef.length] = {title:"下划线", cmd:"Underline", img:cfg.pdir + "under.gif", action:execCommand};
			menudef[menudef.length] = {title:"删除线", cmd:"StrikeThrough", img:cfg.pdir + "strike.gif", action:execCommand};
			menudef[menudef.length] = {title:"左对齐", cmd:"JustifyLeft", img:cfg.pdir + "aleft.gif", action:execCommand};
			menudef[menudef.length] = {title:"居中", cmd:"JustifyCenter", img:cfg.pdir + "center.gif", action:execCommand};
			menudef[menudef.length] = {title:"右对齐", cmd:"JustifyRight", img:cfg.pdir + "aright.gif", action:execCommand};
			menudef[menudef.length] = {title:"项目符号", cmd:"InsertUnorderedList", img:cfg.pdir + "bullist.gif", action:execCommand}; 
			menudef[menudef.length] = {title:"数字编号", cmd:"InsertOrderedList", img:cfg.pdir + "numlist.gif", action:execCommand};
			menudef[menudef.length] = {};
		}
		if ((cfg.nType == 1) || (cfg.nType == 2))	//compelete or middle
		{	
			menudef[menudef.length] = {title:"表格", img:cfg.pdir + "tablesel.gif", child:[
				{item:"插入表格", img:cfg.pdir + "table.gif", action:insertTable},
				{item:"插入行", img:cfg.pdir + "insrow.gif", action:insertRow},
				{item:"删除行", img:cfg.pdir + "delrow.gif", action:deleteRow},
				{item:"插入列", img:cfg.pdir + "inscol.gif", action:insertCol},
				{item:"删除列", img:cfg.pdir + "delcol.gif", action:deleteCol},
				{item:"插入单元格", img:cfg.pdir + "inscell.gif", action:insertCell},
				{item:"删除单元格", img:cfg.pdir + "delcell.gif", action:deleteCell},
				{item:"横扩单元格", cmd:1, img:cfg.pdir + "excellh.gif", action:exCell},
				{item:"纵扩单元格", cmd:2, img:cfg.pdir + "excellv.gif", action:exCell}]};
			menudef[menudef.length] = {title:"插入链接", cmd:"CreateLink", img:cfg.pdir + "link.gif", action:execCommand};
			menudef[menudef.length] = {title:"插入图片", img:cfg.pdir + "image.gif", action:insertImg};
		}
		if (cfg.nType > 0)
		{
			tool = new CommonMenubar(menudef, domobj.firstChild);
			cb = tool.getDomItem("字体颜色");
			bb = tool.getDomItem("背景颜色");
			pb = tool.getDomItem("属性");
			if ((cfg.nType == 1) || (cfg.nType == 2))	//compelete or middle
			{
				objall(domobj, "psel").onchange = formatblock;
				objall(domobj, "fsel").onchange = selfont;
				objall(domobj, "ssel").onchange = selsize;
			}
		}
		else
			domobj.firstChild.style.display = "none";
		doc = objall(domobj, "HTMLEditFrame").contentWindow.document;
		if (text == "")
			text = "<p>&nbsp;</p>";
		doc.write("<HTML><head><link rel='stylesheet' type='text/css' href='" + cfg.css + "'></head><BODY style=margin:0px;>" + text + "</BODY><HTML>");
		domobj.lastChild.value = text;
		doc.designMode = "on";
		doc.oncontextmenu = EditorMenu;
		doc.onmouseup = SetStatus;
//		doc.onkeydown = KeyFilter;
		doc.onkeyup = SetStatus;
	}
	cfg = FormatObjvalue({EName:domobj.id, toolbkcolor:"#f7f5f4", footbkcolor:"#eeeeee", css: "../com/forum.css", pdir:"../com/pic/", nType:1}, cfg);
	Init();
	
	this.copydata = function()
	{
		objall(domobj, cfg.EName).value = doc.getElementsByTagName("HTML")[0].outerHTML;
	};

	this.gettool = function ()
	{
		return tool;
	};

	this.getdoc = function ()
	{
		return doc;
	};

	this.insertHTML = function (tag)
	{
		doc.body.focus();
	 	var oRange = doc.selection.createRange();
		oRange.pasteHTML(tag);
	};
}

//动态编辑框类集合
var DynaEditor = {};
//基类,实现一个有下拉箭头的编辑框,点击弹出下拉内容,具体内容由派生类实现.
DynaEditor.Base = function(width, height)
{
	var self = this;
	self.oHost = undefined;
	self.oEdit = undefined;
	self.oBox = undefined;
	self.bAutoPop = true;
	self.value = "";
	self.bLastValue = true;
	this.attach = function(obj, flag)
	{
		if (flag || (flag == 1))
			return objevent(obj, "mousedown", this.show);
		objevent(obj, "focus", this.show);
	};

	this.detach = function(obj, flag)
	{
		if (flag || (flag == 1))
			return objevent(obj, "onmousedown", this.show, 1);
		objevent(obj, "focus", this.show, 1);
	};

	this.insert = function(obj, width, height, value)
	{
		this.create();
		obj.parentNode.appendChild(self.oEdit);
		self.oEdit.style.position = "static";
		self.oEdit.style.display = "inline-block";
		if (typeof width != "undefined")
			self.oEdit.style.width = width;
		if (typeof height != "undefined")
			self.oEdit.style.height = height;
		if (typeof value != "undefined")
		{
			self.value = value;
			self.oEdit.firstChild.value = value;
			self.oEdit.firstChild.select();
			self.oEdit.firstChild.focus();
		}
	};
	
	this.remove = function ()
	{
		self.oEdit.parentNode.removeChild(self.oEdit);
	};
	
	this.create = function()
	{
		self.oEdit = document.createElement("SPAN");
		self.oEdit.style.position = "absolute";
		self.oEdit.style.overflow = "hidden";
		self.oEdit.style.display = "none";
		self.oEdit.style.border = "1px solid gray";
		self.oEdit.innerHTML = "<input type=text style='overflow:hidden;border:none;width:100%;height:100%;margin:0 13px 0 0'>" +
			"<span unselectable=on style='background-color:white;cursor:default;font-family:webdings;vertical-align:top;margin-left:-13px;width:13px;height:100%;overflow:hidden'>" +
			"<span unselectable=on style=position:relative;top:-6px;>6</span></span>";
		document.body.appendChild(self.oEdit);
		self.oEdit.firstChild.onchange = self.onChange;
//		self.oEdit.firstChild.onblur = self.hide;
		self.oEdit.firstChild.onkeydown = self.keydown;
		self.oEdit.lastChild.onmouseover = OverButton;
		self.oEdit.lastChild.onmouseout = OutButton;
		self.oEdit.lastChild.onmousedown = self.popDown;
	};
	
	this.show = function()
	{
		self.hide();
		var evt = getEvent();
		self.oHost = evt.srcElement;
		var pos = GetObjPos(self.oHost);
		if (typeof self.oEdit == "undefined")
			self.create();
		self.oEdit.style.display = "";
		self.oEdit.style.width = (pos.right - pos.left + 2) + "px";
		self.oEdit.style.height = (pos.bottom - pos.top + 2) + "px";
		self.oEdit.style.left = pos.left + "px";
		self.oEdit.style.top = (pos.top - 1) + "px";

		self.oHost.style.visibility = "hidden";
		self.oEdit.firstChild.value = self.getHostValue();
		self.onshow();
		if (self.bAutoPop)
			self.popDown();
		self.oEdit.firstChild.select();
		self.oEdit.firstChild.focus();
		window.setTimeout(function(){ objevent(document.body, "mousedown", CheckFocus);}, 1);
	};
	
	this.onshow = function ()
	{
		if (self.bLastValue && (Trim(self.oEdit.firstChild.value) == "") && (self.value != ""))
			self.setValue(self.value);
	};
	
	this.getHostValue = function ()
	{
		if (self.oHost.tagName == "INPUT")
			return self.oHost.value;
		return objtext(self.oHost);
	}

	this.hide = function()
	{
		if (typeof self.oHost == "object")
		{
			self.oHost.style.visibility = "visible";
			self.oEdit.style.display = "none";
		}
		if (typeof self.oBox == "object")
			self.oBox.hide();
		self.blur(self.oHost);
		objevent(document.body, "mousedown", CheckFocus, 1);
	};
	
	function CheckFocus()
	{
		if (typeof self.oBox != "object")
			return self.hide(true);
		var evt = getEvent();
		if (isParentObj(evt.srcElement, self.oBox.getdomobj()))
			return;
		if (isParentObj(evt.srcElement, self.oEdit))
			return;
		self.hide(true);
	}
	
	this.blur = function (oHost) {};
	
	this.onChange = function()
	{
		self.value = self.oEdit.firstChild.value;
		if (typeof self.oHost == "object")
		{
			if (self.oHost.tagName == "INPUT")
				self.oHost.value = self.oEdit.firstChild.value;
			else
				objtext(self.oHost, self.oEdit.firstChild.value);
			if ((self.oHost.tagName == "INPUT") || (self.oHost.tagName == "TEXTAREA"))
				fireobjevt(self.oHost, "change");
		}
		self.valueChange(self.oHost);
	}

	this.valueChange = function (oHost) {};
	
	this.setValue = function(value)
	{
//		if (self.oEdit.firstChild.value == value)
//			return;
		self.value = value;
		self.oEdit.firstChild.value = value;
		fireobjevt(self.oEdit.firstChild, "change");
	};
	
	this.getValue = function ()
	{
		return self.value;
	};
	
	this.confirm = function(value)
	{
		self.setValue(value);
		self.hide();
	};
	
	this.createPop = function()
	{
		var tag = "<div style='border:1px solid gray;width:" + self.width  + ";height:" + self.height + "'></div>";
		self.oBox.setPopObj(tag);
		
	};
	
	this.onpop = function()	{};
	
	function OverButton()
	{
		self.oEdit.lastChild.style.borderLeft = "1px solid gray";
		self.oEdit.lastChild.style.filter = "progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#f6faff', EndColorStr='#86dffe')";
	}
	
	function OutButton()
	{
		self.oEdit.lastChild.style.borderLeft = "1px solid transparent";
		self.oEdit.lastChild.style.filter = "";
	}

	this.popDown = function()
	{
		self.width = width;
		self.height = height;
		var pos = GetObjPos(self.oEdit);
		if ((self.width == 0) || (typeof self.height == "undefined"))
			self.width = pos.right - pos.left;
		if ((self.height == 0) || (typeof self.height == "undefined"))
			self.height = 200;

		if (typeof self.oBox == "undefined")
		{
			self.oBox = new PopupBox("", pos.left, pos.top, pos.left, pos.bottom - 1);
			self.createPop();
			self.oBox.hide();
		}
		if (self.oBox.isShow())
			self.oBox.hide();
		else
		{
			self.onpop();
			self.oBox.show(pos.left, pos.top, pos.left, pos.bottom - 1);
		}
	};
	
	this.hidePop = function ()
	{
		if (typeof self.oBox == "object")
			self.oBox.hide();
	};
	this.keydown = function (){};
	
	this.keydownHost = function (){};
};

//动态日期编辑框,继承自DynaEditor.Base
DynaEditor.Date = function (width, height)
{
	var self = this;
	var calendar;
	DynaEditor.Base.call(this, width, height);
	
	this.createPop = function ()
	{
		var obj = self.oBox.getdomobj();
		calendar = new CalendarBase(0, obj);
		obj.className = "CanlendarDiv";
		obj.style.border = "1px solid gray";
		obj.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray)";
		obj.style.width = self.width;
		obj.style.height = self.height;
		calendar.clickDate = this.confirm;
		calendar.onReady = DateReady;
	};
		
	this.onpop = function ()
	{
		calendar.show(self.oEdit.firstChild.value);
		var d = calendar.getDate();
		self.oEdit.firstChild.value = d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
		calendar.selDateCell(d);
	};

	function DateReady()
	{
		self.oBox.unselect();
	}
};

//动态列表编辑框,继承自DynaEditor.Base
DynaEditor.List = function(data, width, height)
{
	var self = this;
	DynaEditor.Base.call(this, width, height);
	var shadow = new CommonShadow(1, "SelectObj");
		
	this.createPop = function ()
	{
		var tag = "";
		if (typeof data == "string")
		{
			var ss = data.split(",");
			for (var x = 0; x < ss.length; x++)
				tag += "<div style=cursor:default;width:100%;height:20px;white-space:nowrap;padding-left:4px>" + ss[x] + "</div>";
		}
		self.oBox.setPopObj(tag);
		var div = self.oBox.getdomobj();
		div.style.border = "1px solid gray";
		div.style.filter = "progid:DXImageTransform.Microsoft.Shadow(direction=135,strength=2,color=gray)";
		div.style.overflowY = "auto";
		div.style.overflowX = "hidden";
		div.style.height = self.height;
		div.onclick = function ()
		{
			var evt = getEvent();
			if (evt.srcElement != div)
				self.confirm(objtext(evt.srcElement));
		};
		div.onmouseover = function()
		{
			var evt = getEvent();
			var obj = evt.srcElement;
			if (obj.tagName != "DIV")
				obj = obj.parentNode;
			if (obj != div)
				 shadow.show(obj);
		};
	};
	
	this.onpop = function()
	{
		var div = self.oBox.getdomobj();
		div.style.width = self.width;
		if ((typeof(self.height) != "undefined") && (div.clientHeight > self.height))
			div.style.height = self.height;
	};
	
	this.setData = function (d)
	{
		data = d;
		if (typeof self.oBox == "object")
		{
			shadow.hide();
			self.oBox.remove();
			self.oBox = undefined;
		}
		self.value = "";
	};
	
	this.getData = function ()
	{
		return data;
	};
	
	this.keydown = function ()
	{
		var sel = shadow.getObj();
		var evt = getEvent();
		switch (evt.keyCode)
		{
		case 40:		//down
			if (typeof sel == "object")
				sel = sel.nextSibling;
			break;
		case 38:		//up
			if (typeof sel == "object")
				sel = sel.previousSibling;
			break;
		case 13:	//enter
			self.confirm(self.oEdit.firstChild.value);
		default:
			return;
		}
		if (typeof self.oBox != "object")
			return;
		var div = self.oBox.getdomobj();
		if (typeof sel == "undefined")
			sel = div.firstChild;
		else if (sel == null)
			return;
		shadow.show(sel);
		sel.scrollIntoView(false);
//		self.setValue(sel.innerText);
		self.value = objtext(sel);
		self.oEdit.firstChild.value = objtext(sel);
	};
};

DynaEditor.TreeList = function(data, width, height)
{
	var self = this;
	DynaEditor.Base.call(this, width, height);
	var expic, tree;
	
	function ClickTree(obj)
	{
		tree.select(obj);
		var item = tree.getTreeItem();
		self.confirm(item.item);
	}
	
	this.createPop = function ()
	{
		var tag = "<div style='border:1px solid gray;width:" + self.width  + ";height:" + self.height + "'></div>";
		self.oBox.setPopObj(tag);
		var domObj = self.oBox.getdomobj();
		tree = new TreeView(domObj.firstChild, data);
		if (typeof expic != "undefined")
			tree.setexpic(expic);
		tree.click = ClickTree;
	};
	
	this.setexpic = function(pic)
	{
		expic = pic;
	};
	
	
}

//动态编辑框,继承自DynaEditor.Base,也是选择框,文本框等对象的基类
DynaEditor.Input = function(width, height)
{
	var self = this;
	DynaEditor.Base.call(this);
	this.create = function()
	{
		var tag = self.createTag();
		if (typeof tag == "string")
		{
			self.oEdit = document.createElement("SPAN");
			self.oEdit.style.position = "absolute";
			self.oEdit.innerHTML = tag;
		}	
		if (typeof tag == "object")
			self.oEdit = tag;
		document.body.appendChild(self.oEdit);
		self.oEdit.firstChild.onchange = self.onChange;
		self.oEdit.firstChild.onblur = self.hide;
		self.oEdit.onkeydown = keydown;
	};
	this.show = function()
	{
		var evt = getEvent();
		self.oHost = evt.srcElement;
		if (typeof self.oEdit == "undefined")
			self.create();
		var pos = GetObjPos(self.oHost);
		if ((width == undefined) || (width == 0))
			self.oEdit.style.width = (pos.right - pos.left + 2) + "px";
		else
			self.oEdit.style.width = width;
		if ((height == undefined) || (height == 0))
			self.oEdit.style.height = (pos.bottom - pos.top + 2) + "px";
		else
			self.oEdit.style.height = height;
		self.oEdit.style.left = (pos.left - 1) + "px";
		self.oEdit.style.top = (pos.top - 1) + "px";
		self.oEdit.style.display = "inline";
		self.oEdit.firstChild.value = self.getHostValue();
		self.oHost.style.visibility = "hidden";
		self.onshow();
		self.oEdit.firstChild.focus();
	};
	this.createTag = function ()
	{
		return "<input type=text style='width:100%;height:100%;'>";
	};
	
	function keydown()
	{
	}
};

//动态文本框,继承自DynaEditor.Input
DynaEditor.Text = function(width, height)
{
	var self = this;
	DynaEditor.Input.call(this, width, height);
	this.createTag = function()
	{
		self.bLastValue = false;
		return "<textarea style='width:100%;height:100%;'></textarea>";
	};
};

//动态选择框,继承自DynaEditor.Input
DynaEditor.Select = function(data)
{
	var self = this;
	DynaEditor.Input.call(this);
	this.createTag = function()
	{
		var tag = "";
		if (typeof data == "string")
		{
			var ss = data.split(",");
			for (var x = 0; x < ss.length; x++)
				tag += "<option value=" + ss[x] + ">" + ss[x] + "</option>";
		}
		return "<select style='width:100%;height:100%;padding:1px'>" + tag + "</select>";
	};
};

//动态组合框,继承自DynaEditor.Select
DynaEditor.Combo = function(data)
{
	var self = this;
	DynaEditor.Select.call(this, data);
	function selchange()
	{
		self.setValue(self.oEdit.lastChild.value);
	}
	var _createTag = this.createTag;
	this.createTag = function()
	{
		var tag =_createTag();
		tag = "<input type=text style='border:1px solid #cccccc;padding-left:2px;" +
			"overflow:border-right:none;hidden;width:100%;height:20px;margin:-1 15px 0 1'>" + tag;
		var oEdit = document.createElement("div");
		oEdit.style.position = "absolute";
		oEdit.innerHTML = tag;
		oEdit.lastChild.style.position = "absolute";
		oEdit.lastChild.style.left = "0px";
		oEdit.lastChild.onchange = selchange;
		oEdit.lastChild.UNSELECTABLE = "on";
		return oEdit;
	};
	var _onshow = this.onshow;
	this.onshow = function ()
	{
		self.oEdit.lastChild.style.clip = "rect(0," + self.oEdit.clientWidth + "," +
			self.oEdit.clientHeight + "," + (self.oEdit.clientWidth - 18) + ")";
		_onshow();
		self.oEdit.lastChild.value = self.oEdit.firstChild.value;
	};
};

//动态增量框,继承自DynaEditor.Input
DynaEditor.Spin = function (minvalue, maxvalue, stepvalue)
{
	var self = this;
	var t = new Date();
	DynaEditor.Input.call(this, 0, 0);
	var _create = this.create;
	this.create = function()
	{
		_create();
		this.oEdit.lastChild.onscroll = run;
		this.oEdit.lastChild.scrollTop = 50;
	};

	function run()
	{
		var t1 = new Date();
		if (t1.getTime() - t.getTime() < 180)
			return;
		t = t1;
		var evt = getEvent();
		var cfp = self.oEdit.lastChild.componentFromPoint(evt.clientX, evt.clientY);
		switch (cfp)
		{
		case "scrollbarDown":
			self.setValue(self.cal(self.oEdit.firstChild.value, 1));
			break;
		case "scrollbarUp":
			self.setValue(self.cal(self.oEdit.firstChild.value, -1));
			break;
		}
		self.oEdit.lastChild.scrollTop = 50;
	}
	
	this.cal = function(value, step)
	{
		var result = parseInt(value) + stepvalue * step;
		if (result > maxvalue)
			result = maxvalue;
		if (result < minvalue)
			result = minvalue;
		 return result;
	}

	this.createTag = function()
	{
		return "<input type=text style='width:100%;height:18px;position:absolute;border:none;border-right:20px solid transparent;top:1px;left:1px;'>" +
			"<div UNSELECTABLE=on style='position:absolute;overflow-y:scroll;overflow-x:hidden;width:100%;height:20px;border:1px solid gray;'>" +
			"<div UNSELECTABLE=on style=height:100px;></div></div>";
	};

};

//动态带提示的搜索框,或自动完成编辑框,继承自DynaEditor.List
DynaEditor.Search = function(hisfun, runfun)
{
	var self = this;
	var marginRight = 16;
	var img = "<img UNSELECTABLE=on src=../com/pic/search.png style=margin-left:-" + marginRight + "px>";
	DynaEditor.List.call(this);
	this.create = function ()
	{
		self.oEdit = document.createElement("SPAN");
		self.oEdit.style.position = "absolute";
		self.oEdit.style.border = "1px solid #9BC9EB";
		self.oEdit.style.overflow = "hidden";
		self.oEdit.innerHTML = "<input type=text style='border:none;width:100%;margin:-1px " + 
			(marginRight + 2) + " 0 1px;'>" + img;
		self.oEdit.firstChild.onkeydown = self.keydown;
		self.oEdit.firstChild.onpropertychange = valuechange;
		self.oEdit.firstChild.oninput = valuechange;
		if ((typeof runfun == "function") && (img != ""))
			self.oEdit.lastChild.onclick = run;
		else
		{
			if (img != "")
				self.oEdit.lastChild.style.display = "none";
			self.oEdit.firstChild.style.marginRight = "0px";
		}
		document.body.appendChild(self.oEdit);
		self.oEdit.firstChild.onchange = self.onChange;
//		self.oEdit.firstChild.onblur = self.hide;
		self.bAutoPop = false;
	};
		
	function valuechange()
	{
		if (self.oEdit.firstChild.value == self.value)
			return;
		if (typeof document.selection == "object")
		{
			if (document.selection.createRange().parentElement() != self.oEdit.firstChild)
				return;
		}
		self.value = self.oEdit.firstChild.value;
		if (typeof hisfun != "function")
			return;
		var data = hisfun(self.value);
		if ((typeof data == "string") && (data != ""))
		{
			self.setData(data);
			self.popDown();
		}
		else
			self.hidePop();
	}

	function run()
	{
		if (typeof runfun == "function")
			runfun(self.oEdit.firstChild.value);
	}

	this.confirm = function(value)
	{
		self.setValue(value);
		self.hide();
		run();
	};
	
	this.setImg = function (pic, width)
	{
		if ((typeof pic != "string") || (pic == ""))
		{
			img = "";
			marginRight = 0;
			return;
		}
		if (typeof width != "undefined")
			marginRight = width;

		if (pic.substr(0, 1) == "<")
			img = pic
		else
			img = "<img UNSELECTABLE=on src=" + pic + " style=margin-left:-" + marginRight + "px>";
	}
};

//动态字体颜色选择对话框
DynaEditor.FontSel = function()
{
	var self = this;
	DynaEditor.Base.call(this);

};

//动态文件上传框
DynaEditor.FileUpload = function(saveurl)
{
	var self = this;
	DynaEditor.Input.call(this, data);

};

function FileUpload()
{
var self = this;
var ocx;
var root = GetRootPath();
var url = root + "/com/upfile.jsp";
var taskcnt = 0;
	function Init()
	{
		if (typeof ocx == "object")
			return true;
		if (document.getElementById("htexOCX") != "object")
			document.body.insertAdjacentHTML("beforeEnd", "<object classid=clsid:805E221F-1C22-424B-BDCD-9CE834919407 codebase=" +
				root + "/htex.ocx" + " id=htexOCX width=1 height=1></object>");
		ocx = document.getElementById("htexOCX");
		ocx.onerror = function ()
		{
			ocx.onerror = null;
			ocx.parentNode.removeChild(ocx);
			ocx = undefined;
			if (confirm("重要提示：未能加载安装文件上传控件。\n" +
				"您必须将本站点" + location.hostname + "加入到可信站点，并在安全设置中启用：\n" +
				"下载未签名的ActiveX控件、未标记为可安全执行脚本的ActiveX控件初始化并执行脚本，并允许本页面出现的ActiveX控件的安装选项。才可使用文件上传控件。\n是否要重新安装?"))
				Init();
			return false;
		}
//		ocx.attachEvent("htexEvent", htexEvent); DocBody
		// lxt w3c 2017.11.13
		if(ocx.attachEvent)
		ocx.attachEvent("PostFileEvent", PostFileEvent);
		else ocx.addEventListener("PostFileEvent", PostFileEvent, false);
	}

	function PostFileEvent(id, param1, param2)
	{
		var evtName, info;
		switch (id)
		{
		case 1:
			evtName = "SendFileBegin";
			info = ocx.HTTPPostGetValue(param1, 1);
			break;
		case 2:
			evtName = "SendFileProgress";
			info = ocx.HTTPPostGetValue(param1, 2);
			break;
		case 3:
			evtName = "SendFileOK";
			info = ocx.HTTPPostGetValue(param1, 4);
			var ss = info.split(":");
			var ID = parseInt(ss[1]);
			if (ID <= 0)
				evtName = "SendFileCancel";
			taskcnt --;
			break;
		case 4:
			evtName = "SendFileFail";
			info = ocx.HTTPPostGetValue(param1, 5);
			taskcnt --;
			break;
		default:
			alert("ERROR" + id);
			return;
		}
		self.progress(evtName, param1, info);
	}

	function htexEvent(evtName, param1, param2)
	{
		switch (evtName)
		{
		case "SendFileBegin":
		case "SendFileProgress":
			break;
		case "SendFileOK":
		case "SendFileFail":
			taskcnt --;
			break;
		}
		self.progress(evtName, param1, param2);
	}
	
	this.upload = function(filename, folder, id)
	{
		if (typeof this.getocx() != "object")
			return -1;
		var posturl = url + "?saveto=" + folder;
		if (typeof id != "undefined")
			posturl += "&affixid=" + id;
		var id = ocx.HTTPPostFile(filename, posturl, document.cookie, 1);
		if (id >= 0)
			taskcnt ++;
		return id;
	};

	this.upfile = function(filename, option)
	{
		if (typeof this.getocx() != "object")
			return "错误，未能上传，上传组件未能正常启动";
		if (typeof option != "object")
			return "错误，未能上传，参数定义不正确";
		var posturl = url, sp = "?";
		for (var key in option)
		{	//可选参数,affixid, DestDir, ParentID, SecretType, saveto
			posturl += sp + key + "=" + option[key];
			sp = "&";
		}
		var id = ocx.HTTPPostFile(filename, posturl, document.cookie, 1);
		if (id >= 0)
			taskcnt ++;
		return id;		
	}

	this.stop = function(id)
	{
		ocx.HTTPPostStop(id);
		if (taskcnt > 0)
			taskcnt --;
	};
	
	this.getocx = function()
	{
		if (typeof ocx != "object")
			Init();
		return ocx;
	};

	this.gettask = function()
	{
		return taskcnt;
	};
	
	this.openfile = function(fun, option)
	{
		var o = document.createElement("<input type=file>");
		document.body.appendChild(o);
		o.style.display = "none";
		o.onchange = function ()
		{
			if (o.value != "")
			{
				if (typeof fun == "function")
					fun(o.value);
				else
				{
//					this.upload(o.value, "临时共享文件夹");
					this.upfile(o.value, option);
				}
			}
			o.onchange = null;
			o.parentNode.removeChild(o);
		}
		o.click();
	};
	
	this.progress = function (evt, param1, param2) {};
	Init();
}

function DragDrop()
{
var self = this;
var srcObj, bDragChanged;
var targets = new Array();
	function DragStart(obj)
	{
		var evt = getEvent();
		if (evt.button == 2)
			return;
	
//		obj.click();
		var oDiv = document.createElement("div");
		oDiv.innerHTML = obj.outerHTML;
		oDiv.style.display = "block";
		oDiv.style.position = "absolute";
		oDiv.style.filter = "alpha(opacity=70)";
		document.body.appendChild(oDiv);
		var p = GetObjPos(obj);
		oDiv.style.top = p.top + "px";
		oDiv.style.left = p.left + "px";
		BeginDragObj(oDiv);
		document.onmousemove = Draging;
		document.onmouseup = EndDrag;
		bDragChanged = 0;
		srcObj = obj;
	}

	function Draging()
	{
	var x, pos, tx, ty;
		DragingObj();
		var evt = getEvent();
		tx = evt.clientX;
		ty = evt.clientY;
		for (x = 0; x < targets.length; x++)
		{
			if (targets[x] != srcObj)
			{
				pos = GetObjPos(targets[x]);
				if(tx >= pos.left && tx <= pos.right && ty >= pos.top && ty <= pos.bottom)
				{
					if (self.dragtest(targets[x]))
					{
						targets[x].insertAdjacentElement("afterEnd", srcObj);
						bDragChanged = 1;
					}
				}
			}
		}
	}

	function EndDrag()
	{
		ResetObjPos(dragObj, 15);
		EndDragObj();
	}

	function ResetObjPos(obj, delta)
	{
		var pos = GetObjPos(dragObj);
		var tx = parseInt(obj.style.left);
		var ty = parseInt(obj.style.top);
		var dx = (tx - pos.left) / delta;
		var dy = (ty - pos.top) / delta;
		var oInterval = window.setInterval(function()
		{
			if (delta > 1)
			{
				delta --;
				tx -= dx;
				ty -= dy;
				if (tx < 0)
					tx = 0;
				if (ty < 0)
					ty < 0;
				obj.style.left = tx + "px";
				obj.style.top = ty + "px";
			}
			else
			{
				clearInterval(oInterval);
				obj.parentNode.removeChild(obj);
//				if (bDragChanged == 1)
//					UserDragFun(2, SeekDragSrcObj, oldParent);
				return;
			}
		}, 20);
	}

	this.attachSrc = function(hitobj, dragobj)
	{
		if (typeof dragobj == "undefined")
			dragobj = hitobj;
		hitobj.onmousedown = function () 
		{
			DragStart(dragobj);
		};
	};
	
	this.detachSrc = function(hitobj)
	{
		hitobj.onmousedown = null;
	};
	
	this.attachTarget = function (obj)
	{
		targets[targets.length] = obj;
	};
	
	this.detachTarget = function (obj)
	{
		
	};
	
	this.ondrag = function()
	{
	};
	
	this.ondraging = function ()
	{
	};
	
	this.ondragend = function ()
	{
	};
	
	this.dragtest = function(obj)
	{
		return true;
	}
}

function WebOffice(ocx, filename, openurl, saveurl)
{
	var self = this;
	var imenu;

	function Init()
	{
		ocx.attachEvent("OnDocumentOpened", onDocumentOpened);
		switch (filename) 
		{
		case ".xls":
			ocx.CreateNew("Excel.Sheet");
			break;
		case ".ppt":
			ocx.CreateNew("PowerPoint.Show");
			break;
		case ".doc":
			ocx.CreateNew("Word.Document");
			break;
		default:
			if (filename != "")
				ocx.Open(openurl + filename, false);
			break;
		}
	}
	
	
	function onDocumentOpened(file, doc)
	{
		addmenu();
	}
	
	function addmenu()
	{
		var pos = GetObjPos(ocx);
		imenu = document.createElement("iframe");
		imenu.frameBorder = "no";
		document.body.appendChild(imenu);
		imenu.style.position = "absolute";
		imenu.style.width = (pos.right - pos.left - 530) + "px";
		imenu.style.height = "20px";
		imenu.style.top = (pos.top + 3) + "px";
		imenu.style.left = (pos.left + 520) + "px";
		imenu.scrolling = "no";
		imenu.contentWindow.document.write("<html><style type=text/css>" +
			"span{font-size:9pt;padding:2px 5px 0px 5px;}</style>" +
			"<body bgcolor=threedface scroll=no style=margin:3px><div id=webofficemenu style=cursor:hand>" +
			"<span>保存</span>" +
			"</div></body></html>");
		imenu.contentWindow.document.close();
//			"<span>痕迹</span><span>取消痕迹</span>"<span>接受修改</span><span>禁止修订</span><span>禁止</span>" +
		idobj("webofficemenu", imenu.contentWindow.document).onclick = SaveDoc;

	}
	
	function SaveDoc()
	{
		alert("save");
		ocx.HttpAddPostString("rename", this.rename); 
		ocx.HttpAddPostString("loadtype", "doc,xls,ppt"); 
		ocx.HttpAddPostString("filepath", this.serverPath); 
		ocx.HttpAddPostCurrFile("file1", this.docName);
		var rtn = ocx.HttpPost(saveurl);
	}
	Init();
}

function OfficeInput(domobj)
{
	var self = this;
	var hidobj = domobj.previousSibling;
	var conobj = domobj.parentNode;
	var readonly = parseInt(hidobj.getAttribute("bReadonly"));
	var rows = hidobj.rows;
	var username = hidobj.getAttribute("user");
	var editmode = hidobj.getAttribute("editmode");
	var App, oUpload;	
	var doclist = [];
	var watch;
	var root = GetRootPath();

	function InitDoc()
	{
		var ss = hidobj.value.split(",");
		for (var x = 0; x < ss.length; x++)
		{
			doclist[x] = {};
			if (ss[x] == "")
				var sss = ["0", ""];
			else
				var sss = ss[x].split(":");
			
			doclist[x].id= parseInt(sss[0]);
			if (sss.length > 1)
				doclist[x].name = sss[1];
			else
				doclist[x].name = "";
			if (x == 0)
				InitDocbar(domobj, x);
			else
				InitDocbar(0, x);
		}
	}

	function OfficeUploadEvent(evt, param1, param2)
	{
		switch (evt)
		{
		case "SendFileBegin":
			break;
		case "SendFileProgress":
			break;
		case "SendFileOK":
			var ss = param2.split(":");
			var uploadid = parseInt(param1);
			if (ss[0] == "OK")
			{
				for (var x = 0; x < doclist.length; x++)
				{
					if (doclist[x].uploadid == uploadid)
					{
						doclist[x].id = parseInt(ss[1]);
						doclist[x].uploadid = -1;
						doclist[x].fullname = 0;
						UploadOKEvent();
						break;
					}
				}
			}
			else
				alert(param2);
			SyncStatus();
			break;
		case "SendFileFail":
			oUpload.stop(param1);
			alert("错误", "上传OFFICE文件失败：" + param2);
			break;
		}
	}
	
	function UploadOKEvent() {}
	
	function InitDocbar(obj, index)
	{
		var result = "";
		if (typeof obj != "object")
		{
			obj = document.createElement("SPAN");
			obj.className = "OfficeInput";
			conobj.insertAdjacentHTML("beforeEnd", "<br>");
			conobj.appendChild(obj);
		}
		if (readonly == 0)
		{
			var o = obj;
			if ((editmode & 1) > 0)
				o = CreateDocButton(o, "新建", NewDoc);
			if ((editmode & 2) > 0)
				o = CreateDocButton(o, "上传", UploadDoc);
			if ((editmode & 4) > 0)
				o = CreateDocButton(o, "阅读", ReadDoc);
			if ((editmode & 8) > 0)
				o = CreateDocButton(o, "编辑", EditDoc);
			if ((editmode & 16) > 0)
				o = CreateDocButton(o, "下载", "", root + "/com/down.jsp?AffixID=" + doclist[index].id);
			if ((editmode & 32) > 0)
				o = CreateDocButton(o, "删除", DeleteDoc);
			if (typeof oUpload != "object")
			{
				oUpload = new FileUpload();
				oUpload.progress = OfficeUploadEvent;
			}
		}
		else
		{
			if (doclist[index].id != 0)
			{
				var o = obj;
				if ((editmode & 4) > 0)
					o = CreateDocButton(o, "阅读", ReadDoc);
				if ((editmode & 16) > 0)
					o = CreateDocButton(o, "下载", "", root + "/com/down.jsp?AffixID=" + doclist[index].id);
			}
		}
		obj.innerHTML = doclist[index].name;
	}

	function CreateDocButton(obj, name, click, href)
	{
		var o = document.createElement("A");
		o.innerHTML = name;
		if (click == "")
			o.href = href;
		else
		{
			o.onclick = click;
			o.href = "javascript:void(0)";
		}
		o.style.marginLeft = "5px";
		obj.insertAdjacentElement("afterEnd", o);
		return o;
	}

	function getDocIndex(obj)
	{
		var objs = conobj.getElementsByTagName("A");
		var index = -1;
		for (var x = 0; x < objs.length; x++)
		{
			if (objtext(objs[x]) == objtext(obj))
				index ++;
			if (objs[x] == obj)
				break;
		}
		return index;
	}
	
	function SetSyn()
	{
		if (typeof watch == "undefined")
			watch = window.setInterval(SyncStatus, 5000);
		SyncStatus();
	}

	function SyncStatus()
	{
		var objs = conobj.getElementsByTagName("SPAN");
		var cnt = 0;
		for (var x = 0; x < doclist.length; x++)
		{
			if (typeof doclist[x].doc == "object")
			{
				try
				{
					objs[x].innerHTML = doclist[x].doc.name + "<q style=color:gray>(编辑中...)</q>";
					if (doclist[x].name != doclist[x].doc.name)
						self.docChangeEvent(x, doclist[x].doc.name);
					doclist[x].name = doclist[x].doc.name;
					doclist[x].fullname = doclist[x].doc.FullName;
				}
				catch (e)
				{
					if (doclist[x].fullname == doclist[x].name)
						objs[x].innerHTML = doclist[x].name + "<q style=color:gray>(OFFICE错误。" + e.description + ")</q>";
					else if (doclist[x].uploadid > 0)
						objs[x].innerHTML = doclist[x].name + "<q style=color:gray>(已保存,正在上传...)</q>";
					else
						objs[x].innerHTML = doclist[x].name + "<q style=color:gray>(已保存,未上传)</q>";
				}
				cnt ++;
			}
			else
			{
				if ((typeof doclist[x].fullname == "string") && (doclist[x].fullname == doclist[x].name))
					objs[x].innerHTML = doclist[x].name;
				else
				{	if (doclist[x].fullname == 0)
						objs[x].innerHTML = doclist[x].name + "<q style=color:gray>(已上传)</q>";
					else if (doclist[x].uploadid > 0)
						objs[x].innerHTML = doclist[x].name + "<q style=color:gray>(已保存,正在上传...)</q>";
					else if (typeof doclist[x].fullname == "string")
						objs[x].innerHTML = doclist[x].name + "<q style=color:gray>(已保存,未上传)</q>";
					else
						objs[x].innerHTML = doclist[x].name;
				}
			}
		}
		if (cnt == 0)
		{
			clearInterval(watch);
			watch = undefined;
		}
	}
	
	function CreateApp()
	{
		if (typeof App != "object")
		{
			try
			{
				App = new ActiveXObject("Word.Application");
				App.visible=true;
				App.UserName = username;
			} catch (e)
			{
				alert("未能打开本地的OFFICE程序。" + e.description);
				return false;
			}
		}
		else
		{
			try
			{
				App.visible = true;
			}
			catch (e)
			{
				App = new ActiveXObject("Word.Application");
				App.visible=true;
				for (var x = 0; x < doclist.length; x++)
					doclist[x].doc = undefined;
			}
		}
	}
	
	function NewDoc()
	{
		if (CreateApp() == false)
			return;
		var doc = App.Documents.Add();
		App.Activate();
		doc.ActiveWindow.Activate();
		var index = doclist.length;
		if (doclist[index - 1].name == "")
		{
			doclist[index - 1].name = doc.FullName;
			doclist[index - 1].doc = doc;
			domobj.innerHTML = doc.FullName;
		}
		else
		{
			doclist[index] = {};
			doclist[index].id = 0;
			doclist[index].name = doc.FullName;
			doclist[index].status = "";
			doclist[index].doc = doc;
			InitDocbar(0, index);
		}
		SetSyn();
	}
	
	function EditDoc()
	{
		var evt = getEvent();
		var index = getDocIndex(evt.srcElement);
		
		
		// Electron lxt 2017.12.20
		if(window.g_isElectron){
			var span;
			if(evt && evt.target && evt.target.parentNode.getElementsByTagName("span").length>0)
				span=evt.target.parentNode.getElementsByTagName("span")[index];
			var url=root + "/com/down.jsp?AffixID=" + doclist[index].id;
			var fileAffixID=doclist[index].id;
			if(fileAffixID==0||!fileAffixID){
				alert("没有文件");
				return;
			}
			var filename=doclist[index].name;
			//span.innerHTML=filename+ "<q style=color:gray>(在修改...)</q>";
			top.g_sessionDownloadDoneCallbackx=function(obj){
				//alert(obj.savePath);
				if(!top.require("electron").shell.openItem(obj.savePath)){
					top.alert("请安装相应Office软件");
					return;
				}
				
				/* Electron 编辑word并自动上传覆盖 */
				var fs = top.require('fs');
				var filepath=obj.savePath;
				var filename=filepath.replace(/.*[\\\/]+([^\\\/]+)$/,"$1");
				//top.alert("ddd:"+obj.savePath);return;
				var filesuffix=filepath.replace(/.*\.(\w+)$/, "$1");
				
				// 循环判断是否更新了文件，然后上传
				var lastMTime;
				if(!window.g_checkFileUpdateTimer)
					window.g_checkFileUpdateTimer={};
				if(window.g_checkFileUpdateTimer["time"+fileAffixID]){
					window.clearTimeout(window.g_checkFileUpdateTimer["time"+fileAffixID]);
					window.g_checkFileUpdateTimer["time"+fileAffixID]=0;
				}
				var func=function(){
				  var stat = fs.statSync(filepath);
				  var mtime=stat.mtime;
				  if(!lastMTime) lastMTime=mtime;
				  if(mtime.getTime()-lastMTime.getTime()>0){
					  lastMTime=mtime;
					  fs.readFile(filepath,function(err,data){
						  //content.textContent = data;
						  //console.log("err:"+err)
						  var bb=new Blob([data]);
						  var fd = new FormData();
							fd.append("fileToUpload", bb);
							fd.append("Name", filename);
							fd.append("blob", 1);
							fd.append("AffixID", fileAffixID);
							var xhr = new XMLHttpRequest();
							//window.g_xhrForUpload=xhr;
							xhr.upload.addEventListener("progress", function(evt){
							   //alert("progress:"+evt);
							}, false);
							xhr.addEventListener("load", function(evt){
							  //var obj=eval("("+evt.target.responseText+")");
							
								//var xhref="/com/down.jsp?AffixID="+obj.affixID;
								//alert("load:"+xhref);
							   
							}, false);
							xhr.addEventListener("error", function(evt){
							  alert("文件【"+filename+"】上传中发生错误，错误码："+evt);
							}, false);
							xhr.addEventListener("abort", function(evt){
							  alert("文件【"+filename+"】上传中发生中断，错误码："+evt);
							}, false);
							xhr.open("POST", "/mobile/pc/uploadFile.jsp");
							xhr.send(fd);
						});
					console.log("update"+fileAffixID+":"+filename);
					if(span)
					span.innerHTML=filename+ "<q style=color:gray>(已保存)</q>";
					//return;
				  }
				  console.log("loop"+fileAffixID);
				  window.g_checkFileUpdateTimer["time"+fileAffixID]=setTimeout(func, 1000);
				};
				window.g_checkFileUpdateTimer["time"+fileAffixID]=setTimeout(func, 1500);
				top.g_sessionDownloadDoneCallbackx=undefined;
				/* Electron 编辑word并自动上传覆盖 */
				
			};
			var electron=top.require("electron");
			var tempDir=electron.remote.app.getPath('userData')+"\\EutTemp\\cache0\\";
			electron.ipcRenderer.send('setSavePath', tempDir+filename);
			var frame1=document.getElementById("electronDownFrame");
			if(!frame1){
				frame1=document.createElement("iframe");
				frame1.id="electronDownFrame";
				frame1.style.display="none";
				document.body.appendChild(frame1);
			}
			frame1.src=url;
			return;
		}
		/*  Electron End */

		if (typeof doclist[index].doc == "object")
		{
			CreateApp();
			try
			{
				doclist[index].doc.ActiveWindow.Activate();
				App.Activate();
				return;
			}
			catch (e)
			{
//				alert("文档已关闭或不可用。");
//				evt.srcElement.nextSibling.nextSibling.click();
			}
		}

		if (CreateApp() == false)
			return;
		if (typeof doclist[index].fullname == "string")
			var doc = App.Documents.Open(doclist[index].fullname);
		else
		{
			if (doclist[index].id == 0)
				return;
			var doc = App.Documents.Open(root + "/com/down.jsp?AffixID=" + doclist[index].id);
			var ocx = oUpload.getocx();
			var path = App.Options.DefaultFilePath(0);
			if (typeof ocx == "object")
				path = ocx.GetTempPath(0);
			doc.SaveAs(path + "\\" + doclist[index].name);
		}
		doc.TrackRevisions = true;
		
		doc.ShowRevisions = true;
		
		doclist[index].doc = doc;
		doclist[index].fullname = doc.FullName;
		App.Activate();
		doc.ActiveWindow.Activate();
		SetSyn();
//		alert(doc.Saved);
	}
	
	function ReadDoc()
	{
		var evt = getEvent();
		var index = getDocIndex(evt.srcElement);
		
		// Electron lxt 2017.12.20
		if(window.g_isElectron){
			var url=root + "/com/down.jsp?AffixID=" + doclist[index].id;
			var fileAffixID=doclist[index].id;
			if(fileAffixID==0||!fileAffixID){
				alert("没有文件");
				return;
			}
			var filename=doclist[index].name;
			top.g_sessionDownloadDoneCallbackx=function(obj){
				//alert(obj.savePath);
				if(!top.require("electron").shell.openItem(obj.savePath)){
					top.alert("请安装相应Office软件");
					return;
				}
				top.g_sessionDownloadDoneCallbackx=undefined;
				
			};
			var electron=top.require("electron");
			var tempDir=electron.remote.app.getPath('userData')+"\\EutTemp\\cache1\\";
			electron.ipcRenderer.send('setSavePath', tempDir+filename);
			var frame1=document.getElementById("electronDownFrame");
			if(!frame1){
				frame1=document.createElement("iframe");
				frame1.id="electronDownFrame";
				frame1.style.display="none";
				document.body.appendChild(frame1);
			}
			frame1.src=url;
			return;
		}
		/* Electron end  */
		
		if ((typeof doclist[index].fullname == "string") && (doclist[index].fullname != doclist[index].name))
		{
			if (doclist[index].id == 0)
				return EditDoc();
			if (window.confirm("您已编辑过此文档，已保存，但未上传。\n您是要继续编辑，还是要阅读原件？\n如需继续编辑，请选择[确定]。\n选择[取消]则阅读原件。") == true)
				return EditDoc();
		}
		
		if (doclist[index].id == 0)
			return;
		if (CreateApp() == false)
			return;
		var href = root + "/com/down.jsp?AffixID=" + doclist[index].id;
		var doc = App.Documents.Open(href);
		doc.ActiveWindow.Caption = doclist[index].name;
		App.Activate();
		doc.ActiveWindow.Activate();
	}
	
	function DownDoc()
	{
		var evt = getEvent();
		var index = getDocIndex(evt.srcElement);
		if (doclist[index].id == 0)
			return alert("未上传。");
		location.href =	root + "/com/down.jsp?AffixID=" + doclist[index].id;
	}
	
	function DeleteDoc()
	{
		var evt = getEvent();
		var obj = evt.srcElement;
		var index = getDocIndex(obj);
		if (doclist[index].id != 0)
		{
			if (window.confirm("是否删除已上传的文件") == false)
				return;
			AjaxRequestPage("../com/upload.jsp?option=DeleteFile&fileName0=" + doclist[index].id, true, "",
				function (data){alert(data);});
		}
		if (index > 0)
		{
			for (var x = 0; x < 7; x++)
			{
				var tag = obj.previousSibling.tagName;
				obj.parentNode.removeChild(obj.previousSibling);
				if (tag == "BR")
					break;
			}
			obj.parentNode.removeChild(obj);
			doclist.splice(index, 1);
		}
		else
		{
			doclist[0].id = 0;
			doclist[0].name = "";
			doclist[0].doc = undefined;
			doclist[0].fullname = undefined;
			domobj.innerHTML = "";
		}
		self.docChangeEvent(index, "");
	}
	
	this.SaveDoc = function (funok)
	{
		if (typeof funok == "function")
			UploadOKEvent = funok;
		for (var x = 0; x < doclist.length; x++)
		{
			if (SaveOne(x) == false)
				return false;
		}
		var value = "";
		for (var x = 0; x < doclist.length; x++)
		{
			if (doclist[x].id != 0)
			{
				if (value != "")
					value += ",";
				value += doclist[x].id + ":" + doclist[x].name;
			}
		}
		hidobj.value = value;
		return true;	
	}
	
	function SaveOne(index)
	{
		if (typeof doclist[index].fullname == "string")
		{
			if (typeof doclist[index].doc == "object")
			{
				try
				{
					doclist[index].doc.Save();
					SyncStatus();
					doclist[index].doc.Close();
				}
				catch (e)
				{
				}
				doclist[index].doc = undefined;
			}
			if (doclist[index].fullname == doclist[index].name)
				alert("不能上传文件，[" + doclist[index].name + "]文件已丢失。");
			else
			{
				if ((typeof doclist[index].uploadid == "undefined") || (doclist[index].uploadid < 0))
				{
//					doclist[index].uploadid = oUpload.upload(doclist[index].fullname, "临时共享文件夹", doclist[index].id);
					doclist[index].uploadid = oUpload.upfile(doclist[index].fullname, {DestDir:"Form", saveto: "表单Office文档", affixid:doclist[index].id});
					if (doclist[index].uploadid < 0)
						alert("上传OFFICE文件失败:" + doclist[index].uploadid);
				}
			}
			SyncStatus();
//			if (savefile(x) != "OK")
				return false;
		}
		return true;
	}
	
	this.docChangeEvent = function (nIndex, value) {};

	function UploadDoc()
	{
		var evt = getEvent();
		var index = getDocIndex(evt.srcElement);
		if ((typeof doclist[index].fullname == "string") && (doclist[index].fullname != doclist[index].name))
		{
			if (window.confirm("您已编辑过此文档，已保存，但未上传。\n您是要上传本次编辑过的文档，还是要上传新文档？\n如需上传本次编辑过的文档，请选择[确定]。\n选择[取消]则上传新文档。\n提示：本次编辑过的文档如未上传，会在表单提交时自动上传。") == true)
				return SaveOne(index);
		}
		
		UploadDoc.SubmitLocalFileOK = SubmitLocalFileOK;
		SubmitLocalFileOK = UploadOK;
		StartSubmitLocalFile("临时共享文件夹", ".doc,.docx,.rtf,.txt,.htm,.html,.mht");
	}
	
	function UploadOK(FileType, AffixID, FileCName)
	{
		UploadOK.obj = undefined;
		SubmitLocalFileOK = UploadDoc.SubmitLocalFileOK;
		if (FileType == undefined)
			return;
		var index = doclist.length;
		if (doclist[index - 1].name == "")
		{
			doclist[index - 1].name = FileCName;
			doclist[index - 1].id = AffixID;
			domobj.innerHTML = FileCName;
		}
		else
		{
			doclist[index] = {};
			doclist[index].id = AffixID;
			doclist[index].name = FileCName;
			InitDocbar(0, index);
		}
		self.docChangeEvent(index, FileCName);
	}
	InitDoc();
}

function ConSignEditor(domobj)
{
	var hidobj = domobj.previousSibling;
	var username = hidobj.getAttribute("UserName");
	var readonly = parseInt(hidobj.getAttribute("bReadonly"));
	var bRequired = parseInt(hidobj.getAttribute("bRequired"));
	var CTime = hidobj.getAttribute("CTime");
	var oldvalue = hidobj.value;
	var editobj;
	var cStepID = 0;

	function onchange_old()
	{
		if (readonly == 2)
			hidobj.value = username + ":" + editobj.value.replace(/:/g, "：").replace(/;/g, "；")
				.replace(/"/g, "“").replace(/'/g, "‘") + ";";
		else
			hidobj.value = oldvalue + username + ":"
				+ editobj.value.replace(/:/g, "：").replace(/;/g, "；").replace(/"/g, "“").replace(/'/g, "‘")
				+ ";";
	}

	function Init_old()
	{
		var EName = hidobj.name;
		var CName = hidobj.getAttribute("CName").split(",");
		var rows = parseInt(hidobj.getAttribute("rows"));
		var lineheight = parseInt(hidobj.getAttribute("lineHeight"));
		if ((readonly == 1) && (hidobj.value == ""))
			return "";
		var tag = "<input type=hidden name=" + EName + "_Pattern value='" + username + ":.*;'><div";
		var ss = hidobj.value.split(";");
		if ((rows > 1) && (ss.length > rows))
			tag += " style=width:100%;height:" + (rows * 24) + "px;overflow-y:auto";
		tag += "><table style=width:100%;>";
		var value = oldvalue;
		if ((value.indexOf(username + ":") < 0) && (readonly != 1))
		{
			if (value != "")
				value += ";";
			value += username + ":;";
		}
		var ss = value.split(";");
		for (var x = 0; x < ss.length; x++)
		{
			var sss = ss[x].split(":");
			if (sss.length < 2)
				continue;
			if ((Trim(sss[1]) == "") && ((readonly == 1) || (sss[0] != username)))
				continue;
			tag += "<tr><td width=5% nowrap class=jformconreadonly1>" + CName[0] + "</td><td width=20%><input name=" +
				EName + "_F1 readonly class=textreadonly value='" + sss[0] + "' style=width:100%;></td>";
			if ((sss[0] == username) && (readonly != 1))
			{
				tag += "<td width=5% nowrap class=jformcon1>" + CName[1] + "</td><td width=70%>";
				var sreq = "";
				if (bRequired == 1)
					sreq = " bRequired=1";
				if (lineheight == 1)
					tag += "<input id=ConsignInput name=" + EName + "_F2" + sreq + " class=text style=width:100%; value='" + sss[1] + "'>";
				else
					tag += "<textarea id=ConsignInput name=" + EName + "_F2" + sreq + " class=text rows=" + lineheight + " style=width:100%;>" + sss[1] + "</textarea>";				
			}
			else
			{
				tag += "<td width=5% nowrap class=jformconreadonly1>" + CName[1] + "</td><td width=70%>";
				if (lineheight == 1)
					tag += "<input readonly name=" + EName + "_F2 class=textreadonly style=width:100%; value=" + sss[1] + ">";
				else
					tag += "<div id=TextReadOnlyViewDiv rows=" + lineheight + " style=width:100%;height:" + rows * 20 + "px;>" + sss[1].replace(/\n/g, "<br>") + "</div>";
			}
			tag += "</td></tr>";
		}
		domobj.insertAdjacentHTML("beforeEnd", tag + "</table></div>");
		editobj = document.getElementById("ConsignInput");
		switch (readonly)
		{
		case 0:			//edit
			hidobj.value = value;
		case 1:			//readonly
			break;
		case 2:			//append
			hidobj.value = username + ":;";
			break;
		}
			
		if (typeof editobj == "object")
		{
			editobj.onchange = onchange_old;
			editobj.scrollIntoView();
		}
	}

	function onchange()
	{
		if (readonly == 2){
			hidobj.value = username + ":" + editobj.value.replace(/:/g, "：")
				.replace(/;/g, "；").replace(/"/g, "“").replace(/'/g, "‘")
				+ ":" + CTime + ":" + cStepID + ";";
		} else {
			hidobj.value = oldvalue.replace(new RegExp(username + ":[^;]*;", "g"), "")
				+ username + ":" + editobj.value.replace(/:/g, "：")
				.replace(/;/g, "；").replace(/"/g, "“").replace(/'/g, "‘")
				+ ":" + CTime + ":" + cStepID + ";";
		}
	}

	function Init()
	{
		var EName = hidobj.name;
		// lxt 2017.11.8
		var CName = hidobj.getAttribute("CName").split(",");
		var rows = parseInt(hidobj.getAttribute("rows"));
		var lineheight = parseInt(hidobj.getAttribute("lineHeight"));
		if(document.getElementById("I_StepID") != null)
			cStepID = document.getElementById("I_StepID").value;

		if ((readonly == 1) && (hidobj.value == ""))
			return "";
		
		if(readonly == 2 && oldvalue.indexOf(":" + cStepID) >= 0)
			var tag = "<input type=hidden name=" + EName + "_Pattern value='" + username + ":[^;]*:" + cStepID + ";'><div";
		else
			var tag = "<input type=hidden name=" + EName + "_Pattern value=''><div";
		
		var ss = hidobj.value.split(";");
		if ((lineheight > 0) && (ss.length > lineheight))
			tag += " style=width:100%;height:" + (lineheight * 24) + "px;overflow-y:auto";
		tag += "><table style=width:100%;>";
		var value = oldvalue;
		
		if ((value.indexOf(username + ":") < 0 && readonly != 1) || (value.indexOf(":" + cStepID) < 0 && readonly == 2))
		{
			if (value != "")
				value += ";";
			value += username + "::" + CTime + ":" + cStepID + ";";
		}
		var ss = value.split(";");
		for (var x = 0; x < ss.length; x++)
		{
			var sss = ss[x].split(":");
			if (sss.length < 2)
				continue;
			if ((Trim(sss[1]) == "") && ((readonly == 1) || (sss[0] != username)))
				continue;
			tag += "<tr>";
			
			if ((readonly == 0 || (cStepID == sss[3] && readonly == 2)) && Trim(sss[0]) == username)
			{
				tag += "<td width=5% nowrap class=jformcon1>" + CName[1] + "</td><td width=70%>";
				var sreq = "";
				if (bRequired == 1)
					sreq = " bRequired=1";
				if (rows == 1)
					tag += "<input id=ConsignInput name=" + EName + "_F2" + sreq + " class=text style=width:100%; value='" + sss[1] + "'>";
				else
					tag += "<textarea id=ConsignInput name=" + EName + "_F2" + sreq
						+ " class=text rows=" + rows + " style=width:100%;height:auto;>" + sss[1] + "</textarea>";				
			}
			else
			{
				tag += "<td width=5% nowrap class=jformconreadonly1>" + CName[1] + "</td><td width=70%>";
				if (rows == 1)
					tag += "<input readonly name=" + EName + "_F2 class=textreadonly style=width:100%; value=" + sss[1] + ">";
				else
					tag += "<div id=TextReadOnlyViewDiv rows=" + rows + " style=width:100%;>" + sss[1].replace(/\n/g, "<br>") + "</div>";
			}
			// width:auto !important; w3c 2017.12.18
			tag += "</td><td width=5% nowrap class=jformconreadonly1>" + CName[0] + "</td><td nowrap width=100><input name=" +
				EName + "_F1 readonly class=textreadonly value='" + sss[0] + "' style='width:auto !important;width:100%;'></td>"; 
			if(sss[2] != undefined && Trim(sss[2]) != "")
				tag += "<td width=5% nowrap class=jformconreadonly1>时间</td><td><input name=" + 
					EName + "_F3 readonly class=textreadonly value='" + (sss[2] == undefined ? "" : sss[2]) + "' style='width:110px;'></td>";
			tag += "</tr>";
		}
		domobj.insertAdjacentHTML("beforeEnd", tag + "</table></div>");
		editobj = objall(domobj, "ConsignInput");
		switch (readonly)
		{
		case 0:			//edit
		case 1:			//readonly
			break;
		case 2:			//append
			hidobj.value = username + ":" + editobj.value.replace(/:/g, "：").replace(/;/g, "；").replace(/"/g, "“") + ":" + CTime + ":" + cStepID + ";";
			break;
		}
			
		if (editobj != null)
		{
			editobj.onchange = onchange;
			editobj.scrollIntoView();
		}
	}
	if (CTime == undefined)
		Init_old();
	else
		Init();
}

function SizeBox(mode, bgcolor, maskcolor, opacity)
{
	var self = this;
	var domobj, mask, nAction, px, py;
	var eleft = -2048, etop = -2048, eright = 2048, ebottom = 2048;
	var minwidth = 8, minheight = 8; maxwidth = 4096, maxheight = 4096;
	var old = {left:0, top:0, width:100, height:100, status:0};
	function init()
	{
		if (typeof bgcolor == "undefined")
			bgcolor = "blue"; 
		mask = document.createElement("<DIV style='position:absolute;overflow:hidden;padding:4px;display:none;'></DIV>");
		document.body.insertBefore(mask, null);
		mask.onmousedown = MouseBegin;
		mask.onmousemove = MouseEdge;
		mask.ondblclick = self.dblclick;
		if (mode == 0)		//没有缩放的指示框
			return;
		var tag = "<div style=position:absolute;overflow:hidden;width:4px;height:5px;background-color:" + bgcolor + "></div>";
		mask.innerHTML = "<div style='width:100%;height:100%;overflow:hidden;'></div>" +
			tag + tag + tag + tag + tag + tag + tag + tag;
		if (typeof maskcolor == "string")		//用透明属性盖住对象，以获得事件
		{
			mask.firstChild.style.backgroundColor = maskcolor;
			mask.firstChild.style.filter = "alpha(opacity=" + opacity + ")";
		}	
		mask.children[1].style.cursor = "NW-resize";
		mask.children[2].style.cursor = "N-resize";
		mask.children[3].style.cursor = "NE-resize";
		mask.children[4].style.cursor = "W-resize";
		mask.children[5].style.cursor = "E-resize";
		mask.children[6].style.cursor = "SW-resize";
		mask.children[7].style.cursor = "S-resize";
		mask.children[8].style.cursor = "SE-resize";
	}
	
	function MouseBegin()
	{
		var evt = getEvent();
		for (var x = 0; x < mask.children.length; x++)
		{
			if (evt.srcElement == mask.children[x])
				break;
		}
		if (x < mask.children.length)
			nAction = x;
		self.start(nAction);
	}


	function MouseEdge()
	{
		if (mode == 0)
			return;
		var pos = GetObjPos(mask);
		var evt = getEvent();
		if (evt.x < pos.left + 4)
		{
			mask.style.cursor = "W-resize";
			nAction = 4;
			return;
		}
		if (evt.x > pos.right - 4)
		{
			mask.style.cursor = "E-resize";
			nAction = 5;
			return;
		}
		if (evt.y < pos.top + 4)
		{
			mask.style.cursor = "N-resize";
			nAction = 2;
			return;
		}
		if (evt.y > pos.bottom - 4)
		{
			mask.style.cursor = "S-resize";
			nAction = 7;
			return;
		}
		mask.style.cursor = "default";
		nAction = 0;
	}

	function MouseAction()
	{
		Action(nAction);
		Apply();
	}

	function Apply()
	{
		domobj.style.left = (parseInt(mask.style.left) + 2) + "px";
		domobj.style.top = (parseInt(mask.style.top) + 2) + "px";
		domobj.style.width = (parseInt(mask.style.width) - 4) + "px";
//		domobj.style.pixelHeight = mask.style.pixelHeight - 4;
		domobj.style.height = (parseInt(mask.style.height) - 4) + "px";
		SetBox();
		self.ActionEvent(2, nAction);
	}
	
	function Action(action)
	{
		var evt = getEvent();
		switch (action)
		{
		case 0:		//MOVE
			if (evt.x + px < eleft)
				mask.style.left = eleft + "px";
			else if (evt.x + px + parseInt(mask.style.width) > eright)
				mask.style.left = (eright - parseInt(mask.style.width)) + "px";
			else
				mask.style.left = (evt.x + px) + "px";
			
			if (evt.y + py < etop)
				mask.style.top = etop + "px";
			else if (evt.y + py + parseInt(mask.style.height) > ebottom)
				mask.style.top = (ebottom - parseInt(mask.style.height)) + "px";
			else
				mask.style.top = (evt.y + py) + "px";
			break;
		case 1:		//SIZE:left top
			Action(2);
			Action(4);
			break;
		case 2:		//SIZE:top
			var b = parseInt(mask.style.top) + parseInt(mask.style.height);
			if (b - evt.y < minheight)
			{
				mask.style.height = minheight + "px";
				mask.style.top = (b - minheight) + "px";
			}
			else if (b - evt.y > maxheight)
			{
				mask.style.height = maxheight + "px";
				mask.style.top = (b - maxheight) + "px";
			}
			else
			{
				mask.style.top = evt.y + "px";
				mask.style.height = (b - parseInt(mask.style.top)) + "px";
			}
			break;
		case 3:		//SIZE: right top
			Action(2);
			Action(5);
			break;
		case 4:		//SIZE: left
			var r = parseInt(mask.style.left) + parseInt(mask.style.width);
			if (r - evt.x < minwidth)
			{
				mask.style.width = minwidth + "px";
				mask.style.left = r - minwidth + "px";
			}
			else if (r - evt.x > maxwidth)
			{
				mask.style.width = maxwidth + "px";
				mask.style.left = (r - maxwidth) + "px";
				
			}
			else
			{
				mask.style.left = evt.x + "px";
				mask.style.width = (r - parseInt(mask.style.left)) + "px";
			}
			break;
		case 5:		//SIZE:	right
			if (evt.x - parseInt(mask.style.left) < minwidth)
				mask.style.width = minwidth + "px";
			else if (evt.x - parseInt(mask.style.left) > maxwidth)
				mask.style.width = maxwidth + "px";
			else
				mask.style.width = (evt.x - parseInt(mask.style.left)) + "px";
			break;
		case 6:		//SIZE:	left bottom
			Action(4);
			Action(7);
			break;
		case 7:		//SIZE:	bottom
			if (evt.y - parseInt(mask.style.top) < minheight)
				mask.style.height = minheight + "px";
			else if (evt.y - parseInt(mask.style.top) > maxheight)
				mask.style.height = maxheight + "px";
			else
				mask.style.height = (evt.y - parseInt(mask.style.top)) + "px";
			break;
		case 8:		//SIZE: right bottom
			Action(5);
			Action(7);
			break;
		case 9:
			break;
		}
	}
	
	function MouseEnd()
	{
		objevent(document, "mousemove", MouseAction, 1);
		objevent(document, "mouseup", MouseEnd, 1);
		mask.onmousemove = MouseEdge;
		self.ActionEvent(3, nAction);
	}

	function SetBox()
	{
		if (mode == 0)
			return;
		var pos = GetObjPos(domobj);
		mask.children[1].style.top = "0px";		//left top
		mask.children[1].style.left = "0px";
		mask.children[2].style.top = "0px";		//top
		mask.children[2].style.left = parseInt((pos.right - pos.left) / 2) + "px";
		mask.children[3].style.top = "0px";		//right top
		mask.children[3].style.left = (pos.right - pos.left - 1) + "px";

		mask.children[4].style.top = parseInt((pos.bottom - pos.top) / 2) + "px";
		mask.children[4].style.left = "0px";		//left
		mask.children[5].style.top = parseInt((pos.bottom - pos.top) / 2) + "px";
		mask.children[5].style.left = (pos.right - pos.left - 10) + "px";	//right

		mask.children[6].style.top = (pos.bottom - pos.top - 1) + "px";
		mask.children[6].style.left = "0px";		//left bottom
		mask.children[7].style.top = (pos.bottom - pos.top - 1) + "px";		//bottom
		mask.children[7].style.left = parseInt((pos.right - pos.left) / 2) + "px";
		mask.children[8].style.top = (pos.bottom - pos.top - 1) + "px";		//right bottom
		mask.children[8].style.left = (pos.right - pos.left - 1) + "px";	
	};

	this.start = function (act)
	{
		if (typeof act != "number")
			act = 0;
		if (old.status == 1)
			return;
		nAction = act;
		var evt = getEvent();
		var pos = GetObjPos(mask);
		px = pos.left - evt.x;
		py = pos.top - evt.y;
		mask.onmousemove = null;
		objevent(document, "mousemove", MouseAction);
		objevent(document, "mouseup", MouseEnd);
		self.ActionEvent(1, nAction);
	};

	this.runMax = function(nType)
	{
		if ((old.status == 0) && (nType != 0))
		{
			old.status = 1;
			old.left = mask.style.left;
			old.top = mask.style.top;
			old.width = mask.style.width;
			old.height = mask.style.height;

			mask.style.left = "0px";
			mask.style.top = "0px";
			mask.style.width = "100%";
			mask.style.height = "100%";
			mask.style.display = "none";

		}
		else if ((old.status == 1) && (nType != 1))
		{
			old.status = 0;
			mask.style.left = old.left;
			mask.style.top = old.top;
			mask.style.width = old.width;
			mask.style.height = old.height;
			mask.style.display = "block";
		}
		Apply();
	}
	this.dblclick = function (){};

	this.attach = function (obj)
	{
		domobj = obj;
		var pos = GetObjPos(obj);
		mask.style.top = (pos.top - 2) + "px";
		mask.style.left = (pos.left - 2) + "px";
		mask.style.width = (pos.right - pos.left + 4) + "px";
		mask.style.height = (pos.bottom - pos.top + 4) + "px";
		mask.style.display = "block";
		SetBox();
	}

	this.detach = function ()
	{
		mask.style.display = "none";
	};

	this.SetMaxRange = function (l, t, r, b)
	{
		eleft = l - 2;
		etop = t - 2;
		eright = r + 2;
		ebottom = b + 2;
	
	}
	
	this.SetLimitBox = function (type, w, h)
	{
		switch (type)
		{
		case 0:
			minwidth = w + 4;
			minheight = h + 4;
			break;
		case 1:
			maxwidth = w;
			maxheight = h;
			break;
		}
	};

	this.remove = function ()
	{
		mask.parentNode.removeChild(mask);
	};

	this.ActionEvent = function(status, action)	{};
	init();
}

function Layer(domobj, faceRoot, cfg)
{
	var self = this;
	var domw, domh;		//容器的宽高
	
	function getTag(aFace, width, height)
	{
		if (typeof aFace.x == "undefined")
			return "";
		var tag = "", html = "";
	
		if (aFace.x <= 0)
		{
			var o = FormatObjvalue({style:"", id:"", html:"", size:""}, aFace.a);
			if (typeof(aFace.a.child) == "object")
				html = getTag(aFace.a.child, width, aFace.y);
			tag += "<div id=\"" + o.id + "\" node=DVA" + aFace.node + " style='border-bottom:" + cfg.border + ";height:" + aFace.y + 
				"px;width:100%;overflow:hidden;" + o.style + "'>" + html + o.html + "</div>";
			html = "";
			var o = FormatObjvalue({style:"", id:"", html:"", size:""}, aFace.b);
			if (typeof(aFace.b.child) == "object")
				html = getTag(aFace.b.child, width, height - aFace.y - 1);
			tag += "<div id=\"" + o.id + "\" node=DVB" + aFace.node + " style=';height:" + (height - aFace.y - 1) + 
				"px;width:100%;overflow:hidden;" + o.style + "'>" + html + o.html + "</div>";
		}
		else if (aFace.y <= 0)
		{
			var o = FormatObjvalue({style:"", id:"", html:"", size:""}, aFace.a);
			if (typeof(aFace.a.child) == "object")
				html = getTag(aFace.a.child, aFace.x, height);
			tag += "<div id=\"" + o.id + "\" node=DVA" + aFace.node + " style='border-right:" + cfg.border + ";width:" + aFace.x +
				"px;height:100%;overflow:hidden;float:left;" + o.style + "'>" + html + o.html + "</div>";
			html = "";
			var o = FormatObjvalue({style:"", id:"", html:"", size:""}, aFace.b);
			if (typeof(aFace.b.child) == "object")
				html = getTag(aFace.b.child, width - aFace.x - 1, height);
			tag += "<div id=\"" + o.id + "\" node=DVB" + aFace.node + " style='width:" + (width - aFace.x - 1) +
					"px;height:100%;overflow:hidden;float:left;" + o.style + "'>" + html + o.html + "</div>";
		}
	return tag;
	}

	function resize()
	{
		var dw = domobj.clientWidth - domw;
		var dh = domobj.clientHeight - domh;
		if ((dw == 0) && (dh == 0))
			return;
		resizerun(faceRoot, dw, dh);
		domw = domobj.clientWidth;	
		domh = domobj.clientHeight;
		rearrange(faceRoot, domw, domh);
		rearrange(faceRoot);
	}

	function resizerun(aFace, dw, dh)
	{
		if ((aFace.x == -2) || (aFace.x == -3))
			aFace.y += dh;
		if ((aFace.y == -2) || (aFace.y == -3))
			aFace.x += dw;
		if (typeof aFace.a.child == "object")
			resizerun(aFace.a.child, dw, dh);
		if (typeof aFace.b.child == "object")
			resizerun(aFace.b.child, dw, dh);		
	}
	
	function splitInit(aFace)
	{
		if ((aFace.x == -1) || (aFace.y == -1) || (aFace.x == -3) || (aFace.y == -3))
		{
			var oo = self.getABDIV(aFace);
			aFace.split = new Split(oo[0], oo[1]);
			aFace.split.onsplit = onsplit;
		}
		if ((typeof aFace.a == "object") && (typeof aFace.a.child == "object"))
			splitInit(aFace.a.child);
		if ((typeof aFace.b == "object") && (typeof aFace.b.child == "object"))
			splitInit(aFace.b.child);
	}

	function onsplit(left, top, split)
	{
		var aFace = getsplitface(faceRoot, split);
		if (aFace.x <= 0)
			aFace.y = top;
		else
			aFace.x = left;

		rearrange(faceRoot, domw, domh);
		rearrange(faceRoot);
	}

	function getsplitface(aFace, split)
	{
		if (aFace.split == split)
			return aFace;
		var oo = [aFace.a, aFace.b]
		for (var x = 0; x < oo.length; x++)
		{
			if ((typeof oo[x] == "object") && (typeof oo[x].child == "object"))
			{
				var obj = getsplitface(oo[x].child, split);
				if (typeof obj == "object")
					return obj;
			}
		}
	}
	
	function rearrange(aFace, width, height)
	{
		if (width == undefined)
		{
			if (typeof aFace.split == "object")
				aFace.split.refresh();
			if (typeof(aFace.a.child) == "object")
				rearrange(aFace.a.child);
			if (typeof(aFace.b.child) == "object")
				rearrange(aFace.b.child);
			return;
		}
		var ab = self.getABDIV(aFace);
		if (aFace.x <= 0)
		{
			if (typeof(aFace.a.child) == "object")
				rearrange(aFace.a.child, width, aFace.y);
			ab[0].style.height = aFace.y + "px";
			if (typeof(aFace.b.child) == "object")
				rearrange(aFace.b.child, width, height - aFace.y - 1);
			ab[1].style.height = (height - aFace.y - 1) + "px";
		}
		else if (aFace.y <= 0)
		{
			if (typeof(aFace.a.child) == "object")
				rearrange(aFace.a.child, aFace.x, height);
			 ab[0].style.width = aFace.x + "px";
			if (typeof(aFace.b.child) == "object")
				rearrange(aFace.b.child, width - aFace.x - 1, height);
			ab[1].style.width = (width - aFace.x - 1) + "px";
		}
	}

	this.getcfg = function ()
	{
		return cfg;
	};

	this.refresh = function(aface)
	{
		if (typeof aface == "object")
			faceRoot = aface;
		if (typeof faceRoot == "object")
			domobj.innerHTML = getTag(faceRoot, domobj.clientWidth, domobj.clientHeight);

		if (typeof aface == "object")
			faceRoot = aface;
		if (typeof faceRoot != "object")
			return;
		objevent(domobj, "resize", resize, 1);
		var w = domobj.style.width;
		var h = domobj.style.height;
		domobj.style.width = cfg.dwidth + "px";
		domobj.style.height = cfg.dheight + "px";
		domw = domobj.clientWidth;
		domh = domobj.clientHeight;
		domobj.innerHTML = getTag(faceRoot, domw, domh);
		domobj.style.width = w;
		domobj.style.height = h;
		resize();
		objevent(domobj, "resize", resize);
		if (cfg.split == 1)
			splitInit(faceRoot);



	};
	

	this.getABDIV = function(aFace, ab)
	{
		var result = [undefined, undefined];
		var all = objall(domobj)
		for (var x = 0; x < all.length; x++)
		{
			if (all[x].tagName == "DIV")
			{
				if (all[x].node == "DVA" + aFace.node)
					result[0] = all[x];
				if (all[x].node == "DVB" + aFace.node)
					result[1] = all[x];
			}
		}
		if (ab == "a")
			return result[0];
		if (ab == "b")
			return result[1];
		return result;
	}
	
	cfg = FormatObjvalue({border:"", split:1, dwidth:640, dheight:480}, cfg);
	this.refresh();
}