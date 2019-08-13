package servlet;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import project.AjaxModelImpl;
import project.SysApp;
import project.SysUser;

import com.jaguar.JDatabase;
import com.jaguar.VB;
import com.jaguar.WebChar;
import com.jaguar.WebUser;

public class AjaxFunction extends HttpServlet {
	private static Logger logger = Logger.getLogger(AjaxFunction.class.getName());
	private static Map<String, String> classList = null;
	private static Map<String, Method> methodMap = null;

	private static final long serialVersionUID = -8386689983035422476L;

	static {
		classList = new HashMap<String, String>();

		WebChar charOption = new WebChar();
		Node moduleNode = charOption.getNode("WEB-INF/app_config.xml", "application{type=Ajax function class}");
		NodeList moduleList = moduleNode.getChildNodes();
		Node node = null;
		String moduleName = "", className = "";
		for (int i = 0; i < moduleList.getLength(); i++) {
			node = moduleList.item(i);
			if (node.getNodeType() != Node.ELEMENT_NODE)
				continue;
			if (node.getNodeName().matches("(?i)module")) {
				moduleName = WebChar.getValueByNodeName(node, "module_name");
				className = WebChar.getValueByNodeName(node, "class");
				classList.put(moduleName, className);
			}
		}
	}

	public static String getClassName(String className) {
		String rtn = "";
		if (VB.isEmpty(className)) {
			rtn = "project.ForAjaxFunction";
		} else {
			rtn = classList.get(className);
		}
		return rtn;
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		JDatabase jdb = null;
		WebUser user = null;
		SysApp sysApp = null;
		int nDB = 0;
		PrintWriter out = null;

		response.setContentType("text/html");
		// 用于方便手机端访问浏览器本地用 lxt 2016.3.24
		response.setHeader("Access-Control-Allow-Origin", "*");

		jdb = new JDatabase();
		int isAutoCommit = WebChar.RequestInt(request, "commit");
		if (isAutoCommit == 1) {
			jdb.setAutoCommit(nDB, false);
		}
		jdb.InitJDatabase();
		user = new SysUser();
		String auth = WebChar.requestStr(request, "auth");
		boolean isNotAuth = auth.equals("false");
		boolean isAuth = !auth.equals("false");
		if (isNotAuth) {
			isAuth = getClass().getName().indexOf("AjaxFunction") >= 0;
			// logger.info("===isAuth = " + isAuth);
		}
		String url = request.getServletPath();
		if (url.indexOf("AjaxInvoke") >= 0) {
			isAuth = false;
		}
		Cookie[] cookies = request.getCookies();
		int r = user.initWebUser(jdb, cookies);
		if (isAuth && r != 1) {
			out = response.getWriter();
			out.print(WebChar.escape("error:认证失败"));
			out.close();
			return;
		}

		sysApp = new SysApp(jdb);

		String type = WebChar.requestStr(request, "action_type");
		if (type.isEmpty()) {
			type = WebChar.requestStr(request, "type");
		}
		String rtn = "";

		// 以后增加新的ajax应用，这各类就不再增加判断了，统一由这里处理，只需要在forAjaxFunction里面增加新的方法就可以了
		// 缺点是不知道从哪里调用过来的，要是能标明都哪些页面调用就好了
		if (type.matches("[A-Z].*")) {
			type = type.substring(0, 1).toLowerCase() + type.substring(1);
		}

		rtn = "";

		Class<?> cls = null;
		AjaxModelImpl ajaxFunc = null;
		Method method = null;

		String className = WebChar.requestStr(request, "project");
		className = getClassName(className);
		String customClassName = WebChar.requestStr(request, "class");
		if (!customClassName.isEmpty()) {
			className = customClassName;
		}
		try {
			// 是固定写好呢，还是传过来好呢？还是从配置文件里面读取好呢？
			if (methodMap == null) {
				methodMap = new HashMap<String, Method>();
			}

			cls = Class.forName(className);
			ajaxFunc = (AjaxModelImpl) cls.newInstance();
			ajaxFunc.init(jdb, user, sysApp, request, response);

			String mapType = className + "." + type;
			method = methodMap.get(mapType);
			if (method == null) {
				method = cls.getMethod(type, null); // 调用ajax方法
				methodMap.put(mapType, method);
			}
			rtn = (String) method.invoke(ajaxFunc, null);
		} catch (SecurityException e) {
			WebChar.printError(e, logger, type);
			rtn = "error:" + e.getMessage();
		} catch (NoSuchMethodException e) {
			WebChar.printError(e, logger, type);
			rtn = "error:" + e.getMessage();
		} catch (IllegalArgumentException e) {
			WebChar.printError(e, logger, type);
			rtn = "error:" + e.getMessage();
		} catch (IllegalAccessException e) {
			WebChar.printError(e, logger, type);
			rtn = "error:" + e.getMessage();
		} catch (InvocationTargetException e) {
			WebChar.printError(e, logger, type);
			rtn = "error:" + e.getMessage();
		} catch (ClassNotFoundException e) {
			WebChar.printError(e, logger, type);
			rtn = "error:" + e.getMessage();
		} catch (InstantiationException e) {
			WebChar.printError(e, logger, type);
			rtn = "error:" + e.getMessage();
		}

		if (isAutoCommit == 1) {
			if (rtn.indexOf("error:") < 0 && VB.isEmpty(jdb.getErrorStr(nDB))) {
				if (jdb.commit(nDB) < 0) {
					jdb.rollBack(nDB);
				}
			} else {
				jdb.rollBack(nDB);
			}
		}
		if (rtn.matches("(page|html|source|body):[\\s\\S]*")) {
			response.setCharacterEncoding("gbk");
		}
		out = response.getWriter();
		if (rtn.indexOf("page:") == 0) {
			rtn = rtn.substring("page:".length());
			out.print(rtn);
		} else if (rtn.indexOf("formerror:") == 0) {
			rtn = "<SCRIPT LANGUAGE=\"JavaScript\">alert(unescape(\""
					+ WebChar.escape(rtn.substring("formerror:".length())) + "\"));</SCRIPT>";
			out.print(rtn);
		} else if (rtn.indexOf("forward:") == 0) {
			String[] arr = null; // forward:url:filename
			String splitStr = ":";
			if (rtn.indexOf("<:>") >= 0) {
				rtn = rtn.replaceFirst(":", "<:>");
				splitStr = "<:>";
			}
			arr = rtn.split(splitStr, rtn.length());
			ServletContext sc = getServletContext();
			request.setAttribute("pagename", SysApp.scriptName(request));
			url = "";
			if (arr[1].equals("url")) {
				url = arr[2];
			} else {
				if (arr.length > 2) {
					request.setAttribute("rename", arr[2]);
				}
				url = "/com/down.jsp?name=" + arr[1];
			}
			RequestDispatcher rd = sc.getRequestDispatcher(url);
			rd.forward(request, response);
		} else if (rtn.indexOf("script:") == 0) {
			rtn = "<SCRIPT LANGUAGE=\"JavaScript\">" + rtn.substring("script:".length()) + "</SCRIPT>";
			out.print(rtn);
		} else if (rtn.indexOf("flow_file:") == 0) {
			byte[] buf;
			int len = 0;
			BufferedInputStream br = null;
			OutputStream ut = null;
			String fileName;

			fileName = WebChar.getValueByRegExp("flow_file:([^;]*);[\\s\\S]*", rtn);
			fileName = new String(fileName.getBytes(), "ISO8859-1");
			rtn = WebChar.getValueByRegExp("flow_file:[^;]*;([\\s\\S]*)", rtn);
			response.reset();// 必须加，不然保存不了临时文件
			response.setContentType("application/x-msdownload");
			response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
			ut = response.getOutputStream();
			buf = rtn.getBytes();
			ut.write(buf);
		} else if (rtn.indexOf("source:") == 0) {
			rtn = rtn.substring("source:".length());
			out.print(rtn);
		} else if (rtn.indexOf("html:") == 0) {
			rtn = rtn.substring("html:".length());
			out.print(rtn);
		} else if (rtn.indexOf("body:") == 0) {
			rtn = rtn.substring("body:".length());
			StringBuilder str = new StringBuilder();
			str.append("<!DOCTYPE HTML>");
			str.append("<html>");
			str.append("<head>");
			str.append("<META http-equiv='Content-Type' content='text/html;' charset='gbk'>");
			str.append("<title>网页</title>");
			str.append("</head>");
			str.append("<body>");
			str.append(rtn);
			str.append("</body>");
			str.append("</html>");
			out.print(str.toString());
		} else {
			rtn = WebChar.escape(rtn);
			out.print(rtn);
		}

		ajaxFunc = null;

		sysApp = null;
		user = null;
		jdb.closeDBCon();
		jdb = null;
		out.flush();
		out.close();
	}

	/**
	 * The doPost method of the servlet. <br>
	 * 
	 * This method is called when a form has its tag value method equals to
	 * post.
	 * 
	 * @param request
	 *            the request send by the client to the server
	 * @param response
	 *            the response send by the server to the client
	 * @throws ServletException
	 *             if an error occurred
	 * @throws IOException
	 *             if an error occurred
	 */
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		doGet(request, response);
	}
}
