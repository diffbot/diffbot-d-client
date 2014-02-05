module controller.exception;

import std.exception;

class DiffBotException : Exception {

	this (string message) {

		super (message);

	}

}