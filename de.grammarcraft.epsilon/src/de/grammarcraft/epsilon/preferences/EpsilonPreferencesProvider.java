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
import com.google.inject.name.Named;

import de.grammarcraft.epsilon.validation.ResourceExtractor;

import static de.grammarcraft.epsilon.preferences.IEpsilonPreferences.*;

/**
 * Constant definitions for plug-in preferences
 */
public class EpsilonPreferencesProvider implements IEpsilonPreferencesProvider {
    
    protected static final String DEFAULT_EVALUATOR_TYPE = "soag";
    public static String EPSILON_TARGET_DIR_DEFAULT = "./build";
    public static String EPSILON_EXE_DEFAULT = EPSILON_TARGET_DIR_DEFAULT + "/cg/gamma"; // for later when we will carrying the gamma exec
    
    private String languageName;

    @Inject
    public void setLanguageName(@Named(Constants.LANGUAGE_NAME) String languageName) {
        this.languageName = languageName;
    }

    @Override
    public String key(String preferenceName) {
        return languageName + "." + preferenceName;
    }
    
    private final static IEpsilonPreferences DEFAULT = new IEpsilonPreferences() {
        @Override public boolean optionSpaceInsteadNL()             { return true;  }
        @Override public boolean optionNoReferenceCounting()        { return false; }
        @Override public boolean optionNoOptimization()             { return false; }
        @Override public boolean optionNoConstantTreesCollapsing()  { return false; }
        @Override public boolean optionIgnoreTokenMarks()           { return false; }
        @Override public boolean optionGenerationOnly()             { return true; }
        @Override public boolean optionCreateTargetDir()            { return true; }
        @Override public boolean useExternalCompilerGeneratorExe()	{ return false; }
        @Override public String generatorTargetDir()                { return EPSILON_TARGET_DIR_DEFAULT; }
        @Override public String additionalGeneratorOptions()        { return ""; }
        @Override public String evaluatorGeneratorType()            { return DEFAULT_EVALUATOR_TYPE; }
        @Override public String generatorExecutablePath()           {
        	if (ResourceExtractor.isWindows())
            	return EPSILON_EXE_DEFAULT + ".exe"; 
        	else
        		return EPSILON_EXE_DEFAULT; 
        }
    };
    
    @Override
    public IEpsilonPreferences defaults() {
        return DEFAULT;
    }
    
    @Override
    public void initializeDefaultPreferences() {
        storeDefault(key(GENERATOR_EXE_PATH), defaults().generatorExecutablePath());
        storeDefault(key(USE_EXTERNAL_GENERATOR_EXE), defaults().useExternalCompilerGeneratorExe());
        storeDefault(key(GENERATOR_TARGET_DIR), defaults().generatorTargetDir());
        storeDefault(key(OPTION_CREATE_TARGET_DIR), defaults().optionCreateTargetDir());
        storeDefault(key(OPTION_NO_CONSTANT_TREES_COLLAPSING), defaults().optionNoConstantTreesCollapsing());
        storeDefault(key(OPTION_GENERATION_ONLY), defaults().optionGenerationOnly());
        storeDefault(key(OPTION_NO_REFERENCE_COUNTING), defaults().optionNoReferenceCounting());
        storeDefault(key(OPTION_IGNORE_TOKEN_MARKS), defaults().optionIgnoreTokenMarks());
        storeDefault(key(OPTION_SPACE_INSTEAD_NL), defaults().optionSpaceInsteadNL());
        storeDefault(key(ADDITIONAL_GENERATOR_OPTIONS), defaults().additionalGeneratorOptions());
        storeDefault(key(EVALUATOR_GENERATOR_TYPE), defaults().evaluatorGeneratorType());        
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
            return this.preferenceStore.get(key(GENERATOR_EXE_PATH), fallback.generatorExecutablePath());
        }

        @Override
        public boolean useExternalCompilerGeneratorExe() {
        	return this.preferenceStore.getBoolean(key(USE_EXTERNAL_GENERATOR_EXE), fallback.useExternalCompilerGeneratorExe());
        }
        
        @Override
        public String generatorTargetDir() {
            return this.preferenceStore.get(key(GENERATOR_TARGET_DIR), fallback.generatorTargetDir());
        }
        
        @Override
        public boolean optionCreateTargetDir() {
            return this.preferenceStore.getBoolean(key(OPTION_CREATE_TARGET_DIR), fallback.optionCreateTargetDir());
        }

        @Override
        public boolean optionNoConstantTreesCollapsing() {
            return this.preferenceStore.getBoolean(key(OPTION_NO_CONSTANT_TREES_COLLAPSING), fallback.optionNoConstantTreesCollapsing());
        }

        @Override
        public boolean optionGenerationOnly() {
            return this.preferenceStore.getBoolean(key(OPTION_GENERATION_ONLY), fallback.optionGenerationOnly());
        }

        @Override
        public boolean optionNoOptimization() {
            return this.preferenceStore.getBoolean(key(OPTION_NO_OPTIMIZATION), fallback.optionNoOptimization());
        }

        @Override
        public boolean optionNoReferenceCounting() {
            return this.preferenceStore.getBoolean(key(OPTION_NO_REFERENCE_COUNTING), fallback.optionNoReferenceCounting());
        }

        @Override
        public boolean optionIgnoreTokenMarks() {
            return this.preferenceStore.getBoolean(key(OPTION_IGNORE_TOKEN_MARKS), fallback.optionIgnoreTokenMarks());
        }

        @Override
        public boolean optionSpaceInsteadNL() {
            return this.preferenceStore.getBoolean(key(OPTION_SPACE_INSTEAD_NL), fallback.optionSpaceInsteadNL());
        }

        @Override
        public String additionalGeneratorOptions() {
            return this.preferenceStore.get(key(ADDITIONAL_GENERATOR_OPTIONS), fallback.additionalGeneratorOptions());
        }
        
        @Override
        public String evaluatorGeneratorType() {
            return this.preferenceStore.get(key(EVALUATOR_GENERATOR_TYPE), fallback.evaluatorGeneratorType());
        }
    }

    @Override
    public IEpsilonPreferences workspacePreferences() {
        IEclipsePreferences preferenceStore = InstanceScope.INSTANCE.getNode(languageName);
        return new PreferenceStoreBasedPreferencesAccess(preferenceStore, DEFAULT);
    }
    
    @Override
    public IEpsilonPreferences projectPreferences(IProject project) {
        IEclipsePreferences projectPreferenceStore = new ProjectScope(project).getNode(languageName);
        return new PreferenceStoreBasedPreferencesAccess(projectPreferenceStore, workspacePreferences());
    }
    
    private void storeDefault(String preferenceName, String value) {
        getPreferenceStore().put(key(preferenceName), value);
    }
    
    private void storeDefault(String preferenceName, boolean value) {
        getPreferenceStore().putBoolean(key(preferenceName), value);
    }

    private IEclipsePreferences getPreferenceStore() {
        return InstanceScope.INSTANCE.getNode(languageName);
    }
    
    
}
