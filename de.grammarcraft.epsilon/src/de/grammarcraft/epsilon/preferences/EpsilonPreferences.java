package de.grammarcraft.epsilon.preferences;

import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.InstanceScope;

/**
 * Constant definitions for plug-in preferences
 */
public class EpsilonPreferences {
    
    public static String EPSILON_TARGET_DIR_DEFAULT = "./build";
    public static String EPSILON_EXE_DEFAULT = EPSILON_TARGET_DIR_DEFAULT + "/cg/gamma"; // for later when we will carrying the gamma exec

    public static final String P_GENERATOR_EXE_PATH = "generatorExecutablePath";
    public static final String P_GENERATOR_TARGET_DIR = "generatorTargetDir";
    public static final String P_GENERATOR_ADDITIONAL_OPTIONS = "generatorAdditionalOptions";
    public static final String P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING = "generatorOptionNoConstantTreesCollabsing";
    public static final String P_GENERATOR_OPTION_GENERATION_ONLY = "generatorOptionNoCompilation";
    public static final String P_GENERATOR_OPTION_NO_OPTIMIZATION = "generatorOptionNoOptimization";
    public static final String P_GENERATOR_OPTION_NO_REFERENCE_COUNTING = "generatorOptionNoRefCounting";
    public static final String P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS = "generatorOptionIgnoreTokenMark";
    public static final String P_GENERATOR_OPTION_SPACE_INSTEA_NL = "generatorOptionStaceInsteadNL";
    
    public static final String getGeneratorExecutablePath() {
        return getPreferenceStore().get(P_GENERATOR_EXE_PATH, EPSILON_EXE_DEFAULT);
    }
    
    public static final String getGeneratorTargetDir() {
        return getPreferenceStore().get(P_GENERATOR_TARGET_DIR, EPSILON_TARGET_DIR_DEFAULT);
    }

// Gamma generator options
//    -c               Disable collapsing constant trees
//    -g               Generate only, do not compile
//    -o               Disable optimizing of variable storage in compiled compiler
//    -p               Parser ignores regular token marks at hyper-nonterminals
//    -r               Disable reference counting in compiled compiler
//    -s, --space      Compiled compiler uses space instead of newline as separator
    
    public static final boolean getNoConstantTreesCollapsing() {
        return getPreferenceStore().getBoolean(P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING, false);        
    }
    
    public static final boolean getGenerationOnly() {
        return getPreferenceStore().getBoolean(P_GENERATOR_OPTION_GENERATION_ONLY, true);        
    }
    
    public static final boolean getNoOptimization() {
        return getPreferenceStore().getBoolean(P_GENERATOR_OPTION_NO_OPTIMIZATION, false);        
    }
    
    public static final boolean getNoReferenceCounting() {
        return getPreferenceStore().getBoolean(P_GENERATOR_OPTION_NO_REFERENCE_COUNTING, false);        
    }
    
    public static final boolean getIngnoreTokenMarks() {
        return getPreferenceStore().getBoolean(P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS, false);        
    }    

    public static final boolean getSpaceInsteadNL() {
        return getPreferenceStore().getBoolean(P_GENERATOR_OPTION_SPACE_INSTEA_NL, true);        
    }

    public static final String getAdditionalGeneratorOptions() {
        return getPreferenceStore().get(P_GENERATOR_ADDITIONAL_OPTIONS, "");
    }
    
    public static IEclipsePreferences getPreferenceStore() {
        return InstanceScope.INSTANCE.getNode("de.grammarcraft.epsilon");
    }

// Eclipse generated:
//	public static final String P_PATH = "pathPreference";
//
//	public static final String P_BOOLEAN = "booleanPreference";
//
//	public static final String P_CHOICE = "choicePreference";
//
//	public static final String P_STRING = "stringPreference";
	
}
