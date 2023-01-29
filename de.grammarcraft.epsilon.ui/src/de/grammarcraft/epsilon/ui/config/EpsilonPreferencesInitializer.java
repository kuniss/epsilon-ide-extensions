/**
 * 
 */
package de.grammarcraft.epsilon.ui.config;

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import de.grammarcraft.epsilon.preferences.EpsilonPreferences;

/**
 * @author Michael Clay - Initial contribution and API
 * @since 2.1
 */
@Singleton
public class EpsilonPreferencesInitializer implements IPreferenceStoreInitializer {
    
    private EpsilonPreferences epsilonPreferences;

    @Inject
    public void setEpsilonPreferences(EpsilonPreferences epsilonPreferences) {
        this.epsilonPreferences = epsilonPreferences;
    }

    @Override
    public void initialize(IPreferenceStoreAccess preferenceStoreAccess) {
        IPreferenceStore store = preferenceStoreAccess.getWritablePreferenceStore();
        initializeEpsilonPreferences(store);
    }

    protected void initializeEpsilonPreferences(IPreferenceStore store) {
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_EXE_PATH), EpsilonPreferences.getGeneratorExecutablePath());
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_TARGET_DIR), EpsilonPreferences.getGeneratorTargetDir());
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_ADDITIONAL_OPTIONS), EpsilonPreferences.getAdditionalGeneratorOptions());
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_OPTION_GENERATION_ONLY), EpsilonPreferences.getGenerationOnly());
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS), EpsilonPreferences.getIgnoreTokenMarks());
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING), EpsilonPreferences.getNoConstantTreesCollapsing());
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_OPTION_NO_OPTIMIZATION), EpsilonPreferences.getNoOptimization());
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_OPTION_NO_REFERENCE_COUNTING), EpsilonPreferences.getNoReferenceCounting());
        store.setDefault(epsilonPreferences.getPropertyKey(EpsilonPreferences.P_GENERATOR_OPTION_SPACE_INSTEAD_NL), EpsilonPreferences.getSpaceInsteadNL());
    }

}
