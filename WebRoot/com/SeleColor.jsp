<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
<HTML>
<HEAD>
<TITLE><j:Lang key="SeleColor.Select_color"/></TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=GBK">
<Link rel="stylesheet" type="text/css" href="pop.css">
<script language=javascript src=psub.jsp></script>
<SCRIPT LANGUAGE=JavaScript>
var SelRGB = '#000000';
var DrRGB = '';
var SelGRAY = '120';

var hexch = new Array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');

function ToHex(n)
{	var h, l;

	n = Math.round(n);
	l = n % 16;
	h = Math.floor((n / 16)) % 16;
	return (hexch[h] + hexch[l]);
}

function DoColor(c, l)
{ var r, g, b;

  r = '0x' + c.substring(1, 3);
  g = '0x' + c.substring(3, 5);
  b = '0x' + c.substring(5, 7);
  
  if(l > 120)
  {
    l = l - 120;

    r = (r * (120 - l) + 255 * l) / 120;
    g = (g * (120 - l) + 255 * l) / 120;
    b = (b * (120 - l) + 255 * l) / 120;
  }else
  {
    r = (r * l) / 120;
    g = (g * l) / 120;
    b = (b * l) / 120;
  }

  return '#' + ToHex(r) + ToHex(g) + ToHex(b);
}

function EndColor()
{ var i;

  if(DrRGB != SelRGB)
  {
    DrRGB = SelRGB;
    for(i = 0; i <= 30; i ++)
      GrayTable.rows(i).bgColor = DoColor(SelRGB, 240 - i * 8);
  }

  SelColor.value = DoColor(RGB.innerText, GRAY.innerText);
  ShowColor.bgColor = SelColor.value;
}

function ClickColorTable(obj)
{
	SelRGB = event.srcElement.bgColor;
	RGB.innerText = event.srcElement.bgColor.toUpperCase();
	EndColor();
}

function MouseoverColorTable(obj)
{
	RGB.innerText = event.srcElement.bgColor.toUpperCase();
	EndColor();
}

function MouseoutColorTable(obj)
{
	RGB.innerText = SelRGB;
	EndColor();
}

function ClickGrayTable(obj)
{
	SelGRAY = event.srcElement.title;
	GRAY.innerText = event.srcElement.title;
	EndColor();
}

function MouseoverGrayTable(obj)
{
	GRAY.innerText = event.srcElement.title;
	EndColor();
}

function MouseoutGrayTable(obj)
{
	GRAY.innerText = SelGRAY;
	EndColor();
}

function SelectNamedColor(obj)
{
	var x = obj.options[obj.selectedIndex].innerText.indexOf("#")
	RGB.innerText = obj.options[obj.selectedIndex].innerText.substr(x, 7);
	GRAY.innerText = "";
	SelColor.value = obj.options[obj.selectedIndex].style.backgroundColor;
	ShowColor.bgColor = SelColor.value;
}

function ConfirmDlg()
{
	window.returnValue = SelColor.value;
	if (IsNetBoxWindow())
		external.EndDialog(returnValue);
	else
		window.close();
}
</SCRIPT>
</HEAD>
	<BODY bgcolor=menu onload=InitParam()>
		<div align="center">
			<center>
				<table border="0" cellspacing="10" cellpadding="0">
					<tr>
						<td>
							<TABLE ID=ColorTable onclick=ClickColorTable(this)
								ondblclick=ConfirmDlg() BORDER=0 CELLSPACING=0 CELLPADDING=0
								style='cursor:pointer'>
								<SCRIPT LANGUAGE=JavaScript>
function wc(r, g, b, n)
{
	r = ((r * 16 + r) * 3 * (15 - n) + 0x80 * n) / 15;
	g = ((g * 16 + g) * 3 * (15 - n) + 0x80 * n) / 15;
	b = ((b * 16 + b) * 3 * (15 - n) + 0x80 * n) / 15;

	document.write('<TD BGCOLOR=#' + ToHex(r) + ToHex(g) + ToHex(b) + ' height=8 width=8></TD>');
}

