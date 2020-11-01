package de.grammarcraft.epsilon.tests

import org.junit.Test

import org.junit.runner.RunWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.InjectWith
import com.google.inject.Inject
import org.eclipse.xtext.testing.util.ParseHelper
import de.grammarcraft.epsilon.epsilon.Specification
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference

import static extension org.junit.Assert.*
import de.grammarcraft.epsilon.epsilon.EpsilonPackage
import de.grammarcraft.epsilon.epsilon.HyperRule
import org.eclipse.xtext.scoping.IScopeProvider

@RunWith(XtextRunner)
@InjectWith(EpsilonInjectorProvider)

class EpsilonScopeTest {

	@Inject extension ParseHelper<Specification> parseHelper
	@Inject extension IScopeProvider
	
	@Test 
	def void testEachFileCreatesOwnScope() {
		val first = '''
			N= 'Hello World!'.
			S <+ 'Hello World!': N>: .
		'''.parse
		
		val second = '''
			S <+ 'Hello World!': N>: .
			M= 'Hello World!'.
		'''
		.parse(first.eResource.resourceSet)
		
		val hyperRule = second.rules.head as HyperRule
		
		hyperRule.formalParams.list.head.affixType => [
			assertScope(EpsilonPackage.eINSTANCE.formalParam_AffixType, "M") // no "N" here!
		]
	}

	def private assertScope(EObject context, EReference reference, CharSequence expected) {
		expected.toString.assertEquals(context.getScope(reference).allElements.map[name].join(", "))
	}
}