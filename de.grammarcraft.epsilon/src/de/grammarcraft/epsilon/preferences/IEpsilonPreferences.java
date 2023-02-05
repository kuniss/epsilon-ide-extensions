/**
 * Copyright 2023 kuniss@grammarcraft.de
 */
package de.grammarcraft.epsilon.preferences;

public interface IEpsilonPreferences {
    
    public static final String GENERATOR_EXE_PATH = "generatorExecutablePath";
    public static final String GENERATOR_TARGET_DIR = "generatorTargetDir";
    public static final String OPTION_CREATE_TARGET_DIR = "generatorOptionCreateTargetDir";
    public static final String OPTION_NO_CONSTANT_TREES_COLLAPSING = "generatorOptionNoConstantTreesCollapsing";
    public static final String OPTION_GENERATION_ONLY = "generatorOptionNoCompilation";
    public static final String OPTION_NO_OPTIMIZATION = "generatorOptionNoOptimization";
    public static final String OPTION_NO_REFERENCE_COUNTING = "generatorOptionNoRefCounting";
    public static final String OPTION_IGNORE_TOKEN_MARKS = "generatorOptionIgnoreTokenMark";
    public static final String OPTION_SPACE_INSTEAD_NL = "generatorOptionSpaceInsteadNL";
    public static final String ADDITIONAL_GENERATOR_OPTIONS = "additionalGeneratorOptions";

    public String generatorExecutablePath();
    
    public String generatorTargetDir();
    
    public boolean optionCreateTargetDir();
    
    public boolean optionNoConstantTreesCollapsing();
    
    public boolean optionGenerationOnly();
    
    public boolean optionNoOptimization();
    
    public boolean optionNoReferenceCounting();
    
    public boolean optionIgnoreTokenMarks();

    public boolean optionSpaceInsteadNL();

    public String additionalGeneratorOptions();

}
