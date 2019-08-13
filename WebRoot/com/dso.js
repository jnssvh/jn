//web office
WordOption = function() {
	var localDir="c:/temp/"; // 本地保存的临时目录
	var docName;// 本地保存的文件名, 也为上传到服务器上时的文件名
	var docUrl; // 远程文件 e.g. http://128.96.172.238:9080/aaa/upload/aaa.doc
	var uploadUrl; //上传到服务器的url
	
	this.serverPath = "";
	this.rename = "";
	/*var fso;
	{
		fso = new ActiveXObject("Scripting.FileSystemObject");
		if (!fso.FolderExists(localDir)) {
			fso.CreateFolder(localDir);
		}
	}*/
	this.openDoc = function(docName, docUrl) {
		if (docName == undefined)
		{
			document.getElementById('oframe').showdialog(1);
			//throw 6;
			if (document.getElementById('oframe').object.DocumentFullName != "")
				this.docName = document.getElementById('oframe').object.DocumentFullName.match(/.*[\\\/](.*)/)[1];
			return;
		}
		this.docName = docName;
		this.docUrl = docUrl;
		if (typeof(docUrl) == 'undefined' || docUrl == '' || docUrl == null) {
			var openType = "";
			var fileType = docName.replace(/.*\.(.*)/, "$1");
			fileType = fileType.toLowerCase();
			switch (fileType) {
				case "doc":
					openType = "Word.Document";
				break;
				case "xls":
					openType = "Excel.Sheet";
				break;
				case "ppt":
					openType = "PowerPoint.Show";
				break;
				default:
					alert("文档类型不能识别：" + docName + "\n" + docUrl);
				return;
			}
			document.getElementById('oframe').CreateNew(openType);
		}else{
			document.getElementById('oframe').Open(docUrl,false);
			//document.getElementById('oframe').TitlebarTextColor(0);
		}
		oframe.Menubar = true;
		document.getElementById('oframe').EnableFileCommand(0) = false;
		document.getElementById('oframe').EnableFileCommand(1) = false;
		document.getElementById('oframe').EnableFileCommand(2) = false;
		document.getElementById('oframe').EnableFileCommand(3) = false;
		document.getElementById('oframe').EnableFileCommand(4) = false;
   		oframe.Activate();
		document.getElementById('oframe').Save(localDir + docName, true);
	}
	this.setUploadUrl = function(uploadUrl){
		this.uploadUrl = uploadUrl;
	}
	this.saveDoc = function(){
		//alert(this.docName);
		if (this.docName.indexOf("local.") >= 0) {
			var name0 = this.docName;
			this.docName = window.prompt("请输入文件名", this.docName);
			if (this.docName == null) {
				return;;
			}
			if (this.docName != "" && !/.+\..*$/i.test(this.docName)) {
				this.docName += "." + name0.replace(/.*\./, '');
			}
		}
		document.getElementById('oframe').HttpInit();
		//document.getElementById('oframe').HttpAddPostString("script", "alert(1)"); 
		document.getElementById('oframe').HttpAddPostString("rename", this.rename); 
		document.getElementById('oframe').HttpAddPostString("loadtype", "doc,xls,ppt"); 
		document.getElementById('oframe').HttpAddPostString("filepath", this.serverPath); 
		document.getElementById('oframe').HttpAddPostCurrFile("file1", this.docName);
		//document.getElementsByName("ifr1")[0].src = 
		//alert(this.uploadUrl)
		var rtn = document.getElementById('oframe').HttpPost(this.uploadUrl);
alert(rtn);
		rtn = rtn.replace(/^\s+|\s+$/g, "");
		if (/<html/i.test(rtn)) {
			document.getElementById("ifr1").contentWindow.document.write(rtn);
		} else {
			alert(rtn);
		}
	}
	this.close = function(){
		document.getElementById('oframe').close();
		try{
			//fso.DeleteFile(localDir + this.docName);
		}catch(err){}
	}
}
//open window
function popwin(url, width, height, resizable) {
	var Ttop = screen.availHeight / 2 - height / 2;
	var Tlef = screen.availWidth / 2 - width / 2;
	var feather = "width=" + width + ", height=" + height + ", scrollbars=1,resizable=" + resizable + ", top=" + Ttop + ",left=" + Tlef;
	window.open(url, "_blank", feather);
}
//open a new max window
function openMaxWin(url) {
	popwin(url, screen.availWidth, screen.availHeight, 1);
}	
//open model window
function popModelWin(url, obj, width, height) {
	var f = "dialogWidth=" + width + "px;dialogHeight=" + height + "px;help=no;status=no";
	return window.showModalDialog(url, obj, f);
}