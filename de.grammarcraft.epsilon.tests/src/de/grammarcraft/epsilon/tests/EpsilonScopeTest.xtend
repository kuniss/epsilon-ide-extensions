package de.grammarcraft.epsilon.tests

import com.google.inject.Inject
import de.grammarcraft.epsilon.epsilon.EpsilonPackage
import de.grammarcraft.epsilon.epsilon.Specification
import org.eclipse.xtext.diagnostics.Diagnostic
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(EpsilonInjectorProvider)

class EpsilonScopeTest {

	@Inject extension ParseHelper<Specification> parseHelper
	@Inject extension ValidationTestHelper
	
	@Test 
	def void testEachFileCreatesOwnScope() {
		val first = '''
			N = 'Hello World!'.
			S <+ 'Hello World!': N>: .
		'''.parse
		
		val second = '''
			M = 'Hello World!'.
			S <+ 'Hello World!': N>: .
		'''
		.parse(first.eResource.resourceSet)
		first.assertNoErrors
		second.assertError(EpsilonPackage.eINSTANCE.formalParam, Diagnostic.LINKING_DIAGNOSTIC, "Couldn't resolve reference to MetaRule 'N'.")
	}

}