var cnum = new Array(1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0);

  for(i = 0; i < 16; i ++)
  {
     document.write('<TR>');
     for(j = 0; j < 30; j ++)
     {
     	n1 = j % 5;
     	n2 = Math.floor(j / 5) * 3;
     	n3 = n2 + 3;

     	wc((cnum[n3] * n1 + cnum[n2] * (5 - n1)),
     		(cnum[n3 + 1] * n1 + cnum[n2 + 1] * (5 - n1)),
     		(cnum[n3 + 2] * n1 + cnum[n2 + 2] * (5 - n1)), i);
     }

     document.writeln('</TR>');
  }
</SCRIPT>
							</TABLE>
						</td>
						<td>
							<TABLE ID=GrayTable onclick=ClickGrayTable(this)
								ondblclick=ConfirmDlg() BORDER=0 CELLSPACING=0 CELLPADDING=0
								style='cursor:hand'>
<SCRIPT LANGUAGE=JavaScript>
  for(i = 255; i >= 0; i -= 8.5)
     document.write('<TR BGCOLOR=#' + ToHex(i) + ToHex(i) + ToHex(i) + '><TD TITLE=' + Math.floor(i * 16 / 17) + ' height=4 width=20></TD></TR>');
</SCRIPT>
							</TABLE>
						</td>
					</tr>
				</table>
			</center>
		</div>

		<div align="center">
			<center>
				<select ID=ColorAlias onchange=SelectNamedColor(this)>
					<option style="background-color:aliceblue;">
						aliceblue - (#F0F8FF)
					</option>
					<option style="background-color:antiquewhite;">
						antiquewhite - (#FAEBD7)
					</option>
					<option style="background-color:aqua;">
						aqua - (#00FFFF)
					</option>
					<option style="background-color:aquamarine;">
						aquamarine - (#7FFFD4)
					</option>
					<option style="background-color:azure;">
						azure - (#F0FFFF)
					</option>
					<option style="background-color:beige;">
						beige - (#F5F5DC)
					</option>
					<option style="background-color:bisque;">
						bisque - (#FFE4C4)
					</option>
					<option style="background-color:black;">
						black - (#000000)
					</option>
					<option style="background-color:blanchedalmond;">
						blanchedalmond - (#FFEBCD)
					</option>
					<option style="background-color:blue;">
						blue - (#0000FF)
					</option>
					<option style="background-color:blueviolet;">
						blueviolet - (#8A2BE2)
					</option>
					<option style="background-color:brown;">
						brown - (#A52A2A)
					</option>
					<option style="background-color:burlywood;">
						burlywood - (#DEB887)
					</option>
					<option style="background-color:cadetblue;">
						cadetblue - (#5F9EA0)
					</option>
					<option style="background-color:chartreuse;">
						chartreuse - (#7FFF00)
					</option>
					<option style="background-color:chocolate;">
						chocolate - (#D2691E)
					</option>
					<option style="background-color:coral;">
						coral - (#FF7F50)
					</option>
					<option style="background-color:cornflowerblue;">
						cornflowerblue - (#6495ED)
					</option>
					<option style="background-color:cornsilk;">
						cornsilk - (#FFF8DC)
					</option>
					<option style="background-color:crimson;">
						crimson - (#DC143C)
					</option>
					<option style="background-color:cyan;">
						cyan - (#00FFFF)
					</option>
					<option style="background-color:darkblue;">
						darkblue - (#00008B)
					</option>
					<option style="background-color:darkcyan;">
						darkcyan - (#008B8B)
					</option>
					<option style="background-color:darkgoldenrod;">
						darkgoldenrod - (#B8860B)
					</option>
					<option style="background-color:darkgray;">
						darkgray - (#A9A9A9)
					</option>
					<option style="background-color:darkgreen;">
						darkgreen - (#006400)
					</option>
					<option style="background-color:darkkhaki;">
						darkkhaki - (#BDB76B)
					</option>
					<option style="background-color:darkmagenta;">
						darkmagenta - (#8B008B)
					</option>
					<option style="background-color:darkolivegreen;">
						darkolivegreen - (#556B2F)
					</option>
					<option style="background-color:darkorange;">
						darkorange - (#FF8C00)
					</option>
					<option style="background-color:darkorchid;">
						darkorchid - (#9932CC)
					</option>
					<option style="background-color:darkred;">
						darkred - (#8B0000)
					</option>
					<option style="background-color:darksalmon;">
						darksalmon - (#E9967A)
					</option>
					<option style="background-color:darkseagreen;">
						darkseagreen - (#8FBC8B)
					</option>
					<option style="background-color:darkslateblue;">
						darkslateblue - (#483D8B)
					</option>
					<option style="background-color:darkslategray;">
						darkslategray - (#2F4F4F)
					</option>
					<option style="background-color:darkturquoise;">
						darkturquoise - (#00CED1)
					</option>
					<option style="background-color:darkviolet;">
						darkviolet - (#9400D3)
					</option>
					<option style="background-color:deeppink;">
						deeppink - (#FF1493)
					</option>
					<option style="background-color:deepskyblue;">
						deepskyblue - (#00BFFF)
					</option>
					<option style="background-color:dimgray;">
						dimgray - (#696969)
					</option>
					<option style="background-color:dodgerblue;">
						dodgerblue - (#1E90FF)
					</option>
					<option style="background-color:firebrick;">
						firebrick - (#B22222)
					</option>
					<option style="background-color:floralwhite;">
						floralwhite - (#FFFAF0)
					</option>
					<option style="background-color:forestgreen;">
						forestgreen - (#228B22)
					</option>
					<option style="background-color:fuchsia;">
						fuchsia - (#FF00FF)
					</option>
					<option style="background-color:gainsboro;">
						gainsboro - (#DCDCDC)
					</option>
					<option style="background-color:ghostwhite;">
						ghostwhite - (#F8F8FF)
					</option>
					<option style="background-color:gold;">
						gold - (#FFD700)
					</option>
					<option style="background-color:goldenrod;">
						goldenrod - (#DAA520)
					</option>
					<option style="background-color:gray;">
						gray - (#808080)
					</option>
					<option style="background-color:green;">
						green - (#008000)
					</option>
					<option style="background-color:greenyellow;">
						greenyellow - (#ADFF2F)
					</option>
					<option style="background-color:honeydew;">
						honeydew - (#F0FFF0)
					</option>
					<option style="background-color:hotpink;">
						hotpink - (#FF69B4)
					</option>
					<option style="background-color:indianred;">
						indianred - (#CD5C5C)
					</option>
					<option style="background-color:indigo;">
						indigo - (#4B0082)
					</option>
					<option style="background-color:ivory;">
						ivory - (#FFFFF0)
					</option>
					<option style="background-color:khaki;">
						khaki - (#F0E68C)
					</option>
					<option style="background-color:lavender;">
						lavender - (#E6E6FA)
					</option>
					<option style="background-color:lavenderblush;">
						lavenderblush - (#FFF0F5)
					</option>
					<option style="background-color:lawngreen;">
						lawngreen - (#7CFC00)
					</option>
					<option style="background-color:lemonchiffon;">
						lemonchiffon - (#FFFACD)
					</option>
					<option style="background-color:lightblue">
						lightblue - (#ADD8E6)
					</option>
					<option style="background-color:lightcoral;">
						lightcoral - (#F08080)
					</option>
					<option style="background-color:lightcyan;">
						lightcyan - (#E0FFFF)
					</option>
					<option style="background-color:lightgoldenrodyellow;">
						lightgoldenrodyellow - (#FAFAD2)
					</option>
					<option style="background-color:lightgreen;">
						lightgreen - (#90EE90)
					</option>
					<option style="background-color:lightgrey;">
						lightgrey - (#D3D3D3)
					</option>
					<option style="background-color:lightpink;">
						lightpink - (#FFB6C1)
					</option>
					<option style="background-color:lightsalmon;">
						lightsalmon - (#FFA07A)
					</option>
					<option style="background-color:lightseagreen;">
						lightseagreen - (#20B2AA)
					</option>
					<option style="background-color:lightskyblue;">
						lightskyblue - (#87CEFA)
					</option>
					<option style="background-color:lightslategray;">
						lightslategray - (#778899)
					</option>
					<option style="background-color:lightsteelblue;">
						lightsteelblue - (#B0C4DE)
					</option>
					<option style="background-color:lightyellow;">
						lightyellow - (#FFFFE0)
					</option>
					<option style="background-color:lime;">
						lime - (#00FF00)
					</option>
					<option style="background-color:limegreen;">
						limegreen - (#32CD32)
					</option>
					<option style="background-color:linen;">
						linen - (#FAF0E6)
					</option>
					<option style="background-color:magenta;">
						magenta - (#FF00FF)
					</option>
					<option style="background-color:maroon;">
						maroon - (#800000)
					</option>
					<option style="background-color:mediumaquamarine;">
						mediumaquamarine - (#66CDAA)
					</option>
					<option style="background-color:mediumblue;">
						mediumblue - (#0000CD)
					</option>
					<option style="background-color:mediumorchid;">
						mediumorchid - (#BA55D3)
					</option>
					<option style="background-color:mediumpurple;">
						mediumpurple - (#9370DB)
					</option>
					<option style="background-color:mediumseagreen;">
						mediumseagreen - (#3CB371)
					</option>
					<option style="background-color:mediumslateblue;">
						mediumslateblue - (#7B68EE)
					</option>
					<option style="background-color:mediumspringgreen;">
						mediumspringgreen - (#00FA9A)
					</option>
					<option style="background-color:mediumturquoise;">
						mediumturquoise - (#48D1CC)
					</option>
					<option style="background-color:mediumvioletred;">
						mediumvioletred - (#C71585)
					</option>
					<option style="background-color:midnightblue;">
						midnightblue - (#191970)
					</option>
					<option style="background-color:mintcream;">
						mintcream - (#F5FFFA)
					</option>
					<option style="background-color:mistyrose;">
						mistyrose - (#FFE4E1)
					</option>
					<option style="background-color:moccasin;">
						moccasin - (#FFE4B5)
					</option>
					<option style="background-color:navajowhite;">
						navajowhite - (#FFDEAD)
					</option>
					<option style="background-color:navy;">
						navy - (#000080)
					</option>
					<option style="background-color:oldlace;">
						oldlace - (#FDF5E6)
					</option>
					<option style="background-color:olive;">
						olive - (#808000)
					</option>
					<option style="background-color:olivedrab;">
						olivedrab - (#6B8E23)
					</option>
					<option style="background-color:orange;">
						orange - (#FFA500)
					</option>
					<option style="background-color:orangered;">
						orangered - (#FF4500)
					</option>
					<option style="background-color:orchid;">
						orchid - (#DA70D6)
					</option>
					<option style="background-color:palegoldenrod;">
						palegoldenrod - (#EEE8AA)
					</option>
					<option style="background-color:palegreen;">
						palegreen - (#98FB98)
					</option>
					<option style="background-color:paleturquoise;">
						paleturquoise - (#AFEEEE)
					</option>
					<option style="background-color:palevioletred;">
						palevioletred - (#DB7093)
					</option>
					<option style="background-color:papayawhip;">
						papayawhip - (#FFEFD5)
					</option>
					<option style="background-color:peachpuff;">
						peachpuff - (#FFDAB9)
					</option>
					<option style="background-color:peru;">
						peru - (#CD853F)
					</option>
					<option style="background-color:pink;">
						pink - (#FFC0CB)
					</option>
					<option style="background-color:plum;">
						plum - (#DDA0DD)
					</option>
					<option style="background-color:powderblue;">
						powderblue - (#B0E0E6)
					</option>
					<option style="background-color:purple;">
						purple - (#800080)
					</option>
					<option style="background-color:red;">
						red - (#FF0000)
					</option>
					<option style="background-color:rosybrown;">
						rosybrown - (#BC8F8F)
					</option>
					<option style="background-color:royalblue;">
						royalblue - (#4169E1)
					</option>
					<option style="background-color:saddlebrown;">
						saddlebrown - (#8B4513)
					</option>
					<option style="background-color:salmon;">
						salmon - (#FA8072)
					</option>
					<option style="background-color:sandybrown;">
						sandybrown - (#F4A460)
					</option>
					<option style="background-color:seagreen;">
						seagreen - (#2E8B57)
					</option>
					<option style="background-color:seashell;">
						seashell - (#FFF5EE)
					</option>
					<option style="background-color:sienna;">
						sienna - (#A0522D)
					</option>
					<option style="background-color:silver;">
						silver - (#C0C0C0)
					</option>
					<option style="background-color:skyblue;">
						skyblue - (#87CEEB)
					</option>
					<option style="background-color:slateblue;">
						slateblue - (#6A5ACD)
					</option>
					<option style="background-color:slategray;">
						slategray - (#708090)
					</option>
					<option style="background-color:snow;">
						snow - (#FFFAFA)
					</option>
					<option style="background-color:springgreen;">
						springgreen - (#00FF7F)
					</option>
					<option style="background-color:steelblue;">
						steelblue - (#4682B4)
					</option>
					<option style="background-color:tan;">
						tan - (#D2B48C)
					</option>
					<option style="background-color:teal;">
						teal - (#008080)
					</option>
					<option style="background-color:thistle;">
						thistle - (#D8BFD8)
					</option>
					<option style="background-color:tomato;">
						tomato - (#FF6347)
					</option>
					<option style="background-color:turquoise;">
						turquoise - (#40E0D0)
					</option>
					<option style="background-color:violet;">
						violet - (#EE82EE)
					</option>
					<option style="background-color:wheat;">
						wheat - (#F5DEB3)
					</option>
					<option style="background-color:white;">
						white - (#FFFFFF)
					</option>
					<option style="background-color:whitesmoke;">
						whitesmoke - (#F5F5F5)
					</option>
					<option style="background-color:yellow;">
						yellow - (#FFFF00)
					</option>
					<option style="background-color:yellowgreen;">
						yellowgreen - (#9ACD32)
					</option>
				</select>
			</center>
		</div>

		<div align="center">
			<center>
				<table border="0" cellspacing="10" cellpadding="0" width="100%">
					<tr>
						<td rowspan="2" align="center" width=70>
							<table ID=ShowColor bgcolor="#000000" border="1" width="50"
								height="40" cellspacing="0" cellpadding="0">
								<tr>
									<td></td>
								</tr>
							</table>
						</td>
						<td rowspan="2">
							<j:Lang key="SeleColor.Jise"/>
							<SPAN ID=RGB>#000000</SPAN>
							<BR>
							<j:Lang key="SeleColor.Liangdui"/>
							<SPAN ID=GRAY>120</SPAN>
							<BR>
					<j:Lang key="SeleColor.Daima"/>
							<INPUT TYPE=TEXT SIZE=20 ID=SelColor value="#000000">
						</td>
						<td width=50>
							<BUTTON id=Ok onclick=ConfirmDlg()>
							<j:Lang key="psub.Queding"/>
							</BUTTON>
						</td>
					</tr>
					<tr>
						<td width=50>
							<BUTTON onclick=CloseWin();>
								<j:Lang key="SeleColor.Guanbi"/>
							</BUTTON>
						</td>
					</tr>
				</table>
			</center>
		</div>

	</BODY>
<SCRIPT LANGUAGE=JavaScript>
function InitParam()
{
	var param = window.dialogArguments;
	if (IsNetBoxWindow())
		param = external.Argument;
	if (typeof(param) != "string")
		return;
	var values = param.split(",");
	if (values.length >=1)
	{
		document.all.SelColor.value = values[0];
		document.all.ShowColor.bgColor = values[0];
		document.all.RGB.value = values[0];
	}
	if (values.length >=2)
	{
		if (values[1] == 0)
			document.all.ColorAlias.style.display = "none";
	}
}
</SCRIPT>
</HTML>
