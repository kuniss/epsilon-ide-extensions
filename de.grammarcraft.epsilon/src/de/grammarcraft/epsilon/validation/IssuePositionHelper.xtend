package de.grammarcraft.epsilon.validation

import com.google.inject.Inject
import de.grammarcraft.epsilon.validation.EpsilonExecutor.EpsilonIssue
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.XtextResource

/**
 * Idea for this helper was taken from 
 * https://github.com/eclipse/sprotty-server/blob/5d6c6c25e7d5d7ded5c19fc6282a1a45137154ac/org.eclipse.sprotty.xtext/src/main/java/org/eclipse/sprotty/xtext/tracing/TextRegionProvider.xtend
 */
class IssuePositionHelper {

	@Inject extension EObjectAtOffsetHelper
		
	def EObject getElementAtOffset(XtextResource resource, EpsilonIssue issue) {
		val offset = issue.offsetAsInt;
		val document = resource.parseResult.rootNode.text
		var offsetAtFirstNonSpace = offset
		while(offsetAtFirstNonSpace < document.length && document.charAt(offsetAtFirstNonSpace) === 32)
			offsetAtFirstNonSpace++
		return resource.resolveContainedElementAt(offsetAtFirstNonSpace)	
	}
	
	private static def int offsetAsInt(EpsilonIssue issue) {
		try {
			Integer.parseInt(issue.getOffset());
		} catch (NumberFormatException e) {
			0;
		}
	}
	
}
