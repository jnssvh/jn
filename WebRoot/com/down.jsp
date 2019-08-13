<%@page import="project.SysApp"%>
<%@page import="project.SysUser"%>
<%@page import="project.SystemLog"%>
<%@ page contentType=" text/html; charset=GBK " pageEncoding="GBK"%>
<%@ page
	import="java.io.*,java.util.*,java.text.*,com.jaguar.*,org.apache.log4j.Logger"%>
<%@page import="com.jaguar.app.IAfterDown"%>
<%!static Logger logger = null;
	static String rootDir = "";

	/** 
	 *  If returns true, then should return a 304 (HTTP_NOT_MODIFIED)
	 */
	public static boolean checkFor304(HttpServletRequest req, File file) {
		// 
		//   We'll do some handling for CONDITIONAL GET (and return a 304)
		//   If the client has set the following headers, do not try for a 304.
		// 
		//     pragma: no-cache
		//     cache-control: no-cache
		//

		if ("no-cache".equalsIgnoreCase(req.getHeader("Pragma"))
				|| "no-cache".equalsIgnoreCase(req.getHeader("cache-control"))) {
			//  Wants specifically a fresh copy 
		} else {
			// 
			//   HTTP 1.1 ETags go first
			//
			String thisTag = Long.toString(file.lastModified());

			String eTag = req.getHeader("If-None-Match");

			if (eTag != null) {
				if (eTag.equals(thisTag)) {
					return true;
				}
			}

			// 
			//   Next, try if-modified-since
			//
			DateFormat rfcDateFormat = new SimpleDateFormat(
					"EEE, dd MMM yyyy HH:mm:ss z");
			Date lastModified = new Date(file.lastModified());

			try {
				long ifModifiedSince = req.getDateHeader("If-Modified-Since");

				// log.info("ifModifiedSince:"+ifModifiedSince); 
				if (ifModifiedSince != -1) {
					long lastModifiedTime = lastModified.getTime();

					// log.info("lastModifiedTime:" + lastModifiedTime); 
					if (lastModifiedTime <= ifModifiedSince) {
						return true;
					}
				} else {
					try {
						String s = req.getHeader("If-Modified-Since");

						if (s != null) {
							Date ifModifiedSinceDate = rfcDateFormat.parse(s);
							// log.info("ifModifiedSinceDate:" + ifModifiedSinceDate); 
							if (lastModified.before(ifModifiedSinceDate)) {
								return true;
							}
						}
					} catch (ParseException e) {
						// log.warn(e.getLocalizedMessage(), e); 
					}
				}
			} catch (IllegalArgumentException e) {
				//  Illegal date/time header format.
				//  We fail quietly, and return false.
				//  FIXME: Should really move to ETags. 
			}
		}
		return false;
	}%>
<%

JDatabase jdb = null;
WebUser user = null;
String sourceUrl = request.getHeader("Referer");
jdb = new JDatabase();
jdb.InitJDatabase();
/*
if (sourceUrl == null) {
	user =new SysUser();
	if (user.initWebUser(jdb, request.getCookies()) != 1)
	{
		ServletContext sc = getServletContext();
		request.setAttribute("pagename", SysApp.scriptName(request));
		RequestDispatcher rd = sc.getRequestDispatcher("/com/error.jsp");
		rd.forward(request, response);
		out.clear();
		out = pageContext.pushBody();
		jdb.closeDBCon();
		return;
	} else {
		sourceUrl = "";
	}
}
if (sourceUrl.indexOf("/espace/") > 0) {

} else {
	if (user == null) {
		user =new SysUser();
		if (user.initWebUser(jdb, request.getCookies()) != 1)
		{
			ServletContext sc = getServletContext();
			request.setAttribute("pagename", SysApp.scriptName(request));
			RequestDispatcher rd = sc.getRequestDispatcher("/com/error.jsp");
			rd.forward(request, response);
			out.clear();
			out = pageContext.pushBody();
			jdb.closeDBCon();
			return;
		}
	}
}
*/


%>

<%
	int FormType = 1;
	String DataID = WebChar.requestStr(request, "DataID");
