package de.grammarcraft.epsilon.ui.outline

import de.grammarcraft.epsilon.epsilon.HyperRule
import de.grammarcraft.epsilon.epsilon.MetaRule
import de.grammarcraft.epsilon.epsilon.Specification
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.eclipse.xtext.ui.editor.outline.impl.DocumentRootNode

class EpsilonOutlineTreeProvider extends DefaultOutlineTreeProvider {
	
	def void _createChildren(DocumentRootNode outlineNode, Specification specification) {
		specification.rules.forEach[ rule | createNode(outlineNode, rule) ]
		// creates rules as root elements in the outline view
	}
	
	def _isLeaf(HyperRule a) { true }
	def _isLeaf(MetaRule a) { true }
	
}