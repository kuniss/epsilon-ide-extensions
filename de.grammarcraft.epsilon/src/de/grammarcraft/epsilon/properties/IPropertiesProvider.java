package de.grammarcraft.epsilon.properties;

import org.eclipse.core.resources.IProject;

import com.google.inject.ImplementedBy;

/**
 * @author denis
 *
 */
@ImplementedBy(PropertiesProvider.class)
public interface IPropertiesProvider {

    public String getGeneratorExecutablePath(IProject project);

    public String getGeneratorTargetDir(IProject project);
    
    public boolean getNoConstantTreesCollapsing(IProject project);
    
    public boolean getGenerationOnly(IProject project);
    
    public boolean getNoOptimization(IProject project);
    
    public boolean getNoReferenceCounting(IProject project);
    
    public boolean getIgnoreTokenMarks(IProject project);    

    public boolean getSpaceInsteadNL(IProject project);

    public String getAdditionalGeneratorOptions(IProject project);
    

}
