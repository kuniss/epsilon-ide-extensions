/*
 * generated by Xtext 2.20.0
 */
package de.grammarcraft.epsilon.tests

import com.google.inject.Inject
import de.grammarcraft.epsilon.epsilon.Specification
import java.io.File
import java.nio.file.Files
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(EpsilonInjectorProvider)
class EpsilonParsingTest {
	@Inject
	ParseHelper<Specification> parseHelper
	@Inject extension ValidationTestHelper
	
	private def assertNoSyntaxErrors(Specification specification) {
		val errors = specification.eResource.errors
		assertTrue('''Unexpected syntax errors: «errors.join(", ")»''', errors.isEmpty)
	}
	
	private def assertNoValidationErrors(Specification specification) {
		specification.assertNoErrors
	}
	
	@Test
	def void parseSimpleExample() {
		val result = parseHelper.parse('''
			// simple example
			x = "a" | "b".
			/* some multiline comment */
			x <+ "a": x> : "a".
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}
	
	@Test
	def void nestedMultilineComment() {
		val result = parseHelper.parse('''
			/* block comment
			/*
			 * nested block comment
			 */
			// not a line comment */
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void singleLineComment() {
		val result = parseHelper.parse('''
			// single line comment
			Code = "empty". // single line comment at end of file
			                // single line comment with preceeding white spaces
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseFormalParamsWithOutExplicitAffixType() {
		val result = parseHelper.parse('''
			Code = "empty".
			OberonO <+ Code>: Module <Code>.
			Module<- "empty": Code>: .
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseActualParamsWithSpaceBetweenAffixandAffixNumber() {
		val result = parseHelper.parse('''
			Code = "empty".
			OberonO <+ Code 1>: Module <Code1>.
			OberonO <+ ! Code 1>: Module <!Code1>.
			Module<- "empty": Code>: .
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}
	
	@Test
	def void parseUnicodeIdentifiers() {
		val result = parseHelper.parse('''
			_output = word "\n" word.
			
			word = | letter word.
			
			letter = "α" | "β".
			
			word:
			    { <+ letter word: word>
			        <letter> ( <+ "α": letter> "α" | <+ "β": letter> "β" )  <word>
			    } <+ : word>.
			
			π:
			      <- /* empty */: word, - word, + word>
			    | <- "α" word 1: word, - word 2, + "α" word 3: word>
			        π <word 1, word 2, word 3>
			    | <- "β" word 1: word, - word 2, + word 3>
			        π <word 1, "β" word 2, word 3>.
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseHelloWorld() {
		val result = parseHelper.parse('''
			// ------------------------   Hello World!
			
			N= 'Hello World!'.
			S <+ 'Hello World!': N>: .
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseNonContextFreeGrammarWithEBNF() {
		val result = parseHelper.parse('''
			//  ------------------------   a^n b^n  -> i^n  with EBNF
			
			N= "i" N | .
			
			S: <+ N: N>
				<N>{<+"i" N : N> 'a' <N> } <+ : N>
				<N>{<-"i" N : N> 'b' <N> } <- : N> .
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseNonContextFreeGrammarWithoutEBNF() {
		val result = parseHelper.parse('''
			//  ------------------------   a^n b^n  -> i^n  without EBNF
			
			N = "i" N | .
			
			S: <+ N : N> A <N> B <N>.
			A: <+ "i" N : N> 'a' A <N> | <+ : N> .
			B: <- "i" N : N> 'b' B <N> | <- : N> .
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseNonContextFreeGrammar() {
		val result = parseHelper.parse('''
			// ------------------------   a^n b^n c^n -> i^n
			
			n = | n "i".
			
			S <+ n: n>:
			  <n> { <+ n "i": n> "a"  <n> } <+ : n>
			  <n> { <+ n "i": n> "b"  <n> } <+ : n>
			  <n> { <+ n "i": n> "c"  <n> } <+ : n>.
  		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseNumberCounterGrammer() {
		val result = parseHelper.parse('''
			// ------------------------   i^n --> n
			
			N = N D | "Number" .
			D = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" .
			
			S : <+ N: N><"Number" "0", N> {<- N: N,+ N2: N> 'i' INC <N, N1> <N1, N2> } <- N: N, + N: N> .
			
			INC: <- N "0": N, + N "1": N> | <- N "1": N, + N "2": N> | <- N "2": N, + N "3": N> | <- N "3": N, + N "4": N>  
				| <- N "4": N, + N "5": N> | <- N "5": N, + N "6": N> | <- N "6": N, + N "7": N> | <- N "7": N, + N "8": N> 
				| <- N "8": N, + N "9": N> | <- N "9": N, + N1 "0": N> INC <N, N1> | <- "Number": N, + "Number" "1": N>.
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseReducedExample() {
		val result = parseHelper.parse('''
			// DeclAppl
			
			Tab = | id ";" Tab.

			DeclAppl <+ Tab: Tab> :
				<, Tab >
				{ <- Tab : Tab, + Tab1: Tab>
					"DECL" id < id > Find <id, Tab, "FALSE" >
					<id ";" Tab, Tab1 >
				| <- Tab : Tab, + Tab1: Tab>
					"APPL" id < id > Find <id, Tab, "TRUE" >
					<Tab, Tab1 >
				} <- Tab : Tab, + Tab: Tab> .
			
			x = "a" | "b".
			id* = x | id x.
			
			x <+ "a": x> : "a".
			x <+ "b": x> : "b".
			
			id* <+ id: id> :
				x < x >
				<x, id >
				{ <- id : id, + id1: id>
					x < x > <id x, id1 >
				} <- id : id, + id: id> .
				
			Bool = "TRUE" | "FALSE".
			
			Find <- id: id, - : Tab, + "FALSE": Bool>: .
			Find <- id: id, - id ";" Tab : Tab, + "TRUE": Bool>: .
			Find <- id: id, - !id ";" Tab : Tab, + Bool: Bool>:
				Find <id, Tab, Bool >.
		''')
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}
	
	@Test
	def void parseExample1() {
		val specFile = new File(class.getResource('/example1.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}
	
	@Test
	def void parseExample2() {
		val specFile = new File(class.getResource('/example2.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}
	
	@Test
	def void parseExample3() {
		val specFile = new File(class.getResource('/example3.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}
	
	@Test
	def void parseExample4() {
		val specFile = new File(class.getResource('/example4.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}
	
	@Test
	def void parseExample5() {
		val specFile = new File(class.getResource('/example5.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}
	
	@Test
	def void parseExample6() {
		val specFile = new File(class.getResource('/example6.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseNotOeag1() {
		val specFile = new File(class.getResource('/not-oeag-1.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseNotOeag2() {
		val specFile = new File(class.getResource('/not-oeag-2.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseNotOeag3() {
		val specFile = new File(class.getResource('/not-oeag-3.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseNotOeag4() {
		val specFile = new File(class.getResource('/not-oeag-4.eag').file)
		val spec = Files.readAllLines(specFile.toPath).join('\n')
		val result = parseHelper.parse(spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseOberon0Spec() {
		val obern0SpecFile = new File(class.getResource('/oberon0.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseOberon0AbstractSyntaxSpec() {
		val obern0SpecFile = new File(class.getResource('/oberon0-abstract-syntax.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseOberon0FrontendSpec() {
		val obern0SpecFile = new File(class.getResource('/oberon0-frontend.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseOberon0SymbolResolutionSpec() {
		val obern0SpecFile = new File(class.getResource('/oberon0-symbol-resolution.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseOberon0SymbolTableSpec() {
		val obern0SpecFile = new File(class.getResource('/oberon0-symbol-tables.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseOberon0TypeCheckSpec() {
		val obern0SpecFile = new File(class.getResource('/oberon0-type-check.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseOberon0TypeTablesSpec() {
		val obern0SpecFile = new File(class.getResource('/oberon0-type-tables.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseOberon0UnequalSpec() {
		val obern0SpecFile = new File(class.getResource('/oberon0-unequal.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

	@Test
	def void parseUnicodeExample() {
		val obern0SpecFile = new File(class.getResource('/unicode-example.eag').file)
		val oberon0Spec = Files.readAllLines(obern0SpecFile.toPath).join('\n')
		val result = parseHelper.parse(oberon0Spec)
		assertNotNull(result)
		result.assertNoSyntaxErrors
		result.assertNoValidationErrors
	}

}
