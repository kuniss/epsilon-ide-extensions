package de.grammarcraft.epsilon.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.core.runtime.preferences.DefaultScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;

/**
 * Class used to initialize default preference values.
 */
public class PreferenceInitializer extends AbstractPreferenceInitializer {

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer#initializeDefaultPreferences()
	 */
	public void initializeDefaultPreferences() {
	    getPreferenceStore().put(EpsilonPreferences.P_GENERATOR_EXE_PATH, EpsilonPreferences.EPSILON_EXE_DEFAULT);
        getPreferenceStore().put(EpsilonPreferences.P_GENERATOR_TARGET_DIR, EpsilonPreferences.EPSILON_TARGET_DIR_DEFAULT);
        getPreferenceStore().put(EpsilonPreferences.P_GENERATOR_ADDITIONAL_OPTIONS, "");
        getPreferenceStore().putBoolean(EpsilonPreferences.P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING, false);
        getPreferenceStore().putBoolean(EpsilonPreferences.P_GENERATOR_OPTION_GENERATION_ONLY, true);
        getPreferenceStore().putBoolean(EpsilonPreferences.P_GENERATOR_OPTION_NO_REFERENCE_COUNTING, false);
        getPreferenceStore().putBoolean(EpsilonPreferences.P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS, false);
        getPreferenceStore().putBoolean(EpsilonPreferences.P_GENERATOR_OPTION_SPACE_INSTEAD_NL, true);
	}

    public static IEclipsePreferences getPreferenceStore() {
        return DefaultScope.INSTANCE.getNode("de.grammarcraft.epsilon");
    }

}
