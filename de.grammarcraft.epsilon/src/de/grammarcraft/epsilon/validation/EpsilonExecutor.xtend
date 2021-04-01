package de.grammarcraft.epsilon.validation

import de.grammarcraft.epsilon.epsilon.Specification
import java.io.BufferedReader
import java.io.File
import java.io.InputStream
import java.io.InputStreamReader
import java.util.ArrayList
import java.util.List
import java.util.concurrent.Executors
import java.util.regex.Pattern
import org.apache.log4j.Logger
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.regex.Matcher

package class EpsilonExecutor {
	
	static val logger = Logger.getLogger(EpsilonValidator.name);
	
	static val EPSILON_EXE_SYSPROP_NAME = 'epsilon.executable'
	static val EPSILON_EXE_ENVVAR_NAME = 'EPSILON_EXE'
	static val EPSILON_EXE_DEFAULT = './epsilon'
	
	static val TAG_ERROR = 'error:'
	static val TAG_WARN  = 'warn:'
	static val TAG_INFO  = 'info:'
	
	
	@Accessors protected static class EpsilonIssue {
		@Accessors(PACKAGE_GETTER) val int severity
		@Accessors(PACKAGE_GETTER) val String message
		@Accessors(PACKAGE_GETTER, PRIVATE_SETTER) String file = ""
		@Accessors(PACKAGE_GETTER, PRIVATE_SETTER) String line = ""
		@Accessors(PACKAGE_GETTER, PRIVATE_SETTER) String column = ""
		
	}
	
	package static def List<EpsilonIssue> executeOn2(Specification specification) {
		val empytIssueList = new ArrayList<EpsilonIssue>
		
		val epsilonExecutableFile = determineEpsilonExecutable();
		if (!epsilonExecutableFile.exists()) {
			logger.warn(String.format("no Epsilon executable found at '%s' - consider setting environment variable %s properly",
					epsilonExecutableFile.getAbsolutePath(), EPSILON_EXE_ENVVAR_NAME));
			return empytIssueList
		}
		
		val eagSrcFile = determineEagSourceFileFrom(specification);
		if (!eagSrcFile.exists()) {
			logger.warn(String.format("Epsilon source file '%s' to be processed does not exist", eagSrcFile.getAbsolutePath()));
			return empytIssueList
		}
		
		val builder = new ProcessBuilder();
		builder.command(epsilonExecutableFile.getAbsolutePath(), eagSrcFile.getAbsolutePath());
		builder.directory(eagSrcFile.getParentFile());
		val process = builder.start();

		val outputConsumer = new OutputMessagesConsumer(process.inputStream, process.errorStream);
		Executors.newSingleThreadExecutor().submit(outputConsumer);
		val exitCode = process.waitFor();
		
		if (exitCode == 0) {
			logger.info(String.format("executing '%s' was successful and did not detect any error", String.join(" ", builder.command())));
			return empytIssueList	
		}
		
		logger.info(String.format("executing '%s' failed with error code %d", String.join(" ", builder.command()), exitCode));
		
		createIssueListFrom(outputConsumer.stderrLines)
	}
	
	def static createIssueListFrom(List<String> stderrLines) {
		val lines = new ArrayList<String>
		for (String line : stderrLines) {
			lines.add(line);
		}
		
		val issues = new ArrayList<EpsilonIssue>
		for (String line : lines) {
			if (line.withTagPrefix)
				issues.add(createIssueFrom(line))
			else {
				val issuePosLineMatcher = EPSILON_ISSUE_POSITION_LINE_PATTERN.matcher(line) 
				val last = issues.size()-1
				if (issuePosLineMatcher.matches() && last >= 0)
					issues.get(last).addPositionInfoFrom(issuePosLineMatcher) 
				// else: skip lines with the ^ marker
			}
		}
		return issues
	}
	
	def static void addPositionInfoFrom(EpsilonIssue lastCreatedIssue, Matcher issuePosLineMatcher) {
		lastCreatedIssue => [
			file = issuePosLineMatcher.group('file')
			line = issuePosLineMatcher.group('line')
			column = issuePosLineMatcher.group('column')
		]
	}
		
	
	
	package static val NO_ISSUE = new EpsilonIssue(Diagnostic.OK, "no issue")
	/**
	 * Example line: <br>
	 * error: number of affixforms differs from signature
	 */
	static val EPSILON_ISSUE_LINE_PATTERN = Pattern.compile("(?<tag>(error:)|(warn:)|(info:))\\s*(?<msg>.*)")
	
	package static def EpsilonIssue createIssueFrom(String issueLine) {
		val issueLineMatcher = EPSILON_ISSUE_LINE_PATTERN.matcher(issueLine)
		if (issueLineMatcher.matches()) {
			val tag = issueLineMatcher.group('tag')
			val msg = issueLineMatcher.group('msg').trim
			
			new EpsilonIssue(tag.asSeverity, msg)
		}
		else
			NO_ISSUE
	}
	
	@Data protected static class IssueLocation {
		int serverity
		int line
		int column
		String message
	}
	
	/**
	 * Example line: <br>
	 * expr-bnf.eag:4:26     Term &lt;Code1&gt; ExprTail&lt;Code1&gt;.
	 */
	static val EPSILON_ISSUE_POSITION_LINE_PATTERN = Pattern.compile("(?<file>[^:]*):(?<line>\\d+):(?<column>\\d+).*")

	package static def boolean isWithPositionInfo(String issuePositionLine) {
		EPSILON_ISSUE_POSITION_LINE_PATTERN.matcher(issuePositionLine).matches()
	}	
	
	package static def List<IssueLocation> executeOn(Specification specification) {
		val empytIssueList = new ArrayList<IssueLocation>
		
		val epsilonExecutableFile = determineEpsilonExecutable();
		if (!epsilonExecutableFile.exists()) {
			logger.warn(String.format("no Epsilon executable found at '%s' - consider setting environment variable %s properly",
					epsilonExecutableFile.getAbsolutePath(), EPSILON_EXE_ENVVAR_NAME));
			return empytIssueList
		}
		
		val eagSrcFile = determineEagSourceFileFrom(specification);
		if (!eagSrcFile.exists()) {
			logger.warn(String.format("Epsilon source file '%s' to be processed does not exist", eagSrcFile.getAbsolutePath()));
			return empytIssueList
		}
		
		val builder = new ProcessBuilder();
		builder.command(epsilonExecutableFile.getAbsolutePath(), eagSrcFile.getAbsolutePath());
		builder.directory(eagSrcFile.getParentFile());
		val process = builder.start();

		val outputConsumer = new OutputMessagesConsumer(process.inputStream, process.errorStream);
		Executors.newSingleThreadExecutor().submit(outputConsumer);
		val exitCode = process.waitFor();
		
		if (exitCode == 0) {
			logger.info(String.format("executing '%s' was successful and did not detect any error", String.join(" ", builder.command())));
			return empytIssueList	
		}
		
		logger.info(String.format("executing '%s' failed with error code %d", String.join(" ", builder.command()), exitCode));
		
		val detectedIssue = createIssueListFrom(outputConsumer.stderrLines)
		val combinedMessages = combineIssueMessageAndPosition(outputConsumer.stderrLines)
		combinedMessages.map[createIssueLocation]
	}
	
	
	static val EPSILON_LINE_PATTERN = Pattern.compile("(?<tag>(error:)|(warn:)|(info:))\\s*(?<msg>[^@]*)(@(?<file>[^:]*):(?<line>\\d+):(?<column>\\d+).*)?")
	
	package static def IssueLocation createIssueLocation(String issueLine) {
		val issueLineMatcher = EPSILON_LINE_PATTERN.matcher(issueLine)
		if (issueLineMatcher.matches()) {
			val tag = issueLineMatcher.group('tag')
			val msg = issueLineMatcher.group('msg').trim
			val line = issueLineMatcher.group('line')
			val column = issueLineMatcher.group('column')
			
			val severity = tag.asSeverity
			
			if (line !== null && column !== null) {
				try {
					
					val lineNumber = Integer.parseUnsignedInt(line)
					val columnNumber = Integer.parseUnsignedInt(column)
					return new IssueLocation(severity, lineNumber, columnNumber, msg)	
				}
				catch (NumberFormatException nfe) {
					return new IssueLocation(severity, 1, 1, msg)
				}				
			}
			else
				return new IssueLocation(severity, 1, 1, msg)
				
		}
	}
	
	private static def int asSeverity(String tag) {
		switch (tag) {
			case TAG_ERROR: return Diagnostic.ERROR
			case TAG_WARN: return Diagnostic.WARNING
			case TAG_INFO: return Diagnostic.OK
			default: return Diagnostic.OK
		}
	}
	
	/**
	 * The Epsilon compiler generator reports errors and warning in 2 lines,
	 * First line contains the issue type "error:" or "warn:" followed by an explanation.
	 * And, on the second optional line contains the issue position 
	 * followed by third line containing a '^' marker
	 * First 2 lines are combined such that each message in the result represents exactly one issue.
	 * Third line is skipped at all.
	 * @param stderrLines
	 * @return combined 
	 */
	package static def List<String> combineIssueMessageAndPosition(List<String> stderrLines) {
		val lines = new ArrayList<String>
		for (String line : stderrLines) {
			lines.add(line);
		}
		val issues = new ArrayList<String>
		for (String line : stderrLines) {
			if (line.withTagPrefix)
				issues.add(line)
			else if (line.notWithMarker) { // skip lines with the ^ marker
				val last = issues.size()-1
				if (last >= 0)
					issues.set(last, issues.get(last) + "@" + line) // add the current line to the last issue separated by @
			}
		}
		return issues
	}
	
	private static def boolean isWithTagPrefix(String line) {
		line.startsWith(TAG_ERROR) || line.startsWith(TAG_WARN) || line.startsWith(TAG_INFO)
	}
	
	private static def boolean isNotWithMarker(String line) {
		!line.trim.endsWith('^')	
	}
	
	
	private static def File determineEagSourceFileFrom(Specification specification) {
		val relativeSrcFileUri = specification.eResource().getURI();
		
		var srcFile = "not-determined";
		if (relativeSrcFileUri.isPlatform()) {
			srcFile = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(relativeSrcFileUri.toPlatformString(true))).getRawLocation().toOSString();	
		}            	
		else {
			srcFile = specification.eResource().getResourceSet().getURIConverter().normalize(relativeSrcFileUri).toFileString();
		}
		return new File(srcFile);
	}

	private def static File determineEpsilonExecutable() {
		var epsilonExecutable = EPSILON_EXE_DEFAULT
		if (System.getProperty('epsilon.executable') !== null) {
			
			epsilonExecutable = System.getProperty(EPSILON_EXE_SYSPROP_NAME)
			logger.info(String.format("system property %s exists, take Epsilon executable from it", EPSILON_EXE_SYSPROP_NAME))
		}
		else if (System.getenv(EpsilonExecutor.EPSILON_EXE_ENVVAR_NAME) !== null) {
			epsilonExecutable = System.getenv(EpsilonExecutor.EPSILON_EXE_ENVVAR_NAME)
			logger.info(String.format("environment variable %s exists, take Epsilon executable from it", EPSILON_EXE_ENVVAR_NAME))
		}
		else {
			logger.info(String.format("Neither system property '%s' nor environment variable '%s' are defined, use the default path '%s' as Epsilon executable", 
				EPSILON_EXE_SYSPROP_NAME, EPSILON_EXE_ENVVAR_NAME, epsilonExecutable
			));
		}
			
		logger.info("Epsilon plugin will use the following Epsilon executable: " + epsilonExecutable)
		return new File(epsilonExecutable);
	}
	
	
	
	private static class OutputMessagesConsumer implements Runnable {
	    val InputStream inputStream
		val InputStream errorStream
		val List<String> stdoutLines = newArrayList
		val List<String> stderrLines = newArrayList

	    new(InputStream inputStream, InputStream errorStream) {
	        this.inputStream = inputStream;
	        this.errorStream = errorStream;
	    }
	    
	    override run() {
	        new BufferedReader(new InputStreamReader(inputStream))
	        	.lines()
	        	.forEach([ line | stdoutLines.add(line) ])
	        new BufferedReader(new InputStreamReader(errorStream))
	        	.lines()
	        	.forEach([ line | stderrLines.add(line) ])
	    }
	    
	}
	
	
}