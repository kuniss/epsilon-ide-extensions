package de.grammarcraft.epsilon.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import com.google.inject.Inject;

/**
 * Class used to initialize default preference values.
 */
public class PreferenceInitializer extends AbstractPreferenceInitializer {

    @Inject EpsilonPreferences epsilonPreferences;
    
	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer#initializeDefaultPreferences()
	 */
	public void initializeDefaultPreferences() {
	    epsilonPreferences.storeDefault(epsilonPreferences.keyFor(EpsilonPreferences.P_GENERATOR_EXE_PATH), epsilonPreferences.defaultFor().generatorExecutablePath());
        epsilonPreferences.storeDefault(epsilonPreferences.keyFor(EpsilonPreferences.P_GENERATOR_TARGET_DIR), epsilonPreferences.defaultFor().generatorTargetDir());
        epsilonPreferences.storeDefault(epsilonPreferences.keyFor(EpsilonPreferences.P_GENERATOR_ADDITIONAL_OPTIONS), epsilonPreferences.defaultFor().additionalGeneratorOptions());
        epsilonPreferences.storeDefault(epsilonPreferences.keyFor(EpsilonPreferences.P_GENERATOR_OPTION_NO_CONSTANT_TREES_COLLABSING), epsilonPreferences.defaultFor().optionNoConstantTreesCollapsing());
        epsilonPreferences.storeDefault(epsilonPreferences.keyFor(EpsilonPreferences.P_GENERATOR_OPTION_GENERATION_ONLY), epsilonPreferences.defaultFor().optionGenerationOnly());
        epsilonPreferences.storeDefault(epsilonPreferences.keyFor(EpsilonPreferences.P_GENERATOR_OPTION_NO_REFERENCE_COUNTING), epsilonPreferences.defaultFor().optionNoReferenceCounting());
        epsilonPreferences.storeDefault(epsilonPreferences.keyFor(EpsilonPreferences.P_GENERATOR_OPTION_IGNORE_TOKEN_MARKS), epsilonPreferences.defaultFor().optionIgnoreTokenMarks());
        epsilonPreferences.storeDefault(epsilonPreferences.keyFor(EpsilonPreferences.P_GENERATOR_OPTION_SPACE_INSTEAD_NL), epsilonPreferences.defaultFor().optionSpaceInsteadNL());
	}

}
