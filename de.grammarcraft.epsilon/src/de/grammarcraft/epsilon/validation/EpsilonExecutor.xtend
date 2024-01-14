package de.grammarcraft.epsilon.validation

import com.google.inject.Inject
import de.grammarcraft.epsilon.epsilon.Specification
import de.grammarcraft.epsilon.preferences.IEpsilonPreferencesProvider
import java.io.BufferedReader
import java.io.File
import java.io.InputStream
import java.io.InputStreamReader
import java.util.ArrayList
import java.util.List
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.regex.Matcher
import java.util.regex.Pattern
import org.apache.log4j.Logger
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.xtend.lib.annotations.Accessors
import org.apache.log4j.Level

package class EpsilonExecutor {
	
	static val logger = Logger.getLogger(EpsilonExecutor.name);
	
	package static val SYSPROP_NAME_EPSILON_TARGET_DIR = 'de.grammarcraft.epsilon.target.dir'
	package static val SYSPROP_NAME_EPSILON_EXE = 'de.grammarcraft.epsilon.executable'
	package static val SYSPROP_NAME_ADDITIONAL_EXE_ARGUMENTS = 'de.grammarcraft.epsilon.additionalExeOptions'
	
	static val SYSPROP_USE_EXTERNAL_GENERATOR = 'de.grammarcraft.epsilon.useExternalExecutable'
	static val SYSPROP_NAME_SKIP_EXECUTION = 'de.grammarcraft.epsilon.skipExecution'
	static val SYSPROP_NAME_CODE_GENERATION_ONLY = 'de.grammarcraft.epsilon.codeGenerationOnly'
	static val SYSPROP_NAME_EVALUTATOR_TYPE = 'de.grammarcraft.epsilon.evaluatorGeneratorType'
	static val SYSPROP_NAME_LOG_LEVEL = 'de.grammarcraft.epsilon.logLevel'  
	
	static val EPSILONCG_FINISHING_TIMEOUT_MS = 2000
	
	static val TAG_ERROR = 'error:'
	static val TAG_WARN  = 'warn:'
	static val TAG_INFO  = 'info:'
	
	File epsilonExecutableFile
	boolean useExternalExecutable
	File epsilonTargetDir
	boolean createTargetDirIfNotExists
	boolean codeGenerationOnly
	List<String> additionalExecutionArgument
	String evaluatorType
	IProject project

	@Inject IEpsilonPreferencesProvider preferenceProvider
	
	@Accessors protected static class EpsilonIssue {
		@Accessors(PACKAGE_GETTER) val int severity
		@Accessors(PACKAGE_GETTER) val String message
		@Accessors(PACKAGE_GETTER, PRIVATE_SETTER) String file = ""
		@Accessors(PACKAGE_GETTER, PRIVATE_SETTER) String offset = ""
		
	}
	
	package def List<EpsilonIssue> executeOn(Specification specification) {
	    
	    setLogLevelFromSystemProperty()
        		
		if (skipEpsilonExecution()) {
			return emptyList			
		}
		
		project = getIProject(specification)
		if (project === null) {
		    logger.warn("no project context for property read out found - going to use default preferences");
		}
		
		epsilonExecutableFile = determineEpsilonExecutable()
		useExternalExecutable = determineUseExternalExecutable()
		epsilonTargetDir = determineEpsilonTargetDir()
		createTargetDirIfNotExists = determineCreateTargetDirOption()
		codeGenerationOnly = determineCodeGenerationOnlyOption()
		additionalExecutionArgument = determineAdditionalExecutionArgument()
		evaluatorType = determineEvaluatorType()

		if (!useExternalExecutable) {
			ResourceExtractor.extractExecutableFromJarTo(epsilonExecutableFile.parentFile)
			ResourceExtractor.extractDLibSourcesFromJarTo(epsilonTargetDir)
		}
		else
			logger.warn("external compiler generator gets used, required Dlang sources needs to be provided manually")
				
		if (!epsilonExecutableFile.exists || !epsilonExecutableFile.isFile) {
			logger.warn(String.format("no compiler generator executable found at '%s'", epsilonExecutableFile.getAbsolutePath()));
			return emptyList
		}
				
		val eagSrcFile = determineEagSourceFileFrom(specification);
		if (!eagSrcFile.exists()) {
			logger.warn(String.format("Epsilon source file '%s' to be processed does not exist", eagSrcFile.getAbsolutePath()));
			return emptyList
		}
		
		val builder = new ProcessBuilder();
		builder.command(epsilonExecutableFile.getAbsolutePath(), '--offset', '--output-directory', epsilonTargetDir.absolutePath)
		if (!additionalExecutionArgument.empty)
		    additionalExecutionArgument.forEach[builder.command.add(it)]
		if (codeGenerationOnly) 
			builder.command.add('-g') // works only since gamma! But we do not differentiate both.
		builder.command.add('--' + evaluatorType)
		builder.command.add(eagSrcFile.getAbsolutePath());
		builder.directory(epsilonTargetDir);
		val finalCmdLine = builder.command.join(" ")
		logger.info("going to invoke the following Epsilon compiler generator cmd line: " + finalCmdLine);
		
		val process = builder.start();
		val outputConsumer = new OutputMessagesConsumer(process.inputStream, process.errorStream);
		Executors.newSingleThreadExecutor().submit(outputConsumer);
		val exitCode = process.waitFor();
		
		if (exitCode == 0)
			logger.info(String.format("executing '%s' was successful and did not detect any error", finalCmdLine))
		else    
    		logger.warn(String.format("executing '%s' failed with error code %d", finalCmdLine, exitCode))
		
        createIssueListFrom(outputConsumer.stdErrLines)
	}
    
    def setLogLevelFromSystemProperty() {
        if (System.getProperty(SYSPROP_NAME_LOG_LEVEL) !== null) {
            val logLevel = System.getProperty(SYSPROP_NAME_LOG_LEVEL)
            switch (logLevel) {
            	case "ALL": logger.level = Level.ALL
            	case "TRACE": logger.level = Level.TRACE
                case "DEBUG": logger.level = Level.DEBUG
                case "INFO": logger.level = Level.INFO
                case "WARN": logger.level = Level.WARN
                case "ERROR": logger.level = Level.ERROR
                case "FATAL": logger.level = Level.FATAL
            }
        }            
    }
    
    def static getIProject(Specification specification) {
        try {
            val path = specification.eResource.URI.toPlatformString(true)
            val file = ResourcesPlugin.workspace?.root?.findMember(path) as IFile
            file?.project
        }
        catch (IllegalStateException ise) {
            logger.warn("no project specific preferences will be loaded as project could not be determined from workspace: " + ise.message);
            return null
        }
    }
	
	package def static skipEpsilonExecution() {
		if (System.getProperty(SYSPROP_NAME_SKIP_EXECUTION) !== null) {
		    val skipped = Boolean.parseBoolean(System.getProperty(SYSPROP_NAME_SKIP_EXECUTION))
		    if (skipped)
			    logger.info("Compiler generator execution is skipped due to setting of system property " + SYSPROP_NAME_SKIP_EXECUTION);		
			return skipped
		}
		return false
	}
			
	def determineCodeGenerationOnlyOption() {
		var result = false
		if (System.getProperty(SYSPROP_NAME_CODE_GENERATION_ONLY) !== null) {	
			result = Boolean.parseBoolean(System.getProperty(SYSPROP_NAME_CODE_GENERATION_ONLY))
			logger.info('''system property '«SYSPROP_NAME_CODE_GENERATION_ONLY»' is defined and set to '«Boolean.toString(result)»', using to to determine whether only code genertion is done, no compilation''');		
		}
		else {
		    result = preferenceProvider.projectPreferences(project).optionGenerationOnly
            logger.info(String.format("No system property '%s' is defined, going to use preference setting code generatioOnly=%b", 
                SYSPROP_NAME_CODE_GENERATION_ONLY, result
            ));
		}

		if (result)
			logger.info("Only source code is generated, not compiled")
		else
			logger.info("source code is generated and compiled using an preinstalled D compiler")
			
		return result
	}
	
	def determineAdditionalExecutionArgument() {
		var List<String> additionalArgs
		if (System.getProperty(de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_ADDITIONAL_EXE_ARGUMENTS) !== null) {
			additionalArgs = System.getProperty(de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_ADDITIONAL_EXE_ARGUMENTS).trim.split('\\s+').toList
			logger.debug(String.format("system property %s defined, take additional execution arguments from it", de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_ADDITIONAL_EXE_ARGUMENTS))
		}
		else {
		    additionalArgs = allConfiguredAdditionalOptions()
			logger.debug(String.format("No system property '%s' is defined, going to use preference settings", 
				de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_ADDITIONAL_EXE_ARGUMENTS
			));
		}
		
		if (!additionalArgs.empty)
			logger.info("The following additional execution arguments will be used: " + additionalArgs.join(' '))
		return additionalArgs
	}
	
	def determineEvaluatorType() {
        if (System.getProperty(de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EVALUTATOR_TYPE) !== null) {   
            logger.debug(String.format("system property '%s' defined, take evaluator generator from it", de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EVALUTATOR_TYPE));     
            return System.getProperty(de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EVALUTATOR_TYPE) 
        }
        else {
            val result = preferenceProvider.projectPreferences(project).evaluatorGeneratorType
            logger.info(String.format("No system property '%s' is defined, going to use preference set evaluator '%s'", 
                de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EVALUTATOR_TYPE, result
            ));
            return result
        }
	}
    
    def allConfiguredAdditionalOptions() {
        val List<String> result = newArrayList
        
        val preferences = if (project !== null) preferenceProvider.projectPreferences(project) else preferenceProvider.workspacePreferences
        
        // Gamma generator options
        //      -c               Disable collapsing constant trees
        //      -o               Disable optimizing of variable storage in compiled compiler
        //      -p               Parser ignores regular token marks at hyper-nonterminals
        //      -r               Disable reference counting in compiled compiler
        //      -s, --space      Compiled compiler uses space instead of newline as separator
        
        if (preferences.optionNoConstantTreesCollapsing)
            result.add("-c")
        
        if (preferences.optionNoOptimization)
            result.add("-o")
        
        if (preferences.optionNoReferenceCounting)
            result.add("-r")
        
        if (preferences.optionIgnoreTokenMarks)
            result.add("-p")
        
        if (preferences.optionSpaceInsteadNL)
            result.add("-s")
        
        val additionalOptions = preferences.additionalGeneratorOptions.trim
        if (!additionalOptions.empty)
            result.addAll(additionalOptions.split('\\s+'))        

        return result
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
				val issuePosLineMatcher = EPSILON_ISSUE_POSITION_PATTERN.matcher(line) 
				val last = issues.size()-1
				if (issuePosLineMatcher.matches() && last >= 0)
					issues.get(last).addPositionInfoFrom(issuePosLineMatcher) 
			}
		}
		return issues
	}
	
	def static void addPositionInfoFrom(EpsilonIssue lastCreatedIssue, Matcher issuePosLineMatcher) {
		lastCreatedIssue => [
			file = issuePosLineMatcher.group('file')
			offset = issuePosLineMatcher.group('offset')
		]
	}
		
	
	
	package static val NO_ISSUE = new EpsilonIssue(Diagnostic.OK, "no issue")
	/**
	 * Example line: <br>
	 * error: number of affix forms differs from signature
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
	 * expr-bnf.eag@72:4:26
	 * <br>
	 * Requires gamma with offset position reporting by cmd line argument --offset being set
	 */
	static val EPSILON_ISSUE_POSITION_PATTERN = Pattern.compile("(?<file>[^:@]*)@(?<offset>\\d+).*")
    
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

	package def File determineEpsilonExecutable() {
		var String epsilonExecutable
		if (System.getProperty(de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EPSILON_EXE) !== null) {
			
			epsilonExecutable = System.getProperty(de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EPSILON_EXE)
			logger.info(String.format("system property %s defined, take Epsilon executable path from it", de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EPSILON_EXE))
		}
		else if (project !== null) {
            epsilonExecutable = preferenceProvider.projectPreferences(project).generatorExecutablePath
            logger.info(String.format("project preferences defined, take Epsilon executable path from it"))		    
		}
		else {
		    epsilonExecutable = preferenceProvider.workspacePreferences.generatorExecutablePath
			logger.info(String.format("No system property '%s' nor project preference is defined, use the default path '%s' from workspace preferences as Epsilon executable", 
				de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EPSILON_EXE, epsilonExecutable
			));
		}
			
		val configuredEpsilonExecutable = new File(epsilonExecutable);
		var result = 
    		if (!configuredEpsilonExecutable.isAbsolute && project !== null) {
    		    // create exe path relative to Eclipse project
    		    project?.location.addTrailingSeparator.append(epsilonExecutable).toFile 
    		}
    		else {
    		    // alternatively, create exe path relative to current working dir
    		    configuredEpsilonExecutable
    		}
		logger.info("The following Epsilon executable will be used for generation and validation: " + epsilonExecutable)
		return result
	}
	
	def boolean determineUseExternalExecutable() {
		var result = false
		if (System.getProperty(SYSPROP_USE_EXTERNAL_GENERATOR) !== null) {	
			result = Boolean.parseBoolean(System.getProperty(SYSPROP_USE_EXTERNAL_GENERATOR))
			logger.info('''system property '«SYSPROP_USE_EXTERNAL_GENERATOR»' is defined and set to '«result.toString»', using it for determine whether an external compiler generator executable is used or the internal one''');		
		}
		else {
		    result = preferenceProvider.projectPreferences(project).useExternalCompilerGeneratorExe
            logger.info(String.format("No system property '%s' is defined, going to use preference setting set to %b", 
                SYSPROP_USE_EXTERNAL_GENERATOR, result
            ));
		}
		if (result)		
			logger.info("External compiler generator executable is used (not the embedded one)")
		else
			logger.info("Embedded compiler generator executable is used (not an external one)")
        return result
	}

    def determineCreateTargetDirOption() {
        if (project !== null) {
            return preferenceProvider.projectPreferences(project).optionCreateTargetDir
        }
        else {
            logger.info("No project preference is defined, use the default option from workspace preferences whether generation target directory should be created");
            return preferenceProvider.workspacePreferences.optionCreateTargetDir
        }
    }
    
	package def File determineEpsilonTargetDir() {
		var String epsilonTargetDir
		if (System.getProperty(de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EPSILON_TARGET_DIR) !== null) {
			
			epsilonTargetDir = System.getProperty(de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EPSILON_TARGET_DIR)
			logger.info(String.format("system property %s defined, use it as Epsilon generation target directory", de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EPSILON_TARGET_DIR))
		}
		else if (project !== null) {
		    epsilonTargetDir = preferenceProvider.projectPreferences(project).generatorTargetDir
            logger.info(String.format("project preference defined, use it as Epsilon generation target directory"))
		}
		else {
            epsilonTargetDir = preferenceProvider.workspacePreferences.generatorTargetDir
            logger.info(String.format(
				"No system property '%s' nor project preference is defined, use the default path '%s' from workspace preferences as Epsilon generation target directory", 
				de.grammarcraft.epsilon.validation.EpsilonExecutor.SYSPROP_NAME_EPSILON_TARGET_DIR, epsilonTargetDir
			));
		}
		
		val configuredTargetDir = new File(epsilonTargetDir)
		var result = 
    		if (!configuredTargetDir.isAbsolute && project !== null) {
    		    // create target dir relative to Eclipse project
    		    project?.location.addTrailingSeparator.append(epsilonTargetDir).toFile 
    		}
    		else {
    		    // alternatively, create target dir relative to current working dir
    		    configuredTargetDir
    		}
		
		if (!result.exists()) {
		    if (createTargetDirIfNotExists) {
		        logger.info(String.format("going to create generator target directory '%s' as defined by preferences", result.absolutePath))
		        if (!result.mkdirs)
		          logger.warn(String.format("failed to create generator target directory '%s' as defined by preferences", result.absolutePath))
		    }
		    else
			    logger.info(String.format("Epsilon generation target directory '%s' does not exist - it is no created as configured",
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
		val CountDownLatch consumptionReady 

	    new(InputStream inputStream, InputStream errorStream) {
	        this.inputStream = inputStream;
	        this.errorStream = errorStream;
	        consumptionReady = new CountDownLatch(1);
	    }
	    
	    override run() {
	        new BufferedReader(new InputStreamReader(inputStream))
	        	.lines()
	        	.forEach([ line | stdoutLines.add(line) ])
	        new BufferedReader(new InputStreamReader(errorStream))
	        	.lines()
	        	.forEach([ line | stderrLines.add(line) ])
	        consumptionReady.countDown()
	    }
	    
		def getStdOutLines() {
			if (consumptionReady.await(EPSILONCG_FINISHING_TIMEOUT_MS, TimeUnit.MILLISECONDS)) {
				this.stdoutLines
			}
			else {
				logger.error(String.format(
					"Output from call to epsilon generator could not be consumed within %dms - no issue will be reported even if exist", EPSILONCG_FINISHING_TIMEOUT_MS))				
				emptyList
			}
		}	    

		def getStdErrLines() {
			if (consumptionReady.await(EPSILONCG_FINISHING_TIMEOUT_MS, TimeUnit.SECONDS)) {
				this.stderrLines
			}
			else {
				logger.error(String.format(
					"Output from call to epsilon generator could not be consumed within %dms - no issue will be reported even if exist", EPSILONCG_FINISHING_TIMEOUT_MS))				
				emptyList
			}
		}	    
	    
	}
	
	
}