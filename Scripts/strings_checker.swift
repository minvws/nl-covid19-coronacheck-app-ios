// A new build phase which will check every line of the Localization.strings
// file and if it finds tags it will validate that they are structured correctly,
// for some basic checking of the HTML tags

import AppKit

struct Tag {
	let name: String
}

extension String: Error {}

struct ParseError: Error {
	let line: String
	let position: Int
	let message: String
}

extension EnumeratedSequence.Iterator where Base == String {
	
	mutating func findContentsBeforeSpaceOrClosingTag() throws -> String {
		
		var found = ""
		
		while let (_, char) = next() {
			
			if char == ">" || char == " " { // the space allows for tags with attributes e.g. <a href=""></a>
				return found
			} else {
				found += [char]
			}
		}
		
		throw "never found the closing tag"
	}

	mutating func findContentsBeforeClosingTag() throws -> String {
		
		var found = ""
		
		while let (_, char) = next() {
			
			if char == ">" {
				return found
			} else {
				found += [char]
			}
		}
		
		throw "never found the closing tag"
	}
}

/// Check the given line for properly openend/closed HTML tags:
func checkLine(line: String) throws {
	var iterator = line.enumerated().makeIterator()

	var stack = [Tag]()
	var hasProcessedAHyperlink = false
	
	// Iterate over each character in the line:
	while let (position, char) = iterator.next() {
		if char == "\\" {
			var findNewlineIterator = iterator
			if let (_, newlineN) = findNewlineIterator.next(), newlineN == "n" {
				// Newline detected, reset `hasProcessedAHyperlink`
				hasProcessedAHyperlink = false
			}
		} else if char == "<" {

			// Check if we're currently closing a tag by looking ahead by 1 for a "/":
			var findSlashIterator = iterator
			if let (_, slash) = findSlashIterator.next(), slash == "/" {
				let tagContents = try findSlashIterator.findContentsBeforeSpaceOrClosingTag()

				guard !stack.isEmpty
				else { throw ParseError(line: line, position: position, message: "Closing a tag \"\(tagContents)\" which doesn't have any opening tag.") }

				let currentTag = stack.removeLast()

				guard currentTag.name == tagContents
				else { throw ParseError(line: line, position: position, message: "Closing a tag \"\(tagContents)\" which doesn't match last opened tag \"\(currentTag.name)\"") }
			}
			// We must be opening a tag, look forwards for the tag name:
			else {
				var findClosingIterator = iterator
				let tagContents = try findClosingIterator.findContentsBeforeSpaceOrClosingTag()

				// Is the tag empty?
				guard !tagContents.isEmpty else {
					throw ParseError(line: line, position: position, message: "Found an empty tag")
				}

				if tagContents == "br" { // || tagContents == "br/"
					var findClosingWithoutSpaceIterator = iterator
					let tagContentsIgnoringSpace = try findClosingWithoutSpaceIterator.findContentsBeforeClosingTag()

					guard tagContentsIgnoringSpace == "br /" else {
						throw ParseError(line: line, position: position, message: "BR tags should only use format `<br />` (not <\(tagContents)>) otherwise it causes a crash")
					}
					continue
				}

				if tagContents == "a" {
					guard !hasProcessedAHyperlink else {
						throw "Due to limitations in the accessibility implementation (see TextView.swift), there can only be one hyperlink <a> tag per line. Use \\n to start a newline."
					}
					// we found a hyperlink
					hasProcessedAHyperlink = true
				}

				// Append this tag to the Stack
				stack += [Tag(name: tagContents)]
			}
		}
	}
	
	// If the line doesn't end in ";" or "*/" (for a comment) and isn't empty, then throw.
	if !(line.suffix(1) == ";" || line.suffix(2) == "*/") && !line.isEmpty {
		throw "Must be on one line -> '\(line)'"
	}
 
	// The tag stack should be empty once we've finished processing this line.
	guard stack.isEmpty else {
		throw ParseError(line: line, position: line.count, message: "There are unclosed tags: \(stack.map { $0.name })")
	}
}

// The script takes a list of paths as an argument:
let paths = CommandLine.arguments.dropFirst()

var didError = false

// For each path, open the file and iterate over each line:
paths.forEach { path in
	
	guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
		fatalError("Could not open path: \(path)")
	}
	
	contents.enumerateLines { line, _ in
		do {
			try checkLine(line: line)
		} catch let error as String {
			print("error: StringsChecker: ", error)
			didError = true
		} catch let error as ParseError {
			print("error: StringsChecker: \(error.message) at position '\(error.position)' on line \(error.line)")
			didError = true
		} catch {
			fatalError("unhandled error")
		}
	}
}

if didError {
	exit(1)
}