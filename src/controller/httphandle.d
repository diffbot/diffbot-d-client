/**

HTTP Handler to fetch requests from Diffbot $(LINK http://www.diffbot.com/dev/docs/)

Authors: Daniel Vieira <daniel@fablefactory.com.br>

Date: 2014-02-03

History: 

version 0.0.1 - initial development

Copyright: Daniel Vieira 2014

License:

Copyright (c) 2014, Daniel Vieira
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.

*/

module controller.httphandle;

import std.net.curl;
import std.stdio;
import std.conv;
import std.datetime;

class HTTPHandle {

	private HTTP _http;

	private string[string] _headers;

	/// Data from the HTTP request
	private string _data;
	
	private string _url;

	this(string url) {

		_url = url;

		http = HTTP(url);

	}

	string url() {
	
		return _url;
	
	}
	
	void url(string url) {
	
		_url = url;
	
	}


	string[string] headers() {
	
		return _headers;
	
	}


	HTTP http() {
	
		return _http;
	
	}
	
	void http(HTTP http) {
	
		_http = http;
	
	}
	
	void headers(string[string] headers) {
	
		_headers = headers;
	
	}

	string data() {
	
		return _data;
	
	}
	
	void data(string data) {
	
		_data = data;
	
	}

	/**

	Fetchs data from Diffbot server

	*/

	public void fetchData() {

		addDelegates();

		http.perform();

	}

	/**

	Get a specific header from the HTTP Headers

	*/

	public string getHeader(string header) {

		if (header in _headers) return header;

		else return null;

	}

	public void addDelegates() {

		addFetchHeadersDelegate();
		addFetchDataDelegate();

	}

	/** 

	Add a delegate to fetch the HTTP headers 

	*/

	private void addFetchHeadersDelegate() {

		http.onReceiveHeader = (in char[] key, in char[] value) {

			_headers[key] = to!string(value);

		};

	}

	/**

	Add a delegate to fetch the data from the HTTP request

	*/

	private void addFetchDataDelegate() {

		http.onReceive = (ubyte[] data) { 

			_data ~= cast (string) data;

			return data.length;

		};

	}

}