<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@page import="java.io.*"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@page import="java.awt.*" %>
<%@page import="java.sql.*" %>
<%@page import="com.jaguar.*" %>
<%@page import="javax.imageio.IIOException" %>
<%@page import="com.sun.image.codec.jpeg.*" %>
<%@page import="project.*" %>
<%@page trimDirectiveWhitespaces="true"%> 
<%!

	// fileIn  大图文件
	// fileOut 将要转换出的小图文件
	// x 将要截取起始横坐标
	// y 将要截取起始横纵标
	// width  缩略图宽
	// height  缩略图高
	// cutWidth 截取宽
 	// cutHeight截取高
	public String thumb(String fileIn, String fileOut, int x, int y, int width,int height,int cutWidth,int cutHeight)
    {
		try{
			File fi = new File(fileIn); //大图文件
			Image src=javax.imageio.ImageIO.read(fi);
	
			//检查高宽是否超出
			if ((x + cutWidth) > width) x = 0;
			if ((y + cutHeight) > height) y = 0;
			if (x < 0) x = 0;
			if (y < 0) y = 0;
						
			BufferedImage tag,deImg;
			tag = new BufferedImage(width, height,BufferedImage.TYPE_INT_RGB);
			tag.getGraphics().drawImage(
			src.getScaledInstance(width, height, Image.SCALE_SMOOTH),
			0,0,new Color(255, 255, 255),null);
			deImg = tag.getSubimage(x, y,cutWidth ,cutHeight);
			FileOutputStream newimage = new FileOutputStream(fileOut); //输出到文件流 
			JPEGImageEncoder encoder = JPEGCodec.createJPEGEncoder(newimage);
			JPEGEncodeParam jep = JPEGCodec.getDefaultJPEGEncodeParam(deImg);
			/* 压缩质量 */
			jep.setQuality((float) 0.7, true);
			encoder.encode(deImg, jep);
			newimage.close();
		} catch (IIOException e) {
			return "源文件不存在。";
		} catch (Exception e) {
			e.printStackTrace();
			return "转换错误";
		}
		return "成功";
	}

	//获得处理后文件路径并返回
	//savepath 保存缩略图的全路径
	//FilePath 源文件全路径
	//isAlbums 是否为相册图片标志
	//basePath 网络根路径
   public String GetThumbNail(int AffixID, int x, int y, int width,int height,int cutWidth,int cutHeight,
   JDatabase jdb, String savepath,String FilePath,int isAlbums,int reutrnType,String basePath)
   {
		ResultSet rs=null;
		String obj, filename = "", ftype, ff, filedate = "", ocalname, img, localname = "", sFile,ParentID="",FileCName="",SubmitMan="";
		int filesize=0,fileattrib=0,pos=0;
		File fo;
		String ThumbNail = "";
		if(AffixID!=0){//源图片数据在数据库中
			rs = jdb.GetTableRecord(0, "AffixFile","FileCName,FileURL, FileSize, FileAttrib, LocalName,ParentID,SubmitTime,SubmitMan", "ID="+ AffixID);
			if (rs == null)
				return ThumbNail;
			try {
					if (!rs.next())
						return ThumbNail;
					filename = rs.getString("FileURL");
					filesize = rs.getInt("FileSize");
					fileattrib = rs.getInt("FileAttrib");
					filedate = rs.getString("SubmitTime");
					localname = rs.getString("LocalName");
					ParentID = rs.getString("ParentID");
					FileCName= rs.getString("FileCName");
					SubmitMan=rs.getString("SubmitMan");
			
			} catch (SQLException e) {
				e.printStackTrace();
			}
			if(filename!=null&&filename.matches(".+\\.(?:jpg|jpeg|swf|bmp|gif|png)")) {
				String dateTime=System.currentTimeMillis()+"";
				pos = filename.lastIndexOf("\\");
				ff = VB.Mid(filename, pos + 2);
				pos = ff.lastIndexOf(".");
				ff = VB.Left(ff, pos - 1);
				if(localname.equals(filename))
					ff = "//S_" + ff + width + height+ CalFun.GetDateStr(filedate, 9) + dateTime +".jpg";
				else
					ff = "//S_" + ff + width + height + dateTime +".jpg";
				
				String pathStr = savepath;
				pathStr = pathStr.replaceAll("%20", " ");
				sFile = VB.Left(pathStr, pathStr.length()) + ff;
				fo = new File(sFile);
				if (!fo.exists()) {//不存在缩略图
					thumb(filename,sFile,x,y,width,height,cutWidth,cutHeight);
					if(isAlbums==1 || reutrnType==1){//是相册图片，多插一条记录,桌面头像用
						String sql="insert into AffixFile(FileCName, FileSize, FileAttrib, LocalName,ParentID,FileURL,SubmitMan)values('"+
						FileCName+"',"+filesize+","+fileattrib+",'"+localname+"',"+ParentID+",'"+pathStr+ff.replaceAll("/","\\\\")+"','"+SubmitMan+"')";
						jdb.ExecuteSQL(0, sql);
					}
				}
				ThumbNail = ff;
			}
		}
		else{
			if(FilePath!=null&&FilePath.matches(".+\\.(?:jpg|jpeg|swf|bmp|gif|png)")) {
				String dateTime=System.currentTimeMillis()+"";
				pos = FilePath.lastIndexOf("\\");
				ff = VB.Mid(FilePath, pos + 2);
				pos = ff.lastIndexOf(".");
				ff = VB.Left(ff, pos - 1);
				ff = "//S_" + ff + width + height + dateTime +".jpg";
				
				String pathStr = savepath;
				pathStr = pathStr.replaceAll("%20", " ");
				sFile = VB.Left(pathStr, pathStr.length()) + ff;
				fo=new File(sFile);
				if(!fo.exists()) {//不存在缩略图
					thumb(FilePath,sFile,x,y,width,height,cutWidth,cutHeight);
				}
				ThumbNail = ff;
			}
		}
		return ThumbNail;
	}
	
	int GetThumbID(int photoID, int x, int y, int width,int height,int cutWidth,int cutHeight,
  	 JDatabase jdb, String savePath,String fullPath,WebUser user,int isAlbums,int returnType,String basePath)//必须写数据库
	{
		String str="",sql="";
		int index=0,FileID=0;
    	str=GetThumbNail(photoID, x, y, width, height,cutWidth,cutHeight,jdb,savePath,fullPath,isAlbums,returnType,basePath);
    	index=str.lastIndexOf("/")+1;
    	sql="select ID from AffixFile where FileURL like '%"+str.substring(index)+"%' AND subMitMan='"+user.CMemberName+"'";
    	ResultSet rs= jdb.rsSQL(0,sql);
    	try{
    		if(rs.next()!=false)
    			FileID=rs.getInt("ID");
    	}
    	catch(SQLException ex){
    	 	ex.printStackTrace();
    	}
    	return FileID;
	}
	
	//isAlbums 是否是相册标志
	//returnPathType 返回路径类型 1:网络地址 2:服务器本地地址
	//savePath 保存缩略图路径
	//fullPath 源文件全路径
	//newPath 保存相对路径或外部全路径
	String GetThumbPath(int photoID, int x, int y, int width,int height,int cutWidth,int cutHeight,
  	 JDatabase jdb,int isAlbums,int returnPathType,String savePath,String fullPath,String newPath,int returnType,String basePath)
	{
		String str="",sql="",Path="";
		if(photoID==0)//不写库的方式
    			str=GetThumbNail(photoID, x, y, width, height,cutWidth,cutHeight,jdb,savePath,fullPath,isAlbums,returnType,basePath);
    	else{
    		str=GetThumbNail(photoID, x, y, width, height,cutWidth,cutHeight,jdb,savePath,fullPath,isAlbums,returnType,basePath);
    		if(isAlbums==0){//本地上传，直接更新源图片地址为缩略图地址
    			sql = "update AffixFile set FileURL='"+savePath+str+"' where ID=" + photoID;
    			sql=sql.replaceAll("/","\\\\");
    			jdb.ExecuteSQL(0, sql);
    		}
    	}
	
  		if(returnPathType==2)
  			Path="../"+newPath+str;
  		else
  			Path=basePath+newPath+str;
    	return Path;
	}
	
	//更新头像
	void UpdateEspacePhoto(HttpServletRequest request,JDatabase jdb,int photoID,WebUser user)
	{
		int espace_id = WebChar.RequestInt(request, "espace_id");
    	String sql = "SELECT espace_id,espace_user_type,user_id,espace_status,espace_admin,remark,create_ren"
    		+ ",create_time,modify_time,escape_image FROM espace_user WHERE espace_id=" + espace_id;
    	ORMapping orm = new ORMapping(jdb, sql);
    	Map<String, String> espaceUser = orm.getMapping();
    	int espace_user_type = VB.CInt(espaceUser.get("espace_user_type"));
    	switch (espace_user_type) {//0普通用户 1部门
    	case 0:
    		sql = "update Member set Photo=" + photoID+ " where CName = '" + user.CMemberName + "'";
    	break;
    	case 1:
    		sql = "update espace_user set escape_image=" + photoID+ " where espace_id=" + espace_id;
    	break;
    	case 2:	break;
    	default:break;
    	}
    	jdb.ExecuteSQL(0, sql);
	}
	
	%>
  
  <%
  		String newPath=WebChar.requestStr(request, "newPath");//缩略图要保存的目录
  		String pathType=WebChar.requestStr(request, "pathType");//缩略图要保存的目录类型 1外部 2内部
  		String fullName=WebChar.requestStr(request, "FullName");//要截取图片名
  		int returnType=WebChar.RequestInt(request, "returnType");//返回值类型 0:换头像专用 1:缩略图ID 2:缩略图地址 
  		int returnPathType=WebChar.RequestInt(request, "returnPathType");//返回路径类型 1:网络地址 2:服务器本地地址
    	int photoID=WebChar.RequestInt(request, "PhotoID");//要截取图片ID
    	int width=(int)Double.parseDouble(WebChar.requestStr(request, "width"));//图片缩放宽
    	int height=(int)Double.parseDouble(WebChar.requestStr(request, "height"));//图片缩放高
    	int x=(int)Double.parseDouble(WebChar.requestStr(request, "left"));//x
    	int y=(int)Double.parseDouble(WebChar.requestStr(request, "top"));//y
        int isAlbums=WebChar.RequestInt(request, "isAlbums");//是否相册图片
        int cutW=WebChar.RequestInt(request,"cutPicWidth");//截取框的宽
        int cutH=WebChar.RequestInt(request,"cutPicHeight");//截取框的高
        
    	JDatabase jdb = new JDatabase();
    	jdb.InitJDatabase();
    	Cookie cookie[] = request.getCookies();
    	WebUser user = new SysUser();
    	int result = user.initWebUser(jdb, cookie);
    	if (result != 1) {
    		jdb.closeDBCon();
    		response.sendRedirect("com/error.jsp");
    		return;
    	}
    
    	if(width ==0||height==0||cutW==0||cutH==0){
    		out.print("");
    		return;
    	}
    	
    	int PicID=0;
		String path="",
		basePath = "",
		serverRootPath="",
		savePath="";//缩略图保存全路径
		path = request.getContextPath();
		serverRootPath =request.getSession().getServletContext().getRealPath("/");
		basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
		if("1".equals(pathType))
			savePath=newPath; //保存到外部路径（全路径）
		else if("2".equals(pathType))
			savePath=serverRootPath+newPath;//服务器下路径，newpath为根目录相对路径
		else{
			newPath="thumb";
			savePath=serverRootPath+"thumb";//默认根目录下thumb文件夹
		}
		
		String fullPath=savePath+"\\"+fullName;
		if(returnType==0){//换头像专用
			path=GetThumbPath(photoID,x,y,width,height,cutW,cutH,jdb,isAlbums,returnPathType,savePath,fullPath,newPath,returnType,basePath);
			if(isAlbums==1){
				int index=path.lastIndexOf("/")+1;
    			String sql3 = "select ID from AffixFile where FileURL like '%"+path.substring(index)+"%' AND subMitMan='"+user.CMemberName+"'";
    			ResultSet rs= jdb.rsSQL(0,sql3);
    			if(rs.next()!=false)
    				photoID=rs.getInt("ID");
    		}
			UpdateEspacePhoto(request,jdb,photoID,user);
			out.clearBuffer();
    		out.print(path);//eut空间头像路径
		}
		else if(returnType==1){//返回缩略图ID
			PicID=GetThumbID(photoID,x,y,width,height,cutW,cutH,jdb,savePath,fullPath,user,isAlbums,returnType,basePath);
			out.clearBuffer();
    		out.print(PicID);
		}
		else if(returnType==2){//返回缩略图地址
			path=GetThumbPath(photoID,x,y,width,height,cutW,cutH,jdb,isAlbums,returnPathType,savePath,fullPath,newPath,returnType,basePath);
			out.clearBuffer();
    		out.print(path);
		}
    	jdb.closeDBCon();
    %>