%>
<%
	logger = Logger.getLogger("down.jsp");
	if (rootDir.length() == 0) {
		rootDir = new WebChar()
				.getNodeContent("application{type=upload file} > root");
	}
	/*
	 System.out.println("Header....");
	 Enumeration<String> e1 = request.getHeaderNames();
	 String key;
	 while(e1.hasMoreElements()){
	 key = e1.nextElement();
	 System.out.println(key+"="+request.getHeader(key));
	 }
	 System.out.println("Attribute....");
	 e1 = request.getAttributeNames();
	 while(e1.hasMoreElements()){
	 key = e1.nextElement();
	 System.out.println(key+"="+request.getAttribute(key));
	 }

	 System.out.println("Parameter....");
	 e1 = request.getParameterNames();
	 while(e1.hasMoreElements()){
	 key = e1.nextElement();
	 System.out.println(key+"="+request.getParameter(key));
	 }
	 */

	String laiyuan0 = request.getRemoteHost();
	//  ����� WEB APP �µ����·���ļ�, ��ʹ�����д���:
	String root = getServletContext().getRealPath("/");
	String inpage = WebChar.requestStr(request, "inpage"); //��ҳ������ʾͼƬ
	String path = WebChar.requestStr(request, "path"); //·��
	String name = WebChar.unescape(WebChar.requestStr(request, "name")); //Ŀ���ļ�
	String rename = WebChar.unescape(WebChar.requestStr(request,
			"rename")); //����ʱ������
	String AffixID = WebChar.requestStr(request, "AffixID"); //�������еı��
	String script = WebChar.unescape(WebChar.requestStr(request,
			"script")); //
	String afterClass = WebChar.requestStr(request, "class");

	String filePath = "";
	boolean isInline = false; //  �Ƿ�����ֱ����������ڴ�(���������ܹ�Ԥ�����ļ�����,
	if (inpage.matches("(?i)true")) {
		isInline = true;
	}
	if (AffixID.length() > 0) {
		filePath = jdb.getSQLValue(0,
				"SELECT FileURL FROM AffixFile WHERE id=" + AffixID);
		rename = jdb.getSQLValue(0,
				"SELECT FileCName FROM AffixFile WHERE id=" + AffixID);
		rename = rename.replaceAll("(.*)\\..*", "$1");
		String sql = "UPDATE AffixFile SET AccessCount=COALESCE(AccessCount,0)+1,LastAccessTime='"
				+ VB.Now() + "' WHERE ID=" + AffixID;
		jdb.ExecuteSQL(0, sql);
	} else {
		if (name.matches(".*\\.(jsp|htm|html|xml|class|jar)$")) {
    		SystemLog.setLog(jdb, user, request, "0", "���طǷ��ļ�[" + name + "]����ֹ", "AffixFile", "");
    		jdb.closeDBCon();
    		return;
		}
		if (name.matches("file:.*")) {
			filePath = rootDir + name.replaceAll("file:", "");

		} else {
			if (path.length() == 0) {
				path = WebChar.isString((String) request
						.getAttribute("path"));
			}

			if (name.length() == 0) {
				name = (String) request.getAttribute("name");
			}
			if (VB.isEmpty(name)) {
				return;
			}
			if (path.length() > 0 && path.matches("\\w:.+|/.+")) {
				root = "";
			}
			filePath = root + path + name;

			if (name.matches(".+?:.*")) {
				filePath = name;
			}
		}
		if (rename.length() == 0) {
			rename = VB.isString((String) request
					.getAttribute("rename"));
		}
	}
	jdb.closeDBCon();
	//  ��ô�ļ�������, �������ʾ����)

	//  ��ջ�����, ��ֹҳ���еĿ���, �ո���ӵ�Ҫ���ص��ļ�������ȥ
	//  �������յĻ��ڵ��� response.reset() ��ʱ�� Tomcat �ᱨ��
	//  java.lang.IllegalStateException: getOutputStream() has already been called for
	//  this response, 
	out.clear();

	//  {{{ BEA Weblogic �ض�
	//  ���� Bea Weblogic ���� "getOutputStream() has already been called for this response"���������
	//  �����ļ�����ʱ�����ļ�������ķ�ʽ����
	//  ����response.reset()���������еģ�>���治Ҫ���У��������һ����
	//  ��ΪApplication Server�ڴ������jspʱ���ڣ�>��<��֮�������һ����ԭ�����������Ĭ����PrintWriter��
	//  ����ȴҪ�����������ServletOutputStream���������൱����ͼ��Servlet��ʹ������������ƣ�
	//  �ͻᷢ����getOutputStream() has already been called for this response�Ĵ���
	//  ��ϸ�����More Java Pitfill��һ��ĵڶ����� Web��Item 33����ͼ��Servlet��ʹ������������� 270
	//  ��������л��У������ı��ļ�û��ʲô���⣬���Ƕ���������ʽ������AutoCAD��Word��Excel���ļ�
	// �����������ļ��оͻ���һЩ���з�0x0d��0x0a���������ܵ���ĳЩ��ʽ���ļ��޷��򿪣���ЩҲ���������򿪡�
	//  ͬʱ���ַ�ʽҲ����ջ�����, ��ֹҳ���еĿ��е����������������ȥ 
	response.reset();
	//  }}} 

	try {
		java.io.File f = new java.io.File(filePath);
		if (!f.exists()) {
			logger.error("�ļ������ڣ�" + filePath);
			response.setCharacterEncoding("GBK");
			if (script.length() > 0) {
				out.print("<script type=\"text/javascript\">eval(\""
						+ script + "\");</script>");
			}
			return;
		}
		if (f.exists() && f.canRead()) {
			//  ����Ҫ���ͻ��˵Ļ������Ƿ��Ѿ����˴��ļ������°汾, ��ʱ��͸���
			//  �ͻ�����������������, ��Ȼ���������Ҳû�й�ϵ 
			if (checkFor304(request, f)) {
				//�ͻ����Ѿ��������°汾, ���� 304 
				response.sendError(HttpServletResponse.SC_NOT_MODIFIED);
				return;
			}
			//  �ӷ���������������ȡ�ļ��� contentType �����ô�contentType, ���Ƽ�����Ϊ
			//  application/x-download, ��Ϊ��ʱ�����ǵĿͻ����ܻ�ϣ�����������ֱ�Ӵ�,
			//  �� Excel ����, ���� application/x-download Ҳ����һ����׼�� mime type,
			//  �ƺ� FireFox �Ͳ���ʶ���ָ�ʽ�� mime type 
			String mimetype = null;
			mimetype = application.getMimeType(filePath);
			if (mimetype == null) {
				mimetype = "application/octet-stream;charset=ISO8859-1 ";
			}
			response.setContentType(mimetype);
			//  IE �Ļ���ֻ���� IE ����ʶ��ͷ�������� HTML �ļ�, ���� IE �ض�Ҫ�򿪴��ļ�! 
			String ua = request.getHeader("User-Agent"); //  ��ȡ�ն����� 
			if (ua == null)
				ua = "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0;)";
			boolean isIE = ua.toLowerCase().indexOf("msie") != -1; //  �Ƿ�Ϊ IE 

			if (isIE && !isInline) {
				mimetype = "application/x-msdownload";
			}
			//  �������ǽ��跨�ÿͻ��˱����ļ���ʱ����ʾ��ȷ���ļ���, ������ǽ��ļ���
			//  ת��Ϊ ISO8859-1 ���� 
			boolean isYzView=WebChar.RequestInt(request,"isYzView")>0;
			String downFileName = new String(isYzView?f.getName().getBytes("utf-8"):f.getName().getBytes(),
					"ISO8859-1");
			if (rename.length() > 0) {
				rename += f.getName().replaceAll(".+(\\..+)", "$1");
				downFileName = new String(isYzView?rename.getBytes("utf-8"):rename.getBytes(),
						"ISO8859-1");
			}

			String inlineType = isInline ? "inline" : "attachment"; //  �Ƿ���������
			//  or using this, but this header might not supported by FireFox
			// response.setContentType("application/x-download"); 
			response.setHeader("Content-Disposition", inlineType
					+ ";filename=\"" + downFileName + "\"");

			response.setContentLength((int) f.length()); //  �����������ݴ�С 
			// �����ļ�����޸�ʱ�䣬��������Ԥ�������𵽻�������� lxt 2017.7.19
			response.setDateHeader("Last-Modified", f.lastModified());

			byte[] buffer = new byte[4096]; //  ������ 
			BufferedOutputStream output = null;
			BufferedInputStream input = null;
			try {
				output = new BufferedOutputStream(response
						.getOutputStream());
				input = new BufferedInputStream(new FileInputStream(f));
				int n = (-1);
				while ((n = input.read(buffer, 0, 4096)) > -1) {
					output.write(buffer, 0, n);
				}
				response.flushBuffer();
				if (VB.isNotEmpty(afterClass)) {
					try {
						Class cls = Class.forName(afterClass);
						if (cls.isAssignableFrom(IAfterDown.class)) {
							IAfterDown afterDown = (IAfterDown) cls
									.newInstance();
							jdb = new JDatabase();
							jdb.InitJDatabase();
							afterDown.check(request, jdb, VB.CInt(AffixID));
							jdb.closeDBCon();
						}
					} catch (Exception e) {
						WebChar.printError(e, WebChar.logger, "class:"
								+ afterClass);
					}
				}
			} catch (Exception e) {
				WebChar.printError(e, WebChar.logger);
			} //�û�����ȡ�������� 
			finally {
				if (input != null)
					input.close();
				if (output != null)
					output.close();
			}

		}
		return;
	} catch (Exception ex) {
		WebChar.printError(ex, WebChar.logger);
	}
	//  �������ʧ���˾͸����û����ļ������� 
	response.sendError(404);
%>