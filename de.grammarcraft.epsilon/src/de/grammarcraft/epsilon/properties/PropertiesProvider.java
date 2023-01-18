/**
 * 
 */
package de.grammarcraft.epsilon.properties;

import org.eclipse.core.resources.IProject;

import de.grammarcraft.epsilon.preferences.EpsilonPreferences;

/**
 * @author denis
 *
 */
public final class PropertiesProvider implements IPropertiesProvider {

    @Override
    public String getGeneratorExecutablePath(IProject project) {
        if (project != null)
            return Properties.getGeneratorExecutablePath(project);
        else
            return EpsilonPreferences.getGeneratorExecutablePath();
    }

    @Override
    public boolean getSpaceInsteadNL(IProject project) {
        if (project != null)
            return Properties.getSpaceInsteadNL(project);
        else
            return EpsilonPreferences.getSpaceInsteadNL();
    }

    @Override
    public String getGeneratorTargetDir(IProject project) {
        if (project != null)
            return Properties.getGeneratorTargetDir(project);
        else
            return EpsilonPreferences.getGeneratorTargetDir();
    }

    @Override
    public boolean getNoConstantTreesCollapsing(IProject project) {
        if (project != null)
            return Properties.getNoConstantTreesCollapsing(project);
        else
            return EpsilonPreferences.getNoConstantTreesCollapsing();
    }

    @Override
    public boolean getGenerationOnly(IProject project) {
        if (project != null)
            return Properties.getGenerationOnly(project);
        else
            return EpsilonPreferences.getGenerationOnly();
    }

    @Override
    public boolean getNoOptimization(IProject project) {
        if (project != null)
            return Properties.getNoOptimization(project);
        else
            return EpsilonPreferences.getNoOptimization();
    }

    @Override
    public boolean getNoReferenceCounting(IProject project) {
        if (project != null)
            return Properties.getNoReferenceCounting(project);
        else
            return EpsilonPreferences.getNoReferenceCounting();
    }

    @Override
    public boolean getIgnoreTokenMarks(IProject project) {
        if (project != null)
            return Properties.getIgnoreTokenMarks(project);
        else
            return EpsilonPreferences.getIgnoreTokenMarks();
    }

    @Override
    public String getAdditionalGeneratorOptions(IProject project) {
        if (project != null)
            return Properties.getAdditionalGeneratorOptions(project);
        else
            return EpsilonPreferences.getAdditionalGeneratorOptions();
    }

}
