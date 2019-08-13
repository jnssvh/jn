<%@ page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.io.*,java.util.*,org.apache.commons.fileupload.*,com.jaguar.*,project.*"%>
<%!
static int uploadCount = 0;
%>
<%@ include file="init.jsp" %>
<%
	String rootDir = AffixManager.getRootDir(jdb);
	{
		File folder = new File(rootDir);
		if (!folder.exists())
			folder.mkdirs();
		if (!folder.exists())
			rootDir = AffixManager.getConfigRootDir();
		if ( !rootDir.matches(".*(?:\\|/)$") )
			rootDir += File.separator;		
	}
	user = new SysUser();
	user.initWebUser(jdb, request.getCookies());
	request.setCharacterEncoding("GBK");

	int	affixid = WebChar.RequestInt(request, "affixid");		//�������е�ID�����0�����滻ԭ�ļ�
	String range = WebChar.requestStr(request, "range");		//�����Ĵ��ͷ�Χ(begin-end/filesize)
	long filetime = WebChar.RequestLong(request, "filetime");	//8�ֽڳ����ļ�ʱ��
	String DestDir = WebChar.requestStr(request, "DestDir");		//Ŀ��Ŀ¼��
	int ParentID = WebChar.RequestInt(request, "ParentID");		//���ڵ�ID
	int SecretType =  WebChar.RequestInt(request, "SecretType");//���ܵȼ� 1�������� 2��˽�У� 6��ϵͳ
	String fileDir = rootDir;
	String localname = "", sql, tag = "", result = "";
	long filesize = 0, rg1 = 0, rg2 = 0;
	if ((range != null) && !range.equals(""))
	{
		String ss[] = range.split("/");
		String sss[] = ss[0].split("-");
		filesize = Long.parseLong(ss[1]);
		rg1 = Long.parseLong(sss[0]);
		rg2 = Long.parseLong(sss[1]);
	}

	if (SecretType == 8964)
	{
		if (WebChar.RequestInt(request, "ask") == 1)
		{
			out.print("FILEPOS=0&AFFIXID=0");
		}
		else
		{
			DiskFileUpload fu = new DiskFileUpload(); 
			List fileItems = fu.parseRequest(request);    //��ʼ��ȡ�ϴ���Ϣ
			Iterator iter = fileItems.iterator();    // ���δ���ÿ���ϴ����ļ�
			while (iter.hasNext()) 
			{
				FileItem item = (FileItem) iter.next();        //�������������ļ�������б���Ϣ
				if(item.isFormField())
					continue;
	    		SysApp sysApp = new SysApp(jdb);
				String DevPublishPath = sysApp.getSysParam(5, "DevPublishPath", "��װ���ͱ��ݰ�����·��", "C:\\DevBackup");
				if ( !DevPublishPath.matches(".*(?:\\|/)$") )
					DevPublishPath += File.separator;
				
		    	localname = item.getName();
		   		if(VB.isEmpty(localname) && item.getSize() == 0)
		            continue;
		   		int pos = localname.lastIndexOf("\\");
		   		if (pos > 0)
		   			localname = localname.substring(pos + 1);
		    	if (rg1 > 0)
		    	{
					RandomAccessFile randomFile;
					if (DestDir.equals(""))
						randomFile = new RandomAccessFile(DevPublishPath + localname, "rw");
					else
						randomFile = new RandomAccessFile(DestDir, "rw");
					randomFile.seek(rg1);
					randomFile.write(item.get());
					randomFile.close();
		    	}
		    	else
		    	{
					String backupName = DevPublishPath + localname + "." + System.currentTimeMillis();
					File savedFile;
					if (DestDir.equals(""))
					{
						savedFile = new File(backupName);
						sql = "insert into SysDevLog (DevType, LogTime, UserID, IPAddress, ObjName, Info) values(2,'" + VB.Now() + "'," + user.UserID +
								"," + WebChar.GetIPAddress(request.getRemoteAddr()) + ",'" + localname + "','" + backupName + "')";
						jdb.ExecuteSQL(0, sql);
					}
					else
					{
						savedFile = new File(DestDir);
						File folder = new File(DevPublishPath);
						if (!folder.exists())
							folder.mkdirs();
						try
						{ 
							int byteread = 0; 
							if (savedFile.exists())
							{ //�ļ�����ʱ 
								InputStream inStream = new FileInputStream(DestDir); //����ԭ�ļ� 
								backupName = DevPublishPath + savedFile.getName() + "." + System.currentTimeMillis();

								FileOutputStream fs = new FileOutputStream(backupName); 
								byte[] buffer = new byte[4096];
								int length; 
								while ( (byteread = inStream.read(buffer)) != -1)
									fs.write(buffer, 0, byteread); 
								inStream.close(); 
								fs.close();
			    			} 
						} 
						catch (Exception e)
						{ 
		    				System.out.println("���Ƶ����ļ���������"); 
		    				e.printStackTrace(); 
						} 

						sql = "insert into SysDevLog (DevType, LogTime, UserID, IPAddress, ObjName, Info) values(1,'" + VB.Now() + "'," + user.UserID +
							"," + WebChar.GetIPAddress(request.getRemoteAddr()) + ",'" + savedFile.getName() + "','" + DestDir + "," + backupName + "')";
	   					jdb.ExecuteSQL(0, sql);
					}		
					item.write(savedFile);
					if (filesize == 0)
					{
						filesize = savedFile.length();
						rg2 = filesize;
					}
				}
			}
			System.out.println("SEND FILE OK.range=" + range + "filetime=" + DestDir);
			result = "OK:2018:" + range + ":" + filetime;
			out.println(result);
		}
		jdb.closeDBCon();
		return;		
	}
	
	if (SecretType == 0)
		SecretType = 6;
	int oldaffixid = affixid;
	if (ParentID == 0)
	{
		String saveto = WebChar.requestStr(request, "saveto");		//�������е��ļ�������
		if (!saveto.equals(""))
		{
			ParentID = WebChar.ToInt(jdb.GetTableValue(0, "AffixFile", "ID", "FileCName", "'" + saveto + "'"));
			if (ParentID == 0)
			{
				sql = "insert into AffixFile (ParentID, SecretType, FileAttrib, FileCName) values(0, " + SecretType + ", 1, '" + saveto + "')";
   				jdb.ExecuteSQL(0, sql);
				ParentID = WebChar.ToInt(jdb.GetTableValue(0, "AffixFile", "ID", "FileCName", "'" + saveto + "'"));
			}
		}
	}
	
	AffixManager afm = new AffixManager(jdb, user, request);
	boolean uploadEnable = afm.isFileUploadEnable(localname, filesize, ParentID, DestDir);

	if (WebChar.RequestInt(request, "Publish") == 1)
	{
		affixid = WebChar.RequestInt(request, "affixid");
		String ParentName = WebChar.requestStr(request, "ParentName");
		int parentNode = WebChar.ToInt(jdb.GetTableValue(0, "AffixFile", "ID", "FileCName", "'" + ParentName + "' and ParentID=0 and SecretType=1 and FileAttrib=1"));
		if (parentNode == 0)
		{
			sql = "insert into AffixFile (ParentID, SecretType, FileAttrib, FileCName) values(0, 1, 1, '" + ParentName + "')";
			jdb.ExecuteSQL(0, sql);
			parentNode = WebChar.ToInt(jdb.GetTableValue(0, "AffixFile", "ID", "FileCName", "'" + ParentName + "' and ParentID=0 and SecretType=1 and FileAttrib=1"));
		}
		sql = "update AffixFile set ParentID=" + parentNode + ", SecretType=1 where ID=" + affixid;
		jdb.ExecuteSQL(0, sql);
		out.print("ok");
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "ask") == 1)
	{
		localname = WebChar.requestStr(request, "localname");
		filesize = WebChar.RequestLong(request, "filesize");
		if (uploadEnable == false)
		{
			out.print("FILEPOS=" + filesize + "&AFFIXID=0");
			jdb.closeDBCon();
			return;
		}
		
		sql = "select * from AffixFile where SubmitMan='" + user.CMemberName + "' and LocalName='" + localname + "' and ParentID=" + ParentID;
		ResultSet rs = jdb.rsSQL(0, sql);
		long pos = 0;
		while (rs.next())
		{
			tag = rs.getString("SubParentID");		//����SubParentID����ļ��ϴ���Ϣ(��ʽ:�ѱ��泤��-�ļ�����:Դ�ļ�ʱ��)
			if ((tag != "") && !tag.equals(""))
			{
				String ss[] = tag.split(":");
				String sss [] = ss[0].split("-");
				if ((Long.parseLong(ss[1]) == filetime) && (Long.parseLong(sss[1]) == filesize))
				{
					pos = Long.parseLong(sss[0]);
					affixid = rs.getInt("ID");
					break;
				}
			}
		}
		out.print("FILEPOS=" + pos + "&AFFIXID=" + affixid);
		jdb.closeDBCon();
		return;
	}
	if (uploadEnable == false)
	{
		out.println("<html><head></head><body>Error.�����ϴ����������ܾ���</body></html>");
		jdb.closeDBCon();
		return;
	}

	if (!DestDir.equals(""))
	{
		String item = jdb.GetTableValue("SysConfig", "ParamValue", "ename", "'" + DestDir + "UploadPath'");
		if ((item == null) || item.equals(""))
			fileDir += DestDir + File.separator;
		else
			fileDir = item;
		File folder = new File(fileDir);
		if (!folder.exists())
			folder.mkdirs();
		if ( !fileDir.matches(".*(?:\\|/)$") )
				fileDir += File.separator;
	}
	String filename = "";		//ԭ�ļ���
	String fname = "";			//�ϴ����·��

	DiskFileUpload fu = new DiskFileUpload(); 
	List fileItems = fu.parseRequest(request);    //��ʼ��ȡ�ϴ���Ϣ
	Iterator iter = fileItems.iterator();    // ���δ���ÿ���ϴ����ļ�
	while (iter.hasNext()) 
	{
		FileItem item = (FileItem) iter.next();        //�������������ļ�������б���Ϣ
		if(item.isFormField())
			continue;
    	localname = item.getName();
   		if(VB.isEmpty(localname) && item.getSize() == 0)
            continue;
 //   	localname = localname.replace('\\','/');
    	if (rg1 > 0)
    	{
	  		sql = "select * from AffixFile where SubParentID='" + rg1 + "-" + filesize + ":" + filetime + 
	  			"' and SubmitMan='" + user.CMemberName + "' and LocalName='" + localname + "' and ParentID=" + ParentID;
   			ResultSet rs = jdb.rsSQL(0, sql);
	   		if (rs.next())
	   		{
				filename = rs.getString("FileCName");
				fname = rs.getString("FileURL");
				filename = rs.getString("FileCName");
				affixid = rs.getInt("ID");
				RandomAccessFile randomFile = new RandomAccessFile(fname, "rw");
//				long fileLength = randomFile.length(); 
//				randomFile.seek(fileLength);
				randomFile.seek(rg1);
				randomFile.write(item.get());
				randomFile.close();
    		}
    		else
    		{
    			WebChar.logger.error("�ϴ��ļ������Ҳ����ѱ���Ĳ��ݣ����ܶϵ�����" + user.CMemberName + "-" + localname);
	    		jdb.rsClose(0, rs);
	    		result = "Error";
	    		break;
    		}
    		jdb.rsClose(0, rs);
    	}
    	else
    	{
	    	File writeFile = new File(localname); 
	    	filename = writeFile.getName();
	    	String fileType = filename.replaceAll(".*\\.(\\w+)", "$1");
			fname = fileDir + System.currentTimeMillis() + WebChar.LStrFill( ++uploadCount, 4, "0" ) + "." + fileType;
			File savedFile = new File(fname);
			item.write(savedFile);
			if (filesize == 0)
			{
				filesize = savedFile.length();
				rg2 = filesize;
			}
			if (affixid != 0)
			{
				String url = jdb.getValueBySql(0, "SELECT FileURL FROM AffixFile WHERE ID=" + affixid);
				File delFile = new File(url);
				if (delFile.exists())
					delFile.delete();
			}
		}

		if (rg2 < filesize)
			tag = rg2 + "-" + filesize + ":" + filetime;
		else
			tag = filesize + "-" + filesize + ":" + filetime;

		String tt = VB.Now();
//		if (filesize > 0x7fffffff)	���ݿ����ļ������ֶ�Ҫ��Ϊ8�ֽ�����������2G�����ļ��������
//			filesize = 0x7fffffff;
		if (rg2 < filesize)
			SecretType = 6;	//�ϴ�δ���ʱ�������ó�ϵͳ�ļ���
		if (affixid != 0)
		{
			sql = "update AffixFile set LocalName='" + localname + "',ParentID=" + ParentID + ", FileURL='" + fname +
				"', SubmitMan='" + user.CMemberName + "', SecretType=" + SecretType + ", SubmitTime='" + tt + 
				"', SubParentID='" + tag + "' where ID=" + affixid;
			jdb.ExecuteSQL(0, sql);
			if (rg2 == filesize)
			{
				if (oldaffixid == 0)
				{
					afm.log("26", user.CMemberName + "�ϴ��ļ�" + filename, "" + affixid, SecretType);
					afm.SendAttention(user.CMemberName + "�ϴ����ļ���", "" + affixid);
				}
				else
				{
					afm.log("28", user.CMemberName + "�滻�ļ�" + filename, "" + affixid, SecretType);
					afm.SendAttention(user.CMemberName + "�滻���ļ���", "" + affixid);
				}
			}
		}
		else
		{
			sql = "INSERT INTO AffixFile(FileCName,LocalName,ParentID,FileURL,FileSize,SubmitMan,SubmitTime,SecretType,FileAttrib, SubParentID) VALUES('" +
				filename + "','" + localname + "'," + ParentID + ",'" + fname + "'," + filesize + ",'" + user.CMemberName + "','" +
				tt + "'," + SecretType + ",3,'" + tag + "')";
			jdb.ExecuteSQL(0, sql);
			affixid = WebChar.ToInt(jdb.getSQLValue(0, "SELECT id FROM AffixFile WHERE FileCName='" + filename + "' AND SubmitTime='" + tt + "'"));
			if (rg2 == filesize)
			{
				afm.log("26", user.CMemberName + "�ϴ��ļ�" + filename, "" + affixid, SecretType);
				afm.SendAttention(user.CMemberName + "�ϴ����ļ���", "" + affixid);
			}
			afm.VersionChangeName(affixid, ParentID, filename);
		}
//		sql = sql.replaceAll("\\\\", "\\\\\\\\");
		result = "OK:" + affixid + ":" + range + ":" + filetime;
		
		System.out.println("SEND FILE OK." + affixid + "range=" + range + "filetime=" + filetime);
		break;
    }
    
out.println(result);
jdb.closeDBCon();
%>