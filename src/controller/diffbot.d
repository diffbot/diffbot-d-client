/**

Base class for diffbot's APIs $(LINK http://www.diffbot.com/dev/docs/)

Authors: Daniel Vieira <daniel@fablefactory.com.br>

Date: 2014-01-29

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

module controller.diffbot;

import std.stdio;
import std.net.curl;
import std.json;
import std.variant;
import std.conv;
import std.string;
import std.array;
import std.algorithm;

import controller.httphandle;
import controller.exception;

struct Url {

	static const string api = "http://api.diffbot.com";
	
	/// URL that will be sent to Diffbot API
	string request;

	/// URL to process (URL encoded).
	string target;

}

class DiffBot {

	enum METHOD { ANALYZE,ARTICLE,FRONTPAGE,IMAGE,PRODUCT }

	static const string versionTag = "v2";

	/// Structure to handle the url target and the url request that will be sent to the diffbot
	public Url url;  

	/// Developer Token
	private string _token;

	/// API method to invoke
	private METHOD _method;

	/// HTTP class that handles HTTP requests
	private HTTPHandle _httpHandle;

	/// Optional arguments
	private string[string] _optionalArguments;

	/// The fields that should be returned with the API response
	private string[] _responseFields;

	this() {

	}

	/**

	Params:

		token = Developer Token
		target = the URL from which we'll fetch data
	
	*/

	this (string token,string target) {

		_token = token;
		url.target = target;

		// Default method
		method = METHOD.ARTICLE;
	
	}

	@property {

		HTTPHandle httpHandle() {
		
			return _httpHandle;
		
		}
		
		void httpHandle(HTTPHandle httpHandle) {
		
			_httpHandle = httpHandle;
		
		}

		string token() {
		
			return _token;
		
		}
		
		void token(string token) {
		
			_token = token;
		
		}

		METHOD method() {
		
			return _method;
		
		}
		
		void method(METHOD method) {
		
			_method = method;
			
		}


		string[string] optionalArguments() {
		
			return _optionalArguments;
		
		}
		
		void optionalArguments(string[string] optionalArguments) {
		
			_optionalArguments = optionalArguments;
		
		}

		string[] responseFields() {
		
			return _responseFields;
		
		}
		
		void responseFields(string[] responseFields) {
		
			_responseFields = responseFields;
		
		}

	}

	/** 

	Constructs the URL that will be sent to the Diffbot server.

	*/

	void makeURL() {

		string method = to!string(_method).toLower(); 

		if (! _token) throw new DiffBotException("You must provide a token to use the DiffBot API");
		if (! url.target) throw new DiffBotException("You must provide a URL to use the DiffBot API");
		if (! method) throw new DiffBotException("You must provide a method to use the DiffBot API");

		url.request = format("%s/%s/%s?token=%s&url=%s",
						
							url.api,
							versionTag,
							method,
							_token,
							url.target

						);

		if (_optionalArguments.length > 0) {

			foreach (key,argument;_optionalArguments) {

				url.request ~= format("&%s=%s",key,argument);

			}

		}


		if (_responseFields.length > 0) {

			url.request ~= "&fields=";

			foreach (index,field;_responseFields) {

				url.request ~= field ~ (index > responseFields.length ? "," : "");

			}
		
		}

		_httpHandle = new HTTPHandle(url.request);

	}

	/** 

	Sends the URL with the request to the diffbot server 

	Returns: JSONValue The Diffbot API response

	*/

	public JSONValue sendRequestToServer() {

		try {

			_httpHandle.fetchData();

		}

		catch (CurlException exception) {

			throw new DiffBotException("Data transfer exception");

		}

		// Waits for the diffbot server response

		while (_httpHandle.data.length == 0) {}

		JSONValue jsonValue;

		try {

			jsonValue = parseJSON (_httpHandle.data);

		}
		
		catch (Exception exception) {

			auto file = File("request.json", "w");

			file.write (_httpHandle.data);

			throw new DiffBotException ("The JSON parser was unable to parse the contents of the request. A log file with the server response was written into the file request.json with the offending data");

		}

		return jsonValue;

	}

}