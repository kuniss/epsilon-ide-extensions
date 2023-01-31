package de.grammarcraft.epsilon.preferences;

public interface IEpsilonPreferences {

    public String generatorExecutablePath();
    
    public String generatorTargetDir();
    
    public boolean optionNoConstantTreesCollapsing();
    
    public boolean optionGenerationOnly();
    
    public boolean optionNoOptimization();
    
    public boolean optionNoReferenceCounting();
    
    public boolean optionIgnoreTokenMarks();

    public boolean optionSpaceInsteadNL();

    public String additionalGeneratorOptions();

}
