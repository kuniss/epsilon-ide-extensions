/**
 * Copyright 2023 kuniss@grammarcraft.de
 */
package de.grammarcraft.epsilon.preferences;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ProjectScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.xtext.Constants;

import com.google.inject.Inject;
import com.google.inject.Singleton;
import com.google.inject.name.Named;

/**
 * Constant definitions for plug-in preferences
 */
@Singleton
public class EpsilonPreferences {
    
    public static String EPSILON_TARGET_DIR_DEFAULT = "./build";
    public static String EPSILON_EXE_DEFAULT = EPSILON_TARGET_DIR_DEFAULT + "./cg/gamma"; // for later when we will carrying the gamma exec

    public static final String P_GENERATOR_EXE_PATH = "generatorExecutablePath";
    public static final String P_GENERATOR_TARGET_DIR = "generatorTargetDir";
    public static final String P_GENERATOR_ADDITIONAL_OPTIONS = "generatorAdditionalOptions";
    public static final String P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING = "generatorOptionNoConstantTreesCollabsing";
    public static final String P_GENERATOR_OPTION_GENERATION_ONLY = "generatorOptionNoCompilation";
    public static final String P_GENERATOR_OPTION_NO_OPTIMIZATION = "generatorOptionNoOptimization";
    public static final String P_GENERATOR_OPTION_NO_REFERENCE_COUNTING = "generatorOptionNoRefCounting";
    public static final String P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS = "generatorOptionIgnoreTokenMark";
    public static final String P_GENERATOR_OPTION_SPACE_INSTEAD_NL = "generatorOptionStaceInsteadNL";
    
    private String languageName;

    @Inject
    public void setLanguageName(@Named(Constants.LANGUAGE_NAME) String languageName) {
        this.languageName = languageName;
    }

    public String keyFor(String preferenceName) {
        return languageName + "." + preferenceName;
    }
    
    private final static IEpsilonPreferences DEFAULT = new IEpsilonPreferences() {
        @Override public boolean optionSpaceInsteadNL()             { return true;  }
        @Override public boolean optionNoReferenceCounting()        { return false; }
        @Override public boolean optionNoOptimization()             { return false; }
        @Override public boolean optionNoConstantTreesCollapsing()  { return false; }
        @Override public boolean optionIgnoreTokenMarks()           { return false; }
        @Override public boolean optionGenerationOnly()             { return true;  }
        @Override public String generatorTargetDir()                { return EPSILON_TARGET_DIR_DEFAULT; }
        @Override public String generatorExecutablePath()           { return EPSILON_EXE_DEFAULT; }
        @Override public String additionalGeneratorOptions()        { return ""; }
    };
    
    public IEpsilonPreferences defaultFor() {
        return DEFAULT;
    }
    
    private final class PreferenceStoreBasedPreferencesAccess implements IEpsilonPreferences {
        private final IEclipsePreferences preferenceStore;
        private final IEpsilonPreferences fallback;

        public PreferenceStoreBasedPreferencesAccess(IEclipsePreferences preferenceStore, IEpsilonPreferences fallback) {
            this.preferenceStore = preferenceStore;
            this.fallback = fallback;
        }

        @Override
        public String generatorExecutablePath() {
            return this.preferenceStore.get(keyFor(P_GENERATOR_EXE_PATH), fallback.generatorExecutablePath());
        }

        @Override
        public String generatorTargetDir() {
            return this.preferenceStore.get(keyFor(P_GENERATOR_TARGET_DIR), fallback.generatorTargetDir());
        }

        @Override
        public boolean optionNoConstantTreesCollapsing() {
            return this.preferenceStore.getBoolean(keyFor(P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING), fallback.optionNoConstantTreesCollapsing());
        }

        @Override
        public boolean optionGenerationOnly() {
            return this.preferenceStore.getBoolean(keyFor(P_GENERATOR_OPTION_GENERATION_ONLY), fallback.optionGenerationOnly());
        }

        @Override
        public boolean optionNoOptimization() {
            return this.preferenceStore.getBoolean(keyFor(P_GENERATOR_OPTION_NO_OPTIMIZATION), fallback.optionNoOptimization());
        }

        @Override
        public boolean optionNoReferenceCounting() {
            return this.preferenceStore.getBoolean(keyFor(P_GENERATOR_OPTION_NO_REFERENCE_COUNTING), fallback.optionNoReferenceCounting());
        }

        @Override
        public boolean optionIgnoreTokenMarks() {
            return this.preferenceStore.getBoolean(keyFor(P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS), fallback.optionIgnoreTokenMarks());
        }

        @Override
        public boolean optionSpaceInsteadNL() {
            return this.preferenceStore.getBoolean(keyFor(P_GENERATOR_OPTION_SPACE_INSTEAD_NL), fallback.optionSpaceInsteadNL());
        }

