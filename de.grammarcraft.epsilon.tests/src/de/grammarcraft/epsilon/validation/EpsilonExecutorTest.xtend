package de.grammarcraft.epsilon.validation

import java.io.File
import org.eclipse.emf.common.util.Diagnostic
import org.junit.Test

import static org.junit.Assert.*

class EpsilonExecutorTest {
	
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
		val errPosLine = '4'
		val errPosCol = '26'
		val errMsg2 = 'errors in Expr'
		val outputLines = '''
			info: «infoMsg»
			warn: «warnMsg»
			error: «errMsg1»
			«errFile»:«errPosLine»:«errPosCol»     Term <Code1> ExprTail<Code1>.
			                                           ^
			error: «errMsg2»
		'''.toString.split('\n')
		
		val result = EpsilonExecutor.createIssueListFrom(outputLines)
		assertEquals(4, result.length)
		result.get(0) => [
			assertEquals(Diagnostic.OK, severity)
			assertEquals(infoMsg, message)
			assertTrue(file.empty)
			assertTrue(line.empty)
			assertTrue(column.empty)
		]
		result.get(1) => [
			assertEquals(Diagnostic.WARNING, severity)
			assertEquals(warnMsg, message)
			assertTrue(file.empty)
			assertTrue(line.empty)
			assertTrue(column.empty)
		]
		result.get(2) => [
			assertEquals(Diagnostic.ERROR, severity)
			assertEquals(errMsg1, message)
			assertEquals(errFile, file)
			assertEquals(errPosLine, line)
			assertEquals(errPosCol, column)
		]
		result.get(3) => [
			assertEquals(Diagnostic.ERROR, severity)
			assertEquals(errMsg2, message)
			assertTrue(file.empty)
			assertTrue(line.empty)
			assertTrue(column.empty)
		]
	}
	
	
	@Test
	def void determineEpsilonTargetDirDefault() {
		val result = EpsilonExecutor.determineEpsilonTargetDir
		assertEquals(new File('./'), result)
	}

	@Test
	def void determineEpsilonTargetDirFromSysProp() {
		val file = new File('./build')
		System.properties.setProperty(EpsilonExecutor.EPSILON_TARGET_DIR_SYSPROP_NAME, file.absolutePath)
		val result = EpsilonExecutor.determineEpsilonTargetDir
		assertEquals(file.absolutePath, result.absolutePath)
	}
	
	@Test
	def void determineEpsilonTargetDirFallBackOnError() {
		val file = File.createTempFile('determineEpsilonTargetDirFallBackOnError', 'build')
		System.properties.setProperty(EpsilonExecutor.EPSILON_TARGET_DIR_SYSPROP_NAME, file.absolutePath)
		try {
			val result = EpsilonExecutor.determineEpsilonTargetDir
			assertEquals(new File('./').absolutePath, result.absolutePath)
		}
		finally {
			System.properties.remove(EpsilonExecutor.EPSILON_EXE_SYSPROP_NAME)
		}
	}
	

	@Test
	def void determineEpsilonExecutableDefault() {
		val result = EpsilonExecutor.determineEpsilonExecutable
		assertEquals(new File('./epsilon'), result)
	}

	@Test
	def void determineEpsilonExecutableFromSysProp() {
		val file = new File('./build/epsilon')
		System.properties.setProperty(EpsilonExecutor.EPSILON_EXE_SYSPROP_NAME, file.absolutePath)
		try {
			val result = EpsilonExecutor.determineEpsilonExecutable
			assertEquals(file.absolutePath, result.absolutePath)			
		}
		finally {
			System.properties.remove(EpsilonExecutor.EPSILON_EXE_SYSPROP_NAME)
		}
	}

	@Test
	def void determineAdditionalExecutionArgsDefault() {
		val result = EpsilonExecutor.determineAdditionalExecutionArgument
		assertTrue(result.empty)
	}

	@Test
	def void determineAdditionalExecutionArgsFromSysProp() {
		val additionalArgs = '-g -s'
		System.properties.setProperty(EpsilonExecutor.ADDITIONAL_EXE_ARGUMENTS_SYSPROP_NAME, additionalArgs)
		try {
			val result = EpsilonExecutor.determineAdditionalExecutionArgument
			assertEquals(additionalArgs, result)			
		}
		finally {
			System.properties.remove(EpsilonExecutor.ADDITIONAL_EXE_ARGUMENTS_SYSPROP_NAME)
		}
	}


}