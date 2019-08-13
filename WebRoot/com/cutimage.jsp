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

	// fileIn  ��ͼ�ļ�
	// fileOut ��Ҫת������Сͼ�ļ�
	// x ��Ҫ��ȡ��ʼ������
	// y ��Ҫ��ȡ��ʼ���ݱ�
	// width  ����ͼ��
	// height  ����ͼ��
	// cutWidth ��ȡ��
 	// cutHeight��ȡ��
	public String thumb(String fileIn, String fileOut, int x, int y, int width,int height,int cutWidth,int cutHeight)
    {
		try{
			File fi = new File(fileIn); //��ͼ�ļ�
			Image src=javax.imageio.ImageIO.read(fi);
	
			//���߿��Ƿ񳬳�
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
			FileOutputStream newimage = new FileOutputStream(fileOut); //������ļ��� 
			JPEGImageEncoder encoder = JPEGCodec.createJPEGEncoder(newimage);
			JPEGEncodeParam jep = JPEGCodec.getDefaultJPEGEncodeParam(deImg);
			/* ѹ������ */
			jep.setQuality((float) 0.7, true);
			encoder.encode(deImg, jep);
			newimage.close();
		} catch (IIOException e) {
			return "Դ�ļ������ڡ�";
		} catch (Exception e) {
			e.printStackTrace();
			return "ת������";
		}
		return "�ɹ�";
	}

	//��ô�����ļ�·��������
	//savepath ��������ͼ��ȫ·��
	//FilePath Դ�ļ�ȫ·��
	//isAlbums �Ƿ�Ϊ���ͼƬ��־
	//basePath �����·��
   public String GetThumbNail(int AffixID, int x, int y, int width,int height,int cutWidth,int cutHeight,
   JDatabase jdb, String savepath,String FilePath,int isAlbums,int reutrnType,String basePath)
   {
		ResultSet rs=null;
		String obj, filename = "", ftype, ff, filedate = "", ocalname, img, localname = "", sFile,ParentID="",FileCName="",SubmitMan="";
		int filesize=0,fileattrib=0,pos=0;
		File fo;
		String ThumbNail = "";
		if(AffixID!=0){//ԴͼƬ���������ݿ���
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
				if (!fo.exists()) {//����������ͼ
					thumb(filename,sFile,x,y,width,height,cutWidth,cutHeight);
					if(isAlbums==1 || reutrnType==1){//�����ͼƬ�����һ����¼,����ͷ����
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
				if(!fo.exists()) {//����������ͼ
					thumb(FilePath,sFile,x,y,width,height,cutWidth,cutHeight);
				}
				ThumbNail = ff;
			}
		}
		return ThumbNail;
	}
	
	int GetThumbID(int photoID, int x, int y, int width,int height,int cutWidth,int cutHeight,
  	 JDatabase jdb, String savePath,String fullPath,WebUser user,int isAlbums,int returnType,String basePath)//����д���ݿ�
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
	
	//isAlbums �Ƿ�������־
	//returnPathType ����·������ 1:�����ַ 2:���������ص�ַ
	//savePath ��������ͼ·��
	//fullPath Դ�ļ�ȫ·��
	//newPath �������·�����ⲿȫ·��
	String GetThumbPath(int photoID, int x, int y, int width,int height,int cutWidth,int cutHeight,
  	 JDatabase jdb,int isAlbums,int returnPathType,String savePath,String fullPath,String newPath,int returnType,String basePath)
	{
		String str="",sql="",Path="";
		if(photoID==0)//��д��ķ�ʽ
    			str=GetThumbNail(photoID, x, y, width, height,cutWidth,cutHeight,jdb,savePath,fullPath,isAlbums,returnType,basePath);
    	else{
    		str=GetThumbNail(photoID, x, y, width, height,cutWidth,cutHeight,jdb,savePath,fullPath,isAlbums,returnType,basePath);
    		if(isAlbums==0){//�����ϴ���ֱ�Ӹ���ԴͼƬ��ַΪ����ͼ��ַ
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
	
	//����ͷ��
	void UpdateEspacePhoto(HttpServletRequest request,JDatabase jdb,int photoID,WebUser user)
	{
		int espace_id = WebChar.RequestInt(request, "espace_id");
    	String sql = "SELECT espace_id,espace_user_type,user_id,espace_status,espace_admin,remark,create_ren"
    		+ ",create_time,modify_time,escape_image FROM espace_user WHERE espace_id=" + espace_id;
    	ORMapping orm = new ORMapping(jdb, sql);
    	Map<String, String> espaceUser = orm.getMapping();
    	int espace_user_type = VB.CInt(espaceUser.get("espace_user_type"));
    	switch (espace_user_type) {//0��ͨ�û� 1����
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
  		String newPath=WebChar.requestStr(request, "newPath");//����ͼҪ�����Ŀ¼
  		String pathType=WebChar.requestStr(request, "pathType");//����ͼҪ�����Ŀ¼���� 1�ⲿ 2�ڲ�
  		String fullName=WebChar.requestStr(request, "FullName");//Ҫ��ȡͼƬ��
  		int returnType=WebChar.RequestInt(request, "returnType");//����ֵ���� 0:��ͷ��ר�� 1:����ͼID 2:����ͼ��ַ 
  		int returnPathType=WebChar.RequestInt(request, "returnPathType");//����·������ 1:�����ַ 2:���������ص�ַ
    	int photoID=WebChar.RequestInt(request, "PhotoID");//Ҫ��ȡͼƬID
    	int width=(int)Double.parseDouble(WebChar.requestStr(request, "width"));//ͼƬ���ſ�
    	int height=(int)Double.parseDouble(WebChar.requestStr(request, "height"));//ͼƬ���Ÿ�
    	int x=(int)Double.parseDouble(WebChar.requestStr(request, "left"));//x
    	int y=(int)Double.parseDouble(WebChar.requestStr(request, "top"));//y
        int isAlbums=WebChar.RequestInt(request, "isAlbums");//�Ƿ����ͼƬ
        int cutW=WebChar.RequestInt(request,"cutPicWidth");//��ȡ��Ŀ�
        int cutH=WebChar.RequestInt(request,"cutPicHeight");//��ȡ��ĸ�
        
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
		savePath="";//����ͼ����ȫ·��
		path = request.getContextPath();
		serverRootPath =request.getSession().getServletContext().getRealPath("/");
		basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
		if("1".equals(pathType))
			savePath=newPath; //���浽�ⲿ·����ȫ·����
		else if("2".equals(pathType))
			savePath=serverRootPath+newPath;//��������·����newpathΪ��Ŀ¼���·��
		else{
			newPath="thumb";
			savePath=serverRootPath+"thumb";//Ĭ�ϸ�Ŀ¼��thumb�ļ���
		}
		
		String fullPath=savePath+"\\"+fullName;
		if(returnType==0){//��ͷ��ר��
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
    		out.print(path);//eut�ռ�ͷ��·��
		}
		else if(returnType==1){//��������ͼID
			PicID=GetThumbID(photoID,x,y,width,height,cutW,cutH,jdb,savePath,fullPath,user,isAlbums,returnType,basePath);
			out.clearBuffer();
    		out.print(PicID);
		}
		else if(returnType==2){//��������ͼ��ַ
			path=GetThumbPath(photoID,x,y,width,height,cutW,cutH,jdb,isAlbums,returnPathType,savePath,fullPath,newPath,returnType,basePath);
			out.clearBuffer();
    		out.print(path);
		}
    	jdb.closeDBCon();
    %>