package de.grammarcraft.epsilon.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import com.google.inject.Inject;

/**
 * Class used to initialize default preference values.
 */
public class PreferenceInitializer extends AbstractPreferenceInitializer {

    @Inject IEpsilonPreferencesProvider preferences;
    
	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer#initializeDefaultPreferences()
	 */
	public void initializeDefaultPreferences() {
	    preferences.initializeDefaultPreferences();
	}

}
