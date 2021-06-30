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
	
	mutating func findContentsBeforeClosingTag() throws -> String {
		
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
}

/// Check the given line for properly openend/closed HTML tags:
func checkLine(line: String) throws {
	var iterator = line.enumerated().makeIterator()

	var stack = [Tag]()

	// Iterate over each character in the line:
	while let (position, char) = iterator.next() {

		if char == "<" {

			// Check if we're currently closing a tag by looking ahead by 1 for a "/":
			var findSlashIterator = iterator
			if let (_, slash) = findSlashIterator.next(), slash == "/" {
				let tagContents = try findSlashIterator.findContentsBeforeClosingTag()

				guard !stack.isEmpty
				else { throw ParseError(line: line, position: position, message: "Closing a tag \"\(tagContents)\" which doesn't have any opening tag.") }

				let currentTag = stack.removeLast()

				guard currentTag.name == tagContents
				else { throw ParseError(line: line, position: position, message: "Closing a tag \"\(tagContents)\" which doesn't match last opened tag \"\(currentTag.name)\"") }
			}
			// We must be opening a tag, look forwards for the tag name:
			else {
				var findClosingIterator = iterator
				let tagContents = try findClosingIterator.findContentsBeforeClosingTag()

				// Is the tag empty? 
				guard !tagContents.isEmpty else {
					throw ParseError(line: line, position: position, message: "Found an empty tag")
				}

				// Is the tag a <br> or <br /> or <br/>?
				guard tagContents != "br /" && tagContents != "br" && tagContents != "br/" else {
					// <br /> is special cased - it stands alone.
					continue
				}

				// Append this tag to the Stack
				stack += [Tag(name: tagContents)]
			}
		}
	}

	// The tag stack should be empty once we've finished processing this line.
	guard stack.isEmpty else {
		throw ParseError(line: line, position: line.count, message: "There are unclosed tags: \(stack.map { $0.name })")
	}
}

// The script takes a list of paths as an argument:
let paths = CommandLine.arguments.dropFirst()

// For each path, open the file and iterate over each line:
paths.forEach { path in
	
	guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
		fatalError("Could not open path: \(path)")
	}
	
	contents.enumerateLines { line, _ in
		do {
			try checkLine(line: line)
		} catch let error as String {
			print("error: ", error)
			exit(1)
			
		} catch let error as ParseError {
			print("error: \(error.message) at position '\(error.position)' on line \(error.line)")
			exit(1)
		} catch {
			fatalError("unhandled error")
		}
	}
}
