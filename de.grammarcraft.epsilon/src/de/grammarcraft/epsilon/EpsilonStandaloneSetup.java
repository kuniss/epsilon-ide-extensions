/*
 * generated by Xtext 2.20.0
 */
package de.grammarcraft.epsilon;


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
public class EpsilonStandaloneSetup extends EpsilonStandaloneSetupGenerated {

	public static void doSetup() {
		new EpsilonStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}