package de.grammarcraft.epsilon.validation

import java.io.File
import org.eclipse.emf.common.util.Diagnostic
import org.junit.Test

import static org.junit.Assert.*
import org.junit.runner.RunWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.InjectWith
import de.grammarcraft.epsilon.tests.EpsilonInjectorProvider
import com.google.inject.Inject
import de.grammarcraft.epsilon.preferences.EpsilonPreferencesProvider
import java.util.List

@RunWith(XtextRunner)
@InjectWith(EpsilonInjectorProvider)
class EpsilonExecutorTest {
    
    @Inject EpsilonExecutor epsilonExecutor
    
	@Test
	def void createIssueFromError() {
		val msg = 'number of affixforms differs from signature'
		val outputLine = '''error: «msg» '''
		val result = EpsilonExecutor.createIssueFrom(outputLine)
		assertNotNull(result)
		assertEquals(Diagnostic.ERROR, result.severity)
		assertEquals(msg, result.message)
	}

	@Test
	def void createIssueFromWarning() {
		val msg = 'nonterminal N is not productive'
		val outputLine = '''warn: «msg» '''
		val result = EpsilonExecutor.createIssueFrom(outputLine)
		assertNotNull(result)
		assertEquals(Diagnostic.WARNING, result.severity)
		assertEquals(msg, result.message)
	}

	@Test
	def void createIssueFromInfo() {
		val msg = 'number of affixforms differs from signature'
		val outputLine = '''info: «msg» '''
		val result = EpsilonExecutor.createIssueFrom(outputLine)
		assertNotNull(result)
		assertEquals(Diagnostic.OK, result.severity)
		assertEquals(msg, result.message)
	}
	
	@Test def void createIssueListFrom() {
		val infoMsg = 'Epsilon 1.02   JoDe/SteWe  22.11.96'
		val warnMsg = 'nonterminal N is unproductive'
		val errMsg1 = 'number of affixforms differs from signature'
		val errFile = 'expr-bnf.eag'
		val errOffset = '73'
		val errMsg2 = 'errors in Expr'
		val outputLines = '''
			info: «infoMsg»
			warn: «warnMsg»
			error: «errMsg1»
			«errFile»@«errOffset»  
			error: «errMsg2»
		'''.toString.split('\n')
		
		val result = EpsilonExecutor.createIssueListFrom(outputLines)
		assertEquals(4, result.length)
		result.get(0) => [
			assertEquals(Diagnostic.OK, severity)
			assertEquals(infoMsg, message)
			assertTrue(file.empty)
			assertTrue(offset.empty)
		]
		result.get(1) => [
			assertEquals(Diagnostic.WARNING, severity)
			assertEquals(warnMsg, message)
			assertTrue(file.empty)
			assertTrue(offset.empty)
		]
		result.get(2) => [
			assertEquals(Diagnostic.ERROR, severity)
			assertEquals(errMsg1, message)
			assertEquals(errFile, file)
			assertEquals(errOffset, offset)
		]
		result.get(3) => [
			assertEquals(Diagnostic.ERROR, severity)
			assertEquals(errMsg2, message)
			assertTrue(file.empty)
			assertTrue(offset.empty)
		]
	}
	
	
	@Test
	def void determineEpsilonTargetDirDefault() {
		val result = epsilonExecutor.determineEpsilonTargetDir
		assertEquals(new File(EpsilonPreferencesProvider.EPSILON_TARGET_DIR_DEFAULT), result)
	}

	@Test
	def void determineEpsilonTargetDirFromSysProp() {
		val file = new File('./build')
		System.properties.setProperty(EpsilonExecutor.SYSPROP_NAME_EPSILON_TARGET_DIR, file.absolutePath)
        try {
        	val result = epsilonExecutor.determineEpsilonTargetDir
        	assertEquals(file.absolutePath, result.absolutePath)
        }
        finally {
            System.properties.remove(EpsilonExecutor.SYSPROP_NAME_EPSILON_TARGET_DIR)
        }
	}
	
	@Test
	def void determineEpsilonTargetDirFallBackOnError() {
		val file = File.createTempFile('determineEpsilonTargetDirFallBackOnError', 'build')
		System.properties.setProperty(EpsilonExecutor.SYSPROP_NAME_EPSILON_TARGET_DIR, file.absolutePath)
		try {
			val result = epsilonExecutor.determineEpsilonTargetDir
			assertEquals(new File('./').absolutePath, result.absolutePath)
		}
		finally {
			System.properties.remove(EpsilonExecutor.SYSPROP_NAME_EPSILON_TARGET_DIR)
		}
	}
	

	@Test
	def void determineEpsilonExecutableDefault() {
		val result = epsilonExecutor.determineEpsilonExecutable
		assertEquals(new File('./build/cg/gamma'), result)
	}

	@Test
	def void determineEpsilonExecutableFromSysProp() {
		val file = new File('./build/epsilon')
		System.properties.setProperty(EpsilonExecutor.SYSPROP_NAME_EPSILON_EXE, file.absolutePath)
		try {
			val result = epsilonExecutor.determineEpsilonExecutable
			assertEquals(file.absolutePath, result.absolutePath)			
		}
		finally {
			System.properties.remove(EpsilonExecutor.SYSPROP_NAME_EPSILON_EXE)
		}
	}

	@Test
	def void determineAdditionalExecutionArgsDefault() {
		val result = epsilonExecutor.determineAdditionalExecutionArgument
		assertEquals(1, result.size)
		assertEquals("-s", result.join(' ')) // by default space instead of NL is enabled
	}

	@Test
	def void determineAdditionalExecutionArgsFromSysProp() {
		val additionalArgs = ' -g -s '
		System.properties.setProperty(EpsilonExecutor.SYSPROP_NAME_ADDITIONAL_EXE_ARGUMENTS, additionalArgs)
		try {
			val List<String> result = epsilonExecutor.determineAdditionalExecutionArgument
			assertEquals(2, result.size)
			assertEquals(additionalArgs.trim, result.join(' '))			
		}
		finally {
			System.properties.remove(EpsilonExecutor.SYSPROP_NAME_ADDITIONAL_EXE_ARGUMENTS)
		}
	}


}