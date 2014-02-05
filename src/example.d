/**

Simple example to demonstrate the DiffBot API Library for D

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

import std.getopt;
import std.net.curl;
import std.stdio;
import std.string;
import std.datetime;
import std.json;
import std.variant;

import controller.diffbot;

// Command line parameters

/// The address we want that Diffbot parses
string url;

/// Developer token
string token;

/// Filter the response from Diffbot using
string responseFields[];

string[string] optionalArguments;

/// Diffbot API method
DiffBot.METHOD method;

DiffBot diffbot;

void main(string[] arguments) {

	getopt (

		arguments,

		"token",&token,
		"url",&url,
		"method",&method,
		"responseFields",&responseFields,
		"optionalArguments",&optionalArguments

		);

    if (isInputFromCommandLineValid) {

    	// You must pass token and url parameters

	   setupDiffBotParameters();
    	showDiffBotTitle();
    	showRequestURL();

    	diffbot.httpHandle.addDelegates();
    	addShowProgressDelegate(diffbot.httpHandle.http);

    	JSONValue json = diffbot.sendRequestToServer();

    	writeln();
    	writeln();

    	switch (diffbot.method) with (DiffBot.METHOD) {

    		case ARTICLE:

    			showArticleResponse(json);

    		break;

    		default:

    			showResponse(json);

    	}

    	writeln();

    }

    else showUsage();
    
}

/**

	Shows the url that will be sent to Diffbot 

*/

void showRequestURL() {

	writeln();
    writeln("URL: ",diffbot.url.request);
    writeln();

}

void setupDiffBotParameters() {

	diffbot = new DiffBot(token,url);

    //diffbot.token = token;
    //diffbot.url.target = url;

    // These are optional parameters. If you don't inform method it will default to article
    diffbot.method = method;
    
    diffbot.responseFields = responseFields;
    diffbot.optionalArguments = optionalArguments;

    // Always remember to call this method after setting diffbot properties
    diffbot.makeURL();

}

bool isInputFromCommandLineValid() {

	return (url.length > 0) && (token.length > 0);

}

void showContentsHeader() {

	writeln("Showing data contents by sections after DiffBot analysis");
	writeln("--------------------------------------------------------");
	writeln();

}

/**

	Just outputs the reponse in JSON format

	You my parse the contents of the response to suit your own needs 

*/
void showResponse(JSONValue json) {

	writeln("Sections: ",json.object.keys);
	writeln();

	writeln(jsonValueToVariant(json));

}

/**

	Example of parsing the JSON contents from DiffBot's Article request

*/

void showArticleResponse(JSONValue json) {

	showContentsHeader();

	writeln("Sections: ",json.object.keys);
	writeln();

	string title,text,type,icon,date,url;
	
	JSONValue images[];

	if ("title" in json.object) title = json.object["title"].str;
	if ("text" in json.object) text = json.object["text"].str;
	if ("type" in json.object) type = json.object["type"].str;								

	if ("images" in json.object) images = json.object["images"].array;

	if ("icon" in json.object) icon = json.object["icon"].str;
	if ("date" in json.object) date = json.object["date"].str;
	if ("url" in json.object) url = json.object["url"].str;
	
	writeln("\tURL: ",url);
	writeln("\tTitle: ",title);

	writeln();

	writeln("\tDate: ",date);
	writeln("\tType: ",type);
	writeln("\tIcon: ",icon);
	writeln("\tText: ",text);
	
	writeln();
	writeln("\tImages:");
	writeln();

	foreach (image;images) {

		write("\t\t");
		
		writeln("Link: ",image.object["url"].str);

	}

}

/**

	Show Diffbot title and webpage

*/
void showDiffBotTitle() {

	writeln();

	writeln("Diffbot: Identify and Extract from Any Web page");
	writeln("http://www.diffbot.com");

}

void showUsage() {

	showDiffBotTitle();

	writeln ( q{
command line parameters:

diffbot --token=<token sent to you by DiffBot> 
		--url=<url to be parsed> 
		--method<API method to invoke> (defaults to Article)

Where --method can be one of the following options:

analyze
article
frontpage
image
product

Example of usage:

diffbot --token=12345678910 --url=http://www.google.com --method=article
});

}

void addShowProgressDelegate(HTTP http) {

	http.onProgress = delegate int(size_t bytesToDownload, size_t downloadedBytes,
								   size_t bytesToUpload, size_t uploadedBytes) {

		if (downloadedBytes == 0) {

			writef("\rWaiting response from Diffbot server. Please, wait ...");

		}

		else {

			writef("\rWaiting response from Diffbot server. Please, wait ... OK, got %d bytes.",downloadedBytes);

		}
	
		return 0;
	
	};

}

/**

	Converts from JSONValue to Variant

	Parameters: JSONValue JSONValue 
	Returns: Variant

*/

Variant jsonValueToVariant(JSONValue jsonValue) {

	Variant variant;

	final switch(jsonValue.type) {
	
		case JSON_TYPE.STRING:

			variant = jsonValue.str;
		
		break;
	
		case JSON_TYPE.INTEGER:
		
			variant = jsonValue.integer;
		
		break;

		case JSON_TYPE.UINTEGER:
		
			variant = jsonValue.uinteger;
		
		break;
	
		case JSON_TYPE.FLOAT:
		
			variant = jsonValue.floating;
		
		break;
	
		case JSON_TYPE.OBJECT:
		
			Variant[string] object;
		
			foreach(key, value; jsonValue.object) {
		
				object[key] = jsonValueToVariant(value);
		
			}

			variant = object;
		
		break;
	
		case JSON_TYPE.ARRAY:
		
			Variant[] array;
		
			foreach(index; jsonValue.array) {
		
				array ~= jsonValueToVariant(index);
		
			}

			variant = array;
		
		break;
	
		case JSON_TYPE.TRUE:
		
			variant = true;
		
		break;
	
		case JSON_TYPE.FALSE:
		
			variant = false;
		
		break;
	
		case JSON_TYPE.NULL:
		
			variant = null;
		
		break;

	}

	return variant;

}
