D library for the Diffbot API

This is a D client library for the Diffbot API (http://www.diffbot.com/products/automatic/).

1. Structure of Directories and Files
-------------------------------------

	Makefile - The Makefile used to build the example
	Readme.1st - This file

	docs/ - Classes documentation

	src/ - The source files

	src/model/response/article.d - data model for article responses 
	src/model/exception.d - exceptions are defined here

	src/controller/diffbot.d - main class
	src/controller/httphandle.d - Handle HTTP requests through the usage of the D's builtin std.net.curl

	src/example.d - Example of how to use the Diffbot's API client library

2. Usage
--------

	2.1 Class instantiation
	-----------------------

		You can get a new instance of a DiffBot class by calling:

			auto diffbot = new DiffBot(token,url);

		Or you can just call the standard constructor with no parameters at all and set the class properties:

			auto diffbot = new DiffBot;

			diffbot.token = "0123456789ABCDEF";
			diffbot.url = "http://www.nytimes.com";


	2.2 Additional Parameters
	-------------------------

		You may also set additional options like the request response filters and additional options:

			diffbot.method = DIFFBOT.METHOD.FRONTPAGE;
			
			diffbot.responseFields = "images(*)";

		Add additional response fields:

			diffbot.responseFields ~= "meta";

		Set optional arguments:

			diffbot.optionalArguments["timeout"] = 5;

		After you set these additional parameters, always remember to call the makeURL method to build the URL that will be sent to diffbot:

		diffbot.makeURL();


	2.3 Server Response
	-------------------

		Now you should call the sendRequestToServer method to fetch the response from DiffBot servers:

			auto response = diffbot.sendRequestToServer();

		If all went well you will end with a JSON response from the server as JSONValue (std.json) data structure.


	2.4 Extract data from Response
	------------------------------

		You can check if the response contains a key with the following example:

			string title;

			if ("title" in response.object) title = response.object["title"].str;

		If you have an array of images, do this:

			JSONValue images[];

			if ("images" in response.object) images = response.object["images"].array;

		Then loop through the array and extract the contents just like the title example

		In future versions it will be added a model for each API method, this will make things pretty much easier :)

		Finally read the example.d file to see a working example.


3. Build
---------

	Use the Makefile included within the project.

	To build the example, just type:

	make 

	and the example will be built

		3.1 Makefile options
		--------------------

		diffbot - builds the diffbot example
		documentation - builds the diffbot documentation at the docs directory (work in progress)
		unittests - builds the executable with unittests (work in progress)
		coverage - builds the executable with code coverage metrics

		clean - cleans all the executables,object files and documentation

		Note: you must have libcurl already installed on your system to be able to build with Diffbot library


4. Dependencies
---------------

	libcurl - avaiable at http://curl.haxx.se/libcurl/

	See the installation proccess according to your platform.


Diffbot D client library was happily written by Daniel Vieira <daniel@fablefactory.com.br>

The author accepts donations to support his work on this and many other projects. 
If you want to support, please contact him.
