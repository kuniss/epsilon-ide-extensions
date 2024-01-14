/**
 * Copyright 2023 kuniss@grammarcraft.de
 */
package de.grammarcraft.epsilon.ui.config;

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import de.grammarcraft.epsilon.preferences.IEpsilonPreferences;
import de.grammarcraft.epsilon.preferences.IEpsilonPreferencesProvider;

/**
 * This implementation and idea is derived from 
 * org.eclipse.xtext.builder_2.25.0.v20210301-0928.jar:org.eclipse.xtext.builder.preferences.BuilderPreferenceAccess.Initializer
 * 
 * @author kuniss@grammarcraft.de
 */
@Singleton
public class EpsilonPreferencesInitializer implements IPreferenceStoreInitializer {
    
    private IEpsilonPreferencesProvider preferences;

    @Inject
    public void setEpsilonPreferences(IEpsilonPreferencesProvider epsilonPreferences) {
        this.preferences = epsilonPreferences;
    }

    @Override
    public void initialize(IPreferenceStoreAccess preferenceStoreAccess) {
        IPreferenceStore store = preferenceStoreAccess.getWritablePreferenceStore();
        initializeEpsilonPreferences(store);
    }

    protected void initializeEpsilonPreferences(IPreferenceStore store) {
        store.setDefault(preferences.key(IEpsilonPreferences.GENERATOR_EXE_PATH), preferences.defaults().generatorExecutablePath());
        store.setDefault(preferences.key(IEpsilonPreferences.USE_EXTERNAL_GENERATOR_EXE), preferences.defaults().useExternalCompilerGeneratorExe());
        store.setDefault(preferences.key(IEpsilonPreferences.GENERATOR_TARGET_DIR), preferences.defaults().generatorTargetDir());
        store.setDefault(preferences.key(IEpsilonPreferences.ADDITIONAL_GENERATOR_OPTIONS), preferences.defaults().additionalGeneratorOptions());
        store.setDefault(preferences.key(IEpsilonPreferences.OPTION_CREATE_TARGET_DIR), preferences.defaults().optionCreateTargetDir());
        store.setDefault(preferences.key(IEpsilonPreferences.OPTION_GENERATION_ONLY), preferences.defaults().optionGenerationOnly());
        store.setDefault(preferences.key(IEpsilonPreferences.OPTION_IGNORE_TOKEN_MARKS), preferences.defaults().optionIgnoreTokenMarks());
        store.setDefault(preferences.key(IEpsilonPreferences.OPTION_NO_CONSTANT_TREES_COLLAPSING), preferences.defaults().optionNoConstantTreesCollapsing());
        store.setDefault(preferences.key(IEpsilonPreferences.OPTION_NO_OPTIMIZATION), preferences.defaults().optionNoOptimization());
        store.setDefault(preferences.key(IEpsilonPreferences.OPTION_NO_REFERENCE_COUNTING), preferences.defaults().optionNoReferenceCounting());
        store.setDefault(preferences.key(IEpsilonPreferences.OPTION_SPACE_INSTEAD_NL), preferences.defaults().optionSpaceInsteadNL());
        store.setDefault(preferences.key(IEpsilonPreferences.EVALUATOR_GENERATOR_TYPE), preferences.defaults().evaluatorGeneratorType());
    }

}
