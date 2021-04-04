package de.grammarcraft.epsilon.validation

import de.grammarcraft.epsilon.epsilon.Specification
import java.io.BufferedReader
import java.io.File
import java.io.InputStream
import java.io.InputStreamReader
import java.util.ArrayList
import java.util.List
import java.util.concurrent.Executors
import java.util.regex.Matcher
import java.util.regex.Pattern
import org.apache.log4j.Logger
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.xtend.lib.annotations.Accessors

package class EpsilonExecutor {
	
	static val logger = Logger.getLogger(EpsilonValidator.name);
	
	package static val EPSILON_EXE_SYSPROP_NAME = 'de.grammarcraft.epsilon.executable'
	package static val EPSILON_EXE_ENVVAR_NAME = 'EPSILON_EXE'
	static val EPSILON_EXE_DEFAULT = './epsilon'
	
	package static val EPSILON_TARGET_DIR_SYSPROP_NAME = 'de.grammarcraft.epsilon.target.dir'
	package static val EPSILON_TARGET_DIR_ENVVAR_NAME = 'EPSILON_TARGET_DIR'
	static val EPSILON_TARGET_DIR_DEFAULT = './'
	
	static val SKIP_EXECUTION_SYSPROP_NAME = 'de.grammarcraft.epsilon.skipExecution'
	
	static val TAG_ERROR = 'error:'
	static val TAG_WARN  = 'warn:'
	static val TAG_INFO  = 'info:'

	static val File epsilonExecutableFile = determineEpsilonExecutable();
	static val File epsilonTargetDir = determineEpsilonTargetDir();		
	
	@Accessors protected static class EpsilonIssue {
		@Accessors(PACKAGE_GETTER) val int severity
		@Accessors(PACKAGE_GETTER) val String message
		@Accessors(PACKAGE_GETTER, PRIVATE_SETTER) String file = ""
		@Accessors(PACKAGE_GETTER, PRIVATE_SETTER) String line = ""
		@Accessors(PACKAGE_GETTER, PRIVATE_SETTER) String column = ""
		
	}
	
	package static def List<EpsilonIssue> executeOn(Specification specification) {
		val empytIssueList = new ArrayList<EpsilonIssue>
		
		if (skipEpsilonExecution()) {
			return empytIssueList			
		}
		
		if (!epsilonExecutableFile.exists()) {
			logger.warn(String.format("no Epsilon executable found at '%s' - consider setting environment variable %s properly",
					epsilonExecutableFile.getAbsolutePath(), EPSILON_EXE_ENVVAR_NAME));
			return empytIssueList
		}
		
		val epsilonExecutableHomeDir = epsilonExecutableFile.parentFile
		checkEpsilonHomeDirConstraints(epsilonExecutableHomeDir)
		
		val eagSrcFile = determineEagSourceFileFrom(specification);
		if (!eagSrcFile.exists()) {
			logger.warn(String.format("Epsilon source file '%s' to be processed does not exist", eagSrcFile.getAbsolutePath()));
			return empytIssueList
		}
		
		val builder = new ProcessBuilder();
		builder.command(epsilonExecutableFile.getAbsolutePath(), '--output-directory', epsilonTargetDir.absolutePath, eagSrcFile.getAbsolutePath());
		builder.directory(epsilonExecutableHomeDir);
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
	
	package def static skipEpsilonExecution() {
		if (System.getProperty(SKIP_EXECUTION_SYSPROP_NAME) !== null) {	
			logger.info("Epsilon execution is skipped due to setting of system property " + SKIP_EXECUTION_SYSPROP_NAME);		
			return Boolean.parseBoolean(System.getProperty(SKIP_EXECUTION_SYSPROP_NAME))
		}
		return false
	}
	
	private def static checkEpsilonHomeDirConstraints(File epsilonHomeDir) {
		val fixSubDir = new File(epsilonHomeDir, "fix")
		if (!fixSubDir.exists || fixSubDir.isFile)
			logger.warn(String.format("There is not 'fix' sub directory in Eclipse executable home directory '%s' - compiler generation may fail.", 
				epsilonHomeDir.absolutePath
			))
	}
	
	package def static createIssueListFrom(List<String> stderrLines) {
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
	
	/**
	 * Example line: <br>
	 * expr-bnf.eag:4:26     Term &lt;Code1&gt; ExprTail&lt;Code1&gt;.
	 */
	static val EPSILON_ISSUE_POSITION_LINE_PATTERN = Pattern.compile("(?<file>[^:]*):(?<line>\\d+):(?<column>\\d+).*")
	
	private static def int asSeverity(String tag) {
		switch (tag) {
			case TAG_ERROR: return Diagnostic.ERROR
			case TAG_WARN: return Diagnostic.WARNING
			case TAG_INFO: return Diagnostic.OK
			default: return Diagnostic.OK
		}
	}
	
	private static def boolean isWithTagPrefix(String line) {
		line.startsWith(TAG_ERROR) || line.startsWith(TAG_WARN) || line.startsWith(TAG_INFO)
	}
	
	private static def File determineEagSourceFileFrom(Specification specification) {
		val relativeSrcFileUri = specification.eResource().getURI();
		
		var srcFile = "not-determined";
		try {
			if (relativeSrcFileUri.isPlatform()) {
				srcFile = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(relativeSrcFileUri.toPlatformString(true))).getRawLocation().toOSString();	
			}            	
			else {
				srcFile = specification.eResource().getResourceSet().getURIConverter().normalize(relativeSrcFileUri).toFileString();
			}			
		}
		catch (RuntimeException re) {
			logger.error("underlying EGA grammar specification file could not be determined from EMF object: " + re.message, re)
		}
		return new File(srcFile);
	}

	package def static File determineEpsilonExecutable() {
		var epsilonExecutable = EPSILON_EXE_DEFAULT
		if (System.getProperty(EPSILON_EXE_SYSPROP_NAME) !== null) {
			
			epsilonExecutable = System.getProperty(EPSILON_EXE_SYSPROP_NAME)
			logger.info(String.format("system property %s defined, take Epsilon executable from it", EPSILON_EXE_SYSPROP_NAME))
		}
		else if (System.getenv(EPSILON_EXE_ENVVAR_NAME) !== null) {
			epsilonExecutable = System.getenv(EPSILON_EXE_ENVVAR_NAME)
			logger.info(String.format("environment variable %s defined, take Epsilon executable from it", EPSILON_EXE_ENVVAR_NAME))
		}
		else {
			logger.info(String.format("Neither system property '%s' nor environment variable '%s' are defined, use the default path '%s' as Epsilon executable", 
				EPSILON_EXE_SYSPROP_NAME, EPSILON_EXE_ENVVAR_NAME, epsilonExecutable
			));
		}
			
		logger.info("The following Epsilon executable will be used for generation and validation: " + epsilonExecutable)
		return new File(epsilonExecutable);
	}

	package static def File determineEpsilonTargetDir() {
		var epsilonTargetDir = EPSILON_TARGET_DIR_DEFAULT
		if (System.getProperty(EPSILON_TARGET_DIR_SYSPROP_NAME) !== null) {
			
			epsilonTargetDir = System.getProperty(EPSILON_TARGET_DIR_SYSPROP_NAME)
			logger.info(String.format("system property %s defined, use it as Epsilon generation target directory", EPSILON_TARGET_DIR_SYSPROP_NAME))
		}
		else if (System.getenv(EPSILON_TARGET_DIR_ENVVAR_NAME) !== null) {
			epsilonTargetDir = System.getenv(EPSILON_TARGET_DIR_ENVVAR_NAME)
			logger.info(String.format("environment variable %s defined, use it as Epsilon generation target directory", EPSILON_TARGET_DIR_ENVVAR_NAME))
		}
		else {
			logger.info(String.format(
				"Neither system property '%s' nor environment variable '%s' are defined, use the default path '%s' as Epsilon generation target directory", 
				EPSILON_TARGET_DIR_SYSPROP_NAME, EPSILON_TARGET_DIR_ENVVAR_NAME, epsilonTargetDir
			));
		}
		
		var result = new File(epsilonTargetDir);
		
		if (!result.exists()) {
			logger.warn(String.format("Epsilon generation target directory '%s' does not exist - hopefully the Epsilon executable will create it",
					result.absolutePath))
		}
		else if (!result.isDirectory) {
			logger.error(String.format("Epsilon generation target directory '%s' is not a directory - going to use the current working directory instead",
					result.absolutePath))
			result = new File('./')
		}
		
			
		logger.info("The following Epsilon generation target directory will be used: " + result.absolutePath)
		return result
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