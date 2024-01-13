/*
 * generated by Xtext 2.21.0
 */
package de.grammarcraft.epsilon.validation

import java.util.List;

import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.CheckType

import com.google.inject.Inject

import de.grammarcraft.epsilon.epsilon.EpsilonPackage
import de.grammarcraft.epsilon.epsilon.Specification
import de.grammarcraft.epsilon.validation.EpsilonExecutor.EpsilonIssue
import org.apache.log4j.Logger

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class EpsilonValidator extends AbstractEpsilonValidator {
    
    static val logger = Logger.getLogger(EpsilonValidator.name);
    
	@Inject extension IssuePositionHelper
	@Inject EpsilonExecutor epsilonExecutor
	
	static val ISSUE_CODE_PREFIX = "de.grammarcraft.epsilon.";
	public static val EPSILON_COMPILER_GENERATOR_DETECTED_ISSUE = ISSUE_CODE_PREFIX + "EpsilonCGIssue";

	// perform this check only on file save
	@Check(CheckType.NORMAL)
	def runEpsilonExecutable(Specification specification) {
	    try {
			val issues = epsilonExecutor.executeOn(specification);
			addMarkersForIssues(specification.eResource(), issues);			        
	    }
	    catch (Exception e) {
	        logger.error("executing epsilon generator failed: " + e.message)
            logger.error("stack trace: ", e)
	    }
	}

	private def addMarkersForIssues(Resource resource, List<EpsilonIssue> issues) {
		val xtextResource = resource as org.eclipse.xtext.resource.XtextResource
		issues
			.filter[issue | issue.getSeverity() != Diagnostic.OK]
			.forEach[ issue | 
				switch (issue.getSeverity()) {
				case Diagnostic.ERROR:
					if (issue.getOffset().isEmpty())						
						error("generator: " + issue.getMessage(), EpsilonPackage.eINSTANCE.getSpecification_Rules(),
								EPSILON_COMPILER_GENERATOR_DETECTED_ISSUE)
					else {
						val relevantElement = xtextResource.getElementAt(issue)
						error("generator: " + issue.getMessage(), relevantElement, null, EPSILON_COMPILER_GENERATOR_DETECTED_ISSUE)
					}
				case Diagnostic.WARNING:
					if (issue.getOffset().isEmpty())						
						warning("generator: " + issue.getMessage(), EpsilonPackage.eINSTANCE.getSpecification_Rules(),
								EPSILON_COMPILER_GENERATOR_DETECTED_ISSUE)
					else {
						val relevantElement = xtextResource.getElementAt(issue);
						warning("generator: " + issue.getMessage(), relevantElement, null, EPSILON_COMPILER_GENERATOR_DETECTED_ISSUE);
					}
				}
			];
	}

	
}
