//: Playground - noun: a place where people can play

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
			
			if char == ">" || char == " " { // space allows for <a href>
				return found
			} else {
				found += [char]
			}
		}
		
		throw "never found the closing tag"
	}
}

func checkLine(line: String) throws {
	var iterator = line.enumerated().makeIterator()

	var stack = [Tag]()

	while let (position, char) = iterator.next() {

		if char == "<" {

			// Check if we're closing a tag by looking ahead by 1:
			var findSlashIterator = iterator
			if let (_, slash) = findSlashIterator.next(), slash == "/" {
				let tagContents = try findSlashIterator.findContentsBeforeClosingTag()

				guard !stack.isEmpty
				else { throw ParseError(line: line, position: position, message: "Closing a tag \"\(tagContents)\" which doesn't have any opening tag.") }

				let currentTag = stack.removeLast()

				guard currentTag.name == tagContents
				else { throw ParseError(line: line, position: position, message: "Closing a tag \"\(tagContents)\" which doesn't match last opened tag \"\(currentTag.name)\"") }
			}
			// We're opening a tag, look forwards for the tag contents:
			else {
				var findClosingIterator = iterator
				let tagContents = try findClosingIterator.findContentsBeforeClosingTag()

				guard !tagContents.isEmpty else {
					throw ParseError(line: line, position: position, message: "Found an empty tag")
				}

				guard tagContents != "br /" && tagContents != "br" && tagContents != "br/" else {
					// <br /> is special cased - it stands alone.
					continue
				}

				stack += [Tag(name: tagContents)]
			}
		}
	}

	guard stack.isEmpty else {
		throw ParseError(line: line, position: line.count, message: "There are unclosed tags: \(stack.map { $0.name })")
	}
}

let paths = CommandLine.arguments.dropFirst()

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