        @Override
        public String additionalGeneratorOptions() {
            return this.preferenceStore.get(keyFor(P_GENERATOR_ADDITIONAL_OPTIONS), fallback.additionalGeneratorOptions());
        }
    }

    public IEpsilonPreferences workspacePreferences() {
        IEclipsePreferences preferenceStore = InstanceScope.INSTANCE.getNode(languageName);
        return new PreferenceStoreBasedPreferencesAccess(preferenceStore , DEFAULT);
    }
    
    public IEpsilonPreferences projectPreferences(IProject project) {
        IEclipsePreferences projectPreferenceStore = new ProjectScope(project).getNode(languageName);
        IEpsilonPreferences workspacePreferences = workspacePreferences();
        return new PreferenceStoreBasedPreferencesAccess(projectPreferenceStore, workspacePreferences);
    }
    
    public void storeDefault(String preferenceName, String value) {
        getPrefStore().put(keyFor(preferenceName), value);
    }
    
    public void storeDefault(String preferenceName, boolean value) {
        getPrefStore().putBoolean(keyFor(preferenceName), value);
    }

    public IEclipsePreferences getPrefStore() {
        return InstanceScope.INSTANCE.getNode(languageName);
    }
    
    
    public static final String LANGUAGE_NAME = "de.grammarcraft.epsilon.Epsilon";
    private static final String PROPERTY_PREFIX = LANGUAGE_NAME + "." ;
    
    public static final String PROPERTY_GENERATOR_EXE_PATH                              = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_EXE_PATH;
    public static final String PROPERTY_GENERATOR_TARGET_DIR                            = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_TARGET_DIR;
    public static final String PROPERTY_GENERATOR_ADDITIONAL_OPTIONS                    = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_ADDITIONAL_OPTIONS;
    public static final String PROPERTY_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING   = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING;
    public static final String PROPERTY_GENERATOR_OPTION_GENERATION_ONLY                = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_OPTION_GENERATION_ONLY;
    public static final String PROPERTY_GENERATOR_OPTION_NO_OPTIMIZATION                = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_OPTION_NO_OPTIMIZATION;
    public static final String PROPERTY_GENERATOR_OPTION_NO_REFERENCE_COUNTING          = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_OPTION_NO_REFERENCE_COUNTING;
    public static final String PROPERTY_GENERATOR_OPTION_IGNORE_TOKEN_MARKS             = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS;
    public static final String PROPERTY_GENERATOR_OPTION_SPACE_INSTEAD_NL               = PROPERTY_PREFIX + EpsilonPreferences.P_GENERATOR_OPTION_SPACE_INSTEAD_NL;

    public static IEclipsePreferences getPreferenceStore() {
        return InstanceScope.INSTANCE.getNode(LANGUAGE_NAME);
    }
    
    public static final String getGeneratorExecutablePath() {
        return getPreferenceStore().get(PROPERTY_GENERATOR_EXE_PATH, EPSILON_EXE_DEFAULT);
    }
    
    public static final String getGeneratorTargetDir() {
        return getPreferenceStore().get(PROPERTY_GENERATOR_TARGET_DIR, EPSILON_TARGET_DIR_DEFAULT);
    }
    
    

// Gamma generator options
//    -c               Disable collapsing constant trees
//    -g               Generate only, do not compile
//    -o               Disable optimizing of variable storage in compiled compiler
//    -p               Parser ignores regular token marks at hyper-nonterminals
//    -r               Disable reference counting in compiled compiler
//    -s, --space      Compiled compiler uses space instead of newline as separator
    
    public static final boolean getNoConstantTreesCollapsing() {
        return getPreferenceStore().getBoolean(PROPERTY_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING, false);        
    }
    
    public static final boolean getGenerationOnly() {
        return getPreferenceStore().getBoolean(PROPERTY_GENERATOR_OPTION_GENERATION_ONLY, true);        
    }
    
    public static final boolean getNoOptimization() {
        return getPreferenceStore().getBoolean(PROPERTY_GENERATOR_OPTION_NO_OPTIMIZATION, false);        
    }
    
    public static final boolean getNoReferenceCounting() {
        return getPreferenceStore().getBoolean(PROPERTY_GENERATOR_OPTION_NO_REFERENCE_COUNTING, false);        
    }
    
    public static final boolean getIgnoreTokenMarks() {
        return getPreferenceStore().getBoolean(PROPERTY_GENERATOR_OPTION_IGNORE_TOKEN_MARKS, false);        
    }    

    public static final boolean getSpaceInsteadNL() {
        return getPreferenceStore().getBoolean(PROPERTY_GENERATOR_OPTION_SPACE_INSTEAD_NL, true);        
    }

    public static final String getAdditionalGeneratorOptions() {
        return getPreferenceStore().get(PROPERTY_GENERATOR_ADDITIONAL_OPTIONS, "");
    }
    
}
