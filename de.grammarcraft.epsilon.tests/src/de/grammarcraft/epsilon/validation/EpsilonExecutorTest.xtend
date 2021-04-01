package de.grammarcraft.epsilon.validation

import org.junit.Test
import static org.junit.Assert.*
import org.eclipse.emf.common.util.Diagnostic

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
	
	
	

}