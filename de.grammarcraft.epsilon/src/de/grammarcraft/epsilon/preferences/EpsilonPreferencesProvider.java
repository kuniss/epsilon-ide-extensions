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

import static de.grammarcraft.epsilon.preferences.IEpsilonPreferences.*;

/**
 * Constant definitions for plug-in preferences
 */
public class EpsilonPreferencesProvider implements IEpsilonPreferencesProvider {
    
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
        @Override public boolean optionGenerationOnly()             { return true;  }
        @Override public String generatorTargetDir()                { return EPSILON_TARGET_DIR_DEFAULT; }
        @Override public String generatorExecutablePath()           { return EPSILON_EXE_DEFAULT; }
        @Override public String additionalGeneratorOptions()        { return ""; }
    };
    
    @Override
    public IEpsilonPreferences defaults() {
        return DEFAULT;
    }
    
    @Override
    public void initializeDefaultPreferences() {
        storeDefault(key(GENERATOR_EXE_PATH), defaults().generatorExecutablePath());
        storeDefault(key(GENERATOR_TARGET_DIR), defaults().generatorTargetDir());
        storeDefault(key(ADDITIONAL_GENERATOR_OPTIONS), defaults().additionalGeneratorOptions());
        storeDefault(key(OPTION_NO_CONSTANT_TREES_COLLAPSING), defaults().optionNoConstantTreesCollapsing());
        storeDefault(key(OPTION_GENERATION_ONLY), defaults().optionGenerationOnly());
        storeDefault(key(OPTION_NO_REFERENCE_COUNTING), defaults().optionNoReferenceCounting());
        storeDefault(key(OPTION_IGNORE_TOKEN_MARKS), defaults().optionIgnoreTokenMarks());
        storeDefault(key(OPTION_SPACE_INSTEAD_NL), defaults().optionSpaceInsteadNL());
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
        public String generatorTargetDir() {
            return this.preferenceStore.get(key(GENERATOR_TARGET_DIR), fallback.generatorTargetDir());
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
