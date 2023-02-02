package de.grammarcraft.epsilon.preferences;

import org.eclipse.core.resources.IProject;

import com.google.inject.ImplementedBy;

@ImplementedBy(EpsilonPreferencesProvider.class)
public interface IEpsilonPreferencesProvider {

    void initializeDefaultPreferences();

    IEpsilonPreferences defaults();

    IEpsilonPreferences workspacePreferences();

    IEpsilonPreferences projectPreferences(IProject project);

    String key(String preferenceName);

}